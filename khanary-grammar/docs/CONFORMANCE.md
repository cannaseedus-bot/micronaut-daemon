# Conformance checklist (implementation targets, not claimed test results)

1. XML parser handles real XML attributes and escaping; EBNF describes the element AST.
2. Unknown relation IDs -> `UNDECLARED_RELATION`; duplicate IDs and domain/range mismatch fail validation.
3. Relation `transitive=true` does not automatically synthesize facts.
4. User/model observations are retained (subject to ingestion safety/access validation) without Xul admission gating.
5. Cheese is contextual, dynamic, bounded 0..10; older data is stale only relative to a freshness-dependent query.
6. A user's correction can lower cheese for *their own intent* but cannot automatically verify external facts.
7. WCR routing success is not evidence verification.
8. Xul closure does not automatically select or promote; root closure terminates, child closure returns to parent.
9. Xul selection excludes L=0 candidates before ranking; zero score does not imply illegality; empty set -> Bottom.
10. Model verification verdict `unavailable` or `uncertain` must not be interpreted as `supports`.
11. Learn proposals remain shadow; `route_weight` target is parse-rejected until Stage 3 authority gate exists.
12. No writes to FactIndex or EventLog from ordinary Xul closure/collapse.
13. ThinkExecutor delegates to FunctionExecutor; bare invoke is wrapped as temporary local FunctionDef.
14. Unselected Yax candidates are not automatically marked false or refuted.
15. EventLog occurrence is append-only; graph state transitions require independent approval.
16. Training pairs derived from cheese require provenance, independent evidence and validation; score is not truth probability.
17. Phase identity: Pop, Wo, Yax, Sek, Ch'en, Xul; per-node phase transitions and continuation.
18. XML content cannot assign its own trusted instruction authority.
