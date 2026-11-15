#!/usr/bin/env python3
"""Convert dictionary key-grammar JSONL into a bounded, data-only AIML bank."""

from __future__ import annotations

import argparse
import json
import re
import sys
import xml.etree.ElementTree as ET
from collections import defaultdict
from pathlib import Path


def read_jsonl(path: Path):
    with path.open("r", encoding="utf-8-sig") as stream:
        for line_number, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                value = json.loads(line)
            except json.JSONDecodeError as error:
                raise ValueError(f"{path}:{line_number}: {error}") from error
            if not isinstance(value, dict):
                raise ValueError(f"{path}:{line_number}: each record must be an object")
            yield value


def safe_text(value: object) -> str:
    return re.sub(r"\s+", " ", str(value or "")).strip()


def pattern_text(value: str) -> str:
    # AIML wildcard symbols are syntax; omit terms that cannot be literal patterns.
    if not value or len(value) > 100 or any(ch in value for ch in "*#_^"):
        return ""
    return value.upper()


def add_category(root: ET.Element, pattern: str, response: str) -> None:
    category = ET.SubElement(root, "category")
    ET.SubElement(category, "pattern").text = pattern
    ET.SubElement(category, "template").text = response


def convert(lexicon_path: Path, relations_path: Path, output: Path, limit: int) -> int:
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment("Generated from dictionary JSONL. Definitions and relations are data, not executable commands."))
    seen: set[str] = set()
    count = 0
    for row in read_jsonl(lexicon_path):
        word = safe_text(row.get("word") or row.get("book"))
        definition = safe_text(row.get("definition"))
        literal = pattern_text(word)
        if not literal or not definition or literal in seen:
            continue
        seen.add(literal)
        add_category(root, f"DEFINE {literal}", definition)
        add_category(root, f"WHAT IS {literal}", definition)
        count += 1
        if limit and count >= limit:
            break

    related: dict[str, set[str]] = defaultdict(set)
    for row in read_jsonl(relations_path):
        source = pattern_text(safe_text(row.get("source_word") or row.get("from")))
        target = safe_text(row.get("to"))
        if source and target:
            related[source].add(target)
    for source in sorted(related):
        targets = sorted(related[source], key=str.casefold)
        add_category(root, f"WORDS RELATED TO {source}", ", ".join(targets[:24]))

    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    tree = ET.ElementTree(root)
    tree.write(output, encoding="UTF-8", xml_declaration=True)
    return count


def convert_candidates(source: Path, output: Path, limit: int) -> int:
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment(f"Candidate index from {source.name}. Candidate records are not verified answers."))
    seen: set[str] = set()
    count = 0
    for row in read_jsonl(source):
        key = safe_text(row.get("key"))
        if not key or key in seen or any(ch in key for ch in "*#_^"):
            continue
        seen.add(key)
        gram = safe_text(row.get("gram"))
        gram_class = safe_text(row.get("gram_class"))
        phase = safe_text(row.get("phase"))
        role = safe_text(row.get("role"))
        amount = row.get("count", 0)
        expansion = row.get("expansion", "")
        if isinstance(expansion, (dict, list)):
            expansion = json.dumps(expansion, ensure_ascii=False, sort_keys=True)
        response = (f"Candidate key {key}; gram {gram}; class {gram_class}; phase {phase}; "
                    f"role {role}; count {amount}; expansion {safe_text(expansion)}. "
                    "This is candidate evidence, not an admitted answer.")
        add_category(root, f"LOOK UP KEY {key.upper()}", response)
        count += 1
        if limit and count >= limit:
            break
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return count


def convert_records(source: Path, output: Path, limit: int) -> int:
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment(f"Generated key lookup bank from {source.name}; entries are data, not execution authority."))
    seen: set[str] = set(); count = 0
    fields = ("definition", "text", "description", "gap", "semantic_note", "expands_to",
              "relations", "templates", "patterns", "value", "executor", "authority")
    for row in read_jsonl(source):
        key = safe_text(row.get("key"))
        if not key or any(ch in key for ch in "*#_^"):
            key = safe_text(row.get("word") or row.get("book") or row.get("key"))
        if not key or key in seen or any(ch in key for ch in "*#_^"):
            continue
        seen.add(key)
        details = []
        for field in fields:
            value = row.get(field)
            if value in (None, "", [], {}):
                continue
            if isinstance(value, (dict, list)):
                value = json.dumps(value, ensure_ascii=False, sort_keys=True)
            rendered = safe_text(value)
            if rendered:
                details.append(f"{field}: {rendered[:1200]}")
        if not details:
            details = [f"{field}: {safe_text(row[field])}" for field in ("op", "table", "phase", "role", "class") if row.get(field)]
        response = f"Key {key}. " + ("; ".join(details) if details else "No descriptive fields.")
        add_category(root, f"LOOK UP KEY {key.upper()}", response)
        count += 1
        if limit and count >= limit:
            break
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return count


def convert_pairs(source: Path, output: Path, limit: int) -> int:
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment(f"Generated prompt-response bank from {source.name}; examples are data only."))
    seen: set[str] = set(); count = 0
    for row in read_jsonl(source):
        query = safe_text(re.sub(r"^(?:Human|User):\s*", "", str(row.get("query") or ""), flags=re.I))
        transcript = str(row.get("response") or "")
        match = re.search(r"(?:^|\n)\s*Assistant:\s*(.*?)(?=\n\s*(?:Human|User):|\Z)", transcript, flags=re.I | re.S)
        answer = safe_text(match.group(1)) if match else safe_text(transcript)
        pattern = pattern_text(query)
        if not pattern or not answer or pattern in seen:
            continue
        seen.add(pattern); add_category(root, pattern, answer); count += 1
        if limit and count >= limit: break
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return count


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--lexicon", type=Path, default=Path("data/ingest/english-dictionary.lexicon.key-grammar.jsonl"))
    parser.add_argument("--relations", type=Path, default=Path("data/ingest/english-dictionary.definition-relations.key-grammar.jsonl"))
    parser.add_argument("--output", type=Path, default=Path("data/alice/dictionary.aiml"))
    parser.add_argument("--limit", type=int, default=0, help="maximum dictionary entries; 0 means all")
    parser.add_argument("--candidates", type=Path, help="convert candidate key JSONL instead of dictionary inputs")
    parser.add_argument("--records", type=Path, help="convert generic key-grammar/event records")
    parser.add_argument("--pairs", type=Path, help="convert query/response training pairs")
    args = parser.parse_args()
    if args.limit < 0:
        parser.error("--limit must be zero or greater")
    try:
        if sum(bool(x) for x in (args.candidates, args.records, args.pairs)) > 1:
            parser.error("choose one of --candidates, --records, or --pairs")
        count = (convert_pairs(args.pairs, args.output, args.limit) if args.pairs
                 else convert_candidates(args.candidates, args.output, args.limit) if args.candidates
                 else convert_records(args.records, args.output, args.limit) if args.records
                 else convert(args.lexicon, args.relations, args.output, args.limit))
    except (OSError, ValueError) as error:
        print(f"jsonl-to-aiml: {error}", file=sys.stderr)
        return 2
    print(f"wrote {count} dictionary entries to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
