"""Encode one AIML retrieval query with the pinned, locally cached EmbeddingGemma 2."""
import argparse
import hashlib
import json
import os
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
MANIFEST = ROOT / "build/io/aiml-embeddinggemma2-vectors/manifest.json"
PROMPT = "Retrieval-query"


def encode(text: str, manifest_path: Path = MANIFEST) -> tuple[np.ndarray, dict]:
    if not text or not text.strip():
        raise ValueError("query text must be nonempty")
    manifest_bytes = manifest_path.read_bytes()
    manifest = json.loads(manifest_bytes)
    if (manifest.get("schema") != "micronaut.aiml.embeddinggemma-vectors.v1"
            or manifest.get("model") != "google/embeddinggemma-2"
            or manifest.get("dimensions") != 256
            or manifest.get("dtype") != "float32"
            or manifest.get("authority") != "data_only"
            or manifest.get("semanticCommit") is not False):
        raise ValueError("unsupported AIML vector manifest")
    snapshot = Path(manifest["model_snapshot"])
    if not snapshot.is_dir() or not (snapshot / "model.safetensors").is_file():
        raise FileNotFoundError(f"pinned EmbeddingGemma 2 snapshot unavailable: {snapshot}")
    config = json.loads((snapshot / "config_sentence_transformers.json").read_text(encoding="utf-8"))
    if config.get("prompts", {}).get(PROMPT) != "task: search result | query: ":
        raise ValueError("pinned model query prompt changed")
    os.environ["HF_HUB_OFFLINE"] = "1"
    os.environ["TRANSFORMERS_OFFLINE"] = "1"
    from sentence_transformers import SentenceTransformer

    model = SentenceTransformer(str(snapshot), device="cpu", local_files_only=True)
    raw = model.encode(text.strip(), prompt_name=PROMPT, truncate_dim=256,
                       normalize_embeddings=True, convert_to_numpy=True,
                       show_progress_bar=False)
    vector = np.asarray(raw, dtype="<f4")
    if vector.shape != (256,) or not np.isfinite(vector).all():
        raise ValueError("encoder returned an invalid vector")
    norm = float(np.linalg.norm(vector.astype(np.float64)))
    if not np.isfinite(norm) or norm <= 0.0:
        raise ValueError("query vector has zero or nonfinite norm")
    vector = np.asarray(vector.astype(np.float64) / norm, dtype="<f4")
    metadata = {
        "schema": "gemma.bridge.query-vector.v1",
        "model": manifest["model"],
        "model_snapshot": str(snapshot),
        "manifest_sha256": hashlib.sha256(manifest_bytes).hexdigest(),
        "prompt_name": PROMPT,
        "prompt": config["prompts"][PROMPT],
        "shape": [256],
        "dtype": "float32-le",
        "normalization": "L2 after Matryoshka truncation",
        "vector_sha256": hashlib.sha256(vector.tobytes()).hexdigest(),
    }
    return vector, metadata


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("text", help="user query to encode")
    parser.add_argument("--output", type=Path, required=True, help="output .npy path")
    args = parser.parse_args()
    vector, metadata = encode(args.text)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    np.save(args.output, vector, allow_pickle=False)
    sidecar = args.output.with_suffix(args.output.suffix + ".json")
    sidecar.write_text(json.dumps(metadata, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"vector": str(args.output), "metadata": str(sidecar), **metadata}))


if __name__ == "__main__":
    main()
