graph [
  directed 1
  label "CFPCQuestionGraph"
  comment "CFPC question topology, hand-declared from micronaut/cfpc_classifier.py. Declares the closed decision set only: which surface form selects which pattern, which bitmap condition opens which gap, and where each gap routes. Pattern internals - captures, wildcards, stripped prefixes - live in cfpc-wildcards.gml; this graph only names the pattern each form selects. It holds no question text and no per-question result - those live in neighborhood-attention.cfpc.jsonl. Nothing here admits, verifies or commits."

  (* gaps, in the order classify_gap checks them *)
  node [ id 1 label "INTENT_GAP" kind "gap" order 1 ]
  node [ id 2 label "QUERY_GAP" kind "gap" order 2 ]
  node [ id 3 label "KNOWLEDGE_GAP_NO_KEYS" kind "gap" order 3 ]
  node [ id 4 label "KNOWLEDGE_GAP_NO_VALUES" kind "gap" order 4 ]
  node [ id 5 label "RESOLVED" kind "gap" order 5 terminal 1 ]

  (* routes, one per open gap; RESOLVED has none *)
  node [ id 11 label "disambiguation" kind "route" ]
  node [ id 12 label "pattern_discovery" kind "route" ]
  node [ id 13 label "retrieval" kind "route" ]
  node [ id 14 label "evidence_resolution" kind "route" ]

  (* bitmap conditions read off the question and the record *)
  node [ id 21 label "intent_present" kind "condition" ]
  node [ id 22 label "query_present" kind "condition" ]
  node [ id 23 label "subject_present" kind "condition" ]
  node [ id 24 label "pattern_present" kind "condition" ]
  node [ id 25 label "keys_present" kind "condition" ]
  node [ id 26 label "values_present" kind "condition" ]

  (* recognized surface prefixes, matched in this order; the pattern each selects
     is declared here, and defined in cfpc-wildcards.gml *)
  node [ id 41 label "what is the difference" kind "question_form" order 1 pattern "what-is-the-difference" ]
  node [ id 42 label "how does" kind "question_form" order 2 pattern "how-does-relate" ]
  node [ id 43 label "how is" kind "question_form" order 3 pattern "how-does-relate" ]
  node [ id 44 label "why does" kind "question_form" order 4 pattern "why-does" ]
  node [ id 45 label "why is" kind "question_form" order 5 pattern "why-does" ]
  node [ id 46 label "how to" kind "question_form" order 6 pattern "how-to" ]
  node [ id 47 label "tell me about" kind "question_form" order 7 pattern "tell-me-about" ]
  node [ id 48 label "explain" kind "question_form" order 8 pattern "explain" ]
  node [ id 49 label "what does" kind "question_form" order 9 pattern "what-is" ]
  node [ id 50 label "what is" kind "question_form" order 10 pattern "what-is" ]

  edge [ source 21 target 1 relation "gates" ]
  edge [ source 22 target 2 relation "gates" ]
  edge [ source 23 target 2 relation "gates" ]
  edge [ source 24 target 2 relation "gates" ]
  edge [ source 25 target 3 relation "gates" ]
  edge [ source 26 target 4 relation "gates" ]

  edge [ source 1 target 2 relation "checked_before" ]
  edge [ source 2 target 3 relation "checked_before" ]
  edge [ source 3 target 4 relation "checked_before" ]
  edge [ source 4 target 5 relation "checked_before" ]

  edge [ source 1 target 11 relation "routes_to" ]
  edge [ source 2 target 12 relation "routes_to" ]
  edge [ source 3 target 13 relation "routes_to" ]
  edge [ source 4 target 14 relation "routes_to" ]
]
