# GEMMA Bridge

Status: **partial read-only implementation**. The AIML corpus, EmbeddingGemma 2 vectors, CCC₄ GML graph, v2 vector candidate route, and XCFE phases exist. `tools/encode_gemma_query.py` produces a compatible query vector from the pinned local snapshot; `semantic_bridge.cpp` retrieves aligned AIML evidence and attaches validated pilot graph evidence for rows 0–2. The pinned response policy and `micronaut_translation.cpp` validate proposals. The v3 host-admitted stdin bridge checks a host-keyed encoder attestation, replays retrieval against the pinned vector store, and can select verified plain-text templates in chat. Broader graph mapping, rich template rendering, and persistence remain open.

The key grammar field lane is generated with `python tools/key_grammar_fields.py compile`. It writes 183 keyed candidate records, Document-prompt EmbeddingGemma vectors, and source/artifact digests under `build/io/key-grammar-fields/`. The shell bus binding `key-grammar.rank` accepts `{ "name": "key-grammar.rank", "prompt": "hello", "topK": 3 }` through `POST /api/bindings/invoke` and returns ranked keys, phases, source paths, and scores. It uses the pinned host query encoder. These rankings are candidate evidence only; chat response selection and XCFE admission are separate.

The bus now has one bounded presentation response from that lane: a simple greeting can select a literal `GREETING:POP:1..3` template when its score is at least 0.80 and its text matches the canonical greeting bank. The chat trace reports the key, phase, score, and source. This host display choice does not perform a K'UHUL fold or grant XCFE execution authority. Other keys remain candidates and follow the existing Gemma/AIML path; placeholders, learned greetings, and general key grammar execution are not admitted by this operation.

An explicit control-word question such as `what does if mean` can select a ranked `control:<word>` row at score 0.75 or higher. The reply describes its source-declared syntax and operator after checking the keyed row against the control-flow JSONL file. It does not execute the operator. Run the full loopback bus test under Windows PowerShell 5.1 with `powershell.exe -NoProfile -ExecutionPolicy Bypass -File tools/test_micronaut_bus.ps1` when PowerShell 7's `HttpListener` cannot start in the host environment.
The `vector_store.cpp` domain loader, `relational_keys.cpp` binding loader, and `conversation.cpp` proposal evaluator remain read-only primitives. They do not mutate AIML rules or graph data.

## Purpose

Use EmbeddingGemma 2 as a semantic evidence lane between AIML and the graph runtime. AIML remains the source of patterns, context, and template ASTs. The embedding vectors help find and compare related records. GML gives typed graph structure and relationships. Micronauts translate selected evidence into a response proposal expressed in the key grammar. XCFE phases validate and admit the proposal before it can affect a response.

`AIML-SRAI-MICRONAUT-EXAMPLES.md` records the proposed AIML/SRAI-to-Micronaut source mapping and its phase/effect boundaries. Its source blocks are examples until the current grammar and compiler accept them and a versioned bridge/track JSON contract is validated.

EmbeddingGemma 2 supplies comparable vectors; it does not itself execute AIML templates, define GML edges, grant authority, or emit a final response. Those behaviors belong to explicit policies and micronauts.

## Existing assets

| Asset | Current role |
| --- | --- |
| `build/io/aiml-corpus.jsonl` | AIML source records and category order |
| `pattern_vectors.f32.npy` | 99,524 pattern plus `that`/`topic` context vectors, 256 dimensions |
| `template_vectors.f32.npy` | Aligned template AST vectors |
| `category_vectors.f32.npy` | Derived category midpoint vectors |
| `aiml_pattern_template_pairs.jsonl` | Row-level alignment between pattern and template lanes |
| `build/ccc4-tensor.gml` | CCC₄ tensor graph identity: 64 nodes and 96 edges |
| `build/ccc4-micronaut.gml` | Same topology with proposal-oriented micronaut node roles |
| `vector.plan.v2.candidate` | Pinned, Ch’en-checked vector computation; returns an uncommitted candidate |
| `build/io/aiml-grams/aiml-grams.v1.json.gz` | Phase-typed AIML n-gram retrieval evidence |
| `build/io/aiml-grams/aiml-relations-grams.json` and `.f32.npy` | Five declared relation-prompt families with aligned auxiliary EmbeddingGemma vectors |
| `build/io/aiml-grams/aiml-fold-pair.v1.json.gz` | Observed fold-pair counts; data-only, with no reverse evidence or selection weight |
| `build/io/aiml-grams/domain-word-tree.v1.json` | Example domain-tree contract with declared membership, association, exclusion, and wildcard patterns |
| `templates/aiml_macros.jinja` | AIML/SRAI rendering templates for separately validated manifest data |

