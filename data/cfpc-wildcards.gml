graph [
  directed 1
  label "CFPCWildcardGraph"
  comment "CFPC capture topology, hand-declared from vendor/key-grammar-kit/data/cfpc/*.cfpc-pattern.v1.json. Each pattern names the slot it captures, the literal prefix stripped before that capture, the phase it belongs to, and how far it may resolve in the neighbourhood. One shared '*' node absorbs the remainder for every capture: the operator is shared, the stripped text is not. Two patterns strip the same prefix 'how does ', so the wildcard alone does not identify a pattern - the pattern id does. Nothing here admits, verifies or commits."

  (* one wildcard operator, bound by every capture *)
  node [ id 1 label "*" kind "wildcard" absorbs "remainder" ]

  (* patterns, with the phase each belongs to and its resolution depth *)
  node [ id 11 label "what-is" kind "pattern" phase "Wo" hops 1 ]
  node [ id 12 label "why-does" kind "pattern" phase "Ch'en" hops 2 ]
  node [ id 13 label "how-to" kind "pattern" phase "Yax" hops 2 ]
  node [ id 14 label "how-does-affect" kind "pattern" phase "Ch'en" hops 2 ]
  node [ id 15 label "how-does-relate" kind "pattern" phase "Sek" hops 2 ]
  node [ id 16 label "what-is-the-difference" kind "pattern" phase "Sek" hops 2 ]
  node [ id 17 label "explain" kind "pattern" phase "Sek" hops 2 ]
  node [ id 18 label "tell-me-about" kind "pattern" phase "Pop" hops 2 ]

  (* capture slots: pattern-scoped, because the stripped prefix belongs to the pattern *)
  node [ id 21 label "what-is:subject" kind "capture" slot "subject" prefix "what is " ]
  node [ id 22 label "why-does:subject" kind "capture" slot "subject" prefix "why does " ]
  node [ id 23 label "how-to:subject" kind "capture" slot "subject" prefix "how to " ]
  node [ id 24 label "how-does-affect:verb" kind "capture" slot "verb" prefix "how does " ]
  node [ id 25 label "how-does-relate:value" kind "capture" slot "value" prefix "how does " ]
  node [ id 26 label "what-is-the-difference:subject" kind "capture" slot "subject" prefix "what is the difference between " ]
  node [ id 27 label "explain:subject" kind "capture" slot "subject" prefix "explain " ]
  node [ id 28 label "tell-me-about:subject" kind "capture" slot "subject" prefix "tell me about " ]

  edge [ source 11 target 21 relation "captures" position 0 ]
  edge [ source 12 target 22 relation "captures" position 0 ]
  edge [ source 13 target 23 relation "captures" position 0 ]
  edge [ source 14 target 24 relation "captures" position 0 ]
  edge [ source 15 target 25 relation "captures" position 0 ]
  edge [ source 16 target 26 relation "captures" position 0 ]
  edge [ source 17 target 27 relation "captures" position 0 ]
  edge [ source 18 target 28 relation "captures" position 0 ]

  edge [ source 21 target 1 relation "binds" ]
  edge [ source 22 target 1 relation "binds" ]
  edge [ source 23 target 1 relation "binds" ]
  edge [ source 24 target 1 relation "binds" ]
  edge [ source 25 target 1 relation "binds" ]
  edge [ source 26 target 1 relation "binds" ]
  edge [ source 27 target 1 relation "binds" ]
  edge [ source 28 target 1 relation "binds" ]
]
