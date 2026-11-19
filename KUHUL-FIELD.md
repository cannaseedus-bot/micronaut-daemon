# KUHUL-FIELD.md

Tracking reference for the K'UHUL phase field: how the phase cycle, key grammar
(⟁KEY fields), CFPC accumulator, and fold delta/direction system connect.

---

## 1. The Phase Cycle

The K'UHUL phase cycle is a C6 cyclic group: **Pop → Wo → Yax → Sek → Ch'en → Xul → (Pop)**.
Phase position `θ ∈ ℤ₆`. Arc weight between any two adjacent phases = `cos(π/3) = 0.5`.

| θ | Phase | Default verb | Role | Ops |
|---|-------|-------------|------|-----|
| 0 | Pop | @read | Reset / corpus entry | 13 |
| 1 | Wo | @delegate | Intake / ana gate | 6 |
| 2 | Yax | @compose | Admission / WCR | 7 |
| 3 | Sek | @call | Proposal / transform | 14 |
| 4 | Ch'en | @verify | Proof / evidence | 10 |
| 5 | Xul | @commit | Commit / cata gate | 8 |

**Foundational semantics (FS14/FS15):**
- **FS14** — Fold ≠ Xul. The fold path and the commit gate are separate events.
- **FS15** — Sek proposes, Ch'en proves, XCFE authorizes, Xul commits.

**Hylomorphism:**
- Wo = ana gate (unfold): opens the recursive structure from the seed query Q.
- Xul = cata gate (fold): collapses the structure into the committed answer A.
- The C6 cycle is a hylomorphism with a 6-phase proof-obligation gap between ana and cata.

**SEK_PI_RADIUS kernel (glyph ⊙, `pi_radius.cpp`):** Only executes while `kuhul::phase::Name == Sek`. Phase-locked. Augments `compute_over_admitted_structure` with π-geometry weights from the `pi_triangle_config` set by Yax's `pi_triangle_route`.

---

## 2. Phase Drivers (JSON Contracts)

Each phase has a driver JSON file in `data/drivers/phases/`. The process server reads
`ops[]` and fires them in order. These files are the **execution contract** layer —
distinct from the semantic/bot layer (AIML) and the K'UHUL program layer (.khl).

**Files:** `pop.json`, `wo.json`, `yax.json`, `sek.json`, `chen.json`, `xul.json`
**Consolidated:** `phase-drivers.v2.json`

Each driver specifies: `phase`, `phase_order`, `theta`, `default_verb`, `ops[]`,
optional `channels[]`, optional `terminal` flag. All files are v2.

Semantic channels add weighted parallel op pipelines:
- **Pop** has 5 channels: `word_sense_disambiguation` (w=1.05), `distributional_context`,
  `function_gram`, `tool_gram`, `typed_runtime_lanes`.
- **Sek** has 1 channel: `high_confidence_miss` (w=1.15) with `miss_kind_routing`.

---

## 3. The Process Server Pattern — JSON + AIML as Semantic Pydantic Deltas

The phase driver JSON files and AIML files are two layers of the same contract stack.
The analogy to Python + Pydantic is exact:

```
Pydantic BaseModel  ←→  Phase driver JSON
Python runtime      ←→  Process server (Python/PowerShell/C++)
Pydantic .validate()←→  Ch'en validate() / CF1–CF9
```

A **Pydantic model** defines the shape, field types, and constraints of a data structure.
It is a typed contract — but it does nothing on its own. A Python runtime must
instantiate it, validate inputs against it, and execute the program logic that uses it.
The model is not the program; it is the schema the program is written against.

A **phase driver JSON file** is the same thing for a semantic fold cycle. It declares:
- the ops[] that must fire, in order
- the channel weights and routing rules
- the authority flags (`candidate_only`, `terminal`, `default_verb`)

Without a process server reading the file and firing ops[], the JSON is a typed spec —
no different from a REST API schema document that requires a server to handle requests.
**The JSON driver is the contract; the process server is the runtime.**

The **AIML files** sit one layer above: they are the semantic/conversational interface
to the same ops. Where the JSON driver says `"op": "emit_fold_delta_proposal"`, the
AIML file provides a `<pattern>WHAT IS EMIT FOLD DELTA PROPOSAL</pattern>` category
that a bot or daemon program can answer. The AIML layer makes the contract legible to
semantic programs (bots, agents, routers) the same way docstrings make a Pydantic model
legible to developers.

**The three-layer stack:**

| Layer | Artifact | Role | Requires |
|-------|----------|------|----------|
| Program | `.khl` (kuhul.atomic) | K'UHUL program in phase-bracket syntax | khl interpreter / XCFE runtime |
| Contract | `*.json` (phase drivers) | Typed op schema per phase | Process server to fire ops |
| Semantic | `*.aiml` (per-phase files) | Conversational interface to ops | AIML interpreter / daemon bot |

**Pydantic delta analogy extended:**

A Pydantic model with a delta pattern — where each field is a `ΔValue` from a prior
state — is exactly a `FoldDelta`. `FoldDelta = ⟨ΔM, ΔRelations, ΔW, ΔC⟩` is not an
execution command; it is a **typed proposal** (the `verdict` field gates ingestion).
The process server (DirectionStore.ingest()) validates the delta, checks `verdict ==
"GOOD"`, and only then applies it — the same way a Pydantic model's `.validate()` runs
before the application logic touches the data.

`CFPCQuestionFoldAccumulator.validate()` (CF1–CF9) is the equivalent of Pydantic's
field-level validators running at Ch'en before Xul commits — `semantic_authority` and
`dispatch` are always `false` by invariant, which maps directly to a Pydantic field
declared `Literal[False]`.

The whole system is a layered contract stack: programs call contracts call servers call
validators. Nothing executes authority without passing through the validator chain.

---

## 4. AIML / Semantic Layer

Per-phase AIML files in `data/alice/` provide the conversational/bot layer — one AIML
category per driver op. They answer questions about phase semantics, not about execution.

