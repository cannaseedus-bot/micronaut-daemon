---
name: kuhul-daemon
description: Kuhul phase cycle, kernel, and runtime reference scoped to this micronaut daemon project. Use when working on phase-gated execution, OpenCL kernels, or the kuhul_runtime in this codebase. For general K'UHUL grammar/syntax questions, also invoke the global kuhul-grammar skill.
---

# Kuhul — micronaut daemon

For general K'UHUL grammar, syntax, and fold system: see the global `kuhul-grammar` skill.
This skill covers the specific wiring in **this project**.

## Phase cycle

Declared in `phase.hpp`. Legal cycle: `pop → wo → yax → [Sek kernel] → sek → chen → xul`

Each phase helper validates current phase and advances only along the declared cycle:

| File | Phase |
|------|-------|
| `pop.cpp` | POP |
| `wo.cpp` | WO |
| `yax.cpp` | YAX |
| `sek.cpp` | SEK (call after kernel) |
| `chen.cpp` | CHEN |
| `xul.cpp` | XUL |

Calling a helper out of order will cause a phase validation error. Always complete a full cycle; don't skip.

## SEK_PI_RADIUS kernel

- Glyph: `⊙`
- Source: `pi_radius.cpp`
- Runs only when `kuhul::phase::Name` is `Sek`
- Input: `positions [points × dimensions]`, scalar `radius > 0`
- Output: `pi_radius_weights [points × points]` using compact-support cosine: `0.5 * (1 + cos(π * distance / radius))` for `distance ≤ radius`, else `0`

## OpenCL kernels in this project

| Kernel file | Used by | Copied to exe dir by CMake |
|-------------|---------|---------------------------|
| `vector_lane.cl` | `vector_lane`, `micronaut`, `test_ccc4_commit` | Yes |
| `attention.cl` | `vector_math_probe`, `vector_lane`, `micronaut` | Yes |
| `micronaut.cl` | `vector_lane`, `micronaut` | Yes |
| `gradients.cl` | `test_ccc4_gradient_opencl` | Yes |

**When adding a new kernel:** add a `copy_if_different` post-build rule in `CMakeLists.txt` for every target that needs it, or the runtime won't find the `.cl` file.

## kuhul_runtime

- Source: `kuhul_runtime.cpp` / `kuhul_runtime.h`
- Linked into: `vector_lane`, `micronaut`, `test_kuhul_runtime`, `test_ccc4_commit`
- Test: `.\build\Release\test_kuhul_runtime.exe`

## XCFE routing

- `xcfe_router.cpp` dispatches ops at runtime
- `xcfe_policy.cpp` enforces policy rules — test: `test_xcfe_policy.exe`
- `scxq2_runtime.cpp` handles JSONL → SCXQ2 frame → XCFE route

## Powernaut GLSL Object Server (GPU compute transport)

> This is the GLSL GPU transport — not the same as the Powernaut K3D infographic module. For SVG→PNG rendering and WPF dashboards, see the `powernaut` skill.

## Powernaut GLSL Object Server

Powernaut is the GPU compute backend for the kuhul-es trainer. It serves GLSL shader dispatch via HTTP.

**Binaries location:** `tools/trainer-dashboard/kuhul-es/bin/`
- `GLSL_Server.exe` — the server (may need extracting from `bin.zip`)
- `server.glsl.json` — opcode manifest (already present)
- `neural_layer.glsl` — base shader (already present)

**Extract binaries if needed:**
```powershell
cd tools\trainer-dashboard\kuhul-es
npm run extract-bin    # unpacks bin/bin.zip → bin/GLSL_Server.exe + xvm-d3d12/
```

**Start the server** (default port 9060):
```powershell
.\tools\trainer-dashboard\kuhul-es\bin\GLSL_Server.exe
```

**Server endpoints:**

