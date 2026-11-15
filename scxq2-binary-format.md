# SCXQ2 binary format audit

Status: **public 16-byte lane-packing v1 module added; SCXQ2B.v1 and AIML corpus compiler remain unimplemented**.

## Implementations found here

| Component | Evidence | Status |
|---|---|---|
| Micronaut request-frame encoder | `common.h` defines `Scxq2Frame` as string maps/vectors; `scxq2_runtime.cpp` fills DICT/FIELD/EDGE/LANE and validates required metadata before XCFE dispatch. | Present; in-memory logical frame only. No magic, widths, byte order, offsets, checksum, encoder-to-file, or decoder. |
| SCXQ2B.v1 packer specification | User-provided File Library excerpt: `.scxq2b`, magic `SCX2`, 32-byte header, little-endian integers/floats, DICT/FIELD/GEOMETRY/EDGE, SHA-256. | Specification excerpt supplied, but the packer source and complete section-record definitions are not in this checkout. |
| Public SCXQ2 Lane Packing Format v1 | [SCX repository frozen spec](https://github.com/cannaseedus-bot/SCX/blob/main/doc/scxq2-lane-packing-format.v1.md). | Different documented variant: 16-byte header, big-endian alignment rule, DICT plus sequential lane stream and optional metadata. Not equivalent to the supplied 32-byte SCXQ2B excerpt. |
| Local Python lane-packing implementation | `scxq2.py` with `test_scxq2.py`. | Implements flags=0 header/dictionary/lane records and supported scalar/vector/token/node payloads for the public 16-byte v1 variant. Rejects undefined payloads and compression/encryption flags. Opaque metadata bytes can round-trip but metadata entries are not decoded. |
| Public SCXQ2 CC-v1 package | [`@xjson/scxq2-cc`](https://www.npmjs.com/package/@xjson/scxq2-cc), installed locally in this project. | Present as a compression calculus API. It emits dictionary/block/proof objects with `SCXQ2-DICT16-B64`; package README explicitly says CC-v1 is not a file format or transport protocol. Async API smoke round-trip passed on a small fixture. It does not implement either SCX2 binary container above. |
| D3D12 SCXQ2 v1 source | Referenced path: `dist/xvm-d3d12/src/scxq2_format.cpp`. | `UNIMPLEMENTED / NOT PRESENT` in this checkout. |
| D3D12 SCXQ2 v1.2 source | Referenced path: `dist/xvm-d3d12/src/scxq2_format_v1_2.cpp`. | `UNIMPLEMENTED / NOT PRESENT` in this checkout. |
| JavaScript binary packer | Referenced path: `src/scxq2/binary.js`. | `UNIMPLEMENTED / NOT PRESENT` in this checkout. |
| Schema registry / conformance fixtures | Referenced artifact: `idb.instance(1).xml`; no matching registry or fixtures were found here. | `UNIMPLEMENTED / NOT PRESENT` in this checkout. |

The formats cannot be reconciled from the available material. The `SCX2` 32-byte SCXQ2B header is retained as a **user-supplied specification excerpt**, not asserted to be the active decoder contract. The public SCX repo separately publishes a 16-byte big-endian lane-packing v1, now implemented independently by `scxq2.py`. The 10-byte D3D12 variants are registry references only and were not directly inspected. The npm CC engine is a compression component, not a binary container reader/writer.

## SCXQ2B.v1 header known from the supplied excerpt

| Offset | Bytes | Field | Encoding |
|---:|---:|---|---|
| `0x00` | 4 | Magic `SCX2` | bytes |
| `0x04` | 2 | Version `1` | little-endian integer |
| `0x06` | 2 | Flags | little-endian integer; bit assignments unavailable |
| `0x08` | 8 | Epoch | little-endian integer; semantics unavailable |
| `0x10` | 8 | Total size | little-endian integer |
| `0x18` | 8 | Hash offset | little-endian integer |

Header size: 32 bytes. Integrity is described as SHA-256. Section payload headers, section IDs, symbol-ID widths, dictionary record shape, geometry representation, lane encoding, hash range, alignment, compression flags, resource limits, and error behavior are **UNIMPLEMENTED / NOT SPECIFIED by the supplied excerpt**.

## Public lane-packing v1 details (separate variant)

The public frozen lane-packing document describes a 16-byte header: `SCX2` (4), version (1), flags (1), dictionary count (2), lane count (4), metadata offset (4). It documents dictionary entries as token ID (2), byte length (1), UTF-8 bytes; lane records as domain (1), operator (1), flags (1), target ID (4), payload length (2), payload; and says the container has no padding and uses **big-endian** encoding. Compression flag values are GZIP `0x01`, ZSTD `0x02`, encryption `0x04`. These details conflict with the supplied 32-byte little-endian excerpt and therefore must not be mixed into its parser.

## Installed CC-v1 compression engine

`@xjson/scxq2-cc` exposes `ccCompressLanesSync` / `ccCompressLanes` and `ccDecompress`. Its dictionary and block objects include SHA-256 identities and reversible DICT16-B64 payloads. The package does not define a `.scxq2b` header or filesystem container. It can serve as the compression calculus only where the selected corpus container explicitly allows the CC-v1 pack representation; it cannot establish the binary framing by itself.

Environment note: `ccCompressSync` failed here with `SCXQ2: ccCompressSync requires Node.js crypto module`; the async `ccCompress` path succeeded with `proof.ok`, `verifyPack`, and exact decompression on an 81-byte AIML snippet. Prefer the async API unless the package's Node crypto resolution is corrected and independently verified.

## Compatibility decision

Do not change `Scxq2Frame` or its request dispatch to pretend it is a binary corpus. `scxq2.py` targets only the separately named public lane-packing v1 variant. Do not emit a `.scxq2b` until the 32-byte SCXQ2B section and symbol encodings can be implemented from its authoritative packer spec or an existing encoder/decoder. Do not adopt the D3D12 variants as corpus formats based only on registry path strings.

Once the authoritative binary details are selected, implement that exact version in a reader/writer module and keep the logical Micronaut request envelope as a separate use of SCXQ2. The Alice compiler may use CC-v1 for reversible lane compression, but its result must be framed by the selected binary contract. A fresh-process load must not read the XML sources.

## AIML corpus state

The Alice source directory contains 66 `.aiml` files (11,499,744 bytes in this checkout); `.hg` is excluded from that count. They remain source data. No AIML-to-lane compiler, compiled Alice corpus, AIML index, or AIML conformance executable exists yet. The current `chat.generate` handler is a stub.

## Required audit artifacts before implementation

- Recover the complete SCXQ2B.v1 packer specification or its source implementation.
- Verify every section record and symbol-gram reference against that source.
- Obtain the D3D12 format files and registry artifact if those variants are intended to be compatibility inputs.
- Add golden binary fixtures and inspect their bytes before implementing a writer.
- Record all unsupported AIML constructs during parsing; do not silently drop them.
