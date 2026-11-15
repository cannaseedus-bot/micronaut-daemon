#!/usr/bin/env python3
"""Compile AIML sources into runtime JSONL records or an optional GGUF container.

The output is a data container with a custom ``micronaut_aiml`` architecture,
not a loadable neural-network weights file. Original AIML source text is kept
inside one uint8 tensor so it can be recovered without the source directory.
"""

from __future__ import annotations

import argparse
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

import numpy as np


SCHEMA = "micronaut.aiml.corpus.v2"
TENSOR_NAME = "aiml.corpus_json"
JSONL_MANIFEST_KIND = "micronaut.aiml.manifest.v1"
JSONL_SOURCE_KIND = "micronaut.aiml.source.v1"
JSONL_CATEGORY_KIND = "micronaut.aiml.category.v1"


class CorpusError(ValueError):
    """Raised when AIML input or a packaged corpus is invalid."""


def _local_name(tag: str) -> str:
    return tag.rsplit("}", 1)[-1].lower()


def _node_record(element: ET.Element) -> dict[str, Any]:
    """Convert an XML element into an ordered, non-executable template AST."""
    content: list[str | dict[str, Any]] = []
    if element.text:
        content.append(element.text)
    for child in list(element):
        content.append(_node_record(child))
        if child.tail:
            content.append(child.tail)
    return {
        "tag": _local_name(element.tag),
        "attrs": {_local_name(key): value for key, value in element.attrib.items()},
        "content": content,
    }


def _visit(element: ET.Element, source_index: int, source_name: str,
           categories: list[dict[str, Any]], topic: str = "", category_base: int | None = None) -> None:
    if category_base is None:
        category_base = len(categories)
    tag = _local_name(element.tag)
    if tag == "topic":
        topic = next((value for key, value in element.attrib.items() if _local_name(key) == "name"), topic)
    if tag == "category":
        direct = {_local_name(child.tag): child for child in list(element)}
        pattern_el = direct.get("pattern")
        that_el = direct.get("that")
        pattern = " ".join("".join(pattern_el.itertext()).split()) if pattern_el is not None else ""
        that = " ".join("".join(that_el.itertext()).split()) if that_el is not None else ""
        categories.append({
            "source": source_index,
            "source_path": source_name,
            "source_category": len(categories) - category_base,
            "pattern": pattern,
            "that": that,
            "topic": topic,
            "nodes": [_node_record(child) for child in list(element)],
        })
    for child in list(element):
        _visit(child, source_index, source_name, categories, topic, category_base)


def compile_corpus(source_dir: Path) -> dict[str, Any]:
    """Read sorted ``*.aiml`` files and return a deterministic JSON corpus."""
    files = sorted(source_dir.rglob("*.aiml"), key=lambda p: p.relative_to(source_dir).as_posix().casefold())
    if not files:
        raise CorpusError(f"no .aiml files found under {source_dir}")

    sources: list[dict[str, str]] = []
    categories: list[dict[str, Any]] = []
    for path in files:
        relative = path.relative_to(source_dir).as_posix()
        try:
            source_bytes = path.read_bytes()
            source_text = source_bytes.decode("utf-8")
        except UnicodeDecodeError as exc:
            raise CorpusError(f"{relative}: AIML source is not valid UTF-8") from exc
        try:
            root = ET.fromstring(source_bytes)
        except ET.ParseError as exc:
            raise CorpusError(f"{relative}: XML parse error: {exc}") from exc

        source_index = len(sources)
        sources.append({"path": relative, "text": source_text})
        _visit(root, source_index, relative, categories)

    return {
        "schema": SCHEMA,
        "source_count": len(sources),
        "category_count": len(categories),
        "sources": sources,
        "categories": categories,
    }