The vector manifest declares `authority: data_only` and `semanticCommit: false`. The present v2 plan assigns rows to nodes by `row_index % 64`; this is a deterministic partition, not a learned semantic assignment. Current chat generation remains in the AIML/chat path and does not consume the v2 candidate.
The neuron, tensor, and micronaut GML files share CCC₄ topology but declare different node roles and bindings. Their common topology does not make AIML grams, word domains, or response templates executable graph edges.

The first bridge primitive is `semantic_bridge::retrieve(root, query, top_k)` in `semantic_bridge.cpp`. It accepts a host-supplied finite 256-value vector, checks the bound pattern and template artifacts and pair-record digest, ranks pattern rows by cosine similarity with stable row-ID tie breaks, then emits aligned template evidence and separate scores. It does not encode text, execute templates, or select a response. Build and run `test_semantic_bridge` to check aligned retrieval and zero-vector rejection.
The pilot graph binding now adds GML node meaning for AIML rows 0–2 only. `relational_graph.cpp` validates the pinned graph, JSONL keys, source pair records, node identities, and `has_template` edges before annotating retrieved hits. Other rows carry empty graph bindings and no graph evidence. This pilot is separate from the CCC₄ tensor topology.

`python tools/encode_gemma_query.py "WHAT IS AI" --output build/query.npy` encodes a new query with the manifest-pinned cached EmbeddingGemma 2 snapshot in offline CPU mode. It uses the snapshot's `Retrieval-query` prompt, truncates to 256 dimensions, applies a final float32 L2 normalization, and writes a `.npy` vector plus a JSON sidecar containing model, prompt, manifest, shape, and vector digests. The corpus uses the `Document` prompt; this query/document pairing is intentional for retrieval. `python tools/test_gemma_query_encoder.py` checks the output contract and confirms that the existing AIML row for “WHAT IS AI” ranks in the top 10. `tools/attest_gemma_query.py` calls that encoder and emits a host-keyed HMAC over the utterance, float32 vector digest, and manifest digest. The v3 C++ bridge verifies this proof before replaying retrieval. The host must keep `MICRONAUT_GEMMA_ATTEST_KEY` available only to the trusted encoder and daemon; an arbitrary caller with that key could sign a different vector.

`tools/gemma_bridge_host.ps1` is the explicit Windows host launch path. It requires one `MICRONAUT_GEMMA_ATTEST_KEY` entry in the ignored workspace `.env`, validates the 64-character hex key, and sets it only for the attestor or daemon child process. Daemon mode also sets `MICRONAUT_GEMMA_BRIDGE=1`; the parent environment is restored afterward. For example, run `pwsh -NoProfile -File tools/gemma_bridge_host.ps1 -Mode Attest -Utterance "WHO CREATED AIML"` to produce an attested query, then `pwsh -NoProfile -File tools/gemma_bridge_host.ps1 -Mode Daemon -RequestFile build/request.jsonl` to serve local JSONL requests. `python tools/test_gemma_bridge_host.py` verifies the real encoder, both launch modes, and tamper rejection without inheriting either variable from its parent.

`Micronaut.ps1` is the WPF shell (`pwsh -STA -File .\Micronaut.ps1`). Its left sidebar contains navigation, chat history, and a bottom profile card. The UI starts `shell/Server.psm1` in a background thread and talks to its loopback REST bus on port 9880. `POST /api/chat` calls the host attestor, `gemma_bridge_request_cli` for pinned C++ retrieval, and the host daemon launcher for verified response selection; `GET /api/sessions` and `GET /api/history` back the sidebar. `GET /api/bindings` discovers the existing shell modules, `POST /api/bindings/refresh` rescans them, and `POST /api/bindings/invoke` calls only host-registered handlers (currently Gemma and Vector identities). Chat history lives in bus memory and is cleared when the UI-owned bus stops; it is outside the deferred persistence contract. `pwsh -NoProfile -File tools/test_micronaut_bus.ps1` exercises the bus, bindings, history, and real chat path. `pwsh -STA -File tools/test_micronaut_ui.ps1` checks PowerShell syntax and WPF XAML loading.

