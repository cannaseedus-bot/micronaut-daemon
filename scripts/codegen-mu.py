"""
CODEGEN-µ pipeline: code generation and edit proposals via bigram corpus + Gemma 3.

Implements the three-stage grammar:
  codegen-mu.parser.ebnf    — input validation (CodeTask, Gemma3EditAST)
  codegen-mu.compiler.ebnf  — Wo: language classification + bigram lookup
                              Yax: compile Gemma 3 AST → EditOperationIR
  codegen-mu.generator.ebnf — Sek: serialize EditCandidate → GeneratedCodeProposal

All output carries authority: candidate_only.
XCFE Ch'en admission is required before any edit crosses into the file system.

Usage:
    # Generate from bigram corpus
    python scripts/codegen-mu.py "compute_score function" --lang cpp --task generate

    # Plan a file edit (calls Gemma 3 for the edit AST)
    python scripts/codegen-mu.py "replace compute_score with faster impl" \\
        --file src/xcfe_router.cpp --task edit

    # Use a pre-computed Gemma 3 edit AST
    python scripts/codegen-mu.py "rename sym" --file src/pop.cpp --task edit \\
        --gemma3-ast ast.json

    # Refactor / debug / test variants
    python scripts/codegen-mu.py "extract magic numbers" --file src/sek.cpp --task refactor
"""
import argparse
import json
import re
import subprocess
import sys
from pathlib import Path

ROOT        = Path(__file__).resolve().parents[1]
CORPUS_ROOT = ROOT / "data" / "gram"
CLI         = Path(r"C:\Users\canna\.llama-win-cpu-x64\llama-cli.exe")
MODEL       = Path(r"C:\Users\canna\.models\gemma-3-1B-it-QAT-Q4_0.gguf")
THREADS     = 4

# Wo: language corpus binding table (codegen-mu.compiler.ebnf §1)
LANGUAGE_MAP = {
    "cpp":  ("codegen-cpp.jsonl",  56176),
    "py":   ("codegen-py.jsonl",   42105),
    "h":    ("codegen-h.jsonl",    25003),
    "json": ("codegen-json.jsonl", 14929),
    "html": ("codegen-html.jsonl", 11417),
    "js":   ("codegen-js.jsonl",   3691),
    "ts":   ("codegen-ts.jsonl",   48),
    "hlsl": ("codegen-hlsl.jsonl", 1347),
    "kxml": ("codegen-kxml.jsonl", 974),
    "css":  ("codegen-css.jsonl",  73),
}

EXT_MAP = {
    ".cpp": "cpp", ".cc": "cpp", ".cxx": "cpp",
    ".py": "py",
    ".h": "h", ".hpp": "h",
    ".json": "json",
    ".html": "html", ".htm": "html",
    ".js": "js", ".mjs": "js",
    ".ts": "ts",
    ".hlsl": "hlsl",
    ".kxml": "kxml",
    ".css": "css",
}

EDIT_OPS = {
    "replace_function", "replace_expression", "insert_block",
    "delete_node", "rename_symbol", "add_parameter", "modify_field",
}

SYSTEM_EDIT = (
    "You are a local code-edit planner for the Micronaut Daemon CODEGEN-µ pipeline. "
    "Given an edit intent and optional file context, produce a structured edit operation as JSON. "
    "Choose exactly one op from: replace_function, replace_expression, insert_block, "
    "delete_node, rename_symbol, add_parameter, modify_field. "
    "Return ONLY the JSON object — no surrounding text, no markdown fences. "
    "Examples:\n"
    '  {"op":"replace_function","name":"compute_score","body":"...","reason":"..."}\n'
    '  {"op":"rename_symbol","from":"old","to":"new","scope":{"kind":"function","name":"process"},'
    '"reason":"..."}\n'
    '  {"op":"insert_block","after":{"kind":"function","name":"init"},"content":"...","reason":"..."}\n'
    "This is a candidate proposal — not an execution grant. Never claim authority."
)


# ── Phase 0: parser (input validation) ────────────────────────────────────────

def detect_language(file: "Path | None", lang: "str | None") -> str:
    if lang:
        if lang not in LANGUAGE_MAP:
            raise ValueError(f"Unknown language '{lang}'. Known: {', '.join(LANGUAGE_MAP)}")
        return lang
    if file:
        ext = Path(file).suffix.lower()
        if ext in EXT_MAP:
            return EXT_MAP[ext]
        raise ValueError(f"Cannot detect language from extension '{ext}'. Pass --lang explicitly.")
    raise ValueError("Either --file or --lang is required.")


