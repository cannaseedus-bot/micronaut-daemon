"""Independent read-only check of a CCC4 vector binding candidate record."""
import argparse
import ast
import hashlib
import json
import pathlib
import re
import struct
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent
VECTOR_DIR = ROOT / "build/io/aiml-embeddinggemma2-vectors"
NAMES = ("pattern_vectors.f32.npy", "template_vectors.f32.npy", "category_vectors.f32.npy")
EXPECTED_TOPOLOGY = "af51f5244ce5ea7fdb352d9fae31ddf511aaca86f442515e81471df5726b1116"
EXPECTED_CONTRACT = "94c9a48fba859b751acfb844fff046f59d6de6b419706614e7daa7fff97b22d6"
EXPECTED_PLAN = "48e1ab4390e7e83ae452861b89f79696c2aa3b963b1429a24cc8dc7417ecd315"


def require(condition, message):
    if not condition:
        raise ValueError(message)


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def npy_header(path):
    with path.open("rb") as stream:
        version = stream.read(8)
        require(len(version) == 8 and version[:6] == b"\x93NUMPY", "bad NPY magic")
        require(version[6] in (1, 2, 3), "unsupported NPY version")
        size_width = 2 if version[6] == 1 else 4
        raw_length = stream.read(size_width)
        require(len(raw_length) == size_width, "truncated NPY length")
        length = int.from_bytes(raw_length, "little")
        require(16 <= length <= 65536, "bad NPY header length")
        header = stream.read(length)
        require(len(header) == length, "truncated NPY header")
        fields = ast.literal_eval(header.decode("latin1" if version[6] < 3 else "utf-8"))
        require(isinstance(fields, dict), "NPY header is not a dictionary")
        require(fields.get("descr") in ("<f4", "=f4"), "NPY dtype mismatch")
        require(fields.get("fortran_order") is False, "NPY memory order mismatch")
        require(fields.get("shape") == (99524, 256), "NPY shape mismatch")
        require(path.stat().st_size - stream.tell() == 99524 * 256 * 4, "NPY payload length mismatch")
    return [99524, 256]


def check(record):
    require(record.get("schema") == "ccc4.vector-binding.candidate.v1", "record schema mismatch")
    require(record.get("status") == "BINDINGS_VALIDATED_CANDIDATE", "record status mismatch")
    for key in ("materialized", "execution_authorized", "persistence_authorized"):
        require(record.get(key) is False, f"{key} must be false")
    require(record.get("declared_source_shape") == [99524, 256], "source shape mismatch")
    require(record.get("declared_target_shape") == [64, 256], "target shape mismatch")
    require(record.get("partition_counts") == [1556] * 4 + [1555] * 60, "partition counts mismatch")
    require(record.get("topology_hash") == EXPECTED_TOPOLOGY, "topology hash mismatch")
    require(record.get("contract_hash") == EXPECTED_CONTRACT, "contract hash mismatch")
    require(record.get("operator_plan_hash") == EXPECTED_PLAN, "operator plan hash mismatch")
    require(record.get("plan_document_sha256") == sha256(ROOT / "build/ccc4-operator-plan.v1.json"), "plan document digest mismatch")

    manifest = json.loads((VECTOR_DIR / "manifest.json").read_text(encoding="utf-8"))
    require(record.get("manifest_sha256") == sha256(VECTOR_DIR / "manifest.json"), "manifest digest mismatch")
    require(manifest.get("schema") == "micronaut.aiml.embeddinggemma-vectors.v1", "manifest schema mismatch")
    require(manifest.get("authority") == "data_only" and manifest.get("semanticCommit") is False, "manifest authority mismatch")
    require(manifest.get("vector_files") == {
        "A_pattern_context": NAMES[0], "B_template": NAMES[1],
        "category_midpoint": NAMES[2], "pair_records": "aiml_pattern_template_pairs.jsonl",
    }, "manifest artifact roles mismatch")
    source = ROOT / "build/io/aiml-corpus.jsonl"
    require(record.get("source_sha256") == manifest.get("source_sha256") == sha256(source), "AIML source digest mismatch")
    require(set(record.get("artifacts", {})) == set(NAMES), "artifact set mismatch")
    for name in NAMES:
        path = VECTOR_DIR / name
        require(npy_header(path) == record["artifacts"][name].get("shape"), f"shape mismatch: {name}")
        require(record["artifacts"][name].get("dtype") == "float32", f"dtype mismatch: {name}")
        require(record["artifacts"][name].get("sha256") == sha256(path), f"artifact digest mismatch: {name}")
    require(record.get("selected_artifact") == {
        "role": "A_pattern_context", "filename": NAMES[0],
        "shape": [99524, 256], "dtype": "float32",
        "sha256": record["artifacts"][NAMES[0]]["sha256"],
    }, "selected artifact binding mismatch")
    require(record.get("kernel") == {
        "filename": "vector_lane.cl", "entry": "row_mod_mean",
        "backend": "OpenCL 1.2", "sha256": sha256(ROOT / "vector_lane.cl"),
    }, "vector kernel binding mismatch")

    pair_path = VECTOR_DIR / "aiml_pattern_template_pairs.jsonl"
    require(record.get("alignment_digest") == sha256(pair_path), "alignment digest mismatch")
    with pair_path.open(encoding="utf-8") as stream:
        for index, line in enumerate(stream):
            row = json.loads(line)
            require(row.get("index") == index and row.get("A", {}).get("vector_row") == index and
                    row.get("B", {}).get("vector_row") == index, f"alignment mismatch at {index}")
    require(index + 1 == 99524, "pair row count mismatch")

    gml = ROOT / "build/gml-stage1/Release/gml.exe"
    identity = subprocess.run([str(gml), str(ROOT / "build/ccc4-tensor.gml")], capture_output=True, text=True, check=True)
    match = re.search(r"topology_hash=([0-9a-f]{64}) contract_hash=([0-9a-f]{64})", identity.stdout)
    require(match and match.groups() == (EXPECTED_TOPOLOGY, EXPECTED_CONTRACT), "Stage-1 identity mismatch")

    encoder = ROOT / "build/gml-stage1/Release/operator_plan_vector.exe"
    with tempfile.TemporaryDirectory() as directory:
        output = pathlib.Path(directory) / "operator-plan.bin"
        subprocess.run([str(encoder), str(output)], capture_output=True, text=True, check=True)
        require(sha256(output) == EXPECTED_PLAN, "C++ operator-plan vector mismatch")
    return "binding candidate independently checked; execution_authorized=false"


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("record", type=pathlib.Path, help="record emitted by validator.py --output")
    args = parser.parse_args()
    try:
        print(check(json.loads(args.record.read_text(encoding="utf-8"))))
    except (OSError, ValueError, KeyError, subprocess.CalledProcessError, json.JSONDecodeError) as error:
        parser.exit(1, f"checker: {error}\n")


if __name__ == "__main__":
    main()