## Bridge flow

1. **Bind input.** Normalize the user's utterance and capture session context (`that`, `topic`, and any explicitly available state). Encode the query with the same model snapshot, prompt convention, 256-dimensional truncation, and normalization used for the AIML vectors. Reject a mismatched model or vector contract.
2. **Retrieve AIML evidence.** Search the pattern/context lane and keep stable AIML row IDs. Join each hit to its template AST and pair record. Score query-to-pattern, query-to-template, and pattern-to-template relationships separately; retain the underlying scores and source identities.
3. **Map graph relativity.** Bind selected rows to typed GML nodes through a versioned semantic mapping policy. Edge traversal may contribute neighborhood evidence or constraints. The bridge must not treat proximity in vector space or a modulo-64 node assignment as proof of an AIML relation or GML edge.
4. **Apply response policy.** Choose among an exact AIML match, a semantically retrieved existing template, or a proposed new pattern/template. Policy thresholds, tie breaks, context handling, and fallback order must be named and versioned.
5. **Translate with micronauts.** A translator micronaut emits a typed key-grammar proposal. Specialized micronauts can check AIML AST validity, variable bindings, graph references, response form, and provenance. A newly synthesized pattern/template remains a proposal until independently validated and admitted.
6. **Verify and emit.** Pop/Wo/Yax bind inputs and authority; Sek computes candidates; Ch’en checks source alignment, policy conformance, grammar, and evidence; Xul emits the approved response. Any write to AIML, graph state, or a checkpoint uses a separate versioned commit contract.

## Semantic proposal envelope

The bridge should pass a typed record between micronauts rather than a bare text answer. A first contract can use `schema: "gemma.bridge.proposal.v1"` with these required fields:

| Field | Meaning |
| --- | --- |
| `request_id`, `session_id` | Correlate the proposal with one input and session |
| `model_snapshot`, `embedding_contract_hash` | Identify the encoder and vector preparation rules |
| `aiml_source_sha256`, `vector_manifest_sha256` | Bind the proposal to source data |
| `row_ids` | Ordered AIML evidence rows, never inferred from vector position alone |
| `scores` | Named query, pattern, template, and graph relationship scores |
| `graph_contract_hash`, `graph_bindings` | Identify the GML graph and typed node assignments |
| `response_policy_id`, `response_policy_hash` | Identify decision and fallback semantics |
| `mode` | `exact_aiml`, `retrieved_template`, or `new_proposal` |
| `key_grammar_proposal` | Typed translator output with AIML/graph references |
| `verification` | Ch’en checks and their evidence; absent until verified |

Scores are evidence, not permission. `new_proposal` must not silently add AIML categories, alter graph edges, or persist vectors. The response policy can use a retrieved template only after checking its AIML AST and context bindings; if no candidate passes, it falls back to the existing AIML response path.

## Graph choice

The CCC₄ topology can host multiple typed lanes when they share meaningful node identities. Pattern, template, category, and response proposal lanes can coexist under separate binding and operator contracts. If response relationships require different nodes or edges, define a separate response GML graph and an explicit bridge between graph identities. The current CCC₄ edges and modulo-64 grouping do not yet encode response semantics.

## Domain stores and relational vector graphs

The bridge can serve more than the AIML corpus. Each domain store should retain its source JSONL records, stable record IDs, embedding model and preprocessing contract, vector arrays or index, and provenance digests. A store can have its own GML graph when its records contain relationships worth traversing or checking. A graph is optional for a store that only needs retrieval.

| Layer | Role | Example |
| --- | --- | --- |
| JSONL source and vector store | Preserve facts, text, embeddings, row IDs, and provenance | A chemistry record and its embedding |
| AIML pattern/template and SRAI | Provide conversational triggers, responses, and redirects where useful | “What is water?” maps to an approved template |
| GML relational graph | Represent typed entities and evidence-backed edges | `compound:H2O` `contains` `element:O` |

