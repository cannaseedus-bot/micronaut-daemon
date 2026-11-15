graph [
  comment "WILDCARD-μ pattern topology. Declares what can match: wildcard patterns, concrete n-grams, and the relations between them. Structural only - no weights, no admission, no persistence. bias.gml carries what can adapt; the KGF lanes decide how adaptation is evaluated. A wildcard is a pattern operator, not another n-gram order: it matches variable-length sequences and produces captures."
  directed 1
  id 1701
  label "WildcardPatternGraph"
  capture_semantics "single_star_absorbs_remainder"

  node [
    id 1
    label "HOW TO *"
    kind "wildcard_pattern"
    order 3
    arity "variable"
  ]

  node [
    id 4
    label "GROW *"
    kind "wildcard_pattern"
    order 2
    arity "variable"
  ]

  node [
    id 2
    label "HOW TO GROW TOMATOES"
    kind "ngram"
    order 4
  ]

  node [
    id 3
    label "GROW TOMATOES"
    kind "ngram"
    order 2
  ]

  edge [
    source 1
    target 2
    relation "matches"
    capture "GROW TOMATOES"
  ]

  edge [
    source 2
    target 3
    relation "suffix"
  ]

  edge [
    source 3
    target 4
    relation "generalizes"
  ]
]