def validate_gemma3_ast(ast: dict) -> None:
    op = ast.get("op")
    if op not in EDIT_OPS:
        raise ValueError(f"Unknown Gemma3EditAST op '{op}'. Valid ops: {', '.join(sorted(EDIT_OPS))}")
    if op == "replace_function" and not ast.get("name"):
        raise ValueError("replace_function requires 'name'")
    if op == "rename_symbol" and ast.get("from") == ast.get("to"):
        raise ValueError("rename_symbol: 'from' and 'to' must differ")
    if op in {"insert_block", "delete_node", "modify_field"} and not ast.get(
        "after" if op == "insert_block" else "target"
    ):
        key = "after" if op == "insert_block" else "target"
        raise ValueError(f"{op} requires '{key}'")


# ── Phase Wo: language classification ─────────────────────────────────────────

def classify_language(lang: str) -> dict:
    corpus_file, records = LANGUAGE_MAP[lang]
    return {"id": lang, "corpus": corpus_file, "records": records}


# ── Phase Wo: bigram lookup ────────────────────────────────────────────────────

def lookup_bigrams(lang_binding: dict, prompt: str, top_k: int = 5) -> list:
    corpus_path = CORPUS_ROOT / lang_binding["corpus"]
    if not corpus_path.exists():
        return []

    prompt_words = set(re.findall(r"[a-z0-9]+", prompt.lower()))
    if not prompt_words:
        return []

    scored: list[tuple[int, dict]] = []
    with corpus_path.open(encoding="utf-8", errors="replace") as fh:
        for line in fh:
            line = line.strip()
            if not line:
                continue
            try:
                rec = json.loads(line)
            except json.JSONDecodeError:
                continue
            surfaces = [s.lower() for s in rec.get("surfaces", [])]
            surface_words = set(re.findall(r"[a-z0-9]+", " ".join(surfaces)))
            score = len(prompt_words & surface_words)
            if score > 0:
                scored.append((score, rec))

    scored.sort(key=lambda x: -x[0])
    return [rec for _, rec in scored[:top_k]]


# ── Phase Yax: Gemma 3 edit AST ───────────────────────────────────────────────

def read_file_context(file: "Path | None", max_lines: int = 60) -> str:
    if not file or not Path(file).exists():
        return "(file not found)"
    lines = Path(file).read_text(encoding="utf-8", errors="replace").splitlines()
    snippet = "\n".join(lines[:max_lines])
    if len(lines) > max_lines:
        snippet += f"\n... ({len(lines) - max_lines} more lines)"
    return snippet


def extract_response(raw: str, prompt: str) -> str:
    marker = f"> {prompt[:80]}\n"
    idx = raw.find(marker)
    if idx == -1:
        parts = raw.split("\n\n")
        return parts[-1].strip() if parts else raw.strip()
    after = raw[idx + len(marker):]
    for sep in ("\n\n[ Prompt:", "\n[ Prompt:", "\n\nExiting", "[end of text]"):
        end = after.find(sep)
        if end != -1:
            after = after[:end]
    return after.strip()


def call_gemma3_edit(prompt: str, file_context: str, bigrams: list,
                     max_tokens: int = 384) -> dict:
    if not CLI.is_file():
        raise FileNotFoundError(f"llama-cli not found: {CLI}")
    if not MODEL.is_file():
        raise FileNotFoundError(f"Gemma 3 model not found: {MODEL}")

    bigram_lines = "\n".join(
        f"  key={b['key']} source={b.get('source', '')} text={b.get('text', '')[:80]}"
        for b in bigrams[:3]
    )
    user_message = (
        f"Edit intent: {prompt}\n\n"
        f"File context (first lines):\n{file_context}\n\n"
        f"Relevant bigram corpus records:\n{bigram_lines or '(none)'}"
    )

    result = subprocess.run(
        [
            str(CLI), "-m", str(MODEL),
            "--system-prompt", SYSTEM_EDIT,
            "-p", user_message,
            "-n", str(max_tokens),
            "--log-disable", "-t", str(THREADS), "--no-warmup", "--single-turn",
        ],
        stdin=subprocess.DEVNULL, capture_output=True, text=True, timeout=300,
    )
    if result.returncode != 0:
        err = (result.stderr or result.stdout or "").strip()
        raise RuntimeError(f"llama-cli exited {result.returncode}: {err}")

    raw = extract_response(result.stdout, user_message)
    stripped = raw.strip()
    if stripped.startswith("```"):
        stripped = stripped.split("\n", 1)[-1]
        stripped = stripped.rsplit("```", 1)[0].strip()

    try:
        ast = json.loads(stripped)
    except json.JSONDecodeError:
        ast = {"op": "replace_function", "name": "unknown", "body": stripped,
               "reason": "Gemma 3 returned non-JSON; body contains raw output"}

    return ast