| File | Sections | Contents |
|------|----------|----------|
| `pop.aiml` | §POP-A/B/C | Phase def, 13 ops, 5 channel patterns |
| `wo.aiml` | §WO-A/B/C | Phase def, 6 ops, ana gate patterns |
| `yax.aiml` | §YAX-A/B/C | Phase def, 7 ops, WCR pipeline patterns |
| `sek.aiml` | §SEK-A/B/C/D | Phase def, 14 ops, high_confidence_miss, ⊙ kernel |
| `chen.aiml` | §CHEN-A/B/C/D | Phase def, 10 ops, CFPC CF1–CF9 patterns, local-max stall |
| `xul.aiml` | §XUL-A/B/C | Phase def, 8 ops, cata gate / FS14/FS15 patterns |
| `kuhul-phases.aiml` | cross-cutting | C6 cycle navigation, theta lookup, FS14/FS15 |

The `.khl` format (`kuhul.atomic.khl`) is the **K'UHUL program layer**: phase-bracket
syntax (`[Pop name]`, `[Sek op]`, etc.) that IS the K'UHUL program, not prose about it.

---

## 5. The ⟁KEY Field Vocabulary

19 total keys; sourced from `cfpc_accumulator.cpp` → `FIELD_KEY_VOCAB[]`.

**11 domain keys:**
`⟁EDUCATION` `⟁TEACHER` `⟁STUDENT` `⟁EVENTS` `⟁COUNTRY` `⟁TECHNOLOGY`
`⟁ENERGY` `⟁WASTE` `⟁NUCLEAR` `⟁DANGER` `⟁WARNING`

**8 reasoning keys:**
`⟁CAUSE` `⟁EFFECT` `⟁EVIDENCE` `⟁COMPARISON` `⟁SOLUTION` `⟁HISTORY` `⟁FUTURE` `⟁RISK`

Field keys flow through the pipeline in phase order:
1. **Pop** `key_lane_bind` — binds the prompt vector to eligible ⟁KEY lanes.
2. **Wo** `state_and_constraints` — lane bindings enter the fold's constraint set.
3. **Yax** `resolve_eliza_field_candidates` — candidates tagged with ⟁KEY eligibility.
4. **Sek** `select_eliza_field_candidate` — sets `activated_fields` on the CFPC accumulator.
5. **Ch'en** CF9 — validates all `field_key` values are in FIELD_KEY_VOCAB.

---

## 6. field-factory (Semantic Field Generator)

**`field-factory/field-factory.py`** — CLI tool that generates a 10-level semantic field
JSON + XAIML pattern bank from a subject word + relations.

**8 field dimensions → phase mapping:**

| Dimension | Phase |
|-----------|-------|
| identity | Pop |
| gradient | Wo |
| bias | Yax |
| topology | Sek |
| sensory | Sek |
| temporal | Ch'en |
| spatial | Ch'en |
| operational | Xul |

Output files: `<subject>-field.factory.json` (10-level field, coordinates ⟁KEY→⟁JROM),
`<subject>-semantic-field.factory.xaiml` (XAIML pattern bank).

**`kuhul-field.factory.json`** is the meta-field: ⟁KUHUL described using its own coordinate
system. 10 coordinates, 8 fieldDimensions (1–8), 2 evaluationDimensions (9–10).

The runtime uses field-factory output for Yax field resolution. The CFPC accumulator
only validates downstream (CF9) — it does not invoke field-factory directly.

---

## 7. CFPC Accumulator

**`cfpc_accumulator.h` / `cfpc_accumulator.cpp`** — namespace `khanary::kuhul`.

A `CFPCQuestionFoldAccumulator` is a question-proposal record opened across the full
phase cycle. It is never execution-authority (`semantic_authority=false`,
`dispatch=false` — permanent).

**Lifecycle by phase:**
- **Pop** — fold_id / pattern_id / subject bound.
- **Wo** — gap_state initialized.
- **Sek** — `map_cfpc_question_candidate` → `filter_cfpc_question_candidates` →
  `rank_cfpc_question_candidates` → `fold_cfpc_question_set` populates `candidates[]` and
  `activated_fields[]`.
- **Ch'en** — `validate()` runs CF1–CF9.
- **Xul** — emits the validated record.

**Gap states:** `IntentGap` → `QueryGap` → `KnowledgeGapNoKeys` → `KnowledgeGapNoValues` → `Resolved`

**CF1–CF9 validate() checks** (source: `cfpc_accumulator.cpp`, first failure returned):

| Code | Error name | Check |
|------|------------|-------|
| CF1 | `CF_SCHEMA_INVALID` | `schema == "kuhul.cfpc-question-fold.v1"` |
| CF2 | `CF_MISSING_FIELD` | `fold_id`, `pattern_id`, `subject` all non-empty |
| CF3 | `CF_SEMANTIC_AUTHORITY_UNAUTHORIZED` | `semantic_authority == false` |
| CF4 | `CF_DISPATCH_UNAUTHORIZED` | `dispatch == false` |
| CF5 | `CF_PATTERN_ID_INVALID` | `pattern_id` in `pattern_id_vocabulary` |
| CF6 | `CF_GAP_STATE_INVALID` | `gap_state` ∈ 0–4 |
| CF7 | `CF_CANDIDATE_TEXT_EMPTY` | every candidate has non-empty `instantiated` |
| CF8 | `CF_NO_CANDIDATES` | `candidates` list non-empty |
| CF9 | `CF_FIELD_KEY_INVALID` | if `activated_fields` non-empty, all `field_key` ∈ FIELD_KEY_VOCAB |

CF9 is vacuously satisfied when `activated_fields` is empty.

---

## 8. FoldDelta and FoldDirection

**`fold_delta.h`** — the learned proposal record.

```
FoldDelta = ⟨ΔM, ΔRelations, ΔW, ΔC⟩
```
Fields: `verdict` (must be `"GOOD"` to ingest), `phase_position` (provenance only —
never authorization), `next_phase`, `jrom_seq` (JROM journal sequence number).

