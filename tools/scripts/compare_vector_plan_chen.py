"""Compare v2 row-mod mean with the runtime's Ch'en-verified OpenCL path."""
import argparse
import copy
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile

import numpy as np

from verify_vector_plan_v2 import canonical_bytes

ROOT = Path(__file__).resolve().parents[1]
BIN = ROOT / "build/gml-stage1/Release"


def run(command, **kwargs):
    result = subprocess.run(command, capture_output=True, text=True, **kwargs)
    if result.returncode:
        raise RuntimeError(f"{' '.join(map(str, command))}: {result.stderr.strip()}")
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, default=ROOT / "build/ccc4-plan-v2-example.npy")
    args = parser.parse_args()
    source = np.load(args.source, allow_pickle=False)
    if source.ndim != 2 or source.dtype != np.float32 or source.shape[0] < 64:
        raise ValueError("source must be float32 rows with at least 64 rows")
    plan = copy.deepcopy(json.loads((ROOT / "build/ccc4-operator-plan.v2.example.json").read_text()))
    plan["source_rows"], plan["dimension"] = source.shape
    selected = {"source", "assign", "fold", "accumulate", "reduce"}
    plan["operators"] = [op for op in plan["operators"] if op["id"] in selected]
    plan["data_flow"] = [dict(source=a, target=b) for a, b in
                         zip(("source", "assign", "fold"), ("assign", "fold", "reduce"))]
    plan["execution_dependencies"] = [dict(before=e["source"], after=e["target"])
                                      for e in plan["data_flow"]]
    plan_hash = hashlib.sha256(canonical_bytes(plan)).hexdigest()
    with tempfile.TemporaryDirectory() as directory:
        folder = Path(directory)
        plan_path, candidate_path, chen_path = folder / "plan.json", folder / "candidate.bin", folder / "chen.bin"
        plan_path.write_text(json.dumps(plan), encoding="utf-8")
        run([BIN / "vector_plan_cli.exe", plan_path, args.source, "--execute", candidate_path],
            env={**os.environ, "MICRONAUT_VECTOR_PLAN_V2": "1"})
        chen = run([BIN / "vector_lane.exe", args.source, "--execute", chen_path])
        if "candidate:Chen:shape_finite_count_bit_exact_verified" not in chen.stderr:
            raise AssertionError("runtime did not report Ch'en verification")
        candidate, verified = candidate_path.read_bytes(), chen_path.read_bytes()
        if candidate != verified:
            a = np.frombuffer(candidate, dtype="<f4")
            b = np.frombuffer(verified, dtype="<f4")
            raise AssertionError(f"v2/Ch'en candidate mismatch: {np.count_nonzero(a != b)} values")
        print(f"plan_sha256={plan_hash}")
        print(f"source_sha256={hashlib.sha256(args.source.read_bytes()).hexdigest()}")
        print(f"candidate_sha256={hashlib.sha256(candidate).hexdigest()}")
        print(f"chen_match=bit_exact shape=[64,{source.shape[1]}]")


if __name__ == "__main__":
    main()
