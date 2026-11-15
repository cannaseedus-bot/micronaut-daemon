# Five-concept prompt: "tell me a joke about a cat, explain cats, then remember that
# cats have been domesticated for 10,000 years, and search for recent cat research,
# and show my cat preference setting."
# "cat" is shared between ⟁HUMOR and ⟁EXPLAIN with different weights — declared.
accumulator [
  concept_id: "⟁HUMOR"
  concept_scope: "tell me a joke about a cat"
  gram_activations: [
    {gram: "tell me a joke", weight: 0.91, source: "unigram+bigram"}
    {gram: "cat",            weight: 0.72, source: "unigram", shared: true}
  ]
  candidate_senses: [
    {sense: "humor_frame",   mass: 0.74, evidence: ["tell me a joke"]}
    {sense: "topic_binding", mass: 0.26, evidence: ["cat"]}
  ]
  shared_references: [
    {ref: "cat", used_by: ["⟁HUMOR", "⟁EXPLAIN"], role_humor: "topic", role_explain: "subject"}
  ]
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

accumulator [
  concept_id: "⟁EXPLAIN"
  concept_scope: "explain cats"
  gram_activations: [
    {gram: "explain",        weight: 0.88, source: "unigram"}
    {gram: "cat",            weight: 0.41, source: "unigram", shared: true}
  ]
  candidate_senses: [
    {sense: "explanation_frame", mass: 0.88, evidence: ["explain"]}
    {sense: "subject_binding",   mass: 0.41, evidence: ["cat"]}
  ]
  shared_references: [
    {ref: "cat", used_by: ["⟁HUMOR", "⟁EXPLAIN"], role_humor: "topic", role_explain: "subject"}
  ]
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

accumulator [
  concept_id: "⟁REMEMBER"
  concept_scope: "remember that cats have been domesticated for 10,000 years"
  gram_activations: [
    {gram: "remember that",  weight: 0.95, source: "bigram"}
    {gram: "domesticated",   weight: 0.78, source: "unigram"}
  ]
  candidate_senses: [
    {sense: "memory_write", mass: 0.95, evidence: ["remember that"]}
  ]
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

accumulator [
  concept_id: "⟁SEARCH"
  concept_scope: "search for recent cat research"
  gram_activations: [
    {gram: "search for",     weight: 0.91, source: "bigram"}
    {gram: "recent",         weight: 0.65, source: "unigram"}
  ]
  candidate_senses: [
    {sense: "web_search", mass: 0.91, evidence: ["search for"]}
  ]
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]

accumulator [
  concept_id: "⟁PREFERENCE"
  concept_scope: "show my cat preference setting"
  gram_activations: [
    {gram: "show my",        weight: 0.88, source: "bigram"}
    {gram: "preference setting", weight: 0.82, source: "bigram"}
  ]
  candidate_senses: [
    {sense: "preference_read", mass: 0.88, evidence: ["show my", "preference setting"]}
  ]
  verified_evidence: []
  fold_state: {status: "pending_reduce", output_candidate: null}
]
