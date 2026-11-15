graph [
  comment "Quantum/plane-wave/vector-field boundary asset for VECTOR-mu projection contracts. FieldParamRecord: read-only wave physics constants for dispatch_geodesic_propagator() boundary condition setup. wave_number, refractive index, amplitude_re/im, and phase_shift are cbuffer-equivalent constants. refractive=3.4 on boundary_reset_bridge signals a high-impedance reset point. Not topology — three nodes define boundary types (Kirchhoff source/sink, Robin mixed), not adjacency. MML contracts: data/grammar/mml/v1/GMLTopology.mml (FieldParamRecord law), data/grammar/mml/v1/WildcardFieldResolution.mml (capture key family: wave/boundary/refractive/frequency)."
  directed 1
  id 1206
  label "Quantum_Field_Boundaries"

  node [
    id 1
    label "Query_Origin"
    x -2.0 y 0.0 z 0.0
    boundary_type "kirchhoff"
    vertex_pot 0.0
    phase_shift 0.0
    divergence 1.0
    singularity "source"
    text_boundary "article"
    boundary_token "◄art►"
  ]

  node [
    id 2
    label "Sentence_Sink"
    x 0.0 y 0.0 z 0.0
    boundary_type "kirchhoff"
    vertex_pot 0.0
    phase_shift 0.7853
    divergence -1.0
    singularity "sink"
    text_boundary "sentence"
    boundary_token "◄/s►"
  ]

  node [
    id 3
    label "Paragraph_Source"
    x 2.0 y 0.0 z 0.0
    boundary_type "robin"
    vertex_pot 0.2
    phase_shift 1.5708
    divergence 0.5
    singularity "source"
    text_boundary "paragraph"
    boundary_token "◄par►"
  ]

  edge [
    id 101
    source 1 target 2
    label "query_to_sentence_wave"
    verb "@requires"
    weight 1.0
    length 3.0
    potential 0.5
    refractive 1.0
    wave_number 2.1
    frequency 0.75
    amplitude_re 1.0
    amplitude_im 0.0
    vx 0.75 vy 0.0 vz 0.0
  ]

  edge [
    id 102
    source 2 target 3
    label "boundary_reset_bridge"
    verb "@defines"
    weight 0.9
    length 1.5
    potential 1.5
    refractive 3.4
    wave_number 1.4
    frequency 0.75
    amplitude_re 0.7
    amplitude_im 0.2
    vx 0.5 vy 0.25 vz 0.0
  ]
]
