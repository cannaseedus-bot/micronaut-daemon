# micronaut-srai.v1.1 Validator Contract

Extends v1.0 with eight new error ids for refinements #2–#4. All v1.0 error ids remain valid.

## SRAI rejection matrix

| Error id | Condition | Refinement |
|---|---|---|
| `E_KIND_MISSING` | `kind: micronaut_srai` absent | — |
| `E_KIND_WRONG` | `kind` not `micronaut_srai` | — |
| `E_ROUTE_MISSING` | `route` absent | — |
| `E_ROUTE_UNRESOLVED` | `route` names key/capability not in active manifests | — |
| `E_CONCEPT_MISSING` | `concept` absent | #3 |
| `E_CONCEPT_INVALID` | `concept` not a valid glyph (`⟁identifier`) | #3 |
| `E_SOURCE_MISSING` | `source` absent | #2 |
| `E_SOURCE_INVALID` | `source` not in `{vector, aiml, manifest, gramstore, rule}` | #2 |
| `E_VECTOR_ROW_MISSING` | `source=vector` and `vector_row` absent | #2 |
| `E_VECTOR_ROW_FORBIDDEN` | `source≠vector` and `vector_row` present | #2 |
| `E_SYMBOLIC_REF_MISSING` | `source≠vector` and `symbolic_ref` absent | #2 |
| `E_SYMBOLIC_REF_UNRESOLVED` | `symbolic_ref` does not resolve in active corpus | #2 |
| `E_MAX_DEPTH_MISSING` | `max_depth` absent | — |
| `E_MAX_DEPTH_RANGE` | `max_depth` < 1 or > 16 | — |
| `E_AUTHORITY_FORBIDDEN` | `authority` ≠ `proposal_only` | — |
| `E_ADMISSION_MISSING` | `route=micronaut:*` and `admission` absent or `not_applicable_read_only` | — |
| `E_ADMISSION_WRONG` | `admission` not in `{xcfe_required, not_applicable_read_only}` | — |
| `E_FALLBACK_MISSING` | `fallback` absent | — |
| `E_FALLBACK_INVALID_CAPABILITY` | `route=micronaut:*` and `fallback=fail_template` | — |
| `E_FALLBACK_UNRESOLVED` | `fallback: route:X` names unresolved key | — |
| `E_PHASE_UNKNOWN` | `phase` not in six-phase enum | — |
| `E_BINDING_UNRESOLVED` | `{binding.path}` in `input` does not resolve | — |
| `E_EXEC_CYCLE` | `execution_dependencies` contains a cycle | — |
| `E_CONTAINMENT_MULTI_PARENT` | node has >1 containment parent | — |
| `E_NODE_DUPLICATE` | node id appears more than once | — |
| `E_HASH_AMBIGUOUS` | two semantically distinct plans hash identically (encoder self-check) | — |

## Accumulator rejection matrix (I1–I4)

| Error id | Condition | Invariant |
|---|---|---|
| `E_ACC_VERIFIED_EVIDENCE_IN_CANDIDATE` | `state=candidate` and `verified_evidence` non-empty | I1 |
| `E_ACC_MISSING_VERIFICATION_ID` | `state=verified` and any `verified_evidence` lacks `verification_id` | I1 |
| `E_ACC_CONCEPT_HASH_MISMATCH` | any `gram_activations[i].scoring_context_hash` ≠ `concept_context_hash` | I2 |
| `E_ACC_SHARED_WITHOUT_SOURCE` | `shared=true` and `shared_source` absent or empty | I2 |
| `E_ACC_UNTRACED_ACTIVATION` | activation has neither matching `vector_matches` entry nor `symbolic_evidence` entry | I3 |
| `E_ACC_VECTOR_ROW_MISSING` | activation claims vector evidence but `source_vector_row` not in `VectorStore` | I3 |
| `E_ACC_SYMBOLIC_REF_UNRESOLVED` | activation claims symbolic evidence but `ref` does not resolve | I3 |
| `E_ACC_ZERO_ADMISSION` | `product=0` and no admission path via I4 (no exact symbolic match, no vector above threshold) | I4 |

## Notes on I4 — ranking vs. admission

The four-factor product is a **ranking** score, not an admission gate. Admission is:

```
admitted(activation) :=
    (has_vector_evidence   AND S > s_threshold)  OR
    (has_symbolic_evidence AND symbolic_match_exact) OR
    (has_vector_evidence   AND has_symbolic_evidence)
```

A symbolic-only activation with `S = 0` is admitted by its exact match and ranked by `W·C·P` with the vector term treated as neutral `1.0` (not `0.0`). This prevents an AIML-matched greeting from being eliminated because its vector similarity is low.

XCFE is a separate gate: an admitted, ranked activation must still pass XCFE before its capability proceeds.

## Freeze criterion (v1.1)

Two independent implementations, run against `data/conformance/micronaut-srai.v1.1/`, produce:
- Identical `srai_hash` for all `valid/` fixtures
- Identical error ids for all `invalid/` fixtures
- `acc-greeting-symbolic-only.json` accepted (I4 refinement #4 correct)
- `acc-five-concepts.json` accepted with distinct `scoring_context_hash` per concept (I2 refinement #3 correct)
