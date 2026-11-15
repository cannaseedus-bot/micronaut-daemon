---
name: key-grammar
description: Key-grammar JSON format, semantic fold compression algebra, .jsonl corpus records, phase-gated manifests, and runtime tests. Use when working with .key-grammar.jsonl files, key-book manifests, semantic tracks, kgf files, or the resolve_manifest pipeline in this project.
---

# Key-Grammar Kit

## What it is

The **Semantic Fold Compression Grammar** — a structured JSON record format for addressing, phase-binding, and validating semantic knowledge against the K'UHUL algebra. `.key-grammar.jsonl` files are the corpus; manifests unfold them into a runtime graph.

**Kit location:** `C:\Users\canna\.key-grammar-kit\`
**Runtime-relative path in project:** `vendor/key-grammar-kit/` (not yet created — runtime references resolve there)
**Local copy rationale:** documented in `C:\Users\canna\.key-grammar-kit\LOCAL-COPY.md`

---

## Core algebra

```text
k -> Book(k)          # a key unfolds to its neighborhood
Book(k) = N(k)        # = { k1, k2, ..., kn }
B_Q = Bag of Key-Words from query tokens/ngrams/aliases/intents/classes/XCFE ops
U(B_Q, theta) -> G_Q  # phase-constrained unfold → query-local graph
```

Phase face `theta(k)` binds to C6: `Pop | Wo | Yax | Sek | Ch'en | Xul`

Layers (most abstract → most concrete):
1. **Semantic Fold Compression Grammar** — manifest key-books, `⟁KEYGRAMMAR`, unfold rules
2. **Semantic Fold Graph Topology** — expanded atoms, relations, books, candidates, phase edges
3. **Geometric Node Field Class** — vectors, fields, coordinates, tensors, GML, SVG-3D

**Invariant: Manifest authority > Graph realization > Geometric projection.** A projection cannot redefine semantic authority.

---

## File types

| Extension | Purpose |
|-----------|---------|
| `.key-grammar.jsonl` | Corpus records — one JSON object per line |
| `.manifest.json` | Key-book bootstrap — executable manifest for a domain |
| `.kgf` | Key-grammar field definition |
| `.runtime-grammar.ebnf` | EBNF grammar for a surface |
| `.semantic-tracks.v1.json` | Semantic program consumed by KHANARY TrackLoader |

---

## Key locations in this project

**Grammar source / editable:**
```
data/grammar/              — .key-grammar.jsonl, .ebnf, .contracts.json
data/grammar/fold_graph.xml — Semantic Fold Graph Topology
```

**Ingest (copy of grammar for runtime):**
```
data/ingest/               — mirrors data/grammar/ for runtime loading
```

**App-specific bindings:**
```
data/apps/*.key-grammar.jsonl  — per-app key-grammar address bindings
```

**AIML integration:**
```
data/alice/khanary/*.key-grammar.aiml  — AIML patterns backed by key-grammar
```

**Manifests (kit):**
```
C:\Users\canna\.key-grammar-kit\data\manifest\   — 25+ domain manifests
  aiml.manifest.json, css.manifest.json, eliza.manifest.json,
  folds.manifest.json, gml.manifest.json, joke.manifest.json,
  kuhul.manifest.json, micronaut.manifest.json, tool.manifest.json,
  words.manifest.json, ...
```

**Semantic tracks:**
```
C:\Users\canna\.key-grammar-kit\data\tracks\     — *.semantic-tracks.v1.json
  registry.json  — hash-pinned index (non-authoritative; each .v1.json is authoritative)
```

**Phase-gated micronaut templates:**
```
C:\Users\canna\.key-grammar-kit\data\templates\micronaut-control.templates.json
```

---

## Tests

Run from `C:\Users\canna\.key-grammar-kit\`:
```bat
test.bat
```

This runs sequentially (each must pass before the next):
1. `python check_key_book_grammar.py` — manifest-book validation
2. `python check_tool_manifest.py` — tool verb registration
3. `python check_micronaut_templates.py` — phase-gated templates
4. `python check_kuhul_source_sync.py` — K'UHUL source sync
5. `python check_2d_key_graph_execution_field.py` — 2D execution field
6. `python check_semantic_tracks.py` — hash, identity, phase, relation checks
7. `python test_tracks.py` — routing behavior

---

## Surface form → sense key disambiguation

A surface word is not the final semantic key. Context, ngrams, aliases, intents, and classes resolve it:

```
surface:bank
  -> bank:river_edge          (context: river, geography)
  -> bank:financial_institution
  -> bank:seed_repository
  -> bank:nearby_financial_search  (adds location/search intent)
```

After disambiguation: normal treatment — `Book(k)=N(k)`, symbolic score `S(k)=W_k+H_N(k)`, phase face `Theta(k)`.

---

## Adding / updating records

1. Edit the source `.key-grammar.jsonl` in `data/grammar/`
2. Copy to `data/ingest/` (runtime loads from there)
3. If adding a new app: create `data/apps/<name>.key-grammar.jsonl` with app-local address bindings
4. If adding a new manifest domain: add `<domain>.manifest.json` to the kit's `data/manifest/`
5. Run `test.bat` to verify grammar, tool verbs, templates, source sync, tracks

---

## PowerShell integration

`shell/key-grammar-topology.psm1` — PS module for key-grammar topology operations. Import with:
```powershell
Import-Module .\shell\key-grammar-topology.psm1 -Force
```
