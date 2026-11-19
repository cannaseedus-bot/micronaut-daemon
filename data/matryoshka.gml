graph [
  directed 1
  label "matryoshka.gml"
  comment "Matryoshka semantic working-set controller. Implements progressive resolution: 32D -> 128D -> 256D -> exact AIML. The AIML corpus is the union of three stores: Compact Vector Index + Exact Symbolic Store + GML Relationships. INACTIVE != DELETED. Active keys form a semantic working-set; inactive keys remain in the corpus and can be reactivated by the outer loop (topology.epoch in trainer.gml). See §20 of KUHUL-FIELD.md."
  phase_theta 0.0

  node [
    id 1
    label "index.scope"
    operator "arc.read"
    phase "pop"
    authority "candidate_only"
    schema "kuhul:matryoshka:index-scope:v1"
    dimensions 32
    comment "Pop phase: bind compact vector index scope (32D). Reads from pattern_vectors.f32.npy. Coordinates are projection metadata — topology-before-coordinates invariant."
    confidence 1.0
    static_weight 1.0
    is_active 1
  ]

  node [
    id 2
    label "intent.agent"
    operator "arc.delegate"
    phase "wo"
    authority "candidate_only"
    schema "kuhul:matryoshka:intent-agent:v1"
    provider_id "EmbeddingGemma-2"
    comment "Wo phase: bind intent query agent (EmbeddingGemma 2). Embeds the query at 32D for initial scope binding."
    dimensions 32
    confidence 1.0
  ]

  node [
    id 3
    label "expand.32d"
    operator "arc.expand"
    phase "yax"
    authority "candidate_only"
    schema "kuhul:matryoshka:expand-32d:v1"
    radius_type "vector_distance"
    radius_distance 0.3
    path_aggregation "max_product"
    dimensions 32
    comment "Yax phase: compact 32D index scan. vector_distance radius 0.3 is a soft boundary — not an access grant. Retrieves candidate AIML keys from compact index without full embedding."
    confidence 1.0
    static_weight 1.0
    is_active 1
  ]

  node [
    id 4
    label "expand.128d"
    operator "arc.expand"
    phase "sek"
    authority "candidate_only"
    schema "kuhul:matryoshka:expand-128d:v1"
    radius_type "vector_distance"
    radius_distance 0.15
    path_aggregation "max_product"
    dimensions 128
    decay_mode "exponential"
    decay_rate 2.0
    gradient_mode "routing_guidance"
    comment "Sek phase: promote candidates to 128D. Tighter radius narrows the working set. routing_guidance only — no gradient_guidance until convergence certificate. EmbeddingGemma 2 Matryoshka truncation caveat: 32D/128D resolution requires evaluation — not guaranteed unless trained with Matryoshka loss."
    confidence 1.0
    is_active 1
  ]

  node [
    id 5
    label "promote.256d"
    operator "arc.call"
    phase "sek"
    authority "candidate_only"
    schema "kuhul:matryoshka:promote-256d:v1"
    radius_type "vector_distance"
    radius_distance 0.08
    path_aggregation "max_product"
    dimensions 256
    decay_mode "exponential"
    decay_rate 4.0
    gradient_mode "routing_guidance"
    comment "Sek phase: promote remaining candidates to full 256D for high-resolution ranking. Only top-k from 128D stage reach this node. GPU executes speculatively — result is a candidate, not an authorized route."
    confidence 1.0
    is_active 1
  ]

  node [
    id 6
    label "exact.aiml"
    operator "arc.call"
    phase "sek"
    authority "candidate_only"
    schema "kuhul:matryoshka:exact-aiml:v1"
    comment "Sek phase: exact AIML symbolic lookup for the top candidate from the 256D stage. Retrieves pattern + template from the in-memory AIML corpus. INACTIVE keys are present in corpus but not retrieved in this traversal — INACTIVE != DELETED."
    confidence 1.0
    is_active 1
  ]

  node [
    id 7
    label "semantic.verify"
    operator "arc.verify"
    phase "chen"
    authority "candidate_only"
    schema "kuhul:matryoshka:semantic-verify:v1"
    convergence_kind "none"
    contract_scope "kuhul:matryoshka:working-set-contract:v1"
    contract_phase "chen"
    comment "Ch'en phase: verify semantic working-set selection. Checks AIML category match quality, wildcard-count compatibility, and field scope. GPU cosine scores are candidate evidence, not proof."
    confidence 1.0
  ]

  node [
    id 8
    label "xcfe.gate"
    operator "arc.authorize"
    phase "xcfe"
    authority "xcfe_admitted"
    schema "kuhul:matryoshka:xcfe-gate:v1"
    contract_scope "kuhul:matryoshka:working-set-contract:v1"
    comment "XCFE gate: admits the semantic working-set proposal. Vector similarity alone does not authorize route dispatch — XCFE admission is required."
    confidence 1.0
    static_weight 1.0
  ]

  node [
    id 9
    label "workingset.commit"
    operator "arc.commit"
    phase "xul"
    authority "xcfe_admitted"
    schema "kuhul:matryoshka:workingset-commit:v1"
    is_active 1
    comment "Xul phase: commit the active working-set G_active = SelectKeys(G, intent, r, pi). Updates G_active and theta_active for trainer.gml cascade. INACTIVE keys remain in corpus (INACTIVE != DELETED) and can be reactivated by the outer topology.epoch loop."
    confidence 1.0
  ]

  edge [
    source 1
    target 2
    verb "@delegates_to"
    weight 1.0
    label "index -> intent"
  ]

  edge [
    source 2
    target 3
    verb "@calls"
    weight 1.0
    label "intent -> expand.32d"
  ]

  edge [
    source 3
    target 4
    verb "@calls"
    weight 1.0
    label "32d -> 128d"
    comment "Progressive promotion: top candidates from 32D scan enter 128D stage."
    radius_influence 0.7
  ]

  edge [
    source 4
    target 5
    verb "@calls"
    weight 1.0
    label "128d -> 256d"
    comment "Top-k from 128D promoted to full 256D resolution."
    radius_influence 0.85
  ]

  edge [
    source 5
    target 6
    verb "@calls"
    weight 1.0
    label "256d -> exact.aiml"
    comment "Top candidate crosses into exact symbolic store for AIML pattern/template retrieval."
    radius_influence 0.9
  ]

  edge [
    source 6
    target 7
    verb "@calls"
    weight 1.0
    label "exact -> verify"
  ]

  edge [
    source 7
    target 8
    verb "@requires"
    weight 1.0
    label "verify -> xcfe"
  ]

  edge [
    source 8
    target 9
    verb "@calls"
    weight 1.0
    label "xcfe -> commit"
  ]

  edge [
    source 3
    target 7
    verb "@related_to"
    weight 0.3
    label "32d bypass"
    comment "Direct path for exact-match candidates that need no progressive promotion."
  ]
]
