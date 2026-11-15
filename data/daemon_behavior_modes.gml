graph [
  directed 1
  id 68
  label "DaemonBehaviorModes"
  comment "Illustrative mode relation graph. Edge weights are affinities, not probabilities or learned gradients. XCFE decides whether a requested mode combination is admissible."

  node [ id 0 label "therapy" category "emotional_interpersonal" ]
  node [ id 1 label "buddy" category "emotional_interpersonal" ]
  node [ id 2 label "counselor" category "emotional_interpersonal" ]
  node [ id 3 label "coach" category "emotional_interpersonal" ]
  node [ id 4 label "listener" category "emotional_interpersonal" ]
  node [ id 5 label "socratic" category "learning_intellectual" ]
  node [ id 6 label "mentor" category "learning_intellectual" ]
  node [ id 7 label "critic" category "learning_intellectual" ]
  node [ id 8 label "strategist" category "professional_productivity" ]
  node [ id 9 label "debugger" category "technical_computational" ]
  node [ id 10 label "investigator" category "technical_computational" ]
  node [ id 11 label "questioner" category "metacognitive_autonomous" ]

  edge [ source 0 target 4 relation "can_pair_with" weight 0.85 ]
  edge [ source 1 target 2 relation "can_pair_with" weight 0.60 ]
  edge [ source 2 target 3 relation "optional_transition" weight 0.65 ]
  edge [ source 3 target 5 relation "question_style_affinity" weight 0.70 ]
  edge [ source 6 target 3 relation "goal_support_affinity" weight 0.65 ]
  edge [ source 7 target 11 relation "question_style_affinity" weight 0.75 ]
  edge [ source 8 target 5 relation "alternative_analysis_affinity" weight 0.60 ]
  edge [ source 9 target 10 relation "hypothesis_support" weight 0.80 ]
  edge [ source 10 target 11 relation "evidence_question_affinity" weight 0.75 ]
]
