---
name: codegen-mu
description: CODEGEN-µ pipeline — bigram-keyed code generation and edit proposals via Gemma 3. Use when asked to generate, edit, refactor, debug, or test code using the local pipeline. Produces candidate_only GeneratedCodeProposals; XCFE Ch'en admission required before any file write.
---

# CODEGEN-µ

Code generation and edit proposals via bigram corpus (155 763 records across 10 domains) and Gemma 3 1B local inference. All output is `candidate_only`; nothing touches the file system without XCFE admission.

---

## Invoke the pipeline

```powershell
# From an attachment (any subset of fields; CLI args override)
python scripts/codegen-mu.py --attach path/to/edit-task.json

# From CLI — edit (calls Gemma 3 for the AST)
python scripts/codegen-mu.py "replace compute_score with faster impl" \
    --file src/xcfe_router.cpp --task edit

# From CLI — generate from bigram corpus only (no model call)
python scripts/codegen-mu.py "compute_score function" --lang cpp --task generate --dry-run

# Pre-computed AST (skip Gemma 3)
python scripts/codegen-mu.py "rename sym" --file src/pop.cpp --task edit \
    --gemma3-ast ast.json

# Write proposal to file
python scripts/codegen-mu.py --attach task.json --output build/io/proposals/edit.json
```

**Flags:**

| Flag | Default | Purpose |
|------|---------|---------|
| `--attach PATH` | — | CodeTask JSON file (any subset of fields) |
| `--file PATH` | — | target source file (overrides attachment) |
| `--lang` | auto from ext | cpp py h json html js ts hlsl kxml css |
| `--task` | edit | generate \| edit \| refactor \| debug \| test \| implement |
| `--gemma3-ast PATH` | — | pre-computed edit AST JSON (overrides attachment gemma3 field) |
| `--dry-run` | false | skip Gemma 3; compile from bigrams only |
| `--top-k N` | 5 | bigram corpus matches to retrieve |
| `--max-tokens N` | 384 | Gemma 3 token budget |
| `--output PATH` | stdout | write JSON proposal to file |

---

## Attachment format (CodeTask)

Any subset of fields. CLI args override what the attachment supplies.

```json
{
  "op":       "code.edit",
  "task":     "edit",
  "language": "cpp",
  "file":     "src/xcfe_router.cpp",
  "prompt":   "replace compute_score with a faster implementation",
  "gemma3": {
    "op":     "replace_function",
    "name":   "compute_score",
    "body":   "float compute_score(float w, float c) { return w * c; }",
    "reason": "inline multiply is faster than the lookup table"
  }
}
```

`op` strings map to tasks: `code.edit→edit`, `code.generate→generate`, `code.refactor→refactor`, `code.debug→debug`, `code.test→test`, `chat.generate→generate`.

---

## Edit ops (Gemma3EditAST shapes)

| op | Required fields | Locator fields |
|----|----------------|----------------|
| `replace_function` | `name`, `body` | — |
| `replace_expression` | `scope`, `old_expr`, `new_expr` | — |
| `insert_block` | `after` (Locator), `content` | `after.kind`, `after.name` |
| `delete_node` | `target` (Locator) | `target.kind`, `target.name` |
| `rename_symbol` | `from`, `to`, `scope` (Locator) | `scope.kind`, `scope.name` |
| `add_parameter` | `function`, `param_type`, `param_name` | — |
| `modify_field` | `target` (Locator), `new_value` | `target.kind`, `target.name` |

Locator `kind` values: `function` `class` `method` `block` `expr` `field` `namespace` `file`

---

## Output

```json
{
  "schema": "codegen-mu.output.v1",
  "authority": "candidate_only",
  "task": "edit",
  "language": "cpp",
  "corpus_records": 56176,
  "bigrams_matched": 5,
  "proposal": {
    "schema": "codegen-mu.proposal.v1",
    "candidate_only": true,
    "xcfe_required": true,
    "authority": "candidate_only",
    "ir_op": "replace_function",
    "language": "cpp",
    "file": "src/xcfe_router.cpp",
    "locator": { "kind": "function", "name": "compute_score" },
    "content": "float compute_score(float w, float c) { return w * c; }",
    "diff_preview": "Replace function compute_score: float compute_score...",
    "route": "CODEGEN:edit · LANG:cpp · TRACK:CODEGEN-µ",
    "reason": "inline multiply is faster than the lookup table"
  }
}
```

`candidate_only: true` and `xcfe_required: true` are always set. The proposal is never an invocation.

---

## Grammar files

| File | Phase | Role |
|------|-------|------|
| `data/grammar/codegen-mu.runtime.ebnf` | all | orchestrator surface syntax, type inventory, delegation |
| `data/grammar/codegen-mu.parser.ebnf` | Pop | CodeTask + Gemma3EditAST input shapes, structural constraints |
| `data/grammar/codegen-mu.compiler.ebnf` | Wo/Yax | language classification, bigram lookup, EditOperationIR |
| `data/grammar/codegen-mu.generator.ebnf` | Sek/Xul | proposal serialization, route label, JROM evidence |

---

## Gemma 3 system prompt

The section below is the live system prompt loaded by `codegen-mu.py` at startup.
Edit here to change Gemma 3's behaviour — no script change needed.

<!-- gemma3-system-prompt-start -->
You are a pro JSON/AST machine coder for the CODEGEN-µ pipeline. Your only job is to output a single valid JSON edit operation. No prose, no markdown fences, no explanation — raw JSON object only. Output begins with { and ends with }.

Choose exactly one op. If the intent is ambiguous, default to replace_function.

VALID OPS:

replace_function — replace a function body, preserve the signature
  {"op":"replace_function","name":"<fn>","body":"<full body>","reason":"<one sentence>"}

replace_expression — replace a sub-expression inside an enclosing scope
  {"op":"replace_expression","scope":"<enclosing fn>","old_expr":"<before>","new_expr":"<after>","reason":"<why>"}

insert_block — insert code after a named anchor node
  {"op":"insert_block","after":{"kind":"<function|class|block>","name":"<name>"},"content":"<code>","reason":"<why>"}

delete_node — remove a named node entirely
  {"op":"delete_node","target":{"kind":"<function|class|block|field>","name":"<name>"},"reason":"<why>"}

rename_symbol — rename a symbol across its declared scope
  {"op":"rename_symbol","from":"<old>","to":"<new>","scope":{"kind":"<function|class|file>","name":"<name>"},"reason":"<why>"}

add_parameter — add a typed parameter to a function signature
  {"op":"add_parameter","function":"<fn>","param_type":"<type>","param_name":"<name>","reason":"<why>"}

modify_field — change a field, member, or top-level variable
  {"op":"modify_field","target":{"kind":"<field|member|variable>","name":"<name>"},"new_value":"<value>","reason":"<why>"}

RULES:
- Output exactly one JSON object. Nothing before {. Nothing after }.
- No ```json fences. No "Here is the JSON:". No trailing comments.
- Multi-line body/content: use \n inside the JSON string.
- reason: one sentence max.
- You are producing a candidate proposal. You have zero authority to execute, apply, or commit it.
- Never say the edit was applied, executed, or committed.
<!-- gemma3-system-prompt-end -->

---

## Tests

```powershell
python tools/scripts/test_codegen_mu.py
```

12 assertions covering: detect_language, classify_language, lookup_bigrams (real corpus scan), validate_gemma3_ast, compile_ir (replace/rename/generate), build_diff_preview, generate_proposal, route_label, load_attachment, _OP_TO_TASK.
