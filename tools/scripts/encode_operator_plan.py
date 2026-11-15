"""Validate and canonically encode a CCC4 operator plan. No vector payload reads."""
import hashlib
import json
import pathlib
import struct
import sys

KINDS = {"SOURCE": 0, "FILTER": 1, "MAP": 2, "FOLD": 3, "ACCUMULATE": 4, "REDUCE": 5}
DTYPES = {"f32": 0, "f64": 1, "u32": 2}
COMBINE = {"mean": 0}
ORDER = {"sequential_row_index_ascending": 0}
EMPTY = {"reject": 0, "zero": 1}
AXIS = {"grouped_rows": 0}


def u8(x):
    return struct.pack("<B", x)


def u32(x):
    return struct.pack("<I", x)


def string(x):
    b = x.encode("utf-8")
    return u32(len(b)) + b


def shape(x):
    return u32(len(x)) + b"".join(u32(v) for v in x)


def validate(plan):
    def require(condition, message):
        if not condition:
            raise ValueError(message)

    require(plan.get("contract") == "ccc4.operator-plan.v1", "unknown plan contract")
    declared, part = plan["declared"], plan["partition"]
    source_shape, target_shape = declared["source_shape"], declared["target_shape"]
    require(declared["materialized"] is False, "Stage-2 plan is materialized")
    require(len(source_shape) == len(target_shape) == 2 and
            all(type(x) is int and 0 < x < 0xffffffff for x in source_shape + target_shape),
            "source/target shapes must be positive rank-2 dimensions")
    rows, dim = source_shape
    require(target_shape == [64, dim], "CCC4 target must be [64,D]")
    require(part == {"rule": "row_index_mod", "modulus": 64, "rows": rows, "groups": 64},
            "unsupported partition or partition/shape mismatch")
    require(rows >= 64, "reject-empty policy requires at least 64 rows")
    operators = plan["operators"]
    require(len(operators) == 6, "v1 requires one operator of each kind")
    ops = {o["id"]: o for o in operators}
    require(len(ops) == len(operators) and all(isinstance(x, str) and x for x in ops),
            "duplicate or empty operator id")
    by_kind = {o["kind"]: o for o in operators}
    require(set(by_kind) == set(KINDS) and len(by_kind) == 6,
            "v1 requires SOURCE/FILTER/MAP/FOLD/ACCUMULATE/REDUCE")
    source, filt, mapper, fold, accum, reduce = (by_kind[k] for k in KINDS)
    sid, fid, mid, gid, aid, rid = (o["id"] for o in (source, filt, mapper, fold, accum, reduce))
    k = 0xffffffff
    expected_ports = {
        "SOURCE": ([], [("out", "f32", [rows, dim])]),
        "FILTER": ([("in", "f32", [rows, dim])], [("out", "f32", [k, dim])]),
        "MAP": ([("in", "f32", [k, dim])], [("node_ids", "u32", [k]), ("vectors", "f32", [k, dim])]),
        "FOLD": ([("node_ids", "u32", [k]), ("vectors", "f32", [k, dim])],
                 [("counts", "u32", [64]), ("sums", "f64", [64, dim])]),
        "ACCUMULATE": ([], []),
        "REDUCE": ([("counts", "u32", [64]), ("sums", "f64", [64, dim])],
                   [("out", "f32", [64, dim])]),
    }
    for op in operators:
        for key, expected in zip(("inputs", "outputs"), expected_ports[op["kind"]]):
            got = [(p["name"], p["dtype"], p["shape"]) for p in op[key]]
            require(sorted(got) == sorted(expected), f"{op['id']} {key} mismatch")
    require(source["params"]["artifact_ref"], "SOURCE needs artifact_ref")
    require(filt["params"] == {"predicate_ref": "row_index_in_range", "predicate_kind": 0},
            "unsupported FILTER predicate")
    require(mapper["params"] == {"map_ref": "row_index_mod64", "output_dtype": "u32"},
            "unsupported MAP binding")
    require(fold["params"] == {"group_by": "node_id", "combine": "mean", "precision": "f64",
            "accumulation_order": "sequential_row_index_ascending", "order_sensitive": True,
            "empty_group_policy": "reject", "accumulator_init_ref": "zero_sums_and_counts"},
            "unsupported FOLD semantics")
    require(accum["params"] == {"update_ref": "sum_count_step_f64", "accumulator_shape": [64, dim]},
            "unsupported ACCUMULATE semantics")
    require(reduce["params"] == {"axis": "grouped_rows", "output_dtype": "f32",
            "output_shape": [64, dim]}, "unsupported REDUCE semantics")
    require(plan["containment"] == [{"parent": gid, "child": aid, "role": "owns_accumulator"}],
            "ACCUMULATE must be owned by FOLD only")
    expected_flow = {(sid, "out", fid, "in"), (fid, "out", mid, "in"),
                     (mid, "node_ids", gid, "node_ids"), (mid, "vectors", gid, "vectors"),
                     (gid, "counts", rid, "counts"), (gid, "sums", rid, "sums")}
    flow = {(x["source"], x["output"], x["target"], x["input"]) for x in plan["data_flow"]}
    require(len(flow) == len(plan["data_flow"]) and flow == expected_flow,
            "data-flow ports or completeness mismatch")
    expected_deps = {(sid, fid), (fid, mid), (mid, gid), (gid, rid)}
    deps = {(x["before"], x["after"]) for x in plan["execution_dependencies"]}
    require(len(deps) == len(plan["execution_dependencies"]) and deps == expected_deps,
            "execution dependencies must follow data flow")


