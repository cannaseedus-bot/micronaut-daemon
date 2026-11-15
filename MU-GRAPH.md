# Micronaut Factory and Runtime Graphs

This map separates artifacts that already exist from the proposed factory bus. An edge means a declared dependency or data flow; it does not grant execution authority. The factory should produce reviewable bundles, while XCFE decides whether a route may execute.

## 1. Factory production graph

```mermaid
flowchart LR
  R[Micronaut grammar registry] --> F[Proposed shell/factory.psm1]
  K[Key grammar JSONL sources] --> F
  E[Per-micronaut EBNF] --> F
  M[MathML content dictionaries] --> F
  C[Runtime and factory contracts] --> F
  F --> P[Bundle proposal manifest]
  P --> G[Parser and contract checks]
  G --> A[AIML/SRAI manifest]
  A --> T[tools/render_aiml.py]
  T --> X[Generated AIML]
  G --> J[Expert field JSONL]
  G --> Q[Program/driver proposal]
  X --> V[Review and XCFE admission]
  J --> V
  Q --> V
```

`data/grammar/micronaut-grammar-registry.json` names individual grammars and typed input/output roles. `data/grammar/factory-production.contracts.json` limits factory output to proposals; registration requires validation, authorization, and a driver. `tools/render_aiml.py` can render a validated basic AIML manifest now. **`shell/factory.psm1` and `factory.xsd` do not exist in this repository.** `data/schema/Micronaut.SRAI.AIML.xsd`, `data/schema/xcfe-aiml.xsd`, and `data/schema/Bindings.xsd` are existing schema inputs, not substitutes for a factory bundle schema.

## 2. One expert bundle

```mermaid
flowchart TB
  ID[Micronaut ID and typed role] --> GR[Own runtime EBNF]
  ID --> KG[Own key grammar JSONL]
  ID --> MM[Own MathML contract, when defined]
  ID --> AR[Small AIML/SRAI route manifest]
  GR --> PAR[Parser/validator]
  KG --> GEN[Field generator and encoder]
  PAR --> PROG[Program and driver proposal]
  GEN --> VEC[Keyed vector field]
  AR --> AIML[Rendered AIML]
  PROG --> BIND[Versioned binding manifest]
  VEC --> BIND
  AIML --> BIND
```

The registry currently lists `SNOBOL-µ`, `CFPC-µ`, `ADVISOR-µ`, `QUESTION-µ`, `CODEX-µ`, `CODEGEN-µ`, and `MX2LM-µ`. Their `implementation_status` values differ; a grammar entry alone is not a working parser or driver. Existing examples include `advisor-mu.runtime.ebnf`, `cfpc-mu.runtime.ebnf`, `codex-mu.runtime.ebnf`, `mx2lm-mu.runtime.ebnf`, and `snobol-mu.runtime.ebnf`. Shared surfaces are `micronaut.runtime-grammar.ebnf`, `micronaut-program.runtime-grammar.ebnf`, `aiml.runtime-grammar.ebnf`, and `typed-query.runtime-grammar.ebnf`.

## 3. Key grammar and vector evidence graph

```mermaid
flowchart LR
  DS[Dataset candidate JSONL] --> N[Normalize and type keys]
  LX[Lexicon and definition JSONL] --> N
  RT[Route, app, control, and program JSONL] --> N
  N --> F[Expert field JSONL with stable keys]
  F --> EMB[EmbeddingGemma Document encoder]
  EMB --> IDX[Vector matrix and digest manifest]
  U[User query] --> QE[Host query encoder]
  QE --> R[Cosine ranker]
  IDX --> R
  R --> RES[Key resolution and source replay]
```

Dataset candidates are `dataset.key-grammar.candidates.jsonl` and the `dataset.{advisor_mu,joke_mu,mx2lm,plan_mu,politics_mu}` variants. Dictionary evidence is in `english-dictionary.lexicon.key-grammar.jsonl` and `english-dictionary.definition-relations.key-grammar.jsonl`. Route and structure sources include `advisor-bootstrap`, `joke-bootstrap`, `plan-bootstrap`, `asx-mini-app`, `cloud-model-chat`, `control-flow`, `css`, `foldgraph-lineage`, `kuhul-relational`, `micronaut-program`, `micronaut-route-contracts`, `ngram-key-grammar`, `self-hosted-forum`, and `socialsphere` key grammar JSONL files. `control-capability-gaps.jsonl` is candidate evidence for the factory, not an executable capability.

