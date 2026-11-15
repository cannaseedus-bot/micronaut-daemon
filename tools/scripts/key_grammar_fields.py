"""Compile and rank read-only key-grammar fields with pinned EmbeddingGemma 2."""
import argparse
import hashlib
import json
import os
import re
import sys
from pathlib import Path

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
VECTOR_MANIFEST = ROOT / "build/io/aiml-embeddinggemma2-vectors/manifest.json"
OUT = ROOT / "build/io/key-grammar-fields"
SOURCES = (
    "greeting-bank.key-grammar.jsonl",
    "control-flow.key-grammar.jsonl",
    "socialsphere.key-grammar.jsonl",
    "asx-mini-app.key-grammar.jsonl",
    "advisor-bootstrap.key-grammar.jsonl",
    "cloud-model-chat.key-grammar.jsonl",
)
PHASES = {"Pop", "Wo", "Yax", "Sek", "Ch'en", "Xul"}


def digest(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def pinned_model():
    manifest_bytes = VECTOR_MANIFEST.read_bytes()
    manifest = json.loads(manifest_bytes)
    if (manifest.get("model") != "google/embeddinggemma-2" or
            manifest.get("dimensions") != 256 or manifest.get("dtype") != "float32"):
        raise ValueError("unsupported embedding contract")
    snapshot = Path(manifest["model_snapshot"])
    config = json.loads((snapshot / "config_sentence_transformers.json").read_text(encoding="utf-8"))
    if config.get("prompts", {}).get("Document") != "title: none | text: ":
        raise ValueError("pinned document prompt changed")
    os.environ["HF_HUB_OFFLINE"] = "1"
    os.environ["TRANSFORMERS_OFFLINE"] = "1"
    from sentence_transformers import SentenceTransformer
    return SentenceTransformer(str(snapshot), device="cpu", local_files_only=True), digest(manifest_bytes)


def collect():
    fields, sources, seen = [], {}, set()
    for name in SOURCES:
        path = ROOT / "data/grammar" / name
        raw = path.read_bytes()
        sources[f"data/grammar/{name}"] = digest(raw)
        for line_no, line in enumerate(raw.decode("utf-8-sig").splitlines(), 1):
            if not line.strip():
                continue
            row = json.loads(line)
            key = row.get("key")
            if not isinstance(key, str) or not key:
                raise ValueError(f"missing key in {name}:{line_no}")
            if key in seen:
                continue  # Shared app rows keep their first source binding.
            seen.add(key)
            key_phase = next((part.title() for part in key.split(":") if part.title() in PHASES), "Pop")
            phase = row.get("phase", key_phase)
            if phase not in PHASES:
                raise ValueError(f"invalid phase in {name}:{line_no}")
            text = next((row[k] for k in ("definition", "description", "pattern", "sugar", "gram", "word", "program", "event")
                         if isinstance(row.get(k), str) and row[k].strip()), None)
            if text is None:
                text = key
            fields.append({"key": key, "phase": phase, "text": text[:2048],
                           "source": f"data/grammar/{name}", "line": line_no,
                           "schema": row.get("schema", row.get("@type", "unspecified")),
                           "authority": "candidate_only"})
    return fields, sources


def compile_fields():
    fields, sources = collect()
    model_manifest_hash = digest(VECTOR_MANIFEST.read_bytes())
    rows_path = OUT / "fields.v1.jsonl"
    vectors_path = OUT / "fields.v1.f32.npy"
    manifest_path = OUT / "manifest.v1.json"
    vectors = None
    if rows_path.is_file() and vectors_path.is_file() and manifest_path.is_file():
        previous = json.loads(manifest_path.read_text(encoding="utf-8"))
        old_rows = [json.loads(line) for line in rows_path.read_text(encoding="utf-8").splitlines()]
        if (previous.get("model_manifest_sha256") == model_manifest_hash and
                previous.get("vectors_sha256") == digest(vectors_path.read_bytes()) and
                [(r["key"], r["text"]) for r in old_rows] == [(r["key"], r["text"]) for r in fields]):
            vectors = np.load(vectors_path, allow_pickle=False)
    if vectors is None:
        model, model_manifest_hash = pinned_model()
        vectors = model.encode([f["text"] for f in fields], prompt_name="Document",
                               truncate_dim=256, normalize_embeddings=True,
                               convert_to_numpy=True, show_progress_bar=False, batch_size=16)
    vectors = np.asarray(vectors, dtype="<f4")
    if vectors.shape != (len(fields), 256) or not np.isfinite(vectors).all():
        raise ValueError("invalid field vectors")
    norms = np.linalg.norm(vectors.astype(np.float64), axis=1)
    if np.any(norms <= 0):
        raise ValueError("zero field vector")
    vectors = np.asarray(vectors / norms[:, None], dtype="<f4")
    OUT.mkdir(parents=True, exist_ok=True)
    rows_path.write_text("".join(json.dumps(f, ensure_ascii=False, separators=(",", ":")) + "\n" for f in fields), encoding="utf-8")
    np.save(vectors_path, vectors, allow_pickle=False)
    manifest = {"schema": "micronaut.key-grammar-fields.v1", "model": "google/embeddinggemma-2",
                "model_manifest_sha256": model_manifest_hash, "rows": len(fields), "dimensions": 256,
                "prompt_name": "Document", "authority": "candidate_only", "sources": sources,
                "fields_sha256": digest(rows_path.read_bytes()), "vectors_sha256": digest(vectors_path.read_bytes())}
    (OUT / "manifest.v1.json").write_text(json.dumps(manifest, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"rows": len(fields), "output": str(OUT)}))


