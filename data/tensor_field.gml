graph [
  comment "TENSOR-µ local tensor-bundle projection. FieldParamRecord: read-only Riemannian metric tensor and curvature constants for VectorMuMicronaut::ExecuteProjection parallel transport. g_00/g_01/g_11 form the local metric; riemann_curvature_scalar=-0.412 marks a hyperbolic region. Not topology — no adjacency. MML contracts: data/grammar/mml/v1/GMLTopology.mml (FieldParamRecord law), data/grammar/mml/v1/WildcardFieldResolution.mml (capture key family: curvature/metric/tensor/bundle)."
  directed 1
  id 1501
  label "Tensor_Bundle_Projection_Field"

  node [
    id 1
    label "Tensor_Source"
    x 0.0 y 0.0 z 0.0
    tensor_rank_p 1
    tensor_rank_q 1
    is_smooth_section 1
    jacobian_determinant 1.0834
    riemann_curvature_scalar -0.412
  ]

  node [
    id 2
    label "Tensor_Target"
    x 1.0 y 0.0 z 0.0
    tensor_rank_p 1
    tensor_rank_q 1
    is_smooth_section 1
  ]

  edge [
    source 1 target 2
    label "coordinate_transition"
    verb "@requires"
    field_kind "tensor_field"
    weight 1.0
    g_00 -0.8524
    g_01 0.0125
    g_10 0.0125
    g_11 1.1486
    jacobian_w 1.0834
    vx 0.1 vy 0.0 vz 0.0
  ]
]
