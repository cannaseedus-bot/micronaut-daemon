# Expected: reject E_ADMISSION_MISSING
srai [
  kind: micronaut_srai
  route: micronaut:QUESTION:GENERATE
  concept: ⟁REASONING
  input: "x"
  max_depth: 2
  source: gramstore
  symbolic_ref: aiml_relations_grams.x
  admission: not_applicable_read_only
  fallback: return_empty
  phase: Yax
  authority: proposal_only
]
