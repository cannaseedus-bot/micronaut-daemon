#!/usr/bin/env python3
"""Convert WikiText Arrow splits into title-addressed AIML retrieval entries."""
from __future__ import annotations
import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from datasets import Dataset


def pattern(value: str) -> str:
    value = re.sub(r"[^\w ]+", " ", value, flags=re.UNICODE)
    return re.sub(r"\s+", " ", value).strip().upper()


def export(source: Path, split: str, output: Path) -> int:
    dataset = Dataset.from_file(str(source))
    if "text" not in dataset.column_names:
        raise ValueError(f"expected text column in {source}")
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment(f"WikiText {split} split; article text indexed by title, not QA supervision."))
    articles = []
    title = ""
    chunks = []
    for row in dataset:
        text = str(row.get("text") or "").strip()
        match = re.fullmatch(r"=+\s*(.*?)\s*=+", text)
        if match and len(match.group(1).strip()) > 0:
            if title and chunks: articles.append((title, chunks))
            title = match.group(1).strip(); chunks = []
        elif text and title:
            chunks.append(text)
    if title and chunks: articles.append((title, chunks))
    used = set(); count = 0
    for title, chunks in articles:
        key = pattern(title)
        if not key or key in used: continue
        used.add(key)
        body = re.sub(r"\s+", " ", " ".join(chunks)).strip()[:5000]
        category = ET.SubElement(root, "category")
        ET.SubElement(category, "pattern").text = f"WIKITEXT {split.upper()} ABOUT {key}"
        ET.SubElement(category, "template").text = f"[{split} article: {title}] {body}"
        count += 1
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return count


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--train", type=Path, required=True)
    ap.add_argument("--validation", type=Path, required=True)
    ap.add_argument("--test", type=Path, required=True)
    ap.add_argument("--output-dir", type=Path, default=Path("data/alice/wikitext"))
    args = ap.parse_args()
    try:
        for split, source in (("train", args.train), ("validation", args.validation), ("test", args.test)):
            count = export(source, split, args.output_dir / f"wikitext-{split}.aiml")
            print(f"{split}: {count} article entries -> {args.output_dir}")
    except (OSError, ValueError) as error:
        print(f"arrow-wikitext-to-aiml: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
