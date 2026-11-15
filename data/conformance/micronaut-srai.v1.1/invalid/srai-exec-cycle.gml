# Expected: reject E_EXEC_CYCLE
# This GML compiles to a plan whose execution_dependencies form a cycle:
# ROUTE_A before ROUTE_B, and ROUTE_B before ROUTE_A.
# See also: data/conformance/micronaut-srai.v1/invalid/srai-exec-cycle.compiled.json
# for the explicit compiled-form representation.
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
  authority: proposal_only
  # _cycle_note: compiler must detect when this srai references a route that
  # transitively re-enters itself in execution_dependencies
]
