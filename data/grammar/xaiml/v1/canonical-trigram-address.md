# Canonical Trigram Address — K'UHUL Feed v1

**Status:** Normative contract. Referenced by `2D Key-Graph Execution Field — Runtime Grammar v2.0`, `KHANARY AIML Runtime Grammar v5`, and `kuhul-feed-serializer.xsl`.

This contract defines the canonical semantic address (GUID) of a K'UHUL feed item and the content digest used to detect feed changes. An address identifies an item; it does not authorize eligibility, admission, dispatch, persistence, or execution.

## 1. Scope

This contract specifies the address grammar, component escaping, phase identity, canonical JSON, digest input, and serializer/consumer conformance. Eligibility, cross-domain bridges, scoring, phase authority, XCFE admission, and execution remain separate downstream contracts.

## 2. Address grammar

```text
canonical-address = track-part "#" atom1 SP atom2 SP atom3 "@" phase
track-part        = escaped-component
atom              = escaped-component
escaped-component = { component-char | pct-escaped }
component-char    = ALPHA | DIGIT | "_" | "-" | "." | "'" | "*" | "µ"
pct-escaped       = "%" HEX HEX
phase             = "Pop" | "Wo" | "Yax" | "Sek" | "Ch'en" | "Xul"
SP                = U+0020
```

`ALPHA` and `DIGIT` are ASCII letters and digits. `HEX` is an uppercase hexadecimal digit (`0`–`9`, `A`–`F`). The µ character is U+00B5 and is preserved verbatim in UTF-8.

### 2.1 Structural characters and escaping

The characters `#`, `@`, space, and `%` are structural or escape characters. When they occur inside a track or atom, they MUST be percent-encoded:

| Literal | Canonical encoding |
|---|---|
| `#` | `%23` |
| `@` | `%40` |
| space | `%20` |
| `%` | `%25` |

Percent hex digits MUST be uppercase. Other code points outside `component-char` MUST be rejected. `*` and `_` are permitted literally. An atom equal to `*` or `_` denotes a wildcard; these characters inside a longer atom are literal characters.

### 2.2 Phase and phase code

Phase names are case-sensitive and MUST be exactly one of the six names in §2. The apostrophe in `Ch'en` is literal. The corresponding phase code is a derived field and MUST match this table:

| Phase | Code |
|---|---|
| `Pop` | `000` |
| `Wo` | `001` |
| `Yax` | `010` |
| `Sek` | `011` |
| `Ch'en` | `100` |
| `Xul` | `101` |

The serializer may also emit a descriptive `phase_role` and a phase operator inventory as metadata. These values are lookup data only. They do not grant eligibility, execution permission, or XCFE admission; the runtime evaluates those separately.

### 2.3 Canonical form and validation

The canonical form is:

```text
{escaped-track}#{escaped-atom1} {escaped-atom2} {escaped-atom3}@{phase}
```

Atoms are separated by exactly one literal U+0020. The structural `#` and `@` each occur exactly once. Phase is emitted exactly as listed, without case folding or escaping.

Every well-formed `(track, three atoms, phase)` tuple has exactly one canonical address, and every canonical address decodes unambiguously to exactly one tuple. A consumer MUST parse the address, percent-decode the track and atoms, re-encode them according to this section, and compare the result byte-for-byte with the received address. Non-canonical or malformed addresses MUST be rejected. Item fields are authoritative; a mismatched GUID MUST be rejected.

Examples:

| Track | Atoms | Phase | Canonical address |
|---|---|---|---|
| `CODEGEN-PY-µ` | `def`, `foo`, `bar` | `Yax` | `CODEGEN-PY-µ#def foo bar@Yax` |
| `CODEGEN-PY-µ` | `def`, `*`, `bar` | `Pop` | `CODEGEN-PY-µ#def * bar@Pop` |
| `a#b` | `x`, `y`, `z` | `Sek` | `a%23b#x y z@Sek` |
| `a b` | `x y`, `@`, `_` | `Xul` | `a%20b#x%20y %40 _@Xul` |
| `CODEGEN-KUHUL-µ` | `a`, `b`, `c` | `Ch'en` | `CODEGEN-KUHUL-µ#a b c@Ch'en` |

## 3. Phase-identity invariant

Two feed items with the same track and the same three pattern atoms but different phases are distinct items. Their canonical addresses MUST differ, and conforming mergers MUST preserve both. Deduplication MUST use the validated GUID, never pattern equality alone. Phase is part of identity and MUST NOT be treated as a render-only attribute.