def _gguf_module(repo_root: Path):
    gguf_dir = repo_root / "gguf-py"
    if not (gguf_dir / "gguf" / "gguf_writer.py").is_file():
        raise CorpusError(f"GGUF Python package not found at {gguf_dir}")
    sys.path.insert(0, str(gguf_dir))
    try:
        import gguf  # type: ignore[import-not-found]
    except ImportError as exc:
        raise CorpusError(f"cannot import gguf from {gguf_dir}: {exc}") from exc
    return gguf


def write_gguf(corpus: dict[str, Any], output_path: Path, repo_root: Path) -> int:
    """Write corpus data through gguf.GGUFWriter; return the JSON byte count."""
    gguf = _gguf_module(repo_root)
    payload = (json.dumps(corpus, ensure_ascii=False, separators=(",", ":"), sort_keys=True) + "\n").encode("utf-8")
    writer = gguf.GGUFWriter(output_path, arch="micronaut_aiml")
    try:
        writer.add_name("Micronaut Alice AIML Corpus")
        writer.add_description("AIML XML source archive and category index; not model weights")
        writer.add_string("micronaut.aiml.schema", SCHEMA)
        writer.add_uint64("micronaut.aiml.source_count", corpus["source_count"])
        writer.add_uint64("micronaut.aiml.category_count", corpus["category_count"])
        writer.add_array("micronaut.aiml.source_files", [source["path"] for source in corpus["sources"]])
        # GGUFWriter's plain-tensor path supports signed I8, not raw U8.
        # Viewing bytes as int8 preserves every bit when they are read back.
        writer.add_tensor(TENSOR_NAME, np.frombuffer(payload, dtype=np.int8).copy())
        writer.write_header_to_file()
        writer.write_kv_data_to_file()
        writer.write_tensors_to_file(progress=False)
    finally:
        writer.close()
    return len(payload)


def write_jsonl(corpus: dict[str, Any], output_path: Path) -> int:
    """Write a line-oriented corpus stream for the daemon's native transport."""
    output_path.parent.mkdir(parents=True, exist_ok=True)
    records = [
        {"@kind": JSONL_MANIFEST_KIND, "schema": SCHEMA,
         "source_count": corpus["source_count"], "category_count": corpus["category_count"]}
    ]
    records.extend({"@kind": JSONL_SOURCE_KIND, "index": index, **source}
                   for index, source in enumerate(corpus["sources"]))
    records.extend({"@kind": JSONL_CATEGORY_KIND, "index": index, "record": category}
                   for index, category in enumerate(corpus["categories"]))
    with output_path.open("w", encoding="utf-8", newline="\n") as stream:
        for record in records:
            stream.write(json.dumps(record, ensure_ascii=False, separators=(",", ":"), sort_keys=True))
            stream.write("\n")
    return output_path.stat().st_size


def load_jsonl(input_path: Path) -> dict[str, Any]:
    """Read and validate the manifest/source/category JSONL record stream."""
    manifest: dict[str, Any] | None = None
    sources: list[dict[str, str]] = []
    categories: list[dict[str, Any]] = []
    with input_path.open("r", encoding="utf-8") as stream:
        for line_number, line in enumerate(stream, 1):
            if not line.strip():
                continue
            try:
                record = json.loads(line)
            except json.JSONDecodeError as exc:
                raise CorpusError(f"JSONL line {line_number}: {exc}") from exc
            kind = record.get("@kind")
            if line_number == 1:
                if kind != JSONL_MANIFEST_KIND or record.get("schema") != SCHEMA:
                    raise CorpusError("JSONL must start with a supported AIML corpus manifest")
                manifest = record
            elif kind == JSONL_SOURCE_KIND:
                if record.get("index") != len(sources) or not isinstance(record.get("path"), str) or not isinstance(record.get("text"), str):
                    raise CorpusError(f"JSONL line {line_number}: invalid source record")
                sources.append({"path": record["path"], "text": record["text"]})
            elif kind == JSONL_CATEGORY_KIND:
                if record.get("index") != len(categories) or not isinstance(record.get("record"), dict):
                    raise CorpusError(f"JSONL line {line_number}: invalid category record")
                categories.append(record["record"])
            else:
                raise CorpusError(f"JSONL line {line_number}: unexpected record kind {kind!r}")
    if manifest is None or manifest.get("source_count") != len(sources) or manifest.get("category_count") != len(categories):
        raise CorpusError("JSONL record counts do not match the manifest")
    return {"schema": SCHEMA, "source_count": len(sources), "category_count": len(categories),
            "sources": sources, "categories": categories}


