# Expected: reject E_MAX_DEPTH_MISSING
srai [
  kind: micronaut_srai
  route: capital_of
  input: "france"
  admission: xcfe_required
  fallback: fail_template
  phase: Sek
  authority: proposal_only
]
