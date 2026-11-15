#!/usr/bin/env python3
"""Convert SQuAD Arrow question-answer pairs into title-addressable AIML."""
from __future__ import annotations
import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from datasets import Dataset


def clean_text(text: str) -> str:
    # Normalize source hard-wrap markers and whitespace before AIML emission.
    return re.sub(r"\s+", " ", re.sub(r"\\+", " ", text)).strip()


def pattern(text: str) -> str:
    return re.sub(r"\s+", " ", re.sub(r"[^\w ]+", " ", text)).strip().upper()


def export(source: Path, split: str, output: Path) -> tuple[int, int, int]:
    dataset = Dataset.from_file(str(source))
    required = {"title", "question", "answers"}
    if not required.issubset(dataset.column_names):
        raise ValueError(f"expected title,question,answers columns in {source}")

    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment(f"SQuAD {split} split; answers are extractive dataset annotations."))
    seen_questions: set[str] = set()
    count = skipped = duplicates = 0
    for row in dataset:
        question = clean_text(str(row["question"] or ""))
        question_pattern = pattern(question)
        answers = row["answers"] or {}
        answer_texts = answers.get("text", []) if isinstance(answers, dict) else []
        answer = next((clean_text(str(value)) for value in answer_texts if clean_text(str(value))), "")
        if not question_pattern or not answer:
            skipped += 1
            continue
        if len(question_pattern) > 400:
            skipped += 1
            continue
        title = clean_text(str(row["title"] or "")).replace("_", " ")
        title_pattern = pattern(title)
        variants = []
        if title_pattern:
            qualified = f"SQUAD {title_pattern} {question_pattern}"
            if len(qualified) <= 600:
                variants.append(qualified)
        if question_pattern in seen_questions:
            duplicates += 1
        else:
            variants.append(question_pattern)
            seen_questions.add(question_pattern)
        for query_pattern in variants:
            category = ET.SubElement(root, "category")
            ET.SubElement(category, "pattern").text = query_pattern
            ET.SubElement(category, "template").text = answer
            count += 1

    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return count, skipped, duplicates


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--train", type=Path, required=True)
    ap.add_argument("--validation", type=Path, required=True)
    ap.add_argument("--output-dir", type=Path, default=Path("data/alice/squad"))
    args = ap.parse_args()
    try:
        for split, source in (("train", args.train), ("validation", args.validation)):
            count, skipped, duplicates = export(source, split, args.output_dir / f"squad-{split}.aiml")
            print(f"{split}: {count} AIML categories; skipped={skipped}; duplicate questions={duplicates}")
    except (OSError, ValueError) as error:
        print(f"arrow-squad-to-aiml: {error}", file=sys.stderr)
        return 2
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
