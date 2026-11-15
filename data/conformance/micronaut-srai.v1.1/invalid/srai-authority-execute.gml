# Expected: reject E_AUTHORITY_FORBIDDEN
srai [
  kind: micronaut_srai
  route: capital_of
  concept: ⟁INFORMATION
  input: "france"
  max_depth: 2
  source: manifest
  symbolic_ref: words.manifest.capital_of
  admission: xcfe_required
  fallback: fail_template
  phase: Sek
  authority: execute
]
