graph [
  comment "Entropy Gradient Vector Field — Ambiguity Gating Matrix. FieldParamRecord: read-only parameter vector for the Omega gate EntropyDiffusion check (vectors.mml CaptureGate). Node attributes entropy_bound and diffusion_beta_inv are cbuffer-equivalent constants, not topology. MML contracts: data/grammar/mml/v1/GMLTopology.mml (FieldParamRecord law), data/grammar/mml/v1/WildcardFieldResolution.mml (capture key family: entropy/ambiguity/diffusion)."
  directed 1
  id 1402
  label "Entropy_Gradient_Manifold"

  node [
    id 10
    label "The verified user authenticated successfully."
    x -1.0 y 0.5 z 0.0
    local_entropy 0.15
    entropy_spike 0.00
    entropy_bound 4.00
    diffusion_beta_inv 0.25
  ]

  node [
    id 20
    label "Initiate conditional multi-task system response pathways."
    x 1.5 y -0.5 z 0.5
    local_entropy 3.82
    entropy_spike 3.67
    entropy_bound 4.00
    diffusion_beta_inv 0.25
  ]

  edge [
    source 10 target 20
    label "divergent_trajectory_line"
    verb "@delegates_to"
    weight 0.75
    field_kind "entropy_gradient"
    eh_x 2.50
    eh_y -1.00
    eh_z 0.50
    entropy_delta 3.67
    diffusion_beta_inv 0.25
  ]
]