def rank(query, top_k):
    manifest = json.loads((OUT / "manifest.v1.json").read_text(encoding="utf-8"))
    if manifest.get("model_manifest_sha256") != digest(VECTOR_MANIFEST.read_bytes()):
        raise ValueError("model manifest changed; rebuild fields")
    for source, expected in manifest["sources"].items():
        if digest((ROOT / source).read_bytes()) != expected:
            raise ValueError(f"field source changed: {source}")
    rows_path, vectors_path = OUT / "fields.v1.jsonl", OUT / "fields.v1.f32.npy"
    if digest(rows_path.read_bytes()) != manifest["fields_sha256"] or digest(vectors_path.read_bytes()) != manifest["vectors_sha256"]:
        raise ValueError("field artifact digest mismatch")
    rows = [json.loads(line) for line in rows_path.read_text(encoding="utf-8").splitlines()]
    vectors = np.load(vectors_path, allow_pickle=False)
    q = np.asarray(query, dtype=np.float64)
    if q.shape != (256,) or not np.isfinite(q).all() or np.linalg.norm(q) <= 0:
        raise ValueError("query must be a finite nonzero 256-value vector")
    if vectors.shape != (len(rows), 256):
        raise ValueError("field shape mismatch")
    scores = vectors.astype(np.float64) @ (q / np.linalg.norm(q))
    order = sorted(range(len(rows)), key=lambda i: (-float(scores[i]), rows[i]["key"]))[:top_k]
    return {"schema": "micronaut.key-grammar-field-ranking.v1", "authority": "candidate_only",
            "model_manifest_sha256": manifest["model_manifest_sha256"],
            "hits": [{**rows[i], "score": float(scores[i])} for i in order]}


def reply(query, prompt):
    """Select source-bound presentation text for declared greeting and control keys."""
    result = rank(query, 20)
    normalized = " ".join(prompt.lower().strip().rstrip(".!?").split())
    empty = {"schema": "micronaut.key-grammar-reply.v1", "selection": "none", "authority": "candidate_only"}
    if normalized in {"hello", "hi", "hey", "good morning", "good afternoon", "good evening"}:
        bank = json.loads((ROOT / "data/grammar/greeting-bank.json").read_text(encoding="utf-8"))
        canonical = set(bank["greetings"][0]["templates"])
        eligible = [hit for hit in result["hits"] if hit["key"] in {"GREETING:POP:1", "GREETING:POP:2", "GREETING:POP:3"}
                    and hit["phase"] == "Pop" and hit["source"] == "data/grammar/greeting-bank.key-grammar.jsonl"
                    and hit["text"] in canonical and "{" not in hit["text"]]
        if eligible and eligible[0]["score"] >= 0.80:
            chosen = eligible[0]
            return {"schema": "micronaut.key-grammar-reply.v1", "selection": "verified_literal_greeting",
                    "authority": "source_bound_read_only", "key": chosen["key"], "phase": chosen["phase"],
                    "score": chosen["score"], "source": chosen["source"], "text": chosen["text"]}
        return empty
    match = re.fullmatch(r"(?:what does|explain|define|what is) (?:the )?([a-z]+)(?: (?:operator|keyword|key))?(?: mean)?", normalized)
    if not match:
        return empty
    word = match.group(1)
    control_path = ROOT / "data/grammar/control-flow.key-grammar.jsonl"
    controls = {row["key"]: row for row in (json.loads(line) for line in control_path.read_text(encoding="utf-8").splitlines())}
    key = f"control:{word}"
    row = controls.get(key)
    if not row or row.get("word") != word or not isinstance(row.get("sugar"), str) or not isinstance(row.get("operator"), str):
        return empty
    hit = next((item for item in result["hits"] if item["key"] == key), None)
    if not hit or hit["score"] < 0.75 or hit["text"] != row["sugar"] or hit["source"] != "data/grammar/control-flow.key-grammar.jsonl":
        return empty
    text = f"The {word} control key uses `{row['sugar']}` and maps to {row['operator']}."
    return {"schema": "micronaut.key-grammar-reply.v1", "selection": "verified_control_description",
            "authority": "source_bound_read_only", "key": key, "phase": hit["phase"],
            "score": hit["score"], "source": hit["source"], "text": text}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("compile")
    rank_parser = sub.add_parser("rank")
    rank_parser.add_argument("--top-k", type=int, default=5)
    sub.add_parser("reply")
    args = parser.parse_args()
    if args.command == "compile":
        compile_fields()
    elif args.command == "rank":
        if not 1 <= args.top_k <= 20:
            raise ValueError("top-k must be 1..20")
        body = json.load(sys.stdin)
        print(json.dumps(rank(body["query_vector"], args.top_k), ensure_ascii=False, separators=(",", ":")))
    else:
        body = json.load(sys.stdin)
        print(json.dumps(reply(body["query_vector"], body["prompt"]), ensure_ascii=False, separators=(",", ":")))


if __name__ == "__main__":
    main()
