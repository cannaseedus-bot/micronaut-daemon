#!/usr/bin/env python3
"""Train a tiny Gemma3 causal LM from random initialization on CPU.

Consumes tokenize_aiml.py's raw little-endian uint32 token stream and writes a
Transformers-compatible Gemma3ForCausalLM checkpoint with Safetensors weights.
This is a compact scratch model, not a fine-tune or a reproduction of the
large Gemma3 checkpoint dimensions.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import os
import random
import struct
import time
from pathlib import Path


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--tokens", type=Path, required=True, help="raw uint32 little-endian token bin")
    parser.add_argument("--tokenizer-dir", type=Path, required=True, help="directory containing tokenizer.json and chat_template.jinja")
    parser.add_argument("--model-config", type=Path, required=True, help="source Gemma model config.json, used for tokenizer IDs/provenance")
    parser.add_argument("--output", type=Path, required=True, help="new checkpoint directory")
    parser.add_argument("--steps", type=int, default=None,
                        help="maximum optimizer steps; default 200 unless --max-hours is set")
    parser.add_argument("--max-hours", type=float, default=None,
                        help="optional wall-clock training budget; checkpoints are saved periodically")
    parser.add_argument("--checkpoint-every", type=int, default=5000,
                        help="write an inference checkpoint every N steps")
    parser.add_argument("--initialize-from", type=Path,
                        help="Safetensors checkpoint to warm-start; optimizer state starts fresh")
    parser.add_argument("--resume-from", type=Path,
                        help="resume model, optimizer, step, and RNG from a complete checkpoint directory")
    parser.add_argument("--threads", type=int, default=4)
    parser.add_argument("--sequence-length", type=int, default=32)
    parser.add_argument("--learning-rate", type=float, default=0.0003)
    parser.add_argument("--model-preset", choices=("compact", "300m"), default="compact",
                        help="compact (~8M parameters) or Gemma3-style ~300M architecture")
    parser.add_argument("--optimizer-backend", choices=("cpu", "opencl"), default="cpu",
                        help="AdamW update backend; forward and backward remain in PyTorch CPU")
    parser.add_argument("--seed", type=int, default=42)
    parser.add_argument("--layers", type=int, default=2)
    parser.add_argument("--hidden-size", type=int, default=32)
    parser.add_argument("--heads", type=int, default=4)
    parser.add_argument("--intermediate-size", type=int, default=64)
    parser.add_argument("--log-every", type=int, default=20)
    args = parser.parse_args()

    if args.model_preset == "300m":
        args.layers, args.hidden_size, args.heads, args.intermediate_size = 12, 768, 12, 3072

    if args.steps is None and args.max_hours is None:
        args.steps = 200

    for label, path in (("tokens", args.tokens), ("tokenizer directory", args.tokenizer_dir), ("model config", args.model_config)):
        if not path.exists():
            parser.error(f"{label} does not exist: {path}")
    if args.tokens.stat().st_size % 4:
        parser.error("token binary size must be a multiple of four bytes")
    if args.steps is not None and args.steps < 1:
        parser.error("steps must be positive when specified")
    if args.max_hours is not None and args.max_hours <= 0:
        parser.error("max-hours must be positive when specified")
    if args.threads < 1 or args.sequence_length < 2 or args.layers < 1 or args.checkpoint_every < 1:
        parser.error("threads, layers, checkpoint-every, and sequence length must be positive")
    if args.hidden_size % args.heads or (args.hidden_size // args.heads) % 2:
        parser.error("hidden size must divide evenly into heads with an even head dimension")
    if args.initialize_from and not args.initialize_from.is_dir():
        parser.error(f"initialize-from checkpoint does not exist: {args.initialize_from}")
    if args.resume_from and not args.resume_from.is_dir():
        parser.error(f"resume-from checkpoint does not exist: {args.resume_from}")
    if args.initialize_from and args.resume_from:
        parser.error("choose either --initialize-from or --resume-from")
    if args.output.exists() and any(args.output.iterdir()) and not args.resume_from:
        parser.error(f"output directory is not empty: {args.output}")

    # Set CPU threading before torch's CPU backend is initialized.
    os.environ["CUDA_VISIBLE_DEVICES"] = ""
    os.environ["OMP_NUM_THREADS"] = str(args.threads)
    os.environ["MKL_NUM_THREADS"] = str(args.threads)
    os.environ["OPENBLAS_NUM_THREADS"] = str(args.threads)

    import numpy as np
    import torch
    from transformers import AutoTokenizer, Gemma3ForCausalLM, Gemma3TextConfig

    torch.set_num_threads(args.threads)
    torch.set_num_interop_threads(max(1, min(args.threads, 4)))
    torch.manual_seed(args.seed)
    np.random.seed(args.seed)
    random.seed(args.seed)
    device = torch.device("cpu")

    metadata_path = args.tokens.with_suffix(args.tokens.suffix + ".json")
    token_metadata = json.loads(metadata_path.read_text(encoding="utf-8")) if metadata_path.is_file() else {}
    if token_metadata.get("format") != "raw_uint32_le":
        parser.error("token metadata must declare format=raw_uint32_le")
    token_ids = np.fromfile(args.tokens, dtype="<u4").astype(np.int64)
    if len(token_ids) <= args.sequence_length:
        parser.error("token stream is shorter than the requested training sequence")

    tokenizer = AutoTokenizer.from_pretrained(
        str(args.tokenizer_dir), local_files_only=True, trust_remote_code=False,
        fix_mistral_regex=False,
    )
    source_config = json.loads(args.model_config.read_text(encoding="utf-8"))
    vocab_size = max(len(tokenizer), int(source_config.get("vocab_size", tokenizer.vocab_size)))
    if int(token_ids.max()) >= vocab_size:
        parser.error(f"token ID {int(token_ids.max())} exceeds model vocabulary size {vocab_size}")
    parameter_estimate = (
        vocab_size * args.hidden_size
        + args.layers * (
            2 * args.hidden_size * args.hidden_size
            + 2 * args.hidden_size * (max(1, args.heads // 4) * (args.hidden_size // args.heads))
            + 3 * args.hidden_size * args.intermediate_size
            + 4 * args.hidden_size
        )
        + args.hidden_size
    )
    # FP32 weights + gradients + Adam first/second moments, plus a 2 GiB
    # allowance for activations, tokenizer, and runtime overhead. This is a
    # conservative training-memory estimate, not a hard OS process limit.
    estimated_training_gib = parameter_estimate * 16 / 1024**3 + 2.0
    memory_budget_gib = 10.0
    if estimated_training_gib > memory_budget_gib:
        parser.error(
            f"estimated training footprint {estimated_training_gib:.1f} GiB exceeds the "
            f"{memory_budget_gib:.1f} GiB RAM budget ({parameter_estimate:,} parameters)"
        )
    if args.model_preset == "300m":
        # Chunked transfers avoid full-size staging copies. This floor covers
        # FP32 model weights, gradients, Adam moments, and modest activations.
        required_ram = 8 * 1024**3
        available_ram = None
        if os.name == "nt":
            import ctypes

            class _MemoryStatus(ctypes.Structure):
                _fields_ = [("dwLength", ctypes.c_ulong), ("dwMemoryLoad", ctypes.c_ulong),
                            ("ullTotalPhys", ctypes.c_ulonglong), ("ullAvailPhys", ctypes.c_ulonglong),
                            ("ullTotalPageFile", ctypes.c_ulonglong), ("ullAvailPageFile", ctypes.c_ulonglong),
                            ("ullTotalVirtual", ctypes.c_ulonglong), ("ullAvailVirtual", ctypes.c_ulonglong),
                            ("ullAvailExtendedVirtual", ctypes.c_ulonglong)]

            _memory_status = _MemoryStatus()
            _memory_status.dwLength = ctypes.sizeof(_memory_status)
            if ctypes.windll.kernel32.GlobalMemoryStatusEx(ctypes.byref(_memory_status)):
                available_ram = int(_memory_status.ullAvailPhys)
        if available_ram is not None and available_ram < required_ram:
            parser.error(
                f"the 300m preset needs at least 8 GiB currently available RAM and must fit the "
                f"10 GiB estimated training budget; "
                f"detected {available_ram / 1024**3:.1f} GiB. Estimated parameters: {parameter_estimate:,}"
            )
    print(f"model_preset={args.model_preset} estimated_parameters={parameter_estimate:,} "
          f"estimated_training_gib={estimated_training_gib:.1f} budget_gib={memory_budget_gib:.1f}", flush=True)

    source_layers = ["sliding_attention", "full_attention"]
    config = Gemma3TextConfig(
        vocab_size=vocab_size,
        hidden_size=args.hidden_size,
        intermediate_size=args.intermediate_size,
        num_hidden_layers=args.layers,
        num_attention_heads=args.heads,
        num_key_value_heads=max(1, args.heads // 4),
        head_dim=args.hidden_size // args.heads,
        max_position_embeddings=args.sequence_length,
        sliding_window=args.sequence_length,
        layer_types=[source_layers[i % len(source_layers)] for i in range(args.layers)],
        use_bidirectional_attention=False,
        tie_word_embeddings=True,
        hidden_activation="gelu_pytorch_tanh",
        rms_norm_eps=float(source_config.get("rms_norm_eps", 1e-6)),
        rope_theta=float(source_config.get("rope_theta", 1_000_000.0)),
        rope_local_base_freq=float(source_config.get("rope_local_base_freq", 10_000.0)),
        query_pre_attn_scalar=int(source_config.get("query_pre_attn_scalar", 256)),
        bos_token_id=tokenizer.bos_token_id,
        eos_token_id=source_config.get("eos_token_id", tokenizer.eos_token_id),
        pad_token_id=tokenizer.pad_token_id,
        attn_implementation="eager",
    )
    model = Gemma3ForCausalLM(config).to(device)
    checkpoint_source = args.resume_from or args.initialize_from
    if checkpoint_source:
        checkpoint_config_path = checkpoint_source / "config.json"
        weights_path = checkpoint_source / "model.safetensors"
        if not checkpoint_config_path.is_file() or not weights_path.is_file():
            parser.error("initialize-from requires config.json and model.safetensors")
        checkpoint_config = json.loads(checkpoint_config_path.read_text(encoding="utf-8"))
        expected = (config.vocab_size, config.hidden_size, config.intermediate_size,
                    config.num_hidden_layers, config.num_attention_heads,
                    config.num_key_value_heads, config.max_position_embeddings)
        actual = tuple(checkpoint_config.get(key) for key in (
            "vocab_size", "hidden_size", "intermediate_size", "num_hidden_layers",
            "num_attention_heads", "num_key_value_heads", "max_position_embeddings"))
        if actual != expected:
            parser.error("initialize-from model configuration does not match requested compact model")
        from safetensors.torch import load_file
        try:
            state_dict = load_file(str(weights_path), device="cpu")
            expected_keys = set(model.state_dict())
            if (expected_keys - set(state_dict)) == {"lm_head.weight"} and checkpoint_config.get("tie_word_embeddings"):
                state_dict["lm_head.weight"] = state_dict["model.embed_tokens.weight"]
            model.load_state_dict(state_dict, strict=True)
        except (OSError, RuntimeError, KeyError) as exc:
            parser.error(f"could not load initialize-from checkpoint: {exc}")
        if args.initialize_from:
            print(f"warm_start={args.initialize_from} optimizer_state=fresh", flush=True)
    model.train()
    if args.optimizer_backend == "opencl":
        from opencl_adamw import OpenCLAdamW
        optimizer = OpenCLAdamW(model.parameters(), learning_rate=args.learning_rate)
        optimizer_backend = optimizer.metadata
    else:
        optimizer = torch.optim.AdamW(model.parameters(), lr=args.learning_rate)
        optimizer_backend = lambda: {"optimizer_backend": "PyTorch CPU AdamW",
                                     "opencl_device": None}

    resume_state = None
    if args.resume_from:
        state_path = args.resume_from / "training_state.pt"
        if not state_path.is_file():
            parser.error("resume-from requires training_state.pt; inference-only checkpoints cannot resume exactly")
        try:
            resume_state = torch.load(state_path, map_location="cpu", weights_only=False)
            if resume_state.get("schema") != "micronaut.training_state.v1":
                parser.error("resume-from training state schema is unsupported")
            if resume_state.get("token_bin_sha256") != hashlib.sha256(args.tokens.read_bytes()).hexdigest():
                parser.error("resume-from token stream differs from the original training run")
            if resume_state.get("sequence_length") != args.sequence_length:
                parser.error("resume-from sequence length differs from the original training run")
            if resume_state.get("optimizer_backend_name") != optimizer_backend()["optimizer_backend"]:
                parser.error("resume-from optimizer backend differs from the original training run")
            optimizer.load_state_dict(resume_state["optimizer_state"])
            torch.set_rng_state(resume_state["torch_rng_state"])
            np.random.set_state(resume_state["numpy_rng_state"])
            random.setstate(resume_state["python_rng_state"])
        except (OSError, KeyError, TypeError, ValueError, RuntimeError) as exc:
            parser.error(f"could not restore training state: {exc}")
        print(f"resuming={args.resume_from} at_step={resume_state['step']}", flush=True)

    # Use a deterministic 95/5 contiguous split; every batch is one sequence.
    declared_train_tokens = token_metadata.get("train_token_count")
    if declared_train_tokens is None:
        split = max(args.sequence_length + 1, int(len(token_ids) * 0.95))
        split = min(split, len(token_ids) - args.sequence_length - 1)
    else:
        split = int(declared_train_tokens)
        if split <= args.sequence_length or len(token_ids) - split <= args.sequence_length:
            parser.error("token metadata train/validation split is too small")
    train_data = token_ids[:split]
    val_data = token_ids[split:]
    rng = np.random.default_rng(args.seed + 1)
    if resume_state:
        rng.bit_generator.state = resume_state["sample_rng_state"]
    losses: list[float] = []
    start = time.monotonic()
    deadline = start + args.max_hours * 3600 if args.max_hours is not None else None
    step_limit = str(args.steps) if args.steps is not None else f"{args.max_hours:g}h"
    checkpoint_steps: list[int] = []

    def sample(data: np.ndarray) -> torch.Tensor:
        last = len(data) - args.sequence_length - 1
        pos = int(rng.integers(0, last + 1))
        return torch.from_numpy(data[pos:pos + args.sequence_length + 1].copy()).to(torch.long)

    step = int(resume_state["step"]) if resume_state else 0
    if resume_state:
        losses = list(resume_state.get("recent_losses", []))

    def save_checkpoint(checkpoint_step: int) -> Path:
        snapshot = args.output / "checkpoints" / f"step_{checkpoint_step:08d}"
        snapshot.mkdir(parents=True, exist_ok=True)
        model.save_pretrained(snapshot, safe_serialization=True)
        training_state = {
            "schema": "micronaut.training_state.v1",
            "step": checkpoint_step,
            "sequence_length": args.sequence_length,
            "token_bin_sha256": hashlib.sha256(args.tokens.read_bytes()).hexdigest(),
            "optimizer_backend_name": optimizer_backend()["optimizer_backend"],
            "optimizer_state": optimizer.state_dict(),
            "torch_rng_state": torch.get_rng_state(),
            "numpy_rng_state": np.random.get_state(),
            "python_rng_state": random.getstate(),
            "sample_rng_state": rng.bit_generator.state,
            "recent_losses": losses[-1000:],
        }
        pending = snapshot / "training_state.pt.pending"
        torch.save(training_state, pending)
        os.replace(pending, snapshot / "training_state.pt")
        return snapshot
    while True:
        if args.steps is not None and step >= args.steps:
            break
        if deadline is not None and step > 0 and time.monotonic() >= deadline:
            break
        step += 1
        window = sample(train_data)
        inputs = window[:-1].unsqueeze(0)
        targets = window[1:].unsqueeze(0)
        optimizer.zero_grad(set_to_none=True)
        result = model(input_ids=inputs, use_cache=False)
        # Inputs and targets are already shifted by the sampled window. Avoid
        # the model's built-in label shift, which would shift targets twice.
        loss = torch.nn.functional.cross_entropy(
            result.logits.reshape(-1, result.logits.size(-1)), targets.reshape(-1))
        if not torch.isfinite(loss):
            raise RuntimeError(f"non-finite training loss at step {step}")
        loss.backward()
        torch.nn.utils.clip_grad_norm_(model.parameters(), 1.0)
        optimizer.step()
        losses.append(float(loss.detach()))
        if step == 1 or step % args.log_every == 0 or (args.steps is not None and step == args.steps):
            print(f"step={step}/{step_limit} loss={losses[-1]:.4f} elapsed={time.monotonic() - start:.1f}s", flush=True)
        if step % args.checkpoint_every == 0:
            snapshot = save_checkpoint(step)
            checkpoint_steps.append(step)
            print(f"checkpoint={snapshot}", flush=True)

    model.eval()
    with torch.no_grad():
        val_window = sample(val_data)
        val_logits = model(input_ids=val_window[:-1].unsqueeze(0), use_cache=False).logits
        val_loss = float(torch.nn.functional.cross_entropy(
            val_logits.reshape(-1, val_logits.size(-1)),
            val_window[1:].unsqueeze(0).reshape(-1)))

    args.output.mkdir(parents=True, exist_ok=True)
    model.config.architectures = ["Gemma3ForCausalLM"]
    model.config._name_or_path = str(args.output.resolve())
    model.save_pretrained(args.output, safe_serialization=True)
    tokenizer.save_pretrained(args.output)
    # Save an auditable training record alongside the Hugging Face files.
    report = {
        "schema": "micronaut.from_scratch_training.v1",
        "initialization": "resumed" if args.resume_from else ("warm_start" if args.initialize_from else "random"),
        "initialized_from": str(args.initialize_from.resolve()) if args.initialize_from else None,
        "resumed_from": str(args.resume_from.resolve()) if args.resume_from else None,
        "optimizer_state": "restored" if args.resume_from else ("fresh" if args.initialize_from else "new"),
        "architecture": "Gemma3ForCausalLM",
        "model_preset": args.model_preset,
        "device": str(device),
        "threads": args.threads,
        "cpu": "Intel Core i7-4790S (4 physical cores)",
        "steps": step,
        "steps_this_run": step - (int(resume_state["step"]) if resume_state else 0),
        "step_limit": args.steps,
        "max_hours": args.max_hours,
        "checkpoint_every": args.checkpoint_every,
        "checkpoint_steps": checkpoint_steps,
        "sequence_length": args.sequence_length,
        "learning_rate": args.learning_rate,
        "training_objective": "next_token_cross_entropy_logits_t_to_token_t_plus_1",
        **optimizer_backend(),
        "train_token_count": int(len(train_data)),
        "validation_token_count": int(len(val_data)),
        "training_loss_first": losses[0],
        "training_loss_last": losses[-1],
        "validation_loss": val_loss,
        "elapsed_seconds": round(time.monotonic() - start, 3),
        "model_parameters": sum(parameter.numel() for parameter in model.parameters()),
        "estimated_parameters": parameter_estimate,
        "estimated_training_gib": round(estimated_training_gib, 3),
        "training_memory_budget_gib": memory_budget_gib,
        "vocab_size": vocab_size,
        "use_bidirectional_attention": False,
        "token_bin": str(args.tokens.resolve()),
        "token_bin_sha256": hashlib.sha256(args.tokens.read_bytes()).hexdigest(),
        "dataset_source_sha256": token_metadata.get("source_sha256"),
        "dataset_sources": token_metadata.get("source_hashes", {}),
        "source_config": str(args.model_config.resolve()),
        "compact_scratch_config": config.to_dict(),
    }
    (args.output / "training_report.json").write_text(json.dumps(report, indent=2) + "\n", encoding="utf-8")
    print(f"Saved Safetensors checkpoint to {args.output}")
    print(f"validation_loss={val_loss:.4f}; parameters={report['model_parameters']:,}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, RuntimeError) as exc:
        raise SystemExit(f"train_gemma3_scratch: error: {exc}")
