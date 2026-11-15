"""Read-only verification of the existing EmbeddingGemma2 AIML vector artifacts."""
import hashlib
import json
from pathlib import Path

import numpy as np

root = Path(__file__).resolve().parents[1] / "build/io"
folder = root / "aiml-embeddinggemma2-vectors"
manifest = json.loads((folder / "manifest.json").read_text(encoding="utf-8"))
rows, dimension = manifest["categories"], manifest["dimensions"]
for name in ("pattern_vectors.f32.npy", "template_vectors.f32.npy", "category_vectors.f32.npy"):
    array = np.load(folder / name, mmap_mode="r", allow_pickle=False)
    assert array.shape == (rows, dimension), (name, array.shape)
    assert array.dtype == np.dtype("<f4"), (name, array.dtype)
    assert array.flags.c_contiguous, name
    print(name, array.shape, array.dtype, (folder / name).stat().st_size)

pair_path = folder / "aiml_pattern_template_pairs.jsonl"
with pair_path.open(encoding="utf-8") as stream:
    for index, line in enumerate(stream):
        record = json.loads(line)
        assert record["index"] == index, (index, "index")
        assert record["A"]["vector_row"] == index, (index, "A")
        assert record["B"]["vector_row"] == index, (index, "B")
assert index + 1 == rows, (index + 1, rows)
print("pair rows aligned:", index + 1)

source = root / "aiml-corpus.jsonl"
if source.exists():
    digest = hashlib.sha256(source.read_bytes()).hexdigest()
    assert digest == manifest["source_sha256"], (digest, manifest["source_sha256"])
    print("source SHA-256 matches:", digest)
else:
    print("source JSONL unavailable at", source)
