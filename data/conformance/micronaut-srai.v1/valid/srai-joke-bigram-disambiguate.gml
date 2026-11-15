srai [
  kind: micronaut_srai
  route: micronaut:JOKE_OR_WORDPLAY
  input: "{punchline_context} following {setup_context}"
  max_depth: 3
  provenance: required
  admission: xcfe_required
  fallback: route:clarify_ambiguity
  phase: Yax
  authority: proposal_only
]
