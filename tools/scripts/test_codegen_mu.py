"""Tests for scripts/codegen-mu.py — pure-Python paths only (no Gemma 3 calls)."""
import json
import sys
import pathlib

import importlib.util

ROOT = pathlib.Path(__file__).resolve().parents[2]

_spec = importlib.util.spec_from_file_location(
    "codegen_mu", ROOT / "scripts" / "codegen-mu.py"
)
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)

detect_language    = _mod.detect_language
classify_language  = _mod.classify_language
lookup_bigrams     = _mod.lookup_bigrams
validate_gemma3_ast = _mod.validate_gemma3_ast
compile_ir         = _mod.compile_ir
build_diff_preview = _mod.build_diff_preview
generate_proposal  = _mod.generate_proposal
route_label        = _mod.route_label
LANGUAGE_MAP       = _mod.LANGUAGE_MAP


# ── 1. detect_language ────────────────────────────────────────────────────────

assert detect_language(None, "cpp") == "cpp"
assert detect_language(None, "py") == "py"
assert detect_language(pathlib.Path("foo.cpp"), None) == "cpp"
assert detect_language(pathlib.Path("bar.hpp"), None) == "h"
assert detect_language(pathlib.Path("baz.mjs"), None) == "js"
assert detect_language(pathlib.Path("x.ts"), None) == "ts"

try:
    detect_language(None, "cobol")
    raise AssertionError("unknown lang accepted")
except ValueError:
    pass

try:
    detect_language(None, None)
    raise AssertionError("no file or lang accepted")
except ValueError:
    pass

print("PASS detect_language")


# ── 2. classify_language ──────────────────────────────────────────────────────

for lang, (corpus, records) in LANGUAGE_MAP.items():
    binding = classify_language(lang)
    assert binding["id"] == lang
    assert binding["corpus"] == corpus
    assert binding["records"] == records

cpp_b = classify_language("cpp")
assert cpp_b["records"] == 56176

print("PASS classify_language")


# ── 3. lookup_bigrams (cpp corpus, real scan) ─────────────────────────────────

cpp_binding = classify_language("cpp")
hits = lookup_bigrams(cpp_binding, "compute_score function", top_k=5)
assert isinstance(hits, list)
assert len(hits) <= 5
if hits:
    assert "key" in hits[0]
    assert "text" in hits[0]
    assert "domain" in hits[0]
    # all hits should be cpp domain
    for h in hits:
        assert h.get("domain") == "cpp", f"unexpected domain: {h.get('domain')}"

# empty prompt → no crash, empty list
empty_hits = lookup_bigrams(cpp_binding, "!!! @@@", top_k=5)
assert isinstance(empty_hits, list)

# py corpus
py_binding = classify_language("py")
py_hits = lookup_bigrams(py_binding, "encode vector", top_k=3)
assert isinstance(py_hits, list)
if py_hits:
    for h in py_hits:
        assert h.get("domain") == "py"

print(f"PASS lookup_bigrams (cpp hits={len(hits)}, py hits={len(py_hits)})")


# ── 4. validate_gemma3_ast ────────────────────────────────────────────────────

validate_gemma3_ast({"op": "replace_function", "name": "foo", "body": "int foo() {}"})
validate_gemma3_ast({"op": "insert_block", "after": {"kind": "function", "name": "init"},
                     "content": "// new"})
validate_gemma3_ast({"op": "delete_node", "target": {"kind": "function", "name": "old"}})
validate_gemma3_ast({"op": "rename_symbol", "from": "a", "to": "b",
                     "scope": {"kind": "function", "name": "process"}})

try:
    validate_gemma3_ast({"op": "unknown_op"})
    raise AssertionError("unknown op accepted")
except ValueError:
    pass

try:
    validate_gemma3_ast({"op": "rename_symbol", "from": "x", "to": "x",
                         "scope": {"kind": "file", "name": ""}})
    raise AssertionError("from==to accepted")
except ValueError:
    pass

try:
    validate_gemma3_ast({"op": "replace_function", "name": "", "body": "..."})
    raise AssertionError("empty name accepted")
except ValueError:
    pass

print("PASS validate_gemma3_ast")


# ── 5. compile_ir — replace_function ─────────────────────────────────────────

