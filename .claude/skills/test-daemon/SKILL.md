---
name: test-daemon
description: Run tests for the micronaut daemon. Use when verifying changes to C++ or Python code in this project.
---

# Test — micronaut daemon

**Never use `npm test`** — it's a placeholder that exits with an error.

## C++ test executables

Build first (`cmake --build build --config Release`), then run the executable(s) for the changed area:

```powershell
.\build\Release\test_vector_plan.exe
.\build\Release\test_semantic_bridge.exe
.\build\Release\test_gemma_bridge_route.exe
.\build\Release\test_micronaut_translation.exe
.\build\Release\test_domain_bridge.exe
.\build\Release\test_ccc4_learning.exe
.\build\Release\test_tensor_contract.exe
.\build\Release\test_reasoning_phase.exe
.\build\Release\test_xcfe_policy.exe
.\build\Release\test_training_phase.exe
.\build\Release\test_kuhul_runtime.exe
.\build\Release\test_ccc4_commit.exe
.\build\Release\test_binding_import.exe
```

Match test to changed source:

| Changed file(s) | Test to run |
|-----------------|-------------|
| `vector_plan.*`, `reduce.*` | `test_vector_plan.exe` |
| `semantic_bridge.*`, `relational_*.` | `test_semantic_bridge.exe` |
| `gemma_bridge_route.*`, `query_attestation.*` | `test_gemma_bridge_route.exe` |
| `micronaut_translation.*`, `conversation.*` | `test_micronaut_translation.exe` |
| `kuhul_runtime.*`, `phase_gate.*`, `pop/wo/yax/sek/chen/xul.cpp` | `test_kuhul_runtime.exe` |
| `tensor_contract.*` | `test_tensor_contract.exe` |
| `xcfe_policy.*` | `test_xcfe_policy.exe` |
| `ccc4_learning.*`, `trainer.*` | `test_ccc4_learning.exe` |
| `bindings.*` | `test_binding_import.exe` |

## Python checks

```powershell
python tools/test_fold_pair.py
python tools/scripts/check_fold_pair.py    # if it exists
python checker.py                           # general validation
python validator.py
```

## Adding a new test

1. Add `tools/test/test_<feature>.cpp`
2. In `CMakeLists.txt`: `add_executable(test_<feature> tools/test/test_<feature>.cpp <deps...>)`
3. If deps need `../vendor/`: add `target_include_directories(test_<feature> PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}/../vendor")`
4. Rebuild and run directly