`canonical_fold_phase_position()` normalizes `"Chen"` → `"Ch'en"`.

**`fold_direction.h` / `fold_direction.cpp`** — the aggregate direction record.

A `FoldDirection` groups multiple GOOD `FoldDelta` entries by `micronaut_id`:
- `capability_key`: sorted union/consensus of verified capability tokens.
- `governs_key`: governance scope.
- `W = 1.0f`, `C = 0.5f` — neutral priors held deliberately (GOOD-only ingest would
  create a ratchet; priors stay neutral until XCFE authorizes parameter updates).
- `source_jrom_seqs[]`, `episode_count`, `last_updated`.

**`DirectionStore`** operations:
- `ingest(fold_delta)` — idempotent on `jrom_seq`; GOOD verdict required.
- `rebuild_from_jrom(journal)` — replay primitive; re-derives store from JROM journal.
- `query(Q, caps)` — WCR ranking: `S = W * C * R` (R = Jaccard(query_caps, capability_key)).
- `query_at_phase(Q, caps, phase_key)` — adds phase filter.
- `get(id)`, `list()`, `size()`.

The same `S = W * C * R` algebra appears in DirectionStore, Yax WCR pipeline,
and CFPC candidate ranking.

---

## 9. JROM Journal

FoldDeltas are serialized into the JROM journal as JSON entries with `jrom_seq`.
`rebuild_from_jrom()` replays the journal to re-derive the DirectionStore.

Provenance chain: **FoldDirection → FoldDelta → Episode**.

