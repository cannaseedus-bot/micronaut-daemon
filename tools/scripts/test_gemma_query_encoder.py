"""Offline smoke test for the pinned EmbeddingGemma 2 AIML query contract."""
import hashlib
import json
from pathlib import Path

import numpy as np

from encode_gemma_query import MANIFEST, PROMPT, encode

ROOT = Path(__file__).resolve().parents[1]
VECTORS = ROOT / "build/io/aiml-embeddinggemma2-vectors/pattern_vectors.f32.npy"


def main():
    vector, metadata = encode("WHAT IS AI")
    assert vector.shape == (256,) and vector.dtype == np.dtype("float32")
    assert np.isfinite(vector).all()
    assert abs(float(np.linalg.norm(vector.astype(np.float64))) - 1.0) < 0.001
    assert metadata["prompt_name"] == PROMPT
    assert metadata["manifest_sha256"] == hashlib.sha256(MANIFEST.read_bytes()).hexdigest()
    assert metadata["vector_sha256"] == hashlib.sha256(vector.tobytes()).hexdigest()
    patterns = np.load(VECTORS, mmap_mode="r")
    scores = np.asarray(patterns @ vector)
    rank = int(np.count_nonzero(scores > scores[1])) + 1
    assert rank <= 10, f"aligned AIML row 1 ranked {rank}"
    pair_path = VECTORS.parent / "aiml_pattern_template_pairs.jsonl"
    with pair_path.open(encoding="utf-8") as stream:
        next(stream)
        pair = json.loads(next(stream))
    assert pair["index"] == pair["A"]["vector_row"] == 1
    assert pair["pattern"] == "WHAT IS AI"
    print(f"query encoder: 256d normalized; AIML row 1 rank {rank}, cosine {scores[1]:.6f}")


if __name__ == "__main__":
    main()
