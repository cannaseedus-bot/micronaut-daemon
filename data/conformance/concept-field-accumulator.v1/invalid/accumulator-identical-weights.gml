# Expected: reject E_INVARIANT_GLOBAL_SCORE
# "cat" has the same scoring_context_hash in two fields without shared: true.
# Two concepts with identical scoring_context_hash means the same global score
# was copied — the runtime did not compute W(g,c) independently per concept.
# Note: equal products alone are NOT a violation if the hashes differ — two
# independent computations can produce equal results by coincidence.
accumulator [
  concept_id: "⟁HUMOR"
  concept_scope: "tell me a joke about a cat"
  state: "candidate"
  gram_activations: [
    {gram: "cat", concept_id: "⟁HUMOR",
     score_components: {W: 0.80, C: 0.90, S: 0.83, P: 0.95},
     product: 0.567, source_vector_row: 41823,
     scoring_context_hash: "abc123deadbeef", shared: false}
  ]
  candidate_senses: []
  verified_evidence: []
  fold_state: "pending_reduce"
]

accumulator [
  concept_id: "⟁EXPLAIN"
  concept_scope: "explain cats"
  state: "candidate"
  gram_activations: [
    {gram: "cat", concept_id: "⟁EXPLAIN",
     score_components: {W: 0.80, C: 0.90, S: 0.83, P: 0.95},
     product: 0.567, source_vector_row: 41823,
     scoring_context_hash: "abc123deadbeef", shared: false}
  ]
  candidate_senses: []
  verified_evidence: []
  fold_state: "pending_reduce"
]
