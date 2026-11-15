"""Independent Python check of the proposed CCC4 contract byte encoding."""
import hashlib
import pathlib
import re
import struct

ROOT = pathlib.Path(__file__).resolve().parents[1]
EXPECTED = {
    "neuron": "37a08263cb88a89cde6408964ce59ec4ea4c463ee35ddce07fabd21658f78dc3",
    "tensor": "94c9a48fba859b751acfb844fff046f59d6de6b419706614e7daa7fff97b22d6",
    "micronaut": "ef8bc0f3106fd05c7e5cd246813265176326c689350059e6ff467a65ace94f54",
}
TOKEN = re.compile(r'"(?:\\.|[^"\\])*"|[^\s\[\]]+')


def pairs(line):
    tokens = TOKEN.findall(line)
    if len(tokens) % 2:
        raise ValueError("odd key/value count")
    return {tokens[i]: tokens[i + 1].strip('"') for i in range(0, len(tokens), 2)}


def u32(value):
    return struct.pack("<I", value)


def string(value):
    data = value.encode("utf-8")
    return u32(len(data)) + data


def declarations(fields, excluded):
    selected = sorted((k, v) for k, v in fields.items() if k not in excluded)
    return u32(len(selected)) + b"".join(string(k) + string(v) for k, v in selected)


for variant, expected in EXPECTED.items():
    source = (ROOT / f"build/ccc4-{variant}.gml").read_text(encoding="utf-8")
    graph, nodes, edges = {}, {}, {}
    for raw in source.splitlines():
        line = raw.strip()
        if line.startswith("node ["):
            item = pairs(line[6:-1])
            nodes[int(item["id"])] = item
        elif line.startswith("edge ["):
            item = pairs(line[6:-1])
            a, b = sorted((int(item["source"]), int(item["target"])))
            edges[a, b] = item
        elif line and line not in ("graph [", "]"):
            graph.update(pairs(line))
    payload = bytearray(b"ccc4.contract.v1\0")
    payload += declarations(graph, {"comment", "id", "label"})
    payload += u32(len(nodes))
    for node_id, item in sorted(nodes.items()):
        payload += u32(node_id) + declarations(item, {"id", "label", "x", "y", "z"})
    payload += u32(len(edges))
    for (a, b), item in sorted(edges.items()):
        payload += u32(a) + u32(b) + declarations(item, {"source", "target"})
    actual = hashlib.sha256(payload).hexdigest()
    assert actual == expected, (variant, actual, expected)
    print(f"{variant}: {actual}")