Coding, chemistry, physics, and astronomy stores may use different graph schemas and edge types. A coding graph might connect symbols to definitions and calls; a chemistry graph might connect compounds, elements, and reactions; a physics graph might connect quantities, units, and equations; an astronomy graph might connect objects, observations, and classifications. These are domain contracts, not automatic consequences of embedding proximity.

Every vector row and graph entity needs an explicit relational key, such as `{store_id, record_id, entity_id, relation_type}`. A binding record should map source IDs to vector rows and graph node IDs, identify the schema and model snapshot, and carry source and artifact digests. One source record may support several graph entities or edges; one graph entity may cite several records. Do not require a one-row-to-one-node mapping.

A relational vector query can combine semantic nearest neighbors with graph traversal: retrieve candidate rows, resolve their relational keys, follow only typed edges admitted by the domain schema, and return scores alongside source and edge evidence. Similarity can propose a missing edge or new AIML rule, but Ch’en validation and a separate versioned commit contract are required before either becomes durable. SRAI can route conversational intent to a domain or approved pattern; it should not be the sole representation of scientific or code relationships.

The first mapping is `build/aiml-relational-pilot/graph.gml`, with six typed nodes and three `has_template` edges for AIML rows 0, 1, and 2. Its manifest pins graph, key, and pair-record digests; `keys.jsonl` maps each source row to its pattern and template nodes. The edge evidence is the existing aligned AIML pair record. The bridge annotates a hit only when its retrieved pattern/template text matches that evidence. This graph does not make a claim about all 99,524 AIML rows or about the CCC₄ graph's 96 edges.
This pilot is a binding test fixture. A broader bridge should use the existing phase-typed gram index and relation-prompt vectors as retrieval evidence, and should bind declared domain relations through explicit keys. The relation-prompt records are `embedding_only`; their prompts do not assert ownership, identity, location, state, or time facts. The fold-pair observation is also data-only and has no selection weight.

`domain-word-tree.v1.json` is an example of a domain-tree schema and seed, not a literal vocabulary that every store must adopt. A field becomes operational only under an admitted, versioned operation-key contract. Its `⟁VEHICLE:*` wildcard captures a possible member with inherited level 1; a wildcard match remains a candidate and does not create declared membership or a durable graph edge.

## Pattern banks as response fields

The supplied `kuhul.xaiml.pattern-bank.v1` **car semantic field** is a different kind of field from a domain tree. It is a pattern-match and response-presentation bank. `WHAT IS CAR` selects a template AST; `WHAT IS A CAR` and `CAR FIELD REPLAY` redirect through SRAI. The other patterns expose field coordinates such as identity, gradient, bias, topology, sensory, temporal, spatial, and operational. Those coordinate names can be operation keys when a versioned runtime contract binds them; their text is not automatically graph truth.

The supplied **Eliza reasoning control board** is another pattern-bank class with `authority: reasoning_route_candidate_only`. Pop patterns capture reasoning slots and route via SRAI to Yax terminal patterns for operators such as DEPENDENCY, CAUSE, DEFINE, COMPARE, EVIDENCE, and INFER. Its declared recursion depth is 4, cycle policy is active-pattern-path detection, and evidence budget is 8. Terminal text reports that a proposal is ready; it does not establish a dependency, cause, definition, or inference. The board needs its own pinned routing policy and validator for slot counts, terminal IDs, route templates, π-route identifiers, recursion, and evidence budgets before a REASON-µ dispatcher can consume it. It must not be admitted under the existing-template response policy.

The supplied `⟁KUHUL` bank is `pattern_match_only` with exact explanatory templates. It is a candidate response field, not a vector-store mapping or a graph edge. Its `field_source` path needs source identity and schema validation before admission; it is not part of the current AIML existing-template policy.

`data/intent-graph.gml` already contains Yax `bigram_candidate` nodes such as `⟁CAR|⟁AUTOMOBILE`, with explicit `left`, `right`, and `proposal_only` authority. These nodes can seed relational questions or scoring, but are not verified relation facts. The current graph has a node-level `phase`, not `phaseL`/`phaseR`. A future version may record each operand's phase provenance separately while retaining the candidate node's Yax phase. `foldl` and `foldr` name left- and right-associative reductions; the AIML fold-pair artifact's reverse matrix is only a transpose of its forward observations and is not independent `foldr` evidence.

