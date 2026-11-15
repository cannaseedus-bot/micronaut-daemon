"""Read-only Stage-2 validator for the fixed CCC4 EmbeddingGemma2 binding.

Emits a binding record to stdout. Does not execute vector operators or grant
admission. The record is specific to the row-index-mod64 fixture.
"""
import argparse
import hashlib
import json
import pathlib
import re
import subprocess
import sys

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / "tools"))
from encode_operator_plan import encode  # noqa: E402
from plan_resolver import resolve  # noqa: E402

VECTOR_DIR = ROOT / "build/io/aiml-embeddinggemma2-vectors"
PLAN = ROOT / "build/ccc4-operator-plan.v1.json"
GML = ROOT / "build/ccc4-tensor.gml"
GML_EXE = ROOT / "build/gml-stage1/Release/gml.exe"
NAMES = ("pattern_vectors.f32.npy", "template_vectors.f32.npy", "category_vectors.f32.npy")
HASH = re.compile(r"topology_hash=([0-9a-f]{64}) contract_hash=([0-9a-f]{64})")


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def validate():
    if not __debug__:
        raise ValueError("run without Python -O; plan assertions must remain active")
    manifest = json.loads((VECTOR_DIR / "manifest.json").read_text(encoding="utf-8"))
    if manifest.get("schema") != "micronaut.aiml.embeddinggemma-vectors.v1":
        raise ValueError("manifest schema mismatch")
    if manifest.get("authority") != "data_only" or manifest.get("semanticCommit") is not False:
        raise ValueError("manifest authority must remain data_only")
    if (manifest.get("categories"), manifest.get("dimensions"), manifest.get("dtype")) != (99524, 256, "float32"):
        raise ValueError("manifest shape or dtype differs from fixed plan")
    expected_files = {"A_pattern_context": NAMES[0], "B_template": NAMES[1],
                      "category_midpoint": NAMES[2], "pair_records": "aiml_pattern_template_pairs.jsonl"}
    if manifest.get("vector_files") != expected_files:
        raise ValueError("manifest artifact roles differ from fixed plan")

    plan = json.loads(PLAN.read_text(encoding="utf-8"))
    try:
        operator_bytes = encode(plan)
    except (AssertionError, KeyError, StopIteration, ValueError) as error:
        raise ValueError(f"operator plan invalid: {error}") from error
    if plan["declared"]["materialized"] is not False:
        raise ValueError("Stage-2 plan is materialized")
    resolved = resolve(PLAN, VECTOR_DIR / NAMES[0])
    if resolved["operator_plan_hash"] != hashlib.sha256(operator_bytes).hexdigest():
        raise ValueError("operator plan resolver identity mismatch")

    arrays = {}
    for name in NAMES:
        path = VECTOR_DIR / name
        array = np.load(path, mmap_mode="r", allow_pickle=False)
        if array.shape != (99524, 256) or array.dtype != np.dtype("<f4") or not array.flags.c_contiguous:
            raise ValueError(f"NPY header mismatch: {name}")
        if path.stat().st_size != array.offset + array.nbytes:
            raise ValueError(f"NPY payload length mismatch: {name}")
        arrays[name] = {"shape": [99524, 256], "dtype": "float32", "sha256": sha256(path)}

    pair_path = VECTOR_DIR / expected_files["pair_records"]
    count = 0
    with pair_path.open(encoding="utf-8") as stream:
        for count, line in enumerate(stream, 1):
            row = json.loads(line)
            expected = count - 1
            if row.get("index") != expected or row.get("A", {}).get("vector_row") != expected or row.get("B", {}).get("vector_row") != expected:
                raise ValueError(f"pair row alignment mismatch at line {count}")
    if count != 99524:
        raise ValueError(f"pair count mismatch: {count}")

    source = ROOT / "build/io/aiml-corpus.jsonl"
    if not source.is_file() or sha256(source) != manifest["source_sha256"]:
        raise ValueError("local AIML source digest mismatch")
    if not GML_EXE.is_file():
        raise ValueError("build the Stage-1 gml target first")
    result = subprocess.run([str(GML_EXE), str(GML)], capture_output=True, text=True, check=True)
    match = HASH.search(result.stdout)
    if not match:
        raise ValueError("Stage-1 GML identity output missing")
    topology_hash, contract_hash = match.groups()
    if topology_hash != "af51f5244ce5ea7fdb352d9fae31ddf511aaca86f442515e81471df5726b1116":
        raise ValueError("unexpected CCC4 topology identity")
    if contract_hash != "94c9a48fba859b751acfb844fff046f59d6de6b419706614e7daa7fff97b22d6":
        raise ValueError("unexpected CCC4 tensor contract identity")
    return {
        "schema": "ccc4.vector-binding.candidate.v1",
        "status": "BINDINGS_VALIDATED_CANDIDATE",
        "topology_hash": topology_hash,
        "contract_hash": contract_hash,
        "operator_plan_hash": hashlib.sha256(operator_bytes).hexdigest(),
        "plan_document_sha256": sha256(PLAN),
        "manifest_sha256": sha256(VECTOR_DIR / "manifest.json"),
        "source_sha256": manifest["source_sha256"],
        "artifacts": arrays,
        "selected_artifact": {
            "role": "A_pattern_context",
            "filename": NAMES[0],
            "shape": [99524, 256],
            "dtype": "float32",
            "sha256": arrays[NAMES[0]]["sha256"],
        },
        "kernel": {
            "filename": "vector_lane.cl",
            "entry": "row_mod_mean",
            "backend": "OpenCL 1.2",
            "sha256": sha256(ROOT / "vector_lane.cl"),
        },
        "alignment_digest": sha256(pair_path),
        "declared_source_shape": [99524, 256],
        "declared_target_shape": [64, 256],
        "partition_counts": resolved["partition_counts"],
        "materialized": False,
        "execution_authorized": False,
        "persistence_authorized": False,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=pathlib.Path, help="optional path for the binding record")
    args = parser.parse_args()
    try:
        record = validate()
        rendered = json.dumps(record, indent=2, sort_keys=True) + "\n"
        if args.output:
            args.output.write_text(rendered, encoding="utf-8")
        else:
            sys.stdout.write(rendered)
    except (OSError, ValueError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        parser.exit(1, f"validator: {error}\n")


if __name__ == "__main__":
    main()
