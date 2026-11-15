# SEMANTICS.md

Relational semantics for the `RELATIONAL` book: what a node means, what an edge
means, what phase each is allowed to occupy, and what the whole network is
forbidden to claim.

This document describes `data/grammar/kuhul-relational.key-grammar.jsonl` and the
artifacts it is compiled from and rendered to. Sections 1–11 document that
relational book. Sections 12–14 record the adjacent runtime semantics for CFPC,
projection, and W-C-V attention. Every measured count is read from generated
artifacts; it is not inferred from intent.

## 1. What the book contains

| artifact | role | size |
|---|---|---|
| `kuhul-relational-graph.xml` | source of truth | 12 nodes, 24 edges, 6 verbs |
| `kuhul-relational.key-grammar.jsonl` | compiled projection | 37 rows (13 node + 24 edge) |
| `kuhul-relational.xsl`, `.sdm.xml`, `.sdm.css` | structural rendering projection | SDM graph |
| `data/manifest/relational.manifest.json` | index and boundary | 24 rows of book keys |

The 37 rows are not 37 things. There are **12 distinct micronaut ids** and 13
node rows, because one micronaut appears twice — see section 3.

## 2. Two units, and only two

Every row has `unit: relational_node` or `unit: relational_edge`. Nothing else
lives in this book.

**Node** — `relational` carries `id`, `category`, `kind` (`micronaut_instance`),
`cluster`, `occurrence_id`, `parent`.

```
RELATIONAL:NODE:0:ORCH-µ    category=executive  cluster=true
RELATIONAL:NODE:9:NET-µ     category=cognitive  cluster=false
```

The five categories and their counts:

```
cognitive   5   REASON-µ ×2, CODE-µ, NET-µ, INFER-µ
executive   2   ORCH-µ, PLAN-µ
creative    2   CREATE-µ, GRAPHICS-µ
storage     2   MEM-µ, FILE-µ
structural  2   MORPHISM-µ, FIXED-POINT-µ
```

**Edge** — `relational` carries `from`, `to`, `verb`, `directed`, `isLink`,
`kind` (`relational_verb`), `parent`.

```
RELATIONAL:EDGE:3:ORCH-µ:@delegate:REASON-µ
  from=ORCH-µ  to=REASON-µ  verb=@delegate  directed=true
```

The row key is the address: `RELATIONAL:EDGE:<index>:<from>:<verb>:<to>`. Node
keys are `RELATIONAL:NODE:<index>:<id>`.

`kuhul-relational.xsl` and the Python renderer emit
`<sdm><graph ...>...</graph></sdm>`. Graph identity (`id`, `name`, `role`,
`phase`, `version`, `provenance`) stays on each graph element. Node `type` is
copied when declared and defaults to `micronaut`; `category` is omitted when
absent. Node and edge phase/provenance metadata is preserved. Explicit edge
`verb` wins; otherwise `directed="false"` or `"0"` maps to `@relate`, and other
values map to `@call`; `directed` is emitted only when authored. Text is
stripped. Unknown element subtrees are omitted by the XSLT's closed element set.

The XSLT serializes typed `Pattern`, `Capability`, `CorpusBinding`, `Bridge`,
and `Requirement` records as `<record kind="...">`, preserving their declared
contract fields. It does not validate them, evaluate eligibility in the 1.0
variant, score utility, enforce XCFE legality, or grant admission. The optional
`kuhul-relational-3.0.xsl` computes eligibility diagnostics only; every result
is marked `*-evaluated` and `admission="not-evaluated"`. Neither transform
issues a legal verdict or authorizes execution.

The source/expected fixtures are in `kuhul-relational.xsl.fixtures.json` and
`kuhul-relational-3.0.fixtures.json`. Run the XSLT 1.0 fixtures with
`python tools/check_kuhul_relational_xsl.py` (lxml); the evaluation fixtures
use `python tools/check_kuhul_relational_xslt3.py` (SaxonC `saxonche` plus lxml).

## 3. Occurrence, not identity

`REASON-µ` has two node rows. That is correct, not a duplicate.

