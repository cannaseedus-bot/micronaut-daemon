graph [
  directed 1
  schema "kuhul.daemon-emotions.v1"
  label "DaemonEmotionPresentationCandidates"
  authority "data_only"
  semantic_authority 0
  purpose "emotion cues suggest presentation modes; no diagnosis or admission"
  mode_catalog "data/grammar/daemon-behavior-modes.v1.json"
  icon_sprite "data/icons/emotions.svg"

  node [ id 1 label "joy" kind "emotion_cue" icon_ref "data/icons/emotions.svg#joy" ]
  node [ id 2 label "sadness" kind "emotion_cue" icon_ref "data/icons/emotions.svg#sadness" ]
  node [ id 3 label "anxiety" kind "emotion_cue" icon_ref "data/icons/emotions.svg#anxiety" ]
  node [ id 4 label "anger" kind "emotion_cue" icon_ref "data/icons/emotions.svg#anger" ]
  node [ id 5 label "curiosity" kind "emotion_cue" icon_ref "data/icons/emotions.svg#curiosity" ]
  node [ id 6 label "calm" kind "emotion_cue" icon_ref "data/icons/emotions.svg#calm" ]
  node [ id 7 label "frustration" kind "emotion_cue" icon_ref "data/icons/emotions.svg#frustration" ]
  node [ id 8 label "loneliness" kind "emotion_cue" icon_ref "data/icons/emotions.svg#loneliness" ]

  node [ id 101 label "buddy" kind "behavior_mode" mode_ref "buddy" ]
  node [ id 102 label "listener" kind "behavior_mode" mode_ref "listener" ]
  node [ id 103 label "coach" kind "behavior_mode" mode_ref "coach" ]
  node [ id 104 label "mediator" kind "behavior_mode" mode_ref "mediator" ]
  node [ id 105 label "socratic" kind "behavior_mode" mode_ref "socratic" ]
  node [ id 106 label "debugger" kind "behavior_mode" mode_ref "debugger" ]
  node [ id 107 label "mentor" kind "behavior_mode" mode_ref "mentor" ]
  node [ id 108 label "grief-support" kind "behavior_mode" mode_ref "grief-support" ]

  edge [ source 1 target 101 relation "presentation_candidate" ]
  edge [ source 2 target 102 relation "presentation_candidate" ]
  edge [ source 2 target 108 relation "presentation_candidate" ]
  edge [ source 3 target 102 relation "presentation_candidate" ]
  edge [ source 4 target 104 relation "presentation_candidate" ]
  edge [ source 5 target 105 relation "presentation_candidate" ]
  edge [ source 6 target 107 relation "presentation_candidate" ]
  edge [ source 7 target 106 relation "presentation_candidate" ]
  edge [ source 8 target 101 relation "presentation_candidate" ]
  edge [ source 8 target 102 relation "presentation_candidate" ]
]
