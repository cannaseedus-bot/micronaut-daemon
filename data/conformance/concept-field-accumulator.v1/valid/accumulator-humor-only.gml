accumulator [
  concept_id: "⟁HUMOR"
  concept_scope: "tell me a joke"
  gram_activations: [
    {gram: "tell me a joke", weight: 0.91, source: "unigram+bigram"}
    {gram: "joke",           weight: 0.84, source: "unigram"}
  ]
  candidate_senses: [
    {sense: "humor_frame", mass: 0.91, evidence: ["tell me a joke", "joke"]}
  ]
  unresolved_gaps: [
    {gap: "punchline_target", severity: "soft", fallback: "generate_generic_joke"}
  ]
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]
