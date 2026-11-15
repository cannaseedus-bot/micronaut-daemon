# Expected: reject — "cat" has identical weight (0.72) in two fields without shared: true.
# INVARIANT: for every gram g in (c1, c2), if weight is identical across fields then
# both must carry shared: true from the same source. Identical weight without shared
# marker means the runtime copied one global score, violating per-concept scoring.
accumulator [
  concept_id: "⟁HUMOR"
  concept_scope: "tell me a joke about a cat"
  gram_activations: [
    {gram: "cat", weight: 0.72, source: "unigram"}
  ]
  candidate_senses: []
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

accumulator [
  concept_id: "⟁EXPLAIN"
  concept_scope: "explain cats"
  gram_activations: [
    {gram: "cat", weight: 0.72, source: "unigram"}
  ]
  candidate_senses: []
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]
