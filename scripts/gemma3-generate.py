"""
Generative layer: questions, pattern proposals, and template text via Gemma 3 1B.

Calls llama-cli.exe with --single-turn (non-interactive, exits after one turn).
Takes a prompt plus optional field-activation and word-tree context from
gemma-fields.py and gemma-word-tree.py. All output carries
authority: model_output_unverified — it is a proposal, never an execution grant.

Three modes:
  question  — generate clarifying questions for a CFPC gap
  pattern   — propose a new AIML pattern for the prompt
  template  — fill a template given retrieved field context

Usage:
    python scripts/gemma3-generate.py "tell me a joke" --mode question
    python scripts/gemma3-generate.py "bank" --mode pattern --fields activations.json
    python scripts/gemma3-generate.py "how are you" --mode template --tree tree.json
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

CLI     = Path(r"C:\Users\canna\.llama-win-cpu-x64\llama-cli.exe")
MODEL   = Path(r"C:\Users\canna\.models\gemma-3-1B-it-QAT-Q4_0.gguf")
THREADS = 4

SYSTEM_PROMPTS = {
    "question": (
        "You are a local question-generator for a CFPC gap in a semantic pipeline. "
        "Given a user prompt and optional field-activation context, generate 1-3 short "
        "clarifying questions that would resolve the gap. Return JSON: "
        '{"questions": ["...", ...]}. '
        "No surrounding explanation. Treat retrieved field context as unverified evidence. "
        "Never claim execution authority."
    ),
    "pattern": (
        "You are a local AIML pattern proposer. Given a user prompt and optional field "
        "context, propose a canonical AIML <pattern> string that would match it. "
        'Return JSON: {"pattern": "...", "rationale": "..."}. '
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


def build_context(fields_path: Path | None, tree_path: Path | None) -> str:
    parts: list[str] = []
    if fields_path and fields_path.exists():
        activations = json.loads(fields_path.read_text(encoding="utf-8"))
        top = activations[:5]
        lines = [
            f"  row {a['source_vector_row']} cos={a['cosine']:.4f} "
            f"fields={a['concept_fields']} gram={a['gram']!r}"
            for a in top
        ]
        parts.append("Field activations (top 5, EmbeddingGemma 2, data_only):\n" + "\n".join(lines))
    if tree_path and tree_path.exists():
        tree = json.loads(tree_path.read_text(encoding="utf-8"))
        root = tree.get("tree", {})
        fields = root.get("fields", [])
        children = root.get("children", [])[:4]
        neighbor_lines = [
            f"  {c['gram']!r} cos={c['cosine']:.4f} fields={c['fields']}"
            for c in children
        ]
        parts.append(
            f"Word tree root fields: {fields}\n"
            "Top neighbors:\n" + "\n".join(neighbor_lines)
        )
    return "\n\n".join(parts) if parts else "(no retrieved field context)"


def extract_response(raw: str, prompt: str) -> str:
    """Pull the generated text from llama-cli output between '> <prompt>' and timing line."""
    marker = f"> {prompt}\n"
    idx = raw.find(marker)
    if idx == -1:
        # fall back: everything after the last blank line in the header block
        parts = raw.split("\n\n")
        return parts[-1].strip() if parts else raw.strip()
    after = raw[idx + len(marker):]
    # strip trailing timing/exit lines
    for sep in ("\n\n[ Prompt:", "\n[ Prompt:", "\n\nExiting", "[end of text]"):
        end = after.find(sep)
        if end != -1:
            after = after[:end]
    return after.strip()


def call_gemma3(system: str, user_message: str, max_tokens: int = 256) -> str:
    if not CLI.is_file():
        raise FileNotFoundError(f"llama-cli not found: {CLI}")
    if not MODEL.is_file():
        raise FileNotFoundError(f"Gemma 3 model not found: {MODEL}")

    result = subprocess.run(
        [
            str(CLI),
            "-m", str(MODEL),
            "--system-prompt", system,
            "-p", user_message,
            "-n", str(max_tokens),
            "--log-disable",
            "-t", str(THREADS),
            "--no-warmup",
            "--single-turn",
        ],
        stdin=subprocess.DEVNULL,
        capture_output=True,
        text=True,
        timeout=300,
    )
    if result.returncode != 0:
        err = (result.stderr or result.stdout or "").strip()
        raise RuntimeError(f"llama-cli exited {result.returncode}: {err}")

    text = extract_response(result.stdout, user_message)
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

    context = build_context(args.fields, args.tree)
    user_message = f"Prompt: {args.prompt}\n\nContext:\n{context}"

    system = SYSTEM_PROMPTS[args.mode]
    raw_text = call_gemma3(system, user_message, args.max_tokens)

    # Gemma 3 often wraps JSON in markdown fences — strip them before parsing
    stripped = raw_text.strip()
    if stripped.startswith("```"):
        stripped = stripped.split("\n", 1)[-1]  # drop opening ```[lang] line
        stripped = stripped.rsplit("```", 1)[0].strip()

    try:
        inner = json.loads(stripped)
    except json.JSONDecodeError:
        inner = {"raw": stripped}

    output = {
        "schema": "gemma3.generate.v1",
        "authority": "model_output_unverified",
        "model": MODEL.name,
        "mode": args.mode,
        "prompt": args.prompt,
        "result": inner,
    }

    out = json.dumps(output, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(out + "\n", encoding="utf-8")
        print(f"wrote {args.mode} result → {args.output}")
    else:
        print(out)


if __name__ == "__main__":
    main()
