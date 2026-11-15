# micronaut-srai.v1 Validator Contract

A conforming Micronaut SRAI validator must reject the following conditions, each identified by the named error id.

## Rejection matrix

| Error id | Condition |
|---|---|
| `E_KIND_MISSING` | `kind: micronaut_srai` is absent |
| `E_KIND_WRONG` | `kind` is not `micronaut_srai` |
| `E_ROUTE_MISSING` | `route` is absent |
| `E_ROUTE_UNRESOLVED` | `route` names a key or capability not present in the active manifest set |
| `E_MAX_DEPTH_MISSING` | `max_depth` is absent |
| `E_MAX_DEPTH_RANGE` | `max_depth` < 1 or > 16 (declared ceiling) |
| `E_AUTHORITY_FORBIDDEN` | `authority` is anything other than `proposal_only` |
| `E_ADMISSION_MISSING` | `route` is a `micronaut:*` capability and `admission` is absent or `not_applicable_read_only` |
| `E_ADMISSION_WRONG` | `admission` is not one of `xcfe_required`, `not_applicable_read_only` |
| `E_FALLBACK_MISSING` | `fallback` is absent |
| `E_FALLBACK_INVALID_CAPABILITY` | `route` is a capability and `fallback` is `fail_template` |
| `E_FALLBACK_UNRESOLVED` | `fallback: route:X` names an unresolved key |
| `E_PHASE_UNKNOWN` | `phase` is not one of `Pop`, `Wo`, `Yax`, `Sek`, `Ch'en`, `Xul` |
| `E_BINDING_UNRESOLVED` | a `{binding.path}` in `input` does not resolve against the active manifest set |
| `E_EXEC_CYCLE` | `execution_dependencies` contains a cycle |
| `E_CONTAINMENT_MULTI_PARENT` | a node has more than one containment parent in v1 |
| `E_NODE_DUPLICATE` | a node id appears more than once |
| `E_HASH_AMBIGUOUS` | two presentation-distinct plans produce the same `srai_hash` for different semantics — encoder self-check; validator must reject both |

## Notes on `E_HASH_AMBIGUOUS`

This is not a user-facing error in the conventional sense. It is a validator self-check: if the encoding in `micronaut-srai.v1.md` has collapsed two semantically distinct plans to the same hash, the validator's encoder is defective. The correct response is to reject both and report the collision for investigation, not to accept one and misattribute its provenance.

## Notes on `E_ADMISSION_MISSING`

A `micronaut:*` capability route requires `admission: xcfe_required` because a capability cannot be invoked without XCFE admission. Setting `admission: not_applicable_read_only` on a capability route is not a lesser restriction — it is a category error: a capability route is never read-only.

## Notes on `E_FALLBACK_INVALID_CAPABILITY`

`fail_template` means "the template engine could not render a result." A capability route does not have a template; its failure is a proposal rejection. The correct fallback for a capability route is `return_empty` or `fallback: route:X`. Using `fail_template` on a capability route indicates the caller has confused key routing with capability routing.

## Notes on `E_MAX_DEPTH_MISSING`

`max_depth` is mandatory — not optional with a default. AIML has no depth bound; that is exactly the failure mode this contract replaces. An implementation that defaults `max_depth` to any value (even 16) violates the contract: the caller must declare the bound explicitly so it appears in the provenance record and can be audited.

## Freeze criterion

Matching the pattern established for `ccc4.operator-plan.v1`: two independent implementations of the §2–§3 encoding in `micronaut-srai.v1.md`, run against `data/conformance/micronaut-srai.v1/`, produce:
- Identical `srai_hash` values for all `valid/` fixtures
- Identical rejections (by error id) for all `invalid/` fixtures
