graph [
  directed 1
  label "SyllableGraph"
  comment "SYLLABLE-mu pronunciation topology. One node per pronounced beat, shared by every word that uses it. Sharing a syllable is evidence of phonological similarity, never of semantic similarity: contains edges carry no meaning relation and grant no authority. Order lives on the contains edge, not on the node, because a shared beat sits at different positions in different words and may repeat inside one word (to-ma-to). Node label is the shared orthographic unit; ipa is the sound where it is known; the edge surface is how the word spells that beat."

  node [ id 1 label "tomato" kind "word" beats 3 ]
  node [ id 2 label "to" kind "syllable" ]
  node [ id 3 label "ma" kind "syllable" ]

  node [ id 4 label "banana" kind "word" beats 3 ]
  node [ id 5 label "ba" kind "syllable" ]
  node [ id 6 label "na" kind "syllable" ]

  node [ id 7 label "computer" kind "word" beats 3 ]
  node [ id 8 label "com" kind "syllable" ipa "k\u0259m" ]
  node [ id 9 label "pu" kind "syllable" ]
  node [ id 10 label "ter" kind "syllable" ]

  node [ id 11 label "prediction" kind "word" beats 3 ]
  node [ id 12 label "pre" kind "syllable" ]
  node [ id 13 label "dic" kind "syllable" ]
  node [ id 14 label "tion" kind "syllable" ]

  node [ id 15 label "complete" kind "word" beats 2 ]
  node [ id 16 label "plete" kind "syllable" ]

  node [ id 17 label "combine" kind "word" beats 2 ]
  node [ id 18 label "bine" kind "syllable" ]

  node [ id 19 label "compare" kind "word" beats 2 ]
  node [ id 20 label "pare" kind "syllable" ]

  node [ id 21 label "command" kind "word" beats 2 ]
  node [ id 22 label "mand" kind "syllable" ]

  node [ id 23 label "compete" kind "word" beats 2 ]
  node [ id 24 label "pete" kind "syllable" ]

  (* tomato: the shared "to" node is used twice in one word *)
  edge [ source 1 target 2 relation "contains" position 0 ]
  edge [ source 1 target 3 relation "contains" position 1 ]
  edge [ source 1 target 2 relation "contains" position 2 ]

  edge [ source 4 target 5 relation "contains" position 0 ]
  edge [ source 4 target 6 relation "contains" position 1 ]
  edge [ source 4 target 6 relation "contains" position 2 ]

  (* six words, one shared "com" node *)
  edge [ source 7 target 8 relation "contains" position 0 ]
  edge [ source 7 target 9 relation "contains" position 1 ]
  edge [ source 7 target 10 relation "contains" position 2 ]

  edge [ source 11 target 12 relation "contains" position 0 ]
  edge [ source 11 target 13 relation "contains" position 1 ]
  edge [ source 11 target 14 relation "contains" position 2 ]

  edge [ source 15 target 8 relation "contains" position 0 ]
  edge [ source 15 target 16 relation "contains" position 1 ]
  edge [ source 17 target 8 relation "contains" position 0 ]
  edge [ source 17 target 18 relation "contains" position 1 ]
  edge [ source 19 target 8 relation "contains" position 0 ]
  edge [ source 19 target 20 relation "contains" position 1 ]
  edge [ source 21 target 8 relation "contains" position 0 ]
  edge [ source 21 target 22 relation "contains" position 1 ]
  edge [ source 23 target 8 relation "contains" position 0 ]
  edge [ source 23 target 24 relation "contains" position 1 ]
]
