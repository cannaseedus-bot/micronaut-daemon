graph [
  comment "BIAS-μ parameter topology. Declares which features address which trainable parameters and with what feature weight. Topology only: no mutation authority, no admission, no persistence. KGF declares HOW learning happens (ParameterMappingLane.kgf); this file declares WHERE it applies. corpus_prior nodes are immutable evidence and never accept feature edges."
  directed 1
  id 1601
  label "Bias_Parameter_Graph"
  parameter_family "ngram_weights"
  update_target "W_learned"
  corpus_prior "immutable"
  max_step 0.25

  node [
    id 1
    label "feature:unigram:tomatoes"
    kind "ngram_feature"
    order 1
  ]

  node [
    id 2
    label "feature:bigram:grow_tomatoes"
    kind "ngram_feature"
    order 2
  ]

  node [
    id 3
    label "feature:trigram:how_to_grow"
    kind "ngram_feature"
    order 3
  ]

  node [
    id 4
    label "feature:quadgram:how_to_grow_tomatoes"
    kind "ngram_feature"
    order 4
  ]

  node [
    id 5
    label "feature:supagram:how_to_grow_tomatoes_indoors"
    kind "ngram_feature"
    order 7
  ]

  node [
    id 100
    label "weight:grow_tomatoes"
    kind "learned_parameter"
    weight 1.0
    family "ngram_weights"
  ]

  node [
    id 101
    label "weight:grow_plants"
    kind "learned_parameter"
    weight 1.0
    family "ngram_weights"
  ]

  node [
    id 102
    label "weight:how_to_grow"
    kind "learned_parameter"
    weight 1.0
    family "ngram_weights"
  ]

  node [
    id 900
    label "prior:corpus:grow_tomatoes"
    kind "corpus_prior"
    immutable 1
  ]

  edge [
    source 1
    target 100
    label "feature"
    feature 0.25
  ]

  edge [
    source 2
    target 100
    label "feature"
    feature 1.0
  ]

  edge [
    source 3
    target 102
    label "feature"
    feature 0.5
  ]

  edge [
    source 4
    target 100
    label "feature"
    feature 0.75
  ]

  edge [
    source 4
    target 102
    label "feature"
    feature 0.25
  ]

  edge [
    source 4
    target 101
    label "feature"
    feature 0.5
  ]

  edge [
    source 5
    target 100
    label "feature"
    feature 1.0
  ]

  edge [
    source 5
    target 102
    label "feature"
    feature 0.5
  ]
]