def encode(plan):
    validate(plan)
    b = bytearray(b"ccc4.operator-plan.v1\0")
    ops = sorted(plan["operators"], key=lambda x: x["id"].encode())
    b += u32(len(ops))
    for op in ops:
        kind, p = op["kind"], op["params"]
        b += string(op["id"]) + u32(KINDS[kind])
        for key in ("inputs", "outputs"):
            ports = sorted(op[key], key=lambda x: x["name"].encode())
            b += u32(len(ports))
            for port in ports:
                b += string(port["name"]) + u32(DTYPES[port["dtype"]]) + shape(port["shape"])
        if kind == "SOURCE": b += string(p["artifact_ref"])
        elif kind == "FILTER": b += string(p["predicate_ref"]) + u8(p["predicate_kind"])
        elif kind == "MAP": b += string(p["map_ref"]) + u32(DTYPES[p["output_dtype"]])
        elif kind == "FOLD":
            b += string(p["group_by"]) + u32(COMBINE[p["combine"]]) + u32(DTYPES[p["precision"]])
            b += u32(ORDER[p["accumulation_order"]]) + u8(int(p["order_sensitive"])) + u32(EMPTY[p["empty_group_policy"]]) + string(p["accumulator_init_ref"])
        elif kind == "ACCUMULATE": b += string(p["update_ref"]) + shape(p["accumulator_shape"])
        elif kind == "REDUCE": b += u32(AXIS[p["axis"]]) + u32(DTYPES[p["output_dtype"]]) + shape(p["output_shape"])
    for key, fields in (("containment", ("parent", "child", "role")), ("data_flow", ("source", "output", "target", "input")), ("execution_dependencies", ("before", "after"))):
        records = sorted(plan[key], key=lambda x: tuple(x[f].encode() for f in fields))
        b += u32(len(records))
        for record in records:
            for field in fields: b += string(record[field])
    part = plan["partition"]
    b += string(part["rule"]) + u32(part["modulus"]) + u32(part["rows"]) + u32(part["groups"])
    d = plan["declared"]
    b += shape(d["source_shape"]) + shape(d["target_shape"]) + u8(int(d["materialized"]))
    return bytes(b)


if __name__ == "__main__":
    path = pathlib.Path(sys.argv[1]) if len(sys.argv) > 1 else pathlib.Path(__file__).resolve().parents[1] / "build/ccc4-operator-plan.v1.json"
    result = encode(json.loads(path.read_text(encoding="utf-8")))
    print(len(result), hashlib.sha256(result).hexdigest())
    if len(sys.argv) > 2: pathlib.Path(sys.argv[2]).write_bytes(result)
