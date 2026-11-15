# Valid: two srai nodes for the same gram (bank) — one vector, one manifest.
# The gram "bank" has both vector evidence (cosine over joke_*) and symbolic
# evidence (words.manifest:bank_pun). Both are first-class; neither excludes the other.
srai [
  kind: micronaut_srai
  route: micronaut:JOKE_OR_WORDPLAY
  concept: ⟁HUMOR
  input: "joke about a bank"
  max_depth: 3
  provenance: required
  source: vector
  vector_row: 41823
  admission: xcfe_required
  fallback: route:clarify_ambiguity
  phase: Yax
  authority: proposal_only
]

srai [
  kind: micronaut_srai
  route: bank_pun
  concept: ⟁HUMOR
  input: "bank pun"
  max_depth: 2
  provenance: required
  source: manifest
  symbolic_ref: words.manifest.bank_pun
  admission: xcfe_required
  fallback: return_empty
  phase: Yax
  authority: proposal_only
]
