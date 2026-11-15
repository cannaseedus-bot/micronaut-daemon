#!/usr/bin/env python3
"""Normalize selected chat JSONL sources into Gemma-tokenized training input.

This is a text-only starter corpus builder. It preserves source provenance,
deduplicates identical user/assistant pairs, shuffles records deterministically,
and writes training records before validation records in the uint32 token bin.
"""
from __future__ import annotations

import argparse
import hashlib
import json
import random
import struct
from pathlib import Path


def get_text(row: dict, *keys: str) -> str:
    for key in keys:
        value = row.get(key)
        if isinstance(value, str) and value.strip():
            return value.strip()
    return ""


def normalize(row: dict, source: str, line_no: int):
    if "Prompt" in row:
        user = get_text(row, "Prompt")
        reasoning = get_text(row, "Step-by-step reasoning")
        answer = get_text(row, "Solution")
        assistant = "\n\n".join(x for x in (reasoning, answer) if x)
    elif "problem" in row:
        user = get_text(row, "problem")
        assistant = "\n\n".join(x for x in (get_text(row, "thinking"), get_text(row, "solution")) if x)
    elif "instruction" in row:
        user = get_text(row, "instruction")
        extra = get_text(row, "input")
        if extra:
            user += "\n\n" + extra
        assistant = get_text(row, "output", "answer")
    elif "question" in row:
        user = get_text(row, "question")
        assistant = get_text(row, "answer", "reference")
    else:
        return None
    if not user or not assistant:
        return None
    return {"source": source, "source_line": line_no, "user": user, "assistant": assistant}


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--data-dir", type=Path, required=True)
    ap.add_argument("--tokenizer-dir", type=Path, required=True)
    ap.add_argument("--output-dir", type=Path, required=True)
    ap.add_argument("--seed", type=int, default=42)
    ap.add_argument("--validation-fraction", type=float, default=0.05)
    ap.add_argument("--sequence-length", type=int, default=32)
    ap.add_argument("--sources", nargs="+", default=[
        "reasoning.jsonl", "distilled_corpus_400k_with_cot-filtered.jsonl",
        "SPP_30K_reasoning_tasks.jsonl", "taskTEXTGEN_reasoning_hypothesis_processed.jsonl",
        "qa-corpus.jsonl",
    ])
    args = ap.parse_args()
    if not 0.01 <= args.validation_fraction <= 0.2:
        ap.error("validation-fraction must be in [0.01, 0.2]")
    if args.sequence_length < 2:
        ap.error("sequence-length must be at least 2")
    for name in args.sources:
        if Path(name).name != name or not (args.data_dir / name).is_file():
            ap.error(f"source must be an existing file name under data-dir: {name}")

    from transformers import AutoTokenizer
    tokenizer = AutoTokenizer.from_pretrained(str(args.tokenizer_dir), local_files_only=True,
                                              trust_remote_code=False, fix_mistral_regex=False)
    eos = tokenizer.eos_token_id
    if eos is None:
        ap.error("Gemma tokenizer must define eos_token_id")

    records = []
    source_hashes = {}
    stats = {}
    seen = set()
    for name in args.sources:
        path = args.data_dir / name
        source_hashes[name] = hashlib.sha256(path.read_bytes()).hexdigest()
        read = accepted = duplicates = 0
        with path.open("r", encoding="utf-8") as stream:
            for line_no, line in enumerate(stream, 1):
                if not line.strip():
                    continue
                read += 1
                row = json.loads(line)
                if not isinstance(row, dict):
                    continue
                item = normalize(row, name, line_no)
                if item is None:
                    continue
                key = hashlib.sha256((item["user"] + "\0" + item["assistant"]).encode("utf-8")).digest()
                if key in seen:
                    duplicates += 1
                    continue
                seen.add(key)
                records.append(item)
                accepted += 1
        stats[name] = {"rows_read": read, "pairs_accepted": accepted, "duplicates": duplicates}

    if len(records) < 20:
        ap.error(f"only {len(records)} usable unique pairs found")
    random.Random(args.seed).shuffle(records)
    split_at = max(1, min(len(records) - 1, int(len(records) * (1.0 - args.validation_fraction))))
    train, validation = records[:split_at], records[split_at:]
    args.output_dir.mkdir(parents=True, exist_ok=True)
    normalized_path = args.output_dir / "chat_pairs.jsonl"
    with normalized_path.open("w", encoding="utf-8", newline="\n") as stream:
        for item in records:
            stream.write(json.dumps(item, ensure_ascii=False) + "\n")

    token_path = args.output_dir / "chat.tokens.bin"
    train_count = validation_count = 0
    with token_path.open("wb") as output:
        for subset, counter_name in ((train, "train"), (validation, "validation")):
            count = 0
            for item in subset:
                text = tokenizer.apply_chat_template(
                    [{"role": "user", "content": item["user"]},
                     {"role": "assistant", "content": item["assistant"]}],
                    tokenize=False, add_generation_prompt=False)
                ids = tokenizer.encode(text, add_special_tokens=False)
                if len(ids) <= args.sequence_length:
                    continue
                ids.append(eos)
                output.write(struct.pack("<" + "I" * len(ids), *ids))
                count += len(ids)
            if counter_name == "train":
                train_count = count
            else:
                validation_count = count
    if train_count <= args.sequence_length or validation_count <= args.sequence_length:
        ap.error("tokenized train or validation partition is too small")
    metadata = {
        "format": "raw_uint32_le",
        "tokenizer": str(args.tokenizer_dir.resolve()),
        "tokenizer_vocab_size": len(tokenizer),
        "eos_token_id": eos,
        "seed": args.seed,
        "validation_fraction": args.validation_fraction,
        "record_count": len(records),
        "train_token_count": train_count,
        "validation_token_count": validation_count,
        "source_sha256": hashlib.sha256("".join(source_hashes[k] for k in sorted(source_hashes)).encode()).hexdigest(),
        "source_hashes": source_hashes,
        "source_stats": stats,
    }
    token_path.with_suffix(token_path.suffix + ".json").write_text(
        json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"tokens": str(token_path), "pairs": len(records),
                      "train_tokens": train_count, "validation_tokens": validation_count,
                      "source_stats": stats}, indent=2))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
