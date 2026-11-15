# Same semantics as valid/srai-route-capital.gml with fields in a different order.
# Expected: accept, same srai_hash as valid/srai-route-capital.gml.
srai [
  authority: proposal_only
  phase: Sek
  fallback: fail_template
  admission: xcfe_required
  symbolic_ref: words.manifest.capital_of
  source: manifest
  provenance: required
  max_depth: 4
  input: "{country} the capital of"
  concept: ⟁INFORMATION
  route: capital_of
  kind: micronaut_srai
]