In the source XML, `ORCH-µ` is a node that contains a nested `<graph>` — a
cluster — holding `REASON-µ`, `CREATE-µ`, `PLAN-µ` and three edges. Those same
micronauts also appear at top level. So the network contains `REASON-µ` once
*inside* the ORCH cluster and once *outside* it.

`relational.occurrence_id` separates them, and it is unique across all thirteen
node rows. The format is `<parent>::<id>::<ordinal>`, so the two REASON-µ rows
read:

```
root::REASON-µ::1        top level
ORCH-µ::REASON-µ::0      inside the ORCH cluster
```

`relational.id` does not distinguish them. Any code that keys a lookup on `id`
alone will silently collapse the two occurrences and lose the cluster. The
trailing ordinal means the scheme can express a third occurrence without
renumbering the first two.

`cluster=true` appears on exactly one node: `ORCH-µ`.

## 4. The six verbs

Counted from the 24 edge rows:

```
@call      12
@eval       3
@delegate   3
@informs    3
@compose    2
@relate     1
```

What each connects, as recorded:

**`@delegate`** — the orchestrator hands work to a specialist. All three have
`ORCH-µ` as source and `REASON-µ`, `CREATE-µ`, `PLAN-µ` as targets. This is the
only verb whose source is the cluster node, which is what makes `ORCH-µ` the
root.

**`@call`** — one micronaut invokes another's capability. Twelve edges, e.g.
`REASON-µ → MEM-µ`, `REASON-µ → CODE-µ`, `REASON-µ → INFER-µ`, `PLAN-µ →
REASON-µ`, `MEM-µ → FILE-µ`, `NET-µ → FILE-µ`. The dominant verb, and the one
that makes the network a call graph rather than a taxonomy.

**`@eval`** — a producer routes through a reasoning target. Three edges, each
ending at `REASON-µ`: `CREATE-µ → REASON-µ`, `CODE-µ → REASON-µ`, `GRAPHICS-µ
→ REASON-µ`.

**`@compose`** — `CREATE-µ` assembles a concrete artifact kind: `CREATE-µ →
GRAPHICS-µ`, `CREATE-µ → CODE-µ`.

**`@informs`** — a proof-theoretic chain, and the only cycle in the network:
`REASON-µ → MORPHISM-µ → FIXED-POINT-µ → MORPHISM-µ`. This is the structural
pair's whole connection to the rest; without it `MORPHISM-µ` and
`FIXED-POINT-µ` would be unreachable.

**`@relate`** — one edge, and the only undirected one: `MEM-µ ↔ FILE-µ`
(`directed=false`). Every other edge in the book is directed.

## 5. Phase placement

The `grammar_phases` field differs by unit, and the difference is the semantics:

```
node rows (13)   Pop  Wo  Yax  Sek
edge rows (24)   Wo   Yax  Sek  Ch'en
```

Nodes are observable from `Pop`; edges are bound from `Wo` and evaluated through
`Ch'en`. No row of either kind reaches `Xul`. That is consistent with the
declared boundary in section 6 — this book can describe, verify and re-render an
execution plan, and it cannot commit one.

## 6. Authority boundary

From `relational:authority-boundary` in the manifest:

```
rendering_projection_only
execution_plan_projection_only
not_semantic_truth
not_Ch'en_verification
not_Xul_persistence
```

Read plainly: the network is a *plan diagram*. `ORCH-µ @delegate REASON-µ` says
the plan routes work that way; it does not assert that delegation happened, that
it was verified, or that anything persisted. The `Ch'en` phase on edge rows is
where such a claim *would* be evaluated, not where it is made.

`relational:tensor-slot-law` adds the same caution at the node level:
`every_micronaut_node_has_tensor_slot`, `tensor_slot_is_projection_not_authority`,
`private_STB_binding_requires_evidence`. A node carrying a tensor slot is not a
node carrying a proof.

## 7. Vocabulary boundary — this matters downstream

The six verbs here are **not** the canonical `relation_verb` set in
`gml.khanary.ebnf`. They are not misspellings of it either; they are a separate
vocabulary with different arity and different intent:

```
this book        GML relation_verb        relationship
@call        vs  @calls                   same intent, singular vs plural
@delegate    vs  @delegates_to            same intent, verb vs gerund
@relate      vs  @related_to              overlaps, but GML's is the broader one
@eval        —   no counterpart
@compose     —   no counterpart
@informs     —   no counterpart
```

Consequences, stated plainly:

- `data/alice/relation-verbs.aiml` — the AIML surface for `@delegates_to`,
  `@calls`, `@relate` and the rest — **cannot answer these edges**. The surface
  redirects on the GML spelling; the graph is written in this book's spelling.
- `data/templates/declarative-realization.templates.json` has no template for
  any of these six verbs, so `document_linearizer` declines all 24 edges.
- The three unmatched verbs (`@eval`, `@compose`, `@informs`) carry no canonical
  meaning anywhere in the kit. They are only meaningful in this book.

Reconciling the two vocabularies is a decision, not a cleanup: either this book
adopts canonical spellings (`@call` → `@calls`, `@delegate` → `@delegates_to`)
and the three extras get added to `relation_verb`, or the canonical surface
gains aliases for this book's spellings. Either way the change belongs in the
grammar first, then the manifest, then the templates — in that order.

## 8. Known drift between the artifacts

Three disagreements exist today and none is enforced by a checker:

**Verb count.** The source XML contains six verbs including `@informs`. The
manifest's `relational:edge-verbs` lists five:

```
@call  @compose  @delegate  @eval  @relate        <- manifest
@call  @compose  @delegate  @eval  @informs  @relate   <- XML and JSONL
```

So the three `@informs` edges are in the graph and outside the index.

**Node count.** `relational:micronaut-network` lists ten ids. The XML and JSONL
carry twelve:

```
missing from manifest: MORPHISM-µ, FIXED-POINT-µ
```

Those are exactly the two nodes reachable only through the `@informs` chain, so
the same omission removes both the nodes and the verb that reaches them.

**Occurrence collapse.** The manifest indexes micronauts by id, so it cannot
express the two `REASON-µ` occurrences at all.

## 9. Provenance chain

```
kuhul-relational-graph.xml          authored graph
        |
        v
kuhul-relational.key-grammar.jsonl  compiled rows
        |                            lexicon_source -> the xml
        |                            provenance     -> relational_graph_compile.node
        v
gram_channels per row               unigram, bigram, trigram, quadgram,
                                    coarse_gram, tool_gram
        |
        v
relational.manifest.json            book index + authority boundary
        |
        v
kuhul-relational.xsl + .sdm.css     rendered SDM graph
```

Every row carries all six n-gram channels **except** the five `@eval` and
`@compose` edges, which carry five and omit `tool_gram`. That is a consistent
rule, not noise: those two verbs describe composition and evaluation, which are
not tool-shaped. `coarse_gram` appears on all 37 rows with
`role: structural_shape` — 266 entries in total.

## 10. Reading a row

```json
{
  "key": "RELATIONAL:EDGE:5:ORCH-µ:@delegate:PLAN-µ",
  "word": "ORCH-µ @delegate PLAN-µ",
  "book": "Book(RELATIONAL)",
  "unit": "relational_edge",
  "grammar_phases": ["Wo", "Yax", "Sek", "Ch'en"],
  "lexicon_source": "data/grammar/kuhul-relational-graph.xml",
  "provenance": "relational_graph_compile.node",
  "relational": {
    "directed": true, "from": "ORCH-µ", "isLink": true,
    "kind": "relational_verb", "parent": "ORCH-µ",
    "to": "PLAN-µ", "verb": "@delegate"
  },
  "gram_channels": { "unigram": [...], "bigram": [...], "trigram": [...],
                     "quadgram": [...], "coarse_gram": [...], "tool_gram": [...] }
}
```

`word` is the surface form: `from`, verb, `to`, space-separated, uppercase verb.
It is what the gram channels are built from, and it is not a sentence — the verb
is a symbol, not an inflection.

