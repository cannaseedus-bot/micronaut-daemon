"""Materialize a small source-backed AIML graph binding fixture."""
import hashlib
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "build/aiml-relational-pilot"
VECTORS = ROOT / "build/io/aiml-embeddinggemma2-vectors"
ROWS = (0, 1, 2)


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    graph = BASE / "graph.gml"
    graph_hash = sha(graph)
    pairs_path = VECTORS / "aiml_pattern_template_pairs.jsonl"
    pairs = {}
    with pairs_path.open(encoding="utf-8") as stream:
        for row, line in enumerate(stream):
            if row in ROWS:
                pair = json.loads(line)
                assert pair["index"] == pair["A"]["vector_row"] == pair["B"]["vector_row"] == row
                pairs[row] = pair
            if row >= max(ROWS):
                break
    assert len(pairs) == len(ROWS)
    keys = []
    for row in ROWS:
        for offset, role in enumerate(("pattern", "template")):
            keys.append({"schema": "gemma.bridge.relational-key.v1", "authority": "data_only",
                         "store_id": "aiml-embeddinggemma2", "record_id": f"aiml:{row}",
                         "vector_row": row, "entity_id": f"{role}:{row}",
                         "relation_type": role, "graph_contract_hash": graph_hash,
                         "graph_node_id": row * 2 + offset})
    keys_path = BASE / "keys.jsonl"
    keys_path.write_text("".join(json.dumps(key, separators=(",", ":")) + "\n" for key in keys), encoding="utf-8")
    vector_manifest = json.loads((VECTORS / "manifest.json").read_text(encoding="utf-8"))
    manifest = {"schema": "gemma.bridge.graph-binding.v1", "authority": "data_only",
                "store_id": "aiml-embeddinggemma2", "graph_file": "graph.gml",
                "graph_sha256": graph_hash, "keys_file": "keys.jsonl", "keys_sha256": sha(keys_path),
                "pairs_sha256": sha(pairs_path), "source_sha256": vector_manifest["source_sha256"],
                "vector_rows": vector_manifest["categories"], "node_count": 6, "edge_count": 3}
    (BASE / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(f"pilot graph={graph_hash} rows={list(ROWS)}")


if __name__ == "__main__":
    main()
