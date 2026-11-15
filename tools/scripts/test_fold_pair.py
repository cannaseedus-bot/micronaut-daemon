import json
import pathlib
import sys

sys.path.insert(0, str(pathlib.Path(__file__).resolve().parents[1]))
from fold_pair import fold_rows  # noqa: E402


def row(index, pattern):
    return json.dumps({"index": index, "A": {"vector_row": index},
                       "B": {"vector_row": index}, "pattern": pattern,
                       "authority": "data_only", "graph_evidence": False})


rows, events, vocabulary, mass = fold_rows([
    row(0, "MAN AND CAT"),
    row(1, "DOG SEES CAT"),
], radius=1)
assert rows == 2 and events == 4
assert vocabulary == ["AND", "CAT", "DOG", "MAN", "SEES"]
assert mass[("AND", "MAN")] == 1
assert mass[("CAT", "AND")] == 1
assert mass[("SEES", "DOG")] == 1
assert mass[("CAT", "SEES")] == 1
assert ("MAN", "AND") not in mass
assert ("CAT", "MAN") not in mass
try:
    fold_rows([row(1, "BAD ALIGNMENT")])
except ValueError:
    pass
else:
    raise AssertionError("misaligned row accepted")
print("fold pair: row boundaries, directed counts and alignment passed")
