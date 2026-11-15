(* K'UHUL Code Wildcard / Tool-Routing Field Graph.
   Declares the structural capture topology for CODEX-µ: wildcard patterns
   that route code operation intents to tool selectors, language-structure
   patterns that anchor captures to code constructs, representative bigram
   candidates from the expert-code-v1.s7 training domain, and the XCFE/
   dual-validator gate chain leading to CodeReviewProposal output.
   Authority: data_only. Graph membership is not execution authority.
   No entry here admits, verifies, or commits. *)
graph [
  directed 1
  id 3101
  label "CodeWildcardFieldGraph"
  schema "kgf.code-wildcard/1"
  authority "data_only"
  admission "xcfe_required"
  cycle_policy "active_path_detection"
  max_depth 3
  micronaut_ref "micronaut:CODEX"
  grammar_ref "vendor/key-grammar-kit/data/grammar/codex-mu.runtime.ebnf"

  (* ---- Wildcard operators ---- *)
  node [ id 20 label "*" kind "wildcard" absorbs "remainder" arity "variable" ]
  node [ id 21 label "* *" kind "wildcard" absorbs "sequence" arity 2 ]

  (* ---- Code construct nodes (Wo binding; structural primitives) ---- *)
  node [ id 1  label "code:FUNCTION"  kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 2  label "code:CLASS"     kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 3  label "code:METHOD"    kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 4  label "code:IMPORT"    kind "code_construct" phase "Pop" authority "data_only" ]
  node [ id 5  label "code:VARIABLE"  kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 6  label "code:LOOP"      kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 7  label "code:CONDITION" kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 8  label "code:EXCEPTION" kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 9  label "code:INTERFACE" kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 10 label "code:ASYNC"     kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 11 label "code:STATIC"    kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 12 label "code:CALLBACK"  kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 13 label "code:PROMISE"   kind "code_construct" phase "Wo" authority "data_only" ]
  node [ id 14 label "code:MODULE"    kind "code_construct" phase "Pop" authority "data_only" ]
  node [ id 15 label "code:RETURN"    kind "code_construct" phase "Wo" authority "data_only" ]

  (* ---- Intent wildcard patterns ---- *)
  (* Each pattern fires at the phase listed; none invoke a tool on match. *)
  node [ id 30 label "pattern:REVIEW_*"              kind "wildcard_pattern" phase "Wo"  authority "proposal_only" ]
  node [ id 31 label "pattern:REFACTOR_*"            kind "wildcard_pattern" phase "Yax" authority "proposal_only" ]
  node [ id 32 label "pattern:ADD_TEST_FOR_*"        kind "wildcard_pattern" phase "Yax" authority "proposal_only" ]
  node [ id 33 label "pattern:TEST_*"                kind "wildcard_pattern" phase "Yax" authority "proposal_only" ]
  node [ id 34 label "pattern:DOCUMENT_*"            kind "wildcard_pattern" phase "Yax" authority "proposal_only" ]
  node [ id 35 label "pattern:OPTIMIZE_*"            kind "wildcard_pattern" phase "Yax" authority "proposal_only" ]
  node [ id 36 label "pattern:FIX_*"                 kind "wildcard_pattern" phase "Yax" authority "proposal_only" ]
  node [ id 37 label "pattern:IMPROVE_PERFORMANCE_*" kind "wildcard_pattern" phase "Yax" authority "proposal_only" ]

  (* ---- Language structure wildcard patterns ---- *)
  (* Language-specific structural anchors; phase Wo (declarative binding). *)
  node [ id 40 label "pattern:FUNCTION_*_JS"    kind "lang_struct_pattern" lang "javascript" phase "Wo" authority "proposal_only" ]
  node [ id 41 label "pattern:CLASS_*_JS"       kind "lang_struct_pattern" lang "javascript" phase "Wo" authority "proposal_only" ]
  node [ id 42 label "pattern:ASYNC_FN_*_JS"    kind "lang_struct_pattern" lang "javascript" phase "Wo" authority "proposal_only" ]
  node [ id 43 label "pattern:DEF_*_PY"         kind "lang_struct_pattern" lang "python"     phase "Wo" authority "proposal_only" ]
  node [ id 44 label "pattern:CLASS_*_PY"       kind "lang_struct_pattern" lang "python"     phase "Wo" authority "proposal_only" ]
  node [ id 45 label "pattern:PUBLIC_*_CS"      kind "lang_struct_pattern" lang "csharp"     phase "Wo" authority "proposal_only" ]
  node [ id 46 label "pattern:VOID_*_CPP"       kind "lang_struct_pattern" lang "cpp"        phase "Wo" authority "proposal_only" ]
  node [ id 47 label "pattern:CLASS_*_JAVA"     kind "lang_struct_pattern" lang "java"       phase "Wo" authority "proposal_only" ]

  (* ---- Capture slot nodes ---- *)
  (* Slots are pattern-scoped; the prefix is stripped before the wildcard absorbs. *)
  node [ id 60 label "capture:REVIEW_SUBJECT"    kind "capture" slot "subject"    prefix "review "                phase "Wo"  ]
  node [ id 61 label "capture:REFACTOR_SUBJECT"  kind "capture" slot "subject"    prefix "refactor "             phase "Yax" ]
  node [ id 62 label "capture:TEST_SUBJECT"      kind "capture" slot "subject"    prefix "add test for "         phase "Yax" ]
  node [ id 63 label "capture:TEST_ALT_SUBJECT"  kind "capture" slot "subject"    prefix "test "                 phase "Yax" ]
  node [ id 64 label "capture:DOC_SUBJECT"       kind "capture" slot "subject"    prefix "document "             phase "Yax" ]
  node [ id 65 label "capture:OPTIMIZE_SUBJECT"  kind "capture" slot "subject"    prefix "optimize "             phase "Yax" ]
  node [ id 66 label "capture:FN_NAME_JS"        kind "capture" slot "fn_name"    prefix "function "             phase "Wo"  ]
  node [ id 67 label "capture:CLASS_NAME_JS"     kind "capture" slot "class_name" prefix "class "                phase "Wo"  ]
  node [ id 68 label "capture:DEF_NAME_PY"       kind "capture" slot "fn_name"    prefix "def "                  phase "Wo"  ]
  node [ id 69 label "capture:CLASS_NAME_PY"     kind "capture" slot "class_name" prefix "class "                phase "Wo"  ]

  (* ---- Tool selector nodes (Sek — selection; no execution) ---- *)
  node [ id 80 label "tool:REVIEWER"   kind "tool_selector" phase "Sek" authority "proposal_only" shards "github-codereview,Code-Feedback"      threshold 0.7 ]
  node [ id 81 label "tool:REFACTORER" kind "tool_selector" phase "Sek" authority "proposal_only" shards "dolphin-coder,phi-2-sft-lora"         threshold 0.7 ]
  node [ id 82 label "tool:TESTER"     kind "tool_selector" phase "Sek" authority "proposal_only" shards "crowd-code-dataset-1.0"                threshold 0.7 ]
  node [ id 83 label "tool:DOCUMENTER" kind "tool_selector" phase "Sek" authority "proposal_only" shards "G-Code"                               threshold 0.7 ]
  node [ id 84 label "tool:OPTIMIZER"  kind "tool_selector" phase "Sek" authority "proposal_only" shards "scripts,dolphin-coder"                threshold 0.7 ]

  (* ---- XCFE gate and dual-validator chain (Ch'en verification) ---- *)
  node [ id 90 label "xcfe:CODEX_ADMISSION" kind "execution_gate"    phase "Sek"    authority "host_gated" ]
  node [ id 91 label "validate:S7_MINI_GGUF" kind "validator"        phase "Ch'en"  authority "host_gated" port 7734 ]
  node [ id 92 label "validate:DESP_V1"      kind "validator"        phase "Ch'en"  authority "host_gated" port 5003 ]
  node [ id 93 label "xcfe:CODEX_POLICY"     kind "policy"           phase "Sek"    authority "host_gated" ]
  node [ id 94 label "phase:CHEN_VERIFY"     kind "verification_gate" phase "Ch'en" authority "host_gated" ]
  node [ id 95 label "phase:XUL_CLOSE"       kind "closure_gate"     phase "Xul"    authority "host_gated" ]

  (* ---- Output proposal nodes ---- *)
  node [ id 100 label "output:CODE_REVIEW_PROPOSAL"   kind "proposal"       phase "Sek"    authority "proposal_only" ]
  node [ id 101 label "output:REFACTOR_PROPOSAL"      kind "proposal"       phase "Sek"    authority "proposal_only" ]
  node [ id 102 label "output:TEST_PROPOSAL"          kind "proposal"       phase "Sek"    authority "proposal_only" ]
  node [ id 103 label "output:DOC_PROPOSAL"           kind "proposal"       phase "Sek"    authority "proposal_only" ]
  node [ id 104 label "output:OPTIMIZATION_PROPOSAL"  kind "proposal"       phase "Sek"    authority "proposal_only" ]
  node [ id 105 label "output:VERIFIED_CODE_PROPOSAL" kind "verified_result" phase "Ch'en" authority "host_gated"    ]
  node [ id 106 label "store:DETERMINISTIC_V6_TRACE"  kind "persistence_target" phase "Xul" authority "host_gated"  ]

  (* ---- Bigram candidate nodes (Yax expansion; from expert-code-v1.s7 domain) ---- *)
  (* Representative pairs drawn from the 1289-bigram personality model.
     Left × right reflect co-occurrence in the training corpus
     (JS 31814, Python 17101, C# 4601, C++ 2444, Java 509 records). *)
  node [ id 200 label "bigram:FUNCTION|ASYNC"     kind "bigram_candidate" phase "Yax" left "code:FUNCTION"  right "code:ASYNC"     authority "proposal_only" lang "javascript" ]
  node [ id 201 label "bigram:FUNCTION|CALLBACK"  kind "bigram_candidate" phase "Yax" left "code:FUNCTION"  right "code:CALLBACK"  authority "proposal_only" lang "javascript" ]
  node [ id 202 label "bigram:CLASS|EXTENDS"      kind "bigram_candidate" phase "Yax" left "code:CLASS"     right "code:INTERFACE" authority "proposal_only" lang "javascript" ]
  node [ id 203 label "bigram:PROMISE|THEN"       kind "bigram_candidate" phase "Yax" left "code:PROMISE"   right "code:CALLBACK"  authority "proposal_only" lang "javascript" ]
  node [ id 204 label "bigram:ASYNC|AWAIT"        kind "bigram_candidate" phase "Yax" left "code:ASYNC"     right "code:PROMISE"   authority "proposal_only" lang "javascript" ]
  node [ id 205 label "bigram:FUNCTION|RETURN"    kind "bigram_candidate" phase "Yax" left "code:FUNCTION"  right "code:RETURN"    authority "proposal_only" lang "javascript" ]
  node [ id 206 label "bigram:VARIABLE|FUNCTION"  kind "bigram_candidate" phase "Yax" left "code:VARIABLE"  right "code:FUNCTION"  authority "proposal_only" lang "javascript" ]
  node [ id 207 label "bigram:IMPORT|MODULE"      kind "bigram_candidate" phase "Yax" left "code:IMPORT"    right "code:MODULE"    authority "proposal_only" lang "javascript" ]
  node [ id 208 label "bigram:LOOP|CONDITION"     kind "bigram_candidate" phase "Yax" left "code:LOOP"      right "code:CONDITION" authority "proposal_only" lang "javascript" ]
  node [ id 209 label "bigram:DEF|SELF"           kind "bigram_candidate" phase "Yax" left "code:METHOD"    right "code:CLASS"     authority "proposal_only" lang "python"     ]
  node [ id 210 label "bigram:CLASS|INIT"         kind "bigram_candidate" phase "Yax" left "code:CLASS"     right "code:METHOD"    authority "proposal_only" lang "python"     ]
  node [ id 211 label "bigram:EXCEPTION|CONDITION" kind "bigram_candidate" phase "Yax" left "code:EXCEPTION" right "code:CONDITION" authority "proposal_only" lang "python"   ]
  node [ id 212 label "bigram:LOOP|RANGE"         kind "bigram_candidate" phase "Yax" left "code:LOOP"      right "code:VARIABLE"  authority "proposal_only" lang "python"     ]
  node [ id 213 label "bigram:STATIC|METHOD"      kind "bigram_candidate" phase "Yax" left "code:STATIC"    right "code:METHOD"    authority "proposal_only" lang "csharp"     ]
  node [ id 214 label "bigram:ASYNC|METHOD"       kind "bigram_candidate" phase "Yax" left "code:ASYNC"     right "code:METHOD"    authority "proposal_only" lang "csharp"     ]
  node [ id 215 label "bigram:INTERFACE|CLASS"    kind "bigram_candidate" phase "Yax" left "code:INTERFACE"  right "code:CLASS"    authority "proposal_only" lang "csharp"     ]
  node [ id 216 label "bigram:VOID|FUNCTION"      kind "bigram_candidate" phase "Yax" left "code:FUNCTION"  right "code:VARIABLE"  authority "proposal_only" lang "cpp"        ]
  node [ id 217 label "bigram:STATIC|VARIABLE"    kind "bigram_candidate" phase "Yax" left "code:STATIC"    right "code:VARIABLE"  authority "proposal_only" lang "cpp"        ]

  (* ---- Edges: code construct → bigram candidates (unfolds_to_bigram) ---- *)
  edge [ source 1  target 200 relation "unfolds_to_bigram" ]
  edge [ source 10 target 200 relation "bigram_target" ]
  edge [ source 1  target 201 relation "unfolds_to_bigram" ]
  edge [ source 12 target 201 relation "bigram_target" ]
  edge [ source 2  target 202 relation "unfolds_to_bigram" ]
  edge [ source 9  target 202 relation "bigram_target" ]
  edge [ source 13 target 203 relation "unfolds_to_bigram" ]
  edge [ source 12 target 203 relation "bigram_target" ]
  edge [ source 10 target 204 relation "unfolds_to_bigram" ]
  edge [ source 13 target 204 relation "bigram_target" ]
  edge [ source 1  target 205 relation "unfolds_to_bigram" ]
  edge [ source 15 target 205 relation "bigram_target" ]
  edge [ source 5  target 206 relation "unfolds_to_bigram" ]
  edge [ source 1  target 206 relation "bigram_target" ]
  edge [ source 4  target 207 relation "unfolds_to_bigram" ]
  edge [ source 14 target 207 relation "bigram_target" ]
  edge [ source 6  target 208 relation "unfolds_to_bigram" ]
  edge [ source 7  target 208 relation "bigram_target" ]
  edge [ source 3  target 209 relation "unfolds_to_bigram" ]
  edge [ source 2  target 209 relation "bigram_target" ]
  edge [ source 2  target 210 relation "unfolds_to_bigram" ]
  edge [ source 3  target 210 relation "bigram_target" ]
  edge [ source 8  target 211 relation "unfolds_to_bigram" ]
  edge [ source 7  target 211 relation "bigram_target" ]
  edge [ source 6  target 212 relation "unfolds_to_bigram" ]
  edge [ source 5  target 212 relation "bigram_target" ]
  edge [ source 11 target 213 relation "unfolds_to_bigram" ]
  edge [ source 3  target 213 relation "bigram_target" ]
  edge [ source 10 target 214 relation "unfolds_to_bigram" ]
  edge [ source 3  target 214 relation "bigram_target" ]
  edge [ source 9  target 215 relation "unfolds_to_bigram" ]
  edge [ source 2  target 215 relation "bigram_target" ]
  edge [ source 1  target 216 relation "unfolds_to_bigram" ]
  edge [ source 5  target 216 relation "bigram_target" ]
  edge [ source 11 target 217 relation "unfolds_to_bigram" ]
  edge [ source 5  target 217 relation "bigram_target" ]

  (* ---- Edges: bigram candidates → tool selectors (instantiates_review) ---- *)
  edge [ source 200 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 201 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 202 target 81 relation "instantiates_review" status "candidate" ]
  edge [ source 203 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 204 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 205 target 82 relation "instantiates_review" status "candidate" ]
  edge [ source 206 target 81 relation "instantiates_review" status "candidate" ]
  edge [ source 207 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 208 target 84 relation "instantiates_review" status "candidate" ]
  edge [ source 209 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 210 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 211 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 212 target 84 relation "instantiates_review" status "candidate" ]
  edge [ source 213 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 214 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 215 target 81 relation "instantiates_review" status "candidate" ]
  edge [ source 216 target 80 relation "instantiates_review" status "candidate" ]
  edge [ source 217 target 84 relation "instantiates_review" status "candidate" ]

  (* ---- Edges: intent patterns → capture slots → wildcard operator ---- *)
  edge [ source 30 target 60 relation "captures" position 0 ]
  edge [ source 31 target 61 relation "captures" position 0 ]
  edge [ source 32 target 62 relation "captures" position 0 ]
  edge [ source 33 target 63 relation "captures" position 0 ]
  edge [ source 34 target 64 relation "captures" position 0 ]
  edge [ source 35 target 65 relation "captures" position 0 ]
  edge [ source 36 target 60 relation "captures" position 0 ]
  edge [ source 60 target 20 relation "binds" ]
  edge [ source 61 target 20 relation "binds" ]
  edge [ source 62 target 20 relation "binds" ]
  edge [ source 63 target 20 relation "binds" ]
  edge [ source 64 target 20 relation "binds" ]
  edge [ source 65 target 20 relation "binds" ]

  (* ---- Edges: language structure patterns → capture slots ---- *)
  edge [ source 40 target 66 relation "captures" position 0 ]
  edge [ source 41 target 67 relation "captures" position 0 ]
  edge [ source 42 target 66 relation "captures" position 0 ]
  edge [ source 43 target 68 relation "captures" position 0 ]
  edge [ source 44 target 69 relation "captures" position 0 ]
  edge [ source 45 target 66 relation "captures" position 0 ]
  edge [ source 46 target 66 relation "captures" position 0 ]
  edge [ source 47 target 67 relation "captures" position 0 ]
  edge [ source 66 target 20 relation "binds" ]
  edge [ source 67 target 20 relation "binds" ]
  edge [ source 68 target 20 relation "binds" ]
  edge [ source 69 target 20 relation "binds" ]

  (* ---- Edges: intent patterns → tool selectors (direct routing) ---- *)
  edge [ source 30 target 80 relation "routes_to" ]
  edge [ source 31 target 81 relation "routes_to" ]
  edge [ source 32 target 82 relation "routes_to" ]
  edge [ source 33 target 82 relation "routes_to" ]
  edge [ source 34 target 83 relation "routes_to" ]
  edge [ source 35 target 84 relation "routes_to" ]
  edge [ source 36 target 80 relation "routes_to" ]
  edge [ source 37 target 84 relation "routes_to" ]

  (* ---- Edges: tool selectors → proposals and admission gate ---- *)
  edge [ source 80 target 100 relation "generates_candidate" ]
  edge [ source 81 target 101 relation "generates_candidate" ]
  edge [ source 82 target 102 relation "generates_candidate" ]
  edge [ source 83 target 103 relation "generates_candidate" ]
  edge [ source 84 target 104 relation "generates_candidate" ]
  edge [ source 100 target 90 relation "requires_admission" ]
  edge [ source 101 target 90 relation "requires_admission" ]
  edge [ source 102 target 90 relation "requires_admission" ]
  edge [ source 103 target 90 relation "requires_admission" ]
  edge [ source 104 target 90 relation "requires_admission" ]

  (* ---- Edges: XCFE gate chain ---- *)
  edge [ source 80 target 93 relation "subject_to_policy" ]
  edge [ source 81 target 93 relation "subject_to_policy" ]
  edge [ source 82 target 93 relation "subject_to_policy" ]
  edge [ source 83 target 93 relation "subject_to_policy" ]
  edge [ source 84 target 93 relation "subject_to_policy" ]
  edge [ source 93 target 90 relation "requires_gate" ]
  edge [ source 90 target 91 relation "requires_validator" ]
  edge [ source 90 target 92 relation "requires_validator" ]
  edge [ source 91 target 94 relation "validator_pass_required" ]
  edge [ source 92 target 94 relation "validator_pass_required" ]
  edge [ source 94 target 105 relation "produces_if_evidence_sufficient" ]
  edge [ source 105 target 95 relation "requires_authorized_closure" ]
  edge [ source 95 target 106 relation "authorized_persistence_only" ]
]
