"""Generates a minimal valid XSHARD/1 file for xshard_info smoke test."""
import struct, json, hashlib, math, os, sys

MAGIC   = b'XSHD'
VERSION = 1
FLAGS   = 0x07  # FOLD_TAGGED | SUB_SHARDED | STATE_MUTABLE
ALIGN   = 64

# Three tiny shards: wte (Pop, whole), attn x2 (Sek, sub-sharded)
SHARDS_DATA = [
    b'\x01\x02\x03\x04' * 16,    # shard 0: wte embed, 64 bytes (F32 [16])
    b'\x10\x11\x12\x13' * 32,    # shard 1: attn row 0-15, 128 bytes
    b'\x20\x21\x22\x23' * 32,    # shard 2: attn row 16-31, 128 bytes
]

def sha256hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def pad(n: int, align: int) -> int:
    return (align - n % align) % align

def build_file(out_path: str):
    shard_records = [
        {
            "id": "wte",
            "seq": 0,
            "tensor_name": "transformer.wte.weight",
            "fold": "Pop",
            "phase_angle": 0.0,
            "shape": [16],
            "dtype": "F32",
            "offset": 0,
            "nbytes": len(SHARDS_DATA[0]),
            "sha256": sha256hex(SHARDS_DATA[0]),
            "shard_of": "transformer.wte.weight",
            "shard_index": 0,
            "shard_count": 1,
        },
        {
            "id": "h.0.attn.c_attn.s0",
            "seq": 1,
            "tensor_name": "transformer.h.0.attn.c_attn.weight",
            "fold": "Sek",
            "phase_angle": round(math.pi, 10),
            "shape": [16, 4],
            "dtype": "F32",
            "offset": len(SHARDS_DATA[0]),
            "nbytes": len(SHARDS_DATA[1]),
            "sha256": sha256hex(SHARDS_DATA[1]),
            "shard_of": "transformer.h.0.attn.c_attn.weight",
            "shard_index": 0,
            "shard_count": 2,
            "shard_axis": 0,
            "shard_slice": [0, 16],
        },
        {
            "id": "h.0.attn.c_attn.s1",
            "seq": 2,
            "tensor_name": "transformer.h.0.attn.c_attn.weight",
            "fold": "Sek",
            "phase_angle": round(math.pi, 10),
            "shape": [16, 4],
            "dtype": "F32",
            "offset": len(SHARDS_DATA[0]) + len(SHARDS_DATA[1]),
            "nbytes": len(SHARDS_DATA[2]),
            "sha256": sha256hex(SHARDS_DATA[2]),
            "shard_of": "transformer.h.0.attn.c_attn.weight",
            "shard_index": 1,
            "shard_count": 2,
            "shard_axis": 0,
            "shard_slice": [16, 32],
        },
    ]

    # ── Compute state_start / data_start (one pass; small manifest) ──────────
    # manifest_len is written at offset 8; manifest starts at 16
    # state block follows at next 64-byte boundary after manifest
    # data block follows at next 64-byte boundary after state block
    N = len(shard_records)
    HEADER_SIZE = 16

    def make_manifest(state_start: int, data_start: int) -> bytes:
        m = {
            "@kind": "xshard/1",
            "version": 1,
            "model": "test-fixture",
            "arch": "gpt2",
            "n_layer": 1,
            "n_embd": 16,
            "n_head": 1,
            "vocab_size": 16,
            "dtype_default": "F32",
            "alignment": ALIGN,
            "n_shards": N,
            "state_start": state_start,
            "data_start": data_start,
            "shards": shard_records,
        }
        return json.dumps(m, separators=(',', ':')).encode()

    # Bootstrap estimate
    est_manifest = make_manifest(0, 0)
    state_start  = HEADER_SIZE + len(est_manifest) + pad(HEADER_SIZE + len(est_manifest), ALIGN)
    data_start   = state_start + N + pad(N, ALIGN)

    # Convergence (≤2 iterations)
    for _ in range(2):
        manifest = make_manifest(state_start, data_start)
        mlen     = len(manifest)
        new_ss   = HEADER_SIZE + mlen + pad(HEADER_SIZE + mlen, ALIGN)
        new_ds   = new_ss + N + pad(N, ALIGN)
        if new_ss == state_start and new_ds == data_start:
            break
        state_start, data_start = new_ss, new_ds

    manifest = make_manifest(state_start, data_start)

    # ── Write ─────────────────────────────────────────────────────────────────
    with open(out_path, 'wb') as f:
        # 16-byte header
        f.write(MAGIC)
        f.write(struct.pack('<HHQ', VERSION, FLAGS, len(manifest)))
        # manifest
        f.write(manifest)
        f.write(b'\x00' * pad(HEADER_SIZE + len(manifest), ALIGN))
        # state block (all pending=0x00)
        assert f.tell() == state_start
        f.write(b'\x00' * N)
        f.write(b'\x00' * pad(N, ALIGN))
        # shard data
        assert f.tell() == data_start
        for sd in SHARDS_DATA:
            f.write(sd)
            f.write(b'\x00' * pad(len(sd), ALIGN))
        # footer
        f.write(struct.pack('<II', N, 0x44485358))

    size = os.path.getsize(out_path)
    print(f"wrote {out_path}  ({size} bytes)")
    print(f"  manifest_len={len(manifest)}  state_start={state_start}  data_start={data_start}")
    print(f"  shards: {N}  (Pop=1, Sek=2)")

if __name__ == '__main__':
    out = sys.argv[1] if len(sys.argv) > 1 else 'trainer/test.xshard'
    build_file(out)
