"""Build a data-only forward/reverse co-occurrence fold from AIML pattern rows.

Direction B is a transpose readout of the SAME observed events. It is not a
second observation and never increments a second count matrix.
"""
import argparse
from collections import Counter
import gzip
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent
SOURCE = ROOT / "build/io/aiml-embeddinggemma2-vectors/aiml_pattern_template_pairs.jsonl"
OUTPUT = ROOT / "build/io/aiml-grams/aiml-fold-pair.v1.json.gz"
MANIFEST = ROOT / "build/io/aiml-embeddinggemma2-vectors/manifest.json"
CORPUS = ROOT / "build/io/aiml-corpus.jsonl"
TOKEN = re.compile(r"[A-Z0-9]+(?:'[A-Z0-9]+)?")


def fold_rows(lines, radius=2):
    if not isinstance(radius, int) or radius < 1:
        raise ValueError("radius must be a positive integer")
    mass = Counter()
    vocabulary = set()
    row_count = event_count = 0
    for row_count, line in enumerate(lines, 1):
        row = json.loads(line)
        index = row_count - 1
        if (row.get("index") != index or row.get("A", {}).get("vector_row") != index or
                row.get("B", {}).get("vector_row") != index):
            raise ValueError(f"pattern row alignment mismatch at {index}")
        if row.get("authority") != "data_only" or row.get("graph_evidence") is not False:
            raise ValueError(f"unexpected pair authority at {index}")
        if not isinstance(row.get("pattern"), str):
            raise ValueError(f"pattern text missing at {index}")
        tokens = TOKEN.findall(row["pattern"].upper())
        vocabulary.update(tokens)
        # X is a token at position i; Y is a later token within the same
        # pattern and the declared radius. No window crosses a row boundary.
        for i, x in enumerate(tokens):
            for y in tokens[i + 1:i + 1 + radius]:
                mass[(y, x)] += 1
                event_count += 1
    return row_count, event_count, sorted(vocabulary), mass


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def build(source=SOURCE, radius=2, manifest_path=MANIFEST, corpus_path=CORPUS):
    manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    if manifest.get("schema") != "micronaut.aiml.embeddinggemma-vectors.v1" or \
       manifest.get("authority") != "data_only" or manifest.get("semanticCommit") is not False:
        raise ValueError("vector manifest contract mismatch")
    if sha256(corpus_path) != manifest.get("source_sha256"):
        raise ValueError("AIML corpus digest mismatch")
    with source.open("r", encoding="utf-8") as stream:
        rows, events, vocab, mass = fold_rows(stream, radius)
    if rows != manifest.get("categories"):
        raise ValueError("pair row count differs from manifest")
    ids = {token: index for index, token in enumerate(vocab)}
    edges = sorted(([ids[y], ids[x], count] for (y, x), count in mass.items()),
                   key=lambda edge: (edge[1], edge[0]))
    if sum(edge[2] for edge in edges) != events:
        raise ValueError("co-occurrence event conservation failed")
    return {
        "schema": "ccc4.fold-pair.observation.v1",
        "authority": "data_only",
        "semantic_truth": False,
        "selection_weight": None,
        "source": {"path": str(source.resolve()), "sha256": sha256(source), "rows": rows,
                   "field": "pattern", "row_alignment": "index=A.vector_row=B.vector_row",
                   "manifest_sha256": sha256(manifest_path),
                   "aiml_corpus_sha256": manifest["source_sha256"]},
        "tokenization": {"rule": "uppercase ASCII alphanumeric with optional internal apostrophe",
                         "wildcards": "excluded", "row_boundary": "hard_reset"},
        "context": {"direction": "right", "radius": radius},
        "axes": {"X": "earlier token", "Y": "later token within radius"},
        "fold_pair": {"forward": "M[Y,X]", "reverse": "transpose(M)[X,Y]",
                      "reverse_evidence": False, "independent_reverse_counts": False},
        "vocabulary": vocab,
        "events": events,
        "edges": edges,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=SOURCE)
    parser.add_argument("--output", type=Path, default=OUTPUT)
    parser.add_argument("--radius", type=int, default=2)
    args = parser.parse_args()
    try:
        result = build(args.source, args.radius)
        rendered = json.dumps(result, separators=(",", ":"), ensure_ascii=False, sort_keys=True).encode("utf-8")
        with args.output.open("wb") as raw:
            with gzip.GzipFile(fileobj=raw, mode="wb", filename="", mtime=0) as compressed:
                compressed.write(rendered)
        print(f"rows={result['source']['rows']} tokens={len(result['vocabulary'])} "
              f"events={result['events']} edges={len(result['edges'])} "
              f"output={args.output}")
    except (OSError, ValueError, KeyError, json.JSONDecodeError) as error:
        parser.exit(1, f"fold_pair: {error}\n")


if __name__ == "__main__":
    main()
