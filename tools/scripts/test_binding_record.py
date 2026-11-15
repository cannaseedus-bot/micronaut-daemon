"""Reject tampered binding records without touching the source artifacts."""
import copy
import json
import pathlib
import subprocess
import sys
import tempfile

root = pathlib.Path(__file__).resolve().parents[1]
record = json.loads((root / "build/ccc4-vector-binding.candidate.json").read_text(encoding="utf-8"))


def rejected(name, change):
    candidate = copy.deepcopy(record)
    change(candidate)
    with tempfile.TemporaryDirectory() as directory:
        path = pathlib.Path(directory) / "record.json"
        path.write_text(json.dumps(candidate), encoding="utf-8")
        result = subprocess.run([sys.executable, str(root / "checker.py"), str(path)], capture_output=True, text=True)
    assert result.returncode != 0, name
    print(name, "rejected")


rejected("execution_grant", lambda r: r.update(execution_authorized=True))
rejected("materialized", lambda r: r.update(materialized=True))
rejected("artifact_digest", lambda r: r["artifacts"]["pattern_vectors.f32.npy"].update(sha256="0" * 64))
rejected("operator_plan_hash", lambda r: r.update(operator_plan_hash="0" * 64))
rejected("selected_artifact", lambda r: r["selected_artifact"].update(filename="template_vectors.f32.npy"))
rejected("kernel_digest", lambda r: r["kernel"].update(sha256="0" * 64))