For a list `[a,b,c]` and initial value `z`, `foldl f z` evaluates `f(f(f(z,a),b),c)`, carrying an accumulator from the left. `foldr f z` evaluates `f(a,f(b,f(c,z)))`, replacing list constructors from the right. Both reduce many inputs to one result. They can differ when `f` is non-associative: subtraction over `[1,2,3]` with `z=0` yields `-6` for `foldl` and `2` for `foldr`. In a lazy language, `foldr` can also produce a prefix without consuming an entire list when `f` does not demand its second argument. The bridge must declare the reducer, input order, initial value, associativity direction, and evaluation assumptions before using either fold. Operand fields named `phaseL` and `phaseR` would record where the left and right values came from; they would not choose `foldl` or `foldr` by themselves.

The example's `authority: pattern_match_only` means matching and template selection are allowed as data operations. A Pop request may bind `mood`, `preference`, and `temperature_bucket` from panel state. The renderer then evaluates `condition` branches, `think`/`set`/`get` session values, and `random` option lists under a separate response policy. Temperature controls the size of the eligible option set (low 1, mid 2, high 4); it does not authorize model temperature sampling, graph mutation, or learning. Icons come from lane metadata at render time, not from embedding similarity.

This pattern bank can consume a verified Gemma Bridge proposal as its **field selector**: vector retrieval suggests `⟁CAR`, relational keys identify the applicable field, and the pattern bank chooses the matching AST. Ch’en must verify the selected field identity, Pop predicates, branch path, SRAI depth/cycle bounds, option count, and rendering contract before Xul emits text. A matched pattern or selected wording does not establish domain membership, a GML edge, or factual correctness. The car response text is illustrative; claims about fuel type or legal requirements need source and context validation before use in a factual response.

The full car example was supplied in conversation; `car-field.json` and a local pattern-bank artifact were not present in this workspace when this section was written. The bridge therefore documents the contract shape without treating the example as an installed runtime route.

The first domain loader accepts `gemma.bridge.domain-store.v1` manifests with local `source_file` and `vector_file` names, SHA-256 digests, model snapshot, float32 shape, and `data_only` authority. The relational-key loader accepts `gemma.bridge.relational-key.v1` JSONL records and checks store ID, vector-row bounds, graph contract hash, graph-node bounds, and duplicate bindings. The conversation evaluator accepts a retrieval envelope and proposes `exact_aiml`, `retrieved_template`, or `fallback` using explicit score and margin thresholds. Its template AST is evidence for later validation; it is not rendered or emitted as a chat response. `test_domain_bridge` covers these primitives with a small synthetic store.

The existing-template response rules are pinned in `build/gemma-response-policy.v1.json` (`gemma.bridge.response-policy.v1`). `conversation::load_policy` verifies the file digest and contract fields; `conversation::propose` verifies source identity, unique and sorted finite retrieval scores, exact pattern/that/topic matching, semantic minimum score, top-two margin, and fallback routing. Exact matches win before semantic scoring, with lowest row ID as the tie break. Output includes policy ID/hash, decision evidence, and `emit: false`. Chat selection uses the separate v3 host admission and Ch’en replay gate.

`store_write.cpp` writes a separate `gemma.bridge.vector-shards.v1` store from a float32 `.npy` matrix. Its CLI takes source, new output directory, store ID, model ID, and rows per shard. It emits contiguous row-range `.npy` slices, a source digest, per-shard digests, and a manifest published after all slices are written. The writer refuses an existing output directory. `--verify` checks source identity, shard ranges and shapes, digests, and every payload byte against the source. `python tools/test_store_write.py` checks uneven slices, exact reassembly, overwrite refusal, and tamper detection. This is a data-store writer; it does not write model weights or training checkpoints.

## First implementation slice

1. Define and test the query embedding contract against the pinned AIML vector manifest.
2. Build deterministic top-k retrieval with row IDs, pair alignment, and explicit score fields.
3. Add a read-only `gemma.bridge.propose` route that emits the proposal envelope for existing AIML templates only.
4. Add a versioned semantic node mapping and response policy; test exact AIML, retrieved-template, ambiguity, and fallback cases.
5. Add key-grammar translation for `new_proposal`, with independent Ch’en validation before any response use.
6. Specify separate versioned commit contracts before persisting new AIML records, GML bindings, or vector checkpoints.

