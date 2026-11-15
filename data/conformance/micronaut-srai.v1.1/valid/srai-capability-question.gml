srai [
  kind: micronaut_srai
  route: micronaut:QUESTION:GENERATE
  concept: ⟁REASONING
  input: "{semantic_field} has unresolved gap"
  max_depth: 2
  provenance: required
  source: gramstore
  symbolic_ref: aiml_relations_grams.unresolved_gap
  admission: xcfe_required
  fallback: route:clarify_input
  phase: Yax
  authority: proposal_only
]
