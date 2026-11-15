"""Check shard coverage, byte-preserving reassembly, and digest rejection."""
import json
from pathlib import Path
import subprocess
import tempfile

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
CLI = ROOT / "build/gml-stage1/Release/store_write_cli.exe"
SOURCE = ROOT / "build/ccc4-plan-v2-example.npy"


def main():
    with tempfile.TemporaryDirectory() as directory:
        output = Path(directory) / "shards"
        created = subprocess.run([CLI, SOURCE, output, "ccc4-fixture", "fixture-model", "16"],
                                 capture_output=True, text=True)
        assert created.returncode == 0, created.stderr
        manifest_path = output / "manifest.json"
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        assert manifest["schema"] == "gemma.bridge.vector-shards.v1"
        assert [(x["start_row"], x["stop_row"]) for x in manifest["shards"]] == [
            (0, 16), (16, 32), (32, 48), (48, 64), (64, 65)]
        source = np.load(SOURCE)
        restored = np.concatenate([np.load(output / entry["file"])
                                   for entry in manifest["shards"]])
        np.testing.assert_array_equal(restored, source)
        denied = subprocess.run([CLI, SOURCE, output, "ccc4-fixture", "fixture-model", "16"],
                                capture_output=True, text=True)
        assert denied.returncode != 0 and "already exists" in denied.stderr
        shard = output / manifest["shards"][0]["file"]
        with shard.open("r+b") as stream:
            stream.seek(-1, 2)
            byte = stream.read(1)
            stream.seek(-1, 2)
            stream.write(bytes([byte[0] ^ 1]))
        rejected = subprocess.run([CLI, "--verify", manifest_path, SOURCE],
                                  capture_output=True, text=True)
        assert rejected.returncode != 0 and "digest mismatch" in rejected.stderr
    print("store writer: five shards, exact reassembly, overwrite and tamper rejection passed")


if __name__ == "__main__":
    main()
