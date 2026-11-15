# KHANARY / CFPC Semantic Grammar Package v0.1

**Status:** Proposed grammar and contract package generated from the conversation and the attached node-lifecycle draft. These files are design artifacts, not a claim that a C++ parser, registry, or executor has been implemented.

## Contents
- `ebnf/00-lexical.ebnf` through `ebnf/12-micronauts.ebnf`: modular element-level EBNF contracts.
- `schemas/*.schema.json`: JSON Schema Draft 2020-12 validators for serialized XJSON contracts.
- `examples/`: XML semantic DOM and XJSON examples.
- `docs/CONFORMANCE.md`: executable test requirements to implement in the runtime.

## Important grammar scope
These EBNF files describe **the parsed XML element grammar**, not a replacement for the XML 1.0 lexical grammar. Attribute presence/types and cross-reference semantics are enforced by a host validator and the JSON Schemas. The self-closing placeholders in EBNF (e.g. `<fact/ >`) denote element kinds, not literal valid XML spelling. XML examples use valid `<fact .../>` or paired tags.

## Canonical laws
- `Pop → Wo → Yax → Sek → Ch'en → Xul` is a per-node lifecycle; child Xul returns to parent.
- `WCR = W * C * cos(Q,K_mu)` ranks eligible Micronauts, not truth.
- `Cheese χ ∈ [0,10]` is contextual doubt/rejection pressure, not a static reward or truth probability.
- In an explicit selection: `argmax_{i:L_i=1} W_i C_i R_i(Q) (1 - χ_i/10)`; stable-ID tie break, empty -> Bottom.
- **Observation ≠ selection ≠ promotion.** Ordinary Xul close never writes FactIndex/EventLog.
- `<learn>` proposes shadow changes; `<promote>` requires separate Stage 3 authority approval.
- RelationRegistry precedes typed fact validation; FactIndex and EventLog are existing distinct projections.
- `ThinkExecutor → FunctionExecutor → InvocationExecutor` is retained.

## Host validation still required
Cross-file EBNF imports, relation IDs, type constraints, instruction authority, provider authorization, provenance, mutation permissions, phase dispatch and candidate score calibration are **semantic runtime checks**. JSON Schema alone cannot enforce these policies. The EBNF files are modular specifications, not yet a single generated parser grammar.

## Known deliberate limits
The attached draft's `node.commit` at Ch'en has been interpreted as *materialize result* except for separately approved authority promotion. The draft's proposed graph-distance WCR relevance is replaced with the established cosine contract. A branch losing WCR selection is *unselected*, not factually rejected. These are architecture reconciliations, not statements that the attached draft already specified them.
