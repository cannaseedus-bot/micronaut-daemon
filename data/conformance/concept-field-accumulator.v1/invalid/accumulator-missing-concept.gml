# Expected: reject — five intent fields were segmented but only four accumulators
# were allocated. allocate must be total over segment: for every concept field
# produced by yax.segment, there must be exactly one accumulator produced by
# yax.allocate. A missing accumulator is a silent drop, not a soft gap.
#
# Five fields declared:
#   ⟁HUMOR, ⟁EXPLAIN, ⟁REMEMBER, ⟁SEARCH, ⟁PREFERENCE
# Four accumulators allocated (⟁PREFERENCE is missing):
accumulator [
  concept_id: "⟁HUMOR"
  concept_scope: "tell me a joke about a cat"
  gram_activations: []
  candidate_senses: []
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

accumulator [
  concept_id: "⟁EXPLAIN"
  concept_scope: "explain cats"
  gram_activations: []
  candidate_senses: []
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

accumulator [
  concept_id: "⟁REMEMBER"
  concept_scope: "remember that cats have been domesticated for 10,000 years"
  gram_activations: []
  candidate_senses: []
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

accumulator [
  concept_id: "⟁SEARCH"
  concept_scope: "search for recent cat research"
  gram_activations: []
  candidate_senses: []
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

# ⟁PREFERENCE accumulator missing — validator must reject with E_ALLOCATE_INCOMPLETE
