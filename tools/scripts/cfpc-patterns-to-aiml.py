#!/usr/bin/env python3
"""Compile CFPC question-pattern contracts into safe AIML route markers."""
from __future__ import annotations
import argparse
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


# AIML forms mirror the nine CFPC contracts. More specific forms precede their
# broad variants; native AIML scoring still gives exact corpus answers priority.
FORMS = {
    "what-is": [
        ("WHAT IS *", ["subject"]),
        ("WHAT DOES * MEAN", ["subject"]),
        ("WHAT DOES *", ["subject"]),
    ],
    "explain": [("EXPLAIN *", ["subject"])],
    "how-to": [("HOW TO *", ["subject"]), ("HOW DO I *", ["subject"]), ("HOW DO YOU *", ["subject"])],
    "how-many": [
        ("HOW MANY * DOES * HAVE", ["quantity", "subject"]),
        ("HOW MANY * ARE THERE AROUND *", ["quantity", "subject"]),
        ("HOW MANY * ARE THERE ON *", ["quantity", "subject"]),
        ("HOW MANY * IS THERE IN *", ["quantity", "subject"]),
        ("HOW MANY * IS THERE ON *", ["quantity", "subject"]),
        ("HOW MUCH * DOES * HAVE", ["quantity", "subject"]),
        ("HOW MUCH * IS IN *", ["quantity", "subject"]),
        ("HOW MUCH * IS ON *", ["quantity", "subject"]),
    ],
    "which-have-property": [
        ("WHICH * HAVE *", ["entities", "property"]),
        ("WHICH * ARE KNOWN TO HAVE *", ["entities", "property"]),
        ("DO ANY * HAVE *", ["entities", "property"]),
    ],
    "how-does-affect": [
        ("HOW DOES * AFFECT *", ["verb", "neighbor"]),
        ("HOW DOES * INFLUENCE *", ["verb", "neighbor"]),
    ],
    "how-does-relate": [
        ("HOW DOES * RELATE TO *", ["value", "neighbor"]),
        ("HOW IS * RELATED TO *", ["value", "neighbor"]),
    ],
    "what-is-the-difference": [
        ("WHAT IS THE DIFFERENCE BETWEEN * AND *", ["left", "right"]),
        ("WHAT IS THE DIFFERENCE OF * AND *", ["left", "right"]),
    ],
    "why-does": [("WHY DOES *", ["subject"]), ("WHY IS *", ["subject"])],
    "tell-me-about": [("TELL ME ABOUT *", ["subject"])],
}


def compile_contracts(source: Path, output: Path) -> int:
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment("Generated from data/cfpc/*.cfpc-pattern.v1.json; markers route intent only and assert no facts."))
    count = 0
    for intent, forms in FORMS.items():
        path = source / f"{intent}.cfpc-pattern.v1.json"
        contract = json.loads(path.read_text(encoding="utf-8-sig"))
        if contract.get("@kind") != "khanary.cfpc.pattern.v1" or contract.get("id") != intent:
            raise ValueError(f"invalid CFPC pattern contract: {path}")
        phase = contract.get("phase", "Wo")
        hops = int(contract.get("neighborhood_resolve", {}).get("max_hops", 1))
        if phase not in {"Pop", "Wo", "Yax", "Sek", "Ch'en", "Xul"} or hops < 1 or hops > 3:
            raise ValueError(f"invalid phase or resolution depth in {path}")
        for pattern, captures in forms:
            category = ET.SubElement(root, "category")
            ET.SubElement(category, "pattern").text = pattern
            template = ET.SubElement(category, "template")
            template.text = f"CFPC1|{intent}|{phase}|{hops}|{captures[0]}="
            for index, name in enumerate(captures, 1):
                if index > 1:
                    template[-1].tail = f"|{name}="
                ET.SubElement(template, "star", {"index": str(index)})
            count += 1
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return count


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--contracts", type=Path, default=Path("data/cfpc"))
    parser.add_argument("--output", type=Path, default=Path("data/alice/00-cfpc-patterns.aiml"))
    args = parser.parse_args()
    try:
        count = compile_contracts(args.contracts, args.output)
    except (OSError, json.JSONDecodeError, ValueError) as exc:
        print(f"cfpc-patterns-to-aiml: {exc}", file=sys.stderr)
        return 2
    print(f"wrote {count} CFPC AIML route patterns to {args.output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
