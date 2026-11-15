# K’UHUL Key-Grammar / Track Suite v2

Updated copies of the three uploaded scripts, with cross-layer tests. They retain their repository paths and expected fixture contracts.

Run the self-contained bridge tests:

```bash
python -m unittest discover -s . -p 'test_grammar_bridge.py' -v
```

In the full KHANARY key-grammar repository, put the scripts in their original `tools/` directory and run:

```bash
python tools/check_key_book_grammar.py
python tools/check_ngram_key_grammar.py
python tools/build_key_relation_graph.py --query ABACUS --output data/grammar/key_relation_graph.manifest.json
```

The validators need the original repository fixtures, manifests, contracts and docs; these are **not** bundled here. Set `KUHUL_KIT_ROOT` to override repository root for both validators and the graph builder.

## Corrections

- Exact graph identity no longer falls through to a fuzzy suggestion. Suggestions remain candidates, not verified semantic keys.
- Relation weight and confidence of zero are preserved rather than silently changed to 1.0.
- Malformed negative fixture patches report a failed conformance case instead of crashing the entire checker.
- Cross-layer tests cover polysemy, edge direction, non-authoritative recognition and compact output.

This is Python-level graph/grammar validation, not native K'UHUL, XCFE, SCFML, or JROM execution.
