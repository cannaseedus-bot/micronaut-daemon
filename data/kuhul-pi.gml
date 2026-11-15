graph [
  comment "K'UHUL π graph carrier: unified vector-field graph over the K'UHUL domain vocabulary. Each semantic node carries V_π = [pi_depth, pi_radius, pi_weight, cohesion, domain_sim, centroid_norm]. V_A / V_B / V_M (EmbeddingGemma 256D) are referenced by record_count and glyph label; tensor data lives in category_vectors.f32.npy. Edges encode domain-tree relationships with XCFE operator labels. Regenerate with tools/build_kuhul_pi_gml.py."
  directed 1
  version "kuhul-pi/1"
  label "KUHUL_PI_Carrier"
  update_target "V_pi"
  authority "data_only"
  source_tree "C:\\Users\\canna\\.ui-shell\\io\\aiml-grams\\domain-word-tree.v1.json"
  source_vectors "C:\\Users\\canna\\.ui-shell\\io\\aiml-embeddinggemma2-vectors\\category_vectors.f32.npy"
  pi_max_depth 10

  node [
    id 1
    label "⟁ANIMAL"
    kind "semantic"
    node_kind "domain"
    domain "⟁MOTION"
    pi_depth 2
    pi_radius 0.6283185307179586
    pi_weight 0.8
    cohesion 0.93691836
    domain_sim 0.97036928
    centroid_norm 0.96827418
    record_count 216
  ]

  node [
    id 2
    label "⟁BALL"
    kind "semantic"
    node_kind "member"
    domain "⟁SPORTS"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.93415498
    domain_sim 0.9786669
    centroid_norm 0.96704078
    record_count 65
  ]

  node [
    id 3
    label "⟁BARK"
    kind "semantic"
    node_kind "associated"
    domain "⟁ANIMAL"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 0.95813316
    domain_sim 0.98394907
    centroid_norm 0.9794054
    record_count 38
  ]

  node [
    id 4
    label "⟁BAT"
    kind "semantic"
    node_kind "member"
    domain "⟁SPORTS"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.93382987
    domain_sim 0.96702141
    centroid_norm 0.96897882
    record_count 13
  ]

  node [
    id 5
    label "⟁BICYCLE"
    kind "semantic"
    node_kind "member"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.95343689
    domain_sim 0.9830721
    centroid_norm 0.97710299
    record_count 36
  ]

  node [
    id 6
    label "⟁BIRD"
    kind "semantic"
    node_kind "member"
    domain "⟁ANIMAL"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.94666439
    domain_sim 0.98769945
    centroid_norm 0.9731214
    record_count 143
  ]

  node [
    id 7
    label "⟁BOAT"
    kind "semantic"
    node_kind "member"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.94589969
    domain_sim 0.97966653
    centroid_norm 0.97368562
    record_count 25
  ]

  node [
    id 8
    label "⟁BUS"
    kind "semantic"
    node_kind "member"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.93871855
    domain_sim 0.98525691
    centroid_norm 0.97063023
    record_count 18
  ]

  node [
    id 9
    label "⟁CAR"
    kind "semantic"
    node_kind "member"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.94234848
    domain_sim 0.99380177
    centroid_norm 0.97092468
    record_count 304
  ]

  node [
    id 10
    label "⟁CARGO"
    kind "semantic"
    node_kind "domain"
    domain "⟁TRANSPORT"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 1.0
    domain_sim 0.91620189
    centroid_norm 1.0
    record_count 1
  ]

  node [
    id 11
    label "⟁CAT"
    kind "semantic"
    node_kind "member"
    domain "⟁ANIMAL"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.94800395
    domain_sim 0.99263316
    centroid_norm 0.97379738
    record_count 249
  ]

  node [
    id 12
    label "⟁DOG"
    kind "semantic"
    node_kind "member"
    domain "⟁ANIMAL"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.94501781
    domain_sim 0.99257398
    centroid_norm 0.97218722
    record_count 336
  ]

  node [
    id 13
    label "⟁DRIVER"
    kind "semantic"
    node_kind "associated"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.91468292
    domain_sim 0.98105013
    centroid_norm 0.96133369
    record_count 9
  ]

  node [
    id 14
    label "⟁ENERGY"
    kind "semantic"
    node_kind "domain"
    domain "⟁PHYSICAL"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.93041914
    domain_sim 0.98319674
    centroid_norm 0.96505684
    record_count 76
  ]

  node [
    id 15
    label "⟁ENGINE"
    kind "semantic"
    node_kind "associated"
    domain "⟁VEHICLE"
    pi_depth 2
    pi_radius 0.6283185307179586
    pi_weight 0.8
    cohesion 0.92284937
    domain_sim 0.98497367
    centroid_norm 0.96190447
    record_count 32
  ]

  node [
    id 16
    label "⟁FIELD"
    kind "semantic"
    node_kind "associated"
    domain "⟁SPORTS"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 0.85741155
    domain_sim 0.97081757
    centroid_norm 0.93000871
    record_count 19
  ]

  node [
    id 17
    label "⟁FLAT"
    kind "semantic"
    node_kind "associated"
    domain "⟁VEHICLE"
    pi_depth 8
    pi_radius 2.5132741228718345
    pi_weight 0.2
    cohesion 0.93788022
    domain_sim 0.97891718
    centroid_norm 0.96911007
    record_count 48
  ]

  node [
    id 18
    label "⟁FLOW"
    kind "semantic"
    node_kind "domain"
    domain "⟁MOTION"
    pi_depth 2
    pi_radius 0.6283185307179586
    pi_weight 0.8
    cohesion 0.92915559
    domain_sim 0.97628492
    centroid_norm 0.96484542
    record_count 40
  ]

  node [
    id 19
    label "⟁FUR"
    kind "semantic"
    node_kind "associated"
    domain "⟁ANIMAL"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 0.95504823
    domain_sim 0.98840648
    centroid_norm 0.97811705
    record_count 27
  ]

  node [
    id 20
    label "⟁GAME"
    kind "semantic"
    node_kind "member"
    domain "⟁SPORTS"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.92412508
    domain_sim 0.97686261
    centroid_norm 0.96125889
    record_count 267
  ]

  node [
    id 21
    label "⟁GROWTH"
    kind "semantic"
    node_kind "domain"
    domain "⟁MOTION"
    pi_depth 2
    pi_radius 0.6283185307179586
    pi_weight 0.8
    cohesion 0.87204345
    domain_sim 0.97003007
    centroid_norm 0.94518226
    record_count 6
  ]

  node [
    id 22
    label "⟁HORSE"
    kind "semantic"
    node_kind "member"
    domain "⟁ANIMAL"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.94806757
    domain_sim 0.98823661
    centroid_norm 0.97402513
    record_count 79
  ]

  node [
    id 23
    label "⟁MATTER"
    kind "semantic"
    node_kind "domain"
    domain "⟁PHYSICAL"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.92274635
    domain_sim 0.9904846
    centroid_norm 0.9609251
    record_count 130
  ]

  node [
    id 24
    label "⟁MEOW"
    kind "semantic"
    node_kind "associated"
    domain "⟁ANIMAL"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 0.96499343
    domain_sim 0.98140037
    centroid_norm 0.98456556
    record_count 8
  ]

  node [
    id 25
    label "⟁MOTION"
    kind "semantic"
    node_kind "domain"
    domain "⟁PHYSICAL"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.90852124
    domain_sim 0.98431778
    centroid_norm 0.95751631
    record_count 11
  ]

  node [
    id 26
    label "⟁MOTORCYCLE"
    kind "semantic"
    node_kind "member"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.93979592
    domain_sim 0.98029459
    centroid_norm 0.9728747
    record_count 9
  ]

  node [
    id 27
    label "⟁PASSENGER"
    kind "semantic"
    node_kind "domain"
    domain "⟁TRANSPORT"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 0.88121761
    domain_sim 0.97064686
    centroid_norm 0.94921786
    record_count 6
  ]

  node [
    id 28
    label "⟁PATH"
    kind "semantic"
    node_kind "domain"
    domain "⟁TRANSPORT"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 1.0
    domain_sim 0.95038146
    centroid_norm 1.0
    record_count 1
  ]

  node [
    id 29
    label "⟁PAW"
    kind "semantic"
    node_kind "associated"
    domain "⟁ANIMAL"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 1.0
    domain_sim 0.89836997
    centroid_norm 1.0
    record_count 1
  ]

  node [
    id 30
    label "⟁PHYSICAL"
    kind "semantic"
    node_kind "domain"
    domain "⟁PHYSICAL"
    pi_depth 0
    pi_radius 0.0
    pi_weight 1.0
    cohesion 0.90232567
    domain_sim 1.0
    centroid_norm 0.95091581
    record_count 51
  ]

  node [
    id 31
    label "⟁PITCH"
    kind "semantic"
    node_kind "associated"
    domain "⟁SPORTS"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 0.89025895
    domain_sim 0.96351999
    centroid_norm 0.96272492
    record_count 3
  ]

  node [
    id 32
    label "⟁PLANE"
    kind "semantic"
    node_kind "member"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.9210998
    domain_sim 0.98472077
    centroid_norm 0.96102315
    record_count 32
  ]

  node [
    id 33
    label "⟁ROAD"
    kind "semantic"
    node_kind "associated"
    domain "⟁VEHICLE"
    pi_depth 7
    pi_radius 2.199114857512855
    pi_weight 0.3
    cohesion 0.92695738
    domain_sim 0.98235804
    centroid_norm 0.96489131
    record_count 18
  ]

  node [
    id 34
    label "⟁ROTATION"
    kind "semantic"
    node_kind "domain"
    domain "⟁MOTION"
    pi_depth 2
    pi_radius 0.6283185307179586
    pi_weight 0.8
    cohesion 0.85654896
    domain_sim 0.96511525
    centroid_norm 0.94087148
    record_count 5
  ]

  node [
    id 35
    label "⟁SCORE"
    kind "semantic"
    node_kind "member"
    domain "⟁SPORTS"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.91509037
    domain_sim 0.97262377
    centroid_norm 0.9593733
    record_count 16
  ]

  node [
    id 36
    label "⟁SPORTS"
    kind "semantic"
    node_kind "domain"
    domain "⟁MOTION"
    pi_depth 2
    pi_radius 0.6283185307179586
    pi_weight 0.8
    cohesion 0.93748939
    domain_sim 0.9587177
    centroid_norm 0.96878737
    record_count 59
  ]

  node [
    id 37
    label "⟁SWING"
    kind "semantic"
    node_kind "associated"
    domain "⟁SPORTS"
    pi_depth 2
    pi_radius 0.6283185307179586
    pi_weight 0.8
    cohesion 0.88137498
    domain_sim 0.95452458
    centroid_norm 0.95447958
    record_count 4
  ]

  node [
    id 38
    label "⟁TIRE"
    kind "semantic"
    node_kind "associated"
    domain "⟁VEHICLE"
    pi_depth 4
    pi_radius 1.2566370614359172
    pi_weight 0.6
    cohesion 0.95160935
    domain_sim 0.9781962
    centroid_norm 0.9796297
    record_count 6
  ]

  node [
    id 39
    label "⟁TRAIN"
    kind "semantic"
    node_kind "member"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.92498889
    domain_sim 0.98055708
    centroid_norm 0.96310717
    record_count 29
  ]

  node [
    id 40
    label "⟁TRANSPORT"
    kind "semantic"
    node_kind "domain"
    domain "⟁MOTION"
    pi_depth 2
    pi_radius 0.6283185307179586
    pi_weight 0.8
    cohesion 0.95973878
    domain_sim 0.96825522
    centroid_norm 0.98137343
    record_count 12
  ]

  node [
    id 41
    label "⟁TRUCK"
    kind "semantic"
    node_kind "member"
    domain "⟁VEHICLE"
    pi_depth 1
    pi_radius 0.3141592653589793
    pi_weight 0.9
    cohesion 0.93933945
    domain_sim 0.98993927
    centroid_norm 0.97142804
    record_count 14
  ]

  node [
    id 42
    label "⟁VEHICLE"
    kind "semantic"
    node_kind "domain"
    domain "⟁TRANSPORT"
    pi_depth 3
    pi_radius 0.9424777960769379
    pi_weight 0.7
    cohesion 0.92482558
    domain_sim 0.98575276
    centroid_norm 0.96446627
    record_count 14
  ]

  node [
    id 43
    label "⟁WHEEL"
    kind "semantic"
    node_kind "associated"
    domain "⟁VEHICLE"
    pi_depth 4
    pi_radius 1.2566370614359172
    pi_weight 0.6
    cohesion 0.93208512
    domain_sim 0.98422813
    centroid_norm 0.96729499
    record_count 19
  ]

  edge [
    source 25
    target 1
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 1
    target 12
    relation "membership"
    operator "map"
  ]

  edge [
    source 1
    target 11
    relation "membership"
    operator "map"
  ]

  edge [
    source 1
    target 22
    relation "membership"
    operator "map"
  ]

  edge [
    source 1
    target 6
    relation "membership"
    operator "map"
  ]

  edge [
    source 1
    target 29
    relation "association"
    operator "filter"
  ]

  edge [
    source 1
    target 19
    relation "association"
    operator "filter"
  ]

  edge [
    source 1
    target 3
    relation "association"
    operator "filter"
  ]

  edge [
    source 1
    target 24
    relation "association"
    operator "filter"
  ]

  edge [
    source 40
    target 10
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 30
    target 14
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 25
    target 18
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 25
    target 21
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 30
    target 23
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 30
    target 25
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 40
    target 27
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 40
    target 28
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 25
    target 34
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 25
    target 36
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 36
    target 4
    relation "membership"
    operator "map"
  ]

  edge [
    source 36
    target 2
    relation "membership"
    operator "map"
  ]

  edge [
    source 36
    target 20
    relation "membership"
    operator "map"
  ]

  edge [
    source 36
    target 35
    relation "membership"
    operator "map"
  ]

  edge [
    source 36
    target 37
    relation "association"
    operator "filter"
  ]

  edge [
    source 36
    target 31
    relation "association"
    operator "filter"
  ]

  edge [
    source 36
    target 16
    relation "association"
    operator "filter"
  ]

  edge [
    source 25
    target 40
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 40
    target 42
    relation "hierarchy"
    operator "fold"
  ]

  edge [
    source 42
    target 9
    relation "membership"
    operator "map"
  ]

  edge [
    source 42
    target 41
    relation "membership"
    operator "map"
  ]

  edge [
    source 42
    target 8
    relation "membership"
    operator "map"
  ]

  edge [
    source 42
    target 26
    relation "membership"
    operator "map"
  ]

  edge [
    source 42
    target 5
    relation "membership"
    operator "map"
  ]

  edge [
    source 42
    target 39
    relation "membership"
    operator "map"
  ]

  edge [
    source 42
    target 7
    relation "membership"
    operator "map"
  ]

  edge [
    source 42
    target 32
    relation "membership"
    operator "map"
  ]

  edge [
    source 42
    target 43
    relation "association"
    operator "filter"
  ]

  edge [
    source 42
    target 15
    relation "association"
    operator "filter"
  ]

  edge [
    source 42
    target 33
    relation "association"
    operator "filter"
  ]

  edge [
    source 42
    target 13
    relation "association"
    operator "filter"
  ]

  edge [
    source 42
    target 38
    relation "association"
    operator "filter"
  ]

  edge [
    source 42
    target 17
    relation "association"
    operator "filter"
  ]

]