The current `tools/key_grammar_fields.py` compiles six bounded JSONL sources into 183 candidate fields; it does not yet cover every source above. Each expert needs a declared source-to-key binding and a separate response policy before ranked fields can affect chat.

## 4. Conversation and authority graph

```mermaid
flowchart LR
  U[Utterance] --> AIML[Basic AIML match/SRAI redirect]
  AIML --> BUS[shell/Server.psm1 bus]
  BUS --> VR[Vector ingress and expert ranking]
  VR --> RP[Typed route proposal]
  RP --> XCFE[XCFE admission]
  XCFE --> PROG[Registered parser/compiler/generator program]
  PROG --> CH[Ch'en verification]
  CH --> XU[Xul response or authorized commit]
  RP --> TRACE[Observation-only trace]
  XCFE --> TRACE
  CH --> TRACE
```

`runtime-graph.contracts.json` defines legal topology, while `vector-ingress.contracts.json` and `vector-mu.contracts.json` keep similarity separate from identity and permission. `srai-operators.contracts.json` defines typed dispatch proposals. `xcfe-aiml.contract.json`, `xcfe-modes.contracts.json`, and `xcfe-policy.contracts.json` govern admission; `daemon-bot.trace.contracts.json` describes observation only. `word-domains.v1.json` supplies domain vocabulary, not executable graph edges. The current bus emits source-bound greeting and control-key descriptions; it does not execute arbitrary expert programs.

## 5. MathML and grammar authority graph

```mermaid
flowchart TB
  MML[data/grammar/mml/v1 content dictionaries] --> MC[Matching machine contracts in data/grammar]
  MC --> XC[XCFE and runtime validation]
  EBNF[Per-micronaut EBNF] --> PAR[Parser/type checks]
  PAR --> XC
  KG[Key grammar JSONL] --> PAR
  XSD[Existing AIML/XAIML/Bindings XSD] --> PAR
```

`mml/v1/SraiOperators.mml`, `MicronautPatterns.mml`, `XaimlMicronautDispatch.mml`, `DaemonBehaviorModes.mml`, and `daemon-factory.mml` express distinct operator, pattern, dispatch, mode, and factory laws. The phase-driver files cover Pop, Wo, Yax, Sek, Ch'en, and Xul; daemon and CODEGEN dictionaries add domain-specific laws. These MathML files are contract sources. A factory must validate references and types against them; it must not treat an MML declaration as a compiled implementation.

## Factory bundle contract to add

A proposed bundle should identify `{micronaut_id, grammar_ref, key_source_refs, mml_refs, aiml_manifest, program_ref, driver_ref, source_digests, authority: proposal_only}`. The factory should reject missing files, duplicate keys, unsupported AIML tags, unresolved SRAI targets, mismatched phases, and unregistered program operations. It should publish outputs only after all generated files parse and their digests match. Registration and execution remain separate XCFE-controlled steps.

## Low-score query to expert loop

```mermaid
flowchart TD
  Q[User asks about space] --> R[Rank eligible expert fields]
  R --> D{Best admitted field meets its policy threshold?}
  D -- Yes --> V[Replay source and validate response operation]
  V --> A{XCFE admits operation?}
  A -- Yes --> E[Emit sourced answer and trace]
  A -- No --> U[Unresolved query]
  D -- No --> U
  U --> N[Immediate reply: clarify or state no verified answer]
  U --> T[Observation-only gap trace]
  T --> G{Repeated or explicit capability gap with usable evidence?}
  G -- No --> H[Keep gap for review; no expert created]
  G -- Yes --> F[Factory creates SPACE-µ bundle proposal]
  F --> C[Gather and cite domain sources]
  C --> B[Generate grammar, keyed JSONL, AIML/SRAI routes, program and driver proposals]
  B --> P[Parse, type-check, resolve SRAI, verify digests and contracts]
  P --> X{Independent verification and XCFE authorization?}
  X -- No --> H
  X -- Yes --> I[Register expert and build its vector field]
  I --> R2[Later space question can rank SPACE-µ]
```

