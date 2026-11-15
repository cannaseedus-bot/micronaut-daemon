# Expected: reject E_SYMBOLIC_REF_MISSING (refinement #2)
# source=manifest requires symbolic_ref; a manifest route without a ref has no
# declared traceability target.
srai [
  kind: micronaut_srai
  route: capital_of
  concept: ⟁INFORMATION
  input: "france"
  max_depth: 2
  source: manifest
  admission: xcfe_required
  fallback: fail_template
  phase: Sek
  authority: proposal_only
]