def load_gguf(input_path: Path, repo_root: Path) -> dict[str, Any]:
    """Load corpus JSON from the GGUF tensor without accessing AIML XML files."""
    gguf = _gguf_module(repo_root)
    reader = gguf.GGUFReader(input_path)
    field = reader.get_field("micronaut.aiml.schema")
    if field is None or field.contents() != SCHEMA:
        raise CorpusError("GGUF does not contain a supported Micronaut AIML corpus")
    tensor = next((item for item in reader.tensors if item.name == TENSOR_NAME), None)
    if tensor is None:
        raise CorpusError(f"GGUF tensor {TENSOR_NAME!r} is missing")
    try:
        corpus = json.loads(tensor.data.tobytes().decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise CorpusError("GGUF corpus tensor is not valid UTF-8 JSON") from exc
    if corpus.get("schema") != SCHEMA or not isinstance(corpus.get("categories"), list) or not isinstance(corpus.get("sources"), list):
        raise CorpusError("corpus tensor has an invalid schema or shape")
    if corpus.get("category_count") != len(corpus["categories"]) or corpus.get("source_count") != len(corpus["sources"]):
        raise CorpusError("corpus counts do not match the stored records")
    return corpus


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("source", type=Path, nargs="?", help="directory containing AIML files")
    parser.add_argument("output", type=Path, nargs="?", help="output .gguf path")
    parser.add_argument("--output-path", type=Path, help="output path when compiling from --from-jsonl")
    parser.add_argument("--repo-root", type=Path, help="llama.cpp root containing gguf-py (defaults to this file's parent)")
    parser.add_argument("--inspect", type=Path, help="inspect an existing corpus GGUF instead of compiling")
    parser.add_argument("--from-jsonl", type=Path, help="compile an existing runtime JSONL corpus instead of AIML folders")
    args = parser.parse_args(argv)

    repo_root = args.repo_root.resolve() if args.repo_root else Path(__file__).resolve().parent.parent
    try:
        if args.inspect:
            corpus = load_jsonl(args.inspect) if args.inspect.suffix.lower() == ".jsonl" else load_gguf(args.inspect, repo_root)
            print(json.dumps({"path": str(args.inspect), "sources": corpus["source_count"], "categories": corpus["category_count"]}))
            return 0
        if args.from_jsonl and args.source:
            parser.error("choose either source directory or --from-jsonl")
        output_path = args.output_path or args.output
        if output_path is None:
            parser.error("output is required unless --inspect is used")
        if args.from_jsonl:
            corpus = load_jsonl(args.from_jsonl.resolve())
        elif args.source is not None:
            corpus = compile_corpus(args.source.resolve())
        else:
            parser.error("source directory or --from-jsonl is required")
        if output_path.suffix.lower() == ".jsonl":
            payload_size = write_jsonl(corpus, output_path.resolve())
            output_format = "JSONL"
        else:
            payload_size = write_gguf(corpus, output_path.resolve(), repo_root)
            output_format = "GGUF"
        print(json.dumps({
            "output": str(output_path.resolve()),
            "format": output_format,
            "architecture": "micronaut_aiml" if output_format == "GGUF" else None,
            "sources": corpus["source_count"],
            "categories": corpus["category_count"],
            "serialized_bytes": payload_size,
            "original_sources_embedded": True,
            "loadable_as_llama_model": False,
        }))
        return 0
    except (CorpusError, OSError, ValueError) as exc:
        print(f"aiml_to_gguf: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