The first slice should demonstrate that vector evidence changes a response choice in a traceable way while preserving the original AIML row and template provenance. It should not rely on the present modulo-64 fold as a semantic label.

## Task list

### Contracts and input binding

- [ ] Define `gemma.bridge.proposal.v1` as a machine-validated schema with required identities, score fields, graph bindings, mode, and verification status.
- [x] Pin the query encoder snapshot, query prompt, 256-dimensional truncation, dtype, and normalization to the existing vector manifest in the offline encoder command.
- [ ] Define input normalization and session-context binding for utterance, `that`, and `topic`.
- [ ] Reject a query or artifact when its model, manifest, source, shape, or digest differs from the pinned contract.

### Retrieval and graph evidence

- [x] Implement deterministic top-k search over the AIML pattern/context vectors with stable row IDs and tie breaks in the read-only `semantic_bridge::retrieve` primitive.
- [x] Join every retrieved row to its template AST and pair record; verify row alignment before scoring.
- [x] Compute and record separate query–pattern, query–template, and pattern–template scores.
- [ ] Define a versioned semantic mapping from AIML rows to typed GML nodes, with a documented rule for unbound rows.
- [ ] Add graph-neighborhood evidence only after validating GML identity and node bindings; keep vector similarity distinct from graph edges.
- [ ] Bind the existing AIML gram phase lanes and relation-prompt vector rows into retrieval evidence without promoting prompts to facts.
- [ ] Define an operation-key contract for domain-tree membership, association, exclusion, and wildcard capture; keep example labels as data.
- [x] Define a first domain-store manifest and loader for source/vector files, model snapshot, shape, and provenance digests. Encoder preprocessing and graph identity still need their own versioned fields.
- [x] Define typed relational keys with many-to-many row/entity bindings and checks for row bounds, node bounds, graph hash, and duplicate keys. Source-record existence and edge evidence checks remain open.
- [x] Add an AIML domain pilot with a small evidence-backed GML `has_template` relation schema for rows 0–2.
- [x] Test vector retrieval followed by keyed graph-edge attachment, including an unbound retrieved row and tampered text. Multi-hop traversal remains open.
- [x] Add a data-only vector shard writer with row ranges, source/model IDs, digests, and exact reassembly verification.

### Response policy and micronauts

- [x] Specify and validate a pinned v1 existing-template policy for exact AIML, retrieved template, ambiguous results, and fallback.
- [x] Add a read-only conversation proposal evaluator for exact literal matches, score-and-margin retrieval, ambiguity, and fallback under the pinned v1 policy.
- [x] Add a local stdin `gemma.bridge.propose` route behind the pinned `gemma-chat-admission.v3.json` host contract and `MICRONAUT_GEMMA_BRIDGE=1`. It requires a 256-value query vector, host encoder attestation, `top_k`, and a retrieval envelope, recomputes the complete retrieval from the pinned store, and returns verified provenance and selection metadata without text or state changes. Earlier v1/v2 admission files are retained as history and are no longer active.
- [x] Add an explicit `.env` host launcher for the offline attestor and daemon; verify that the parent process need not set or retain the bridge key or gate.
- [x] Add the WPF history/navigation sidebar and the loopback PowerShell REST bus with a production retrieval-request CLI and read-only binding registry.
- [x] Add a read-only C++ translator that emits a typed existing-template proposal after independent Ch’en policy replay. It never emits text or changes state.
- [x] Validate the bounded AIML template AST subset, `set`/`get`/`bot` names, glyph token syntax, selected-row pattern/that/topic/template provenance, graph bindings, and exact/semantic/fallback outcomes. Unrecognized tags and malformed structures fail closed. Full template-variable scope and `new_proposal` grammar remain open.
- [ ] Permit a new pattern/template only as a `new_proposal` until separate admission succeeds.
- [ ] Define when a domain record should become an AIML pattern/template or SRAI redirect, and retain a direct retrieval path for records that do not need conversational rules.
- [ ] Define and validate `kuhul.xaiml.pattern-bank.v1` operation keys, template AST tags, SRAI redirects, and panel-predicate bindings independently of domain-tree and GML authority.
- [ ] Add a response-field selector that binds verified retrieval/graph evidence to a pattern bank without granting graph or learning authority.
- [ ] Define deterministic or recorded `random` selection and temperature-bucket option counts; test mood, preference, fallback branches, and SRAI cycle limits.
- [ ] Define a separate `reasoning_route_candidate_only` policy for the Eliza reasoning control board, including slot/terminal matching, depth 4, active-path cycle rejection, and evidence budget 8.
- [ ] Version operand `phaseL`/`phaseR` provenance for intent-graph bigram candidates, if needed, and define any foldl/foldr operation separately from fold-pair matrix orientation.

