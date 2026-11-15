"""Resolve the supported CCC4 operator-plan v1 mapping against an NPY header.

Stage 2 only: validates operators, ports, partition, and source metadata;
never reads vector elements, runs a kernel, or commits state.
"""
import argparse
import hashlib
import json
import pathlib
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "tools"))
from encode_operator_plan import encode  # noqa: E402

ARTIFACT_NAMES = {
    "EmbeddingGemma2.pattern_vectors": "pattern_vectors.f32.npy",
    "EmbeddingGemma2.template_vectors": "template_vectors.f32.npy",
    "EmbeddingGemma2.category_vectors": "category_vectors.f32.npy",
}


def resolve(plan_path: pathlib.Path, artifact_path: pathlib.Path) -> dict:
    plan = json.loads(plan_path.read_text(encoding="utf-8"))
    encoded = encode(plan)
    source = next(op for op in plan["operators"] if op["kind"] == "SOURCE")
    ref = source["params"]["artifact_ref"]
    if ref not in ARTIFACT_NAMES or artifact_path.name != ARTIFACT_NAMES[ref]:
        raise ValueError("SOURCE artifact_ref is unresolved or does not match supplied artifact")
    array = np.load(artifact_path, mmap_mode="r", allow_pickle=False)
    shape = plan["declared"]["source_shape"]
    if array.shape != tuple(shape) or array.dtype != np.dtype("<f4") or not array.flags.c_contiguous:
        raise ValueError("NPY header does not match declared C-contiguous little-endian f32 source")
    if artifact_path.stat().st_size != array.offset + array.nbytes:
        raise ValueError("NPY payload length does not match header")
    rows, dim = shape
    groups = plan["partition"]["groups"]
    counts = [rows // groups + (i < rows % groups) for i in range(groups)]
    if not all(counts):
        raise ValueError("empty group under reject policy")
    return {
        "contract": "ccc4.operator-plan.v1",
        "status": "BINDINGS_VALIDATED",
        "operator_plan_hash": hashlib.sha256(encoded).hexdigest(),
        "artifact_ref": ref,
        "artifact_path": str(artifact_path.resolve()),
        "source_shape": shape,
        "target_shape": plan["declared"]["target_shape"],
        "partition_counts": counts,
        "materialized": False,
        "execution_authorized": False,
        "persistence_authorized": False,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plan", type=pathlib.Path)
    parser.add_argument("artifact", type=pathlib.Path)
    args = parser.parse_args()
    try:
        print(json.dumps(resolve(args.plan, args.artifact), indent=2, sort_keys=True))
    except (OSError, ValueError, KeyError, TypeError, StopIteration, json.JSONDecodeError) as error:
        parser.exit(1, f"plan_resolver: {error}\n")


if __name__ == "__main__":
    main()
