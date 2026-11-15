# Same semantics as valid/srai-route-capital.gml with fields in a different order.
# Expected: accept, and produce the same srai_hash as srai-route-capital.gml.
srai [
  authority: proposal_only
  phase: Sek
  route: capital_of
  kind: micronaut_srai
  fallback: fail_template
  admission: xcfe_required
  max_depth: 4
  provenance: required
  input: "{country} the capital of"
]
