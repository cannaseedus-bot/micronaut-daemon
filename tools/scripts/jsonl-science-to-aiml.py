#!/usr/bin/env python3
"""Convert subject-tagged instruction JSONL files into deduplicated AIML Q&A banks."""
from __future__ import annotations
import argparse
import ast
import hashlib
import json
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


def safe_text(value: object) -> str:
    return re.sub(r"\s+", " ", str(value or "")).strip()


def get_question(value: object) -> str:
    if isinstance(value, dict):
        messages = value.get("messages", [])
        if isinstance(messages, list):
            for message in messages:
                if isinstance(message, dict) and message.get("role") == "user":
                    return safe_text(message.get("content"))
        return safe_text(value.get("question") or value.get("prompt") or value.get("input"))
    text = safe_text(value)
    # Some chemistry rows store a Python-style repr of a chat-message object.
    if text.startswith("{'messages':") or text.startswith('{"messages":'):
        try:
            return get_question(ast.literal_eval(text))
        except (ValueError, SyntaxError):
            pass
    return text


def aiml_pattern(question: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[^\w ]+", " ", question, flags=re.UNICODE)).strip().upper()


def response_text(value: object) -> str:
    text = safe_text(value)
    # Do not surface hidden-reasoning tags if a shard includes them.
    text = re.sub(r"<think\b[^>]*>.*?</think\s*>", " ", text, flags=re.I | re.S)
    return safe_text(text)


def load_rows(paths: list[Path]):
    seen_files: set[bytes] = set()
    for path in paths:
        identity = hashlib.sha256(path.read_bytes()).digest()
        if identity in seen_files:
            print(f"duplicate file skipped: {path}", file=sys.stderr)
            continue
        seen_files.add(identity)
        with path.open("r", encoding="utf-8-sig") as stream:
            for line_no, line in enumerate(stream, 1):
                if not line.strip():
                    continue
                try:
                    row = json.loads(line)
                except json.JSONDecodeError as exc:
                    raise ValueError(f"{path}:{line_no}: invalid JSON: {exc}") from exc
                if not isinstance(row, dict):
                    continue
                question = get_question(row.get("instruction") or row.get("question") or row.get("prompt") or row.get("input"))
                answer = response_text(row.get("response") or row.get("answer") or row.get("output") or row.get("completion"))
                pattern = aiml_pattern(question)
                if pattern and answer:
                    yield path, pattern, answer


def convert(paths: list[Path], output: Path, subject: str) -> tuple[int, int]:
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment(f"Generated {subject} Q&A bank. Source entries are dataset responses, not medical or scientific authority."))
    seen: set[str] = set()
    count = duplicates = 0
    for _path, pattern, answer in load_rows(paths):
        if pattern in seen:
            duplicates += 1
            continue
        seen.add(pattern)
        category = ET.SubElement(root, "category")
        ET.SubElement(category, "pattern").text = pattern
        ET.SubElement(category, "template").text = answer
        count += 1
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return count, duplicates


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--chemistry", nargs="+", type=Path, default=[])
    ap.add_argument("--medical", nargs="+", type=Path, default=[])
    ap.add_argument("--physics", nargs="+", type=Path, default=[])
    ap.add_argument("--output-dir", type=Path, default=Path("data/alice/science"))
    args = ap.parse_args()
    groups = (("chemistry", args.chemistry), ("medical", args.medical), ("physics", args.physics))
    if not any(paths for _, paths in groups):
        ap.error("provide at least one subject input group")
    try:
        for subject, paths in groups:
            if not paths:
                continue
            output = args.output_dir / f"{subject}.aiml"
            count, duplicates = convert(paths, output, subject)
            print(f"{subject}: {count} unique Q&A categories; duplicates skipped={duplicates}; output={output}")
    except (OSError, ValueError) as exc:
        print(f"jsonl-science-to-aiml: {exc}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
