import json
import os
import subprocess
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
fixture_exe = ROOT / "build/gml-stage1/Release/test_gemma_bridge_route.exe"
bridge = json.loads(subprocess.check_output([str(fixture_exe), "--fixture"],
                                           text=True, encoding="utf-8", cwd=ROOT))
exe = ROOT / "build/gml-stage1/Release/eliza-µ.exe"
env = dict(os.environ, MICRONAUT_GEMMA_BRIDGE="1",
           MICRONAUT_GEMMA_ATTEST_KEY="test-only-host-attestation-key-32-bytes")
encoded = json.loads(subprocess.check_output(
    ["python", "tools/attest_gemma_query.py", "WHO CREATED AIML"],
    text=True, encoding="utf-8", cwd=ROOT, env=env))
encoded["utterance"] = "WHO CREATED AIML"
encoded_bridge = json.loads(subprocess.check_output(
    [str(fixture_exe), "--fixture-from-stdin"], input=json.dumps(encoded),
    text=True, encoding="utf-8", cwd=ROOT))
tampered_bridge = json.loads(json.dumps(encoded_bridge))
tampered_bridge["query_vector"][0] += 0.01
requests = [
    {"id": "proposal", "op": "gemma.bridge.propose", "bridge": bridge},
    {"id": "chat", "op": "chat.generate", "prompt": "WHO CREATED AIML", "bridge": bridge},
    {"id": "vector-extended", "op": "chat.generate", "prompt": "WHO CREATED AIML",
     "response_mode": "vector_extended_v1", "bridge": bridge},
    {"id": "attested", "op": "gemma.bridge.propose", "bridge": encoded_bridge},
    {"id": "attested-chat", "op": "chat.generate", "prompt": "WHO CREATED AIML",
     "bridge": encoded_bridge},
    {"id": "tampered", "op": "gemma.bridge.propose", "bridge": tampered_bridge},
]
run = subprocess.run([str(exe)], input="\n".join(map(json.dumps, requests)) + "\n",
                     text=True, capture_output=True, encoding="utf-8", cwd=ROOT, env=env, check=True)
results = [item for line in run.stdout.splitlines() if line
           if (item := json.loads(line)).get("@kind") == "micronaut.result.v1"]
assert len(results) == 6, run.stdout
assert results[0]["ok"] and results[0]["result"]["selection"] == "verified_plain_template", results[0]
assert "text" not in results[0]["result"], results[0]
assert results[1]["ok"] and results[1]["result"]["text"] == "Dr. Richard S. Wallace created AIML.", results[1]
assert results[1]["result"]["bridge"]["row_id"] == 2, results[1]
assert results[2]["ok"] and results[2]["result"]["bridge"]["selection"] == "verified_vector_response", results[2]
assert results[2]["result"]["bridge"]["vector_response"]["key"] == "⟁AIML_ROW_2", results[2]
assert "Verified AIML pattern: WHO CREATED AIML" in results[2]["result"]["text"], results[2]
assert results[3]["ok"] and results[3]["result"]["attestation_verified"] is True, results[3]
assert results[3]["result"]["retrieval_verified"] is True, results[3]
assert results[4]["ok"] and results[4]["result"]["bridge"]["attestation_verified"] is True, results[4]
assert not results[5]["ok"] and results[5]["error"]["code"] == "GEMMA_BRIDGE_REJECTED", results[5]
print("Gemma bridge daemon proposal, chat, and VECTOR-µ response passed")