The threshold is a response-policy gate, not a universal cosine constant. The current key-grammar bus uses 0.80 for literal greetings and 0.75 for explicit control-word descriptions; a SPACE-µ response policy would need its own calibrated threshold, margin, context checks, and source requirements. A low score alone does not prove that an expert is missing: the query may be ambiguous, the encoder or index may be stale, or the relevant source may be outside the current read scope.

The live request must finish without waiting for factory production. Store the utterance, candidate keys and scores, model/index digests, route decision, and missing-capability label as **observation-only** trace data. The factory may use repeated gaps or an explicit build request to propose an expert, but it must not convert a trace into permission, invent facts, or auto-register a program. If admitted later, SPACE-µ owns its source-backed field records and small AIML/SRAI entry routes; a new query still passes ranking, source replay, and response admission before text is emitted. The existing bus currently ends at the fallback and trace side of this loop; factory proposal, registration, and SPACE-µ are planned components.

## 6. ELIZA bias projection graph

```mermaid
flowchart LR
  A[data/alice AIML categories] --> P[data/eliza-bias.gml source projection]
  P --> F[GENERAL_QA / REFLECTION / CONVERSATION / KNOWLEDGE / REASONING / FALLBACK fields]
  P --> B[Default bias: ranking hint]
  F --> R[Candidate field route]
  B --> R
  R --> V[Source, context, and XCFE checks]
  V --> E[Admitted response operation]
  P -. no direct execution .-> E
```

`data/eliza-bias.gml` already binds AIML category nodes to field nodes with `contains_aiml_category` edges. Its own header says `authority "data_only"`, `admission "xcfe_required"`, and `bias_semantics "default ranking hint only; learned bias is separate"`. The category nodes retain pattern, source, source hash, XML, wildcard count, and projection order. This makes the graph useful as a candidate-routing input for the factory and future expert fields; it does not turn its `<mx2lm>` templates into executable programs. Its declared `source_manifest` points to `vendor/key-grammar-kit/data/eliza-field.sources.json`, which is absent from this checkout; a local `data/eliza-field.sources.json` exists and must be identity-checked before substituting it.

## 7. Continuation and π bias graphs

```mermaid
flowchart LR
  L[English dictionary lexicon JSONL] --> C[data/continuation-bias.gml]
  C --> CP[Static token reuse prior]
  D[Domain word tree] --> PI[data/kuhul-pi.gml]
  D --> PR[data/pi-radius-bias.gml]
  V[EmbeddingGemma category vectors] --> PI
  V --> S[data/vectors.gml cohesion features]
  PI --> R[Domain and radius candidate ranking]
  PR --> R
  S --> R
  CP --> R
  R --> A[Source replay and admission]
```

`continuation-bias.gml` contains 4,000 weighted token nodes derived from definition reuse counts. Its weight is a static continuation prior, not a word meaning, truth score, or expert answer. The graph header names `tools/build_continuation_bias.py`, but that generator is absent from this checkout; provenance must be checked before regeneration. `kuhul-pi.gml` carries six-component `V_π` node features and declared domain-tree edges. `pi-radius-bias.gml` supplies a separate depth prior for `W_pi_routing`; `vectors.gml` supplies semantic cohesion features. Their source paths currently point into `.ui-shell`, so the factory must bind local source/vector identities before using them as verified inputs. None of these weights bypasses the response-policy threshold or XCFE gate.

## 8. Behavior and emotion presentation graphs

```mermaid
flowchart LR
  MODES[68-mode catalog JSON] --> BG[data/daemon_behavior_modes.gml]
  AIML[data/alice/daemon-modes.aiml] --> BG
  EM[data/daemon_emotions.gml] --> ICON[data/icons/emotions.svg]
  EM --> MC[Candidate mode IDs in catalog]
  BG --> SEL[Behavior preference selection]
  MC --> SEL
  SEL --> XC[Host policy and XCFE checks]
  XC --> UI[Response style and icon display]
```

