# Expected: reject E_ADMISSION_MISSING
# A micronaut:* capability route requires admission: xcfe_required.
# not_applicable_read_only is a category error for capability routes.
srai [
  kind: micronaut_srai
  route: micronaut:QUESTION:GENERATE
  input: "x"
  max_depth: 2
  admission: not_applicable_read_only
  fallback: return_empty
  phase: Yax
  authority: proposal_only
]
