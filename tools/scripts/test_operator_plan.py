"""Positive and adversarial checks for the proposed operator-plan encoding."""
import copy
import hashlib
import json
import pathlib

from encode_operator_plan import encode

path = pathlib.Path(__file__).resolve().parents[1] / "build/ccc4-operator-plan.v1.json"
base = json.loads(path.read_text(encoding="utf-8"))
baseline = encode(base)
assert len(baseline) == 1239
assert hashlib.sha256(baseline).hexdigest() == "48e1ab4390e7e83ae452861b89f79696c2aa3b963b1429a24cc8dc7417ecd315"

reordered = copy.deepcopy(base)
for key in ("operators", "containment", "data_flow", "execution_dependencies"):
    reordered[key].reverse()
assert encode(reordered) == baseline

renamed = copy.deepcopy(base)
renamed["plan_id"] = "display-only-name"
assert encode(renamed) == baseline


def rejects(name, modify):
    plan = copy.deepcopy(base)
    modify(plan)
    try:
        encode(plan)
    except (AssertionError, KeyError, StopIteration, ValueError):
        print(name, "rejected")
        return
    raise AssertionError(name + " was accepted")


rejects("missing_accumulate", lambda p: p["containment"].clear())
rejects("flow_type_mismatch", lambda p: p["operators"][0]["outputs"][0].update(dtype="u32"))
rejects("unconnected_input", lambda p: p["data_flow"].pop())
rejects("execution_cycle", lambda p: p["execution_dependencies"].append({"before": "reduce.mean", "after": "fold.groups"}))
rejects("materialized_state", lambda p: p["declared"].update(materialized=True))
rejects("wrong_partition", lambda p: p["partition"].update(modulus=63))
print("canonical bytes", len(baseline), hashlib.sha256(baseline).hexdigest())
