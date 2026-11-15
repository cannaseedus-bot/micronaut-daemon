# Expected: reject — verified_evidence is non-empty before Ch'en.
# An accumulator may be structurally complete after Sek, but semantically closed
# only after Ch'en. verified_evidence must be empty until Ch'en runs.
# Same discipline as materialized: false in vector-lane BINDINGS_VALIDATED.
accumulator [
  concept_id: "⟁HUMOR"
  concept_scope: "tell me a joke"
  gram_activations: [
    {gram: "tell me a joke", weight: 0.91, source: "unigram+bigram"}
  ]
  candidate_senses: [
    {sense: "humor_frame", mass: 0.91, evidence: ["tell me a joke"]}
  ]
  verified_evidence: [
    {kind: "provenance", value: "source=words.manifest:joke", admitted: true}
  ]
  fold_state: {status: "pending_reduce", output_candidate: null}
]