### Verification and integration

- [x] Define Ch’en checks for row provenance, complete top-k score reproducibility, policy outcome, graph binding, translator output, and host-keyed query attestation. The proof binds utterance, vector bytes, and pinned encoder manifest; its authority depends on host key custody.
- [x] Test exact-match and semantic selection, score tampering, nonfinite and malformed query vectors, ambiguity, no-hit fallback, invalid AST, mismatched digests, host-gate denial, and tampered encoder proofs. An empty supplied retrieval is rejected by v3 replay because a valid top-k query returns at least one row; the policy's no-hit fallback is tested independently.
- [x] Integrate verified exact-match and semantic plain-text templates into `chat.generate` selection under the v3 host gate. The AIML session records the selected response so later `<that>` matching sees it. Rich ASTs, ambiguity, and fallback use the existing AIML renderer. The chat route accepts bridge evidence on local stdin only; HTTP remains on the existing AIML path.
- [x] Return the selected row, policy decision, graph bindings, retrieval verification, source and admission digests in the bridge trace.

### MATH-µ and VECTOR-µ chat selection

The REST chat bus selects `MATH-µ` for bounded numeric expressions before vector retrieval. `shell/MathML.psm1` compiles the expression to Content MathML and evaluates its typed AST under `build/mathml-host-admission.v1.json`, which pins the three MathML grammars. For example, `What is 5*25=` returns `5*25 = 125` with a `<times/>` node and `ARITHMETIC:local_eval · TRACK:MATH-µ` trace. Symbolic or unrecognized expressions continue to the Gemma bridge. `tools/test_mathml.ps1` checks arithmetic precedence, symbolic handling, and invalid input.

`build/io/aiml-embeddinggemma2-vectors/aiml_pattern_template_pairs.jsonl` is already AIML JSONL. It aligns each pattern and template with a vector row and similarity metadata; converting that file again would not provide arithmetic evaluation.

`VECTOR-µ` has an explicit extended response mode, `vector_extended_v1`, pinned by `build/vector-response-admission.v1.json`. The REST bus accepts `responseMode: "vector_extended_v1"`; the WPF chat accepts `/vector <question>`. The mode requires the existing host-attested query, exact retrieval replay, verified response policy, plain-text selected template, and both validated pattern and template graph bindings. It appends the source AIML pattern and a typed `⟁AIML_ROW_<id>` key to the selected answer and returns the row, score, and graph bindings in `vector_response` trace data. When these prerequisites are absent, the bridge keeps its existing selection. This first contract covers only the three mapped pilot rows; it does not synthesize facts from unrelated nearest neighbors or create new graph edges. The native route and daemon chat tests cover this mode.

The bus now handles a verified retrieval miss under `build/gemma-rank-fallback.v1.json`. It requires successful host query attestation, exact retrieval replay, and a verified fallback policy outcome before returning `gemma_mu_no_verified_answer` with `track: GEMMA-µ`. This replaces generic AIML filler at the UI boundary. EmbeddingGemma 2 is a ranker, so this route reports that no answer was verified; it does not generate a factual answer. For `what is organics`, the live top score was about 0.795, below the pinned 0.85 semantic threshold. `tools/test_gemma_rank_fallback.ps1` checks the handoff and rejects unverified evidence.

### Persistence, separately versioned

- **Deferred by request.** The current bridge is read-only; `gemma.bridge.propose` and `chat.generate` do not commit AIML rules, graph bindings, or vectors. Persistence requires its own versioned admission and recovery contract before implementation.
- [ ] Define a commit contract for newly admitted AIML patterns/templates and graph bindings with generation checks and recovery rules.
- [ ] Keep vector checkpoint persistence under its separate `ccc4.vector-checkpoint.v1` contract; test atomic writes and digest validation before enabling it.