| Method | Path | Purpose |
|--------|------|---------|
| `GET` | `/health` | Liveness check |
| `GET` | `/manifest` | SSBO binding layout per opcode |
| `POST` | `/dispatch` | Single op: `{opcode, inputs, outputs, params, readback}` |
| `POST` | `/chain` | Multi-op: `{ops: [dispatch payloads]}` |
| `POST` | `/compile` | Pre-warm shader cache: `{opcode}` |

**Opcodes and kernel mapping:**

| kuhul-es kernel | Powernaut opcode | Notes |
|-----------------|-----------------|-------|
| `matmul`, `dense`, `ffn`, `embed`, `lm_head` | `WO_DENSE` | SSBO order: input, weight, bias, output, params |
| `gelu` | `WO_GEGLU` | Two inputs → one output |
| `swiglu` | `WO_SWIGLU` | Two inputs → one output |
| `layernorm`, `rms_norm` | `WO_RMS_NORM` | input, output, params |
| `softmax`, `attention` | `WO_SOFTMAX` | input, output, params |
| `adam` | `WO_ADAM_STEP` | param, grad, momentum, velocity, params |

**Wire into kuhul-es trainer:**
```js
const { GLSLTrainer, powernautGlslTransport } = require('kuhul-es');
const transport = powernautGlslTransport('http://127.0.0.1:9060', {
  manifest: './tools/trainer-dashboard/kuhul-es/bin/server.glsl.json',
});
const trainer = new GLSLTrainer({ vocabSize, embedDim, hiddenDim, transport });
```

**CLI shorthand:**
```powershell
node tools\trainer-dashboard\kuhul-es\bin\kuhul-es.js train config.json --backend powernaut-glsl
node tools\trainer-dashboard\kuhul-es\bin\kuhul-es.js gpu --backend powernaut-glsl --backend-endpoint http://127.0.0.1:9060
```

**Transport source:** `tools/trainer-dashboard/kuhul-es/runtime/src/transports/powernaut_glsl_transport.js`

## kuhul-es (JavaScript K'UHUL runtime)

Located at `tools/trainer-dashboard/kuhul-es/`. A Node.js ES-module K'UHUL engine used by the trainer dashboard.

**Run the CLI:**
```powershell
node tools/trainer-dashboard/kuhul-es/bin/kuhul-es.js
```

**Run the server** (default port 8776, override with `KUHUL_SERVER_PORT`):
```powershell
node tools/trainer-dashboard/kuhul-es/bin/kuhul-server.js
# or:
$env:KUHUL_SERVER_PORT=9000; node tools/trainer-dashboard/kuhul-es/bin/kuhul-server.js
```

**Run tests:**
```powershell
node tools/trainer-dashboard/kuhul-es/test/kuhul-e.test.js
```

**Key internals:**
- `KUHULEngine` — main class with `DomainStack`, `FoldEngine`, `ResponsePatternEngine`
- Domains map to K'UHUL glyphs (Pop, Wo, Yax, Sek, Ch'en, Xul) with attention weights
- Python bridge: `tools/trainer-dashboard/kuhul_runtime_bridge.py`

**K'UHUL stdlib** (`.kuhul` programs): `data/stdlib/` — includes `core.kuhul`, `vectors.kuhul`, `tensors.kuhul`, `geometry.kuhul`, etc.

**Grammar files** (EBNF): `data/grammar/kuhul-pi.ebnf`, `kuhul.runtime-grammar.ebnf`, `kuhul-fold-algebra.ebnf`

**Micronaut registry**: `data/micronauts/kuhul-micronaut-registry.json` with schema `data/schema/kuhul-micronaut-registry.v1.schema.json`

## CCC4 learning + training

- `ccc4_learning.cpp` / `trainer.cpp` — shared by `ccc4_train`, `ccc4_infer`, and test targets
- OpenCL gradient kernel: `gradients.cl` (used by `test_ccc4_gradient_opencl`)
- Test: `test_ccc4_learning.exe`, `test_ccc4_commit.exe`
