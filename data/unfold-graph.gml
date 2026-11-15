graph [
  directed 0
  comment "G_runtime = Q_3 □ C_6 — product of the semantic hypercube and the K'UHUL phase cycle.
|V| = 48  (8 semantic addresses × 6 phases)
deg(v) = 5  (3 semantic + 2 phase neighbors at every vertex)
Semantic edge  (b,θ) ↔ (b⊕eᵢ,θ)  : d_H=1 bit flip, weight=1.0
Phase edge     (b,θ) ↔ (b,θ±1)   : C6 step,        weight=0.5
Vertex id = b*6 + theta_idx  where b = b0 + 2*b1 + 4*b2
  b0: analysis(0) / generation(1)
  b1: active(0)   / memory-grounded(1)
  b2: object(0)   / meta-orchestration(1)
  theta_idx: 0=Pop 1=Wo 2=Yax 3=Sek 4=Chen 5=Xul
Semantic addresses (Q3):
  000→REASON-µ  001→CREATE-µ  010→INFER-µ   011→ELIZA
  100→TOOL-µ    101→ORCH-µ    110→MEM-µ     111→Coordinator
Reference: Q_3 = K_2^□3; G_runtime = Q_3 □ C_6; legal atomic transition ↔ d_H=1"

  (* ───────────────────────────────────────────────────────── *)
  (* VERTICES  id = b*6 + theta                                *)
  (* ───────────────────────────────────────────────────────── *)

  (* REASON-µ (000) × C_6 *)
  node [ id  0  label "REASON-µ:Pop"   micronaut "REASON-µ"   b0 0 b1 0 b2 0 theta 0 phase "Pop"   ]
  node [ id  1  label "REASON-µ:Wo"    micronaut "REASON-µ"   b0 0 b1 0 b2 0 theta 1 phase "Wo"    ]
  node [ id  2  label "REASON-µ:Yax"   micronaut "REASON-µ"   b0 0 b1 0 b2 0 theta 2 phase "Yax"   ]
  node [ id  3  label "REASON-µ:Sek"   micronaut "REASON-µ"   b0 0 b1 0 b2 0 theta 3 phase "Sek"   ]
  node [ id  4  label "REASON-µ:Chen"  micronaut "REASON-µ"   b0 0 b1 0 b2 0 theta 4 phase "Chen"  ]
  node [ id  5  label "REASON-µ:Xul"   micronaut "REASON-µ"   b0 0 b1 0 b2 0 theta 5 phase "Xul"   ]

  (* CREATE-µ (001) × C_6 *)
  node [ id  6  label "CREATE-µ:Pop"   micronaut "CREATE-µ"   b0 1 b1 0 b2 0 theta 0 phase "Pop"   ]
  node [ id  7  label "CREATE-µ:Wo"    micronaut "CREATE-µ"   b0 1 b1 0 b2 0 theta 1 phase "Wo"    ]
  node [ id  8  label "CREATE-µ:Yax"   micronaut "CREATE-µ"   b0 1 b1 0 b2 0 theta 2 phase "Yax"   ]
  node [ id  9  label "CREATE-µ:Sek"   micronaut "CREATE-µ"   b0 1 b1 0 b2 0 theta 3 phase "Sek"   ]
  node [ id 10  label "CREATE-µ:Chen"  micronaut "CREATE-µ"   b0 1 b1 0 b2 0 theta 4 phase "Chen"  ]
  node [ id 11  label "CREATE-µ:Xul"   micronaut "CREATE-µ"   b0 1 b1 0 b2 0 theta 5 phase "Xul"   ]

  (* INFER-µ (010) × C_6 *)
  node [ id 12  label "INFER-µ:Pop"    micronaut "INFER-µ"    b0 0 b1 1 b2 0 theta 0 phase "Pop"   ]
  node [ id 13  label "INFER-µ:Wo"     micronaut "INFER-µ"    b0 0 b1 1 b2 0 theta 1 phase "Wo"    ]
  node [ id 14  label "INFER-µ:Yax"    micronaut "INFER-µ"    b0 0 b1 1 b2 0 theta 2 phase "Yax"   ]
  node [ id 15  label "INFER-µ:Sek"    micronaut "INFER-µ"    b0 0 b1 1 b2 0 theta 3 phase "Sek"   ]
  node [ id 16  label "INFER-µ:Chen"   micronaut "INFER-µ"    b0 0 b1 1 b2 0 theta 4 phase "Chen"  ]
  node [ id 17  label "INFER-µ:Xul"    micronaut "INFER-µ"    b0 0 b1 1 b2 0 theta 5 phase "Xul"   ]

  (* ELIZA (011) × C_6 *)
  node [ id 18  label "ELIZA:Pop"      micronaut "ELIZA"      b0 1 b1 1 b2 0 theta 0 phase "Pop"   ]
  node [ id 19  label "ELIZA:Wo"       micronaut "ELIZA"      b0 1 b1 1 b2 0 theta 1 phase "Wo"    ]
  node [ id 20  label "ELIZA:Yax"      micronaut "ELIZA"      b0 1 b1 1 b2 0 theta 2 phase "Yax"   ]
  node [ id 21  label "ELIZA:Sek"      micronaut "ELIZA"      b0 1 b1 1 b2 0 theta 3 phase "Sek"   ]
  node [ id 22  label "ELIZA:Chen"     micronaut "ELIZA"      b0 1 b1 1 b2 0 theta 4 phase "Chen"  ]
  node [ id 23  label "ELIZA:Xul"      micronaut "ELIZA"      b0 1 b1 1 b2 0 theta 5 phase "Xul"   ]

  (* TOOL-µ (100) × C_6 *)
  node [ id 24  label "TOOL-µ:Pop"     micronaut "TOOL-µ"     b0 0 b1 0 b2 1 theta 0 phase "Pop"   ]
  node [ id 25  label "TOOL-µ:Wo"      micronaut "TOOL-µ"     b0 0 b1 0 b2 1 theta 1 phase "Wo"    ]
  node [ id 26  label "TOOL-µ:Yax"     micronaut "TOOL-µ"     b0 0 b1 0 b2 1 theta 2 phase "Yax"   ]
  node [ id 27  label "TOOL-µ:Sek"     micronaut "TOOL-µ"     b0 0 b1 0 b2 1 theta 3 phase "Sek"   ]
  node [ id 28  label "TOOL-µ:Chen"    micronaut "TOOL-µ"     b0 0 b1 0 b2 1 theta 4 phase "Chen"  ]
  node [ id 29  label "TOOL-µ:Xul"     micronaut "TOOL-µ"     b0 0 b1 0 b2 1 theta 5 phase "Xul"   ]

  (* ORCH-µ (101) × C_6 *)
  node [ id 30  label "ORCH-µ:Pop"     micronaut "ORCH-µ"     b0 1 b1 0 b2 1 theta 0 phase "Pop"   ]
  node [ id 31  label "ORCH-µ:Wo"      micronaut "ORCH-µ"     b0 1 b1 0 b2 1 theta 1 phase "Wo"    ]
  node [ id 32  label "ORCH-µ:Yax"     micronaut "ORCH-µ"     b0 1 b1 0 b2 1 theta 2 phase "Yax"   ]
  node [ id 33  label "ORCH-µ:Sek"     micronaut "ORCH-µ"     b0 1 b1 0 b2 1 theta 3 phase "Sek"   ]
  node [ id 34  label "ORCH-µ:Chen"    micronaut "ORCH-µ"     b0 1 b1 0 b2 1 theta 4 phase "Chen"  ]
  node [ id 35  label "ORCH-µ:Xul"     micronaut "ORCH-µ"     b0 1 b1 0 b2 1 theta 5 phase "Xul"   ]

  (* MEM-µ (110) × C_6 *)
  node [ id 36  label "MEM-µ:Pop"      micronaut "MEM-µ"      b0 0 b1 1 b2 1 theta 0 phase "Pop"   ]
  node [ id 37  label "MEM-µ:Wo"       micronaut "MEM-µ"      b0 0 b1 1 b2 1 theta 1 phase "Wo"    ]
  node [ id 38  label "MEM-µ:Yax"      micronaut "MEM-µ"      b0 0 b1 1 b2 1 theta 2 phase "Yax"   ]
  node [ id 39  label "MEM-µ:Sek"      micronaut "MEM-µ"      b0 0 b1 1 b2 1 theta 3 phase "Sek"   ]
  node [ id 40  label "MEM-µ:Chen"     micronaut "MEM-µ"      b0 0 b1 1 b2 1 theta 4 phase "Chen"  ]
  node [ id 41  label "MEM-µ:Xul"      micronaut "MEM-µ"      b0 0 b1 1 b2 1 theta 5 phase "Xul"   ]

  (* Coordinator (111) × C_6 *)
  node [ id 42  label "Coordinator:Pop"  micronaut "Coordinator" b0 1 b1 1 b2 1 theta 0 phase "Pop"   ]
  node [ id 43  label "Coordinator:Wo"   micronaut "Coordinator" b0 1 b1 1 b2 1 theta 1 phase "Wo"    ]
  node [ id 44  label "Coordinator:Yax"  micronaut "Coordinator" b0 1 b1 1 b2 1 theta 2 phase "Yax"   ]
  node [ id 45  label "Coordinator:Sek"  micronaut "Coordinator" b0 1 b1 1 b2 1 theta 3 phase "Sek"   ]
  node [ id 46  label "Coordinator:Chen" micronaut "Coordinator" b0 1 b1 1 b2 1 theta 4 phase "Chen"  ]
  node [ id 47  label "Coordinator:Xul"  micronaut "Coordinator" b0 1 b1 1 b2 1 theta 5 phase "Xul"   ]

  (* ───────────────────────────────────────────────────────── *)
  (* SEMANTIC EDGES  (b,θ) ↔ (b⊕eᵢ,θ)  weight=1.0  verb="@semantic_step" *)
  (* b0 flip: pairs (0↔1,2↔3,4↔5,6↔7) × 6 phases = 24 edges              *)
  (* ───────────────────────────────────────────────────────── *)
  edge [ source  0 target  6 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source  1 target  7 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source  2 target  8 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source  3 target  9 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source  4 target 10 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source  5 target 11 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 12 target 18 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 13 target 19 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 14 target 20 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 15 target 21 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 16 target 22 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 17 target 23 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 24 target 30 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 25 target 31 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 26 target 32 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 27 target 33 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 28 target 34 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 29 target 35 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 36 target 42 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 37 target 43 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 38 target 44 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 39 target 45 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 40 target 46 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]
  edge [ source 41 target 47 label "b0_flip" weight 1.0 verb "@semantic_step" bit "b0" ]

  (* b1 flip: pairs (0↔2,1↔3,4↔6,5↔7) × 6 phases = 24 edges *)
  edge [ source  0 target 12 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  1 target 13 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  2 target 14 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  3 target 15 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  4 target 16 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  5 target 17 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  6 target 18 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  7 target 19 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  8 target 20 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source  9 target 21 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 10 target 22 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 11 target 23 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 24 target 36 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 25 target 37 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 26 target 38 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 27 target 39 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 28 target 40 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 29 target 41 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 30 target 42 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 31 target 43 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 32 target 44 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 33 target 45 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 34 target 46 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]
  edge [ source 35 target 47 label "b1_flip" weight 1.0 verb "@semantic_step" bit "b1" ]

  (* b2 flip: pairs (0↔4,1↔5,2↔6,3↔7) × 6 phases = 24 edges *)
  edge [ source  0 target 24 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  1 target 25 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  2 target 26 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  3 target 27 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  4 target 28 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  5 target 29 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  6 target 30 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  7 target 31 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  8 target 32 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source  9 target 33 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 10 target 34 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 11 target 35 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 12 target 36 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 13 target 37 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 14 target 38 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 15 target 39 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 16 target 40 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 17 target 41 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 18 target 42 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 19 target 43 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 20 target 44 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 21 target 45 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 22 target 46 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]
  edge [ source 23 target 47 label "b2_flip" weight 1.0 verb "@semantic_step" bit "b2" ]

  (* ───────────────────────────────────────────────────────── *)
  (* PHASE EDGES  (b,θ) ↔ (b,θ+1 mod 6)  weight=0.5  verb="@phase_step" *)
  (* arc_weight(θ,θ+1) = cos(π/3) = 0.5 for all adjacent C6 steps       *)
  (* 8 semantic addresses × 6 cycle edges = 48 edges                      *)
  (* ───────────────────────────────────────────────────────── *)

  (* REASON-µ cycle *)
  edge [ source  0 target  1 label "Pop→Wo"   weight 0.5 verb "@phase_step" ]
  edge [ source  1 target  2 label "Wo→Yax"   weight 0.5 verb "@phase_step" ]
  edge [ source  2 target  3 label "Yax→Sek"  weight 0.5 verb "@phase_step" ]
  edge [ source  3 target  4 label "Sek→Chen" weight 0.5 verb "@phase_step" ]
  edge [ source  4 target  5 label "Chen→Xul" weight 0.5 verb "@phase_step" ]
  edge [ source  5 target  0 label "Xul→Pop"  weight 0.5 verb "@phase_step" ]

  (* CREATE-µ cycle *)
  edge [ source  6 target  7 label "Pop→Wo"   weight 0.5 verb "@phase_step" ]
  edge [ source  7 target  8 label "Wo→Yax"   weight 0.5 verb "@phase_step" ]
  edge [ source  8 target  9 label "Yax→Sek"  weight 0.5 verb "@phase_step" ]
  edge [ source  9 target 10 label "Sek→Chen" weight 0.5 verb "@phase_step" ]
  edge [ source 10 target 11 label "Chen→Xul" weight 0.5 verb "@phase_step" ]
  edge [ source 11 target  6 label "Xul→Pop"  weight 0.5 verb "@phase_step" ]

  (* INFER-µ cycle *)
  edge [ source 12 target 13 label "Pop→Wo"   weight 0.5 verb "@phase_step" ]
  edge [ source 13 target 14 label "Wo→Yax"   weight 0.5 verb "@phase_step" ]
  edge [ source 14 target 15 label "Yax→Sek"  weight 0.5 verb "@phase_step" ]
  edge [ source 15 target 16 label "Sek→Chen" weight 0.5 verb "@phase_step" ]
  edge [ source 16 target 17 label "Chen→Xul" weight 0.5 verb "@phase_step" ]
  edge [ source 17 target 12 label "Xul→Pop"  weight 0.5 verb "@phase_step" ]

  (* ELIZA cycle *)
  edge [ source 18 target 19 label "Pop→Wo"   weight 0.5 verb "@phase_step" ]
  edge [ source 19 target 20 label "Wo→Yax"   weight 0.5 verb "@phase_step" ]
  edge [ source 20 target 21 label "Yax→Sek"  weight 0.5 verb "@phase_step" ]
  edge [ source 21 target 22 label "Sek→Chen" weight 0.5 verb "@phase_step" ]
  edge [ source 22 target 23 label "Chen→Xul" weight 0.5 verb "@phase_step" ]
  edge [ source 23 target 18 label "Xul→Pop"  weight 0.5 verb "@phase_step" ]

  (* TOOL-µ cycle *)
  edge [ source 24 target 25 label "Pop→Wo"   weight 0.5 verb "@phase_step" ]
  edge [ source 25 target 26 label "Wo→Yax"   weight 0.5 verb "@phase_step" ]
  edge [ source 26 target 27 label "Yax→Sek"  weight 0.5 verb "@phase_step" ]
  edge [ source 27 target 28 label "Sek→Chen" weight 0.5 verb "@phase_step" ]
  edge [ source 28 target 29 label "Chen→Xul" weight 0.5 verb "@phase_step" ]
  edge [ source 29 target 24 label "Xul→Pop"  weight 0.5 verb "@phase_step" ]

  (* ORCH-µ cycle *)
  edge [ source 30 target 31 label "Pop→Wo"   weight 0.5 verb "@phase_step" ]
  edge [ source 31 target 32 label "Wo→Yax"   weight 0.5 verb "@phase_step" ]
  edge [ source 32 target 33 label "Yax→Sek"  weight 0.5 verb "@phase_step" ]
  edge [ source 33 target 34 label "Sek→Chen" weight 0.5 verb "@phase_step" ]
  edge [ source 34 target 35 label "Chen→Xul" weight 0.5 verb "@phase_step" ]
  edge [ source 35 target 30 label "Xul→Pop"  weight 0.5 verb "@phase_step" ]

  (* MEM-µ cycle *)
  edge [ source 36 target 37 label "Pop→Wo"   weight 0.5 verb "@phase_step" ]
  edge [ source 37 target 38 label "Wo→Yax"   weight 0.5 verb "@phase_step" ]
  edge [ source 38 target 39 label "Yax→Sek"  weight 0.5 verb "@phase_step" ]
  edge [ source 39 target 40 label "Sek→Chen" weight 0.5 verb "@phase_step" ]
  edge [ source 40 target 41 label "Chen→Xul" weight 0.5 verb "@phase_step" ]
  edge [ source 41 target 36 label "Xul→Pop"  weight 0.5 verb "@phase_step" ]

  (* Coordinator cycle *)
  edge [ source 42 target 43 label "Pop→Wo"   weight 0.5 verb "@phase_step" ]
  edge [ source 43 target 44 label "Wo→Yax"   weight 0.5 verb "@phase_step" ]
  edge [ source 44 target 45 label "Yax→Sek"  weight 0.5 verb "@phase_step" ]
  edge [ source 45 target 46 label "Sek→Chen" weight 0.5 verb "@phase_step" ]
  edge [ source 46 target 47 label "Chen→Xul" weight 0.5 verb "@phase_step" ]
  edge [ source 47 target 42 label "Xul→Pop"  weight 0.5 verb "@phase_step" ]
]
