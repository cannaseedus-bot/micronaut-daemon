"""Focused stage-1 CCC4 loader checks using temporary GML fixtures."""
import pathlib
import re
import subprocess
import tempfile

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXE = ROOT / "build/gml-stage1/Release/gml.exe"
BASE = (ROOT / "build/ccc4-neuron.gml").read_text(encoding="utf-8")


def run(name, source, expected_ok, baseline_hash=None, distinct_contract=None, same_contract=None):
    with tempfile.TemporaryDirectory() as directory:
        path = pathlib.Path(directory) / f"{name}.gml"
        path.write_text(source, encoding="utf-8")
        result = subprocess.run([str(EXE), str(path)], capture_output=True, text=True)
    assert (result.returncode == 0) == expected_ok, (name, result.stdout, result.stderr)
    if baseline_hash:
        match = re.search(r"topology_hash=([0-9a-f]{64})", result.stdout)
        assert match and match.group(1) == baseline_hash, name
    if distinct_contract:
        contract = re.search(r"contract_hash=([0-9a-f]{64})", result.stdout)
        assert contract and contract.group(1) != distinct_contract, name
    if same_contract:
        contract = re.search(r"contract_hash=([0-9a-f]{64})", result.stdout)
        assert contract and contract.group(1) == same_contract, name
    print(f"{name}: {'accepted' if expected_ok else 'rejected'}")
    return re.search(r"topology_hash=([0-9a-f]{64})", result.stdout)


baseline = run("baseline", BASE, True).group(1)
base_contract = re.search(r"contract_hash=([0-9a-f]{64})", subprocess.run(
    [str(EXE), str(ROOT / "build/ccc4-neuron.gml")], capture_output=True, text=True
).stdout).group(1)
run("presentation", BASE.replace('label "0000:0"', 'label "renamed"', 1).replace('x -1.22', 'x 99.0', 1), True, baseline, same_contract=base_contract)
run("declaration_change", BASE.replace('operator "neuron.activation"', 'operator "neuron.alternative"', 1), True, baseline, base_contract)
run("wrong_schema", BASE.replace('schema "ccc4.neuron.v1"', 'schema "wrong"', 1), False)
run("nested_payload", BASE.replace('bias_ref "runtime.neuron.biases[node_id]"', 'bias_ref "runtime.neuron.biases[node_id]" weight 0.37', 1), False)
run("nested_list", BASE.replace('bias_ref "runtime.neuron.biases[node_id]"', 'bias_ref [ value 0.37 ]', 1), False)
run("wrong_xor_label", BASE.replace('label "xor:bit0"', 'label "xor:bit1"', 1), False)
run("duplicate_pair", BASE.replace('edge [ source 0  target 4 ', 'edge [ source 0  target 1 ', 1), False)
run("trailing_tokens", BASE + "\nextra\n", False)
