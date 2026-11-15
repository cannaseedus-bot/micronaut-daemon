"""Compare every pinned v2 plan with the independent Ch'en CLI, byte for byte."""
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

from verify_vector_plan_v2 import canonical_bytes

ROOT = Path(__file__).resolve().parents[1]
CATALOG_DIR = ROOT / "build/ccc4-v2-admission"
SOURCE = ROOT / "build/io/aiml-embeddinggemma2-vectors/pattern_vectors.f32.npy"
BIN = ROOT / "build/gml-stage1/Release"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def run(args, env=None):
    result = subprocess.run([str(arg) for arg in args], capture_output=True, text=True, env=env)
    assert result.returncode == 0, (args, result.stderr)


def main():
    catalog_bytes = (CATALOG_DIR / "catalog.json").read_bytes()
    catalog = json.loads(catalog_bytes)
    with tempfile.TemporaryDirectory() as directory:
        folder = Path(directory)
        for name, record in catalog.items():
            plan_path = CATALOG_DIR / f"{name}.json"
            raw = plan_path.read_bytes()
            assert sha(raw) == record["file_sha256"], name
            assert sha(canonical_bytes(json.loads(raw))) == record["plan_sha256"], name
            candidate, reference = folder / "candidate.bin", folder / "chen.bin"
            run([BIN / "vector_plan_cli.exe", plan_path, SOURCE, "--execute", candidate],
                env={**os.environ, "MICRONAUT_VECTOR_PLAN_V2": "1"})
            run([BIN / "chen_vector_plan_cli.exe", plan_path, SOURCE, reference])
            assert candidate.read_bytes() == reference.read_bytes(), name
            print(f"{name}: Ch'en byte match {sha(candidate.read_bytes())}")
    print(f"catalog_sha256={sha(catalog_bytes)}")


if __name__ == "__main__":
    main()
