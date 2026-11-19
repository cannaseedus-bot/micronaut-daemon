graph [
  directed 1
  label "trainer.gml"
  comment "K'UHUL machine-executable training graph. This topology IS the training algorithm. Nodes encode phase-bound operators; edges encode data-dependency and authority relationships. The graph is traversed by the K'UHUL phase cycle (Pop→Wo→Yax→Sek→Ch'en→XCFE→Xul); each node executes its declared operator only when the runtime phase matches its phase field. Two-loop update principle: inner loop (θ per step within BoundedStepContract) = Sek→Ch'en; outer loop (G topology per epoch) = full Ch'en→XCFE→XulGate. See §17–§18 of KUHUL-FIELD.md."
  phase_theta 0.0

  node [
    id 1
    label "corpus.scope"
    operator "arc.read"
    phase "pop"
    authority "candidate_only"
    schema "kuhul:trainer:corpus-scope:v1"
    comment "Pop phase: bind training corpus scope and context. Reads token sequence from active corpus handle. candidate_only — no authority before Ch'en."
    confidence 1.0
    static_weight 1.0
  ]

  node [
    id 2
    label "session.agent"
    operator "arc.delegate"
    phase "wo"
    authority "candidate_only"
    schema "kuhul:trainer:session-agent:v1"
    provider_id "TRAINER-µ"
    comment "Wo phase: bind training session agent (TRAINER-µ) and planning policy. Establishes learning_rate schedule and gradient_clip bound for this session."
    learning_rate 1e-4
    gradient_clip 1.0
    confidence 1.0
  ]

  node [
    id 3
    label "candidate.expand"
    operator "arc.expand"
    phase "yax"
    authority "candidate_only"
    schema "kuhul:trainer:candidate-expand:v1"
    radius_type "graph_hops"
    radius 1
    path_aggregation "max_product"
    decay_mode "exponential"
    decay_rate 1.0
    comment "Yax phase: expand candidate parameter updates within radius 1 hop. Scores candidates by WCR (confidence × static_weight). No topology mutation yet."
    confidence 1.0
    static_weight 1.0
  ]

  node [
    id 4
    label "gradient.propose"
    operator "arc.call"
    phase "sek"
    authority "candidate_only"
    schema "kuhul:trainer:gradient-propose:v1"
    gradient_mode "routing_guidance"
    comment "Sek phase (inner loop): compute gradient proposal g = grad_phi L. routing_guidance only — no gradient_guidance until convergence certificate. GPU executes this speculatively; result is a candidate, not an authorized update."
    training_step 0
    grad_norm 0.0
    loss_value 0.0
  ]

  node [
    id 5
    label "convergence.verify"
    operator "arc.verify"
    phase "chen"
    authority "candidate_only"
    schema "kuhul:trainer:convergence-verify:v1"
    convergence_kind "empirical"
    convergence_value 0.001
    contract_scope "kuhul:trainer:bounded-step-contract:v1"
    contract_phase "chen"
    comment "Ch'en phase: accumulate convergence evidence. Empirical certificate requires N consecutive improvement steps ≥ convergence_value. GPU_RESULT ≠ PROOF — gradient norm alone does not certify convergence. BoundedStepContract is scoped here."
    confidence 1.0
  ]

  node [
    id 6
    label "xcfe.gate"
    operator "arc.authorize"
    phase "xcfe"
    authority "xcfe_admitted"
    schema "kuhul:trainer:xcfe-gate:v1"
    contract_scope "kuhul:trainer:bounded-step-contract:v1"
    comment "XCFE gate: dispatch authority check on the convergence certificate. Admits the parameter update proposal only when Ch'en certificate is present. XCFE covers the entire BoundedStepContract scope — not each individual gradient step."
    confidence 1.0
    static_weight 1.0
  ]

  node [
    id 7
    label "theta.commit"
    operator "arc.commit"
    phase "xul"
    authority "xcfe_admitted"
    schema "kuhul:trainer:theta-commit:v1"
    comment "Xul phase (inner loop close): commit authorized parameter update theta_next = theta - eta * clip(g, clip). Inner loop: theta updates within BoundedStepContract. Outer loop (G topology): full Ch'en→XCFE→XulGate required for topology mutation."
    training_step 0
    parameter_id "theta"
    confidence 1.0
  ]

  node [
    id 8
    label "topology.epoch"
    operator "arc.commit"
    phase "xul"
    authority "xcfe_admitted"
    schema "kuhul:trainer:topology-epoch:v1"
    comment "Xul phase (outer loop): commit topology change G_next after full epoch. Requires separate Ch'en proof + XCFE authorization for each topology mutation — a new BoundedStepContract scope per epoch. INACTIVE nodes are NOT deleted (Matryoshka invariant)."
    contract_scope "kuhul:trainer:topology-epoch-contract:v1"
    convergence_kind "empirical"
    is_active 1
    confidence 1.0
  ]

  edge [
    source 1
    target 2
    verb "@delegates_to"
    weight 1.0
    label "corpus -> session"
  ]

  edge [
    source 2
    target 3
    verb "@delegates_to"
    weight 1.0
    label "session -> expand"
  ]

  edge [
    source 3
    target 4
    verb "@calls"
    weight 1.0
    label "expand -> gradient"
  ]

  edge [
    source 4
    target 5
    verb "@calls"
    weight 1.0
    label "gradient -> verify"
    grad_norm 0.0
    training_step 0
  ]

  edge [
    source 5
    target 6
    verb "@requires"
    weight 1.0
    label "verify -> xcfe"
    comment "Ch'en certificate required before XCFE gate opens."
  ]

  edge [
    source 6
    target 7
    verb "@calls"
    weight 1.0
    label "xcfe -> theta.commit"
    comment "Inner loop: theta update per step within contract."
  ]

  edge [
    source 6
    target 8
    verb "@calls"
    weight 0.1
    label "xcfe -> topology.epoch"
    comment "Outer loop: topology commit per epoch. Low weight — infrequent path."
  ]

  edge [
    id 10
    source 7
    target 4
    verb "@calls"
    weight 1.0
    label "inner loop back-edge"
    comment "Inner training loop: theta.commit -> gradient.propose for next step within BoundedStepContract. Loop continues while contract is active and Ch'en gate admits."
  ]
]
