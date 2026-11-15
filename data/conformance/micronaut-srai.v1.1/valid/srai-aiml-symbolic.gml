# Valid: source=aiml, no vector_row required (refinement #2).
# A greeting matched exactly by AIML pattern — S=0 is admitted via I4 symbolic path.
srai [
  kind: micronaut_srai
  route: greeting_response
  concept: ⟁SOCIAL
  input: "HI HOW ARE YOU"
  max_depth: 1
  provenance: optional
  source: aiml
  symbolic_ref: alice.HI_HOW_ARE_YOU
  admission: not_applicable_read_only
  fallback: return_empty
  phase: Pop
  authority: proposal_only
]