## 11. Invariants worth enforcing

Not currently checked, listed here as the specification for a checker:

1. Every verb in the JSONL appears in `relational:edge-verbs`.
2. Every node id in the JSONL appears in `relational:micronaut-network`.
3. `occurrence_id` is unique across node rows.
4. Edge rows have `grammar_phases == [Wo, Yax, Sek, Ch'en]`; node rows have
   `[Pop, Wo, Yax, Sek]`; no row reaches `Xul`.
5. Exactly one node has `cluster=true`, and it is the source of every `@delegate`
   edge.
6. `tool_gram` is absent exactly on `@eval` and `@compose` edges.
7. `directed=false` appears on at most the `@relate` edges.
8. Every `lexicon_source` resolves to a file that exists.
9. No row claims `semantic_authority`, `commit`, or `verified_outcome`.

Invariants 1 and 2 fail today. The other seven hold as written: `occurrence_id` is unique across all 13 node rows, and no row carries an authority token.

## 12. CFPC context-field classification

CFPC means **Context-Field Pattern Classifier**. The local contract is
`data/tracks/CFPC-u.semantic-tracks.v1.json`; its `@no-eval` declaration and
the runtime classifier define deterministic classification, not model
inference. CFPC classifies a question before selecting a response route.

The stages have distinct responsibilities:

```text
Pop    recognize intent and read context
Wo     bind the intent and candidate context
Yax    classify the context bitmap and identify gaps
Sek    select the route associated with the gap
Ch'en  verify the classification structure
Xul    close the local classification record
```

The gap bitmap distinguishes these states:

| gap type | meaning | route |
|---|---|---|
| `RESOLVED` | intent, query/subject, candidate keys, and candidate values are present | no gap route |
| `INTENT_GAP` | no supported intent was recognized | `disambiguation` |
| `QUERY_GAP` | the query is incomplete or has no supported pattern | `pattern_discovery` |
| `KNOWLEDGE_GAP_NO_KEYS` | no candidate context keys are available | `retrieval` |
| `KNOWLEDGE_GAP_NO_VALUES` | keys exist but candidate values are absent | `evidence_resolution` |

`RESOLVED` means only that the required fields are populated for routing. It
does **not** mean the candidate value is correct, verified, or admitted as
knowledge. Gap routes are next-step proposals; they do not authorize tools,
model calls, writes, or execution. Host policy and XCFE remain authoritative.

The deterministic implementation is `micronaut/cfpc_classifier.py`. Its batch
projection over `neighborhood.attention.jsonl` is
`.micronaut/checkpoints/neighborhood-attention.cfpc.jsonl`, with one row per
generated question. In the current 8,373-row projection, 2,990 rows are
`RESOLVED`, 5,305 are `QUERY_GAP`, and 78 are `INTENT_GAP`. No row is labeled
fact-verified: every row has `epistemic_state: UNKNOWN` and
`candidate_status: candidate_relevance_only`. The current source has usable
candidate keys and values, so it produces no `KNOWLEDGE_GAP_NO_KEYS` or
`KNOWLEDGE_GAP_NO_VALUES` rows. Counts describe this generated projection and
are not stable contract constants. CFPC's semantic track is
`data/tracks/CFPC-u.semantic-tracks.v1.json`; its AIML class surface is
`data/alice/semantic-control-classes.aiml`.

## 13. Projection ABI and thinking/reasoning exposure

`data/projection_abi_v1.json` is the versioned contract for `project_v()`. It
defines the dimensions that may cross the neural boundary, authorized event
names, retained thinking levels, and target-specific exposure. `project_v()`
implements this contract; it does not define or expand its authority.

The dimensions are `FIELD`, `EVIDENCE`, `INFER`, `COUNTEREXAMPLE`, `VERIFY`,
and `XUL`. Thinking levels (`low`, `medium`, `high`) control which dimensions
are retained. Target exposure (`chat`, `code`, `patch`, `kuhul`) further limits
which dimensions are exposed. Therefore a requested thinking level does not
override the target contract or authorize hidden execution effects.

Semantic invariants:

