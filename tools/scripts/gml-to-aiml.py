#!/usr/bin/env python3
"""Export generic GML graph metadata as non-executable AIML lookup banks."""
from __future__ import annotations

import argparse
import re
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


class GmlError(ValueError):
    pass


def strip_comments(text: str) -> str:
    text = re.sub(r"(?s)/\*.*?\*/|\(\*.*?\*\)", " ", text)
    return re.sub(r"(?m)^\s*#.*$", " ", text)


TOKEN = re.compile(r'"(?:\\.|[^"\\])*"|\[|\]|[^\s\[\]]+')


def unquote(token: str) -> str:
    if token.startswith('"'):
        body = token[1:-1]
        return re.sub(r'\\(["\\])', r'\1', body)
    return token


def parse_gml(text: str) -> dict:
    tokens = TOKEN.findall(strip_comments(text))
    pos = 0

    def value():
        nonlocal pos
        if pos >= len(tokens):
            raise GmlError("unexpected end of GML")
        if tokens[pos] != "[":
            item = unquote(tokens[pos]); pos += 1; return item
        pos += 1
        result = {}
        while pos < len(tokens) and tokens[pos] != "]":
            key = unquote(tokens[pos]); pos += 1
            child = value()
            if key in result:
                if not isinstance(result[key], list) or not result[key] or not isinstance(result[key][0], dict):
                    result[key] = [result[key]]
                result[key].append(child)
            else:
                result[key] = child
        if pos >= len(tokens):
            raise GmlError("unclosed GML list")
        pos += 1
        return result

    if not tokens or tokens[0] != "graph":
        raise GmlError("expected graph root")
    pos = 1
    graph = value()
    if not isinstance(graph, dict) or pos != len(tokens):
        raise GmlError("invalid graph body or trailing tokens")
    return graph


def text_value(value) -> str:
    if isinstance(value, list):
        return ", ".join(text_value(x) for x in value)
    if isinstance(value, dict):
        return "; ".join(f"{k}={text_value(v)}" for k, v in sorted(value.items()))
    return str(value)


def literal_pattern(value: str) -> str:
    value = re.sub(r"\s+", " ", value).strip()
    if not value or len(value) > 120 or any(c in value for c in "*#_^"):
        return ""
    return value.upper()


def add(root, pattern, response):
    if not pattern:
        return
    category = ET.SubElement(root, "category")
    ET.SubElement(category, "pattern").text = pattern
    ET.SubElement(category, "template").text = response


def graph_to_aiml(path: Path, output: Path) -> int:
    graph = parse_gml(path.read_text(encoding="utf-8-sig"))
    root = ET.Element("aiml", {"version": "1.0"})
    root.append(ET.Comment(f"Graph lookup export from {path.name}. Metadata is not execution authority."))
    graph_label = text_value(graph.get("label", path.stem))
    identity = text_value(graph.get("schema", graph.get("id", path.stem)))
    info = [f"source {path.name}", f"label {graph_label}", f"identity {identity}"]
    for key in ("authority", "semantic_authority", "purpose", "topology", "directed"):
        if key in graph:
            info.append(f"{key} {text_value(graph[key])}")
    nodes = graph.get("node", [])
    edges = graph.get("edge", [])
    if isinstance(nodes, dict): nodes = [nodes]
    if isinstance(edges, dict): edges = [edges]
    add(root, f"DESCRIBE GRAPH {literal_pattern(graph_label)}", "; ".join(info) + f"; nodes {len(nodes)}; edges {len(edges)}. Data-only graph export.")
    emitted = 1
    for node in nodes:
        if not isinstance(node, dict): continue
        node_id = text_value(node.get("id", ""))
        label = text_value(node.get("label", node_id))
        fields = "; ".join(f"{k}: {text_value(v)}" for k, v in sorted(node.items()))
        response = f"Graph {graph_label}; node {node_id}; {fields}. Data-only graph record."
        for lookup in (f"GRAPH {literal_pattern(graph_label)} NODE {node_id}",
                       f"GRAPH {literal_pattern(graph_label)} NODE {literal_pattern(label)}"):
            if literal_pattern(lookup):
                add(root, lookup, response); emitted += 1
    for edge in edges:
        if not isinstance(edge, dict): continue
        source = text_value(edge.get("source", edge.get("from", "")))
        target = text_value(edge.get("target", edge.get("to", "")))
        kind = text_value(edge.get("label", edge.get("relation", edge.get("kind", "EDGE"))))
        if not source or not target: continue
        fields = "; ".join(f"{k}: {text_value(v)}" for k, v in sorted(edge.items()))
        response = f"Graph {graph_label}; edge {source} to {target}; {fields}. Data-only graph record."
        add(root, f"GRAPH {literal_pattern(graph_label)} EDGE {source} {literal_pattern(kind)} {target}", response)
        emitted += 1
    output.parent.mkdir(parents=True, exist_ok=True)
    ET.indent(root, space="  ")
    ET.ElementTree(root).write(output, encoding="UTF-8", xml_declaration=True)
    return emitted


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("inputs", nargs="+", type=Path)
    ap.add_argument("--output-dir", type=Path, default=Path("data/alice/graphs"))
    args = ap.parse_args()
    failed = False
    for source in args.inputs:
        try:
            count = graph_to_aiml(source, args.output_dir / f"{source.stem}.aiml")
            print(f"{source}: wrote {count} lookup categories")
        except (OSError, UnicodeError, GmlError) as error:
            failed = True
            print(f"{source}: {error}", file=sys.stderr)
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
