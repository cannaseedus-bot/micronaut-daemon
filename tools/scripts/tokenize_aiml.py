#!/usr/bin/env python3
"""Tokenize a compiled AIML JSONL corpus with the selected model tokenizer.

The .bin output is a headerless stream of little-endian uint32 token IDs. It can
use the local Hugging Face tokenizer and chat template, or llama.cpp's native
tokenizer. A JSON sidecar records provenance; the bin is data, not weights.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import struct
import subprocess
import tempfile
from pathlib import Path
from typing import Any, Iterator


def walk_text(node: Any) -> Iterator[str]:
    if isinstance(node, str):
        yield node
    elif isinstance(node, list):
        for item in node:
            yield from walk_text(item)
    elif isinstance(node, dict):
        # AIML <think> and <srai> are control/state operations, not assistant-visible text.
        if node.get("tag") in {"think", "srai"}:
            return
        # Compiled AIML template AST nodes store ordered children in content.
        if "content" in node:
            yield from walk_text(node["content"])


def template_text(category: dict[str, Any]) -> str:
    """Flatten only the AIML template, never its pattern/that match fields."""
    nodes = category.get("nodes", [])
    templates = [node for node in nodes if isinstance(node, dict) and node.get("tag") == "template"]
    return " ".join("".join(walk_text(templates)).split())


def corpus_text(jsonl_path: Path) -> tuple[str, int]:
    rows: list[str] = []
    categories = 0
    with jsonl_path.open("r", encoding="utf-8") as stream:
        for line_no, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"{jsonl_path}:{line_no}: invalid JSONL: {exc}") from exc
            if record.get("@kind") != "micronaut.aiml.category.v1":
                continue
            category = record.get("record", {})
            pattern = " ".join(str(category.get("pattern", "")).split())
            that = " ".join(str(category.get("that", "")).split())
            topic = " ".join(str(category.get("topic", "")).split())
            template = template_text(category)
            if not template:
                continue
            fields = [f"<pattern> {pattern} </pattern>"]
            if that:
                fields.append(f"<that> {that} </that>")
            if topic:
                fields.append(f"<topic> {topic} </topic>")
            fields.append(f"<template> {template} </template>")
            rows.append(" ".join(fields))
            categories += 1
    if not rows:
        raise ValueError(f"no AIML category records found in {jsonl_path}")
    # One category per line gives the model a stable boundary between examples.
    return "\n".join(rows) + "\n", categories


def corpus_examples(jsonl_path: Path) -> Iterator[tuple[str, str, str, str]]:
    """Yield pattern, that, topic, and flattened template for each category."""
    with jsonl_path.open("r", encoding="utf-8") as stream:
        for line_no, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError as exc:
                raise ValueError(f"{jsonl_path}:{line_no}: invalid JSONL: {exc}") from exc
            if record.get("@kind") != "micronaut.aiml.category.v1":
                continue
            category = record.get("record", {})
            pattern = " ".join(str(category.get("pattern", "")).split())
            that = " ".join(str(category.get("that", "")).split())
            topic = " ".join(str(category.get("topic", "")).split())
            template = template_text(category)
            if not template:
                continue
            yield pattern, that, topic, template


def sha256(path: Path) -> str:
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--input", required=True, type=Path, help="compiled AIML JSONL")
    source = parser.add_mutually_exclusive_group(required=True)
    source.add_argument("--tokenizer-json", type=Path, help="Hugging Face tokenizer.json")
    source.add_argument("--model", type=Path, help="GGUF containing the target tokenizer vocabulary")
    parser.add_argument("--tokenizer-config", type=Path, help="HF tokenizer_config.json, used with --tokenizer-json")
    parser.add_argument("--model-config", type=Path, help="model config.json for provenance metadata")
    parser.add_argument("--tokenizer", type=Path, help="llama-tokenize executable built with --output-bin support; used with --model")
    parser.add_argument("--output", required=True, type=Path, help="destination token ID .bin")
    parser.add_argument("--no-bos", action="store_true", help="suppress tokenizer-configured BOS behavior")
    args = parser.parse_args()

    required_files = [("input", args.input)]
    if args.tokenizer_json:
        required_files.append(("tokenizer-json", args.tokenizer_json))
        if args.tokenizer_config:
            required_files.append(("tokenizer-config", args.tokenizer_config))
        if args.model_config:
            required_files.append(("model-config", args.model_config))
        if args.tokenizer:
            parser.error("--tokenizer is only used with --model, not --tokenizer-json")
    else:
        if not args.tokenizer or args.tokenizer_config:
            parser.error("--model requires --tokenizer and cannot use --tokenizer-config")
        required_files.extend((("model", args.model), ("tokenizer", args.tokenizer)))
    for label, path in required_files:
        if not path.is_file():
            parser.error(f"{label} file does not exist: {path}")

    args.output.parent.mkdir(parents=True, exist_ok=True)
    category_count = 0
    if args.tokenizer_json:
        try:
            from transformers import AutoTokenizer
        except ImportError as exc:
            raise RuntimeError("HF tokenizer mode requires the 'transformers' Python package") from exc
        config = json.loads(args.tokenizer_config.read_text(encoding="utf-8")) if args.tokenizer_config else {}
        tokenizer = AutoTokenizer.from_pretrained(
            str(args.tokenizer_json.parent), local_files_only=True,
            trust_remote_code=False, fix_mistral_regex=False,
        )
        if not tokenizer.chat_template:
            raise ValueError(f"no chat template found beside {args.tokenizer_json}")
        try:
            with args.output.open("wb") as out:
                for pattern, that, topic, answer in corpus_examples(args.input):
                    context = []
                    if that:
                        context.append(f"Previous response: {that}")
                    if topic:
                        context.append(f"Topic: {topic}")
                    user_text = "\n".join(context + [pattern])
                    ids = tokenizer.apply_chat_template(
                        [{"role": "user", "content": user_text},
                         {"role": "assistant", "content": answer}],
                        tokenize=True, add_generation_prompt=False,
                    )
                    if args.no_bos and ids and ids[0] == tokenizer.bos_token_id:
                        ids = ids[1:]
                    if ids:
                        out.write(struct.pack(f"<{len(ids)}I", *ids))
                    category_count += 1
        except Exception:
            args.output.unlink(missing_ok=True)
            raise
        tokenizer_info = {
            "tokenizer_json": str(args.tokenizer_json.resolve()),
            "tokenizer_json_sha256": sha256(args.tokenizer_json),
            "tokenizer_config": str(args.tokenizer_config.resolve()) if args.tokenizer_config else None,
            "tokenizer_config_sha256": sha256(args.tokenizer_config) if args.tokenizer_config else None,
            "chat_template": str((args.tokenizer_json.parent / "chat_template.jinja").resolve()),
            "chat_template_sha256": sha256(args.tokenizer_json.parent / "chat_template.jinja") if (args.tokenizer_json.parent / "chat_template.jinja").is_file() else None,
            "model_config": str(args.model_config.resolve()) if args.model_config else None,
            "model_config_sha256": sha256(args.model_config) if args.model_config else None,
            "model_architectures": json.loads(args.model_config.read_text(encoding="utf-8")).get("architectures") if args.model_config else None,
            "model_type": json.loads(args.model_config.read_text(encoding="utf-8")).get("model_type") if args.model_config else None,
            "configured_bos_token_id": json.loads(args.model_config.read_text(encoding="utf-8")).get("bos_token_id") if args.model_config else None,
            "configured_eos_token_id": json.loads(args.model_config.read_text(encoding="utf-8")).get("eos_token_id") if args.model_config else None,
            "use_bidirectional_attention": json.loads(args.model_config.read_text(encoding="utf-8")).get("use_bidirectional_attention") if args.model_config else None,
            "vocab_size": tokenizer.vocab_size,
            "bos_policy": "suppressed_after_template" if args.no_bos else "chat_template",
            "tokenizer_add_bos_token": config.get("add_bos_token"),
            "tokenizer_add_eos_token": config.get("add_eos_token"),
            "training_format": "user_assistant_chat_template",
        }
    else:
        text, category_count = corpus_text(args.input)
        with tempfile.TemporaryDirectory(prefix="aiml-tokenize-") as temporary:
            prompt_path = Path(temporary) / "corpus.txt"
            prompt_path.write_text(text, encoding="utf-8", newline="\n")
            command = [
                str(args.tokenizer), "--model", str(args.model), "--file", str(prompt_path),
                "--output-bin", str(args.output), "--log-disable", "--no-escape",
            ]
            if args.no_bos:
                command.append("--no-bos")
            completed = subprocess.run(command, text=True, capture_output=True)
            if completed.returncode:
                args.output.unlink(missing_ok=True)
                raise RuntimeError(
                    f"native tokenizer failed ({completed.returncode}):\n{completed.stderr.strip()}"
                )
        model_stat = args.model.stat()
        tokenizer_info = {
            "tokenizer_model": str(args.model.resolve()),
            "tokenizer_model_bytes": model_stat.st_size,
            "tokenizer_model_mtime_ns": model_stat.st_mtime_ns,
            "tokenizer_executable": str(args.tokenizer.resolve()),
            "bos_policy": "suppressed" if args.no_bos else "model_default",
        }

    size = args.output.stat().st_size
    if size == 0 or size % 4:
        args.output.unlink(missing_ok=True)
        raise RuntimeError(f"tokenizer produced invalid uint32 stream ({size} bytes)")
    manifest = {
        "schema": "micronaut.token-ids.v1",
        "format": "raw_uint32_le",
        "token_count": size // 4,
        "token_bytes": size,
        "category_count": category_count,
        "source_jsonl": str(args.input.resolve()),
        "source_sha256": sha256(args.input),
        **tokenizer_info,
        "bin_sha256": sha256(args.output),
        "note": "Token IDs are vocabulary-specific training data, not trained model weights.",
    }
    manifest_path = args.output.with_suffix(args.output.suffix + ".json")
    manifest_path.write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {manifest['token_count']:,} token IDs ({size:,} bytes): {args.output}")
    print(f"Categories: {category_count:,}; metadata: {manifest_path}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, ValueError, RuntimeError) as exc:
        raise SystemExit(f"tokenize_aiml: error: {exc}")
