graph [
  comment "PI-radius depth-prior bias topology. Each pi_anchor node carries the depth_prior for its glyph; edges to weight:pi_routing declare that prior as a feature weight. Topology only: no mutation authority, no admission, no persistence. Regenerate with tools/build_pi_radius_bias.py."
  directed 1
  label "PI_Radius_Bias_Graph"
  parameter_family "pi_routing"
  update_target "W_pi_routing"
  authority "data_only"
  source "C:\\Users\\canna\\.ui-shell\\io\\aiml-grams\\domain-word-tree.v1.json"

  node [
    id 1
    label "pi_anchor:⟁ANIMAL"
    kind "pi_anchor"
    glyph "⟁ANIMAL"
    pi_depth 2
    depth_prior 0.8
  ]

  node [
    id 2
    label "pi_anchor:⟁BALL"
    kind "pi_anchor"
    glyph "⟁BALL"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 3
    label "pi_anchor:⟁BARK"
    kind "pi_anchor"
    glyph "⟁BARK"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 4
    label "pi_anchor:⟁BAT"
    kind "pi_anchor"
    glyph "⟁BAT"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 5
    label "pi_anchor:⟁BICYCLE"
    kind "pi_anchor"
    glyph "⟁BICYCLE"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 6
    label "pi_anchor:⟁BIRD"
    kind "pi_anchor"
    glyph "⟁BIRD"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 7
    label "pi_anchor:⟁BOAT"
    kind "pi_anchor"
    glyph "⟁BOAT"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 8
    label "pi_anchor:⟁BUS"
    kind "pi_anchor"
    glyph "⟁BUS"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 9
    label "pi_anchor:⟁CAR"
    kind "pi_anchor"
    glyph "⟁CAR"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 10
    label "pi_anchor:⟁CARGO"
    kind "pi_anchor"
    glyph "⟁CARGO"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 11
    label "pi_anchor:⟁CAT"
    kind "pi_anchor"
    glyph "⟁CAT"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 12
    label "pi_anchor:⟁DOG"
    kind "pi_anchor"
    glyph "⟁DOG"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 13
    label "pi_anchor:⟁DRIVER"
    kind "pi_anchor"
    glyph "⟁DRIVER"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 14
    label "pi_anchor:⟁ENERGY"
    kind "pi_anchor"
    glyph "⟁ENERGY"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 15
    label "pi_anchor:⟁ENGINE"
    kind "pi_anchor"
    glyph "⟁ENGINE"
    pi_depth 2
    depth_prior 0.8
  ]

  node [
    id 16
    label "pi_anchor:⟁FIELD"
    kind "pi_anchor"
    glyph "⟁FIELD"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 17
    label "pi_anchor:⟁FLAT"
    kind "pi_anchor"
    glyph "⟁FLAT"
    pi_depth 8
    depth_prior 0.2
  ]

  node [
    id 18
    label "pi_anchor:⟁FLOW"
    kind "pi_anchor"
    glyph "⟁FLOW"
    pi_depth 2
    depth_prior 0.8
  ]

  node [
    id 19
    label "pi_anchor:⟁FUR"
    kind "pi_anchor"
    glyph "⟁FUR"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 20
    label "pi_anchor:⟁GAME"
    kind "pi_anchor"
    glyph "⟁GAME"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 21
    label "pi_anchor:⟁GROWTH"
    kind "pi_anchor"
    glyph "⟁GROWTH"
    pi_depth 2
    depth_prior 0.8
  ]

  node [
    id 22
    label "pi_anchor:⟁HORSE"
    kind "pi_anchor"
    glyph "⟁HORSE"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 23
    label "pi_anchor:⟁MATTER"
    kind "pi_anchor"
    glyph "⟁MATTER"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 24
    label "pi_anchor:⟁MEOW"
    kind "pi_anchor"
    glyph "⟁MEOW"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 25
    label "pi_anchor:⟁MOTION"
    kind "pi_anchor"
    glyph "⟁MOTION"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 26
    label "pi_anchor:⟁MOTORCYCLE"
    kind "pi_anchor"
    glyph "⟁MOTORCYCLE"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 27
    label "pi_anchor:⟁PASSENGER"
    kind "pi_anchor"
    glyph "⟁PASSENGER"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 28
    label "pi_anchor:⟁PATH"
    kind "pi_anchor"
    glyph "⟁PATH"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 29
    label "pi_anchor:⟁PAW"
    kind "pi_anchor"
    glyph "⟁PAW"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 30
    label "pi_anchor:⟁PHYSICAL"
    kind "pi_anchor"
    glyph "⟁PHYSICAL"
    pi_depth 0
    depth_prior 1.0
  ]

  node [
    id 31
    label "pi_anchor:⟁PITCH"
    kind "pi_anchor"
    glyph "⟁PITCH"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 32
    label "pi_anchor:⟁PLANE"
    kind "pi_anchor"
    glyph "⟁PLANE"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 33
    label "pi_anchor:⟁ROAD"
    kind "pi_anchor"
    glyph "⟁ROAD"
    pi_depth 7
    depth_prior 0.3
  ]

  node [
    id 34
    label "pi_anchor:⟁ROTATION"
    kind "pi_anchor"
    glyph "⟁ROTATION"
    pi_depth 2
    depth_prior 0.8
  ]

  node [
    id 35
    label "pi_anchor:⟁SCORE"
    kind "pi_anchor"
    glyph "⟁SCORE"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 36
    label "pi_anchor:⟁SPORTS"
    kind "pi_anchor"
    glyph "⟁SPORTS"
    pi_depth 2
    depth_prior 0.8
  ]

  node [
    id 37
    label "pi_anchor:⟁SWING"
    kind "pi_anchor"
    glyph "⟁SWING"
    pi_depth 2
    depth_prior 0.8
  ]

  node [
    id 38
    label "pi_anchor:⟁TIRE"
    kind "pi_anchor"
    glyph "⟁TIRE"
    pi_depth 4
    depth_prior 0.6
  ]

  node [
    id 39
    label "pi_anchor:⟁TRAIN"
    kind "pi_anchor"
    glyph "⟁TRAIN"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 40
    label "pi_anchor:⟁TRANSPORT"
    kind "pi_anchor"
    glyph "⟁TRANSPORT"
    pi_depth 2
    depth_prior 0.8
  ]

  node [
    id 41
    label "pi_anchor:⟁TRUCK"
    kind "pi_anchor"
    glyph "⟁TRUCK"
    pi_depth 1
    depth_prior 0.9
  ]

  node [
    id 42
    label "pi_anchor:⟁VEHICLE"
    kind "pi_anchor"
    glyph "⟁VEHICLE"
    pi_depth 3
    depth_prior 0.7
  ]

  node [
    id 43
    label "pi_anchor:⟁WHEEL"
    kind "pi_anchor"
    glyph "⟁WHEEL"
    pi_depth 4
    depth_prior 0.6
  ]

  node [
    id 1000
    label "weight:pi_routing"
    kind "learned_parameter"
    weight 1.0
    family "pi_routing"
  ]

  edge [
    source 1
    target 1000
    label "pi_bias"
    feature 0.8
  ]

  edge [
    source 2
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 3
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 4
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 5
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 6
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 7
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 8
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 9
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 10
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 11
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 12
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 13
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 14
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 15
    target 1000
    label "pi_bias"
    feature 0.8
  ]

  edge [
    source 16
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 17
    target 1000
    label "pi_bias"
    feature 0.2
  ]

  edge [
    source 18
    target 1000
    label "pi_bias"
    feature 0.8
  ]

  edge [
    source 19
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 20
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 21
    target 1000
    label "pi_bias"
    feature 0.8
  ]

  edge [
    source 22
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 23
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 24
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 25
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 26
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 27
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 28
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 29
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 30
    target 1000
    label "pi_bias"
    feature 1.0
  ]

  edge [
    source 31
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 32
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 33
    target 1000
    label "pi_bias"
    feature 0.3
  ]

  edge [
    source 34
    target 1000
    label "pi_bias"
    feature 0.8
  ]

  edge [
    source 35
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 36
    target 1000
    label "pi_bias"
    feature 0.8
  ]

  edge [
    source 37
    target 1000
    label "pi_bias"
    feature 0.8
  ]

  edge [
    source 38
    target 1000
    label "pi_bias"
    feature 0.6
  ]

  edge [
    source 39
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 40
    target 1000
    label "pi_bias"
    feature 0.8
  ]

  edge [
    source 41
    target 1000
    label "pi_bias"
    feature 0.9
  ]

  edge [
    source 42
    target 1000
    label "pi_bias"
    feature 0.7
  ]

  edge [
    source 43
    target 1000
    label "pi_bias"
    feature 0.6
  ]

]
