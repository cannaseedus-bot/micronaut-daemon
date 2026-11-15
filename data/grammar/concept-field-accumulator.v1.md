# ConceptFieldAccumulator v1 — Canonical Encoding and Invariants

**Freeze artifact.** The execution plan in `concept-relative-fold.v1.plan.gml` consumes this model. Invariants I1–I4 are normative; the plan can be revised without invalidating what it consumes.

## Boundary: EmbeddingGemma vs. Micronaut SRAI

| Owned by | Factor | Requires |
|---|---|---|
| **EmbeddingGemma** | `S(g,c)` — vector cosine score per `(gram, concept)` | Frozen vector store; concept fields from Yax allocation |
| **Micronaut SRAI** | `W(g,c)` — gram-to-concept weight | Words manifest |
| **Micronaut SRAI** | `C(g,p)` — contextual compatibility | Prompt context span |
| **Micronaut SRAI** | `P(g)` — provenance / evidence reliability | Provenance store |

EmbeddingGemma produces one query tensor per prompt. Everything else — retrieval, scoring, accumulation — is lane output.

## EmbeddingGemma interface

```
retrieve(
  grams:    [unigram, bigram, trigram, ...],  // from words manifest
  concepts: [ConceptField],                   // from Yax allocation
  vectors:  VectorStore,                      // frozen, read-only
  top_k:    int
) -> [ {gram, concept_id, cosine, rank, source_vector_row} ]
```

One result per `(gram, concept)` pair. Output is `S(g,c)` only — not `R(g,c,p)`.

## Domain separator

```
"concept-field-accumulator.v1\0"
```

Prefix the byte stream with this null-terminated UTF-8 string before hashing.

## Canonical encoding (for accumulator_hash)

```
u8   state_index                # candidate=0, verified=1
utf8 concept_id
utf8 concept_scope
utf8 concept_context_hash       # sha256:... as ASCII (66 bytes)

u32le n_gram_activations
for each activation, sorted by (gram, concept_id, scoring_context_hash):
    utf8  gram
    utf8  concept_id
    u32le W_x1e6               # W quantized to 1e-6, u32le
    u32le C_x1e6
    u32le S_x1e6
    u32le P_x1e6
    u32le product_x1e6
    utf8  scoring_context_hash
    u8    shared               # 0 or 1
    if shared:
        utf8 shared_source

u32le n_vector_matches
for each, sorted by (pattern_id, source_vector_row):
    utf8  pattern_id
    u8    source_index         # pattern=0, template=1, category=2
    i32le cosine_x1e6          # signed, -1e6..1e6
    u32le source_vector_row

u32le n_symbolic_evidence
for each, sorted by (kind, ref):
    u8    kind_index           # aiml=0, manifest=1, gramstore=2, rule=3
    utf8  ref
    utf8  source

u32le n_unresolved_gaps
for each, sorted by (gap, severity):
    utf8  gap
    u8    severity_index       # soft=0, hard=1
    utf8  fallback             # or empty

u32le n_shared_references
for each, sorted by (ref, used_by):
    utf8  ref
    u32le n_used_by
    for each used_by_id (sorted): utf8 used_by_id

u32le n_verified_evidence
for each, sorted by (kind, verification_id):
    utf8  kind
    utf8  value_canonical      # kind-specific
    u8    admitted             # 0 or 1
    utf8  verification_id

u8   fold_state_index          # pending_reduce=0, reduced=1, verified=2

accumulator_hash := SHA-256 of domain_separator + above bytes, hex-lowercase
```

All `utf8` fields are length-prefixed: `u32le length` followed by `length` bytes of UTF-8.

## `concept_context_hash` derivation

```
concept_context_hash := sha256(
    concept_id || 0x00 ||
    concept_scope || 0x00 ||
    canonical_sources_hash || 0x00 ||
    "concept-field-accumulator.v1"
)
```

Every `gram_activations[i].scoring_context_hash` for an activation in this accumulator must equal this value.

## Invariants (normative)

**I1 — State discipline.** `state: "candidate"` implies `verified_evidence == []`. `state: "verified"` implies every item in `verified_evidence` has a non-empty `verification_id` produced by a `Ch'en` record, and `fold_state ∈ {"reduced", "verified"}`. A `Sek` fold that writes anything to `verified_evidence` is a violation.

**I2 — Scoring context identity.** Every `gram_activations[i].scoring_context_hash` must equal the accumulator's `concept_context_hash`. Two activations with different `concept_id` (i.e., in different accumulators) **must** have different `scoring_context_hash` values, unless both carry `shared: true` with the same `shared_source`. This catches the failure mode where a global score is copied into every concept field — the hash would be identical across fields, which is the invariant violation, even if the numerical product happens to differ.

**I3 — Traceability, typed.** For every `GramActivation`:
- If the activation has a matching `vector_matches` entry, that entry's `source_vector_row` must exist in the referenced `VectorStore`.
- If the activation has a matching `symbolic_evidence` entry, that entry's `ref` must resolve in the referenced corpus/manifest/rule store.
- **At least one** must hold. An activation with neither a vector match nor a symbolic evidence entry is free-floating and is rejected (`E_ACC_UNTRACED_ACTIVATION`).

v1.0 required every activation to have a vector row. v1.1 relaxes this to "at least one typed source." This admits `"HI HOW ARE YOU"` via AIML match with `S=0`.

**I4 — Admission vs. ranking.** The four-factor product is a **ranking** score, not an admission gate. Admission is:

```
admitted(activation) :=
    (has_vector_evidence   AND S > s_threshold)   OR
    (has_symbolic_evidence AND symbolic_match_exact) OR
    (has_vector_evidence   AND has_symbolic_evidence)
```

A symbolic-only activation with `S = 0` is admitted by its exact match and ranked by `W·C·P` (the vector term is treated as neutral `1.0` for ranking, not `0.0` for elimination). XCFE admission is a **separate gate** that follows ranking.

## Failure modes

| Factor dropped | Silent failure | Detected by |
|---|---|---|
| `W(g,c)` global | Every field gets the same gram weights | I2: same `scoring_context_hash` without `shared: true` |
| `C(g,p)` global | Context is read once for the prompt, not per span | I2: hash encodes prompt span |
| `S(g,c)` missing source | Retrieval score has no traceable row | I3: `source_vector_row` required |
| `P(g)` global | Unreliable source lends credibility to any field | I2: hash encodes provenance record |
| `verified_evidence` pre-populated | `Sek` wrote evidence before `Ch'en` | I1: state must be `"candidate"` |
| `candidate_senses` collapsed early | Pun loses alternate sense before REDUCE | Fixture: `acc-bank-pun-both-senses.json` |
| `allocate` not total | A segmented concept has no accumulator | Fixture: `acc-missing-concept.json` (see `.gml` fixture in v1 set) |

## Freeze criterion

Two independent implementations, run against `data/conformance/concept-field-accumulator.v1/`:
- `acc-greeting-symbolic-only.json` accepted (I4 correct — `S=0` admitted by AIML)
- `acc-five-concepts.json` accepted with distinct `scoring_context_hash` per concept field (I2 correct)
- All `invalid/` fixtures rejected with the named error ids