`store_rejected_candidate_evidence` (Ch'en op 10) writes rejected proposals to the
bounded candidate evidence store — not discarded, not promoted. Available for future
cycle replay.

---

## 10. How the Layers Connect

```
field-factory.py
  └─ generates kuhul-field.factory.json (field coordinates)
       └─ Yax: resolve_eliza_field_candidates (runtime resolves fields)
            └─ Sek: select_eliza_field_candidate → activated_fields set
                 └─ Ch'en: validate() CF9 → field_key ∈ FIELD_KEY_VOCAB

phase-drivers.v2.json (execution contract)
  └─ process server fires ops[] in phase order
       ├─ Pop (13 ops): read, vectorize, key_lane_bind
       ├─ Wo (6 ops): intake, constraints, auth check
       ├─ Yax (7 ops): WCR admission → V_mu
       ├─ Sek (14 ops): propose → emit_fold_delta_proposal → CFPC fold
       ├─ Ch'en (10 ops): verify → CFPC validate() CF1–CF9 → store_rejected
       └─ Xul (8 ops): compare_and_commit → record_phase_evidence → emit_answer

FoldDelta (Sek emit_fold_delta_proposal)
  └─ JROM journal (jrom_seq provenance)
       └─ DirectionStore.ingest() — GOOD verdict only
            └─ DirectionStore.query() — W*C*R ranking
                 └─ Xul: update_authorized_metric_parameters (if XCFE authorized)

CFPC accumulator (Sek → Ch'en → Xul)
  └─ candidates[] + activated_fields[] populated at Sek
  └─ validate() CF1–CF9 at Ch'en
  └─ emitted at Xul as question-proposal record
  └─ rejected records → store_rejected_candidate_evidence (Ch'en op 10)
```

**Key distinction:** phase_position on a FoldDelta is **provenance** (where the delta
originated), not **authorization**. Only XCFE Ch'en admission and Xul commit confer
authorization. FS15 is the invariant.

---

## 11. kuhul-es — The KHL Runtime

**`tools/trainer-dashboard/kuhul-es/`** — kuhul-es v1.7.0. This is the KHL system the
key grammar kit uses. The core insight: **the binary contract formats (KHL/1, KAST/1,
KFOLD/1, XCFE/1, KXML/1) are AIML + XML + K'UHUL phases combined** — each one is a
typed reformulation of an AIML/XML construct through the C6 phase cycle.

---

### The TypeScript Interpreter

The KHL interpreter is built **on top of the TypeScript compiler API**.
`compiler/src/parser.js` (`KUHULParser`) calls `ts.createSourceFile()` to parse
K'UHUL-ES source as a TypeScript AST, then walks it to extract:

- **`π` / `pi` bindings** — immutable constants (`π x = value`). Frozen with
  `Object.freeze`. Phase-law: π binds once at Pop and never changes.
- **`τ` / `tau` bindings** — temporal mutable state (`τ x = value`). Can update
  across phase steps. Phase-law: τ flows through the cycle, τ at Xul is the commit.
- **Glyph calls** — `yield*` expressions: `yield* Sek('log', message)`,
  `yield* Pop(...)`, `yield* Ch'en(...)`. The `yield*` syntax makes phase calls
  generators — the runtime can pause/resume at each phase boundary.

`runtime/src/runtime_parser.js` wraps `KUHULParser` and adds expression evaluation
(`ExpressionEvaluator`) so variable references, string concatenation, and member
access work at runtime. The TypeScript compiler is the lexer/parser; the runtime
adds the semantic execution layer on top.

---

### The Binary Contract Grammars — AIML + XML + K'UHUL Phases

Each grammar in `grammars/` is a typed reformulation of an AIML/XML concept:

**KHL/1** (`khl-rom-1.ebnf`) — the executable ROM format for `sw.khl`.
Block-based: `[GlyphName value]` → `BlockBody` → `[Xul]`.
AIML analogue: `<category><pattern>…</pattern><template>…</template></category>`.
In KHL/1 each block IS a category — the phase glyph is the structural wrapper instead
of XML tags. Control flow: `[@loop]`, `[@if]/@then/@else`, `[@dispatch]/@case`,
`[@microagent]/@agent.spawn/@agent.assign_task/@agent.execute/@agent.merge_results`.

**KAST/1** (`kast-1.ebnf`) — canonical JSON AST output. Protocol field `"kast/1"`.
Nodes carry `glyph` (phase name), `opcode`, `operands`, `phase`.
Edges carry `kind`: `control | data | sequence | admission | semantic`.
AIML analogue: the parsed AIML category tree — KAST/1 is what the AIML XML DOM
becomes when expressed as a phase-labelled JSON graph. `semantic_hash` is the
content fingerprint.

**KFOLD/1** (`kfold-1.ebnf`) — lazy semantic fold graph. `folds[]` keyed by phase,
each fold has `nodes[]` in lanes with `admitted`, `latent`, `collapsed` states.
`unfolds[]` with gate types: `always | capability | pressure | confidence | dependency | explicit`.
AIML analogue: the SRAI chain — `<srai>` is an unfold from one category to another.
KFOLD/1 makes that lazy graph explicit, typed, and gated. The KXML driver converts
`kxml/model` forward graphs → KFOLD/1 at runtime.
TypeScript reference implementation: `runtime/src/fold-engine.ts`.
`FoldSchemaState`: `collapsed → admitted → unfolded → executing → committed`
(mirrors Ch'en → Xul in the phase cycle).

**XCFE/1** (`xcfe-1.ebnf`) — execution control flow enforcement.
Three vector types: `@control.*` (choose), `@flow.*` (sequence), `@variable.*` (store).
Driver contracts: `@driver id { @control: …, @flow: …, @admit: … }`.
AIML analogue: `<condition>`, `<set>`, `<get>`, `<think>` — XCFE/1 is those AIML
state-manipulation tags expressed as typed enforcement vectors.
Invariant (in grammar): "Only K'UHUL can enforce, only Micronaut can control."

**KXML/1** (`kxml-1.ebnf`) — K'UHUL XML inference grammar. Three forms:
- `kxml/model` — forward inference graph (layers, ports, weights, template strings).
  AIML analogue: an AIML brain file with `<category>` entries that have weight refs.
- `kxml/chat` — tool-aware Jinja template with `tools[]` declarations.
  AIML analogue: an AIML `<template>` with `<condition>` tool dispatch.
- `kxml/render` — prompt rendering call with `template_file` + `context`.
  AIML analogue: `<srai>` to a template category with predicate context.

**XJSON/1** (`xjson-1.ebnf`) — JSON extended with semantic `@`-keys:
`@context`, `@v`, `@law`, `@entity`, `@control`, `@flow`, `@view`, `@variable`,
`@id`, `@type`. Plus `AtomicBlock` annotations. AIML analogue: AIML predicates
(`<get>`/`<set>`) expressed as typed JSON semantic metadata.

---

### ELIZA Connection

`runtime/src/pattern_reasoner.js` explicitly inherits the ELIZA lineage:

> "Uses an ELIZA-style pattern→transform pipeline, but for reasoning about semantic
> execution (folds, nodes, metrics, training state), not therapy."

Patterns are PCRE2-compatible regex with backrefs and lookarounds. The `transform`
function maps a match to a `{proposition, confidence}` — the same shape as a CFPC
candidate. PCRE2 WASM is the browser fallback when native PCRE2 is unavailable.
This is the pattern reasoner that feeds the phase-gated fold execution.

---

### Plugin System

kuhul-es is built to be plugged into. External projects (including the Micronaut Daemon)
connect through three surfaces:

**Research plugins** — `KUHULEngine.registerResearch(name, fn)`. Called during the fold
query to fetch domain evidence. Returns `{source, content, confidence, type}`.

**Response patterns** — `KUHULEngine.registerPattern(id, config)`. ELIZA-style
trigger→template+branch with per-domain `weight`. Built-in patterns: `troubleshoot`,
`symptom`, `poem`, `fallback`. Built-in domains: `tech`, `medical`, `legal`,
`creative`, `general` — each with a phase-glyph subset, response patterns, research
hooks, and attention weights over sources.

**Domain stack** — `engine.switchDomain(id)`. Domains declare which phase glyphs they
use: `tech` → `[Pop, Sek, Ch'en]`, `medical` → `[Wo, Sek, Ch'en, Xul]`, etc.
This is the kuhul-es-side expression of the phase field: each domain is a phase-subset
view of the C6 cycle.

**Compute transport plugins** — four transports in `runtime/src/transports/`:

| Transport | File | Backend |
|-----------|------|---------|
| `botsTransport` | `bots_transport.js` | `bots.py` JSONL subprocess — resident models |
| `powernautGlslTransport` | `powernaut_glsl_transport.js` | Powernaut GLSL Server |
| `xvmD3d12Transport` | `xvm_d3d12_transport.js` | XVM D3D12 compute |
| `hybridClusterGlslTransport` | `hybrid_cluster_glsl_transport.js` | Hybrid cluster GLSL |

**`bots_transport.js` phase→model routing** — the most direct expression of the phase
field as a compute allocation:

| Phase | Model | Memory | Role |
|-------|-------|--------|------|
| Pop / Yax / Ch'en | `gemma_complete_mem` — Gemma 1B Q8 | 1020 MB | Perceive / validate / commit |
| Sek / Xul | `mini_chat` — GPT-2 Q8 | 386 MB | Generate / collapse to answer |
| Wo | `mini_tool_read` — GPT-2 Q2K | 80 MB | Plan / format tool results |

`bots.py` spawns once as a persistent JSONL subprocess; a promise queue serialises
concurrent fold phase requests so they don't interleave (1486 MB total resident).

**Micronaut Daemon integration** — the daemon plugs into kuhul-es via
`runtime/src/micronaut_bridges.js` and `MicronautFactory.fromXjsonFile()`.
Each `.xjson` model definition is a kuhul-es plugin contract: it declares phases,
field bindings, and dispatch routes that the runtime enforces through XCFE/1 vectors.

---

### GitHub

- **Repo:** https://github.com/cannaseedus-bot/KUHUL-ES
- **Clone:** `git clone https://github.com/cannaseedus-bot/KUHUL-ES.git`

Updates: push from `tools/trainer-dashboard/kuhul-es/` or the repo root per project.

---

### sw.khl and the Runtime

**`sw.khl`** — the complete Micronaut and KHL kernel (202 KB legacy / 14 KB current).
Authoritative KHL program in KHL/1 format. The service worker (`sw.js`) loads this
at browser startup for offline chat.

**Unified runtime API:**
```js
kuhul.execute(source, {
  orchestrate: 'micronaut',   // selects and arranges contexts
  enforce:     'kuhul_pi',    // executes phase glyphs, collapses to law
  expand:      'extrapolator' // metaphor/analogy/framing expansions
})
```

Bindings exported from `src/index.js`: `KuhulRuntime`, `KastEngine`, `KxmlEngine`,
`Micronaut`, `Fold`, `Field`, `Tool`, `Gram`, `Agent`, `Rule`, plus full registries
(`MicronautRegistry`, `FoldRegistry`, `FieldRegistry`, `ToolRegistry`, `GramRegistry`).

**Training targets** — `npm run train:native`, `train:webgl2`, `train:webgl2-sweep`,
`train:xshard`. Produces `xshard_info.obj` (native weight archive, 364 KB).
**Browser PWA** — `index.html` + `sw.js` + `manifest.webmanifest`. Offline chat
with PCRE2 WASM regex support.

---

## 12. Jinja Codegen Pipeline

**`templates/aiml_macros.jinja`** — Jinja2 macro library that emits well-formed AIML
from Python dict manifests. Provides `category()`, `srai()`, `star()`, `thatstar()`,
`get()`, `set_predicate()`, `think()`, `random()`, `condition()`, `topic()`,
`render_brain()`. All text/attribute values pass through `xml_escape`. Used by
`render_aiml.py` to generate AIML from manifest data — not from raw strings.

**`build/jinja_source/daemon_basic.aiml`** — example AIML output from the Jinja
pipeline. Canonical test artifact showing HELLO/HI/TELL ME ABOUT/MY NAME IS patterns
plus a `coder` topic with SRAI examples.

**`scripts/codegen-mu.py`** — 3-stage code generation pipeline mapping directly to
phase grammar:

| Stage | Grammar file | Phase | Function |
|-------|-------------|-------|----------|
| Parser | `codegen-mu.parser.ebnf` | Pop/Wo | Input validation — `CodeTask`, `Gemma3EditAST` |
| Compiler | `codegen-mu.compiler.ebnf` | Wo/Yax | Language classification + bigram lookup → `EditOperationIR` |
| Generator | `codegen-mu.generator.ebnf` | Sek | Serialize `EditCandidate` → `GeneratedCodeProposal` |

Tasks: `generate`, `edit`, `refactor`, `debug`, `test`, `implement`. Bigram corpora:
`codegen-cpp.jsonl` (56,176 entries), `codegen-py.jsonl` (42,105 entries).
All output: `authority: candidate_only`. XCFE Ch'en admission required before any edit
reaches the file system.

---

## 13. Gemma Script Layer

Five Python scripts in `scripts/` that form the Gemma inference and field-activation
layer. All output: `authority: model_output_unverified`. Model: `gemma-3-1B-it-QAT-Q4_0.gguf`
via `llama-cli.exe` at `C:\Users\canna\.llama-win-cpu-x64\`.

**`gemma-fields.py`** — On-the-fly ⟁ concept-field activations via EmbeddingGemma 2.
Encodes the prompt, scores against AIML pattern vectors (`pattern_vectors.f32.npy`),
walks `words.manifest.json` to find which ⟁ concept fields each top-k match activates.
Produces the `S(g,c)` column consumed by the ConceptFieldAccumulator.

**`gemma-word-tree.py`** — 3-level word tree for a gram via EmbeddingGemma 2.
Root: query gram. Children: top-k AIML pattern neighbors (by cosine).
Leaves: ⟁ fields, phase tags (`phase:`, `intent:`, `route:`, `ELIZA-`), synonym chains.
Output consumed by the bigram/trigram co-activation layer.

**`gemma3-generate.py`** — Generative layer for three modes:
- `question` — clarifying questions for a CFPC gap → `{"questions": [...]}`
- `pattern` — proposed AIML `<pattern>` string → `{"pattern": "...", "rationale": "..."}`
- `template` — short AIML `<template>` text → `{"template": "..."}`
Takes optional `--fields` (from `gemma-fields.py`) and `--tree` (from `gemma-word-tree.py`).

**`gemma-tools.py`** — Tool and verb reasoning from `data/grammar/gemma-tools.v1.json`
catalog. Answers: which phase a tool runs in, how to call it, what verbs it exposes.
Never invents verb names not in the catalog. Answers are `candidate_only`.

---

## 14. PowerShell Shell Layer

All `.psm1` modules in `shell/`. They form the daemon's PowerShell bus — micronauts
import `micronaut_bindings.psm1` as the base, then expose named wrappers on top.

**`micronaut_bindings.psm1`** — Micronaut bus base. All micronauts call these functions
instead of hardcoding daemon URLs. AIML API: port 3217. AppHost: port 17885.
Fallback: loads `aiml_matcher.psm1` locally if daemon is offline.

**`aiml_matcher.psm1`** — PowerShell AIML pattern matcher. Implements the kuhul/AIML
specificity formula and pattern compilation (`AimlPattern`, `AimlMatch` classes).
Used as local fallback when port 3217 is offline. Integrates with `micronaut_bindings`
via `Invoke-MicronautMatch`.

**`key-grammar-topology.psm1`** — Read-only topology map between grammar assets, bus
routes, and native binaries. Maps `⟁GRAMMAR:*` keys to `{grammar file, bus route, binary}`.
Binaries route to `eliza-µ.exe` (eliza) or `gml.exe`. Checks grammar file presence and
binary hash parity between `build/gml-stage1/Release/` and `bin/`. authority:
`binding_metadata_only`, `executable: false`.

**`GemmaNeural.psm1`** — Local Gemma 3 inference at port 8091. `Invoke-GemmaNeuralCompletion`
(single turn, temperature 0.2), `Invoke-GemmaNeuralContinuation` (with AIML hit context).
Model output carries no source or execution authority.

**`GemmaFallback.psm1`** — Host handoff for verified retrieval miss. Contract hash-pinned
(`gemma-rank-fallback.v1.json`, SHA-256 `e8228f40b6be…`). GEMMA-µ is rank-only;
fires only after verified retrieval + attestation_verified + proposal.mode==fallback.
Explicit `no_verified_answer` response — never invents a retrieval result.

**`factory.psm1`** — Neural factory drafting. `Invoke-MicronautFactoryDraft` calls
GemmaNeural to draft expert bundle proposals (id, purpose, grammar, key_fields,
aiml_entry_patterns, program_roles, evidence_needed, validation_checks).
authority: `proposal_only`, `executable: false`, `registered: false`.

**Per-micronaut binding modules:**

| Module | Micronaut | Port/authority | Role |
|--------|-----------|----------------|------|
| `patterns.bindings.psm1` | PATTERNS-µ | 3213, `xcfe_gated_read_only` | Pattern matching, CFPC intent routing, CHEESE reinforcement |
| `infer.bindings.psm1` | INFER-µ | `proposal_only` | Evidence scoring, Bayesian accumulation, Ch'en provenance |
| `gemma.bindings.psm1` | Gemma bridge | — | Gemma inference bindings |
| `app.bindings.psm1` | App | — | App surface bindings |
| `xjson-ml.bindings.psm1` | XJSON-ML | — | XJSON/ML bindings |
| `graph-theory.bindings.psm1` | Graph | — | Graph theory ops |
| `learn.bindings.psm1` | Learn | — | Learning/update bindings |

**`tools/powershell/`** — Standalone build/diagnostic/test scripts (not bus modules):
`build-cssc-gemm.ps1`, `gemma_bridge_host.ps1`, `gen-guidance.ps1`,
`inspect_gemma_retrieval.ps1`, `render-kuhul-infographic.ps1`,
`test_gemma_rank_fallback.ps1`, `test_micronaut_bus.ps1`, `train-slice.ps1`, etc.

---

## 15. Build Targets

Two separate build output directories with different purposes:

**`build/gml-stage1/Release/`** — Production build. The primary output target.
Contains `eliza-µ.exe` (the main daemon). Referenced by `key-grammar-topology.psm1`
as the canonical binary location. `eliza-µ.exe` only lives here, not in `build/Release/`.

**`build/Release/`** — Development/CMake default build. No `eliza-µ.exe`. Contains
the full test suite plus additional test executables not in the stage1 build:
`test_candidate_evidence_store.exe`, `test_cfpc_accumulator.exe`,
`test_cfpc_sek_ops.exe`, `test_paragraph_accumulator.exe`, `test_sek_para_ops.exe`.

Both builds share: `gml.exe`, `ccc4_infer.exe`, `ccc4_train.exe`,
`chen_vector_plan_cli.exe`, `gemma_bridge_request_cli.exe`, `vector_plan_cli.exe`,
`vector_lane.exe`, `store_write_cli.exe`, `operator_plan_vector.exe`.

The topology: `key-grammar-topology.psm1` checks `build/gml-stage1/Release/<binary>`
vs `bin/<binary>` and reports hash parity. `bin/` is the installed location
(`key-grammar-topology.psm1` → `binTarget`); `build/gml-stage1/Release/` is the build
source (`buildTarget`).

---

## 16. GML — Graph Map Language

GML is **Graph Map Language** — not graph machine learning. It is the topology substrate `B`:
the authoritative discrete graph that K'UHUL fold operations traverse.

### Why "Graph Map Language"

The *map* in GML names the **anamorphism** (unfold): the fold map function walks GML edges
to generate candidate-continuation structure. In hylomorphism terms:

| Fold algebra term | GML role |
|-------------------|----------|
| `B` | The discrete topology — nodes + typed edges (this is a GML graph) |
| `M_mu` | VECTOR-µ learned geometry *over* B — derived, not authoritative |
| `unfold` / ana | Walks GML edges; generates fold-candidate structure |
| `fold` / cata | Collapses KFOLD/1 phase slices back to a committed answer |
| `unfold-graph.gml` | Q3×C6 (3D hypercube × C6 phase cycle) — phase-aware neighbor map |

**Laws:**
- `topology-before-coordinates` — GML graph shape precedes any learned geometry
- `GML != VECTOR` — VECTOR-µ learns geometry over B; it cannot redefine B
- `ParsedGraph ≠ VerifiedGraph ≠ B` — parse → validate → admit are three distinct gates

### GML Files and Roles

GML files fall into three categories:

| Category | Examples | Role |
|----------|---------|------|
| Reference topology | `hypercube_Q3.gml`, `hypercube_Q4.gml`, `khanary_topology.gml` | 3D/4D geodesic reference; CCC interconnects; cognitive track adjacency |
| Fold-map traversal | `unfold-graph.gml` (Q3×C6, 48 nodes, 120 edges) | Phase-aware neighbor map for fold iterations |
| Semantic graphs | `intent-graph.gml`, `cfpc-questions.gml`, `metric_graph.gml`, `micronaut_fieldgraph.gml` | Intent routing, CFPC question traversal, WCR metric graph, fold-phase projection |
| Bias / wildcard | `eliza-bias.gml`, `bias.gml`, `pi-radius-bias.gml`, `wildcard.gml` | ELIZA pattern bias; π-radius weights; wildcard capture routing |
| Field projections | `vectors.gml`, `kuhul-pi.gml`, `tensor_field.gml`, `entropy_gradient_field.gml` | Read-only ranking/projection; `semantic_authority=false` |

### GML Grammar Layers

| Grammar | Location | Coverage |
|---------|---------|---------|
| `gml-1.ebnf` | `tools/trainer-dashboard/kuhul-es/grammars/` | Fold-map interface contract: nodes, edges, relation verbs, WCR weights, phase/epistemic state |
| `gml.khanary.ebnf` | `data/grammar/` (this repo) | Full Khanary grammar: all extensions — geodesic coordinates, Minkowski events, tensor bundles, quantum graphs, training gradients, deductive system |
| `gml.validator.json` | `data/grammar/` (this repo) | Semantic validator: V1–V5, R1–R5, W1–W4, G1–G2, S1–S4, D1–D4, Q1–Q14, L1–L3, A1, HE1–HE8, LB1–LB3, P1–P2, T1–T7, E1–E9, TB1–TB11 |

### Validation Pipeline

```
GML text
  → ParseGML (gml.khanary.ebnf)       → ParsedGraph
  → ValidateGML (gml.validator.json)  → VerifiedGraph   grade: VALID
  → Proposal (field_dag.cpp)          → Candidate
  → Ch'en (assert_and_verify)         → Certificate
  → XCFE (dispatch authority)         → Authorization
  → XulGate (compare_and_commit)      → B'              grade: ADMITTED
```

**Key rule:** A VerifiedGraph (grade=VALID) does not automatically update B. The admission
path `Proposal → Ch'en → XCFE → XulGate` is mandatory for topology mutation.

### Relation Verbs

Canonical verbs (`src/micronaut/relation_isa.h`) produce VerifiedRelations:
`@related_to`, `@delegates_to`, `@requires`, `@part_of`, `@defines`, `@is_a`,
`@causes`, `@contradicts`, `@has_part`, `@has_property`, `@possesses`, `@value`,
`@imports`, `@calls`, `@exposes`.

Non-canonical strings → `infer_relation_from_lexical()` → RelationCandidate (confidence < 1.0,
must pass Ch'en before use in B). **Law:** `Representation → Relevance → Candidate → Verification`.

### Authority Boundary

GML files are topology contracts, not truth certificates. `semantic_authority=false` for
all GML projections. Only an authorized Xul commit may mutate B. VECTOR-µ / METRIC-µ / TENSOR-µ
learn geometry *over* B — they cannot redefine the graph topology.

---

## 17. Four-Graph Architecture — Training and Retrieval

The K'UHUL training system separates four distinct concerns across four GML graphs. The model does not own its training process — the graphs do.

| Graph | Owns |
|-------|------|
| `model.gml` | Computational architecture — layer topology, tensor shapes, operator contracts |
| `trainer.gml` | Training mechanics — forward pass, loss, backward pass, optimizer proposal, commit |
| `learning.gml` | Meta-policy — evaluates training evidence, proposes adaptation of `trainer.gml` behavior |
| `matryoshka.gml` | Semantic working-set — isolates active keys and neighborhoods from the full corpus |

**Execution cascade:**
```
matryoshka.gml   selects G_active from corpus topology
  ↓
trainer.gml      trains θ_active within G_active dependency structure
  ↓
learning.gml     evaluates training evidence, proposes policy adaptations
```

### Bounded Training-Step Contract

Requiring a full XCFE round trip per tensor update would make training prohibitively slow. XCFE instead admits a **bounded training-step contract** that covers a full training session. The GPU executes thousands of operations within the admitted scope; no individual step requires separate authorization.

```
BoundedStepContract {
  permitted_parameters  : tensor address range or parameter group name
  update_rule           : SGD | AdamW | WCR-informed
  max_steps             : integer
  resource_limits       : { max_memory_mb, max_vram_mb }
  checkpoint_policy     : interval and validation criteria
  convergence_evidence  : required before contract renewal
}
```

### The Two-Loop Update Principle

Model parameter updates and graph topology updates operate at different frequencies and require different gates:

| Loop | Target | Frequency | Gate |
|------|--------|-----------|------|
| Inner | `θ` — model parameters | Per step, within admitted contract | Bounded training-step contract |
| Outer | `G` — graph ARC weights, edges | Per evaluation epoch | Full Ch'en → XCFE → XulGate |

```
θ_{t+1} = UpdateModel(θ_t, G_t, π_t)   ← inner loop, per-step
G_{t+1} = UpdateGraph(G_t, evidence)    ← outer loop, per epoch, full admission
```

Topology changes alter the **program structure** — they always require a full Xul commit. Parameter changes within an admitted contract scope do not.

---

## 18. Radius Contract

A radius field in a GML node defines the neighborhood over which a proposed operation may consider influence. Three radius types are defined:

| `radius_type` | Unit | Governed by |
|--------------|------|-------------|
| `graph_hops` | Integer number of edges | Graph topology — primary boundary |
| `vector_distance` | Real distance in embedding space | `M_µ` geometry — derived |
| `influence` | Real scalar influence magnitude | Model-defined threshold |

**Primary boundary:** `topology-before-coordinates` — `graph_hops` is the principal radius type. `vector_distance` operates over `M_µ` (learned geometry over B), not over B itself.

### Influence Equation

```
I(i,j) = w_ij · e^{-λ · d_G(i,j)}    for d_G(i,j) ≤ r
         0                              otherwise
```

Where `d_G(i,j)` is shortest-path graph distance, `r` is `radius`, `λ` is `decay_rate`, and `w_ij` is the **aggregated path weight** (not a single edge weight for multi-hop neighbors).

### Path Aggregation Modes

| `path_aggregation` | Meaning |
|-------------------|---------|
| `max_product` | Strongest multiplicative path — **default** |
| `min_product` | Weakest multiplicative path (conservative worst-case) |
| `sum_product` | Sum of path contributions; normalization constant required |
| `shortest_path_product` | Product along a deterministically selected shortest path |

**Law:** `path_aggregation` must be declared when `radius > 1`. Omitting it when `radius == 1` is permitted (single-hop, no path ambiguity).

### Radius does not grant access

A radius restricts which nodes a proposed operation *may consider*. It does not authorize modification of those nodes. Ch'en verifies the neighborhood contracts. XCFE authorizes the update scope. Xul commits only admitted changes.

**Law:** `RADIUS_BOUND ≠ ACCESS_GRANT`

---

## 19. KUHUL-π Gradient Guidance

KUHUL-π can guide learning in two architecturally distinct ways.

### Routing Guidance

KUHUL-π selects which graph neighborhoods, operators, or parameter groups participate in a training step. Implemented as GML topology + phase dispatch — no gradient mathematics involved. This is the safer, implementable path.

### Gradient Guidance

KUHUL-π mathematically modifies gradient updates through a declared transformation:

```
g̃ = P_{π,G}(g)
θ' = θ - η·g̃
```

`P_{π,G}` is a graph-aware gradient preconditioner. For ARC weights in `[0,1]`, elementwise scaling is:

```
g̃_i = w_i · g_i     where w_i = ARC weight on parameter i
```

An arbitrary weighting scheme can harm convergence. Any gradient transformation admitted by XCFE must carry a **convergence certificate**.

### Convergence Certificate

| `convergence_kind` | Evidence required |
|-------------------|-----------------|
| `theoretical` | Proof that P is a valid preconditioner; bounded condition number κ(P) stated |
| `empirical` | Validation loss improved or held over `convergence_min_steps` consecutive steps by at least `convergence_loss_threshold` |
| `none` | Validator issues WARNING — transformation is admissible but unverified |

Ch'en accumulates convergence evidence before certifying a transformation as admissible. `theoretical` and `empirical` are distinct claims — a passing empirical run is not a theoretical guarantee.

**Law:** `GPU_RESULT ≠ PROOF ≠ AUTHORIZATION ≠ COMMIT`

---

## 20. Matryoshka Semantic Working-Set

`matryoshka.gml` is a **semantic working-set controller**. It isolates the active semantic subgraph from the full AIML corpus topology, bounding expansion with the radius contract.

### Corpus Representation

```
AIML Corpus = Compact Vector Index + Exact Symbolic Store + GML Relationships
```

| Component | Contents | Purpose |
|-----------|---------|---------|
| Compact Vector Index | 32D–256D embeddings per category | Fast semantic candidate discovery |
| Exact Symbolic Store | Pattern text, templates, wildcards, SRAI edges | Exact rule evaluation |
| GML Relationships | Edge topology connecting keys, fields, categories | Active subgraph selection |

### Progressive Vector Resolution

```
32D candidate discovery → 128D reranking → 256D verification → exact AIML resolution
```

At 32D float32: ~12 MiB for 99,524 categories. At int8: ~3 MiB. The 256D pass runs only on a small shortlist.

**Matryoshka truncation caveat:** Truncating EmbeddingGemma 2 vectors from 256D to 32D preserves retrieval quality only when the model was trained with Matryoshka loss at that dimension. The existing vectors must be evaluated for top-k recall at 32D and 64D before the progressive resolution cascade can be trusted. PCA projection is a fallback but is not Matryoshka.

### The "Inactive ≠ Deleted" Invariant

**Law:** `INACTIVE ≠ DELETED`

An inactive key means excluded from the current active working set. The full corpus and graph remain available for subsequent retrievals. `matryoshka.gml` is a *view controller*, not a delete operation.

### Connection to trainer.gml

During training, `matryoshka.gml` proposes the active parameter scope:

```
G_active  = SelectKeys(G, intent, r, π)      ← matryoshka selects
θ_active  = Parameters(G_active)             ← trainer scope
θ_active' = UpdateModel(θ_active, ...)       ← trainer updates within scope
```

**Dependency law:** If parameters are shared across key groups, their gradients may still depend on examples outside `G_active`. `G_active` restricts the update *proposal*, not the gradient computation graph.

---

## File Locations

| Artifact | Canonical location |
|----------|--------------------|
| Phase drivers (JSON) | `data/drivers/phases/*.json` |
| Per-phase AIML | `data/alice/*.aiml` |
| CFPC C++ source | `src/cfpc_accumulator.{h,cpp}` |
| FoldDelta / FoldDirection | `src/fold_delta.h`, `src/fold_direction.{h,cpp}` |
| field-factory | `../key-grammar-kit/field-factory/` |
| kuhul.atomic.khl | `data/grammar/kuhul.atomic.khl` |
| kuhul-es (KHL runtime) | `tools/trainer-dashboard/kuhul-es/` |
| GML/1 fold-map grammar | `tools/trainer-dashboard/kuhul-es/grammars/gml-1.ebnf` |
| GML full Khanary grammar | `data/grammar/gml.khanary.ebnf` |
| GML semantic validator | `data/grammar/gml.validator.json` |
| GML manifest | `data/manifest/gml.manifest.json` |
| GML C++ parser | `src/world/gml_parser.cpp` |
| GML field DAG builder | `src/world/field_dag.cpp` |
| GML fold-map graph | `data/unfold-graph.gml` (Q3×C6, 48 nodes) |
| KHL kernel program | `tools/trainer-dashboard/kuhul-es/sw.khl` |
| AIML Jinja macros | `templates/aiml_macros.jinja` |
| Jinja AIML example output | `build/jinja_source/daemon_basic.aiml` |
| Gemma scripts | `scripts/gemma3-generate.py`, `gemma-fields.py`, `gemma-tools.py`, `gemma-word-tree.py` |
| Codegen pipeline | `scripts/codegen-mu.py` |
| PowerShell bus modules | `shell/*.psm1` |
| PowerShell tools/scripts | `tools/powershell/*.ps1` |
| Production build (eliza-µ) | `build/gml-stage1/Release/` |
| Dev/test build | `build/Release/` |
| Installed binaries | `bin/` |
| All grammar/semantic files mirrored to | `data/alice/` and `data/grammar/` in both repos |
| **Training architecture (§17–§20)** | |
| Training graph topology | `data/trainer.gml` |
| Matryoshka working-set controller | `data/matryoshka.gml` |
| Radius contract conformance suite | `data/conformance/trainer-radius.conformance.json` |
