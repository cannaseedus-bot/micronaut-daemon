graph [
  comment "Semantic cohesion bias topology derived from runtime AIML category embeddings (pattern+template midpoint vectors, google/embeddinggemma-2). centroid_norm = L2 norm of mean category vector for matching AIML categories; cohesion = mean pairwise cosine among those category vectors; domain_sim = cosine similarity centroid to primary/parent domain centroid. Word matching: exact token boundaries in pattern+template text. Edge feature = cohesion; wires to weight:semantic_cohesion. Regenerate with tools/build_vectors_gml.py."
  directed 1
  label "Semantic_Cohesion_Graph"
  parameter_family "semantic_cohesion"
  update_target "W_semantic_cohesion"
  authority "data_only"
  source "C:\\Users\\canna\\.ui-shell\\io\\aiml-embeddinggemma2-vectors\\category_vectors.f32.npy"

  node [
    id 1
    label "sem_anchor:⟁ANIMAL"
    kind "sem_anchor"
    glyph "⟁ANIMAL"
    centroid_norm 0.96827418
    cohesion 0.93691836
    domain_sim 0.97036928
    record_count 216
  ]

  node [
    id 2
    label "sem_anchor:⟁BALL"
    kind "sem_anchor"
    glyph "⟁BALL"
    centroid_norm 0.96704078
    cohesion 0.93415498
    domain_sim 0.9786669
    record_count 65
  ]

  node [
    id 3
    label "sem_anchor:⟁BARK"
    kind "sem_anchor"
    glyph "⟁BARK"
    centroid_norm 0.9794054
    cohesion 0.95813316
    domain_sim 0.98394907
    record_count 38
  ]

  node [
    id 4
    label "sem_anchor:⟁BAT"
    kind "sem_anchor"
    glyph "⟁BAT"
    centroid_norm 0.96897882
    cohesion 0.93382987
    domain_sim 0.96702141
    record_count 13
  ]

  node [
    id 5
    label "sem_anchor:⟁BICYCLE"
    kind "sem_anchor"
    glyph "⟁BICYCLE"
    centroid_norm 0.97710299
    cohesion 0.95343689
    domain_sim 0.9830721
    record_count 36
  ]

  node [
    id 6
    label "sem_anchor:⟁BIRD"
    kind "sem_anchor"
    glyph "⟁BIRD"
    centroid_norm 0.9731214
    cohesion 0.94666439
    domain_sim 0.98769945
    record_count 143
  ]

  node [
    id 7
    label "sem_anchor:⟁BOAT"
    kind "sem_anchor"
    glyph "⟁BOAT"
    centroid_norm 0.97368562
    cohesion 0.94589969
    domain_sim 0.97966653
    record_count 25
  ]

  node [
    id 8
    label "sem_anchor:⟁BUS"
    kind "sem_anchor"
    glyph "⟁BUS"
    centroid_norm 0.97063023
    cohesion 0.93871855
    domain_sim 0.98525691
    record_count 18
  ]

  node [
    id 9
    label "sem_anchor:⟁CAR"
    kind "sem_anchor"
    glyph "⟁CAR"
    centroid_norm 0.97092468
    cohesion 0.94234848
    domain_sim 0.99380177
    record_count 304
  ]

  node [
    id 10
    label "sem_anchor:⟁CARGO"
    kind "sem_anchor"
    glyph "⟁CARGO"
    centroid_norm 1.0
    cohesion 1.0
    domain_sim 0.91620189
    record_count 1
  ]

  node [
    id 11
    label "sem_anchor:⟁CAT"
    kind "sem_anchor"
    glyph "⟁CAT"
    centroid_norm 0.97379738
    cohesion 0.94800395
    domain_sim 0.99263316
    record_count 249
  ]

  node [
    id 12
    label "sem_anchor:⟁DOG"
    kind "sem_anchor"
    glyph "⟁DOG"
    centroid_norm 0.97218722
    cohesion 0.94501781
    domain_sim 0.99257398
    record_count 336
  ]

  node [
    id 13
    label "sem_anchor:⟁DRIVER"
    kind "sem_anchor"
    glyph "⟁DRIVER"
    centroid_norm 0.96133369
    cohesion 0.91468292
    domain_sim 0.98105013
    record_count 9
  ]

  node [
    id 14
    label "sem_anchor:⟁ENERGY"
    kind "sem_anchor"
    glyph "⟁ENERGY"
    centroid_norm 0.96505684
    cohesion 0.93041914
    domain_sim 0.98319674
    record_count 76
  ]

  node [
    id 15
    label "sem_anchor:⟁ENGINE"
    kind "sem_anchor"
    glyph "⟁ENGINE"
    centroid_norm 0.96190447
    cohesion 0.92284937
    domain_sim 0.98497367
    record_count 32
  ]

  node [
    id 16
    label "sem_anchor:⟁FIELD"
    kind "sem_anchor"
    glyph "⟁FIELD"
    centroid_norm 0.93000871
    cohesion 0.85741155
    domain_sim 0.97081757
    record_count 19
  ]

  node [
    id 17
    label "sem_anchor:⟁FLAT"
    kind "sem_anchor"
    glyph "⟁FLAT"
    centroid_norm 0.96911007
    cohesion 0.93788022
    domain_sim 0.97891718
    record_count 48
  ]

  node [
    id 18
    label "sem_anchor:⟁FLOW"
    kind "sem_anchor"
    glyph "⟁FLOW"
    centroid_norm 0.96484542
    cohesion 0.92915559
    domain_sim 0.97628492
    record_count 40
  ]

  node [
    id 19
    label "sem_anchor:⟁FUR"
    kind "sem_anchor"
    glyph "⟁FUR"
    centroid_norm 0.97811705
    cohesion 0.95504823
    domain_sim 0.98840648
    record_count 27
  ]

  node [
    id 20
    label "sem_anchor:⟁GAME"
    kind "sem_anchor"
    glyph "⟁GAME"
    centroid_norm 0.96125889
    cohesion 0.92412508
    domain_sim 0.97686261
    record_count 267
  ]

  node [
    id 21
    label "sem_anchor:⟁GROWTH"
    kind "sem_anchor"
    glyph "⟁GROWTH"
    centroid_norm 0.94518226
    cohesion 0.87204345
    domain_sim 0.97003007
    record_count 6
  ]

  node [
    id 22
    label "sem_anchor:⟁HORSE"
    kind "sem_anchor"
    glyph "⟁HORSE"
    centroid_norm 0.97402513
    cohesion 0.94806757
    domain_sim 0.98823661
    record_count 79
  ]

  node [
    id 23
    label "sem_anchor:⟁MATTER"
    kind "sem_anchor"
    glyph "⟁MATTER"
    centroid_norm 0.9609251
    cohesion 0.92274635
    domain_sim 0.9904846
    record_count 130
  ]

  node [
    id 24
    label "sem_anchor:⟁MEOW"
    kind "sem_anchor"
    glyph "⟁MEOW"
    centroid_norm 0.98456556
    cohesion 0.96499343
    domain_sim 0.98140037
    record_count 8
  ]

  node [
    id 25
    label "sem_anchor:⟁MOTION"
    kind "sem_anchor"
    glyph "⟁MOTION"
    centroid_norm 0.95751631
    cohesion 0.90852124
    domain_sim 0.98431778
    record_count 11
  ]

  node [
    id 26
    label "sem_anchor:⟁MOTORCYCLE"
    kind "sem_anchor"
    glyph "⟁MOTORCYCLE"
    centroid_norm 0.9728747
    cohesion 0.93979592
    domain_sim 0.98029459
    record_count 9
  ]

  node [
    id 27
    label "sem_anchor:⟁PASSENGER"
    kind "sem_anchor"
    glyph "⟁PASSENGER"
    centroid_norm 0.94921786
    cohesion 0.88121761
    domain_sim 0.97064686
    record_count 6
  ]

  node [
    id 28
    label "sem_anchor:⟁PATH"
    kind "sem_anchor"
    glyph "⟁PATH"
    centroid_norm 1.0
    cohesion 1.0
    domain_sim 0.95038146
    record_count 1
  ]

  node [
    id 29
    label "sem_anchor:⟁PAW"
    kind "sem_anchor"
    glyph "⟁PAW"
    centroid_norm 1.0
    cohesion 1.0
    domain_sim 0.89836997
    record_count 1
  ]

  node [
    id 30
    label "sem_anchor:⟁PHYSICAL"
    kind "sem_anchor"
    glyph "⟁PHYSICAL"
    centroid_norm 0.95091581
    cohesion 0.90232567
    domain_sim 1.0
    record_count 51
  ]

  node [
    id 31
    label "sem_anchor:⟁PITCH"
    kind "sem_anchor"
    glyph "⟁PITCH"
    centroid_norm 0.96272492
    cohesion 0.89025895
    domain_sim 0.96351999
    record_count 3
  ]

  node [
    id 32
    label "sem_anchor:⟁PLANE"
    kind "sem_anchor"
    glyph "⟁PLANE"
    centroid_norm 0.96102315
    cohesion 0.9210998
    domain_sim 0.98472077
    record_count 32
  ]

  node [
    id 33
    label "sem_anchor:⟁ROAD"
    kind "sem_anchor"
    glyph "⟁ROAD"
    centroid_norm 0.96489131
    cohesion 0.92695738
    domain_sim 0.98235804
    record_count 18
  ]

  node [
    id 34
    label "sem_anchor:⟁ROTATION"
    kind "sem_anchor"
    glyph "⟁ROTATION"
    centroid_norm 0.94087148
    cohesion 0.85654896
    domain_sim 0.96511525
    record_count 5
  ]

  node [
    id 35
    label "sem_anchor:⟁SCORE"
    kind "sem_anchor"
    glyph "⟁SCORE"
    centroid_norm 0.9593733
    cohesion 0.91509037
    domain_sim 0.97262377
    record_count 16
  ]

  node [
    id 36
    label "sem_anchor:⟁SPORTS"
    kind "sem_anchor"
    glyph "⟁SPORTS"
    centroid_norm 0.96878737
    cohesion 0.93748939
    domain_sim 0.9587177
    record_count 59
  ]

  node [
    id 37
    label "sem_anchor:⟁SWING"
    kind "sem_anchor"
    glyph "⟁SWING"
    centroid_norm 0.95447958
    cohesion 0.88137498
    domain_sim 0.95452458
    record_count 4
  ]

  node [
    id 38
    label "sem_anchor:⟁TIRE"
    kind "sem_anchor"
    glyph "⟁TIRE"
    centroid_norm 0.9796297
    cohesion 0.95160935
    domain_sim 0.9781962
    record_count 6
  ]

  node [
    id 39
    label "sem_anchor:⟁TRAIN"
    kind "sem_anchor"
    glyph "⟁TRAIN"
    centroid_norm 0.96310717
    cohesion 0.92498889
    domain_sim 0.98055708
    record_count 29
  ]

  node [
    id 40
    label "sem_anchor:⟁TRANSPORT"
    kind "sem_anchor"
    glyph "⟁TRANSPORT"
    centroid_norm 0.98137343
    cohesion 0.95973878
    domain_sim 0.96825522
    record_count 12
  ]

  node [
    id 41
    label "sem_anchor:⟁TRUCK"
    kind "sem_anchor"
    glyph "⟁TRUCK"
    centroid_norm 0.97142804
    cohesion 0.93933945
    domain_sim 0.98993927
    record_count 14
  ]

  node [
    id 42
    label "sem_anchor:⟁VEHICLE"
    kind "sem_anchor"
    glyph "⟁VEHICLE"
    centroid_norm 0.96446627
    cohesion 0.92482558
    domain_sim 0.98575276
    record_count 14
  ]

  node [
    id 43
    label "sem_anchor:⟁WHEEL"
    kind "sem_anchor"
    glyph "⟁WHEEL"
    centroid_norm 0.96729499
    cohesion 0.93208512
    domain_sim 0.98422813
    record_count 19
  ]

  node [
    id 2000
    label "weight:semantic_cohesion"
    kind "learned_parameter"
    weight 1.0
    family "semantic_cohesion"
  ]

  edge [
    source 1
    target 2000
    label "sem_bias"
    feature 0.93691836
  ]

  edge [
    source 2
    target 2000
    label "sem_bias"
    feature 0.93415498
  ]

  edge [
    source 3
    target 2000
    label "sem_bias"
    feature 0.95813316
  ]

  edge [
    source 4
    target 2000
    label "sem_bias"
    feature 0.93382987
  ]

  edge [
    source 5
    target 2000
    label "sem_bias"
    feature 0.95343689
  ]

  edge [
    source 6
    target 2000
    label "sem_bias"
    feature 0.94666439
  ]

  edge [
    source 7
    target 2000
    label "sem_bias"
    feature 0.94589969
  ]

  edge [
    source 8
    target 2000
    label "sem_bias"
    feature 0.93871855
  ]

  edge [
    source 9
    target 2000
    label "sem_bias"
    feature 0.94234848
  ]

  edge [
    source 10
    target 2000
    label "sem_bias"
    feature 1.0
  ]

  edge [
    source 11
    target 2000
    label "sem_bias"
    feature 0.94800395
  ]

  edge [
    source 12
    target 2000
    label "sem_bias"
    feature 0.94501781
  ]

  edge [
    source 13
    target 2000
    label "sem_bias"
    feature 0.91468292
  ]

  edge [
    source 14
    target 2000
    label "sem_bias"
    feature 0.93041914
  ]

  edge [
    source 15
    target 2000
    label "sem_bias"
    feature 0.92284937
  ]

  edge [
    source 16
    target 2000
    label "sem_bias"
    feature 0.85741155
  ]

  edge [
    source 17
    target 2000
    label "sem_bias"
    feature 0.93788022
  ]

  edge [
    source 18
    target 2000
    label "sem_bias"
    feature 0.92915559
  ]

  edge [
    source 19
    target 2000
    label "sem_bias"
    feature 0.95504823
  ]

  edge [
    source 20
    target 2000
    label "sem_bias"
    feature 0.92412508
  ]

  edge [
    source 21
    target 2000
    label "sem_bias"
    feature 0.87204345
  ]

  edge [
    source 22
    target 2000
    label "sem_bias"
    feature 0.94806757
  ]

  edge [
    source 23
    target 2000
    label "sem_bias"
    feature 0.92274635
  ]

  edge [
    source 24
    target 2000
    label "sem_bias"
    feature 0.96499343
  ]

  edge [
    source 25
    target 2000
    label "sem_bias"
    feature 0.90852124
  ]

  edge [
    source 26
    target 2000
    label "sem_bias"
    feature 0.93979592
  ]

  edge [
    source 27
    target 2000
    label "sem_bias"
    feature 0.88121761
  ]

  edge [
    source 28
    target 2000
    label "sem_bias"
    feature 1.0
  ]

  edge [
    source 29
    target 2000
    label "sem_bias"
    feature 1.0
  ]

  edge [
    source 30
    target 2000
    label "sem_bias"
    feature 0.90232567
  ]

  edge [
    source 31
    target 2000
    label "sem_bias"
    feature 0.89025895
  ]

  edge [
    source 32
    target 2000
    label "sem_bias"
    feature 0.9210998
  ]

  edge [
    source 33
    target 2000
    label "sem_bias"
    feature 0.92695738
  ]

  edge [
    source 34
    target 2000
    label "sem_bias"
    feature 0.85654896
  ]

  edge [
    source 35
    target 2000
    label "sem_bias"
    feature 0.91509037
  ]

  edge [
    source 36
    target 2000
    label "sem_bias"
    feature 0.93748939
  ]

  edge [
    source 37
    target 2000
    label "sem_bias"
    feature 0.88137498
  ]

  edge [
    source 38
    target 2000
    label "sem_bias"
    feature 0.95160935
  ]

  edge [
    source 39
    target 2000
    label "sem_bias"
    feature 0.92498889
  ]

  edge [
    source 40
    target 2000
    label "sem_bias"
    feature 0.95973878
  ]

  edge [
    source 41
    target 2000
    label "sem_bias"
    feature 0.93933945
  ]

  edge [
    source 42
    target 2000
    label "sem_bias"
    feature 0.92482558
  ]

  edge [
    source 43
    target 2000
    label "sem_bias"
    feature 0.93208512
  ]

]
