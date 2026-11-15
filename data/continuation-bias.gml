graph [
  comment "Classic-vocabulary continuation prior. Generated from the 18th-century lexicon: weight = BIAS_SCALE * log(1+count) / log(1+peak), where count is the number of distinct words whose definition uses the token. A prior about reuse, not about meaning. Regenerate with tools/build_continuation_bias.py; never hand-edit."
  directed 1
  label "Continuation_Bias_Classic"
  generated_from "english-dictionary.lexicon.key-grammar.jsonl"
  bias_scale 0.5
  min_count 2
  words 18830
  shared_tokens 4504
  emitted 4000

  node [
    id 1
    label "to"
    kind "continuation_bias"
    weight 0.5
    evidence 6966
    source "classic-lexicon"
  ]

  node [
    id 2
    label "in"
    kind "continuation_bias"
    weight 0.4785
    evidence 4763
    source "classic-lexicon"
  ]

  node [
    id 3
    label "by"
    kind "continuation_bias"
    weight 0.4398
    evidence 2399
    source "classic-lexicon"
  ]

  node [
    id 4
    label "any"
    kind "continuation_bias"
    weight 0.4297
    evidence 2008
    source "classic-lexicon"
  ]

  node [
    id 5
    label "one"
    kind "continuation_bias"
    weight 0.4294
    evidence 1996
    source "classic-lexicon"
  ]

  node [
    id 6
    label "which"
    kind "continuation_bias"
    weight 0.4221
    evidence 1755
    source "classic-lexicon"
  ]

  node [
    id 7
    label "and"
    kind "continuation_bias"
    weight 0.4173
    evidence 1611
    source "classic-lexicon"
  ]

  node [
    id 8
    label "for"
    kind "continuation_bias"
    weight 0.3951
    evidence 1087
    source "classic-lexicon"
  ]

  node [
    id 9
    label "part"
    kind "continuation_bias"
    weight 0.3811
    evidence 848
    source "classic-lexicon"
  ]

  node [
    id 10
    label "being"
    kind "continuation_bias"
    weight 0.3779
    evidence 802
    source "classic-lexicon"
  ]

  node [
    id 11
    label "at"
    kind "continuation_bias"
    weight 0.375
    evidence 761
    source "classic-lexicon"
  ]

  node [
    id 12
    label "make"
    kind "continuation_bias"
    weight 0.375
    evidence 761
    source "classic-lexicon"
  ]

  node [
    id 13
    label "out"
    kind "continuation_bias"
    weight 0.3686
    evidence 680
    source "classic-lexicon"
  ]

  node [
    id 14
    label "without"
    kind "continuation_bias"
    weight 0.3644
    evidence 631
    source "classic-lexicon"
  ]

  node [
    id 15
    label "having"
    kind "continuation_bias"
    weight 0.3613
    evidence 597
    source "classic-lexicon"
  ]

  node [
    id 16
    label "place"
    kind "continuation_bias"
    weight 0.3596
    evidence 580
    source "classic-lexicon"
  ]

  node [
    id 17
    label "un"
    kind "continuation_bias"
    weight 0.3585
    evidence 568
    source "classic-lexicon"
  ]

  node [
    id 18
    label "into"
    kind "continuation_bias"
    weight 0.3574
    evidence 557
    source "classic-lexicon"
  ]

  node [
    id 19
    label "kind"
    kind "continuation_bias"
    weight 0.3567
    evidence 551
    source "classic-lexicon"
  ]

  node [
    id 20
    label "another"
    kind "continuation_bias"
    weight 0.3559
    evidence 543
    source "classic-lexicon"
  ]

  node [
    id 21
    label "power"
    kind "continuation_bias"
    weight 0.3524
    evidence 510
    source "classic-lexicon"
  ]

  node [
    id 22
    label "manner"
    kind "continuation_bias"
    weight 0.3478
    evidence 470
    source "classic-lexicon"
  ]

  node [
    id 23
    label "other"
    kind "continuation_bias"
    weight 0.3475
    evidence 468
    source "classic-lexicon"
  ]

  node [
    id 24
    label "body"
    kind "continuation_bias"
    weight 0.3451
    evidence 448
    source "classic-lexicon"
  ]

  node [
    id 25
    label "quality"
    kind "continuation_bias"
    weight 0.3437
    evidence 437
    source "classic-lexicon"
  ]

  node [
    id 26
    label "con"
    kind "continuation_bias"
    weight 0.3405
    evidence 413
    source "classic-lexicon"
  ]

  node [
    id 27
    label "time"
    kind "continuation_bias"
    weight 0.3332
    evidence 363
    source "classic-lexicon"
  ]

  node [
    id 28
    label "form"
    kind "continuation_bias"
    weight 0.3315
    evidence 352
    source "classic-lexicon"
  ]

  node [
    id 29
    label "word"
    kind "continuation_bias"
    weight 0.3297
    evidence 341
    source "classic-lexicon"
  ]

  node [
    id 30
    label "put"
    kind "continuation_bias"
    weight 0.3278
    evidence 330
    source "classic-lexicon"
  ]

  node [
    id 31
    label "ed"
    kind "continuation_bias"
    weight 0.3252
    evidence 315
    source "classic-lexicon"
  ]

  node [
    id 32
    label "no"
    kind "continuation_bias"
    weight 0.3213
    evidence 294
    source "classic-lexicon"
  ]

  node [
    id 33
    label "use"
    kind "continuation_bias"
    weight 0.3176
    evidence 275
    source "classic-lexicon"
  ]

  node [
    id 34
    label "person"
    kind "continuation_bias"
    weight 0.3138
    evidence 257
    source "classic-lexicon"
  ]

  node [
    id 35
    label "over"
    kind "continuation_bias"
    weight 0.3135
    evidence 256
    source "classic-lexicon"
  ]

  node [
    id 36
    label "mind"
    kind "continuation_bias"
    weight 0.3118
    evidence 248
    source "classic-lexicon"
  ]

  node [
    id 37
    label "water"
    kind "continuation_bias"
    weight 0.3111
    evidence 245
    source "classic-lexicon"
  ]

  node [
    id 38
    label "full"
    kind "continuation_bias"
    weight 0.3097
    evidence 239
    source "classic-lexicon"
  ]

  node [
    id 39
    label "fame"
    kind "continuation_bias"
    weight 0.3087
    evidence 235
    source "classic-lexicon"
  ]

  node [
    id 40
    label "like"
    kind "continuation_bias"
    weight 0.3075
    evidence 230
    source "classic-lexicon"
  ]

  node [
    id 41
    label "two"
    kind "continuation_bias"
    weight 0.3053
    evidence 221
    source "classic-lexicon"
  ]

  node [
    id 42
    label "mean"
    kind "continuation_bias"
    weight 0.3045
    evidence 218
    source "classic-lexicon"
  ]

  node [
    id 43
    label "law"
    kind "continuation_bias"
    weight 0.3037
    evidence 215
    source "classic-lexicon"
  ]

  node [
    id 44
    label "great"
    kind "continuation_bias"
    weight 0.3032
    evidence 213
    source "classic-lexicon"
  ]

  node [
    id 45
    label "may"
    kind "continuation_bias"
    weight 0.3021
    evidence 209
    source "classic-lexicon"
  ]

  node [
    id 46
    label "ground"
    kind "continuation_bias"
    weight 0.3005
    evidence 203
    source "classic-lexicon"
  ]

  node [
    id 47
    label "ill"
    kind "continuation_bias"
    weight 0.2988
    evidence 197
    source "classic-lexicon"
  ]

  node [
    id 48
    label "low"
    kind "continuation_bias"
    weight 0.2982
    evidence 195
    source "classic-lexicon"
  ]

  node [
    id 49
    label "art"
    kind "continuation_bias"
    weight 0.2959
    evidence 187
    source "classic-lexicon"
  ]

  node [
    id 50
    label "together"
    kind "continuation_bias"
    weight 0.2959
    evidence 187
    source "classic-lexicon"
  ]

  node [
    id 51
    label "motion"
    kind "continuation_bias"
    weight 0.2953
    evidence 185
    source "classic-lexicon"
  ]

  node [
    id 52
    label "way"
    kind "continuation_bias"
    weight 0.2953
    evidence 185
    source "classic-lexicon"
  ]

  node [
    id 53
    label "name"
    kind "continuation_bias"
    weight 0.2944
    evidence 182
    source "classic-lexicon"
  ]

  node [
    id 54
    label "order"
    kind "continuation_bias"
    weight 0.2937
    evidence 180
    source "classic-lexicon"
  ]

  node [
    id 55
    label "where"
    kind "continuation_bias"
    weight 0.2937
    evidence 180
    source "classic-lexicon"
  ]

  node [
    id 56
    label "end"
    kind "continuation_bias"
    weight 0.2931
    evidence 178
    source "classic-lexicon"
  ]

  node [
    id 57
    label "point"
    kind "continuation_bias"
    weight 0.2928
    evidence 177
    source "classic-lexicon"
  ]

  node [
    id 58
    label "hand"
    kind "continuation_bias"
    weight 0.2925
    evidence 176
    source "classic-lexicon"
  ]

  node [
    id 59
    label "head"
    kind "continuation_bias"
    weight 0.2922
    evidence 175
    source "classic-lexicon"
  ]

  node [
    id 60
    label "cut"
    kind "continuation_bias"
    weight 0.2918
    evidence 174
    source "classic-lexicon"
  ]

  node [
    id 61
    label "right"
    kind "continuation_bias"
    weight 0.2915
    evidence 173
    source "classic-lexicon"
  ]

  node [
    id 62
    label "away"
    kind "continuation_bias"
    weight 0.2912
    evidence 172
    source "classic-lexicon"
  ]

  node [
    id 63
    label "fit"
    kind "continuation_bias"
    weight 0.2905
    evidence 170
    source "classic-lexicon"
  ]

  node [
    id 64
    label "tree"
    kind "continuation_bias"
    weight 0.2905
    evidence 170
    source "classic-lexicon"
  ]

  node [
    id 65
    label "bird"
    kind "continuation_bias"
    weight 0.2892
    evidence 166
    source "classic-lexicon"
  ]

  node [
    id 66
    label "piece"
    kind "continuation_bias"
    weight 0.2888
    evidence 165
    source "classic-lexicon"
  ]

  node [
    id 67
    label "good"
    kind "continuation_bias"
    weight 0.2882
    evidence 163
    source "classic-lexicon"
  ]

  node [
    id 68
    label "under"
    kind "continuation_bias"
    weight 0.2875
    evidence 161
    source "classic-lexicon"
  ]

  node [
    id 69
    label "animal"
    kind "continuation_bias"
    weight 0.2871
    evidence 160
    source "classic-lexicon"
  ]

  node [
    id 70
    label "little"
    kind "continuation_bias"
    weight 0.2871
    evidence 160
    source "classic-lexicon"
  ]

  node [
    id 71
    label "degree"
    kind "continuation_bias"
    weight 0.2868
    evidence 159
    source "classic-lexicon"
  ]

  node [
    id 72
    label "house"
    kind "continuation_bias"
    weight 0.2864
    evidence 158
    source "classic-lexicon"
  ]

  node [
    id 73
    label "down"
    kind "continuation_bias"
    weight 0.285
    evidence 154
    source "classic-lexicon"
  ]

  node [
    id 74
    label "more"
    kind "continuation_bias"
    weight 0.2846
    evidence 153
    source "classic-lexicon"
  ]

  node [
    id 75
    label "matter"
    kind "continuation_bias"
    weight 0.2835
    evidence 150
    source "classic-lexicon"
  ]

  node [
    id 76
    label "light"
    kind "continuation_bias"
    weight 0.2827
    evidence 148
    source "classic-lexicon"
  ]

  node [
    id 77
    label "late"
    kind "continuation_bias"
    weight 0.282
    evidence 146
    source "classic-lexicon"
  ]

  node [
    id 78
    label "number"
    kind "continuation_bias"
    weight 0.282
    evidence 146
    source "classic-lexicon"
  ]

  node [
    id 79
    label "work"
    kind "continuation_bias"
    weight 0.282
    evidence 146
    source "classic-lexicon"
  ]

  node [
    id 80
    label "round"
    kind "continuation_bias"
    weight 0.2812
    evidence 144
    source "classic-lexicon"
  ]

  node [
    id 81
    label "their"
    kind "continuation_bias"
    weight 0.2808
    evidence 143
    source "classic-lexicon"
  ]

  node [
    id 82
    label "large"
    kind "continuation_bias"
    weight 0.28
    evidence 141
    source "classic-lexicon"
  ]

  node [
    id 83
    label "horse"
    kind "continuation_bias"
    weight 0.2792
    evidence 139
    source "classic-lexicon"
  ]

  node [
    id 84
    label "between"
    kind "continuation_bias"
    weight 0.2788
    evidence 138
    source "classic-lexicon"
  ]

  node [
    id 85
    label "certain"
    kind "continuation_bias"
    weight 0.2788
    evidence 138
    source "classic-lexicon"
  ]

  node [
    id 86
    label "this"
    kind "continuation_bias"
    weight 0.2784
    evidence 137
    source "classic-lexicon"
  ]

  node [
    id 87
    label "colour"
    kind "continuation_bias"
    weight 0.2767
    evidence 133
    source "classic-lexicon"
  ]

  node [
    id 88
    label "go"
    kind "continuation_bias"
    weight 0.2767
    evidence 133
    source "classic-lexicon"
  ]

  node [
    id 89
    label "nature"
    kind "continuation_bias"
    weight 0.2763
    evidence 132
    source "classic-lexicon"
  ]

  node [
    id 90
    label "mark"
    kind "continuation_bias"
    weight 0.2759
    evidence 131
    source "classic-lexicon"
  ]

  node [
    id 91
    label "but"
    kind "continuation_bias"
    weight 0.275
    evidence 129
    source "classic-lexicon"
  ]

  node [
    id 92
    label "particular"
    kind "continuation_bias"
    weight 0.275
    evidence 129
    source "classic-lexicon"
  ]

  node [
    id 93
    label "high"
    kind "continuation_bias"
    weight 0.2746
    evidence 128
    source "classic-lexicon"
  ]

  node [
    id 94
    label "line"
    kind "continuation_bias"
    weight 0.2742
    evidence 127
    source "classic-lexicon"
  ]

  node [
    id 95
    label "all"
    kind "continuation_bias"
    weight 0.2737
    evidence 126
    source "classic-lexicon"
  ]

  node [
    id 96
    label "back"
    kind "continuation_bias"
    weight 0.2737
    evidence 126
    source "classic-lexicon"
  ]

  node [
    id 97
    label "play"
    kind "continuation_bias"
    weight 0.2733
    evidence 125
    source "classic-lexicon"
  ]

  node [
    id 98
    label "much"
    kind "continuation_bias"
    weight 0.2728
    evidence 124
    source "classic-lexicon"
  ]

  node [
    id 99
    label "quick"
    kind "continuation_bias"
    weight 0.2724
    evidence 123
    source "classic-lexicon"
  ]

  node [
    id 100
    label "woman"
    kind "continuation_bias"
    weight 0.2724
    evidence 123
    source "classic-lexicon"
  ]

  node [
    id 101
    label "hard"
    kind "continuation_bias"
    weight 0.271
    evidence 120
    source "classic-lexicon"
  ]

  node [
    id 102
    label "when"
    kind "continuation_bias"
    weight 0.271
    evidence 120
    source "classic-lexicon"
  ]

  node [
    id 103
    label "violence"
    kind "continuation_bias"
    weight 0.2705
    evidence 119
    source "classic-lexicon"
  ]

  node [
    id 104
    label "change"
    kind "continuation_bias"
    weight 0.27
    evidence 118
    source "classic-lexicon"
  ]

  node [
    id 105
    label "fire"
    kind "continuation_bias"
    weight 0.27
    evidence 118
    source "classic-lexicon"
  ]

  node [
    id 106
    label "free"
    kind "continuation_bias"
    weight 0.27
    evidence 118
    source "classic-lexicon"
  ]

  node [
    id 107
    label "wood"
    kind "continuation_bias"
    weight 0.2691
    evidence 116
    source "classic-lexicon"
  ]

  node [
    id 108
    label "about"
    kind "continuation_bias"
    weight 0.2686
    evidence 115
    source "classic-lexicon"
  ]

  node [
    id 109
    label "fort"
    kind "continuation_bias"
    weight 0.2681
    evidence 114
    source "classic-lexicon"
  ]

  node [
    id 110
    label "close"
    kind "continuation_bias"
    weight 0.2676
    evidence 113
    source "classic-lexicon"
  ]

  node [
    id 111
    label "al"
    kind "continuation_bias"
    weight 0.2671
    evidence 112
    source "classic-lexicon"
  ]

  node [
    id 112
    label "noise"
    kind "continuation_bias"
    weight 0.2671
    evidence 112
    source "classic-lexicon"
  ]

  node [
    id 113
    label "land"
    kind "continuation_bias"
    weight 0.2661
    evidence 110
    source "classic-lexicon"
  ]

  node [
    id 114
    label "able"
    kind "continuation_bias"
    weight 0.2646
    evidence 107
    source "classic-lexicon"
  ]

  node [
    id 115
    label "see"
    kind "continuation_bias"
    weight 0.2635
    evidence 105
    source "classic-lexicon"
  ]

  node [
    id 116
    label "common"
    kind "continuation_bias"
    weight 0.263
    evidence 104
    source "classic-lexicon"
  ]

  node [
    id 117
    label "pain"
    kind "continuation_bias"
    weight 0.2624
    evidence 103
    source "classic-lexicon"
  ]

  node [
    id 118
    label "publick"
    kind "continuation_bias"
    weight 0.2624
    evidence 103
    source "classic-lexicon"
  ]

  node [
    id 119
    label "above"
    kind "continuation_bias"
    weight 0.2619
    evidence 102
    source "classic-lexicon"
  ]

  node [
    id 120
    label "call"
    kind "continuation_bias"
    weight 0.2619
    evidence 102
    source "classic-lexicon"
  ]

  node [
    id 121
    label "cloth"
    kind "continuation_bias"
    weight 0.2613
    evidence 101
    source "classic-lexicon"
  ]

  node [
    id 122
    label "general"
    kind "continuation_bias"
    weight 0.2613
    evidence 101
    source "classic-lexicon"
  ]

  node [
    id 123
    label "figure"
    kind "continuation_bias"
    weight 0.2608
    evidence 100
    source "classic-lexicon"
  ]

  node [
    id 124
    label "liquor"
    kind "continuation_bias"
    weight 0.2608
    evidence 100
    source "classic-lexicon"
  ]

  node [
    id 125
    label "air"
    kind "continuation_bias"
    weight 0.2602
    evidence 99
    source "classic-lexicon"
  ]

  node [
    id 126
    label "new"
    kind "continuation_bias"
    weight 0.2602
    evidence 99
    source "classic-lexicon"
  ]

  node [
    id 127
    label "rate"
    kind "continuation_bias"
    weight 0.2602
    evidence 99
    source "classic-lexicon"
  ]

  node [
    id 128
    label "less"
    kind "continuation_bias"
    weight 0.2596
    evidence 98
    source "classic-lexicon"
  ]

  node [
    id 129
    label "contrary"
    kind "continuation_bias"
    weight 0.2591
    evidence 97
    source "classic-lexicon"
  ]

  node [
    id 130
    label "dress"
    kind "continuation_bias"
    weight 0.2591
    evidence 97
    source "classic-lexicon"
  ]

  node [
    id 131
    label "money"
    kind "continuation_bias"
    weight 0.2591
    evidence 97
    source "classic-lexicon"
  ]

  node [
    id 132
    label "again"
    kind "continuation_bias"
    weight 0.2585
    evidence 96
    source "classic-lexicon"
  ]

  node [
    id 133
    label "lay"
    kind "continuation_bias"
    weight 0.2579
    evidence 95
    source "classic-lexicon"
  ]

  node [
    id 134
    label "writing"
    kind "continuation_bias"
    weight 0.2573
    evidence 94
    source "classic-lexicon"
  ]

  node [
    id 135
    label "ne"
    kind "continuation_bias"
    weight 0.2567
    evidence 93
    source "classic-lexicon"
  ]

  node [
    id 136
    label "well"
    kind "continuation_bias"
    weight 0.2567
    evidence 93
    source "classic-lexicon"
  ]

  node [
    id 137
    label "equal"
    kind "continuation_bias"
    weight 0.2561
    evidence 92
    source "classic-lexicon"
  ]

  node [
    id 138
    label "rule"
    kind "continuation_bias"
    weight 0.2561
    evidence 92
    source "classic-lexicon"
  ]

  node [
    id 139
    label "bear"
    kind "continuation_bias"
    weight 0.2555
    evidence 91
    source "classic-lexicon"
  ]

  node [
    id 140
    label "only"
    kind "continuation_bias"
    weight 0.2555
    evidence 91
    source "classic-lexicon"
  ]

  node [
    id 141
    label "young"
    kind "continuation_bias"
    weight 0.2555
    evidence 91
    source "classic-lexicon"
  ]

  node [
    id 142
    label "food"
    kind "continuation_bias"
    weight 0.2549
    evidence 90
    source "classic-lexicon"
  ]

  node [
    id 143
    label "heat"
    kind "continuation_bias"
    weight 0.2549
    evidence 90
    source "classic-lexicon"
  ]

  node [
    id 144
    label "old"
    kind "continuation_bias"
    weight 0.2549
    evidence 90
    source "classic-lexicon"
  ]

  node [
    id 145
    label "drawn"
    kind "continuation_bias"
    weight 0.2543
    evidence 89
    source "classic-lexicon"
  ]

  node [
    id 146
    label "first"
    kind "continuation_bias"
    weight 0.2543
    evidence 89
    source "classic-lexicon"
  ]

  node [
    id 147
    label "fight"
    kind "continuation_bias"
    weight 0.2536
    evidence 88
    source "classic-lexicon"
  ]

  node [
    id 148
    label "knowledge"
    kind "continuation_bias"
    weight 0.253
    evidence 87
    source "classic-lexicon"
  ]

  node [
    id 149
    label "church"
    kind "continuation_bias"
    weight 0.2523
    evidence 86
    source "classic-lexicon"
  ]

  node [
    id 150
    label "flower"
    kind "continuation_bias"
    weight 0.2523
    evidence 86
    source "classic-lexicon"
  ]

  node [
    id 151
    label "court"
    kind "continuation_bias"
    weight 0.251
    evidence 84
    source "classic-lexicon"
  ]

  node [
    id 152
    label "fruit"
    kind "continuation_bias"
    weight 0.251
    evidence 84
    source "classic-lexicon"
  ]

  node [
    id 153
    label "proper"
    kind "continuation_bias"
    weight 0.251
    evidence 84
    source "classic-lexicon"
  ]

  node [
    id 154
    label "wild"
    kind "continuation_bias"
    weight 0.251
    evidence 84
    source "classic-lexicon"
  ]

  node [
    id 155
    label "par"
    kind "continuation_bias"
    weight 0.2504
    evidence 83
    source "classic-lexicon"
  ]

  node [
    id 156
    label "produce"
    kind "continuation_bias"
    weight 0.2504
    evidence 83
    source "classic-lexicon"
  ]

  node [
    id 157
    label "fore"
    kind "continuation_bias"
    weight 0.2497
    evidence 82
    source "classic-lexicon"
  ]

  node [
    id 158
    label "will"
    kind "continuation_bias"
    weight 0.2497
    evidence 82
    source "classic-lexicon"
  ]

  node [
    id 159
    label "account"
    kind "continuation_bias"
    weight 0.249
    evidence 81
    source "classic-lexicon"
  ]

  node [
    id 160
    label "foot"
    kind "continuation_bias"
    weight 0.249
    evidence 81
    source "classic-lexicon"
  ]

  node [
    id 161
    label "live"
    kind "continuation_bias"
    weight 0.249
    evidence 81
    source "classic-lexicon"
  ]

  node [
    id 162
    label "many"
    kind "continuation_bias"
    weight 0.249
    evidence 81
    source "classic-lexicon"
  ]

  node [
    id 163
    label "thought"
    kind "continuation_bias"
    weight 0.249
    evidence 81
    source "classic-lexicon"
  ]

  node [
    id 164
    label "worn"
    kind "continuation_bias"
    weight 0.249
    evidence 81
    source "classic-lexicon"
  ]

  node [
    id 165
    label "care"
    kind "continuation_bias"
    weight 0.2483
    evidence 80
    source "classic-lexicon"
  ]

  node [
    id 166
    label "charge"
    kind "continuation_bias"
    weight 0.2483
    evidence 80
    source "classic-lexicon"
  ]

  node [
    id 167
    label "course"
    kind "continuation_bias"
    weight 0.2483
    evidence 80
    source "classic-lexicon"
  ]

  node [
    id 168
    label "fub"
    kind "continuation_bias"
    weight 0.2483
    evidence 80
    source "classic-lexicon"
  ]

  node [
    id 169
    label "gives"
    kind "continuation_bias"
    weight 0.2483
    evidence 80
    source "classic-lexicon"
  ]

  node [
    id 170
    label "loose"
    kind "continuation_bias"
    weight 0.2483
    evidence 80
    source "classic-lexicon"
  ]

  node [
    id 171
    label "earth"
    kind "continuation_bias"
    weight 0.2476
    evidence 79
    source "classic-lexicon"
  ]

  node [
    id 172
    label "fellow"
    kind "continuation_bias"
    weight 0.2476
    evidence 79
    source "classic-lexicon"
  ]

  node [
    id 173
    label "purpose"
    kind "continuation_bias"
    weight 0.2476
    evidence 79
    source "classic-lexicon"
  ]

  node [
    id 174
    label "thin"
    kind "continuation_bias"
    weight 0.2476
    evidence 79
    source "classic-lexicon"
  ]

  node [
    id 175
    label "flight"
    kind "continuation_bias"
    weight 0.2469
    evidence 78
    source "classic-lexicon"
  ]

  node [
    id 176
    label "value"
    kind "continuation_bias"
    weight 0.2469
    evidence 78
    source "classic-lexicon"
  ]

  node [
    id 177
    label "view"
    kind "continuation_bias"
    weight 0.2469
    evidence 78
    source "classic-lexicon"
  ]

  node [
    id 178
    label "look"
    kind "continuation_bias"
    weight 0.2462
    evidence 77
    source "classic-lexicon"
  ]

  node [
    id 179
    label "metal"
    kind "continuation_bias"
    weight 0.2462
    evidence 77
    source "classic-lexicon"
  ]

  node [
    id 180
    label "weight"
    kind "continuation_bias"
    weight 0.2462
    evidence 77
    source "classic-lexicon"
  ]

  node [
    id 181
    label "contempt"
    kind "continuation_bias"
    weight 0.2454
    evidence 76
    source "classic-lexicon"
  ]

  node [
    id 182
    label "mouth"
    kind "continuation_bias"
    weight 0.2454
    evidence 76
    source "classic-lexicon"
  ]

  node [
    id 183
    label "trade"
    kind "continuation_bias"
    weight 0.2454
    evidence 76
    source "classic-lexicon"
  ]

  node [
    id 184
    label "beyond"
    kind "continuation_bias"
    weight 0.2447
    evidence 75
    source "classic-lexicon"
  ]

  node [
    id 185
    label "bound"
    kind "continuation_bias"
    weight 0.2447
    evidence 75
    source "classic-lexicon"
  ]

  node [
    id 186
    label "clear"
    kind "continuation_bias"
    weight 0.2447
    evidence 75
    source "classic-lexicon"
  ]

  node [
    id 187
    label "language"
    kind "continuation_bias"
    weight 0.2447
    evidence 75
    source "classic-lexicon"
  ]

  node [
    id 188
    label "break"
    kind "continuation_bias"
    weight 0.244
    evidence 74
    source "classic-lexicon"
  ]

  node [
    id 189
    label "hinder"
    kind "continuation_bias"
    weight 0.244
    evidence 74
    source "classic-lexicon"
  ]

  node [
    id 190
    label "rest"
    kind "continuation_bias"
    weight 0.244
    evidence 74
    source "classic-lexicon"
  ]

  node [
    id 191
    label "capable"
    kind "continuation_bias"
    weight 0.2432
    evidence 73
    source "classic-lexicon"
  ]

  node [
    id 192
    label "else"
    kind "continuation_bias"
    weight 0.2432
    evidence 73
    source "classic-lexicon"
  ]

  node [
    id 193
    label "four"
    kind "continuation_bias"
    weight 0.2432
    evidence 73
    source "classic-lexicon"
  ]

  node [
    id 194
    label "measure"
    kind "continuation_bias"
    weight 0.2432
    evidence 73
    source "classic-lexicon"
  ]

  node [
    id 195
    label "opinion"
    kind "continuation_bias"
    weight 0.2432
    evidence 73
    source "classic-lexicon"
  ]

  node [
    id 196
    label "death"
    kind "continuation_bias"
    weight 0.2424
    evidence 72
    source "classic-lexicon"
  ]

  node [
    id 197
    label "every"
    kind "continuation_bias"
    weight 0.2424
    evidence 72
    source "classic-lexicon"
  ]

  node [
    id 198
    label "beat"
    kind "continuation_bias"
    weight 0.2416
    evidence 71
    source "classic-lexicon"
  ]

  node [
    id 199
    label "country"
    kind "continuation_bias"
    weight 0.2416
    evidence 71
    source "classic-lexicon"
  ]

  node [
    id 200
    label "gain"
    kind "continuation_bias"
    weight 0.2416
    evidence 71
    source "classic-lexicon"
  ]

  node [
    id 201
    label "crime"
    kind "continuation_bias"
    weight 0.2409
    evidence 70
    source "classic-lexicon"
  ]

  node [
    id 202
    label "natural"
    kind "continuation_bias"
    weight 0.2409
    evidence 70
    source "classic-lexicon"
  ]

  node [
    id 203
    label "pi"
    kind "continuation_bias"
    weight 0.2409
    evidence 70
    source "classic-lexicon"
  ]

  node [
    id 204
    label "case"
    kind "continuation_bias"
    weight 0.2401
    evidence 69
    source "classic-lexicon"
  ]

  node [
    id 205
    label "forward"
    kind "continuation_bias"
    weight 0.2401
    evidence 69
    source "classic-lexicon"
  ]

  node [
    id 206
    label "hair"
    kind "continuation_bias"
    weight 0.2401
    evidence 69
    source "classic-lexicon"
  ]

  node [
    id 207
    label "iron"
    kind "continuation_bias"
    weight 0.2401
    evidence 69
    source "classic-lexicon"
  ]

  node [
    id 208
    label "meat"
    kind "continuation_bias"
    weight 0.2401
    evidence 69
    source "classic-lexicon"
  ]

  node [
    id 209
    label "state"
    kind "continuation_bias"
    weight 0.2401
    evidence 69
    source "classic-lexicon"
  ]

  node [
    id 210
    label "fill"
    kind "continuation_bias"
    weight 0.2392
    evidence 68
    source "classic-lexicon"
  ]

  node [
    id 211
    label "love"
    kind "continuation_bias"
    weight 0.2392
    evidence 68
    source "classic-lexicon"
  ]

  node [
    id 212
    label "pe"
    kind "continuation_bias"
    weight 0.2392
    evidence 68
    source "classic-lexicon"
  ]

  node [
    id 213
    label "reason"
    kind "continuation_bias"
    weight 0.2384
    evidence 67
    source "classic-lexicon"
  ]

  node [
    id 214
    label "room"
    kind "continuation_bias"
    weight 0.2384
    evidence 67
    source "classic-lexicon"
  ]

  node [
    id 215
    label "those"
    kind "continuation_bias"
    weight 0.2384
    evidence 67
    source "classic-lexicon"
  ]

  node [
    id 216
    label "ward"
    kind "continuation_bias"
    weight 0.2384
    evidence 67
    source "classic-lexicon"
  ]

  node [
    id 217
    label "laid"
    kind "continuation_bias"
    weight 0.2376
    evidence 66
    source "classic-lexicon"
  ]

  node [
    id 218
    label "lu"
    kind "continuation_bias"
    weight 0.2376
    evidence 66
    source "classic-lexicon"
  ]

  node [
    id 219
    label "price"
    kind "continuation_bias"
    weight 0.2376
    evidence 66
    source "classic-lexicon"
  ]

  node [
    id 220
    label "taking"
    kind "continuation_bias"
    weight 0.2376
    evidence 66
    source "classic-lexicon"
  ]

  node [
    id 221
    label "fear"
    kind "continuation_bias"
    weight 0.2367
    evidence 65
    source "classic-lexicon"
  ]

  node [
    id 222
    label "five"
    kind "continuation_bias"
    weight 0.2367
    evidence 65
    source "classic-lexicon"
  ]

  node [
    id 223
    label "note"
    kind "continuation_bias"
    weight 0.2367
    evidence 65
    source "classic-lexicon"
  ]

  node [
    id 224
    label "business"
    kind "continuation_bias"
    weight 0.2359
    evidence 64
    source "classic-lexicon"
  ]

  node [
    id 225
    label "own"
    kind "continuation_bias"
    weight 0.2359
    evidence 64
    source "classic-lexicon"
  ]

  node [
    id 226
    label "forth"
    kind "continuation_bias"
    weight 0.235
    evidence 63
    source "classic-lexicon"
  ]

  node [
    id 227
    label "hole"
    kind "continuation_bias"
    weight 0.235
    evidence 63
    source "classic-lexicon"
  ]

  node [
    id 228
    label "table"
    kind "continuation_bias"
    weight 0.235
    evidence 63
    source "classic-lexicon"
  ]

  node [
    id 229
    label "wise"
    kind "continuation_bias"
    weight 0.235
    evidence 63
    source "classic-lexicon"
  ]

  node [
    id 230
    label "building"
    kind "continuation_bias"
    weight 0.2341
    evidence 62
    source "classic-lexicon"
  ]

  node [
    id 231
    label "corn"
    kind "continuation_bias"
    weight 0.2341
    evidence 62
    source "classic-lexicon"
  ]

  node [
    id 232
    label "deep"
    kind "continuation_bias"
    weight 0.2341
    evidence 62
    source "classic-lexicon"
  ]

  node [
    id 233
    label "rise"
    kind "continuation_bias"
    weight 0.2341
    evidence 62
    source "classic-lexicon"
  ]

  node [
    id 234
    label "bone"
    kind "continuation_bias"
    weight 0.2332
    evidence 61
    source "classic-lexicon"
  ]

  node [
    id 235
    label "chief"
    kind "continuation_bias"
    weight 0.2332
    evidence 61
    source "classic-lexicon"
  ]

  node [
    id 236
    label "desire"
    kind "continuation_bias"
    weight 0.2332
    evidence 61
    source "classic-lexicon"
  ]

  node [
    id 237
    label "duty"
    kind "continuation_bias"
    weight 0.2332
    evidence 61
    source "classic-lexicon"
  ]

  node [
    id 238
    label "fee"
    kind "continuation_bias"
    weight 0.2332
    evidence 61
    source "classic-lexicon"
  ]

  node [
    id 239
    label "leg"
    kind "continuation_bias"
    weight 0.2332
    evidence 61
    source "classic-lexicon"
  ]

  node [
    id 240
    label "near"
    kind "continuation_bias"
    weight 0.2332
    evidence 61
    source "classic-lexicon"
  ]

  node [
    id 241
    label "once"
    kind "continuation_bias"
    weight 0.2332
    evidence 61
    source "classic-lexicon"
  ]

  node [
    id 242
    label "either"
    kind "continuation_bias"
    weight 0.2323
    evidence 60
    source "classic-lexicon"
  ]

  node [
    id 243
    label "people"
    kind "continuation_bias"
    weight 0.2323
    evidence 60
    source "classic-lexicon"
  ]

  node [
    id 244
    label "temper"
    kind "continuation_bias"
    weight 0.2323
    evidence 60
    source "classic-lexicon"
  ]

  node [
    id 245
    label "touch"
    kind "continuation_bias"
    weight 0.2323
    evidence 60
    source "classic-lexicon"
  ]

  node [
    id 246
    label "fault"
    kind "continuation_bias"
    weight 0.2313
    evidence 59
    source "classic-lexicon"
  ]

  node [
    id 247
    label "fine"
    kind "continuation_bias"
    weight 0.2313
    evidence 59
    source "classic-lexicon"
  ]

  node [
    id 248
    label "joint"
    kind "continuation_bias"
    weight 0.2313
    evidence 59
    source "classic-lexicon"
  ]

  node [
    id 249
    label "lie"
    kind "continuation_bias"
    weight 0.2313
    evidence 59
    source "classic-lexicon"
  ]

  node [
    id 250
    label "lower"
    kind "continuation_bias"
    weight 0.2313
    evidence 59
    source "classic-lexicon"
  ]

  node [
    id 251
    label "plural"
    kind "continuation_bias"
    weight 0.2313
    evidence 59
    source "classic-lexicon"
  ]

  node [
    id 252
    label "regular"
    kind "continuation_bias"
    weight 0.2313
    evidence 59
    source "classic-lexicon"
  ]

  node [
    id 253
    label "whole"
    kind "continuation_bias"
    weight 0.2313
    evidence 59
    source "classic-lexicon"
  ]

  node [
    id 254
    label "ail"
    kind "continuation_bias"
    weight 0.2304
    evidence 58
    source "classic-lexicon"
  ]

  node [
    id 255
    label "easily"
    kind "continuation_bias"
    weight 0.2304
    evidence 58
    source "classic-lexicon"
  ]

  node [
    id 256
    label "false"
    kind "continuation_bias"
    weight 0.2304
    evidence 58
    source "classic-lexicon"
  ]

  node [
    id 257
    label "relation"
    kind "continuation_bias"
    weight 0.2304
    evidence 58
    source "classic-lexicon"
  ]

  node [
    id 258
    label "union"
    kind "continuation_bias"
    weight 0.2304
    evidence 58
    source "classic-lexicon"
  ]

  node [
    id 259
    label "weak"
    kind "continuation_bias"
    weight 0.2304
    evidence 58
    source "classic-lexicon"
  ]

  node [
    id 260
    label "blood"
    kind "continuation_bias"
    weight 0.2294
    evidence 57
    source "classic-lexicon"
  ]

  node [
    id 261
    label "favour"
    kind "continuation_bias"
    weight 0.2294
    evidence 57
    source "classic-lexicon"
  ]

  node [
    id 262
    label "gun"
    kind "continuation_bias"
    weight 0.2294
    evidence 57
    source "classic-lexicon"
  ]

  node [
    id 263
    label "pleasure"
    kind "continuation_bias"
    weight 0.2294
    evidence 57
    source "classic-lexicon"
  ]

  node [
    id 264
    label "toward"
    kind "continuation_bias"
    weight 0.2294
    evidence 57
    source "classic-lexicon"
  ]

  node [
    id 265
    label "game"
    kind "continuation_bias"
    weight 0.2284
    evidence 56
    source "classic-lexicon"
  ]

  node [
    id 266
    label "letter"
    kind "continuation_bias"
    weight 0.2284
    evidence 56
    source "classic-lexicon"
  ]

  node [
    id 267
    label "longing"
    kind "continuation_bias"
    weight 0.2284
    evidence 56
    source "classic-lexicon"
  ]

  node [
    id 268
    label "party"
    kind "continuation_bias"
    weight 0.2284
    evidence 56
    source "classic-lexicon"
  ]

  node [
    id 269
    label "walk"
    kind "continuation_bias"
    weight 0.2284
    evidence 56
    source "classic-lexicon"
  ]

  node [
    id 270
    label "black"
    kind "continuation_bias"
    weight 0.2274
    evidence 55
    source "classic-lexicon"
  ]

  node [
    id 271
    label "condition"
    kind "continuation_bias"
    weight 0.2274
    evidence 55
    source "classic-lexicon"
  ]

  node [
    id 272
    label "fold"
    kind "continuation_bias"
    weight 0.2274
    evidence 55
    source "classic-lexicon"
  ]

  node [
    id 273
    label "middle"
    kind "continuation_bias"
    weight 0.2274
    evidence 55
    source "classic-lexicon"
  ]

  node [
    id 274
    label "age"
    kind "continuation_bias"
    weight 0.2264
    evidence 54
    source "classic-lexicon"
  ]

  node [
    id 275
    label "due"
    kind "continuation_bias"
    weight 0.2264
    evidence 54
    source "classic-lexicon"
  ]

  node [
    id 276
    label "fail"
    kind "continuation_bias"
    weight 0.2264
    evidence 54
    source "classic-lexicon"
  ]

  node [
    id 277
    label "feet"
    kind "continuation_bias"
    weight 0.2264
    evidence 54
    source "classic-lexicon"
  ]

  node [
    id 278
    label "honour"
    kind "continuation_bias"
    weight 0.2264
    evidence 54
    source "classic-lexicon"
  ]

  node [
    id 279
    label "birth"
    kind "continuation_bias"
    weight 0.2254
    evidence 53
    source "classic-lexicon"
  ]

  node [
    id 280
    label "fell"
    kind "continuation_bias"
    weight 0.2254
    evidence 53
    source "classic-lexicon"
  ]

  node [
    id 281
    label "foul"
    kind "continuation_bias"
    weight 0.2254
    evidence 53
    source "classic-lexicon"
  ]

  node [
    id 282
    label "act"
    kind "continuation_bias"
    weight 0.2243
    evidence 52
    source "classic-lexicon"
  ]

  node [
    id 283
    label "danger"
    kind "continuation_bias"
    weight 0.2243
    evidence 52
    source "classic-lexicon"
  ]

  node [
    id 284
    label "talk"
    kind "continuation_bias"
    weight 0.2243
    evidence 52
    source "classic-lexicon"
  ]

  node [
    id 285
    label "white"
    kind "continuation_bias"
    weight 0.2243
    evidence 52
    source "classic-lexicon"
  ]

  node [
    id 286
    label "child"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 287
    label "cold"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 288
    label "dead"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 289
    label "female"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 290
    label "next"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 291
    label "night"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 292
    label "port"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 293
    label "preterit"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 294
    label "truth"
    kind "continuation_bias"
    weight 0.2233
    evidence 51
    source "classic-lexicon"
  ]

  node [
    id 295
    label "den"
    kind "continuation_bias"
    weight 0.2222
    evidence 50
    source "classic-lexicon"
  ]

  node [
    id 296
    label "ear"
    kind "continuation_bias"
    weight 0.2222
    evidence 50
    source "classic-lexicon"
  ]

  node [
    id 297
    label "feat"
    kind "continuation_bias"
    weight 0.2222
    evidence 50
    source "classic-lexicon"
  ]

  node [
    id 298
    label "hollow"
    kind "continuation_bias"
    weight 0.2222
    evidence 50
    source "classic-lexicon"
  ]

  node [
    id 299
    label "mu"
    kind "continuation_bias"
    weight 0.2222
    evidence 50
    source "classic-lexicon"
  ]

  node [
    id 300
    label "original"
    kind "continuation_bias"
    weight 0.2222
    evidence 50
    source "classic-lexicon"
  ]

  node [
    id 301
    label "something"
    kind "continuation_bias"
    weight 0.2222
    evidence 50
    source "classic-lexicon"
  ]

  node [
    id 302
    label "void"
    kind "continuation_bias"
    weight 0.2222
    evidence 50
    source "classic-lexicon"
  ]

  node [
    id 303
    label "censure"
    kind "continuation_bias"
    weight 0.221
    evidence 49
    source "classic-lexicon"
  ]

  node [
    id 304
    label "claim"
    kind "continuation_bias"
    weight 0.221
    evidence 49
    source "classic-lexicon"
  ]

  node [
    id 305
    label "disease"
    kind "continuation_bias"
    weight 0.221
    evidence 49
    source "classic-lexicon"
  ]

  node [
    id 306
    label "religion"
    kind "continuation_bias"
    weight 0.221
    evidence 49
    source "classic-lexicon"
  ]

  node [
    id 307
    label "thick"
    kind "continuation_bias"
    weight 0.221
    evidence 49
    source "classic-lexicon"
  ]

  node [
    id 308
    label "utter"
    kind "continuation_bias"
    weight 0.221
    evidence 49
    source "classic-lexicon"
  ]

  node [
    id 309
    label "her"
    kind "continuation_bias"
    weight 0.2199
    evidence 48
    source "classic-lexicon"
  ]

  node [
    id 310
    label "liable"
    kind "continuation_bias"
    weight 0.2199
    evidence 48
    source "classic-lexicon"
  ]

  node [
    id 311
    label "narrow"
    kind "continuation_bias"
    weight 0.2199
    evidence 48
    source "classic-lexicon"
  ]

  node [
    id 312
    label "property"
    kind "continuation_bias"
    weight 0.2199
    evidence 48
    source "classic-lexicon"
  ]

  node [
    id 313
    label "ring"
    kind "continuation_bias"
    weight 0.2199
    evidence 48
    source "classic-lexicon"
  ]

  node [
    id 314
    label "title"
    kind "continuation_bias"
    weight 0.2199
    evidence 48
    source "classic-lexicon"
  ]

  node [
    id 315
    label "yet"
    kind "continuation_bias"
    weight 0.2199
    evidence 48
    source "classic-lexicon"
  ]

  node [
    id 316
    label "cry"
    kind "continuation_bias"
    weight 0.2187
    evidence 47
    source "classic-lexicon"
  ]

  node [
    id 317
    label "half"
    kind "continuation_bias"
    weight 0.2187
    evidence 47
    source "classic-lexicon"
  ]

  node [
    id 318
    label "within"
    kind "continuation_bias"
    weight 0.2187
    evidence 47
    source "classic-lexicon"
  ]

  node [
    id 319
    label "ancient"
    kind "continuation_bias"
    weight 0.2175
    evidence 46
    source "classic-lexicon"
  ]

  node [
    id 320
    label "external"
    kind "continuation_bias"
    weight 0.2175
    evidence 46
    source "classic-lexicon"
  ]

  node [
    id 321
    label "fir"
    kind "continuation_bias"
    weight 0.2175
    evidence 46
    source "classic-lexicon"
  ]

  node [
    id 322
    label "firm"
    kind "continuation_bias"
    weight 0.2175
    evidence 46
    source "classic-lexicon"
  ]

  node [
    id 323
    label "leaves"
    kind "continuation_bias"
    weight 0.2175
    evidence 46
    source "classic-lexicon"
  ]

  node [
    id 324
    label "length"
    kind "continuation_bias"
    weight 0.2175
    evidence 46
    source "classic-lexicon"
  ]

  node [
    id 325
    label "method"
    kind "continuation_bias"
    weight 0.2175
    evidence 46
    source "classic-lexicon"
  ]

  node [
    id 326
    label "present"
    kind "continuation_bias"
    weight 0.2175
    evidence 46
    source "classic-lexicon"
  ]

  node [
    id 327
    label "coarse"
    kind "continuation_bias"
    weight 0.2163
    evidence 45
    source "classic-lexicon"
  ]

  node [
    id 328
    label "dark"
    kind "continuation_bias"
    weight 0.2163
    evidence 45
    source "classic-lexicon"
  ]

  node [
    id 329
    label "himself"
    kind "continuation_bias"
    weight 0.2163
    evidence 45
    source "classic-lexicon"
  ]

  node [
    id 330
    label "our"
    kind "continuation_bias"
    weight 0.2163
    evidence 45
    source "classic-lexicon"
  ]

  node [
    id 331
    label "petty"
    kind "continuation_bias"
    weight 0.2163
    evidence 45
    source "classic-lexicon"
  ]

  node [
    id 332
    label "pipe"
    kind "continuation_bias"
    weight 0.2163
    evidence 45
    source "classic-lexicon"
  ]

  node [
    id 333
    label "reproach"
    kind "continuation_bias"
    weight 0.2163
    evidence 45
    source "classic-lexicon"
  ]

  node [
    id 334
    label "trick"
    kind "continuation_bias"
    weight 0.2163
    evidence 45
    source "classic-lexicon"
  ]

  node [
    id 335
    label "angle"
    kind "continuation_bias"
    weight 0.2151
    evidence 44
    source "classic-lexicon"
  ]

  node [
    id 336
    label "humour"
    kind "continuation_bias"
    weight 0.2151
    evidence 44
    source "classic-lexicon"
  ]

  node [
    id 337
    label "main"
    kind "continuation_bias"
    weight 0.2151
    evidence 44
    source "classic-lexicon"
  ]

  node [
    id 338
    label "male"
    kind "continuation_bias"
    weight 0.2151
    evidence 44
    source "classic-lexicon"
  ]

  node [
    id 339
    label "particle"
    kind "continuation_bias"
    weight 0.2151
    evidence 44
    source "classic-lexicon"
  ]

  node [
    id 340
    label "proportion"
    kind "continuation_bias"
    weight 0.2151
    evidence 44
    source "classic-lexicon"
  ]

  node [
    id 341
    label "ready"
    kind "continuation_bias"
    weight 0.2151
    evidence 44
    source "classic-lexicon"
  ]

  node [
    id 342
    label "world"
    kind "continuation_bias"
    weight 0.2151
    evidence 44
    source "classic-lexicon"
  ]

  node [
    id 343
    label "command"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 344
    label "design"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 345
    label "edge"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 346
    label "leave"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 347
    label "loss"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 348
    label "press"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 349
    label "root"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 350
    label "teeth"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 351
    label "tie"
    kind "continuation_bias"
    weight 0.2138
    evidence 43
    source "classic-lexicon"
  ]

  node [
    id 352
    label "behind"
    kind "continuation_bias"
    weight 0.2125
    evidence 42
    source "classic-lexicon"
  ]

  node [
    id 353
    label "born"
    kind "continuation_bias"
    weight 0.2125
    evidence 42
    source "classic-lexicon"
  ]

  node [
    id 354
    label "coin"
    kind "continuation_bias"
    weight 0.2125
    evidence 42
    source "classic-lexicon"
  ]

  node [
    id 355
    label "injury"
    kind "continuation_bias"
    weight 0.2125
    evidence 42
    source "classic-lexicon"
  ]

  node [
    id 356
    label "meaning"
    kind "continuation_bias"
    weight 0.2125
    evidence 42
    source "classic-lexicon"
  ]

  node [
    id 357
    label "principle"
    kind "continuation_bias"
    weight 0.2125
    evidence 42
    source "classic-lexicon"
  ]

  node [
    id 358
    label "real"
    kind "continuation_bias"
    weight 0.2125
    evidence 42
    source "classic-lexicon"
  ]

  node [
    id 359
    label "wall"
    kind "continuation_bias"
    weight 0.2125
    evidence 42
    source "classic-lexicon"
  ]

  node [
    id 360
    label "goods"
    kind "continuation_bias"
    weight 0.2112
    evidence 41
    source "classic-lexicon"
  ]

  node [
    id 361
    label "heart"
    kind "continuation_bias"
    weight 0.2112
    evidence 41
    source "classic-lexicon"
  ]

  node [
    id 362
    label "plain"
    kind "continuation_bias"
    weight 0.2112
    evidence 41
    source "classic-lexicon"
  ]

  node [
    id 363
    label "true"
    kind "continuation_bias"
    weight 0.2112
    evidence 41
    source "classic-lexicon"
  ]

  node [
    id 364
    label "bent"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 365
    label "cant"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 366
    label "coming"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 367
    label "doubt"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 368
    label "empty"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 369
    label "fish"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 370
    label "grammar"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 371
    label "living"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 372
    label "tear"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 373
    label "tri"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 374
    label "tumult"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 375
    label "wo"
    kind "continuation_bias"
    weight 0.2098
    evidence 40
    source "classic-lexicon"
  ]

  node [
    id 376
    label "bread"
    kind "continuation_bias"
    weight 0.2084
    evidence 39
    source "classic-lexicon"
  ]

  node [
    id 377
    label "disposition"
    kind "continuation_bias"
    weight 0.2084
    evidence 39
    source "classic-lexicon"
  ]

  node [
    id 378
    label "hawk"
    kind "continuation_bias"
    weight 0.2084
    evidence 39
    source "classic-lexicon"
  ]

  node [
    id 379
    label "last"
    kind "continuation_bias"
    weight 0.2084
    evidence 39
    source "classic-lexicon"
  ]

  node [
    id 380
    label "opposition"
    kind "continuation_bias"
    weight 0.2084
    evidence 39
    source "classic-lexicon"
  ]

  node [
    id 381
    label "position"
    kind "continuation_bias"
    weight 0.2084
    evidence 39
    source "classic-lexicon"
  ]

  node [
    id 382
    label "attack"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 383
    label "bright"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 384
    label "car"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 385
    label "chance"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 386
    label "employment"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 387
    label "even"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 388
    label "fortune"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 389
    label "gree"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 390
    label "horn"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 391
    label "nice"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 392
    label "participle"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 393
    label "properly"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 394
    label "upper"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 395
    label "wicked"
    kind "continuation_bias"
    weight 0.207
    evidence 38
    source "classic-lexicon"
  ]

  node [
    id 396
    label "ball"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 397
    label "city"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 398
    label "corrupt"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 399
    label "covering"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 400
    label "evil"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 401
    label "gentle"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 402
    label "glass"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 403
    label "health"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 404
    label "limit"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 405
    label "opposite"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 406
    label "tid"
    kind "continuation_bias"
    weight 0.2055
    evidence 37
    source "classic-lexicon"
  ]

  node [
    id 407
    label "card"
    kind "continuation_bias"
    weight 0.204
    evidence 36
    source "classic-lexicon"
  ]

  node [
    id 408
    label "composition"
    kind "continuation_bias"
    weight 0.204
    evidence 36
    source "classic-lexicon"
  ]

  node [
    id 409
    label "degrees"
    kind "continuation_bias"
    weight 0.204
    evidence 36
    source "classic-lexicon"
  ]

  node [
    id 410
    label "die"
    kind "continuation_bias"
    weight 0.204
    evidence 36
    source "classic-lexicon"
  ]

  node [
    id 411
    label "gather"
    kind "continuation_bias"
    weight 0.204
    evidence 36
    source "classic-lexicon"
  ]

  node [
    id 412
    label "praise"
    kind "continuation_bias"
    weight 0.204
    evidence 36
    source "classic-lexicon"
  ]

  node [
    id 413
    label "pronoun"
    kind "continuation_bias"
    weight 0.204
    evidence 36
    source "classic-lexicon"
  ]

  node [
    id 414
    label "wrong"
    kind "continuation_bias"
    weight 0.204
    evidence 36
    source "classic-lexicon"
  ]

  node [
    id 415
    label "attempt"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 416
    label "bar"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 417
    label "bearing"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 418
    label "below"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 419
    label "bo"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 420
    label "bottom"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 421
    label "cannot"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 422
    label "gold"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 423
    label "hop"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 424
    label "idle"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 425
    label "ion"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 426
    label "liquid"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 427
    label "lock"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 428
    label "moon"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 429
    label "pair"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 430
    label "pure"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 431
    label "religious"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 432
    label "reverence"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 433
    label "rope"
    kind "continuation_bias"
    weight 0.2025
    evidence 35
    source "classic-lexicon"
  ]

  node [
    id 434
    label "apple"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 435
    label "both"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 436
    label "breath"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 437
    label "divine"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 438
    label "going"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 439
    label "guard"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 440
    label "hone"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 441
    label "privilege"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 442
    label "roll"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 443
    label "some"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 444
    label "timber"
    kind "continuation_bias"
    weight 0.2009
    evidence 34
    source "classic-lexicon"
  ]

  node [
    id 445
    label "branch"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 446
    label "breach"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 447
    label "contrast"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 448
    label "discourse"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 449
    label "feather"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 450
    label "fowl"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 451
    label "frame"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 452
    label "holy"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 453
    label "lord"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 454
    label "mode"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 455
    label "opening"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 456
    label "paper"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 457
    label "tender"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 458
    label "vain"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 459
    label "vile"
    kind "continuation_bias"
    weight 0.1993
    evidence 33
    source "classic-lexicon"
  ]

  node [
    id 460
    label "agent"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 461
    label "along"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 462
    label "beginning"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 463
    label "civil"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 464
    label "complete"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 465
    label "cure"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 466
    label "deal"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 467
    label "door"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 468
    label "height"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 469
    label "irregular"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 470
    label "lead"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 471
    label "merry"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 472
    label "small"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 473
    label "so"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 474
    label "taste"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 475
    label "wheel"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 476
    label "wide"
    kind "continuation_bias"
    weight 0.1976
    evidence 32
    source "classic-lexicon"
  ]

  node [
    id 477
    label "anger"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 478
    label "choice"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 479
    label "fallen"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 480
    label "fence"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 481
    label "memory"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 482
    label "noun"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 483
    label "quiet"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 484
    label "row"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 485
    label "trial"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 486
    label "worthy"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 487
    label "wretch"
    kind "continuation_bias"
    weight 0.1958
    evidence 31
    source "classic-lexicon"
  ]

  node [
    id 488
    label "bell"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 489
    label "broad"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 490
    label "burning"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 491
    label "cattle"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 492
    label "cross"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 493
    label "juice"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 494
    label "poem"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 495
    label "pole"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 496
    label "previous"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 497
    label "race"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 498
    label "reward"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 499
    label "river"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 500
    label "turning"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 501
    label "wool"
    kind "continuation_bias"
    weight 0.194
    evidence 30
    source "classic-lexicon"
  ]

  node [
    id 502
    label "bite"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 503
    label "board"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 504
    label "breed"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 505
    label "coat"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 506
    label "endeavour"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 507
    label "garment"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 508
    label "gross"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 509
    label "heaven"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 510
    label "hide"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 511
    label "inclination"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 512
    label "just"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 513
    label "lady"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 514
    label "legal"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 515
    label "lick"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 516
    label "mine"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 517
    label "noble"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 518
    label "principal"
    kind "continuation_bias"
    weight 0.1922
    evidence 29
    source "classic-lexicon"
  ]

  node [
    id 519
    label "arch"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 520
    label "arms"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 521
    label "belly"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 522
    label "cavity"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 523
    label "class"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 524
    label "cloud"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 525
    label "continuance"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 526
    label "copy"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 527
    label "crooked"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 528
    label "evidence"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 529
    label "finger"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 530
    label "former"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 531
    label "ice"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 532
    label "increase"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 533
    label "meal"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 534
    label "merriment"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 535
    label "moving"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 536
    label "nose"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 537
    label "notion"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 538
    label "peace"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 539
    label "plate"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 540
    label "portion"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 541
    label "proceeding"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 542
    label "pull"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 543
    label "region"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 544
    label "rude"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 545
    label "till"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 546
    label "town"
    kind "continuation_bias"
    weight 0.1903
    evidence 28
    source "classic-lexicon"
  ]

  node [
    id 547
    label "also"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 548
    label "bag"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 549
    label "better"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 550
    label "civility"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 551
    label "compass"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 552
    label "dance"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 553
    label "eager"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 554
    label "ease"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 555
    label "elevation"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 556
    label "entrance"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 557
    label "familiar"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 558
    label "feel"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 559
    label "gloomy"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 560
    label "handle"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 561
    label "ling"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 562
    label "meet"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 563
    label "oblique"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 564
    label "pointed"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 565
    label "powder"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 566
    label "prayer"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 567
    label "prince"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 568
    label "remain"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 569
    label "verse"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 570
    label "wooden"
    kind "continuation_bias"
    weight 0.1883
    evidence 27
    source "classic-lexicon"
  ]

  node [
    id 571
    label "anciently"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 572
    label "anew"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 573
    label "angry"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 574
    label "behaviour"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 575
    label "boat"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 576
    label "burn"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 577
    label "field"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 578
    label "fulness"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 579
    label "grace"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 580
    label "grave"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 581
    label "growth"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 582
    label "idea"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 583
    label "lean"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 584
    label "level"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 585
    label "liberty"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 586
    label "lively"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 587
    label "maker"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 588
    label "mother"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 589
    label "proof"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 590
    label "tune"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 591
    label "twenty"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 592
    label "worm"
    kind "continuation_bias"
    weight 0.1862
    evidence 26
    source "classic-lexicon"
  ]

  node [
    id 593
    label "agreement"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 594
    label "armour"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 595
    label "base"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 596
    label "composed"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 597
    label "criminal"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 598
    label "date"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 599
    label "distance"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 600
    label "doe"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 601
    label "double"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 602
    label "foil"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 603
    label "hurry"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 604
    label "joy"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 605
    label "member"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 606
    label "negligent"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 607
    label "organ"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 608
    label "pit"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 609
    label "planet"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 610
    label "plunder"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 611
    label "poetry"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 612
    label "proceed"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 613
    label "taught"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 614
    label "tenderness"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 615
    label "travel"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 616
    label "vigour"
    kind "continuation_bias"
    weight 0.1841
    evidence 25
    source "classic-lexicon"
  ]

  node [
    id 617
    label "accident"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 618
    label "approach"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 619
    label "battle"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 620
    label "beauty"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 621
    label "box"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 622
    label "built"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 623
    label "cock"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 624
    label "count"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 625
    label "cow"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 626
    label "delight"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 627
    label "discharge"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 628
    label "faith"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 629
    label "father"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 630
    label "formerly"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 631
    label "ingredient"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 632
    label "intention"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 633
    label "judicial"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 634
    label "mild"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 635
    label "mill"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 636
    label "mischief"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 637
    label "musical"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 638
    label "needle"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 639
    label "nothing"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 640
    label "outward"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 641
    label "peculiar"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 642
    label "purity"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 643
    label "quarrel"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 644
    label "resemblance"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 645
    label "train"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 646
    label "ware"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 647
    label "weed"
    kind "continuation_bias"
    weight 0.1819
    evidence 24
    source "classic-lexicon"
  ]

  node [
    id 648
    label "aside"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 649
    label "blue"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 650
    label "circular"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 651
    label "deck"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 652
    label "extreme"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 653
    label "forcible"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 654
    label "gaiety"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 655
    label "gently"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 656
    label "grain"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 657
    label "harass"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 658
    label "leap"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 659
    label "lion"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 660
    label "loosely"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 661
    label "moral"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 662
    label "native"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 663
    label "nine"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 664
    label "pall"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 665
    label "pear"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 666
    label "perplexity"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 667
    label "road"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 668
    label "third"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 669
    label "vehement"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 670
    label "wanton"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 671
    label "whether"
    kind "continuation_bias"
    weight 0.1796
    evidence 23
    source "classic-lexicon"
  ]

  node [
    id 672
    label "backward"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 673
    label "belief"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 674
    label "border"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 675
    label "decay"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 676
    label "decree"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 677
    label "eternal"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 678
    label "exercise"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 679
    label "express"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 680
    label "faculty"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 681
    label "fair"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 682
    label "fitness"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 683
    label "floor"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 684
    label "foreign"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 685
    label "frequently"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 686
    label "green"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 687
    label "hazard"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 688
    label "hope"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 689
    label "leather"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 690
    label "mere"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 691
    label "mingle"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 692
    label "mutual"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 693
    label "openly"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 694
    label "poison"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 695
    label "precious"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 696
    label "process"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 697
    label "trouble"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 698
    label "turbulent"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 699
    label "twelve"
    kind "continuation_bias"
    weight 0.1772
    evidence 22
    source "classic-lexicon"
  ]

  node [
    id 700
    label "cease"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 701
    label "clean"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 702
    label "coal"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 703
    label "coloured"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 704
    label "content"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 705
    label "corruption"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 706
    label "deer"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 707
    label "deviation"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 708
    label "early"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 709
    label "eight"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 710
    label "eminent"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 711
    label "fast"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 712
    label "feeble"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 713
    label "firmness"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 714
    label "flying"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 715
    label "fro"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 716
    label "guilty"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 717
    label "hanging"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 718
    label "hell"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 719
    label "holding"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 720
    label "hundred"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 721
    label "lightly"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 722
    label "mention"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 723
    label "naked"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 724
    label "oil"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 725
    label "paint"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 726
    label "palate"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 727
    label "payment"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 728
    label "poor"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 729
    label "remote"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 730
    label "remove"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 731
    label "uncertain"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 732
    label "usually"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 733
    label "vegetable"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 734
    label "warm"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 735
    label "whereby"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 736
    label "yellow"
    kind "continuation_bias"
    weight 0.1747
    evidence 21
    source "classic-lexicon"
  ]

  node [
    id 737
    label "arc"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 738
    label "arm"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 739
    label "bead"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 740
    label "bill"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 741
    label "brutal"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 742
    label "busy"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 743
    label "calling"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 744
    label "calm"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 745
    label "centre"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 746
    label "companion"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 747
    label "creature"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 748
    label "credit"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 749
    label "cunning"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 750
    label "delicate"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 751
    label "funeral"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 752
    label "gin"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 753
    label "heap"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 754
    label "hill"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 755
    label "hour"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 756
    label "inhabitant"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 757
    label "list"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 758
    label "malignity"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 759
    label "material"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 760
    label "month"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 761
    label "motive"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 762
    label "nearly"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 763
    label "pence"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 764
    label "promise"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 765
    label "reckoning"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 766
    label "tax"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 767
    label "upward"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 768
    label "vulgar"
    kind "continuation_bias"
    weight 0.172
    evidence 20
    source "classic-lexicon"
  ]

  node [
    id 769
    label "abode"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 770
    label "author"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 771
    label "bank"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 772
    label "blame"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 773
    label "bulky"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 774
    label "ceremony"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 775
    label "closely"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 776
    label "commotion"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 777
    label "conclusion"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 778
    label "concretion"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 779
    label "dispute"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 780
    label "dominion"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 781
    label "downward"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 782
    label "duration"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 783
    label "enough"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 784
    label "escape"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 785
    label "fragrant"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 786
    label "friend"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 787
    label "girl"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 788
    label "glutinous"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 789
    label "gut"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 790
    label "harmony"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 791
    label "hire"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 792
    label "load"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 793
    label "mis"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 794
    label "mould"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 795
    label "north"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 796
    label "passion"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 797
    label "personal"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 798
    label "pillar"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 799
    label "read"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 800
    label "remarkable"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 801
    label "removal"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 802
    label "tail"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 803
    label "trary"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 804
    label "troop"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 805
    label "vapour"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 806
    label "waste"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 807
    label "wonder"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 808
    label "worthless"
    kind "continuation_bias"
    weight 0.1693
    evidence 19
    source "classic-lexicon"
  ]

  node [
    id 809
    label "agency"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 810
    label "airy"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 811
    label "balance"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 812
    label "burthen"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 813
    label "cap"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 814
    label "descent"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 815
    label "element"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 816
    label "excellent"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 817
    label "flag"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 818
    label "flesh"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 819
    label "fool"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 820
    label "furious"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 821
    label "knight"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 822
    label "learning"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 823
    label "limb"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 824
    label "lime"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 825
    label "looking"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 826
    label "march"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 827
    label "mate"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 828
    label "meeting"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 829
    label "mien"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 830
    label "mock"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 831
    label "nail"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 832
    label "negligence"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 833
    label "observation"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 834
    label "petition"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 835
    label "physick"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 836
    label "rock"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 837
    label "tool"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 838
    label "torment"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 839
    label "transparent"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 840
    label "tumour"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 841
    label "vessel"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 842
    label "vigorous"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 843
    label "wan"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 844
    label "weary"
    kind "continuation_bias"
    weight 0.1664
    evidence 18
    source "classic-lexicon"
  ]

  node [
    id 845
    label "after"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 846
    label "ale"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 847
    label "ally"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 848
    label "animate"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 849
    label "binding"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 850
    label "burden"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 851
    label "cat"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 852
    label "cautious"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 853
    label "clergy"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 854
    label "column"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 855
    label "community"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 856
    label "current"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 857
    label "eaten"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 858
    label "fluid"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 859
    label "forces"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 860
    label "front"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 861
    label "generation"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 862
    label "happy"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 863
    label "immediately"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 864
    label "incapable"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 865
    label "indian"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 866
    label "inheritance"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 867
    label "jest"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 868
    label "knowing"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 869
    label "lone"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 870
    label "malice"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 871
    label "meanness"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 872
    label "merely"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 873
    label "murder"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 874
    label "neat"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 875
    label "need"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 876
    label "obligation"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 877
    label "occasion"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 878
    label "plainly"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 879
    label "publickly"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 880
    label "range"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 881
    label "reception"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 882
    label "remedy"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 883
    label "ripe"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 884
    label "rugged"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 885
    label "somewhat"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 886
    label "strong"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 887
    label "temporary"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 888
    label "tense"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 889
    label "toil"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 890
    label "tory"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 891
    label "vein"
    kind "continuation_bias"
    weight 0.1633
    evidence 17
    source "classic-lexicon"
  ]

  node [
    id 892
    label "ability"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 893
    label "address"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 894
    label "aim"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 895
    label "allowance"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 896
    label "appetite"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 897
    label "arrow"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 898
    label "bark"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 899
    label "beam"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 900
    label "beer"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 901
    label "bold"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 902
    label "brightness"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 903
    label "cent"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 904
    label "certainty"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 905
    label "clay"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 906
    label "cloaths"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 907
    label "contest"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 908
    label "cord"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 909
    label "countenance"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 910
    label "courage"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 911
    label "crowd"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 912
    label "darkness"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 913
    label "discovery"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 914
    label "eagerness"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 915
    label "employ"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 916
    label "equivalent"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 917
    label "exempt"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 918
    label "expedient"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 919
    label "extremity"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 920
    label "failure"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 921
    label "falsely"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 922
    label "file"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 923
    label "folly"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 924
    label "fragment"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 925
    label "fume"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 926
    label "gland"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 927
    label "grate"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 928
    label "happiness"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 929
    label "hardness"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 930
    label "harm"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 931
    label "idly"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 932
    label "melancholy"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 933
    label "mirth"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 934
    label "moderate"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 935
    label "moveable"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 936
    label "ore"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 937
    label "pale"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 938
    label "pick"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 939
    label "plane"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 940
    label "pledge"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 941
    label "prison"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 942
    label "pursuit"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 943
    label "quarter"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 944
    label "quit"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 945
    label "relief"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 946
    label "remark"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 947
    label "robber"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 948
    label "rose"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 949
    label "thief"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 950
    label "tile"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 951
    label "treatment"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 952
    label "uneasiness"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 953
    label "urine"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 954
    label "wickedness"
    kind "continuation_bias"
    weight 0.1601
    evidence 16
    source "classic-lexicon"
  ]

  node [
    id 955
    label "action"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 956
    label "aperture"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 957
    label "barrel"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 958
    label "blind"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 959
    label "brain"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 960
    label "brick"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 961
    label "bundle"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 962
    label "cannon"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 963
    label "combat"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 964
    label "compliance"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 965
    label "concert"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 966
    label "concord"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 967
    label "cool"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 968
    label "crack"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 969
    label "eagerly"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 970
    label "eminently"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 971
    label "fay"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 972
    label "feeling"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 973
    label "fever"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 974
    label "frolick"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 975
    label "fury"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 976
    label "goodness"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 977
    label "grape"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 978
    label "hare"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 979
    label "liberal"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 980
    label "mall"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 981
    label "mankind"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 982
    label "pile"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 983
    label "punishment"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 984
    label "reserve"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 985
    label "revenue"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 986
    label "sharp"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 987
    label "stone"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 988
    label "terrible"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 989
    label "triumph"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 990
    label "twice"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 991
    label "upright"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 992
    label "west"
    kind "continuation_bias"
    weight 0.1567
    evidence 15
    source "classic-lexicon"
  ]

  node [
    id 993
    label "acid"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 994
    label "agitation"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 995
    label "anchor"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 996
    label "apparent"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 997
    label "ardour"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 998
    label "article"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 999
    label "big"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1000
    label "block"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1001
    label "breadth"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1002
    label "brown"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1003
    label "bud"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1004
    label "capital"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1005
    label "careless"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1006
    label "cement"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1007
    label "chamber"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1008
    label "clamour"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1009
    label "comparative"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1010
    label "dealing"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1011
    label "decline"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1012
    label "departure"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1013
    label "devotion"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1014
    label "dice"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1015
    label "ding"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1016
    label "dislike"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1017
    label "divinity"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1018
    label "doing"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1019
    label "dread"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1020
    label "dung"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1021
    label "errour"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1022
    label "ether"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1023
    label "ever"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1024
    label "favourable"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1025
    label "feast"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1026
    label "firing"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1027
    label "flax"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1028
    label "flock"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1029
    label "garden"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1030
    label "grandeur"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1031
    label "gravity"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1032
    label "heed"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1033
    label "here"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1034
    label "honey"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1035
    label "lace"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1036
    label "lustre"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1037
    label "malignant"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1038
    label "most"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1039
    label "noxious"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1040
    label "originally"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1041
    label "ornamental"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1042
    label "perceptible"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1043
    label "perverse"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1044
    label "poverty"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1045
    label "preserve"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1046
    label "prize"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1047
    label "prohibition"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1048
    label "province"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1049
    label "prudence"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1050
    label "texture"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1051
    label "transport"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1052
    label "trunk"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1053
    label "unable"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1054
    label "universal"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1055
    label "utterance"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1056
    label "valuable"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1057
    label "wax"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1058
    label "wea"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1059
    label "weakness"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1060
    label "whence"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1061
    label "willing"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1062
    label "winter"
    kind "continuation_bias"
    weight 0.153
    evidence 14
    source "classic-lexicon"
  ]

  node [
    id 1063
    label "absence"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1064
    label "acute"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1065
    label "adherence"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1066
    label "bore"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1067
    label "bully"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1068
    label "certainly"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1069
    label "character"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1070
    label "check"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1071
    label "compound"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1072
    label "concerning"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1073
    label "converse"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1074
    label "convert"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1075
    label "corner"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1076
    label "corporeal"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1077
    label "curve"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1078
    label "dealer"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1079
    label "depart"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1080
    label "distant"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1081
    label "dulness"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1082
    label "exchange"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1083
    label "execution"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1084
    label "fatigue"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1085
    label "fibre"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1086
    label "final"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1087
    label "forbearance"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1088
    label "gem"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1089
    label "generous"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1090
    label "heal"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1091
    label "hoot"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1092
    label "impediment"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1093
    label "journey"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1094
    label "keeper"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1095
    label "lake"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1096
    label "lament"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1097
    label "laughter"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1098
    label "lazy"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1099
    label "learned"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1100
    label "ledge"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1101
    label "levity"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1102
    label "lover"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1103
    label "lungs"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1104
    label "madness"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1105
    label "maid"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1106
    label "maintenance"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1107
    label "married"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1108
    label "master"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1109
    label "meditation"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1110
    label "mercy"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1111
    label "mountain"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1112
    label "muscle"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1113
    label "obedience"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1114
    label "obstinate"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1115
    label "odd"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1116
    label "painting"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1117
    label "parallel"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1118
    label "parent"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1119
    label "pause"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1120
    label "period"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1121
    label "pore"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1122
    label "privation"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1123
    label "progress"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1124
    label "proposition"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1125
    label "puzzle"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1126
    label "ramble"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1127
    label "relative"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1128
    label "report"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1129
    label "rich"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1130
    label "rightly"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1131
    label "roof"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1132
    label "rouse"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1133
    label "sour"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1134
    label "tall"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1135
    label "tame"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1136
    label "teacher"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1137
    label "tenure"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1138
    label "termination"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1139
    label "track"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1140
    label "trull"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1141
    label "twist"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1142
    label "vision"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1143
    label "while"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1144
    label "whore"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1145
    label "window"
    kind "continuation_bias"
    weight 0.1491
    evidence 13
    source "classic-lexicon"
  ]

  node [
    id 1146
    label "abatement"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1147
    label "abroad"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1148
    label "aid"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1149
    label "alive"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1150
    label "always"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1151
    label "ardent"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1152
    label "attendant"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1153
    label "beak"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1154
    label "bravery"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1155
    label "candle"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1156
    label "clamorous"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1157
    label "comb"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1158
    label "connexion"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1159
    label "convex"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1160
    label "copper"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1161
    label "cruelty"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1162
    label "curse"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1163
    label "dependant"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1164
    label "depth"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1165
    label "evident"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1166
    label "except"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1167
    label "exclamation"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1168
    label "exuberant"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1169
    label "fare"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1170
    label "farm"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1171
    label "farther"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1172
    label "few"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1173
    label "fierce"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1174
    label "flexure"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1175
    label "forcibly"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1176
    label "forepart"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1177
    label "fruits"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1178
    label "gradual"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1179
    label "gripe"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1180
    label "haughty"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1181
    label "hearing"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1182
    label "hedge"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1183
    label "heel"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1184
    label "home"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1185
    label "hound"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1186
    label "humble"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1187
    label "inner"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1188
    label "insolent"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1189
    label "internal"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1190
    label "jews"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1191
    label "kite"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1192
    label "local"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1193
    label "match"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1194
    label "mineral"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1195
    label "minute"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1196
    label "mire"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1197
    label "moderation"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1198
    label "moist"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1199
    label "mortar"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1200
    label "never"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1201
    label "nimbly"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1202
    label "orb"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1203
    label "outcry"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1204
    label "painter"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1205
    label "pardon"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1206
    label "past"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1207
    label "pate"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1208
    label "perhaps"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1209
    label "permit"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1210
    label "physical"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1211
    label "pine"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1212
    label "plump"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1213
    label "practice"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1214
    label "priest"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1215
    label "prudent"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1216
    label "rain"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1217
    label "readily"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1218
    label "readiness"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1219
    label "reading"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1220
    label "really"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1221
    label "repair"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1222
    label "repeat"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1223
    label "repose"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1224
    label "residence"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1225
    label "retire"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1226
    label "riches"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1227
    label "ridicule"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1228
    label "rigorous"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1229
    label "royal"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1230
    label "rustick"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1231
    label "theology"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1232
    label "thigh"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1233
    label "threat"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1234
    label "tide"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1235
    label "tumultuous"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1236
    label "unhappy"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1237
    label "unit"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1238
    label "untaught"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1239
    label "visible"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1240
    label "vomit"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1241
    label "worse"
    kind "continuation_bias"
    weight 0.1449
    evidence 12
    source "classic-lexicon"
  ]

  node [
    id 1242
    label "abundance"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1243
    label "ace"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1244
    label "across"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1245
    label "ago"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1246
    label "apartment"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1247
    label "appendant"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1248
    label "arithmetick"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1249
    label "arrogant"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1250
    label "bate"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1251
    label "bench"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1252
    label "brittle"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1253
    label "bull"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1254
    label "burst"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1255
    label "casual"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1256
    label "circuit"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1257
    label "convenient"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1258
    label "cot"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1259
    label "counter"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1260
    label "crush"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1261
    label "curl"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1262
    label "dangerous"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1263
    label "declivity"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1264
    label "deprivation"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1265
    label "description"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1266
    label "desert"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1267
    label "dexterity"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1268
    label "diligent"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1269
    label "dismal"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1270
    label "display"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1271
    label "dole"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1272
    label "dully"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1273
    label "east"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1274
    label "embrace"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1275
    label "engine"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1276
    label "envy"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1277
    label "equality"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1278
    label "example"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1279
    label "failing"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1280
    label "fidelity"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1281
    label "flatter"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1282
    label "foundation"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1283
    label "genuine"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1284
    label "globe"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1285
    label "gradually"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1286
    label "grains"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1287
    label "grown"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1288
    label "haste"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1289
    label "hatch"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1290
    label "healing"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1291
    label "heard"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1292
    label "idler"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1293
    label "imaginary"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1294
    label "impress"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1295
    label "improperly"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1296
    label "impudent"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1297
    label "impulse"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1298
    label "inequality"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1299
    label "innocent"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1300
    label "inside"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1301
    label "insult"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1302
    label "interruption"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1303
    label "inward"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1304
    label "judicially"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1305
    label "lame"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1306
    label "lax"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1307
    label "lucky"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1308
    label "malicious"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1309
    label "marble"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1310
    label "medical"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1311
    label "mentally"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1312
    label "meridian"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1313
    label "model"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1314
    label "moisture"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1315
    label "monk"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1316
    label "morning"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1317
    label "multitude"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1318
    label "nerve"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1319
    label "oak"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1320
    label "off"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1321
    label "omen"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1322
    label "opprobrious"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1323
    label "owner"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1324
    label "perpetual"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1325
    label "pie"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1326
    label "pigeon"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1327
    label "pike"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1328
    label "pillage"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1329
    label "pint"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1330
    label "player"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1331
    label "poet"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1332
    label "pope"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1333
    label "pregnant"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1334
    label "prominent"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1335
    label "pulse"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1336
    label "quid"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1337
    label "rather"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1338
    label "recovery"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1339
    label "reign"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1340
    label "reparation"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1341
    label "sweet"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1342
    label "tedious"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1343
    label "tenant"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1344
    label "thew"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1345
    label "thousand"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1346
    label "thrice"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1347
    label "tread"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1348
    label "type"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1349
    label "uneven"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1350
    label "useless"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1351
    label "wages"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1352
    label "weighty"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1353
    label "yard"
    kind "continuation_bias"
    weight 0.1404
    evidence 11
    source "classic-lexicon"
  ]

  node [
    id 1354
    label "acrid"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1355
    label "advancement"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1356
    label "agony"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1357
    label "ait"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1358
    label "amends"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1359
    label "antecedent"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1360
    label "attentively"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1361
    label "ay"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1362
    label "bandage"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1363
    label "bitter"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1364
    label "breathing"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1365
    label "carnal"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1366
    label "cave"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1367
    label "cavern"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1368
    label "chase"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1369
    label "cheer"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1370
    label "chest"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1371
    label "cloudy"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1372
    label "collision"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1373
    label "commodity"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1374
    label "cone"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1375
    label "corporation"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1376
    label "cowardly"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1377
    label "crook"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1378
    label "crown"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1379
    label "daughter"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1380
    label "decision"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1381
    label "deed"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1382
    label "delicacy"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1383
    label "doom"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1384
    label "dross"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1385
    label "drunkard"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1386
    label "dwelling"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1387
    label "earthen"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1388
    label "education"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1389
    label "elevate"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1390
    label "empire"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1391
    label "emption"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1392
    label "estate"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1393
    label "esteem"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1394
    label "excess"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1395
    label "fabrick"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1396
    label "fetch"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1397
    label "fox"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1398
    label "frequency"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1399
    label "girdle"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1400
    label "goose"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1401
    label "gradation"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1402
    label "hake"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1403
    label "hammer"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1404
    label "heavenly"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1405
    label "hind"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1406
    label "ignorant"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1407
    label "incident"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1408
    label "intent"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1409
    label "interval"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1410
    label "justice"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1411
    label "keen"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1412
    label "key"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1413
    label "knee"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1414
    label "lading"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1415
    label "lance"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1416
    label "likeness"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1417
    label "loudly"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1418
    label "moment"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1419
    label "morbid"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1420
    label "mortal"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1421
    label "narrative"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1422
    label "oar"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1423
    label "overthrow"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1424
    label "path"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1425
    label "pinch"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1426
    label "pitch"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1427
    label "planted"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1428
    label "pliant"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1429
    label "premises"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1430
    label "push"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1431
    label "raw"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1432
    label "ray"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1433
    label "repetition"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1434
    label "rigour"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1435
    label "saviour"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1436
    label "short"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1437
    label "sorrow"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1438
    label "tale"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1439
    label "tar"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1440
    label "taunt"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1441
    label "tenderly"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1442
    label "territory"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1443
    label "tiling"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1444
    label "torture"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1445
    label "toss"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1446
    label "touching"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1447
    label "treachery"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1448
    label "troublesome"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1449
    label "uncommon"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1450
    label "unknown"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1451
    label "unlimited"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1452
    label "ure"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1453
    label "vicious"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1454
    label "warrant"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1455
    label "weakly"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1456
    label "wealth"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1457
    label "wherein"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1458
    label "whim"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1459
    label "zealous"
    kind "continuation_bias"
    weight 0.1355
    evidence 10
    source "classic-lexicon"
  ]

  node [
    id 1460
    label "absolute"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1461
    label "accurately"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1462
    label "adequate"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1463
    label "alms"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1464
    label "anxiety"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1465
    label "approbation"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1466
    label "appropriate"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1467
    label "arched"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1468
    label "armorial"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1469
    label "ass"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1470
    label "asunder"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1471
    label "awkward"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1472
    label "axis"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1473
    label "bladder"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1474
    label "boar"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1475
    label "bowl"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1476
    label "breeding"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1477
    label "brook"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1478
    label "cable"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1479
    label "calmness"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1480
    label "caprice"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1481
    label "cart"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1482
    label "caught"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1483
    label "chill"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1484
    label "clearly"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1485
    label "clown"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1486
    label "concealment"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1487
    label "conceit"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1488
    label "contention"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1489
    label "conveyance"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1490
    label "critical"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1491
    label "crop"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1492
    label "dear"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1493
    label "deeply"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1494
    label "degenerate"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1495
    label "deity"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1496
    label "deliberation"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1497
    label "denial"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1498
    label "devil"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1499
    label "diameter"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1500
    label "direct"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1501
    label "distress"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1502
    label "ditch"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1503
    label "duck"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1504
    label "dwarf"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1505
    label "eighth"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1506
    label "ell"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1507
    label "epithet"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1508
    label "exception"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1509
    label "experiment"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1510
    label "falsehood"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1511
    label "fetter"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1512
    label "fickly"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1513
    label "fiddle"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1514
    label "fitly"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1515
    label "fleet"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1516
    label "flux"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1517
    label "forwards"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1518
    label "froward"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1519
    label "futurity"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1520
    label "gone"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1521
    label "grossly"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1522
    label "guardian"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1523
    label "habitually"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1524
    label "hail"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1525
    label "hasty"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1526
    label "heavily"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1527
    label "hock"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1528
    label "impose"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1529
    label "inelegant"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1530
    label "intercourse"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1531
    label "jump"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1532
    label "kindred"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1533
    label "latter"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1534
    label "leaf"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1535
    label "league"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1536
    label "lender"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1537
    label "liberality"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1538
    label "literal"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1539
    label "literature"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1540
    label "lure"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1541
    label "mandate"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1542
    label "manual"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1543
    label "market"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1544
    label "mature"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1545
    label "muddy"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1546
    label "naturally"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1547
    label "nobility"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1548
    label "novelty"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1549
    label "oral"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1550
    label "ordinal"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1551
    label "otherwise"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1552
    label "outer"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1553
    label "page"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1554
    label "pent"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1555
    label "piety"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1556
    label "pimple"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1557
    label "plague"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1558
    label "prejudice"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1559
    label "preparation"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1560
    label "presence"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1561
    label "reasoning"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1562
    label "record"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1563
    label "reed"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1564
    label "resolve"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1565
    label "respiration"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1566
    label "ress"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1567
    label "retirement"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1568
    label "review"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1569
    label "royalty"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1570
    label "rudeness"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1571
    label "sea"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1572
    label "tenet"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1573
    label "tenour"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1574
    label "thorn"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1575
    label "trace"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1576
    label "trader"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1577
    label "ugly"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1578
    label "uncivil"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1579
    label "unpleasing"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1580
    label "unreasonable"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1581
    label "vainly"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1582
    label "venereal"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1583
    label "wearing"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1584
    label "whip"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1585
    label "witness"
    kind "continuation_bias"
    weight 0.1301
    evidence 9
    source "classic-lexicon"
  ]

  node [
    id 1586
    label "abuse"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1587
    label "acrimony"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1588
    label "alien"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1589
    label "amount"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1590
    label "anatomy"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1591
    label "anxious"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1592
    label "backwards"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1593
    label "bay"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1594
    label "blameable"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1595
    label "bloody"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1596
    label "boldness"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1597
    label "bowels"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1598
    label "breeches"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1599
    label "bridle"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1600
    label "cathedral"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1601
    label "cauf"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1602
    label "celebration"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1603
    label "ceremonious"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1604
    label "cess"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1605
    label "chair"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1606
    label "challenge"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1607
    label "charity"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1608
    label "cheek"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1609
    label "circularly"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1610
    label "clock"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1611
    label "coarsely"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1612
    label "cod"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1613
    label "complaint"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1614
    label "continuity"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1615
    label "covenant"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1616
    label "damage"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1617
    label "delicious"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1618
    label "dense"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1619
    label "dial"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1620
    label "diet"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1621
    label "diligence"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1622
    label "dirty"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1623
    label "discontent"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1624
    label "disguise"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1625
    label "disordered"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1626
    label "dispose"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1627
    label "emblem"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1628
    label "explanation"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1629
    label "expression"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1630
    label "feller"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1631
    label "fertile"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1632
    label "fertility"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1633
    label "fillet"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1634
    label "filly"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1635
    label "finery"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1636
    label "firmly"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1637
    label "foam"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1638
    label "formation"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1639
    label "fraudulent"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1640
    label "gayety"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1641
    label "genius"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1642
    label "gratitude"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1643
    label "grease"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1644
    label "harmless"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1645
    label "harmonious"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1646
    label "harsh"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1647
    label "highly"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1648
    label "honesty"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1649
    label "household"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1650
    label "hum"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1651
    label "idleness"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1652
    label "ile"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1653
    label "immaterial"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1654
    label "importunate"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1655
    label "improper"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1656
    label "impure"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1657
    label "injurious"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1658
    label "insipid"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1659
    label "intricacy"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1660
    label "involution"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1661
    label "jewel"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1662
    label "jointed"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1663
    label "keeping"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1664
    label "knock"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1665
    label "lately"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1666
    label "laugh"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1667
    label "laxity"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1668
    label "layer"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1669
    label "lees"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1670
    label "lewd"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1671
    label "likely"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1672
    label "lodge"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1673
    label "luck"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1674
    label "mid"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1675
    label "mildly"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1676
    label "modern"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1677
    label "morose"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1678
    label "nef"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1679
    label "northern"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1680
    label "obedient"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1681
    label "ointment"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1682
    label "ordinary"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1683
    label "parsimony"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1684
    label "parting"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1685
    label "pattern"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1686
    label "petulant"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1687
    label "popular"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1688
    label "prick"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1689
    label "printing"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1690
    label "rare"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1691
    label "ravenous"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1692
    label "recourse"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1693
    label "redness"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1694
    label "repeal"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1695
    label "requisite"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1696
    label "rescue"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1697
    label "resin"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1698
    label "retired"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1699
    label "retreat"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1700
    label "riding"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1701
    label "rotten"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1702
    label "rupture"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1703
    label "search"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1704
    label "shut"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1705
    label "slight"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1706
    label "sound"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1707
    label "space"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1708
    label "struck"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1709
    label "stupid"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1710
    label "tack"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1711
    label "tendon"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1712
    label "tension"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1713
    label "tire"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1714
    label "tithe"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1715
    label "tone"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1716
    label "tooth"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1717
    label "tough"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1718
    label "traveller"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1719
    label "treacherous"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1720
    label "tribute"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1721
    label "trip"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1722
    label "truly"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1723
    label "ulcer"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1724
    label "unnatural"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1725
    label "vagabond"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1726
    label "valley"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1727
    label "vehicle"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1728
    label "venture"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1729
    label "virtuous"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1730
    label "vocal"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1731
    label "voluntary"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1732
    label "vowel"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1733
    label "wager"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1734
    label "warlike"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1735
    label "wheat"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1736
    label "wickedly"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1737
    label "won"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1738
    label "woollen"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1739
    label "wort"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1740
    label "wretched"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1741
    label "you"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1742
    label "zodiack"
    kind "continuation_bias"
    weight 0.1242
    evidence 8
    source "classic-lexicon"
  ]

  node [
    id 1743
    label "abandoned"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1744
    label "abundant"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1745
    label "abundantly"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1746
    label "adaptation"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1747
    label "agreeably"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1748
    label "ague"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1749
    label "alteration"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1750
    label "appeal"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1751
    label "aptness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1752
    label "artless"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1753
    label "ascent"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1754
    label "atrocious"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1755
    label "attendance"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1756
    label "awake"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1757
    label "badness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1758
    label "baseness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1759
    label "beetle"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1760
    label "beloved"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1761
    label "bile"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1762
    label "bitterness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1763
    label "botany"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1764
    label "brace"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1765
    label "bridge"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1766
    label "brood"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1767
    label "camp"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1768
    label "cavil"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1769
    label "chat"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1770
    label "christian"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1771
    label "chyle"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1772
    label "clergyman"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1773
    label "college"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1774
    label "combination"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1775
    label "communion"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1776
    label "concise"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1777
    label "conclusive"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1778
    label "congelation"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1779
    label "conqueror"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1780
    label "contract"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1781
    label "copious"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1782
    label "corporal"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1783
    label "council"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1784
    label "crease"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1785
    label "culpable"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1786
    label "dawn"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1787
    label "dedication"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1788
    label "deluge"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1789
    label "desirous"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1790
    label "disgust"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1791
    label "distemper"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1792
    label "diversity"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1793
    label "drain"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1794
    label "duke"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1795
    label "during"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1796
    label "eagle"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1797
    label "easiness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1798
    label "elegantly"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1799
    label "emperor"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1800
    label "enchantment"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1801
    label "entrails"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1802
    label "examiner"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1803
    label "exertion"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1804
    label "exorbitant"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1805
    label "experience"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1806
    label "extremely"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1807
    label "exuberance"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1808
    label "fairy"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1809
    label "familiarity"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1810
    label "feature"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1811
    label "fickle"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1812
    label "fiery"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1813
    label "flood"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1814
    label "foulness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1815
    label "fraudulently"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1816
    label "friendly"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1817
    label "fringe"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1818
    label "fter"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1819
    label "further"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1820
    label "giddy"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1821
    label "gloom"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1822
    label "golden"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1823
    label "grasp"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1824
    label "grey"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1825
    label "harvest"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1826
    label "hatred"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1827
    label "heady"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1828
    label "heathen"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1829
    label "heave"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1830
    label "heaviness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1831
    label "hermit"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1832
    label "hive"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1833
    label "honest"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1834
    label "hoop"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1835
    label "horrible"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1836
    label "horseback"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1837
    label "however"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1838
    label "idiom"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1839
    label "idiot"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1840
    label "immunity"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1841
    label "imputation"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1842
    label "incision"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1843
    label "individual"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1844
    label "inevitable"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1845
    label "inordinate"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1846
    label "inquiry"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1847
    label "insidious"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1848
    label "invasion"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1849
    label "issue"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1850
    label "laborious"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1851
    label "landing"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1852
    label "leading"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1853
    label "liberally"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1854
    label "licentious"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1855
    label "lights"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1856
    label "lily"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1857
    label "lineage"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1858
    label "liver"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1859
    label "mail"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1860
    label "malady"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1861
    label "malignantly"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1862
    label "mangle"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1863
    label "maxim"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1864
    label "medley"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1865
    label "might"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1866
    label "miserable"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1867
    label "moderately"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1868
    label "mole"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1869
    label "monarch"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1870
    label "movement"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1871
    label "negation"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1872
    label "noted"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1873
    label "obscene"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1874
    label "occult"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1875
    label "occurrence"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1876
    label "odour"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1877
    label "opera"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1878
    label "opponent"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1879
    label "park"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1880
    label "pea"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1881
    label "pellucid"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1882
    label "pernicious"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1883
    label "pious"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1884
    label "pleasant"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1885
    label "plunderer"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1886
    label "pompous"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1887
    label "precedent"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1888
    label "pretender"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1889
    label "proverbial"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1890
    label "publication"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1891
    label "purse"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1892
    label "recital"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1893
    label "regiment"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1894
    label "renown"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1895
    label "result"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1896
    label "reve"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1897
    label "revel"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1898
    label "revenge"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1899
    label "rigid"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1900
    label "ripeness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1901
    label "rogue"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1902
    label "rotation"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1903
    label "rudiment"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1904
    label "secret"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1905
    label "show"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1906
    label "suit"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1907
    label "temptation"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1908
    label "tho"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1909
    label "thunder"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1910
    label "timely"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1911
    label "tobacco"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1912
    label "toper"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1913
    label "tower"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1914
    label "tragedy"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1915
    label "trail"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1916
    label "tremulous"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1917
    label "unbecoming"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1918
    label "unsold"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1919
    label "unwilling"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1920
    label "utmost"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1921
    label "vacuity"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1922
    label "vapid"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1923
    label "virgin"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1924
    label "visit"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1925
    label "vocation"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1926
    label "volatile"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1927
    label "wake"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1928
    label "wantonness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1929
    label "whale"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1930
    label "willingness"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1931
    label "woody"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1932
    label "yarn"
    kind "continuation_bias"
    weight 0.1175
    evidence 7
    source "classic-lexicon"
  ]

  node [
    id 1933
    label "absent"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1934
    label "absolutely"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1935
    label "absurdity"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1936
    label "acceptance"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1937
    label "adherent"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1938
    label "adhesive"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1939
    label "adultery"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1940
    label "adventure"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1941
    label "advice"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1942
    label "alarm"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1943
    label "ambiguous"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1944
    label "apology"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1945
    label "arbitrary"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1946
    label "asperity"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1947
    label "avarice"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1948
    label "avaricious"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1949
    label "aversion"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1950
    label "bale"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1951
    label "bard"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1952
    label "bare"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1953
    label "basis"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1954
    label "bearer"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1955
    label "bishop"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1956
    label "boundless"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1957
    label "brutality"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1958
    label "bullet"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1959
    label "butcher"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1960
    label "butt"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1961
    label "buyer"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1962
    label "cage"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1963
    label "calculation"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1964
    label "calmly"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1965
    label "canon"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1966
    label "chancery"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1967
    label "cherry"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1968
    label "childbirth"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1969
    label "chink"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1970
    label "chirurgeon"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1971
    label "civilly"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1972
    label "clash"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1973
    label "claw"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1974
    label "clearness"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1975
    label "clog"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1976
    label "cohesion"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1977
    label "comparison"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1978
    label "complaisance"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1979
    label "compliment"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1980
    label "conducive"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1981
    label "conquerable"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1982
    label "conscience"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1983
    label "convulsion"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1984
    label "cork"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1985
    label "county"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1986
    label "covert"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1987
    label "cruelly"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1988
    label "curd"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1989
    label "custody"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1990
    label "dagger"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1991
    label "darkly"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1992
    label "deliverance"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1993
    label "depravity"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1994
    label "descry"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1995
    label "despicable"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1996
    label "dier"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1997
    label "dimension"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1998
    label "disregard"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 1999
    label "diver"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2000
    label "dock"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2001
    label "dream"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2002
    label "drone"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2003
    label "durable"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2004
    label "earnest"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2005
    label "endearment"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2006
    label "exaltation"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2007
    label "excursion"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2008
    label "fawn"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2009
    label "felicity"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2010
    label "fickleness"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2011
    label "flattery"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2012
    label "forest"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2013
    label "foretoken"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2014
    label "fortress"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2015
    label "forty"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2016
    label "freight"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2017
    label "frost"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2018
    label "fusion"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2019
    label "gallon"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2020
    label "german"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2021
    label "gibe"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2022
    label "glance"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2023
    label "glitter"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2024
    label "glory"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2025
    label "goat"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2026
    label "greatly"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2027
    label "guess"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2028
    label "gunpowder"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2029
    label "harbour"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2030
    label "heir"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2031
    label "herd"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2032
    label "hereditary"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2033
    label "hostile"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2034
    label "hue"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2035
    label "hunger"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2036
    label "husband"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2037
    label "immense"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2038
    label "impious"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2039
    label "inseparable"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2040
    label "integral"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2041
    label "invention"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2042
    label "ire"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2043
    label "ironical"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2044
    label "itch"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2045
    label "jet"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2046
    label "judicious"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2047
    label "keenness"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2048
    label "kernel"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2049
    label "kettle"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2050
    label "kingdom"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2051
    label "lamina"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2052
    label "languor"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2053
    label "lawyer"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2054
    label "lazily"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2055
    label "lemon"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2056
    label "libidinous"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2057
    label "lid"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2058
    label "likelihood"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2059
    label "likewise"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2060
    label "limber"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2061
    label "lodging"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2062
    label "log"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2063
    label "logical"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2064
    label "luminous"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2065
    label "magistrate"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2066
    label "magnitude"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2067
    label "malevolence"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2068
    label "manageable"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2069
    label "medicament"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2070
    label "medium"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2071
    label "memorial"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2072
    label "merrily"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2073
    label "mimick"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2074
    label "mote"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2075
    label "mouse"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2076
    label "murderer"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2077
    label "must"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2078
    label "nauseous"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2079
    label "naval"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2080
    label "negative"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2081
    label "nervous"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2082
    label "observant"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2083
    label "oily"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2084
    label "orange"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2085
    label "oriental"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2086
    label "ought"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2087
    label "oven"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2088
    label "ox"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2089
    label "pagan"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2090
    label "paring"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2091
    label "parliament"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2092
    label "patron"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2093
    label "peel"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2094
    label "peevish"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2095
    label "penal"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2096
    label "pendant"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2097
    label "peril"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2098
    label "persuasion"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2099
    label "picture"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2100
    label "plait"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2101
    label "plough"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2102
    label "pollution"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2103
    label "populace"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2104
    label "portable"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2105
    label "positive"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2106
    label "possible"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2107
    label "pretence"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2108
    label "prickly"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2109
    label "printer"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2110
    label "priority"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2111
    label "privy"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2112
    label "prodigal"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2113
    label "propitious"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2114
    label "prosperity"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2115
    label "purple"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2116
    label "purulent"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2117
    label "quake"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2118
    label "quickly"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2119
    label "reasonable"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2120
    label "receiver"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2121
    label "reducible"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2122
    label "register"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2123
    label "remembrance"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2124
    label "render"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2125
    label "resistance"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2126
    label "retinue"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2127
    label "rhetorick"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2128
    label "rider"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2129
    label "rind"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2130
    label "rival"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2131
    label "rug"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2132
    label "ruler"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2133
    label "rumour"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2134
    label "side"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2135
    label "sin"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2136
    label "sleep"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2137
    label "support"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2138
    label "swelling"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2139
    label "talkative"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2140
    label "teller"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2141
    label "temple"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2142
    label "tenacious"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2143
    label "tenacity"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2144
    label "tenement"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2145
    label "theatre"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2146
    label "thickness"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2147
    label "thinking"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2148
    label "thoughtless"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2149
    label "thumb"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2150
    label "tight"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2151
    label "tillage"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2152
    label "toll"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2153
    label "torch"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2154
    label "total"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2155
    label "trench"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2156
    label "tun"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2157
    label "unsettled"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2158
    label "unsuitable"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2159
    label "unusual"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2160
    label "unworthy"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2161
    label "usury"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2162
    label "valour"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2163
    label "vault"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2164
    label "venomous"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2165
    label "verbal"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2166
    label "vexatiously"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2167
    label "vibration"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2168
    label "viper"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2169
    label "vivid"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2170
    label "volume"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2171
    label "vote"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2172
    label "warning"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2173
    label "wash"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2174
    label "wedge"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2175
    label "wheedle"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2176
    label "winged"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2177
    label "wish"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2178
    label "wor"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2179
    label "wrought"
    kind "continuation_bias"
    weight 0.11
    evidence 6
    source "classic-lexicon"
  ]

  node [
    id 2180
    label "admixture"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2181
    label "admonition"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2182
    label "adverse"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2183
    label "although"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2184
    label "amazement"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2185
    label "amendment"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2186
    label "ample"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2187
    label "amusement"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2188
    label "analogy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2189
    label "angel"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2190
    label "angular"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2191
    label "annoy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2192
    label "antique"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2193
    label "ape"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2194
    label "appendage"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2195
    label "appointment"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2196
    label "argumental"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2197
    label "ark"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2198
    label "artery"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2199
    label "articulate"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2200
    label "artillery"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2201
    label "attribute"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2202
    label "audible"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2203
    label "audibly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2204
    label "august"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2205
    label "bait"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2206
    label "bane"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2207
    label "batter"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2208
    label "beard"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2209
    label "beau"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2210
    label "beneath"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2211
    label "benevolence"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2212
    label "betwixt"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2213
    label "bible"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2214
    label "blunder"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2215
    label "bolt"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2216
    label "brevity"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2217
    label "brewing"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2218
    label "brute"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2219
    label "builder"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2220
    label "burrow"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2221
    label "cabbage"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2222
    label "canal"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2223
    label "cane"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2224
    label "capricious"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2225
    label "catalogue"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2226
    label "cautiously"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2227
    label "cell"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2228
    label "censurer"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2229
    label "chap"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2230
    label "chaste"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2231
    label "cheese"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2232
    label "chess"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2233
    label "chirp"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2234
    label "chop"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2235
    label "cloak"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2236
    label "club"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2237
    label "clumsy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2238
    label "coach"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2239
    label "coagulation"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2240
    label "coast"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2241
    label "comedy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2242
    label "competition"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2243
    label "competitor"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2244
    label "concourse"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2245
    label "consciousness"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2246
    label "consecrate"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2247
    label "constancy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2248
    label "constitution"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2249
    label "contagious"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2250
    label "continuous"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2251
    label "convolution"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2252
    label "coop"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2253
    label "copiousness"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2254
    label "correlative"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2255
    label "corrosive"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2256
    label "corrupter"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2257
    label "corruptly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2258
    label "counsel"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2259
    label "counsellor"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2260
    label "cramp"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2261
    label "critick"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2262
    label "crocodile"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2263
    label "culture"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2264
    label "cunningly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2265
    label "dean"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2266
    label "debtor"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2267
    label "deceiver"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2268
    label "decent"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2269
    label "decisive"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2270
    label "decrease"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2271
    label "deliberate"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2272
    label "desirable"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2273
    label "dilatory"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2274
    label "dire"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2275
    label "disagreement"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2276
    label "discipline"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2277
    label "discus"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2278
    label "disorderly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2279
    label "disputable"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2280
    label "distillation"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2281
    label "divers"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2282
    label "dove"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2283
    label "drama"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2284
    label "drench"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2285
    label "duel"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2286
    label "dweller"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2287
    label "eater"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2288
    label "elephant"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2289
    label "elf"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2290
    label "emphasis"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2291
    label "encounter"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2292
    label "english"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2293
    label "enigma"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2294
    label "enmity"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2295
    label "enticement"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2296
    label "epitome"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2297
    label "esculent"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2298
    label "evening"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2299
    label "expedition"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2300
    label "explainer"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2301
    label "fabled"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2302
    label "facility"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2303
    label "fallow"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2304
    label "fart"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2305
    label "fatness"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2306
    label "faulty"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2307
    label "fender"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2308
    label "filler"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2309
    label "finely"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2310
    label "flake"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2311
    label "flout"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2312
    label "follower"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2313
    label "fondly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2314
    label "foolish"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2315
    label "footed"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2316
    label "formality"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2317
    label "fraternity"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2318
    label "frugal"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2319
    label "fruition"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2320
    label "furnace"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2321
    label "games"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2322
    label "gathering"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2323
    label "gentleman"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2324
    label "giver"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2325
    label "gloss"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2326
    label "glue"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2327
    label "goddess"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2328
    label "graving"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2329
    label "gray"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2330
    label "gust"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2331
    label "habitant"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2332
    label "harbinger"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2333
    label "haviour"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2334
    label "headlong"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2335
    label "hearted"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2336
    label "heedless"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2337
    label "helper"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2338
    label "heraldry"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2339
    label "horrid"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2340
    label "idol"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2341
    label "ignominy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2342
    label "illiberal"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2343
    label "impudently"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2344
    label "income"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2345
    label "incongruity"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2346
    label "inexorable"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2347
    label "integument"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2348
    label "intelligent"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2349
    label "interiour"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2350
    label "intimate"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2351
    label "intimation"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2352
    label "inventor"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2353
    label "invitation"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2354
    label "irony"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2355
    label "irreverence"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2356
    label "irreverent"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2357
    label "ivy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2358
    label "jerk"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2359
    label "kid"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2360
    label "labourer"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2361
    label "levy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2362
    label "lewdness"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2363
    label "lizard"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2364
    label "logick"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2365
    label "loop"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2366
    label "looseness"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2367
    label "lowness"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2368
    label "ludicrously"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2369
    label "madly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2370
    label "mahometan"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2371
    label "manager"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2372
    label "maturity"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2373
    label "mayor"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2374
    label "methodical"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2375
    label "mighty"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2376
    label "miry"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2377
    label "modest"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2378
    label "mound"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2379
    label "narrowly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2380
    label "needlework"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2381
    label "neutral"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2382
    label "nigh"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2383
    label "nitre"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2384
    label "nobly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2385
    label "noon"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2386
    label "notch"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2387
    label "onion"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2388
    label "ounce"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2389
    label "palsy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2390
    label "parish"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2391
    label "partition"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2392
    label "pawn"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2393
    label "peer"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2394
    label "pencil"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2395
    label "pending"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2396
    label "pension"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2397
    label "permission"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2398
    label "physician"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2399
    label "pier"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2400
    label "pond"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2401
    label "popery"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2402
    label "pouch"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2403
    label "pox"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2404
    label "precise"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2405
    label "prescience"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2406
    label "prevalent"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2407
    label "preventive"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2408
    label "prickle"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2409
    label "procedure"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2410
    label "promoter"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2411
    label "proverb"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2412
    label "provoking"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2413
    label "pungent"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2414
    label "quadruped"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2415
    label "quaver"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2416
    label "queen"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2417
    label "quire"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2418
    label "quiver"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2419
    label "rapacious"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2420
    label "rapidity"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2421
    label "rarely"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2422
    label "ravage"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2423
    label "rear"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2424
    label "recompense"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2425
    label "resort"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2426
    label "rhyme"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2427
    label "rick"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2428
    label "riddle"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2429
    label "riot"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2430
    label "rover"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2431
    label "rower"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2432
    label "rush"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2433
    label "sale"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2434
    label "sounding"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2435
    label "spirit"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2436
    label "spring"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2437
    label "straight"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2438
    label "strength"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2439
    label "sup"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2440
    label "superior"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2441
    label "swell"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2442
    label "tailed"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2443
    label "talker"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2444
    label "tardy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2445
    label "tea"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2446
    label "teat"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2447
    label "theory"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2448
    label "thinness"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2449
    label "tolerable"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2450
    label "tomb"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2451
    label "treatise"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2452
    label "trine"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2453
    label "trumpet"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2454
    label "tube"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2455
    label "tumid"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2456
    label "unrestrained"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2457
    label "untimely"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2458
    label "unwieldy"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2459
    label "vanity"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2460
    label "vary"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2461
    label "veal"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2462
    label "velocity"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2463
    label "vicar"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2464
    label "village"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2465
    label "villain"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2466
    label "vinegar"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2467
    label "violator"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2468
    label "voyage"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2469
    label "wal"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2470
    label "wantonly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2471
    label "wedlock"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2472
    label "wisdom"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2473
    label "witty"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2474
    label "wives"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2475
    label "wolf"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2476
    label "woolly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2477
    label "worship"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2478
    label "yearly"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2479
    label "yes"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2480
    label "youth"
    kind "continuation_bias"
    weight 0.1012
    evidence 5
    source "classic-lexicon"
  ]

  node [
    id 2481
    label "abstruse"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2482
    label "acutely"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2483
    label "admiration"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2484
    label "advantageous"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2485
    label "algebra"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2486
    label "alienation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2487
    label "aliment"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2488
    label "allotment"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2489
    label "allurement"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2490
    label "alphabet"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2491
    label "als"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2492
    label "altitude"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2493
    label "alum"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2494
    label "ambush"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2495
    label "analysis"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2496
    label "archer"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2497
    label "area"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2498
    label "arrangement"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2499
    label "athwart"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2500
    label "atom"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2501
    label "awkwardly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2502
    label "badger"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2503
    label "basket"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2504
    label "beech"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2505
    label "bidding"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2506
    label "blackness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2507
    label "blindly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2508
    label "bloom"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2509
    label "bodily"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2510
    label "bony"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2511
    label "boots"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2512
    label "bosom"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2513
    label "botch"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2514
    label "bower"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2515
    label "braid"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2516
    label "bravely"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2517
    label "bribe"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2518
    label "brief"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2519
    label "brisk"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2520
    label "brit"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2521
    label "bubble"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2522
    label "burlesque"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2523
    label "bustle"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2524
    label "butter"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2525
    label "calumny"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2526
    label "canopy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2527
    label "captious"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2528
    label "ceiling"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2529
    label "celebrity"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2530
    label "celerity"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2531
    label "celestial"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2532
    label "cellar"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2533
    label "censorious"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2534
    label "chalk"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2535
    label "champion"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2536
    label "chant"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2537
    label "chatter"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2538
    label "childhood"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2539
    label "chin"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2540
    label "chymistry"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2541
    label "cion"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2542
    label "citation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2543
    label "clasp"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2544
    label "clause"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2545
    label "closure"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2546
    label "coarseness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2547
    label "cogent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2548
    label "collection"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2549
    label "colony"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2550
    label "complex"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2551
    label "complexion"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2552
    label "compliant"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2553
    label "compulsion"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2554
    label "concurrent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2555
    label "conduit"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2556
    label "conquest"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2557
    label "consistent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2558
    label "constituent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2559
    label "consul"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2560
    label "contemptible"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2561
    label "continent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2562
    label "convoy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2563
    label "cook"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2564
    label "coolness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2565
    label "cottage"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2566
    label "cotton"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2567
    label "cough"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2568
    label "couple"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2569
    label "courtesy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2570
    label "coxcomb"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2571
    label "creation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2572
    label "criticism"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2573
    label "crookedness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2574
    label "cudgel"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2575
    label "cue"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2576
    label "curb"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2577
    label "curious"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2578
    label "cutter"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2579
    label "daily"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2580
    label "deadly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2581
    label "debauchery"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2582
    label "declination"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2583
    label "delicately"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2584
    label "delineation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2585
    label "demeanour"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2586
    label "density"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2587
    label "dependent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2588
    label "derivation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2589
    label "despair"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2590
    label "detriment"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2591
    label "dialogue"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2592
    label "digestion"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2593
    label "dish"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2594
    label "displeasure"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2595
    label "distribution"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2596
    label "disunion"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2597
    label "docility"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2598
    label "doctrine"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2599
    label "drinker"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2600
    label "drowsy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2601
    label "drunken"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2602
    label "earl"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2603
    label "earthy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2604
    label "ebb"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2605
    label "echo"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2606
    label "edness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2607
    label "elbow"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2608
    label "elder"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2609
    label "eloquence"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2610
    label "elves"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2611
    label "emission"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2612
    label "emphatically"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2613
    label "emptiness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2614
    label "encourager"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2615
    label "energy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2616
    label "evenly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2617
    label "exceedingly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2618
    label "exchequer"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2619
    label "excise"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2620
    label "excision"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2621
    label "exclusive"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2622
    label "exile"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2623
    label "expiation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2624
    label "expressive"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2625
    label "externally"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2626
    label "extortion"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2627
    label "faced"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2628
    label "fatal"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2629
    label "favourably"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2630
    label "fearless"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2631
    label "feathered"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2632
    label "feebleness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2633
    label "feebly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2634
    label "feli"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2635
    label "ferry"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2636
    label "figuratively"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2637
    label "filament"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2638
    label "flavour"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2639
    label "fleam"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2640
    label "fleece"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2641
    label "fleer"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2642
    label "fleshy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2643
    label "fluency"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2644
    label "fluent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2645
    label "fondling"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2646
    label "ford"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2647
    label "forehand"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2648
    label "forehead"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2649
    label "forerunner"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2650
    label "forethought"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2651
    label "forger"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2652
    label "forgery"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2653
    label "fork"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2654
    label "fortunate"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2655
    label "frail"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2656
    label "friar"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2657
    label "fuller"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2658
    label "gainer"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2659
    label "gale"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2660
    label "gallery"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2661
    label "galley"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2662
    label "garland"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2663
    label "gatherer"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2664
    label "girth"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2665
    label "glutton"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2666
    label "hart"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2667
    label "hazardous"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2668
    label "headland"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2669
    label "hearts"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2670
    label "heath"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2671
    label "heresy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2672
    label "hinge"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2673
    label "holiness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2674
    label "honestly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2675
    label "hunter"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2676
    label "hypocrisy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2677
    label "ignorantly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2678
    label "illustrious"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2679
    label "imitator"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2680
    label "immature"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2681
    label "immortal"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2682
    label "impatience"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2683
    label "impetuous"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2684
    label "incense"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2685
    label "indignity"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2686
    label "indubitable"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2687
    label "ingenuous"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2688
    label "inherent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2689
    label "inhuman"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2690
    label "initiate"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2691
    label "inordinately"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2692
    label "inscription"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2693
    label "insensible"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2694
    label "integrity"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2695
    label "intelligible"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2696
    label "interchange"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2697
    label "internally"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2698
    label "intestine"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2699
    label "intricate"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2700
    label "intrinsick"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2701
    label "inundation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2702
    label "inveterate"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2703
    label "invincible"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2704
    label "invisible"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2705
    label "involuntary"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2706
    label "island"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2707
    label "jeer"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2708
    label "jointly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2709
    label "jointure"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2710
    label "jolt"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2711
    label "jot"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2712
    label "juicy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2713
    label "kingly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2714
    label "lack"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2715
    label "laziness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2716
    label "lea"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2717
    label "license"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2718
    label "listed"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2719
    label "livery"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2720
    label "luckily"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2721
    label "luxuriously"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2722
    label "maiden"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2723
    label "martial"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2724
    label "mask"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2725
    label "meadow"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2726
    label "mediately"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2727
    label "mediator"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2728
    label "message"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2729
    label "midst"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2730
    label "mildness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2731
    label "minded"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2732
    label "mood"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2733
    label "mule"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2734
    label "musically"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2735
    label "mutually"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2736
    label "nauseousness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2737
    label "nearness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2738
    label "negro"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2739
    label "neigh"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2740
    label "neighbour"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2741
    label "nest"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2742
    label "niggardly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2743
    label "nobleman"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2744
    label "november"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2745
    label "oblivion"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2746
    label "oblong"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2747
    label "obnoxious"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2748
    label "ocean"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2749
    label "often"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2750
    label "onward"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2751
    label "orator"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2752
    label "orbit"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2753
    label "ordnance"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2754
    label "oval"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2755
    label "pail"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2756
    label "paleness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2757
    label "parchment"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2758
    label "partial"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2759
    label "participial"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2760
    label "passionate"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2761
    label "passive"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2762
    label "patch"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2763
    label "patient"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2764
    label "paw"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2765
    label "peak"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2766
    label "peal"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2767
    label "peep"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2768
    label "pellicle"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2769
    label "penny"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2770
    label "pepper"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2771
    label "perch"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2772
    label "perjury"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2773
    label "perspiration"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2774
    label "perversely"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2775
    label "pest"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2776
    label "petal"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2777
    label "petulantly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2778
    label "pilot"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2779
    label "plaything"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2780
    label "poisonous"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2781
    label "polish"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2782
    label "ported"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2783
    label "possibility"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2784
    label "potent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2785
    label "potential"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2786
    label "prelate"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2787
    label "preservative"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2788
    label "primarily"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2789
    label "primary"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2790
    label "probably"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2791
    label "prodigy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2792
    label "prone"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2793
    label "prosperous"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2794
    label "proudly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2795
    label "puberty"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2796
    label "puddle"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2797
    label "pustule"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2798
    label "quack"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2799
    label "quarry"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2800
    label "quell"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2801
    label "quicksilver"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2802
    label "quill"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2803
    label "rabbit"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2804
    label "ragged"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2805
    label "random"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2806
    label "rap"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2807
    label "rapid"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2808
    label "rarity"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2809
    label "rationally"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2810
    label "reaper"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2811
    label "receipt"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2812
    label "receptacle"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2813
    label "reciprocally"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2814
    label "reins"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2815
    label "relatively"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2816
    label "religiously"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2817
    label "relish"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2818
    label "remorse"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2819
    label "renovation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2820
    label "repayment"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2821
    label "republick"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2822
    label "requital"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2823
    label "reserved"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2824
    label "resolute"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2825
    label "respite"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2826
    label "retribution"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2827
    label "reverse"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2828
    label "revile"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2829
    label "revolt"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2830
    label "rhetorical"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2831
    label "ridiculous"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2832
    label "ritual"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2833
    label "roar"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2834
    label "robe"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2835
    label "romance"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2836
    label "rook"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2837
    label "rout"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2838
    label "runner"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2839
    label "rust"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2840
    label "salt"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2841
    label "scripture"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2842
    label "several"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2843
    label "sharply"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2844
    label "sharpness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2845
    label "shin"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2846
    label "shoe"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2847
    label "shore"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2848
    label "shortness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2849
    label "sight"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2850
    label "silent"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2851
    label "single"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2852
    label "sip"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2853
    label "skin"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2854
    label "sleepy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2855
    label "soil"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2856
    label "solemn"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2857
    label "speed"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2858
    label "splendour"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2859
    label "stout"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2860
    label "sudden"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2861
    label "sullen"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2862
    label "sunday"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2863
    label "supreme"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2864
    label "susceptible"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2865
    label "tartar"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2866
    label "tediously"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2867
    label "temperately"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2868
    label "testimony"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2869
    label "text"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2870
    label "thinly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2871
    label "thirty"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2872
    label "thorny"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2873
    label "thorough"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2874
    label "throng"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2875
    label "thump"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2876
    label "tome"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2877
    label "torpid"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2878
    label "totally"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2879
    label "translation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2880
    label "treasure"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2881
    label "turbid"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2882
    label "twitch"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2883
    label "tye"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2884
    label "tyrant"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2885
    label "unequalled"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2886
    label "unimportant"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2887
    label "unmoved"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2888
    label "unsteadiness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2889
    label "unto"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2890
    label "uproar"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2891
    label "utensil"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2892
    label "vacancy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2893
    label "vail"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2894
    label "vantage"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2895
    label "variegation"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2896
    label "veil"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2897
    label "vengeance"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2898
    label "vesture"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2899
    label "vileness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2900
    label "violet"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2901
    label "viscid"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2902
    label "volubly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2903
    label "waist"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2904
    label "waistcoat"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2905
    label "watching"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2906
    label "widow"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2907
    label "wilderness"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2908
    label "wildly"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2909
    label "willow"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2910
    label "windy"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2911
    label "winning"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2912
    label "wisely"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2913
    label "wry"
    kind "continuation_bias"
    weight 0.0909
    evidence 4
    source "classic-lexicon"
  ]

  node [
    id 2914
    label "abolition"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2915
    label "abominably"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2916
    label "abrupt"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2917
    label "academy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2918
    label "accent"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2919
    label "access"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2920
    label "accountable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2921
    label "acquittal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2922
    label "acrimonious"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2923
    label "active"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2924
    label "admittance"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2925
    label "adoption"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2926
    label "adulterate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2927
    label "adversely"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2928
    label "ahead"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2929
    label "alacrity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2930
    label "alike"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2931
    label "alimentary"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2932
    label "alkali"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2933
    label "alleviation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2934
    label "alley"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2935
    label "alliance"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2936
    label "allusive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2937
    label "almonds"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2938
    label "aloud"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2939
    label "altar"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2940
    label "alterable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2941
    label "amaze"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2942
    label "amiss"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2943
    label "antagonist"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2944
    label "anxiously"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2945
    label "applause"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2946
    label "arse"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2947
    label "ashes"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2948
    label "assembly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2949
    label "associate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2950
    label "astronomy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2951
    label "asylum"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2952
    label "attire"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2953
    label "audience"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2954
    label "augury"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2955
    label "autumn"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2956
    label "averse"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2957
    label "baboon"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2958
    label "baldness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2959
    label "balsam"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2960
    label "banquet"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2961
    label "barb"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2962
    label "barely"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2963
    label "beadle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2964
    label "beggar"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2965
    label "belch"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2966
    label "best"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2967
    label "bilberry"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2968
    label "bituminous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2969
    label "blameableness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2970
    label "bole"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2971
    label "boot"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2972
    label "botanist"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2973
    label "bracelet"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2974
    label "brawl"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2975
    label "breeder"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2976
    label "breeze"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2977
    label "brine"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2978
    label "broil"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2979
    label "broker"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2980
    label "broom"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2981
    label "brush"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2982
    label "buckler"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2983
    label "bug"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2984
    label "bulwark"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2985
    label "burned"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2986
    label "cab"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2987
    label "callous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2988
    label "camel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2989
    label "carving"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2990
    label "castle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2991
    label "caviller"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2992
    label "century"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2993
    label "ceremonial"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2994
    label "cessation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2995
    label "chapel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2996
    label "chargeable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2997
    label "chariot"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2998
    label "charitable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 2999
    label "charming"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3000
    label "chasm"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3001
    label "cheap"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3002
    label "chimney"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3003
    label "choir"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3004
    label "chorus"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3005
    label "chub"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3006
    label "churl"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3007
    label "cinque"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3008
    label "circularity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3009
    label "citadel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3010
    label "citizen"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3011
    label "clandestine"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3012
    label "clatter"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3013
    label "clemency"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3014
    label "client"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3015
    label "clink"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3016
    label "clod"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3017
    label "closeness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3018
    label "clutch"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3019
    label "cocker"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3020
    label "cog"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3021
    label "cogency"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3022
    label "coil"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3023
    label "coinage"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3024
    label "colonel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3025
    label "colt"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3026
    label "comma"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3027
    label "commonness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3028
    label "commons"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3029
    label "compact"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3030
    label "compassion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3031
    label "compendium"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3032
    label "competent"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3033
    label "complaisant"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3034
    label "complicate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3035
    label "component"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3036
    label "compress"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3037
    label "conceited"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3038
    label "concomitant"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3039
    label "concrete"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3040
    label "condense"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3041
    label "congress"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3042
    label "conjunct"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3043
    label "connubial"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3044
    label "consecution"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3045
    label "considerable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3046
    label "console"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3047
    label "consonant"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3048
    label "constraint"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3049
    label "consult"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3050
    label "consumption"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3051
    label "contemner"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3052
    label "contented"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3053
    label "contexture"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3054
    label "contortion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3055
    label "convention"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3056
    label "conversable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3057
    label "cony"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3058
    label "coolly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3059
    label "cordial"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3060
    label "corse"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3061
    label "costive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3062
    label "couch"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3063
    label "courier"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3064
    label "coverlet"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3065
    label "cowardice"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3066
    label "craw"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3067
    label "cream"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3068
    label "crew"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3069
    label "cuckold"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3070
    label "cud"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3071
    label "customarily"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3072
    label "cuticle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3073
    label "daintily"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3074
    label "daisy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3075
    label "dam"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3076
    label "dancer"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3077
    label "deacon"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3078
    label "declension"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3079
    label "dedicate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3080
    label "degeneracy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3081
    label "degradation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3082
    label "delegate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3083
    label "deliciously"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3084
    label "delve"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3085
    label "demon"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3086
    label "depravation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3087
    label "designing"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3088
    label "despicably"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3089
    label "determinate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3090
    label "detestable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3091
    label "device"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3092
    label "dewy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3093
    label "diffuse"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3094
    label "dirtiness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3095
    label "discoverable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3096
    label "disdain"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3097
    label "disingenuous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3098
    label "dismission"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3099
    label "dividend"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3100
    label "divisible"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3101
    label "divorce"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3102
    label "document"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3103
    label "dome"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3104
    label "dose"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3105
    label "dotage"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3106
    label "drapery"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3107
    label "drowsiness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3108
    label "drudge"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3109
    label "dryness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3110
    label "dusky"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3111
    label "easter"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3112
    label "edged"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3113
    label "edition"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3114
    label "eel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3115
    label "emotion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3116
    label "enclosure"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3117
    label "enjoyment"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3118
    label "enlargement"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3119
    label "entreaty"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3120
    label "equation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3121
    label "equator"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3122
    label "erroneous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3123
    label "eternally"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3124
    label "eternity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3125
    label "evasion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3126
    label "evergreen"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3127
    label "exact"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3128
    label "exactly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3129
    label "excessive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3130
    label "excusable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3131
    label "expounder"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3132
    label "expressly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3133
    label "extraneous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3134
    label "eyelid"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3135
    label "falcon"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3136
    label "fallacy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3137
    label "favourer"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3138
    label "feasible"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3139
    label "federate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3140
    label "fencer"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3141
    label "filter"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3142
    label "filthily"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3143
    label "filtration"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3144
    label "flatterer"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3145
    label "flatulent"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3146
    label "flaw"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3147
    label "flexion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3148
    label "flown"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3149
    label "foe"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3150
    label "foetus"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3151
    label "footing"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3152
    label "forecast"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3153
    label "foresight"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3154
    label "forlorn"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3155
    label "formally"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3156
    label "fortuitous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3157
    label "fossil"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3158
    label "fourteen"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3159
    label "frenzy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3160
    label "friable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3161
    label "friendship"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3162
    label "frozen"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3163
    label "fuel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3164
    label "fungus"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3165
    label "gabble"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3166
    label "gage"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3167
    label "gallows"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3168
    label "gaol"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3169
    label "garrison"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3170
    label "generative"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3171
    label "getting"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3172
    label "ghost"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3173
    label "gloomily"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3174
    label "gloominess"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3175
    label "glove"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3176
    label "gluttony"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3177
    label "godhead"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3178
    label "grammarian"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3179
    label "grinder"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3180
    label "grove"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3181
    label "grudge"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3182
    label "guidance"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3183
    label "guile"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3184
    label "gunner"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3185
    label "hackle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3186
    label "hairy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3187
    label "halter"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3188
    label "handsomeness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3189
    label "hardy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3190
    label "haven"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3191
    label "havock"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3192
    label "herald"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3193
    label "hideous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3194
    label "hireling"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3195
    label "hiss"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3196
    label "history"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3197
    label "hollowness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3198
    label "hoof"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3199
    label "hopeless"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3200
    label "hough"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3201
    label "howl"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3202
    label "humbly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3203
    label "hungry"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3204
    label "hyacinth"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3205
    label "icy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3206
    label "ides"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3207
    label "ilex"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3208
    label "illegal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3209
    label "immaculate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3210
    label "immoderate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3211
    label "immoveable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3212
    label "impartially"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3213
    label "impatient"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3214
    label "impeachment"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3215
    label "impersonal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3216
    label "implacable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3217
    label "implement"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3218
    label "imprudent"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3219
    label "inauspicious"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3220
    label "inborn"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3221
    label "incentive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3222
    label "incorporeal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3223
    label "incursion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3224
    label "indecency"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3225
    label "index"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3226
    label "ingenuity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3227
    label "initial"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3228
    label "injudicious"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3229
    label "inland"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3230
    label "innocently"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3231
    label "innumerable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3232
    label "inoculation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3233
    label "insidiously"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3234
    label "instability"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3235
    label "interception"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3236
    label "intermediate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3237
    label "intervenient"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3238
    label "intimacy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3239
    label "intolerable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3240
    label "intrepid"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3241
    label "inventive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3242
    label "invincibly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3243
    label "ironically"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3244
    label "irreligion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3245
    label "irreligious"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3246
    label "irremediable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3247
    label "jelly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3248
    label "journal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3249
    label "joyous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3250
    label "judicature"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3251
    label "juridical"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3252
    label "justness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3253
    label "keel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3254
    label "kidney"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3255
    label "killer"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3256
    label "kiln"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3257
    label "knighthood"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3258
    label "knotted"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3259
    label "lade"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3260
    label "lampoon"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3261
    label "languish"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3262
    label "lard"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3263
    label "lash"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3264
    label "lavish"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3265
    label "lawn"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3266
    label "layman"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3267
    label "leader"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3268
    label "leak"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3269
    label "leaved"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3270
    label "lecher"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3271
    label "legate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3272
    label "lettered"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3273
    label "lever"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3274
    label "ley"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3275
    label "lightness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3276
    label "lightning"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3277
    label "lisp"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3278
    label "lixivium"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3279
    label "loaf"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3280
    label "looker"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3281
    label "lotion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3282
    label "lucrative"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3283
    label "luminary"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3284
    label "lust"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3285
    label "magician"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3286
    label "magick"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3287
    label "mainmast"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3288
    label "major"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3289
    label "mallet"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3290
    label "mantle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3291
    label "marcasite"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3292
    label "mariner"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3293
    label "marrow"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3294
    label "mason"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3295
    label "mechanicks"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3296
    label "mechanism"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3297
    label "medal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3298
    label "meek"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3299
    label "melioration"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3300
    label "melodious"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3301
    label "mercenary"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3302
    label "merchandise"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3303
    label "mercury"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3304
    label "mess"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3305
    label "milky"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3306
    label "minutely"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3307
    label "miraculous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3308
    label "mission"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3309
    label "misty"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3310
    label "mocker"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3311
    label "mockery"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3312
    label "mocking"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3313
    label "modesty"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3314
    label "moor"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3315
    label "morn"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3316
    label "motionless"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3317
    label "moulding"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3318
    label "mover"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3319
    label "musculous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3320
    label "mute"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3321
    label "nastiness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3322
    label "nativity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3323
    label "navigation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3324
    label "nay"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3325
    label "neglect"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3326
    label "negotiation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3327
    label "ninety"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3328
    label "obscenely"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3329
    label "observable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3330
    label "offensive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3331
    label "oft"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3332
    label "oiliness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3333
    label "ombre"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3334
    label "omened"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3335
    label "opportune"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3336
    label "optick"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3337
    label "opticks"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3338
    label "orally"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3339
    label "oration"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3340
    label "orbicular"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3341
    label "ordinate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3342
    label "outline"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3343
    label "outwardly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3344
    label "paragraph"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3345
    label "parochial"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3346
    label "paste"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3347
    label "pasture"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3348
    label "patent"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3349
    label "pathless"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3350
    label "paunch"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3351
    label "peaceable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3352
    label "pediment"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3353
    label "peevishness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3354
    label "penance"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3355
    label "penitent"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3356
    label "pensive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3357
    label "perceptibly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3358
    label "perpetuity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3359
    label "persuasive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3360
    label "pertinently"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3361
    label "phantom"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3362
    label "physically"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3363
    label "pill"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3364
    label "plausible"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3365
    label "pleader"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3366
    label "pleasantly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3367
    label "pleasantness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3368
    label "plebeian"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3369
    label "plumpness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3370
    label "plunge"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3371
    label "poetically"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3372
    label "polite"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3373
    label "pool"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3374
    label "poorly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3375
    label "popularly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3376
    label "preacher"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3377
    label "preceptive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3378
    label "precipitate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3379
    label "preparatory"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3380
    label "prime"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3381
    label "principally"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3382
    label "prior"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3383
    label "prisoner"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3384
    label "procurer"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3385
    label "prodigally"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3386
    label "production"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3387
    label "progressive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3388
    label "promotion"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3389
    label "proposal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3390
    label "proprietor"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3391
    label "provident"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3392
    label "proximity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3393
    label "prudently"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3394
    label "punk"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3395
    label "purely"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3396
    label "puritan"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3397
    label "putrid"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3398
    label "quietness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3399
    label "rabbet"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3400
    label "racy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3401
    label "radically"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3402
    label "rake"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3403
    label "rambler"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3404
    label "rapidly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3405
    label "rapier"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3406
    label "rapine"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3407
    label "rapture"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3408
    label "rasp"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3409
    label "raze"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3410
    label "reasonableness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3411
    label "rebel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3412
    label "recrement"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3413
    label "recruit"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3414
    label "reliance"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3415
    label "remotely"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3416
    label "repository"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3417
    label "resentment"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3418
    label "resignation"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3419
    label "resinous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3420
    label "retail"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3421
    label "rheum"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3422
    label "rhomb"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3423
    label "rigidly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3424
    label "rigorously"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3425
    label "rill"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3426
    label "riotous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3427
    label "rote"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3428
    label "ruby"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3429
    label "rye"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3430
    label "sal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3431
    label "savage"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3432
    label "school"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3433
    label "scorn"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3434
    label "seven"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3435
    label "severe"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3436
    label "shake"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3437
    label "shot"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3438
    label "sick"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3439
    label "size"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3440
    label "skill"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3441
    label "slavery"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3442
    label "slender"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3443
    label "slimy"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3444
    label "soldier"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3445
    label "soon"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3446
    label "southern"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3447
    label "square"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3448
    label "stick"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3449
    label "stoutly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3450
    label "suitably"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3451
    label "supposition"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3452
    label "susceptive"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3453
    label "tabour"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3454
    label "tackle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3455
    label "talon"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3456
    label "tangle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3457
    label "taper"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3458
    label "tart"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3459
    label "temperature"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3460
    label "tenuity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3461
    label "thereof"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3462
    label "thicket"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3463
    label "thirsty"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3464
    label "throughout"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3465
    label "thunderbolt"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3466
    label "thursday"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3467
    label "tipple"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3468
    label "tiresome"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3469
    label "toad"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3470
    label "torpor"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3471
    label "tract"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3472
    label "triple"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3473
    label "triumphant"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3474
    label "trope"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3475
    label "turbot"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3476
    label "turd"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3477
    label "ultimate"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3478
    label "unarmed"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3479
    label "unbodied"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3480
    label "unbound"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3481
    label "uncalled"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3482
    label "unconcerned"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3483
    label "uncouth"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3484
    label "underneath"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3485
    label "unequal"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3486
    label "uninhabited"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3487
    label "unlikely"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3488
    label "unmusical"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3489
    label "unripeness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3490
    label "unsolid"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3491
    label "unsteady"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3492
    label "unwillingly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3493
    label "vagrant"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3494
    label "vale"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3495
    label "valve"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3496
    label "variable"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3497
    label "variance"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3498
    label "vegetative"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3499
    label "ventricle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3500
    label "verity"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3501
    label "version"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3502
    label "vigil"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3503
    label "vigilantly"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3504
    label "villous"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3505
    label "vindicator"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3506
    label "wane"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3507
    label "weasel"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3508
    label "welcome"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3509
    label "whey"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3510
    label "whig"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3511
    label "whine"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3512
    label "whisper"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3513
    label "whiteness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3514
    label "wicker"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3515
    label "windiness"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3516
    label "windpipe"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3517
    label "wooer"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3518
    label "workmanship"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3519
    label "wrangle"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3520
    label "yoke"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3521
    label "zealously"
    kind "continuation_bias"
    weight 0.0783
    evidence 3
    source "classic-lexicon"
  ]

  node [
    id 3522
    label "abortion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3523
    label "abscess"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3524
    label "absurdly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3525
    label "accursed"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3526
    label "accusable"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3527
    label "acre"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3528
    label "addle"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3529
    label "adieu"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3530
    label "adjustment"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3531
    label "adult"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3532
    label "adversary"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3533
    label "advised"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3534
    label "aga"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3535
    label "agen"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3536
    label "aggregate"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3537
    label "aghast"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3538
    label "alert"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3539
    label "allay"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3540
    label "allegiance"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3541
    label "allusion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3542
    label "aloes"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3543
    label "amazing"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3544
    label "ambitious"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3545
    label "amble"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3546
    label "amorous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3547
    label "amply"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3548
    label "anil"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3549
    label "animation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3550
    label "ankle"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3551
    label "annoyance"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3552
    label "answerable"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3553
    label "antick"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3554
    label "antler"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3555
    label "aper"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3556
    label "apiece"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3557
    label "apposition"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3558
    label "appulse"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3559
    label "arbitrator"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3560
    label "archangel"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3561
    label "archetype"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3562
    label "arid"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3563
    label "aries"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3564
    label "armpit"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3565
    label "array"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3566
    label "arsenick"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3567
    label "aslope"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3568
    label "assistance"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3569
    label "assurance"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3570
    label "astray"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3571
    label "atheism"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3572
    label "athirst"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3573
    label "ative"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3574
    label "atmosphere"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3575
    label "attainder"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3576
    label "attorney"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3577
    label "augur"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3578
    label "austere"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3579
    label "authentick"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3580
    label "avenue"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3581
    label "avouch"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3582
    label "avowedly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3583
    label "await"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3584
    label "axe"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3585
    label "axiom"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3586
    label "babe"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3587
    label "bachelor"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3588
    label "backbone"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3589
    label "bail"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3590
    label "baker"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3591
    label "balk"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3592
    label "bandy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3593
    label "banter"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3594
    label "barbarism"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3595
    label "barber"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3596
    label "barley"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3597
    label "barn"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3598
    label "baron"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3599
    label "baronet"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3600
    label "barrier"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3601
    label "basely"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3602
    label "bass"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3603
    label "bastard"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3604
    label "bawdy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3605
    label "beach"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3606
    label "bearded"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3607
    label "beater"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3608
    label "beef"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3609
    label "beholding"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3610
    label "besom"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3611
    label "bias"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3612
    label "birch"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3613
    label "bitumen"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3614
    label "blamer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3615
    label "bland"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3616
    label "bleak"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3617
    label "blindness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3618
    label "blusterer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3619
    label "boisterous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3620
    label "bondsman"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3621
    label "botcher"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3622
    label "bounty"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3623
    label "bowler"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3624
    label "bracket"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3625
    label "braggart"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3626
    label "bravado"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3627
    label "bray"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3628
    label "breaker"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3629
    label "bride"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3630
    label "brier"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3631
    label "brimstone"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3632
    label "brinded"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3633
    label "briskness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3634
    label "broth"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3635
    label "bruit"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3636
    label "brutally"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3637
    label "buckle"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3638
    label "bugle"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3639
    label "bush"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3640
    label "busily"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3641
    label "cackle"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3642
    label "caldron"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3643
    label "calx"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3644
    label "cannibal"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3645
    label "canvass"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3646
    label "capability"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3647
    label "cape"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3648
    label "captive"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3649
    label "cardinal"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3650
    label "caress"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3651
    label "carminative"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3652
    label "carneous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3653
    label "carrier"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3654
    label "cascade"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3655
    label "casting"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3656
    label "catcher"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3657
    label "caustick"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3658
    label "cension"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3659
    label "chaise"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3660
    label "chalky"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3661
    label "char"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3662
    label "charmingly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3663
    label "checker"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3664
    label "chick"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3665
    label "childish"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3666
    label "chilness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3667
    label "chine"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3668
    label "chocolate"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3669
    label "choke"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3670
    label "churlish"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3671
    label "circulation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3672
    label "citer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3673
    label "clammy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3674
    label "cleanliness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3675
    label "cleanly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3676
    label "clinch"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3677
    label "cloister"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3678
    label "clot"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3679
    label "clove"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3680
    label "cockle"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3681
    label "code"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3682
    label "cogitation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3683
    label "coherent"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3684
    label "coldly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3685
    label "colon"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3686
    label "combed"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3687
    label "comer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3688
    label "comick"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3689
    label "commercial"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3690
    label "commitment"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3691
    label "commonalty"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3692
    label "compages"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3693
    label "comport"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3694
    label "compulsive"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3695
    label "compulsory"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3696
    label "concisely"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3697
    label "conditional"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3698
    label "conduct"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3699
    label "congruous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3700
    label "conjecture"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3701
    label "conjunction"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3702
    label "conjuration"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3703
    label "conjurer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3704
    label "conscious"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3705
    label "consequent"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3706
    label "conspirator"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3707
    label "consular"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3708
    label "consumptive"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3709
    label "contagion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3710
    label "contaminate"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3711
    label "contiguous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3712
    label "contingent"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3713
    label "contrarily"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3714
    label "control"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3715
    label "contumacy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3716
    label "contumely"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3717
    label "cookery"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3718
    label "cooper"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3719
    label "cop"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3720
    label "copier"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3721
    label "copulation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3722
    label "cornice"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3723
    label "correct"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3724
    label "corrosion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3725
    label "corrugation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3726
    label "corruptness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3727
    label "cost"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3728
    label "countable"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3729
    label "couplet"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3730
    label "courteous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3731
    label "courtship"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3732
    label "cousin"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3733
    label "covetously"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3734
    label "crabbed"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3735
    label "cranes"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3736
    label "creditor"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3737
    label "credulity"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3738
    label "credulous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3739
    label "creed"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3740
    label "creek"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3741
    label "crier"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3742
    label "criminally"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3743
    label "crimson"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3744
    label "cringe"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3745
    label "critically"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3746
    label "cruise"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3747
    label "crust"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3748
    label "cumber"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3749
    label "cumbersome"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3750
    label "curative"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3751
    label "curmudgeon"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3752
    label "curvated"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3753
    label "curvet"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3754
    label "cushion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3755
    label "customary"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3756
    label "cutaneous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3757
    label "cylinder"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3758
    label "cynosure"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3759
    label "dainty"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3760
    label "dairy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3761
    label "damnation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3762
    label "darling"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3763
    label "dash"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3764
    label "delivery"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3765
    label "demean"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3766
    label "desertion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3767
    label "destiny"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3768
    label "devise"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3769
    label "diagram"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3770
    label "diamond"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3771
    label "diaphanous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3772
    label "dictate"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3773
    label "digger"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3774
    label "dimly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3775
    label "dinner"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3776
    label "dirtily"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3777
    label "discernible"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3778
    label "discernment"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3779
    label "disciple"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3780
    label "discount"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3781
    label "discoverer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3782
    label "discredit"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3783
    label "discussion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3784
    label "dismay"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3785
    label "dispersion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3786
    label "disposal"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3787
    label "disputation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3788
    label "dissidence"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3789
    label "distrust"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3790
    label "disuse"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3791
    label "diverse"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3792
    label "divulger"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3793
    label "dizzy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3794
    label "dogstar"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3795
    label "doit"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3796
    label "doltish"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3797
    label "dominant"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3798
    label "donation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3799
    label "dotal"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3800
    label "doubly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3801
    label "downy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3802
    label "dragon"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3803
    label "dreamer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3804
    label "dredge"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3805
    label "dressing"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3806
    label "driveller"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3807
    label "driver"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3808
    label "droll"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3809
    label "dropsical"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3810
    label "drossy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3811
    label "dual"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3812
    label "dubiously"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3813
    label "dunce"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3814
    label "dutchy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3815
    label "earnestly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3816
    label "earthly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3817
    label "eastern"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3818
    label "eatable"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3819
    label "ebriety"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3820
    label "ebullition"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3821
    label "edging"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3822
    label "edible"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3823
    label "eft"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3824
    label "elders"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3825
    label "elect"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3826
    label "eleven"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3827
    label "eleventh"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3828
    label "elo"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3829
    label "embolus"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3830
    label "emendation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3831
    label "emmet"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3832
    label "enchanter"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3833
    label "encumbrance"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3834
    label "enemv"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3835
    label "enterprise"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3836
    label "entirely"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3837
    label "equipoise"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3838
    label "era"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3839
    label "essence"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3840
    label "estimation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3841
    label "evaporation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3842
    label "ewe"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3843
    label "expanse"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3844
    label "expansion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3845
    label "expert"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3846
    label "expiatory"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3847
    label "explanatory"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3848
    label "export"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3849
    label "exposure"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3850
    label "exterior"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3851
    label "extract"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3852
    label "eyed"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3853
    label "fabulous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3854
    label "fallacious"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3855
    label "fashion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3856
    label "fatuus"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3857
    label "fawner"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3858
    label "ferocious"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3859
    label "fervour"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3860
    label "festival"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3861
    label "fetched"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3862
    label "fetid"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3863
    label "fighter"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3864
    label "filiation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3865
    label "filthiness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3866
    label "finer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3867
    label "finical"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3868
    label "finite"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3869
    label "fistula"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3870
    label "fitter"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3871
    label "flagration"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3872
    label "flam"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3873
    label "flash"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3874
    label "flatness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3875
    label "flea"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3876
    label "fleshly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3877
    label "flew"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3878
    label "florid"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3879
    label "flounce"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3880
    label "flounder"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3881
    label "flowery"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3882
    label "flute"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3883
    label "foal"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3884
    label "fodder"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3885
    label "foible"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3886
    label "folio"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3887
    label "foreigner"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3888
    label "forked"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3889
    label "formidable"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3890
    label "forwarder"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3891
    label "founder"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3892
    label "fowler"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3893
    label "fragile"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3894
    label "frangible"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3895
    label "frankly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3896
    label "freshly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3897
    label "freshness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3898
    label "frigid"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3899
    label "frigidity"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3900
    label "frugally"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3901
    label "fruitless"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3902
    label "fundamental"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3903
    label "fungous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3904
    label "funnel"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3905
    label "furze"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3906
    label "fusible"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3907
    label "gallantry"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3908
    label "garret"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3909
    label "gaudy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3910
    label "gaze"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3911
    label "gelly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3912
    label "genealogy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3913
    label "gentility"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3914
    label "genus"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3915
    label "gesture"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3916
    label "gilding"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3917
    label "gill"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3918
    label "ginger"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3919
    label "gingle"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3920
    label "gladiator"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3921
    label "gladly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3922
    label "glare"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3923
    label "gleaning"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3924
    label "globule"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3925
    label "gorge"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3926
    label "gospel"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3927
    label "gourd"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3928
    label "governour"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3929
    label "graced"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3930
    label "gravely"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3931
    label "graver"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3932
    label "greasiness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3933
    label "greasy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3934
    label "greedily"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3935
    label "greediness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3936
    label "greenish"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3937
    label "grievance"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3938
    label "grievous"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3939
    label "groin"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3940
    label "grumbler"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3941
    label "grunt"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3942
    label "guest"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3943
    label "guise"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3944
    label "gulf"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3945
    label "gummy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3946
    label "gutter"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3947
    label "handgun"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3948
    label "handsomely"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3949
    label "haranguer"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3950
    label "hardly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3951
    label "harpoon"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3952
    label "harrow"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3953
    label "harshness"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3954
    label "hazel"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3955
    label "headdress"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3956
    label "heartily"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3957
    label "heiress"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3958
    label "helve"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3959
    label "hemisphere"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3960
    label "hemlock"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3961
    label "hence"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3962
    label "herpes"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3963
    label "hers"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3964
    label "hierarchy"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3965
    label "hillock"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3966
    label "hilly"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3967
    label "hitherto"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3968
    label "hoard"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3969
    label "hoary"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3970
    label "holder"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3971
    label "honorary"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3972
    label "honourable"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3973
    label "horizontal"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3974
    label "horned"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3975
    label "horoscope"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3976
    label "horseman"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3977
    label "host"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3978
    label "huddle"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3979
    label "humility"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3980
    label "hundredth"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3981
    label "husbandry"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3982
    label "ideal"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3983
    label "idolatry"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3984
    label "ignoble"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3985
    label "ignorance"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3986
    label "illusion"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3987
    label "imagery"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3988
    label "immensely"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3989
    label "impeach"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3990
    label "impellent"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3991
    label "impertinent"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3992
    label "imprecation"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3993
    label "impression"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3994
    label "improver"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3995
    label "imprudence"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3996
    label "imputable"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3997
    label "inadequate"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3998
    label "inanity"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 3999
    label "incendiary"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]

  node [
    id 4000
    label "inclemency"
    kind "continuation_bias"
    weight 0.0621
    evidence 2
    source "classic-lexicon"
  ]
]
