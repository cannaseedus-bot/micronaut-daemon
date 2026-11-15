# ConceptFieldAccumulator v1 — Frozen Data Model

This is the **freeze artifact** for the per-concept accumulation layer. The execution plan in `concept-relative-fold.v1.plan.gml` is a consumer; this model is what the plan reads and writes. Invariants live on the model; the plan can be revised without invalidating what it consumes.

## Boundary: EmbeddingGemma vs. Micronaut SRAI

The four-factor score `R(g,c,p) = W(g,c) · C(g,p) · S(g,c) · P(g)` splits cleanly across the layer boundary:

| Owned by | Factor | Requires |
|---|---|---|
| **EmbeddingGemma** | `S(g,c)` — vector cosine score per `(gram, concept)` | Frozen vector store; concept fields from Yax allocation |
| **Micronaut SRAI** | `W(g,c)` — gram-to-concept weight | Words manifest |
| **Micronaut SRAI** | `C(g,p)` — contextual compatibility | Prompt context span |
| **Micronaut SRAI** | `P(g)` — provenance / evidence reliability | Provenance store |

EmbeddingGemma returns `S(g,c)` only. It never applies `W`, `C`, or `P`; it has neither the manifest, the context, nor the provenance record. It returns one result per `(gram, concept)` pair with a traceable `source_vector_row`.

## EmbeddingGemma interface

```
retrieve(
  grams:    [unigram, bigram, trigram, ...],  // from words manifest
  concepts: [ConceptField],                   // from Yax allocation
  vectors:  VectorStore,                      // frozen, read-only
  top_k:    int
) -> [ {gram, concept_id, cosine, rank, source_vector_row} ]
```

One result per `(gram, concept)` pair. Output is `S(g,c)` — not `R(g,c,p)`.

## Data model

```
ConceptFieldAccumulator {
  concept_id:           string
  concept_scope:        string               // the prompt span that produced this field
  state:                "candidate" | "verified"
  gram_activations:     [GramActivation]
  vector_matches:       [VectorMatch]
  candidate_senses:     [SenseMass]          // distribution, never collapsed before REDUCE
  unresolved_gaps:      [Gap]
  shared_references:    [SharedRef]
  verified_evidence:    [Evidence]           // empty when state == "candidate"
  fold_state:           "pending_reduce" | "reduced" | "verified"
}

GramActivation {
  gram:                 string
  concept_id:           string               // redundant with parent — intentional for traceability
  score_components: {
    W:  float,                               // gram-to-concept weight (words manifest)
    C:  float,                               // contextual compatibility (prompt span)
    S:  float,                               // vector cosine score (EmbeddingGemma)
    P:  float                                // provenance reliability (provenance store)
  }
  product:              float                // W · C · S · P
  source_vector_row:    int                  // row in VectorStore that produced S
  scoring_context_hash: string              // SHA-256 of (manifest_entry || prompt_span || provenance_record)
  shared:               bool                // true if this gram appears in another field with declared shared provenance
}

VectorMatch {
  pattern_id:           string
  cosine:               float
  source_vector_row:    int
  source:               string              // "EmbeddingGemma.pattern" | "EmbeddingGemma.template" | "EmbeddingGemma.category"
}

SenseMass {
  sense:                string
  mass:                 float               // 0..1; distribution over candidate_senses sums to ~1
  evidence:             [string]            // gram ids or manifest keys
}
```

## Invariants

**I1 — State discipline.** When `state == "candidate"`, `verified_evidence` must be empty. When `state == "verified"`, `verified_evidence` must have been produced by a `Ch'en` record — not by `Sek`. A `Sek` fold that writes anything to `verified_evidence` is a violation.

**I2 — Scoring context consistency.** For every `GramActivation`, `scoring_context_hash` must equal the hash of `(words_manifest_entry, prompt_context_span, provenance_record)` for that specific `(gram, concept)` pair. Two activations for the *same gram in different concepts* must have different `scoring_context_hash` values, unless both carry `shared: true` with an identical declared source. This catches the failure mode where a global score is copied into every concept field — the hash would be identical, which is the invariant violation, even if the product happens to be different.

**I3 — Traceability.** Every `GramActivation.source_vector_row` must exist in the referenced `VectorStore`. Every `GramActivation` must have at least one `VectorMatch` with a matching `source_vector_row`. A score without a traceable source is a guess, not a retrieval result.

## Failure modes (one per dropped factor)

| Factor dropped | Silent failure | Detected by |
|---|---|---|
| `W(g,c)` global | Every field gets the same gram weights; concept assignment is decorative | I2: `scoring_context_hash` identical across fields without `shared: true` |
| `C(g,p)` global | Context is read once for the prompt, not per span; joke field inherits explanation's context | I2: hash encodes prompt span; different spans → different hash |
| `S(g,c)` missing source | Retrieval score has no row reference; provenance cannot be checked | I3: `source_vector_row` required |
| `P(g)` global | A gram from an unreliable source gets the same credibility as a verified one | I2: hash encodes provenance record; different records → different hash |
| `verified_evidence` pre-populated | A `Sek` step wrote evidence before `Ch'en` ran; verification is fiction | I1: state must be `"candidate"` with empty `verified_evidence` |
| `candidate_senses` collapsed early | A pun loses its alternate sense before `REDUCE`; cross-field pun is impossible | Fixture: `accumulator-collapsed-senses.gml` |
| `allocate` not total | A segmented concept has no accumulator; `Xul` compose silently drops it | Fixture: `accumulator-missing-concept.gml` |

## Freeze criterion

Two independent implementations of a `ConceptFieldAccumulator` validator, run against `data/conformance/concept-field-accumulator.v1/`, produce:
- Identical acceptance for all `valid/` fixtures
- Identical rejections (by error id) for all `invalid/` fixtures

Matching the gate established for `ccc4.operator-plan.v1` and `micronaut-srai.v1`.