```text
projection visibility ≠ execution permission
inference event       ≠ verified result
counterexample        ≠ rejection until the verifier decides
XUL visibility        ≠ persistent write authorization
```

`micronaut/xaiml/model-runtime-frame.json` and the host runtime bind the
projection operation to the ABI. Changes to event names, retention, or exposure
must update the ABI and its consumers together.

## 14. W-C-V field attention and Safetensors projection

The neighborhood attention representation uses `W`, `C`, and `V` as separate
roles:

| symbol | role | source |
|---|---|---|
| `W` | question/query embedding | `embeddinggemma:latest` through the configured Ollama embedding API |
| `C` | candidate context-key embedding | `candidateEmbeddings[].keyEmbedding` in `neighborhood.attention.jsonl` |
| `V` | candidate value embedding | `candidateEmbeddings[].valueEmbedding` in `neighborhood.attention.jsonl` |

`C` and `V` are existing candidate vectors. `W` embeds the question text; it is
not a replacement for either candidate vector. Attention scores rank candidate
keys against the query, and the weighted residual `R` combines the corresponding
values. This is candidate relevance and context aggregation, not evidence of
truth or a reward signal.

`micronaut/neighborhood_safetensors.py` projects the JSONL records into
`.micronaut/checkpoints/neighborhood-attention.safetensors`, with a JSON index
sidecar. The named tensors are `W_query_embeddings`,
`C_candidate_key_embeddings`, `V_candidate_value_embeddings`, `record_offsets`,
and `wcr_temperature`. The checkpoint is a numeric projection of the source
records; IDs, relations, and provenance remain in the sidecar/source. It is not
the source of truth for the neighborhood, and it does not replace the distinct
`.micronaut/checkpoints/gqa-demo.safetensors` model checkpoint.

π learning may replay these vectors, relate records, calculate bounded W-C
attention and a V-weighted residual, and emit candidate field deltas. Without
an external verifier, reward remains zero, `verified` remains false, and
admission remains `not_requested`. Neither Safetensors serialization nor
successful replay grants semantic admission, model execution authority, or
persistent learning permission.

## 15. SCFML semantic control flow and learning

SCFML means **Semantic Control Flow Machine Learning**. Its role is to
normalize semantic branch surfaces, preserve epistemic distinctions, manage
pattern-learning candidates, and project proposed moves to XCFE. SCFML declares
semantic branches and candidate moves; XCFE independently authorizes and
executes permitted moves.

The SCFML branch surface has four ordered parts:

```text
if       condition
then     action when the condition is SUPPORTED
else     complementary action when the condition is CONTRADICTED
unknown  handler for an UNKNOWN condition
```

Surface children may appear in different orders, but normalization emits the
canonical order `if`, `then`, `else`, `unknown`. `if/pattern` becomes the
condition; `then/template` and `else/template` become their branch actions;
`unknown` becomes the unknown handler. A nested `else/if/then` remains a nested
conditional after normalization. `then/pattern` and `else/pattern` are pattern
candidates, not branch actions.

The epistemic state is part of branch selection:

| state | branch interpretation | prohibited inference |
|---|---|---|
| `SUPPORTED` | select `then` for the supported condition | support does not grant execution permission |
| `CONTRADICTED` | select `else` as the condition's complement | a contradicted condition does not prove another candidate |
| `MISS` | no matching evidence was found | a miss is not contradiction and does not select `else` |
| `UNKNOWN` | evidence is unresolved or insufficient | unknown is not `else` and does not assert negation |

In particular, `else` is a control-flow branch, not the logical operator
`not`. `MISS(P) != CONTRADICTED(P)` and `UNKNOWN(P) != else` are invariants.
Reply traces record a no-match outcome as `no_match`; they must not encode a
miss or unknown as a contradicted condition.

### Pattern learning boundary

SCFML pattern-learning rows may be derived from memory events, semantic branch
surfaces, or prompts. Candidate kinds include AIML patterns/templates,
semantic branches, key-grammar entries, and route patterns. These are learning
candidates, not live rules. Promotion requires a `SUPPORTED` result or explicit
user verification; fact authority defaults to false. A pattern's promotion
does not by itself admit its branch actions for execution.

