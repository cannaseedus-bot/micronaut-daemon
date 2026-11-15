"""
On-the-fly concept-field activations for a prompt using EmbeddingGemma 2.

Encodes the prompt, scores it against all AIML pattern vectors, then walks
words.manifest.json to find which ⟁ concept fields each top-k match activates.
Produces the S(g,c) column consumed by the ConceptFieldAccumulator.

Usage:
    python scripts/gemma-fields.py "tell me a joke" --top 20
    python scripts/gemma-fields.py "Hi how are you" --top 10 --output out.json
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
PAIRS    = ROOT / "build/io/aiml-embeddinggemma2-vectors/aiml_pattern_template_pairs.jsonl"
WORDS   = ROOT / "data/manifest/words.manifest.json"


def load_pairs(path: Path) -> dict[int, dict]:
    pairs: dict[int, dict] = {}
    with path.open(encoding="utf-8") as fh:
        for line in fh:
            rec = json.loads(line)
            pairs[rec["index"]] = rec
    return pairs


def concept_fields_for(gram: str, words: dict) -> list[str]:
    """Walk words.manifest to collect ⟁ concept-field refs reachable from gram."""
    seen: set[str] = set()
    queue = [gram.lower()]
    fields: list[str] = []
    while queue:
        key = queue.pop(0)
        if key in seen:
            continue
        seen.add(key)
        for entry in words.get(key, []):
            if isinstance(entry, str):
                if entry.startswith("⟁"):
                    if entry not in fields:
                        fields.append(entry)
                else:
                    queue.append(entry.lower())
    return fields


def run(text: str, top_k: int) -> list[dict]:
    vector, meta = encode(text, manifest_path=MANIFEST)
    patterns = np.load(VECTORS, mmap_mode="r")
    scores = np.asarray(patterns @ vector, dtype=np.float64)
    top_idx = np.argsort(scores)[::-1][:top_k]

    pairs = load_pairs(PAIRS)
    words = json.loads(WORDS.read_text(encoding="utf-8"))

    activations: list[dict] = []
    for row in top_idx.tolist():
        pair = pairs.get(row, {})
        gram = pair.get("pattern", "")
        cosine = float(scores[row])
        fields = concept_fields_for(gram, words)
        activations.append({
            "gram": gram,
            "source_vector_row": row,
            "cosine": round(cosine, 6),
            "concept_fields": fields,
        })
    return activations


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("text",             help="user prompt to score")
    parser.add_argument("--top",  type=int, default=20, metavar="K",
                        help="number of top pattern matches to return (default: 20)")
    parser.add_argument("--output", type=Path, metavar="PATH",
                        help="write JSON output to this file instead of stdout")
    args = parser.parse_args()

    activations = run(args.text, args.top)

    out = json.dumps(activations, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(out + "\n", encoding="utf-8")
        print(f"wrote {len(activations)} activations → {args.output}")
    else:
        print(out)


if __name__ == "__main__":
    main()
