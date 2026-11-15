#!/usr/bin/env python3
"""Convert AG News Arrow splits to title-addressed AIML entries."""
from __future__ import annotations
import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from datasets import Dataset

LABELS = {0: "WORLD", 1: "SPORTS", 2: "BUSINESS", 3: "SCIENCE TECHNOLOGY"}


def pattern(text):
    return re.sub(r"\s+", " ", re.sub(r"[^\w ]+", " ", text)).strip().upper()


def clean_text(text):
    # The Arrow text uses backslashes as hard-wrap markers inside words.
    return re.sub(r"\s+", " ", re.sub(r"\\+", " ", text)).strip()


def export(source: Path, split: str, output: Path):
    dataset = Dataset.from_file(str(source))
    if not {"text", "label"}.issubset(dataset.column_names):
        raise ValueError(f"expected text,label columns in {source}")
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment(f"AG News {split} split; article labels are dataset annotations, not model judgments."))
    seen = set(); seen_titles = set(); count = 0
    for i, row in enumerate(dataset):
        label = int(row["label"])
        if label not in LABELS: continue
        text = clean_text(str(row["text"] or ""))
        match = re.match(r"^(.*?)\s+\(([^)]+)\)\s+\2\s+-\s*(.*)$", text)
        title, body = (match.group(1).strip(), match.group(3).strip()) if match else (text[:120], text)
        key = pattern(title)
        identity = (label, key)
        if not key or len(key) > 140 or identity in seen: continue
        seen.add(identity)
        response = clean_text(body)[:4000]
        # Keep a namespaced form for explicit dataset queries and add the raw
        # title form so ordinary user questions retrieve the same article.
        for query in (f"AG NEWS {LABELS[label]} {key}", key):
            if query == key and key in seen_titles:
                continue
            category = ET.SubElement(root, "category")
            ET.SubElement(category, "pattern").text = query
            ET.SubElement(category, "template").text = response
            count += 1
        seen_titles.add(key)
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return count


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--train", type=Path, required=True)
    ap.add_argument("--test", type=Path, required=True)
    ap.add_argument("--output-dir", type=Path, default=Path("data/alice/ag-news"))
    args = ap.parse_args()
    try:
        for split, source in (("train", args.train), ("test", args.test)):
            count = export(source, split, args.output_dir / f"ag-news-{split}.aiml")
            print(f"{split}: {count} articles -> {args.output_dir}")
    except (OSError, ValueError) as error:
        print(f"arrow-agnews-to-aiml: {error}", file=sys.stderr); return 2
    return 0


if __name__ == "__main__": raise SystemExit(main())
