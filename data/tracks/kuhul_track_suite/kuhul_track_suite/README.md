# KHANARY / K'UHUL Track Contract Suite

Run: `python -m unittest discover -s . -p 'test_tracks.py' -v`

This suite exercises the **uploaded authored assets** for JOKE-µ, PLAN-µ, ADVISOR-µ and greeting-bank.
It validates AIML-like wildcard capture and precedence, declared frames and phases, alias boundaries,
fail-closed XCFE admission, independent Ch'en verification and Xul commit gating.

`track_suite.py` is a **Python reference contract harness**, not a C++ integration, AIML engine,
SCFML proof engine, JROM persistence, or native fold executor. Callbacks in tests are test doubles.
No learned capabilities, journal entries, or authority are produced by passing tests.

The supplied `JOKE-u.semantic-tracks.v1.json` declares `frame:subverted` as Ch'en-only.
Accordingly, the harness uses the declared `frame:collapse` Sek executor and evaluates
`frame:subverted` as a Ch'en outcome variant, rather than executing an undeclared Sek fold.

Production integration requires binding compiled AIML/Key-Grammar recognition, registered
XCFE admission and K'UHUL fold handlers, externally evidenced Ch'en verification, and
JROM/FoldDelta recording only after a genuinely verified outcome.