`daemon_behavior_modes.gml` is a partial affinity graph: 12 shipped nodes and 9 edges over the 68-mode catalog. Its edge weights are preferences, not probabilities. The new `daemon_emotions.gml` has eight emotion-cue nodes, eight catalog mode references, ten `presentation_candidate` edges, and SVG icon references in `data/icons/emotions.svg`. These cue-to-mode edges are illustrative presentation suggestions, not diagnoses or inferred user emotions. The icon sprite provides display metadata; the current WPF shell has no emotion-icon renderer yet. Mode selection cannot change phase, permission, or learned weights.

## 9. Bootstrap, wildcard, and runtime topology

```mermaid
flowchart LR
  AB[data/advisor-bootstrap.json] --> AM[data/advisor-map.json]
  JB[data/joke-bootstrap.json] --> JT[data/JOKE semantic tracks JSON]
  PB[data/plan-bootstrap.json] --> ROUTES[Expert route proposals]
  W[data/wildcard.gml] --> ROUTES
  AS[data/aiml_state.json] --> ROUTES
  ROUTES --> U[data/unfold-graph.gml]
  G[data/gyro_abi_v1.json] --> U
  M[data/mx2lm.vectors.meta.json] --> U
  U --> XC[XCFE route validation]
```

The bootstrap JSON files author candidate routes; `advisor-map.json` records an XCFE-gated projection of the advisor bootstrap. `wildcard.gml` declares pattern/capture topology without weights. `aiml_state.json` currently contains only a topic field, so it is session context rather than expert knowledge. `unfold-graph.gml` is the Q3 × C6 runtime topology; `gyro_abi_v1.json` maps measurement tracks to epistemic coordinates; `mx2lm.vectors.meta.json` describes the separate large trigram vector snapshot. `data/greeting-bank.json` supplies phase-scoped greeting templates and placeholder rules, while `data/grammar/greeting-bank.key-grammar.jsonl` supplies keyed fields for ranking. Keep these layers distinct when generating expert bundles.

## 10. Local generative Gemma path

```mermaid
flowchart LR
  GG[gemma.bat] --> LL[tiny-llama HTTP server on 127.0.0.1:8091]
  MODEL[Gemma 3 1B GGUF] --> LL
  GAP[Explicit capability gap] --> FACT[shell/factory.psm1]
  FACT --> LL
  LL --> DRAFT[Proposal-only expert draft]
  Q[Chat query] --> EMB[EmbeddingGemma vector retrieval]
  EMB --> V{Verified template selected?}
  V -- Yes --> ANS[Existing admitted response]
  V -- No, neural_local_v1 --> LL
  LL --> GEN[Unverified local model response]
```

`gemma.bat` starts `C:\Users\canna\.llama-win-cpu-x64\llama-server.exe` with `C:\Users\canna\.models\gemma-3-1B-it-QAT-Q4_0.gguf`. The Windows CPU bundle includes `ggml-cpu-haswell.dll` for compatible Haswell processors; the server selects its backend. This **generative** Gemma 3 model is distinct from the pinned **EmbeddingGemma 2** encoder used to rank fields. The shell client is `shell/GemmaNeural.psm1`; `shell/factory.psm1` uses it to draft a bundle from an explicit capability gap without writing or registering anything. The bus exposes `factory.draft` and `gemma.neural.health`. Chat can request `responseMode: "neural_local_v1"` (WPF command `/gemma <question>`) to call the model after verified vector retrieval falls back. Model text is marked `model_output_unverified`; it is not a verified source answer, XCFE admission, or a persistent expert. The default chat route retains the existing no-verified-answer fallback when the neural mode is not requested.

The bus also exposes `gemma.neural.identity` so clients can distinguish the optional text continuation from `gemma.identity`, whose `GEMMA-µ` descriptor remains `rank_only`. A query vector is an embedding produced by a neural encoder; it is not itself a neural network or a set of trainable weights. The Gemma 3 model supplies generated text only after the explicit continuation route is selected.

For code tasks, AIML `<code language="cpp">…</code>` and `<code language="typescript">…</code>` are response content, not learning instructions. `coder.grammar` compiles the existing code grammar patterns, parses source, generates bounded code proposals, and validates a Gemma-proposed AST against a fresh parse. A validated proposal may be reviewed for LEARN-µ; this repository does not yet automatically send AIML code tags or model output to LEARN-µ or register factory drafts as experts.