## 4. Content digest (ETag)

`generated_at` and `content_digest` have separate meanings:

| Field | Meaning | Change detection |
|---|---|---|
| `generated_at` | RFC 3339 UTC production time with second precision | MUST NOT be used |
| `content_digest` | `sha256:` followed by lowercase hexadecimal SHA-256 | MUST be used |

The digest is calculated over canonical JSON of the feed map after removing both `generated_at` and `content_digest`:

```text
content_digest = "sha256:" || lowercase_hex(
  SHA-256(UTF8(canonical_json(feed_map minus generated_at and content_digest)))
)
```

Consequently, identical content built at different times has the same digest. Any change to a remaining feed field changes the digest. A transport MAY use this digest as an `If-None-Match`-style validator. Optional fields are omitted when absent; they are not represented as `null`.

## 5. Canonical JSON

`canonical_json(M)` is the JSON serialization of map `M` with:

- object keys sorted by Unicode code point in ascending order;
- no insignificant whitespace or trailing commas;
- strings escaped according to RFC 8259;
- numbers serialized in shortest round-trippable form;
- arrays kept in their declared order.

Two JSON documents are byte-equivalent when their canonical JSON strings are identical. They are semantically equivalent when their parsed data-model values are structurally equal. These are distinct assertions; both are required where round-trip testing is specified.

## 6. Conformance

### 6.1 Serializer

A conforming serializer MUST:

1. Emit each GUID from the item's track, exactly three atoms, and phase using §2.
2. Reject patterns that do not contain exactly three atoms.
3. Reject phases outside the exact six-value phase set.
4. Apply canonical percent encoding to the track and every atom.
5. Emit the matching `phase_code`.
6. Emit `content_digest` according to §4 and `generated_at` as RFC 3339 UTC with second precision.
7. Emit JSON in canonical form according to §5.
8. Reject duplicate GUIDs within one feed.

### 6.2 Consumer

A conforming consumer MUST validate each GUID by deriving it again from the item fields and comparing byte-for-byte. It MUST preserve phase as part of item identity, use `content_digest` (not `generated_at`) for change detection, and preserve provenance and typed bindings. It MUST treat address validity as an existence/addressability assertion only.

A valid address does not prove that an item is eligible, that a Bridge exists, that a reference resolves, that its phase is currently executable, or that XCFE has admitted it.

## 7. Round-trip and fixture requirements

### 7.1 Structural equality

For a conforming feed map `F`, BSON and CBOR encoders/decoders MUST preserve the complete data model:

```text
J  = parse(canonical_json(F))
J1 = decode_bson(encode_bson(F))
J2 = decode_cbor(encode_cbor(F))
assert deep_equal(J, J1)
assert deep_equal(J, J2)
```

All map keys, array positions, integer values/types supported by the feed schema, strings, escaped characters, and µ must survive. Encoders MUST NOT silently lose or rewrite data.

### 7.2 Serializer determinism

For an input document `D`, repeated serialization MUST produce byte-identical canonical JSON and identical content digests. This tests serializer determinism independently of BSON/CBOR behavior.

### 7.3 Required failure fixtures

The serializer test suite MUST reject:

- a pattern with two atoms or four atoms;
- misspelled `Chen` or lower-case `xul` phase;
- a malformed/non-canonical address, including an invalid or lower-case percent escape;
- a GUID that differs from the value re-derived from item fields;
- duplicate GUIDs in one feed.

### 7.4 Required acceptance fixtures

The test suite MUST cover:

- identical atoms in `Pop` and `Yax` producing two distinct GUIDs;
- identical atoms in different tracks producing distinct GUIDs;
- literal `*` and `_` wildcard atoms;
- track `a#b` and atom `x@y` round-tripping through `%23` and `%40`;
- identical content at different build times retaining the same digest;
- changed item content changing the digest;
- BSON and CBOR round-trips with escaped characters and µ.

## 8. Versioning and references

This contract defines `kuhul.feed/1`. Changes to the address form, escape rule, phase set/codes, or digest input require a major-version change and migration note. Adding feed fields without changing address identity or the digest rule does not require re-addressing existing items.

Related contracts: `aiml-feed-v1.ebnf`, `kuhul-feed.schema.json`, `kuhul-feed-serializer.xsl`, MicronautPatterns, Key-Graph Runtime Grammar v2.0, and KHANARY AIML Runtime Grammar v5. A canonical address is never an admission or execution token.
