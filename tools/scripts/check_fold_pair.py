"""Check the stored fold-pair observations without deriving new evidence."""
import gzip
import hashlib
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[1]
ARTIFACT = ROOT / "build/io/aiml-grams/aiml-fold-pair.v1.json.gz"
MANIFEST = ROOT / "build/io/aiml-embeddinggemma2-vectors/manifest.json"
CORPUS = ROOT / "build/io/aiml-corpus.jsonl"
PAIRS = ROOT / "build/io/aiml-embeddinggemma2-vectors/aiml_pattern_template_pairs.jsonl"


def digest(path):
    h = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


def main():
    if not __debug__:
        raise ValueError("run without Python -O; checks must remain active")
    with gzip.open(ARTIFACT, "rt", encoding="utf-8") as stream:
        record = json.load(stream)
    assert record["schema"] == "ccc4.fold-pair.observation.v1"
    assert record["authority"] == "data_only" and record["semantic_truth"] is False
    assert record["selection_weight"] is None
    assert record["fold_pair"]["reverse"] == "transpose(M)[X,Y]"
    assert record["fold_pair"]["reverse_evidence"] is False
    assert record["source"]["sha256"] == digest(PAIRS)
    assert record["source"]["manifest_sha256"] == digest(MANIFEST)
    assert record["source"]["aiml_corpus_sha256"] == digest(CORPUS)
    assert record["source"]["rows"] == 99524
    vocabulary, edges = record["vocabulary"], record["edges"]
    assert vocabulary == sorted(set(vocabulary))
    assert all(len(edge) == 3 and 0 <= edge[0] < len(vocabulary) and
               0 <= edge[1] < len(vocabulary) and edge[2] > 0 for edge in edges)
    assert edges == sorted(edges, key=lambda edge: (edge[1], edge[0]))
    assert len({(edge[0], edge[1]) for edge in edges}) == len(edges)
    assert sum(edge[2] for edge in edges) == record["events"]
    print(f"fold pair checked: {record['source']['rows']} rows, {len(vocabulary)} tokens, "
          f"{record['events']} observed events, {len(edges)} sparse pairs; reverse=transpose only")


if __name__ == "__main__":
    try:
        main()
    except (OSError, KeyError, ValueError, AssertionError) as error:
        sys.exit(f"check_fold_pair: {error}")
