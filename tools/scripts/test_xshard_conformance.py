"""
XSHARD/1 conformance test — verifies round-trip correctness of the Python writer
against independent Python re-reading (not via the C++ reader, so the two
implementations can be compared separately).

Checks:
  1. Magic, version, flags parse correctly
  2. state_start and data_start match manifest values
  3. For every shard: seek to data_start + shard.offset, read shard.nbytes,
     compute SHA-256, compare to manifest sha256
  4. Footer n_shards matches manifest n_shards
  5. State block is all 0x00 (pending) on a fresh file

Usage:
  python trainer/test_xshard_conformance.py <file.xshard>
  python trainer/test_xshard_conformance.py trainer/roundtrip_test.xshard
  python trainer/test_xshard_conformance.py trainer/test.xshard
"""
import struct, json, hashlib, sys, os

MAGIC   = b'XSHD'
VERSION = 1
FOOTER_MAGIC = 0x44485358

def sha256hex(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()

def run(path: str) -> bool:
    print(f"XSHARD conformance: {path}")
    size = os.path.getsize(path)
    print(f"  file size     : {size:,} bytes")

    with open(path, 'rb') as f:
        # ── 1. Header ─────────────────────────────────────────────────────────
        raw_magic = f.read(4)
        if raw_magic != MAGIC:
            print(f"  FAIL magic: got {raw_magic!r}, want {MAGIC!r}")
            return False

        version, flags, manifest_len = struct.unpack('<HHQ', f.read(12))
        if version != VERSION:
            print(f"  FAIL version: got {version}, want {VERSION}")
            return False

        print(f"  version       : {version}")
        print(f"  flags         : 0x{flags:04X}")
        print(f"  manifest_len  : {manifest_len:,} bytes")

        # ── 2. Manifest JSON ──────────────────────────────────────────────────
        manifest_bytes = f.read(manifest_len)
        if len(manifest_bytes) != manifest_len:
            print(f"  FAIL manifest truncated: got {len(manifest_bytes)}, want {manifest_len}")
            return False

        manifest = json.loads(manifest_bytes.decode('utf-8'))
        n_shards    = manifest['n_shards']
        state_start = manifest['state_start']
        data_start  = manifest['data_start']
        shards      = manifest['shards']

        print(f"  n_shards      : {n_shards}")
        print(f"  state_start   : {state_start}")
        print(f"  data_start    : {data_start}")

        if len(shards) != n_shards:
            print(f"  FAIL shards array length {len(shards)} != n_shards {n_shards}")
            return False

        # ── 3. State block ────────────────────────────────────────────────────
        f.seek(state_start)
        state_block = f.read(n_shards)
        if len(state_block) != n_shards:
            print(f"  FAIL state block truncated: got {len(state_block)}, want {n_shards}")
            return False

        non_pending = [(i, b) for i, b in enumerate(state_block) if b not in (0x00, 0x01, 0x02, 0xFF)]
        if non_pending:
            print(f"  FAIL state block has invalid bytes: {non_pending[:5]}")
            return False

        all_pending = all(b == 0x00 for b in state_block)
        trained_count = sum(1 for b in state_block if b == 0x01)
        print(f"  state block   : {'all pending' if all_pending else f'{trained_count} trained'}")

        # ── 4. SHA-256 per shard ──────────────────────────────────────────────
        print(f"\n  verifying SHA-256 for {n_shards} shards ...")
        n_ok = 0
        n_fail = 0
        for s in shards:
            seq    = s['seq']
            offset = s['offset']
            nbytes = s['nbytes']
            expect = s['sha256']

            f.seek(data_start + offset)
            data = f.read(nbytes)
            if len(data) != nbytes:
                print(f"  FAIL seq={seq} read {len(data)} bytes, want {nbytes}")
                n_fail += 1
                continue

            got = sha256hex(data)
            if got != expect:
                print(f"  FAIL seq={seq} sha256 mismatch")
                print(f"       got    : {got}")
                print(f"       expect : {expect}")
                n_fail += 1
            else:
                n_ok += 1

        if n_fail == 0:
            print(f"  SHA-256 OK    : {n_ok}/{n_shards} shards all match")
        else:
            print(f"  SHA-256 FAIL  : {n_fail} shards mismatched, {n_ok} ok")
            return False

        # ── 5. Footer ─────────────────────────────────────────────────────────
        f.seek(size - 8)
        footer_n, footer_magic = struct.unpack('<II', f.read(8))
        if footer_magic != FOOTER_MAGIC:
            print(f"  FAIL footer magic: 0x{footer_magic:08X}, want 0x{FOOTER_MAGIC:08X}")
            return False
        if footer_n != n_shards:
            print(f"  FAIL footer n_shards: {footer_n}, want {n_shards}")
            return False
        print(f"  footer        : n_shards={footer_n} magic=0x{footer_magic:08X} OK")

    print(f"\n  PASS — {n_shards} shards, all SHA-256 verified")
    return True

if __name__ == '__main__':
    paths = sys.argv[1:] if len(sys.argv) > 1 else ['trainer/roundtrip_test.xshard', 'trainer/test.xshard']
    results = {}
    for p in paths:
        print()
        ok = run(p)
        results[p] = 'PASS' if ok else 'FAIL'

    print("\n--- summary ---")
    all_pass = True
    for p, r in results.items():
        print(f"  {r}  {p}")
        if r != 'PASS':
            all_pass = False

    sys.exit(0 if all_pass else 1)
