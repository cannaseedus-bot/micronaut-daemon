# Expected: reject — candidate_senses has been collapsed to one sense with mass 1.0
# before REDUCE. Sense collapse is a REDUCE-stage operation; an accumulator with a
# single sense at mass 1.0 has lost the alternate-sense record that cross-field puns
# depend on. The pun bank fixture (valid/accumulator-pun-bank.gml) shows the correct form.
accumulator [
  concept_id: "⟁HUMOR"
  concept_scope: "joke about a bank"
  gram_activations: [
    {gram: "bank", weight: 0.76, source: "unigram"}
  ]
  candidate_senses: [
    {sense: "bank_financial", mass: 1.0, evidence: ["bank"]}
  ]
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]
