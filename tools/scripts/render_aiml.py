#!/usr/bin/env python3
"""Render validated basic AIML 2.0 categories from a JSON binding manifest."""

from __future__ import annotations

import argparse
import html
import json
import sys
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

from jinja2 import Environment, FileSystemLoader, StrictUndefined


class ManifestError(ValueError):
    pass


def _validate_nodes(nodes: Any, allowed_tags: set[str], attrs_by_tag: dict[str, set[str]], path: str) -> None:
    if not isinstance(nodes, list):
        raise ManifestError(f"{path} must be a list")
    for index, node in enumerate(nodes):
        current = f"{path}[{index}]"
        if isinstance(node, str):
            continue
        if not isinstance(node, dict):
            raise ManifestError(f"{current} must be text or a template node object")
        tag = node.get("tag")
        if tag not in allowed_tags:
            raise ManifestError(f"{current}: unsupported AIML tag {tag!r}")
        unknown_fields = set(node) - {"tag", "attrs", "content"}
        if unknown_fields:
            raise ManifestError(f"{current}: unsupported node fields {sorted(unknown_fields)}")
        attrs = node.get("attrs", {})
        if not isinstance(attrs, dict):
            raise ManifestError(f"{current}.attrs must be an object")
        unknown_attrs = set(attrs) - attrs_by_tag.get(tag, set())
        if unknown_attrs:
            raise ManifestError(f"{current}: unsupported {tag} attributes {sorted(unknown_attrs)}")
        for key, value in attrs.items():
            if key == "index":
                try:
                    if int(value) < 1:
                        raise ValueError
                except (TypeError, ValueError):
                    raise ManifestError(f"{current}: {tag}.index must be a positive integer") from None
            elif not isinstance(value, str):
                raise ManifestError(f"{current}: {tag}.{key} must be a string")
        content = node.get("content", [])
        if tag in {"star", "thatstar", "topicstar", "bot", "get", "br"} and content:
            raise ManifestError(f"{current}: {tag} does not accept children")
        _validate_nodes(content, allowed_tags, attrs_by_tag, f"{current}.content")


def validate_manifest(manifest: Any, bindings: dict[str, Any]) -> int:
    if not isinstance(manifest, dict) or manifest.get("schema") != "micronaut.aiml.jinja-manifest.v1":
        raise ManifestError("manifest schema must be micronaut.aiml.jinja-manifest.v1")
    brains = manifest.get("brains")
    if not isinstance(brains, list) or not brains:
        raise ManifestError("manifest must contain at least one brain")
    bindings_data = bindings.get("bindings", {})
    allowed_tags = set(bindings_data)
    attrs_by_tag = bindings.get("attributes", {})
    attrs_by_tag = {tag: set(attrs) for tag, attrs in attrs_by_tag.items()}
    count = 0
    for b_index, brain in enumerate(brains):
        if not isinstance(brain, dict):
            raise ManifestError(f"brains[{b_index}] must be an object")
        for c_index, category in enumerate(brain.get("categories", [])):
            location = f"brains[{b_index}].categories[{c_index}]"
            if not isinstance(category, dict) or not str(category.get("pattern", "")).strip():
                raise ManifestError(f"{location} must define a non-empty pattern")
            if "that" in category and not isinstance(category["that"], str):
                raise ManifestError(f"{location}.that must be a string")
            _validate_nodes(category.get("template"), allowed_tags, attrs_by_tag, f"{location}.template")
            count += 1
        topics = brain.get("topics", [])
        if not isinstance(topics, list):
            raise ManifestError(f"brains[{b_index}].topics must be a list")
        names: set[str] = set()
        for t_index, topic in enumerate(topics):
            name = topic.get("name") if isinstance(topic, dict) else None
            if not isinstance(name, str) or not name.strip() or name in names:
                raise ManifestError(f"brains[{b_index}].topics[{t_index}] needs a unique non-empty name")
            names.add(name)
            categories = topic.get("categories", [])
            if not isinstance(categories, list):
                raise ManifestError(f"brains[{b_index}].topics[{t_index}].categories must be a list")
            for c_index, category in enumerate(categories):
                location = f"brains[{b_index}].topics[{t_index}].categories[{c_index}]"
                if not isinstance(category, dict) or not str(category.get("pattern", "")).strip():
                    raise ManifestError(f"{location} must define a non-empty pattern")
                if "that" in category and not isinstance(category["that"], str):
                    raise ManifestError(f"{location}.that must be a string")
                _validate_nodes(category.get("template"), allowed_tags, attrs_by_tag, f"{location}.template")
                count += 1
    return count


def main() -> int:
    root = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--manifest", type=Path, default=root / "examples" / "aiml_basic_brain.json")
    parser.add_argument("--bindings", type=Path, default=root / "aiml_bindings.v1.json")
    parser.add_argument("--template-dir", type=Path, default=root / "templates")
    parser.add_argument("--output", type=Path, default=root / "build" / "daemon_basic.aiml")
    args = parser.parse_args()

    manifest = json.loads(args.manifest.read_text(encoding="utf-8"))
    bindings = json.loads(args.bindings.read_text(encoding="utf-8"))
    category_count = validate_manifest(manifest, bindings)

    def raise_unsupported(tag: str) -> str:
        raise ManifestError(f"template uses unsupported construct {tag!r}")

    env = Environment(
        loader=FileSystemLoader(str(args.template_dir)),
        undefined=StrictUndefined,
        autoescape=False,
        trim_blocks=True,
        lstrip_blocks=True,
    )
    env.filters["xml_escape"] = lambda value: html.escape(str(value), quote=True)
    env.globals["raise_unsupported"] = raise_unsupported
    renderer = env.get_template("aiml_macros.jinja")
    xml_text = renderer.module.render_brain(manifest)
    document = ET.fromstring(xml_text)
    if document.tag != "aiml":
        raise ManifestError("rendered root element must be <aiml>")
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(xml_text.rstrip() + "\n", encoding="utf-8", newline="\n")
    print(f"Rendered {category_count} categories to {args.output}")
    print(f"Validated XML root: <{document.tag} version={document.attrib.get('version', '')}>")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except (OSError, json.JSONDecodeError, ManifestError) as exc:
        print(f"render_aiml: error: {exc}", file=sys.stderr)
        raise SystemExit(2)
