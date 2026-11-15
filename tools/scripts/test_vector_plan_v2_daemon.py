"""Integration checks for the host-pinned v2 vector daemon admission route."""
import json
import os
from pathlib import Path
import subprocess

ROOT = Path(__file__).resolve().parents[1]
DAEMON = ROOT / "build/gml-stage1/Release/eliza-µ.exe"
CATALOG = json.loads((ROOT / "build/ccc4-v2-admission/catalog.json").read_text(encoding="utf-8"))


def request(payload, enabled):
    env = os.environ.copy()
    env.pop("MICRONAUT_VECTOR_PLAN_V2_DAEMON", None)
    if enabled:
        env["MICRONAUT_VECTOR_PLAN_V2_DAEMON"] = "1"
    run = subprocess.run([str(DAEMON)], input=json.dumps(payload) + "\n", text=True,
                         capture_output=True, env=env, check=True)
    results = [json.loads(line) for line in run.stdout.splitlines()
               if json.loads(line).get("@kind") == "micronaut.result.v1"]
    assert len(results) == 1, run.stdout
    return results[0]


def main():
    base = {"op": "vector.plan.v2.candidate", "id": "v2-admission-test"}
    denied = request(base, False)
    assert not denied["ok"] and denied["error"]["code"] == "XCFE_ADMISSION_DENIED"
    for extra in ({"source": "other.npy"}, {"plan": "other.json"}, {"host_authorized": True}):
        rejected = request({**base, **extra}, True)
        assert not rejected["ok"] and rejected["error"]["code"] == "XCFE_ADMISSION_DENIED"
    unknown = request({**base, "plan_id": "unknown"}, True)
    assert not unknown["ok"] and unknown["error"]["code"] == "XCFE_ADMISSION_DENIED"
    for name, record in CATALOG.items():
        accepted = request({**base, "plan_id": name}, True)
        assert accepted["ok"], accepted
        result = accepted["result"]
        assert result["verified"] is True and result["committed"] is False
        assert result["shape"] == [64, 256] and len(result["first_values"]) == 4
        assert result["plan_id"] == name and result["operator_plan_hash"] == record["plan_sha256"]
        print(f"{name}: daemon Ch'en admission passed")
    print("v2 daemon admission: gate, request fields, and all catalog plans passed")


if __name__ == "__main__":
    main()
