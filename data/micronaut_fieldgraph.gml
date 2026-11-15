graph [
  comment "Micronaut fleet FieldGraph. GML is the canonical fold-node and transition topology; resident identities are resolved from a host Micronaut registry at projection time. The graph is descriptive/projection geometry and does not grant execution authority. See grammar/mml/v1/MicronautFieldGraph.mml for tensor and W-C-R laws."
  directed 1
  id 2701
  label "MICRONAUT_FOLD_FIELDGRAPH"
  graph_kind "field_graph"
  authority "projection_only"
  weight_policy "fibonacci_destination_node"
  fold_cycle "Pop,Wo,Yax,Sek,Ch'en,Xul"
  fold_weights "1,1,2,3,5,8"

  node [ id 0 label "Pop" fold_phase "Pop" role "observe_read_context" fibonacci_weight 1 resident_selector "fold=Pop" x 0.0 y 0.0 z 0.0 ]
  node [ id 1 label "Wo" fold_phase "Wo" role "schedule_plan" fibonacci_weight 1 resident_selector "fold=Wo" x 1.0 y 0.0 z 0.0 ]
  node [ id 2 label "Yax" fold_phase "Yax" role "branch_explore" fibonacci_weight 2 resident_selector "fold=Yax" x 2.0 y 0.0 z 0.0 ]
  node [ id 3 label "Sek" fold_phase "Sek" role "dispatch_execute" fibonacci_weight 3 resident_selector "fold=Sek" x 3.0 y 0.0 z 0.0 ]
  node [ id 4 label "Ch'en" fold_phase "Ch'en" role "verify" fibonacci_weight 5 resident_selector "fold=Ch'en|fold=Chen" x 4.0 y 0.0 z 0.0 ]
  node [ id 5 label "Xul" fold_phase "Xul" role "emit_persist" fibonacci_weight 8 resident_selector "fold=Xul" x 5.0 y 0.0 z 0.0 ]
  node [ id 6 label "System" fold_phase "null" role "entry_meta" fibonacci_weight 1 resident_selector "fold=null|fold=missing" x 0.0 y 1.0 z 0.0 ]

  edge [ id 101 source 0 target 1 label "Pop_to_Wo" verb "@phase_step" weight 1.0 arc_weight 1 ]
  edge [ id 102 source 1 target 2 label "Wo_to_Yax" verb "@phase_step" weight 2.0 arc_weight 2 ]
  edge [ id 103 source 2 target 3 label "Yax_to_Sek" verb "@phase_step" weight 3.0 arc_weight 3 ]
  edge [ id 104 source 3 target 4 label "Sek_to_Chen" verb "@phase_step" weight 5.0 arc_weight 5 ]
  edge [ id 105 source 4 target 5 label "Chen_to_Xul" verb "@phase_step" weight 8.0 arc_weight 8 ]
  edge [ id 106 source 5 target 0 label "Xul_to_Pop" verb "@phase_step" weight 1.0 arc_weight 1 ]
  edge [ id 107 source 1 target 3 label "Wo_to_Sek_shortcut" verb "@delegates_to" weight 3.0 arc_weight 3 ]
  edge [ id 108 source 6 target 0 label "System_to_Pop_entry" verb "@produces" weight 1.0 arc_weight 1 ]
]
