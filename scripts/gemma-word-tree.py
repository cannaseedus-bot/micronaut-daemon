"""
On-the-fly word tree for a gram using EmbeddingGemma 2.

Encodes the gram, finds its nearest neighbors in AIML pattern space, then
walks words.manifest.json to expand each neighbor into synonyms, ⟁ concept
fields, and phase tags — producing the disambiguation tree consumed by the
bigram/trigram co-activation layer.

The tree has three levels:
  root     : the query gram
  children : top-k AIML pattern neighbors (by cosine)
  leaves   : ⟁ fields, phase tags, and synonym chains reachable from each child

Usage:
    python scripts/gemma-word-tree.py bank --top 10
    python scripts/gemma-word-tree.py "tell me a joke" --top 15 --output tree.json
"""
import argparse
import json
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools" / "scripts"))

from encode_gemma_query import encode  # noqa: E402

MANIFEST = ROOT / "build/io/aiml-embeddinggemma2-vectors/manifest.json"
VECTORS  = ROOT / "build/io/aiml-embeddinggemma2-vectors/pattern_vectors.f32.npy"
PAIRS   = ROOT / "build/io/aiml-embeddinggemma2-vectors/aiml_pattern_template_pairs.jsonl"
WORDS   = ROOT / "data/manifest/words.manifest.json"
FIELDS  = ROOT / "data/manifest/semantic-fields.manifest.json"

_TAG_PREFIXES = ("⟁", "phase:", "intent:", "route:", "ELIZA-")


def load_pairs(path: Path) -> dict[int, dict]:
    pairs: dict[int, dict] = {}
    with path.open(encoding="utf-8") as fh:
        for line in fh:
            rec = json.loads(line)
            pairs[rec["index"]] = rec
    return pairs


def expand_gram(gram: str, words: dict, depth: int = 2) -> dict:
    """Recursively expand a gram through words.manifest up to `depth` hops."""
    node: dict = {"gram": gram, "tags": [], "synonyms": [], "fields": []}
    seen: set[str] = set()

    def _visit(key: str, cur_depth: int):
        if key in seen or cur_depth == 0:
            return
        seen.add(key)
        for entry in words.get(key, []):
            if isinstance(entry, str):
                if entry.startswith("⟁"):
                    if entry not in node["fields"]:
                        node["fields"].append(entry)
                elif any(entry.startswith(p) for p in _TAG_PREFIXES):
                    if entry not in node["tags"]:
                        node["tags"].append(entry)
                else:
                    if entry not in node["synonyms"]:
                        node["synonyms"].append(entry)
                    _visit(entry.lower(), cur_depth - 1)

    _visit(gram.lower(), depth)
    return node


def related_fields(concept_id: str, semantic_fields: dict) -> list[str]:
    key = f"fields:{concept_id}"
    return semantic_fields.get(key, [])


def run(gram: str, top_k: int) -> dict:
    vector, meta = encode(gram, manifest_path=MANIFEST)
    patterns = np.load(VECTORS, mmap_mode="r")
    scores = np.asarray(patterns @ vector, dtype=np.float64)
    top_idx = np.argsort(scores)[::-1][:top_k]

    pairs = load_pairs(PAIRS)
    words = json.loads(WORDS.read_text(encoding="utf-8"))
    semantic_fields = json.loads(FIELDS.read_text(encoding="utf-8"))

    children = []
    for row in top_idx.tolist():
        pair = pairs.get(row, {})
        neighbor = pair.get("pattern", "")
        cosine = float(scores[row])
        node = expand_gram(neighbor, words)
        node["source_vector_row"] = row
        node["cosine"] = round(cosine, 6)
        # attach field-level relations for each activated ⟁ field
        node["field_relations"] = {
            f: related_fields(f, semantic_fields)
            for f in node["fields"]
        }
        children.append(node)

    root_node = expand_gram(gram, words)
    root_node["source_vector_row"] = None
    root_node["children"] = children

    return {
        "schema": "gemma.word-tree.v1",
        "query": gram,
        "model": meta["model"],
        "top_k": top_k,
        "tree": root_node,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("gram",             help="word or gram to build the tree for")
    parser.add_argument("--top",  type=int, default=10, metavar="K",
                        help="top-k AIML pattern neighbors (default: 10)")
    parser.add_argument("--output", type=Path, metavar="PATH",
                        help="write JSON output to this file instead of stdout")
    args = parser.parse_args()

    tree = run(args.gram, args.top)

    out = json.dumps(tree, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(out + "\n", encoding="utf-8")
        child_count = len(tree["tree"]["children"])
        print(f"word tree: {child_count} neighbors, {len(tree['tree']['fields'])} root fields → {args.output}")
    else:
        print(out)


if __name__ == "__main__":
    main()
