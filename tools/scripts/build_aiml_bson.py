#!/usr/bin/env python3
"""Compile repository AIML XML into the runtime's BSON pattern-bank schema."""
from __future__ import annotations

import argparse
import os
import re
import sys
import tempfile
from datetime import datetime, timezone
from pathlib import Path
try:
    from lxml import etree as ET
except ImportError:
    import xml.etree.ElementTree as ET

from bson import BSON


def inner_xml(node: ET.Element) -> str:
    parts = [node.text or ""]
    for child in list(node):
        if ET.__name__.startswith("lxml"):
            # The caller appends child.tail separately; suppress lxml's default
            # tail serialization to avoid duplicating mixed-content text.
            parts.append(ET.tostring(child, encoding="unicode", with_tail=False))
        else:
            parts.append(ET.tostring(child, encoding="unicode", short_empty_elements=True))
        parts.append(child.tail or "")
    return "".join(parts).strip()


def tag_name(node) -> str:
    return node.tag.rsplit("}", 1)[-1].lower() if isinstance(node.tag, str) else ""


def collect(root: Path, exclude: set[Path]):
    exact, wild, topic, that = {}, [], {}, {}
    found = parsed = skipped = recovered = 0
    for path in sorted(root.rglob("*.aiml"), key=lambda p: p.as_posix().casefold()):
        resolved = path.resolve()
        if any(resolved == item or item in resolved.parents for item in exclude):
            continue
        found += 1
        try:
            tree = ET.parse(path)
        except ET.ParseError:
            try:
                source = path.read_text(encoding="utf-8-sig")
                if hasattr(ET, "XMLParser") and ET.__name__.startswith("lxml"):
                    tree = ET.ElementTree(ET.fromstring(source.encode("utf-8"), parser=ET.XMLParser(recover=True)))
                    recovered += 1
                else:
                    source = re.sub(r"^\s*<\?xml[^?]*\?>", "", source)
                    source = re.sub(r"&(?!#\d+;|#x[0-9A-Fa-f]+;|[A-Za-z][A-Za-z0-9]+;)", "&amp;", source)
                    source = re.sub(r"<(?![A-Za-z/!?])", "&lt;", source)
                    source = re.sub(r"[\x00-\x08\x0B\x0C\x0E-\x1F]", "", source)
                    tree = ET.ElementTree(ET.fromstring(source))
                    recovered += 1
            except (ET.ParseError, OSError, UnicodeError) as error:
                skipped += 1
                print(f"skip invalid AIML {path}: {error}", file=sys.stderr)
                continue
        except OSError as error:
            skipped += 1
            print(f"skip unreadable AIML {path}: {error}", file=sys.stderr)
            continue
        parsed += 1
        for category in tree.iter():
            if tag_name(category) != "category":
                continue
            pattern_node = next((n for n in category if tag_name(n) == "pattern"), None)
            template_node = next((n for n in category if tag_name(n) == "template"), None)
            if pattern_node is None or template_node is None:
                continue
            pattern = re.sub(r"\s+", " ", inner_xml(pattern_node)).strip().upper()
            response = inner_xml(template_node)
            if not pattern or not response:
                continue
            topic_node = next((n for n in category if tag_name(n) == "topic"), None)
            that_node = next((n for n in category if tag_name(n) == "that"), None)
            topic_value = re.sub(r"\s+", " ", inner_xml(topic_node)).strip().upper() if topic_node is not None else None
            that_value = re.sub(r"\s+", " ", inner_xml(that_node)).strip().upper() if that_node is not None else None
            if that_value is not None:
                that[f"{pattern}|{that_value}"] = response
            elif topic_value is not None:
                topic[f"{pattern}|{topic_value}"] = response
            elif any(c in pattern for c in "*_#"):
                tokens = pattern.split()
                wild.append({"pattern": pattern, "tokens": tokens, "template": response,
                             "wildcardCount": sum(token in ("*", "_", "#") for token in tokens),
                             "topic": None, "that": None})
            else:
                exact[pattern] = response
    return found, parsed, skipped, recovered, exact, wild, topic, that


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    ap.add_argument("--output", type=Path, default=Path("build/io/aiml-grams/alice.bson"))
    args = ap.parse_args()
    root = args.root.resolve()
    output = args.output if args.output.is_absolute() else root / args.output
    excluded = {root / "build", root / ".git", root / ".venv", root / "venv"}
    found, parsed, skipped, recovered, exact, wild, topic, that = collect(root, excluded)
    bank = {"meta": {"compiledAt": datetime.now(timezone.utc).isoformat(timespec="seconds"),
                      "count": len(exact) + len(wild) + len(topic) + len(that),
                      "exactCount": len(exact), "wildCount": len(wild),
                      "topicCount": len(topic), "thatCount": len(that),
                      "source": str(root), "version": 1, "filesFound": found,
                      "filesParsed": parsed, "filesRecovered": recovered,
                      "categoryFragmentsSkipped": 0, "filesSkipped": skipped},
            "exact": exact, "wild": wild, "topic": topic, "that": that}
    encoded = BSON.encode(bank)
    output.parent.mkdir(parents=True, exist_ok=True)
    fd, temp_name = tempfile.mkstemp(prefix=output.name + ".", suffix=".tmp", dir=output.parent)
    try:
        with os.fdopen(fd, "wb") as stream:
            stream.write(encoded)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temp_name, output)
    finally:
        if os.path.exists(temp_name): os.unlink(temp_name)
    print(f"BSON bank: {output}")
    print(f"AIML files: {parsed}/{found} parsed; recovered={recovered}; skipped={skipped}")
    print(f"Categories: exact={len(exact)} wildcard={len(wild)} topic={len(topic)} that={len(that)}")
    return 0 if not skipped else 1


if __name__ == "__main__":
    raise SystemExit(main())
