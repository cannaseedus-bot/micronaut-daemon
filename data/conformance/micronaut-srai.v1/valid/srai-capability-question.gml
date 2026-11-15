srai [
  kind: micronaut_srai
  route: micronaut:QUESTION:GENERATE
  input: "{semantic_field} has unresolved gap"
  max_depth: 2
  provenance: required
  admission: xcfe_required
  fallback: route:clarify_input
  phase: Yax
  authority: proposal_only
]