# ── Phase Yax: compile IR ─────────────────────────────────────────────────────

def compile_ir(lang_binding: dict, file: "Path | None", bigrams: list,
               gemma3_ast: "dict | None", task: str) -> dict:
    lang = lang_binding["id"]
    file_str = str(file) if file else ""

    base = {
        "language": lang,
        "file": file_str,
        "candidate_only": True,
    }

    if gemma3_ast:
        op = gemma3_ast.get("op", "replace_function")
        ir = {**base, "ir_op": op}

        if op == "replace_function":
            ir["locator"] = {"kind": "function", "name": gemma3_ast.get("name", "")}
            ir["content"] = gemma3_ast.get("body", "")
        elif op == "replace_expression":
            ir["locator"] = {"kind": "expr", "name": gemma3_ast.get("scope", "")}
            ir["content"] = gemma3_ast.get("new_expr", "")
            ir["old_expr"] = gemma3_ast.get("old_expr", "")
        elif op == "insert_block":
            ir["after"] = gemma3_ast.get("after", {})
            ir["locator"] = gemma3_ast.get("after", {})
            ir["content"] = gemma3_ast.get("content", "")
        elif op == "delete_node":
            ir["locator"] = gemma3_ast.get("target", {})
            ir["content"] = ""
        elif op == "rename_symbol":
            ir["locator"] = gemma3_ast.get("scope", {})
            ir["from"] = gemma3_ast.get("from", "")
            ir["to"] = gemma3_ast.get("to", "")
            ir["content"] = ""
        elif op == "add_parameter":
            ir["locator"] = {"kind": "function", "name": gemma3_ast.get("function", "")}
            ir["param_type"] = gemma3_ast.get("param_type", "")
            ir["param_name"] = gemma3_ast.get("param_name", "")
            ir["content"] = f"{gemma3_ast.get('param_type','')} {gemma3_ast.get('param_name','')}"
        elif op == "modify_field":
            ir["locator"] = gemma3_ast.get("target", {})
            ir["content"] = gemma3_ast.get("new_value", "")

        ir["reason"] = gemma3_ast.get("reason", "")
    else:
        # generate from bigram corpus alone
        ir = {
            **base,
            "ir_op": "generate",
            "locator": {"kind": "file", "name": file_str},
            "bigrams": bigrams,
            "task": task,
            "content": "\n".join(b.get("text", "") for b in bigrams[:3]),
        }

    return ir


# ── Phase Sek: generate proposal ──────────────────────────────────────────────

def build_diff_preview(ir: dict) -> str:
    op = ir.get("ir_op", "generate")
    loc = ir.get("locator", {})
    loc_str = f"{loc.get('kind','')} {loc.get('name','')}".strip()

    if op == "replace_function":
        body = (ir.get("content") or "")[:60]
        return f"Replace function {loc.get('name','?')}: {body}..."
    if op == "replace_expression":
        return f"In {loc_str}: replace {ir.get('old_expr','?')} → {ir.get('content','?')}"
    if op == "insert_block":
        content = (ir.get("content") or "")[:60]
        return f"After {loc_str}: insert {content}..."
    if op == "delete_node":
        return f"Delete {loc_str}"
    if op == "rename_symbol":
        scope = ir.get("locator", {})
        scope_str = f"{scope.get('kind','')} {scope.get('name','')}".strip()
        return f"Rename {ir.get('from','?')} → {ir.get('to','?')} in {scope_str}"
    if op == "add_parameter":
        return (f"Add parameter {ir.get('param_type','?')} {ir.get('param_name','?')} "
                f"to {loc.get('name','?')}()")
    if op == "modify_field":
        return f"Set {loc_str} = {(ir.get('content') or '')[:60]}"
    if op == "generate":
        bk = ir.get("bigrams", [{}])[0].get("key", "?") if ir.get("bigrams") else "?"
        return f"Generate {ir.get('task','?')} from bigram key {bk} in {ir.get('language','?')}"
    return f"{op} on {loc_str}"


def route_label(task: str, lang: str) -> str:
    task_routes = {
        "refactor": "refactor", "debug": "debug", "test": "test", "generate": "generate",
    }
    verb = task_routes.get(task, "edit")
    return f"CODEGEN:{verb} · LANG:{lang} · TRACK:CODEGEN-µ"


