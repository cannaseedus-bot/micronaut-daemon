# Expected: reject E_MAX_DEPTH_MISSING
srai [
  kind: micronaut_srai
  route: capital_of
  concept: ⟁INFORMATION
  input: "france"
  source: manifest
  symbolic_ref: words.manifest.capital_of
  admission: xcfe_required
  fallback: fail_template
  phase: Sek
  authority: proposal_only
]
