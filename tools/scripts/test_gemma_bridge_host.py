"""Exercise the .env-backed host launcher without exposing its key."""
import json
import os
import subprocess
import tempfile
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
LAUNCHER = ROOT / "tools/gemma_bridge_host.ps1"
FIXTURE = ROOT / "build/gml-stage1/Release/test_gemma_bridge_route.exe"
PWSH = r"C:\Program Files\PowerShell\7\pwsh.exe"
child_env = os.environ.copy()
child_env.pop("MICRONAUT_GEMMA_ATTEST_KEY", None)
child_env.pop("MICRONAUT_GEMMA_BRIDGE", None)

encoded_run = subprocess.run(
    [PWSH, "-NoProfile", "-File", str(LAUNCHER), "-Mode", "Attest",
     "-Utterance", "WHO CREATED AIML"],
    text=True, capture_output=True, encoding="utf-8", cwd=ROOT, env=child_env, check=True)
encoded = json.loads(encoded_run.stdout)
encoded["utterance"] = "WHO CREATED AIML"
bridge = json.loads(subprocess.check_output(
    [str(FIXTURE), "--fixture-from-stdin"], input=json.dumps(encoded),
    text=True, encoding="utf-8", cwd=ROOT))
tampered = json.loads(json.dumps(bridge))
tampered["query_vector"][0] += 0.01
requests = [
    {"id": "valid", "op": "gemma.bridge.propose", "bridge": bridge},
    {"id": "tampered", "op": "gemma.bridge.propose", "bridge": tampered},
]
with tempfile.NamedTemporaryFile("w", suffix=".jsonl", dir=ROOT / "build",
                                 encoding="utf-8", delete=False) as stream:
    request_path = Path(stream.name)
    for request in requests:
        stream.write(json.dumps(request) + "\n")
try:
    daemon_run = subprocess.run(
        [PWSH, "-NoProfile", "-File", str(LAUNCHER), "-Mode", "Daemon",
         "-RequestFile", str(request_path)],
        text=True, capture_output=True, encoding="utf-8", cwd=ROOT, env=child_env, check=True)
finally:
    request_path.unlink(missing_ok=True)
results = [item for line in daemon_run.stdout.splitlines() if line
           if (item := json.loads(line)).get("@kind") == "micronaut.result.v1"]
assert len(results) == 2, daemon_run.stdout
assert results[0]["ok"] and results[0]["result"]["attestation_verified"] is True, results[0]
assert results[0]["result"]["retrieval_verified"] is True, results[0]
assert results[1]["ok"] is False and results[1]["error"]["code"] == "GEMMA_BRIDGE_REJECTED", results[1]
print("Gemma bridge .env host launch passed")
