# micronaut-srai.v1 — Canonical Encoding for Hashing

Defines the byte layout for computing `srai_hash` (SHA-256) over a compiled `micronaut-srai.v1` plan. Two presentation-distinct plans with the same semantics must produce the same hash; two semantically distinct plans must not collide.

## Domain separator

```
"micronaut-srai.v1\0"
```

Prefix the byte stream with this null-terminated UTF-8 string before hashing.

## Byte layout

```
u32le n_nodes
for each node, in ascending id (lexicographic UTF-8):
    utf8  node.id
    u8    node.kind_index      # SRAI=0, ROUTE=1, CAPABILITY=2, FALLBACK=3, BINDING=4
    u32le n_params
    for each param, in ascending key (lexicographic UTF-8):
        utf8  param.key
        u8    param.value_kind   # STRING=0, INT=1, ENUM=2, REF=3
        utf8  param.value_canonical
        # For ENUM values, value_canonical is the enum name.
        # For REF values, value_canonical is the referenced node.id or capability id.

u32le n_containment
for each containment, sorted by (parent_id, child_id, role):
    utf8  parent_id
    utf8  child_id
    u8    role_index           # owns=0, owns_fallback=1, owns_binding=2, owns_route=3

u32le n_data_flow
for each data_flow, sorted by (source_id, output_port, target_id, input_port):
    utf8  source_id
    u8    output_port_index    # out=0, resolved_input=1, fallback_out=2, binding_out=3
    utf8  target_id
    u8    input_port_index     # in=0, input=1, fallback_in=2, binding_in=3

u32le n_exec
for each execution dependency, sorted by (before_id, after_id):
    utf8  before_id
    utf8  after_id

srai_hash := SHA-256 of domain_separator_bytes + above bytes, hex-lowercase
```

All `utf8` fields are length-prefixed: `u32le length` followed by `length` bytes of UTF-8. No null terminator on field values.

## Properties enforced

**Source-order independence.** Declarations are sorted before encoding; the bytes are a function of the plan's semantics, not its presentation order.

**String-spacing independence.** Every string is length-prefixed UTF-8; `route: capital_of` and `route:capital_of` produce identical bytes after normalization.

## Self-check

The validator runs `E_HASH_AMBIGUOUS` as a self-check: if two semantically distinct plans produce the same `srai_hash`, the encoder has collapsed something it should not have. The validator must reject both plans rather than accept one with mis-attributed provenance.

## Freeze criterion

Two independent implementations of this encoding, run against `data/conformance/micronaut-srai.v1/valid/`, produce identical `srai_hash` values for all valid fixtures.