## 11. Runtime grammar families and terminal routing

```mermaid
flowchart LR
  U[User request] --> TK[Key grammar binding: terminal.route]
  TK --> R{Typed route proposal}
  R -->|retrieve| V[Vector retrieval]
  R -->|chat| C[Chat/AIML]
  R -->|model| G[Local Gemma]
  R -->|model_code| GC[Gemma code proposal]
  R -->|terminal guidance| TA[terminal.aiml]
  TA --> CP[Command proposal]
  CP --> CONFIRM[YES / NO / AUTO UI]
  CONFIRM --> HOST[Registered host command dispatch]
  R --> TRACE[Route trace]
```

`data/alice/terminal.aiml` supplies small command intent patterns; `shell/terminal.bindings.psm1` classifies requests through `terminal.route`, and the WPF shell selects the supported response mode. A terminal route is not shell execution. Command proposals appear for host confirmation; dispatch must remain limited to named host commands. AUTO is session-scoped and limited to read-only commands. AIML guides intent handling, while key grammar bindings and the host perform typed routing and dispatch.

The additional EBNF files map into these graph layers:

| Layer | Grammar sources | Graph role |
| --- | --- | --- |
| Conversation and control | `aiml.runtime-grammar.v4.ebnf`, `aiml.runtime-grammar.v5.ebnf`; `scfml.runtime-grammar.v1.ebnf`, `v2.ebnf`, `v3.ebnf` | AIML categories and templates feed SCFML control-flow normalization before host routing. Keep versioned contracts distinct; do not silently treat a newer grammar as proof that the runtime implements it. |
| Program composition | `program.grammar.ebnf`, `micronaut.runtime-grammar.v2.ebnf` | Shared program syntax composes typed Micronaut declarations and calls; registry entries still need concrete parser and binding implementations. |
| Pattern and regex | `script-pattern.runtime-grammar.ebnf`, `script-pattern.runtime-grammar.v2.ebnf`; `regex-kuhul.runtime-grammar.ebnf`, `v1.ebnf`, `v2.ebnf`; `regex-fsm.runtime-grammar.ebnf` | Pattern text is parsed into regex/FSM structure, then mapped to K'UHUL phases. This is a parse/transform lane, not permission to evaluate arbitrary patterns. |
| Key and retrieval | `ngram-key-grammar.runtime-grammar.v2.ebnf` | Defines typed n-gram key structure used to address indexed fields; keys support retrieval and ranking, not response authority by themselves. |
| Domain experts | `npc-theory.runtime-grammar.ebnf`, `npc-theory.runtime-grammar.v2.ebnf`; `eliza-reasoning.ebnf`; `geometric-coder-mu.runtime-grammar.ebnf`; `snobol-mu.runtime-grammar.ebnf`; `wildcard-micronauts-mu.runtime-grammar.ebnf`; `tool-control-mu.runtime-grammar.ebnf` | Expert-specific reasoning, code geometry, pattern matching, wildcard capture, and tool proposal grammars. Each must bind to its own data and program before dispatch. |
| Geometry and ranking | `kuhul-pi.ebnf` | Pi comparison, radius, proximity, and routing signals feed candidate ranking; they remain bias/features until response validation and host admission. |

The versioned files coexist as authored grammar sources. Before a factory upgrades an active route, it should record the chosen version, compare productions and contracts, verify the consuming parser, and preserve older fixtures for compatibility. `program.grammar.ebnf` is the composition point; domain grammars describe typed surfaces and do not independently grant execution authority.

`tools/gml-to-aiml.py` exports graph metadata as separate lookup banks under `data/alice/graphs/`. It preserves source filename, graph label/schema, authority metadata, node attributes, and edge endpoints in data-only templates. `gml.cpp` remains the CCC4-specific 64-node/96-edge topology validator; it is not the general exporter. Large projections such as `eliza-bias.gml` and `continuation-bias.gml` produce large AIML banks, so select them explicitly when rebuilding a runtime corpus.
