# Expected: reject E_FALLBACK_INVALID_CAPABILITY
srai [
  kind: micronaut_srai
  route: micronaut:QUESTION:GENERATE
  concept: ⟁REASONING
  input: "x"
  max_depth: 2
  source: gramstore
  symbolic_ref: aiml_relations_grams.x
  admission: xcfe_required
  fallback: fail_template
  phase: Yax
  authority: proposal_only
]
