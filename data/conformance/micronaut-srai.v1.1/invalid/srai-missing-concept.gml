# Expected: reject E_CONCEPT_MISSING (refinement #3)
# Every srai must declare which concept field it is scoped to.
srai [
  kind: micronaut_srai
  route: capital_of
  input: "france"
  max_depth: 2
  source: manifest
  symbolic_ref: words.manifest.capital_of
  admission: xcfe_required
  fallback: fail_template
  phase: Sek
  authority: proposal_only
]
