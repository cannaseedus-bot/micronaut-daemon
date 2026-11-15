# Expected: reject E_FALLBACK_INVALID_CAPABILITY
# A capability route cannot use fail_template — a capability failure is a
# proposal rejection, not a template rendering failure.
srai [
  kind: micronaut_srai
  route: micronaut:QUESTION:GENERATE
  input: "x"
  max_depth: 2
  admission: xcfe_required
  fallback: fail_template
  phase: Yax
  authority: proposal_only
]
