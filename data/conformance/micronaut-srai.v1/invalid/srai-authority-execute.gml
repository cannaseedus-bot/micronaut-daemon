# Expected: reject E_AUTHORITY_FORBIDDEN
srai [
  kind: micronaut_srai
  route: capital_of
  input: "france"
  max_depth: 2
  admission: xcfe_required
  fallback: fail_template
  phase: Sek
  authority: execute
]
