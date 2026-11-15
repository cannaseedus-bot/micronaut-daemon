#!/usr/bin/env python3
"""Build and query a key-definition relation graph from key-grammar JSONL banks.

The graph treats a key definition as relational evidence:
- lexicon/greeting rows create key nodes, book nodes, definition-key edges, synonym edges, and gram-channel summaries;
- definition-relation rows create directed semantic edges from source key to target key;
- query mode returns the local wildcard graph, AIML/KXML pattern cues, and the fold route that Atomic DOM can consume.

Default output is a compact manifest so the tool can be run on the full dictionary without writing a huge graph file. Use --emit-full when you explicitly want all nodes and edges in the JSON output.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
from collections import Counter, defaultdict
from dataclasses import dataclass, field
from datetime import datetime, timezone
from pathlib import Path
import os
from typing import Any, Dict, Iterable, Iterator, List, Optional, Tuple

ROOT = Path(os.environ.get("KUHUL_KIT_ROOT", Path(__file__).resolve().parents[1])).resolve()
VERSION = "1.0.0"
PHASE_ROUTE = ["Pop", "Wo", "Yax", "Sek", "Ch'en", "Xul"]

SOURCE_SPECS = [
    {
        "kind": "greeting",
        "path": "greeting-bank.key-grammar.jsonl",
        "zip": None,
        "limit_arg": "max_greeting",
    },
    {
        "kind": "npc_theory",
        "path": "npc-theory.key-grammar.jsonl",
        "zip": None,
        "limit_arg": "max_npc",
    },
    {
        "kind": "script_pattern",
        "path": "script-pattern.key-grammar.jsonl",
        "zip": None,
        "limit_arg": "max_script",
    },
    {
        "kind": "regex_fsm",
        "path": "regex-fsm.key-grammar.jsonl",
        "zip": None,
        "limit_arg": "max_regex_fsm",
    },
    {
        "kind": "regex_kuhul",
        "path": "regex-kuhul.key-grammar.jsonl",
        "zip": None,
        "limit_arg": "max_regex_kuhul",
    },
    {
        "kind": "lexicon",
        "path": "english-dictionary.lexicon.key-grammar.jsonl",
        "zip": "english-dictionary.lexicon.key-grammar.jsonl.zip",
        "limit_arg": "max_lexicon",
    },
    {
        "kind": "definition_relations",
        "path": "english-dictionary.definition-relations.key-grammar.jsonl",
        "zip": None,
        "limit_arg": "max_relations",
    },
]


def now_iso() -> str:
    return datetime.now(timezone.utc).isoformat().replace("+00:00", "Z")


def normalize_id(value: Any) -> str:
    text = "" if value is None else str(value).strip()
    if not text:
        return "UNKNOWN"
    book = re.fullmatch(r"Book\((.+)\)", text)
    if book:
        return "BOOK:" + normalize_id(book.group(1))
    text = text.replace("µ", "u")
    text = re.sub(r"\s+", "_", text)
    text = re.sub(r"[^A-Za-z0-9_:@.\-']+", "", text)
    return text.upper() or "UNKNOWN"


def first_text(*values: Any) -> str:
    for value in values:
        if isinstance(value, str) and value.strip():
            return value.strip()
    return ""


@dataclass
class GraphNode:
    id: str
    label: str
    kind: str
    weight: float = 1.0
    confidence: float = 1.0
    definition: str = ""
    source_files: set[str] = field(default_factory=set)
    books: set[str] = field(default_factory=set)
    gram_channels: Dict[str, List[Dict[str, Any]]] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)

    def to_json(self) -> Dict[str, Any]:
        return {
            "id": self.id,
            "label": self.label,
            "kind": self.kind,
            "weight": self.weight,
            "confidence": self.confidence,
            "definition": self.definition,
            "source_files": sorted(self.source_files),
            "books": sorted(self.books),
            "gram_channels": summarize_gram_channels(self.gram_channels, limit=12),
            "metadata": self.metadata,
        }


@dataclass
class GraphEdge:
    from_id: str
    to_id: str
    relation: str
    weight: float = 1.0
    confidence: float = 1.0
    evidence: str = ""
    source_word: str = ""
    source_file: str = ""

    def key(self) -> Tuple[str, str, str, str]:
        return (self.from_id, self.to_id, self.relation, self.evidence)

    def to_json(self) -> Dict[str, Any]:
        return {
            "from": self.from_id,
            "to": self.to_id,
            "relation": self.relation,
            "weight": self.weight,
            "confidence": self.confidence,
            "evidence": self.evidence,
            "source_word": self.source_word,
            "source_file": self.source_file,
        }


class KeyRelationGraph:
    def __init__(self) -> None:
        self.nodes: Dict[str, GraphNode] = {}
        self.edges: Dict[Tuple[str, str, str, str], GraphEdge] = {}
        self.outgoing: Dict[str, List[GraphEdge]] = defaultdict(list)
        self.incoming: Dict[str, List[GraphEdge]] = defaultdict(list)
        self.stats: Dict[str, Any] = {
            "source_rows": 0,
            "malformed_rows": 0,
            "rows_by_file": {},
            "rows_by_kind": {},
            "edge_relations": {},
        }

    def node(self, node_id: str, label: str = "", kind: str = "key") -> GraphNode:
        node_id = normalize_id(node_id)
        node = self.nodes.get(node_id)
        if node is None:
            node = GraphNode(id=node_id, label=label or node_id, kind=kind)
            self.nodes[node_id] = node
        else:
            if label and node.label == node.id:
                node.label = label
            if kind != "key" and node.kind == "key":
                node.kind = kind
        return node

    def edge(self, from_id: Any, to_id: Any, relation: str, *, weight: float = 1.0, confidence: float = 1.0, evidence: str = "", source_word: str = "", source_file: str = "") -> None:
        from_norm = normalize_id(from_id)
        to_norm = normalize_id(to_id)
        if not from_norm or not to_norm or from_norm == "UNKNOWN" or to_norm == "UNKNOWN":
            return
        self.node(from_norm)
        self.node(to_norm)
        edge = GraphEdge(from_norm, to_norm, relation or "@related_to", float(1.0 if weight is None else weight), float(1.0 if confidence is None else confidence), evidence, source_word, source_file)
        key = edge.key()
        if key in self.edges:
            old = self.edges[key]
            old.weight += edge.weight
            old.confidence = max(old.confidence, edge.confidence)
            if source_file and source_file not in old.source_file.split(";"):
                old.source_file = ";".join(x for x in [old.source_file, source_file] if x)
            return
        self.edges[key] = edge
        self.outgoing[from_norm].append(edge)
        self.incoming[to_norm].append(edge)

    def ingest_row(self, row: Dict[str, Any], source_file: str, source_kind: str) -> None:
        self.stats["source_rows"] += 1
        self.stats["rows_by_file"][source_file] = self.stats["rows_by_file"].get(source_file, 0) + 1
        self.stats["rows_by_kind"][source_kind] = self.stats["rows_by_kind"].get(source_kind, 0) + 1
        if {"from", "to", "relation"}.issubset(row):
            self._ingest_relation_row(row, source_file)
        else:
            self._ingest_key_row(row, source_file, source_kind)

    def _ingest_key_row(self, row: Dict[str, Any], source_file: str, source_kind: str) -> None:
        key = first_text(row.get("key"), row.get("word"), row.get("book"))
        if not key:
            self.stats["malformed_rows"] += 1
            return
        node_id = normalize_id(key)
        label = first_text(row.get("word"), row.get("key"), row.get("book"), node_id)
        kind = first_text(row.get("class"), row.get("schema"), source_kind, "key").lower()
        node = self.node(node_id, label, kind)
        node.source_files.add(source_file)
        node.definition = first_text(node.definition, row.get("definition"))
        if row.get("book"):
            node.books.add(str(row["book"]))
        if row.get("unit"):
            node.metadata["unit"] = row.get("unit")
        if row.get("lexicon_source"):
            node.metadata["lexicon_source"] = row.get("lexicon_source")
        if row.get("schema"):
            node.metadata["schema"] = row.get("schema")
        merge_gram_channels(node.gram_channels, row.get("gram_channels"))

        if row.get("book"):
            book_id = normalize_id(row["book"])
            book = self.node(book_id, str(row["book"]), "book")
            book.source_files.add(source_file)
            self.edge(node_id, book_id, "@in_book", evidence="book", source_word=label, source_file=source_file)

        for target in row.get("definition_keys") or []:
            self.edge(node_id, target, "@definition_key", evidence="definition_keys", source_word=label, source_file=source_file)
        for target in row.get("synonyms") or []:
            self.edge(node_id, target, "@synonym", evidence="synonyms", source_word=label, source_file=source_file)

    def _ingest_relation_row(self, row: Dict[str, Any], source_file: str) -> None:
        relation = str(row.get("relation") or "@related_to")
        self.stats["edge_relations"][relation] = self.stats["edge_relations"].get(relation, 0) + 1
        self.edge(
            row.get("from"),
            row.get("to"),
            relation,
            weight=float(1.0 if row.get("weight") is None else row["weight"]),
            confidence=float(1.0 if row.get("confidence") is None else row["confidence"]),
            evidence=str(row.get("evidence") or row.get("weight_kind") or "relation_row"),
            source_word=str(row.get("source_word") or ""),
            source_file=source_file,
        )

    def query(self, query_text: str, *, edge_limit: int = 30) -> Dict[str, Any]:
        focus = resolve_query_node(self, query_text)
        if focus is None:
            return {
                "query": query_text,
                "found": False,
                "candidates": suggest_nodes(self, query_text, 12),
                "fold_route": PHASE_ROUTE,
            }
        out_edges = sorted(self.outgoing.get(focus.id, []), key=lambda e: (-e.weight, e.relation, e.to_id))[:edge_limit]
        in_edges = sorted(self.incoming.get(focus.id, []), key=lambda e: (-e.weight, e.relation, e.from_id))[:edge_limit]
        related_ids = []
        for edge in out_edges:
            related_ids.append(edge.to_id)
        for edge in in_edges:
            related_ids.append(edge.from_id)
        related_nodes = [self.nodes[x].to_json() for x in unique(related_ids) if x in self.nodes]
        return {
            "query": query_text,
            "found": True,
            "focus": focus.to_json(),
            "outgoing": [e.to_json() for e in out_edges],
            "incoming": [e.to_json() for e in in_edges],
            "related_nodes": related_nodes,
            "wildcard_graph": build_wildcard_graph(focus, out_edges, in_edges),
            "aiml": {
                "pattern": "DEFINE * WITH RELATION KEYS *",
                "template": "Resolve key definition, gather definition keys and relation edges, then fold the neighborhood into an explanation.",
                "wildcards": [
                    {"id": "wildcard_0", "role": "key", "value": focus.id},
                    {"id": "wildcard_1", "role": "relations", "value": str(len(out_edges) + len(in_edges))},
                ],
            },
            "kxml": {
                "pattern": "LINK * TO * AS *",
                "template": "Pattern -> wildcard graph -> key relation track -> fold field -> Xul",
                "fold_route": PHASE_ROUTE,
            },
            "fold_route": PHASE_ROUTE,
        }

    def manifest(self, *, query_result: Optional[Dict[str, Any]] = None, emit_full: bool = False, max_preview: int = 24) -> Dict[str, Any]:
        relation_counts = Counter(edge.relation for edge in self.edges.values())
        manifest: Dict[str, Any] = {
            "kind": "key_definition_relation_graph",
            "version": VERSION,
            "generated_at": now_iso(),
            "contract": "key definitions describe relations; relation rows are graph edges; gram channels are query-local evidence tracks",
            "stats": {
                **self.stats,
                "node_count": len(self.nodes),
                "edge_count": len(self.edges),
                "relation_counts": dict(relation_counts.most_common(24)),
            },
            "patterns": [
                "DEFINE * WITH RELATION KEYS *",
                "LINK * TO * AS *",
                "ANSWER GREETING * WITH *",
            ],
            "templates": [
                "Key row -> gram channels -> relation edges -> wildcard graph -> reusable response track",
                "Relation row -> directed edge -> neighborhood fold -> explanation",
            ],
            "fold_route": PHASE_ROUTE,
            "sample_nodes": [node.to_json() for node in list(self.nodes.values())[:max_preview]],
            "sample_edges": [edge.to_json() for edge in list(self.edges.values())[:max_preview]],
        }
        if query_result is not None:
            manifest["query_result"] = query_result
        if emit_full:
            manifest["nodes"] = [node.to_json() for node in self.nodes.values()]
            manifest["edges"] = [edge.to_json() for edge in self.edges.values()]
        return manifest


def unique(values: Iterable[str]) -> List[str]:
    seen = set()
    out = []
    for value in values:
        if value in seen:
            continue
        seen.add(value)
        out.append(value)
    return out


def merge_gram_channels(target: Dict[str, List[Dict[str, Any]]], value: Any) -> None:
    if not isinstance(value, dict):
        return
    for channel, grams in value.items():
        if not isinstance(grams, list):
            continue
        bucket = target.setdefault(str(channel), [])
        seen = {str(item.get("gram")) for item in bucket if isinstance(item, dict)}
        for gram in grams:
            if not isinstance(gram, dict):
                continue
            name = str(gram.get("gram") or "").strip()
            if not name or name in seen:
                continue
            seen.add(name)
            bucket.append({
                "gram": name,
                "count": gram.get("count", 1),
                "width": gram.get("width"),
                "role": gram.get("role"),
                "phase": gram.get("phase"),
                "position": gram.get("position"),
                "provenance": gram.get("provenance"),
            })


def summarize_gram_channels(channels: Dict[str, List[Dict[str, Any]]], *, limit: int = 8) -> Dict[str, List[Dict[str, Any]]]:
    return {channel: grams[:limit] for channel, grams in sorted(channels.items())}


def resolve_query_node(graph: KeyRelationGraph, query_text: str) -> Optional[GraphNode]:
    target = normalize_id(query_text)
    if target in graph.nodes:
        return graph.nodes[target]
    compact = target.replace("_", "")
    for node in graph.nodes.values():
        if normalize_id(node.label) == target or normalize_id(node.label).replace("_", "") == compact:
            return node
    # Suggestions are not exact semantic identity. Never promote fuzzy matches to authority.
    return None


def suggest_nodes(graph: KeyRelationGraph, query_text: str, limit: int) -> List[Dict[str, Any]]:
    needle = normalize_id(query_text).lower().replace("_", "")
    if not needle:
        return []
    scored = []
    for node in graph.nodes.values():
        hay = (node.id + " " + node.label).lower().replace("_", "")
        score = 0
        if needle == node.id.lower().replace("_", ""):
            score = 100
        elif needle == normalize_id(node.label).lower().replace("_", ""):
            score = 90
        elif needle in hay:
            score = 50 + min(20, len(needle))
        if score:
            scored.append((score, node))
    scored.sort(key=lambda item: (-item[0], item[1].id))
    return [{"id": node.id, "label": node.label, "kind": node.kind, "score": score} for score, node in scored[:limit]]


def build_wildcard_graph(focus: GraphNode, outgoing: List[GraphEdge], incoming: List[GraphEdge]) -> Dict[str, Any]:
    nodes = [
        {"id": "wildcard_0", "value": focus.id, "type": focus.kind, "role": "source_key", "phase": "Pop", "confidence": focus.confidence},
    ]
    edges = []
    for index, edge in enumerate(outgoing[:12], start=1):
        node_id = f"wildcard_{index}"
        nodes.append({"id": node_id, "value": edge.to_id, "type": "related_key", "role": edge.relation, "phase": "Wo", "confidence": edge.confidence})
        edges.append({"from": "wildcard_0", "to": node_id, "relationship": edge.relation, "weight": edge.weight})
    offset = len(nodes)
    for index, edge in enumerate(incoming[:12], start=offset):
        node_id = f"wildcard_{index}"
        nodes.append({"id": node_id, "value": edge.from_id, "type": "incoming_key", "role": edge.relation, "phase": "Yax", "confidence": edge.confidence})
        edges.append({"from": node_id, "to": "wildcard_0", "relationship": edge.relation, "weight": edge.weight})
    return {"nodes": nodes, "edges": edges, "node_count": len(nodes), "edge_count": len(edges)}


def source_path(root: Path, spec: Dict[str, Any]) -> Tuple[Path, bool]:
    plain = root / spec["path"]
    if plain.exists():
        return plain, False
    if spec.get("zip"):
        zipped = root / spec["zip"]
        if zipped.exists():
            return zipped, True
    return plain, False


def iter_jsonl(path: Path, zipped: bool) -> Iterator[Tuple[int, Dict[str, Any]]]:
    if zipped:
        with zipfile.ZipFile(path) as zf:
            members = [name for name in zf.namelist() if name.endswith(".jsonl")]
            if not members:
                return
            with zf.open(members[0], "r") as fh:
                for line_no, raw in enumerate(fh, start=1):
                    text = raw.decode("utf-8", errors="replace").strip()
                    if not text:
                        continue
                    yield line_no, json.loads(text)
    else:
        with path.open("r", encoding="utf-8", errors="replace") as fh:
            for line_no, text in enumerate(fh, start=1):
                text = text.strip()
                if not text:
                    continue
                yield line_no, json.loads(text)


def build_graph(root: Path, args: argparse.Namespace) -> KeyRelationGraph:
    graph = KeyRelationGraph()
    for spec in SOURCE_SPECS:
        path, zipped = source_path(root, spec)
        source_name = path.name
        if not path.exists():
            graph.stats["malformed_rows"] += 1
            graph.stats["rows_by_file"][source_name] = 0
            continue
        limit = int(getattr(args, spec["limit_arg"], 0) or 0)
        loaded = 0
        for line_no, row in iter_jsonl(path, zipped):
            try:
                if not isinstance(row, dict):
                    graph.stats["malformed_rows"] += 1
                    continue
                graph.ingest_row(row, source_name, spec["kind"])
                loaded += 1
            except Exception as exc:
                graph.stats["malformed_rows"] += 1
                if args.strict:
                    raise RuntimeError(f"{source_name}:{line_no}: {exc}") from exc
            if limit and loaded >= limit:
                break
    return graph


def render_summary(graph: KeyRelationGraph, query_result: Optional[Dict[str, Any]]) -> str:
    lines = [
        f"key relation graph v{VERSION}",
        f"nodes: {len(graph.nodes)}",
        f"edges: {len(graph.edges)}",
        f"rows:  {graph.stats['source_rows']}",
        "relations: " + ", ".join(f"{k}={v}" for k, v in Counter(e.relation for e in graph.edges.values()).most_common(8)),
    ]
    if query_result:
        lines.append("")
        if not query_result.get("found"):
            lines.append(f"query: {query_result.get('query')} not found")
            candidates = query_result.get("candidates") or []
            if candidates:
                lines.append("candidates: " + ", ".join(f"{c['id']}({c['label']})" for c in candidates[:8]))
        else:
            focus = query_result["focus"]
            lines.append(f"query: {query_result['query']}")
            lines.append(f"focus: {focus['id']} ({focus['label']}) [{focus['kind']}]")
            if focus.get("definition"):
                lines.append(f"definition: {focus['definition']}")
            lines.append(f"outgoing: {len(query_result['outgoing'])}; incoming: {len(query_result['incoming'])}")
            for edge in query_result["outgoing"][:8]:
                lines.append(f"  - {edge['from']} {edge['relation']} {edge['to']} w={edge['weight']}")
            lines.append(f"wildcard_graph: {query_result['wildcard_graph']['node_count']} nodes, {query_result['wildcard_graph']['edge_count']} edges")
            lines.append("fold_route: " + " -> ".join(query_result["fold_route"]))
    return "\n".join(lines)


def parse_args(argv: List[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Build/query key-definition relation graph from key-grammar JSONL banks.")
    parser.add_argument("--root", type=Path, default=ROOT, help="key-grammar-kit root")
    parser.add_argument("--query", default="", help="key/word to query after building")
    parser.add_argument("--output", type=Path, default=None, help="write compact manifest JSON to this path")
    parser.add_argument("--emit-full", action="store_true", help="include all nodes and edges in output JSON")
    parser.add_argument("--json", action="store_true", help="print JSON instead of text summary")
    parser.add_argument("--strict", action="store_true", help="raise on malformed rows instead of counting them")
    parser.add_argument("--max-greeting", type=int, default=0, help="limit greeting rows; 0 means all")
    parser.add_argument("--max-npc", type=int, default=0, help="limit NPC theory rows; 0 means all")
    parser.add_argument("--max-script", type=int, default=0, help="limit script-pattern rows; 0 means all")
    parser.add_argument("--max-regex-fsm", type=int, default=0, help="limit regex/FSM bridge rows; 0 means all")
    parser.add_argument("--max-regex-kuhul", type=int, default=0, help="limit regex/KUHUL bridge rows; 0 means all")
    parser.add_argument("--max-lexicon", type=int, default=0, help="limit lexicon rows; 0 means all")
    parser.add_argument("--max-relations", type=int, default=0, help="limit relation rows; 0 means all")
    return parser.parse_args(argv)


def main(argv: List[str]) -> int:
    args = parse_args(argv)
    root = args.root.resolve()
    graph = build_graph(root, args)
    query_result = graph.query(args.query) if args.query else None
    manifest = graph.manifest(query_result=query_result, emit_full=args.emit_full)

    if args.output:
        output = args.output if args.output.is_absolute() else root / args.output
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(manifest, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")

    if args.json:
        print(json.dumps(query_result or manifest, indent=2, ensure_ascii=False))
    else:
        print(render_summary(graph, query_result))
        if args.output:
            print(f"wrote: {output}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))