Static unigram banks are corpus priors and remain immutable. Learned evidence
is stored separately. A track limits which rules are available; the active
context selects a query and may bind a capture or candidate for that invocation.
Bigram vector references and trigram phase/fold references provide structured
candidate evidence. Every executable trigram retains its own phase and
`fold_ref`; template or track metadata cannot silently replace them.

### Reasoning over semantic keys

The SCFML v3 reasoning extension represents typed, directed relations between
namespace-qualified semantic keys. Relation kinds include `supports`,
`contradicts`, `implies`, `requires`, `questions`, `explains`, `causes`,
`qualifies`, and `alternative_to`. Edges carry an epistemic state and may carry
source evidence, a weight, or a guard. Inverse relations are not assumed.

Reasoning operators include `trace`, `compare`, `infer`, `verify`,
`counterexample`, `decompose`, `explain`, `question`, and `reconcile`. The active
track and query select the reasoning neighborhood. Vector geometry, cosine
similarity, and edge weights may retrieve or rank candidate relations; they do
not establish truth, entailment, or contradiction. Transitive inference needs
an explicit sound rule, compatible evidence, and provenance. Cycles, score
domains, reference integrity, and traversal budgets require host validation;
EBNF syntax alone does not establish them.

`<thinking>` exposure and SCFML reasoning are related but distinct. Projection
ABI thinking levels control which dimensions are retained or shown to a target.
SCFML reasoning describes semantic operations and evidence over keys. Exposing
a reasoning dimension does not authorize a reasoning side effect, branch
execution, or XCFE move.

### XCFE projection and phase authority

The semantic pipeline is:

```text
SCFML surface → canonical branch row → epistemic resolution → XCFE move proposal
```

Projected move kinds include guard, select, spawn-unknown, preserve, retrieve,
defer, merge, commit, and rollback. The projection is a request for XCFE policy
evaluation, not an authorization token. Reasoning is side-effect-free until an
authorized phase fold executes. Ch'en observes and verifies; Xul commits only
through the existing host-owned admission and closure gates. Parsing, branch
selection, pattern promotion, and a `project_to_xcfe` record cannot bypass
those gates.

SCFML's semantic track is `data/tracks/SCFML-u.semantic-tracks.v1.json`.
XCFE's policy track is `data/tracks/XCFE-u.semantic-tracks.v1.json`. Both,
together with CFPC, have declarative AIML categories in
`data/alice/semantic-control-classes.aiml`, indexed by `data/manifest/aiml.manifest.json`.
These AIML categories describe the classes and route to no runtime by themselves.
The track registry at `data/tracks/registry.json` is an index only; its entries
do not confer semantic or execution authority.

The callable AIML surface uses `<srai>` as an internal pattern redirect. The
Daemon Bot has aliases `SCFML`, `CFPC`, and `XCFE` (plus each `HELP` form) that
redirect to canonical class-description patterns. In the browser runtime, each
redirect is recursively resolved against the local pattern bank, recorded in
the SRAI trace, and bounded by the frame's recursion limit. It is pattern
dispatch only: SRAI does not invoke a Micronaut, run a classifier, authorize an
XCFE move, or commit learning. A host-callable function needs a separate
registered route and its own validation and admission gates.

### Grammar and manifest drift

The repository currently contains two SCFML grammar surfaces: the root
`vendor/key-grammar-kit/scfml.runtime-grammar.ebnf` declares v3, including the
optional phase/field extension and key-to-key reasoning extension; the
`vendor/key-grammar-kit/data/grammar/scfml.runtime-grammar.ebnf` copy declares
v1 and covers the branch, pattern-learning, and epistemic core. The SCFML
manifest points at the data/grammar copy. Until those artifacts are reconciled,
consumers must not assume that the v3 extensions are accepted by every v1
grammar consumer. The v3 extension is declarative grammar and contract; this
document does not claim that every listed reasoning operator has a complete
runtime implementation.
