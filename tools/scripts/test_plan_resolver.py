import copy
import json
import pathlib
import sys
import tempfile

import numpy as np

ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from plan_resolver import resolve  # noqa: E402


def main():
    base = json.loads((ROOT / "build/ccc4-operator-plan.v1.json").read_text(encoding="utf-8"))
    with tempfile.TemporaryDirectory() as folder:
        folder = pathlib.Path(folder)
        plan = copy.deepcopy(base)
        plan["plan_id"] = "small-shape"
        plan["partition"]["rows"] = 65
        plan["declared"]["source_shape"] = [65, 3]
        plan["declared"]["target_shape"] = [64, 3]
        for op in plan["operators"]:
            for port in op["inputs"] + op["outputs"]:
                port["shape"] = [65 if x == 99524 else 3 if x == 256 else x for x in port["shape"]]
            if op["kind"] == "ACCUMULATE":
                op["params"]["accumulator_shape"] = [64, 3]
            if op["kind"] == "REDUCE":
                op["params"]["output_shape"] = [64, 3]
        path, array = folder / "plan.json", folder / "pattern_vectors.f32.npy"
        path.write_text(json.dumps(plan), encoding="utf-8")
        np.save(array, np.ones((65, 3), dtype="<f4"))
        result = resolve(path, array)
        assert result["source_shape"] == [65, 3]
        assert result["partition_counts"] == [2] + [1] * 63
        assert result["materialized"] is False
        plan["operators"].reverse()
        path.write_text(json.dumps(plan), encoding="utf-8")
        assert resolve(path, array)["operator_plan_hash"] == result["operator_plan_hash"]
        next(op for op in plan["operators"] if op["kind"] == "SOURCE")["params"]["artifact_ref"] = "EmbeddingGemma2.template_vectors"
        path.write_text(json.dumps(plan), encoding="utf-8")
        alternate = folder / "template_vectors.f32.npy"
        np.save(alternate, np.ones((65, 3), dtype="<f4"))
        assert resolve(path, alternate)["operator_plan_hash"] != result["operator_plan_hash"]
        plan["containment"] = []
        path.write_text(json.dumps(plan), encoding="utf-8")
        try:
            resolve(path, alternate)
        except ValueError:
            pass
        else:
            raise AssertionError("uncontained ACCUMULATE accepted")
        plan["containment"] = base["containment"]
        path.write_text(json.dumps(plan), encoding="utf-8")
        np.save(alternate, np.ones((64, 3), dtype="<f4"))
        try:
            resolve(path, alternate)
        except ValueError:
            pass
        else:
            raise AssertionError("source shape mismatch accepted")
    print("plan resolver: alternate shape, canonical order, containment and header checks passed")


if __name__ == "__main__":
    main()
