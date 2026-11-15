"""Canonical v2 plan identity and optional independent Ch'en candidate comparison."""
import argparse
import hashlib
import json
from pathlib import Path

import numpy as np


def canonical_bytes(plan):
    """Semantic JSON encoding: sorted keys, compact UTF-8, graph arrays sorted by identity."""
    plan = json.loads(json.dumps(plan))
    plan["operators"].sort(key=lambda item: item["id"])
    for key in ("data_flow", "execution_dependencies", "containment"):
        plan[key].sort(key=lambda item: json.dumps(item, sort_keys=True, separators=(",", ":")))
    return json.dumps(plan, sort_keys=True, separators=(",", ":"), ensure_ascii=False,
                      allow_nan=False).encode("utf-8")


def digest(data):
    return hashlib.sha256(data).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("plan", type=Path)
    parser.add_argument("--candidate", type=Path, help="CLI raw little-endian float32 output")
    parser.add_argument("--chen", type=Path, help="independently produced Ch'en .npy reference")
    parser.add_argument("--chen-sha256", help="expected SHA-256 of the Ch'en reference file")
    args = parser.parse_args()
    plan = json.loads(args.plan.read_text(encoding="utf-8"))
    assert plan["contract"] == "ccc4.operator-plan.v2"
    identity = digest(canonical_bytes(plan))
    print(f"canonical_plan_sha256={identity}")
    if not any((args.candidate, args.chen, args.chen_sha256)):
        return
    if not all((args.candidate, args.chen, args.chen_sha256)):
        parser.error("comparison requires --candidate, --chen, and --chen-sha256")
    actual_digest = digest(args.chen.read_bytes())
    if actual_digest != args.chen_sha256.lower():
        raise ValueError(f"Ch'en reference digest mismatch: {actual_digest}")
    shape = (plan["groups"], plan["dimension"])
    candidate = np.fromfile(args.candidate, dtype="<f4")
    reference = np.load(args.chen, allow_pickle=False)
    if candidate.size != shape[0] * shape[1] or reference.shape != shape or reference.dtype != np.float32:
        raise ValueError("candidate or Ch'en reference shape/dtype mismatch")
    candidate = candidate.reshape(shape)
    if not np.isfinite(candidate).all() or not np.isfinite(reference).all():
        raise ValueError("nonfinite candidate or Ch'en reference")
    np.testing.assert_array_equal(candidate, reference)
    print(f"chen_reference_match=exact reference_sha256={actual_digest}")


if __name__ == "__main__":
    main()
