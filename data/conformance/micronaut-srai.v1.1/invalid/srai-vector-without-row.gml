# Expected: reject E_VECTOR_ROW_MISSING (refinement #2)
# source=vector requires vector_row; no symbolic route for vector evidence.
srai [
  kind: micronaut_srai
  route: capital_of
  concept: ⟁INFORMATION
  input: "france"
  max_depth: 2
  source: vector
  admission: xcfe_required
  fallback: fail_template
  phase: Sek
  authority: proposal_only
]
