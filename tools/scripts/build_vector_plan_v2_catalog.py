"""Build fixed v2 admission plans and their byte-pinned catalog."""
import copy
import hashlib
import json
from pathlib import Path

from verify_vector_plan_v2 import canonical_bytes

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / "build/ccc4-operator-plan.v2.admitted.json"
OUT = ROOT / "build/ccc4-v2-admission"


def main():
    base = json.loads(BASE.read_text(encoding="utf-8"))
    variants = {
        "filter_all": ([{"kind": "FILTER", "policy": "all"}], [], "mean", "reject"),
        "filter_row_range": ([{"kind": "FILTER", "policy": "row_range", "start": 0, "stop": 64}], [], "mean", "reject"),
        "filter_row_mod_eq": ([{"kind": "FILTER", "policy": "row_mod_eq", "modulus": 2, "remainder": 0}], [], "mean", "zero"),
        "filter_norm_min": ([{"kind": "FILTER", "policy": "norm_min", "threshold": 1.0}], [], "mean", "zero"),
        "map_scale": ([], [{"kind": "MAP", "policy": "scale", "factor": -0.5}], "mean", "reject"),
        "map_l2_normalize": ([], [{"kind": "MAP", "policy": "l2_normalize"}], "mean", "reject"),
        "fold_mean": ([], [], "mean", "reject"),
        "fold_sum": ([], [], "sum", "reject"),
        "fold_min": ([], [], "min", "reject"),
        "fold_max": ([], [], "max", "reject"),
        "empty_zero": ([{"kind": "FILTER", "policy": "row_range", "start": 0, "stop": 1}], [], "mean", "zero"),
    }
    OUT.mkdir(exist_ok=True)
    catalog = {}
    for name, (filters, maps, fold, empty) in variants.items():
        plan = copy.deepcopy(base)
        source = next(op for op in plan["operators"] if op["kind"] == "SOURCE")
        assign = next(op for op in plan["operators"] if op["id"] == "assign")
        fold_op = next(op for op in plan["operators"] if op["kind"] == "FOLD")
        accumulate = next(op for op in plan["operators"] if op["kind"] == "ACCUMULATE")
        reduce = next(op for op in plan["operators"] if op["kind"] == "REDUCE")
        fold_op["policy"], fold_op["empty_group_policy"] = fold, empty
        transforms = [{"id": f"filter{i}", **op} for i, op in enumerate(filters)]
        transforms += [{"id": f"map{i}", **op} for i, op in enumerate(maps)]
        chain = [source, *transforms, assign, fold_op, reduce]
        plan["operators"] = [*chain[:-1], accumulate, reduce]
        plan["data_flow"] = [{"source": a["id"], "target": b["id"]} for a, b in zip(chain, chain[1:])]
        plan["execution_dependencies"] = [{"before": e["source"], "after": e["target"]}
                                          for e in plan["data_flow"]]
        raw = (json.dumps(plan, indent=2, ensure_ascii=False) + "\n").encode("utf-8")
        (OUT / f"{name}.json").write_bytes(raw)
        catalog[name] = {"file_sha256": hashlib.sha256(raw).hexdigest(),
                         "plan_sha256": hashlib.sha256(canonical_bytes(plan)).hexdigest()}
    (OUT / "catalog.json").write_text(json.dumps(catalog, indent=2) + "\n", encoding="utf-8")
    print(f"wrote {len(catalog)} plans")


if __name__ == "__main__":
    main()
