"""Independent NumPy oracle for built-in CCC4 v2 vector policies."""
import copy
import json
import os
from pathlib import Path
import subprocess
import tempfile

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
CLI = ROOT / "build/gml-stage1/Release/vector_plan_cli.exe"
BASE = json.loads((ROOT / "build/ccc4-operator-plan.v2.example.json").read_text())


def reference(plan, source):
    if not np.isfinite(source).all():
        raise ValueError("source contains non-finite value")
    rows = np.arange(len(source))
    values = source.copy()
    nodes = None
    ops = {op["id"]: op for op in plan["operators"]}
    current = next(op["id"] for op in plan["operators"] if op["kind"] == "SOURCE")
    links = {edge["source"]: edge["target"] for edge in plan["data_flow"]}
    while current in links:
        current = links[current]
        op = ops[current]
        policy = op["policy"]
        if op["kind"] == "FILTER":
            if policy == "all":
                mask = np.ones(len(rows), dtype=bool)
            elif policy == "row_range":
                mask = (rows >= op["start"]) & (rows < op["stop"])
            elif policy == "row_mod_eq":
                mask = rows % op["modulus"] == op["remainder"]
            else:
                mask = np.linalg.norm(values.astype(np.float64), axis=1) >= op["threshold"]
            rows, values = rows[mask], values[mask]
            if nodes is not None:
                nodes = nodes[mask]
        elif op["kind"] == "MAP":
            if policy == "row_index_mod":
                nodes = rows % plan["groups"]
            elif policy == "scale":
                scaled = values.astype(np.float64) * op["factor"]
                if not np.isfinite(scaled).all() or np.any(np.abs(scaled) > np.finfo(np.float32).max):
                    raise ValueError("MAP scale overflow")
                values = scaled.astype(np.float32)
            else:
                norms = np.linalg.norm(values.astype(np.float64), axis=1)
                values = np.array([v if n == 0 else (v.astype(np.float64) / n).astype(np.float32)
                                   for v, n in zip(values, norms)], dtype=np.float32).reshape(values.shape)
        elif op["kind"] == "FOLD":
            if nodes is None:
                raise ValueError("FOLD needs a MAP node assignment")
            counts = np.zeros(plan["groups"], dtype=np.int64)
            result = np.zeros((plan["groups"], source.shape[1]), dtype=np.float64)
            for node, row in zip(nodes, values):
                x = row.astype(np.float64)
                if policy in ("mean", "sum"):
                    result[node] += x
                elif policy == "min":
                    result[node] = np.minimum(result[node], x) if counts[node] else x
                else:
                    result[node] = np.maximum(result[node], x) if counts[node] else x
                counts[node] += 1
            if op["empty_group_policy"] == "reject" and np.any(counts == 0):
                raise ValueError("REDUCE encountered an empty group")
            if policy == "mean":
                np.divide(result, counts[:, None], out=result, where=counts[:, None] != 0)
            if not np.isfinite(result).all() or np.any(np.abs(result) > np.finfo(np.float32).max):
                raise ValueError("REDUCE produced non-finite float32 output")
            return result.astype(np.float32)
    raise ValueError("missing FOLD")


def case(name, source, filters, maps, fold="mean", empty="reject"):
    plan = copy.deepcopy(BASE)
    plan["source_rows"], plan["dimension"], plan["groups"] = source.shape[0], source.shape[1], 64
    operators = [dict(id="source", kind="SOURCE", policy="artifact", artifact_ref="test.rows")]
    operators += [dict(id=f"filter{i}", kind="FILTER", **spec) for i, spec in enumerate(filters)]
    operators += [dict(id=f"map{i}", kind="MAP", **spec) for i, spec in enumerate(maps)]
    operators += [dict(id="fold", kind="FOLD", policy=fold, precision="f64",
                      order="sequential_row_index_ascending", empty_group_policy=empty),
                  dict(id="accumulate", kind="ACCUMULATE", policy="f64_sequential"),
                  dict(id="reduce", kind="REDUCE", policy="to_f32")]
    chain = [op["id"] for op in operators if op["kind"] != "ACCUMULATE"]
    plan["operators"] = operators
    plan["data_flow"] = [dict(source=a, target=b) for a, b in zip(chain, chain[1:])]
    plan["execution_dependencies"] = [dict(before=a, after=b) for a, b in zip(chain, chain[1:])]
    with tempfile.TemporaryDirectory() as folder:
        folder = Path(folder)
        plan_path, input_path, output_path = folder / "plan.json", folder / "input.npy", folder / "candidate.bin"
        plan_path.write_text(json.dumps(plan))
        np.save(input_path, source)
        try:
            expected = reference(plan, source)
            error = None
        except ValueError as exc:
            expected, error = None, str(exc)
        proc = subprocess.run([str(CLI), str(plan_path), str(input_path), "--execute", str(output_path)],
                              env={**os.environ, "MICRONAUT_VECTOR_PLAN_V2": "1"},
                              capture_output=True, text=True)
        if error:
            assert proc.returncode != 0 and error in proc.stderr, (name, error, proc.stderr)
            assert not output_path.exists(), name
        else:
            assert proc.returncode == 0, (name, proc.stderr)
            actual = np.fromfile(output_path, dtype="<f4").reshape(expected.shape)
            np.testing.assert_array_equal(actual, expected, err_msg=name)
        print(f"{name}: passed")


def main():
    seed = np.array([[1, 2], [3, -4], [0, 0], [-2, 5], [7, 8], [9, -1], [2, 3]], dtype="<f4")
    source = np.tile(seed, (10, 1))[:65].copy()
    assign = [dict(policy="row_index_mod", modulus=64)]
    for fold in ("mean", "sum", "min", "max"):
        case(f"fold_{fold}", source, [dict(policy="all")], assign, fold)
    for name, spec in (("row_range", dict(policy="row_range", start=1, stop=7)),
                       ("row_mod_eq", dict(policy="row_mod_eq", modulus=2, remainder=0)),
                       ("norm_min", dict(policy="norm_min", threshold=2.0))):
        case(name, source, [spec], assign, empty="zero")
    case("scale", source, [dict(policy="all")], [dict(policy="scale", factor=-0.5)] + assign)
    case("l2_normalize", source, [dict(policy="all")], [dict(policy="l2_normalize")] + assign)
    case("empty_zero", source, [dict(policy="row_range", start=0, stop=1)], assign, empty="zero")
    case("empty_reject", source, [dict(policy="row_range", start=0, stop=1)], assign)
    for value in (np.nan, np.inf, -np.inf):
        invalid = source.copy()
        invalid[0, 0] = value
        case(f"nonfinite_{value}", invalid, [dict(policy="all")], assign)
    case("scale_overflow", source, [dict(policy="all")], [dict(policy="scale", factor=1e40)] + assign)


if __name__ == "__main__":
    main()
