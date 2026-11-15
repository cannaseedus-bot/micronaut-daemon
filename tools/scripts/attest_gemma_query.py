"""Encode and attest one bridge query using the pinned offline encoder."""
import argparse
import hashlib
import hmac
import json
import os

from encode_gemma_query import encode


def attest(text: str) -> dict:
    utterance = text.strip()
    if not utterance or utterance != text:
        raise ValueError("utterance must be nonempty and trimmed")
    key = os.environ.get("MICRONAUT_GEMMA_ATTEST_KEY", "").encode("utf-8")
    if len(key) < 32:
        raise ValueError("host attestation key must contain at least 32 UTF-8 bytes")
    vector, metadata = encode(utterance)
    digest = hashlib.sha256(vector.tobytes()).hexdigest()
    message = ("gemma.bridge.query-attestation.v1\n" + utterance + "\n" + digest +
               "\n" + metadata["manifest_sha256"]).encode("utf-8")
    return {
        "query_vector": vector.tolist(),
        "attestation": {
            "schema": "gemma.bridge.query-attestation.v1",
            "model": metadata["model"],
            "prompt_name": metadata["prompt_name"],
            "manifest_sha256": metadata["manifest_sha256"],
            "vector_sha256": digest,
            "mac_sha256": hmac.new(key, message, hashlib.sha256).hexdigest(),
        },
    }


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("utterance")
    args = parser.parse_args()
    print(json.dumps(attest(args.utterance), separators=(",", ":")))


if __name__ == "__main__":
    main()