def generate_proposal(ir: dict, task: str) -> dict:
    lang = ir["language"]
    loc = ir.get("locator", {"kind": "file", "name": ir.get("file", "")})
    proposal = {
        "schema": "codegen-mu.proposal.v1",
        "candidate_only": True,
        "xcfe_required": True,
        "authority": "candidate_only",
        "ir_op": ir["ir_op"],
        "language": lang,
        "file": ir.get("file", ""),
        "locator": loc,
        "content": ir.get("content", ""),
        "diff_preview": build_diff_preview(ir),
        "route": route_label(task, lang),
    }
    if ir.get("reason"):
        proposal["reason"] = ir["reason"]
    if ir.get("ir_op") == "generate" and ir.get("bigrams"):
        proposal["bigram_key"] = ir["bigrams"][0].get("key", "")
    return proposal


# ── Main ──────────────────────────────────────────────────────────────────────

def main():
    ap = argparse.ArgumentParser(description=__doc__,
                                 formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("prompt",
                    help="edit intent or generation prompt")
    ap.add_argument("--file",        type=Path, metavar="PATH",
                    help="target source file")
    ap.add_argument("--lang",        metavar="LANG",
                    help="language id: cpp py h json html js ts hlsl kxml css")
    ap.add_argument("--task",        default="edit",
                    choices=["generate", "edit", "refactor", "debug", "test", "implement"],
                    help="task kind (default: edit)")
    ap.add_argument("--gemma3-ast",  type=Path, metavar="PATH",
                    help="pre-computed Gemma 3 edit AST JSON (skip the Gemma 3 call)")
    ap.add_argument("--top-k",       type=int, default=5, metavar="N",
                    help="bigram corpus matches to retrieve (default: 5)")
    ap.add_argument("--max-tokens",  type=int, default=384, metavar="N",
                    help="Gemma 3 token budget for edit AST (default: 384)")
    ap.add_argument("--output",      type=Path, metavar="PATH",
                    help="write JSON proposal to this file instead of stdout")
    ap.add_argument("--dry-run",     action="store_true",
                    help="skip Gemma 3 call; compile from bigrams only")
    args = ap.parse_args()

    # ── parser phase ──────────────────────────────────────────────────────────
    try:
        lang = detect_language(args.file, args.lang)
    except ValueError as e:
        print(f"error: {e}", file=sys.stderr)
        sys.exit(1)

    gemma3_ast: dict | None = None
    if args.gemma3_ast:
        try:
            gemma3_ast = json.loads(args.gemma3_ast.read_text(encoding="utf-8"))
            validate_gemma3_ast(gemma3_ast)
        except (json.JSONDecodeError, ValueError) as e:
            print(f"error: invalid gemma3-ast: {e}", file=sys.stderr)
            sys.exit(1)

    # ── Wo: classify + bigram lookup ──────────────────────────────────────────
    lang_binding = classify_language(lang)
    bigrams = lookup_bigrams(lang_binding, args.prompt, top_k=args.top_k)

    # ── Yax: get Gemma 3 edit AST if needed ───────────────────────────────────
    needs_gemma3 = (
        args.task in {"edit", "refactor", "debug", "test", "implement"}
        and gemma3_ast is None
        and not args.dry_run
    )
    if needs_gemma3:
        file_context = read_file_context(args.file)
        try:
            gemma3_ast = call_gemma3_edit(
                args.prompt, file_context, bigrams, max_tokens=args.max_tokens
            )
            validate_gemma3_ast(gemma3_ast)
        except Exception as e:
            print(f"warning: Gemma 3 edit AST failed ({e}); falling back to generate mode",
                  file=sys.stderr)
            gemma3_ast = None

    # ── Yax: compile IR ───────────────────────────────────────────────────────
    ir = compile_ir(lang_binding, args.file, bigrams, gemma3_ast, args.task)

    # ── Sek: generate proposal ────────────────────────────────────────────────
    proposal = generate_proposal(ir, args.task)

    output = {
        "schema": "codegen-mu.output.v1",
        "authority": "candidate_only",
        "model": MODEL.name if needs_gemma3 else None,
        "task": args.task,
        "language": lang,
        "corpus_records": lang_binding["records"],
        "bigrams_matched": len(bigrams),
        "proposal": proposal,
    }
    if output["model"] is None:
        del output["model"]

    out = json.dumps(output, ensure_ascii=False, indent=2)
    if args.output:
        args.output.parent.mkdir(parents=True, exist_ok=True)
        args.output.write_text(out + "\n", encoding="utf-8")
        print(f"wrote proposal -> {args.output}")
    else:
        print(out)


if __name__ == "__main__":
    main()