cpp_binding = classify_language("cpp")
ast_replace = {"op": "replace_function", "name": "compute_score",
               "body": "float compute_score(float w) { return w; }", "reason": "simplify"}
ir = compile_ir(cpp_binding, pathlib.Path("src/sek.cpp"), hits[:3], ast_replace, "edit")

assert ir["ir_op"] == "replace_function"
assert ir["language"] == "cpp"
assert ir["file"] == str(pathlib.Path("src/sek.cpp"))
assert ir["candidate_only"] is True
assert ir["locator"]["kind"] == "function"
assert ir["locator"]["name"] == "compute_score"
assert "compute_score" in ir["content"]
assert ir["reason"] == "simplify"

print("PASS compile_ir replace_function")


# ── 6. compile_ir — rename_symbol ────────────────────────────────────────────

ast_rename = {"op": "rename_symbol", "from": "old_fn", "to": "new_fn",
              "scope": {"kind": "function", "name": "process"}, "reason": "clarity"}
ir_r = compile_ir(cpp_binding, pathlib.Path("src/wo.cpp"), [], ast_rename, "refactor")

assert ir_r["ir_op"] == "rename_symbol"
assert ir_r["from"] == "old_fn"
assert ir_r["to"] == "new_fn"
assert ir_r["candidate_only"] is True

print("PASS compile_ir rename_symbol")


# ── 7. compile_ir — generate (no gemma3 ast) ─────────────────────────────────

ir_gen = compile_ir(cpp_binding, None, hits[:3], None, "generate")

assert ir_gen["ir_op"] == "generate"
assert ir_gen["candidate_only"] is True
assert ir_gen["task"] == "generate"
assert isinstance(ir_gen["bigrams"], list)

print("PASS compile_ir generate")


# ── 8. build_diff_preview ────────────────────────────────────────────────────

preview_replace = build_diff_preview({
    "ir_op": "replace_function",
    "locator": {"kind": "function", "name": "foo"},
    "content": "int foo() { return 42; }",
})
assert "foo" in preview_replace
assert "Replace function" in preview_replace

preview_rename = build_diff_preview({
    "ir_op": "rename_symbol",
    "locator": {"kind": "function", "name": "scope_fn"},
    "from": "old_x", "to": "new_x",
    "content": "",
})
assert "old_x" in preview_rename
assert "new_x" in preview_rename

preview_delete = build_diff_preview({
    "ir_op": "delete_node",
    "locator": {"kind": "function", "name": "dead_code"},
    "content": "",
})
assert "Delete" in preview_delete
assert "dead_code" in preview_delete

preview_gen = build_diff_preview({
    "ir_op": "generate",
    "locator": {"kind": "file", "name": ""},
    "bigrams": [{"key": "my_bigram"}],
    "language": "cpp",
    "task": "test",
})
assert "my_bigram" in preview_gen
assert "test" in preview_gen

print("PASS build_diff_preview")


# ── 9. generate_proposal ─────────────────────────────────────────────────────

proposal = generate_proposal(ir, "edit")
assert proposal["schema"] == "codegen-mu.proposal.v1"
assert proposal["candidate_only"] is True
assert proposal["xcfe_required"] is True
assert proposal["authority"] == "candidate_only"
assert proposal["ir_op"] == "replace_function"
assert proposal["language"] == "cpp"
assert "CODEGEN:edit" in proposal["route"]
assert "LANG:cpp" in proposal["route"]
assert "TRACK:CODEGEN-" in proposal["route"]
assert isinstance(proposal["diff_preview"], str)
assert len(proposal["diff_preview"]) > 0

proposal_gen = generate_proposal(ir_gen, "generate")
assert "CODEGEN:generate" in proposal_gen["route"]
assert "bigram_key" in proposal_gen

print("PASS generate_proposal")


# ── 10. route_label ───────────────────────────────────────────────────────────

for task, verb in [("edit","edit"), ("refactor","refactor"),
                   ("debug","debug"), ("test","test"), ("generate","generate"),
                   ("implement","edit")]:
    lbl = route_label(task, "py")
    assert f"CODEGEN:{verb}" in lbl
    assert "LANG:py" in lbl
    assert "TRACK:CODEGEN-" in lbl

print("PASS route_label")


print("\nAll codegen-mu tests passed.")
