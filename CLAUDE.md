# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build

```powershell
cmake -S . -B build
cmake --build build --config Release
```

The main executable is named `eliza-µ` and outputs to `../bin/` (one level up from this directory), not `build/`. Test executables go to `build/Release/`.

Prepare the AIML corpus before first run (or after modifying the AIML source):
```powershell
python aiml_to_gguf.py aiml-en-us-foundation-alice build\alice.aiml.jsonl
```

External dependencies are in `../vendor` (sibling of this directory, e.g. `C:\Users\canna\vendor\`) — CMake targets reference this via `target_include_directories(... PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../vendor")`. The build will fail if that directory is missing.

## CSS-C Native Runners (separate build)

`.CSS-C/native/` has its own `build.cmd` — independent of the CMake project:
```powershell
# Must be in a VS x64 dev shell first (call vcvars64.bat)
cd .CSS-C\native
build.cmd release
```
Produces `cssc_gate_run.exe`, `cssc_klsl_run.exe`, `cssc_softmax_run.exe`, etc.

## Tests

**`npm test` is broken — do not use it.** Run test executables directly:

```powershell
.\build\Release\test_vector_plan.exe
.\build\Release\test_semantic_bridge.exe
.\build\Release\test_gemma_bridge_route.exe
python tools/test_fold_pair.py
```

Run only the executable(s) relevant to what changed. See `CMakeLists.txt` for the full list of test targets (`test_*.cpp` in `tools/`).

## WPF Chat UI

```powershell
pwsh -STA -File .\Micronaut.ps1
```
Requires PowerShell 7+ with `-STA`. Default CLI path is `C:\Users\canna\.micronauts\models\micronauts\native\micronaut.exe`; override with `-CliPath`.

## Run

JSONL mode:
```powershell
echo {"@kind":"micronaut.request.v1","op":"chat.generate","id":"r1","prompt":"Hello","stream":true} | ..\bin\eliza-µ.exe
```

Chat mode:
```powershell
..\bin\eliza-µ.exe --chat "Hello"
```

HTTP mode (default port 9879):
```powershell
..\bin\eliza-µ.exe --http
# GET /health  POST /api/chat  POST /v1/chat/completions
```

Override corpus path: `--aiml-corpus PATH` flag or `MICRONAUT_AIML_CORPUS` env var.

## Environment

`.env` holds `MICRONAUT_GEMMA_ATTEST_KEY` — keep it out of commits. `.gitignore` already excludes it.

## Kuhul Phase Cycle

The phase-gated execution cycle is: `pop → wo → yax → (Sek kernel) → sek → chen → xul`. Each helper (in `pop.cpp`, `wo.cpp`, `yax.cpp`, `sek.cpp`, `chen.cpp`, `xul.cpp`) validates its phase and advances along the legal cycle declared in `phase.hpp`. The `SEK_PI_RADIUS` kernel (`pi_radius.cpp`, glyph `⊙`) only executes while `kuhul::phase::Name` is `Sek`.

## Architecture Notes

- OpenCL kernels: `vector_lane.cl`, `attention.cl`, `micronaut.cl` — CMake copies them next to their executables post-build.
- XCFE routing: `xcfe_router.cpp` dispatches ops; SCXQ2 frames flow through `scxq2_runtime.cpp`.
- Gemma bridge: `gemma_bridge_route.cpp` + `semantic_bridge.cpp` — attestation key from `.env` is used in `query_attestation.cpp`.
- AIML corpus is 99,524 categories; `<learn>` cannot mutate the loaded read-only corpus at runtime.

## External Dependencies

These directories live outside the project root and must be present for their respective systems to work:

| Path | Used by |
|------|---------|
| `vendor/nlohmann/json.hpp` | C++ build — single-header nlohmann/json v3.11.3, committed in-repo |
| `C:\Users\canna\.key-grammar-kit\` | Key-grammar manifests, tracks, and test suite (`test.bat`) |
| `E:\models\_khanary_inspect\.Powernaut-v1.0.0\Kuhul3D.psm1` | Powernaut K3D infographic renderer |
| `tools/bin/gpt2_trainer.exe` | Micronaut factory dashboard trainer (in-repo) |

**kuhul-es** lives inside the project at `tools/trainer-dashboard/kuhul-es/` — no external path, but `npm install` must have been run there before using CLI commands.

**CSS-ML** lives inside the project at `.CSS-C/css-ml-runtime/` — ESM module, Node.js only, no install step needed.

## Code Style

4-space indentation in C++ and Python. `snake_case` filenames and functions. Keep declarations in matching headers. New test targets named `test_<feature>`. No repo-wide formatter or linter is configured.
