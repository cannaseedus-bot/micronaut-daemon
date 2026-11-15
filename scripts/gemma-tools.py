"""
Tool and verb implementation reasoning via Gemma 3 1B.

Loads gemma-tools.v1.json as grounding context, then lets Gemma 3 answer
questions about how tools are implemented, which phase they run in, what
verbs they expose, and how to call them.

Output carries authority: model_output_unverified — Gemma 3 reasons from
the catalog but its answers are proposals, not execution grants.

Usage:
    python scripts/gemma-tools.py "What does vector_match do?"
    python scripts/gemma-tools.py "Which phase does fold_execute run in?"
    python scripts/gemma-tools.py "List all verbs in tool:xcfe"
    python scripts/gemma-tools.py "How do I call micronaut_dispatch?" --output answer.json
    python scripts/gemma-tools.py --list-verbs
"""
import argparse
import json
import subprocess
import sys
from pathlib import Path

CLI        = Path(r"C:\Users\canna\.llama-win-cpu-x64\llama-cli.exe")
MODEL      = Path(r"C:\Users\canna\.models\gemma-3-1B-it-QAT-Q4_0.gguf")
TOOLS_JSON = Path(__file__).resolve().parents[1] / "data/grammar/gemma-tools.v1.json"
THREADS    = 4

SYSTEM = (
    "You are a local tool-reasoning assistant for the Micronaut Daemon. "
    "You have access to a tool and verb implementation catalog (gemma-tools.v1). "
    "Answer questions about tool verbs, phases, surfaces, scripts, and admission rules "
    "using only information in the provided catalog. "
    "Be concise. If a verb is not in the catalog, say so. "
    "Never claim that a tool call grants execution authority — all entries are candidate_only. "
    "Do not invent verb names or implementation paths not listed in the catalog."
)


def load_catalog() -> dict:
    if not TOOLS_JSON.exists():
        raise FileNotFoundError(f"gemma-tools.v1.json not found: {TOOLS_JSON}")
    return json.loads(TOOLS_JSON.read_text(encoding="utf-8"))


def catalog_summary(catalog: dict) -> str:
    """Compact text representation of the catalog for the context window."""
    lines = [
        f"schema: {catalog['schema']}",
        f"admission_rule: {catalog['admission_rule']}",
        f"execution_boundary: {catalog['execution_boundary']}",
        "",
        "--- verb_catalog ---",
    ]
    for entry in catalog.get("verb_catalog", []):
        lines.append(
            f"verb={entry['verb']}  surface={entry['surface']}  method={entry['method']}  "
            f"phase={entry['phase']}  authority={entry['authority']}\n"
            f"  ngrams={entry['ngrams']}\n"
            f"  params={json.dumps(entry['params'])}\n"
            f"  impl={entry['implementation']}"
        )
    lines.append("")
    lines.append("--- tool_families ---")
    for family, info in catalog.get("tool_families", {}).items():
        lines.append(
            f"{family}  phase={info['phase']}  authority={info['authority']}\n"
            f"  verbs={info['verbs']}"
        )
    lines.append("")
    lines.append("--- intent_to_verb ---")
    for intent, verb in catalog.get("intent_to_verb", {}).items():
        lines.append(f"  {intent} → {verb}")
    return "\n".join(lines)


def extract_response(raw: str, prompt_prefix: str) -> str:
    marker = f"> {prompt_prefix[:40]}"
    idx = raw.find(marker)
    if idx != -1:
        after = raw[idx:]
        newline = after.find("\n")
        after = after[newline + 1:] if newline != -1 else after
    else:
        parts = raw.split("\n\n")
        after = parts[-1] if parts else raw
    for sep in ("\n\n[ Prompt:", "\n[ Prompt:", "\n\nExiting", "[end of text]"):
        end = after.find(sep)
        if end != -1:
            after = after[:end]
    return after.strip()


def call_gemma3(user_message: str, max_tokens: int) -> str:
    if not CLI.is_file():
        raise FileNotFoundError(f"llama-cli not found: {CLI}")
    if not MODEL.is_file():
        raise FileNotFoundError(f"Gemma 3 model not found: {MODEL}")

    result = subprocess.run(
        [
            str(CLI),
            "-m", str(MODEL),
            "--system-prompt", SYSTEM,
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
    return extract_response(result.stdout, user_message)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("question",  nargs="?", default=None,
                        help="natural-language question about a tool or verb")
    parser.add_argument("--list-verbs", action="store_true",
                        help="print all verb names from the catalog and exit")
    parser.add_argument("--max-tokens", type=int, default=256, metavar="N")
    parser.add_argument("--output",     type=Path, metavar="PATH",
                        help="write JSON result to this file instead of stdout")
    args = parser.parse_args()

    catalog = load_catalog()

    if args.list_verbs:
        verbs = [e["verb"] for e in catalog.get("verb_catalog", [])]
        print("\n".join(verbs))
        return

    if not args.question:
        parser.print_help()
        sys.exit(1)

    summary = catalog_summary(catalog)
    user_message = f"Catalog:\n{summary}\n\nQuestion: {args.question}"

    answer = call_gemma3(user_message, args.max_tokens)

    output = {
        "schema": "gemma-tools.answer.v1",
        "authority": "model_output_unverified",
        "model": MODEL.name,
        "catalog": TOOLS_JSON.name,
        "question": args.question,
        "answer": answer,
    }

    out = json.dumps(output, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(out + "\n", encoding="utf-8")
        print(f"wrote answer → {args.output}")
    else:
        print(out)


if __name__ == "__main__":
    main()
