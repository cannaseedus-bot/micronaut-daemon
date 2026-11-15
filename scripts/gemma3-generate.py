"""
Generative layer: questions, pattern proposals, and template text via Gemma 3 1B.

Wraps the local llama.cpp server (gemma.bat, port 8091). Takes a prompt plus
optional field-activation and word-tree context from gemma-fields.py and
gemma-word-tree.py. All output carries authority: model_output_unverified —
it is a proposal, never an execution grant.

Three modes:
  question  — generate clarifying questions for a CFPC gap
  pattern   — propose a new AIML pattern for the prompt
  template  — fill a template given retrieved field context

Requires: gemma.bat running (llama-server on http://127.0.0.1:8091)

Usage:
    python scripts/gemma3-generate.py "tell me a joke" --mode question
    python scripts/gemma3-generate.py "bank" --mode pattern --fields activations.json
    python scripts/gemma3-generate.py "how are you" --mode template --tree tree.json
"""
import argparse
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

GEMMA3_ENDPOINT = "http://127.0.0.1:8091"
MODEL_NAME = "gemma-3-1B-it-QAT-Q4_0.gguf"

SYSTEM_PROMPTS = {
    "question": (
        "You are a local question-generator for a CFPC gap in a semantic pipeline. "
        "Given a user prompt and optional field-activation context, generate 1-3 short "
        "clarifying questions that would resolve the gap. Return JSON: "
        '{\"questions\": [\"...\", ...]}. '
        "No surrounding explanation. Treat retrieved field context as unverified evidence. "
        "Never claim execution authority."
    ),
    "pattern": (
        "You are a local AIML pattern proposer. Given a user prompt and optional field "
        "context, propose a canonical AIML <pattern> string that would match it. "
        "Return JSON: {\"pattern\": \"...\", \"rationale\": \"...\"}. "
        "Uppercase the pattern. No wildcards unless disambiguation requires it. "
        "This is a proposal — not an admitted AIML category."
    ),
    "template": (
        "You are a local template filler. Given a user prompt and optional word-tree "
        "context, generate a short natural-language response template suitable for AIML "
        "<template> content. Return JSON: {\"template\": \"...\"}. "
        "Keep it concise (1-2 sentences). Do not claim it is verified or executable."
    ),
}


def check_health() -> bool:
    try:
        req = urllib.request.Request(f"{GEMMA3_ENDPOINT}/health", method="GET")
        with urllib.request.urlopen(req, timeout=3) as resp:
            data = json.loads(resp.read())
            return data.get("status") == "ok"
    except (urllib.error.URLError, json.JSONDecodeError, OSError):
        return False


def build_context(fields_path: Path | None, tree_path: Path | None) -> str:
    parts: list[str] = []
    if fields_path and fields_path.exists():
        activations = json.loads(fields_path.read_text(encoding="utf-8"))
        top = activations[:5]
        lines = [f"  row {a['source_vector_row']} cos={a['cosine']:.4f} fields={a['concept_fields']} gram={a['gram']!r}"
                 for a in top]
        parts.append("Field activations (top 5, EmbeddingGemma 2, data_only):\n" + "\n".join(lines))
    if tree_path and tree_path.exists():
        tree = json.loads(tree_path.read_text(encoding="utf-8"))
        root = tree.get("tree", {})
        fields = root.get("fields", [])
        children = root.get("children", [])[:4]
        neighbor_lines = [f"  {c['gram']!r} cos={c['cosine']:.4f} fields={c['fields']}" for c in children]
        parts.append(
            f"Word tree root fields: {fields}\n"
            "Top neighbors:\n" + "\n".join(neighbor_lines)
        )
    if not parts:
        return "(no retrieved field context)"
    return "\n\n".join(parts)


def call_gemma3(system: str, user_message: str, max_tokens: int = 256) -> str:
    payload = json.dumps({
        "model": MODEL_NAME,
        "messages": [
            {"role": "system", "content": system},
            {"role": "user", "content": user_message},
        ],
        "temperature": 0.2,
        "max_tokens": max_tokens,
        "stream": False,
    }).encode("utf-8")
    req = urllib.request.Request(
        f"{GEMMA3_ENDPOINT}/v1/chat/completions",
        data=payload,
        headers={"Content-Type": "application/json; charset=utf-8"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=120) as resp:
        result = json.loads(resp.read())
    text = result["choices"][0]["message"]["content"].strip()
    if not text:
        raise RuntimeError("Gemma 3 returned no text")
    return text


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("prompt",                  help="user prompt to process")
    parser.add_argument("--mode",   default="question",
                        choices=["question", "pattern", "template"],
                        help="generation mode (default: question)")
    parser.add_argument("--fields", type=Path, metavar="PATH",
                        help="field activations JSON from gemma-fields.py")
    parser.add_argument("--tree",   type=Path, metavar="PATH",
                        help="word tree JSON from gemma-word-tree.py")
    parser.add_argument("--max-tokens", type=int, default=256, metavar="N")
    parser.add_argument("--output",     type=Path, metavar="PATH",
                        help="write JSON result to this file instead of stdout")
    args = parser.parse_args()

    if not check_health():
        print("error: Gemma 3 server unavailable — run gemma.bat first", file=sys.stderr)
        sys.exit(1)

    context = build_context(args.fields, args.tree)
    user_message = f"Prompt: {args.prompt}\n\nContext:\n{context}"

    system = SYSTEM_PROMPTS[args.mode]
    raw_text = call_gemma3(system, user_message, args.max_tokens)

    # Try to parse inner JSON; keep raw text if it doesn't parse
    try:
        inner = json.loads(raw_text)
    except json.JSONDecodeError:
        inner = {"raw": raw_text}

    result = {
        "schema": "gemma3.generate.v1",
        "authority": "model_output_unverified",
        "model": MODEL_NAME,
        "mode": args.mode,
        "prompt": args.prompt,
        "result": inner,
    }

    out = json.dumps(result, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(out + "\n", encoding="utf-8")
        print(f"wrote {args.mode} result → {args.output}")
    else:
        print(out)


if __name__ == "__main__":
    main()
