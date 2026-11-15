# "joke about a bank" — ⟁HUMOR keeps both financial and riverbank senses alive.
# candidate_senses must NOT be collapsed to one sense before REDUCE.
accumulator [
  concept_id: "⟁HUMOR"
  concept_scope: "joke about a bank"
  gram_activations: [
    {gram: "joke about",   weight: 0.88, source: "bigram"}
    {gram: "bank",         weight: 0.76, source: "unigram"}
  ]
  candidate_senses: [
    {sense: "bank_financial", mass: 0.52, evidence: ["bank"]}
    {sense: "bank_riverbank", mass: 0.48, evidence: ["bank"]}
  ]
  unresolved_gaps: [
    {gap: "pun_target_sense", severity: "soft", fallback: "generate_ambiguous_pun"}
  ]
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]
