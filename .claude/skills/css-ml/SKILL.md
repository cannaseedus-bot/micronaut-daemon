---
name: css-ml
description: CSS-ML language compiler and WebGL2 training loop runner. Use when working with .cssc source files, compiling CSS-ML programs, running the GEMM/training demo, or wiring CSS-ML into the WebGL2 trainer dashboard.
---

# CSS-ML Runtime

CSS-ML is a domain-specific language that compiles to CSS-C (a compute shader graph). The runtime executes those graphs in WebGL2.

**Location in project:** `.CSS-C/css-ml-runtime/`
**Also at (parent dir):** `C:\Users\canna\.CSS-C\css-ml-runtime\`

---

## CLI

```powershell
# Compile a .cssc source file to a build directory
node .CSS-C\css-ml-runtime\bin\cssml-compile.js <input.cssc> <output-dir>

# Run a compiled CSS-ML program
node .CSS-C\css-ml-runtime\bin\cssml-run.js <output-dir>
```

**Package test (compile MNIST demo):**
```powershell
cd .CSS-C\css-ml-runtime
node --experimental-vm-modules bin/cssml-compile.js examples/mnist.cssc ./build/mnist
```

---

## Source layout

```
.CSS-C/css-ml-runtime/
  bin/
    cssml-compile.js    — compiler CLI
    cssml-run.js        — runner CLI
  src/
    compiler/
      lexer.js          — CSS-ML tokenizer
      parser.js         — parse .cssc → AST
      graph-builder.js  — AST → compute graph
      kernel-lower.js   — lower graph to shader kernels
      cssc-emitter.js   — emit CSS-C output
      index.js          — compiler entry
    runner/
      autograd.js       — automatic differentiation
      dispatcher.js     — kernel dispatch
      gate.js           — phase/execution gating
      loop.js           — training loop
      tensors.js        — tensor management
      webgl2-model-trainer.js  — full model training surface
    runtime/
      cpu.js            — CPU kernel implementations
      webgl2.js         — WebGL2 kernel implementations
  examples/
    mnist.cssc          — MNIST example (synthetic data)
  package.json          — name: css-ml-runtime, ESM module
```

---

## Demo

The live demo runs inside the WebGL2 trainer dashboard:

```
.CSS-C/demo/gsnr-universe.html   — demo page (loads css-ml-runtime WebGL2 trainer)
.CSS-C/demo/demo.cssc            — demo CSS-ML source
```

In the dashboard, select **CSS-ML / WebGL2 model trainer** and press **TRAIN MODEL**. This runs the synthetic MNIST-shaped graph — it does **not** train Gemma or any language model.

**Operations the demo executes in WebGL2:** GEMM, linear, ReLU, SiLU, elementwise multiply
**Still on CPU reference:** graph backpropagation, AdamW updates

---

## Dashboard integration

The WebGL2 trainer dashboard (`tools/trainer-dashboard/webgl2-trainer-dashboard.ps1`) embeds the demo page via WebView2 and maps `.CSS-C` → `https://cssml.local`. This virtual origin allows local modules and shaders to load consistently across the embedded browser context.

Bridge messages between the dashboard shell and the CSS-ML page should be small — send status, loss, step counts, and checkpoint metadata rather than raw tensor arrays.

---

## Native CSS-C runners (compiled separately)

The `.CSS-C/native/` subdirectory contains D3D11-based native runners. These are **not** built by the main CMake project — they use `build.cmd` with an MSVC dev shell. See the `build` skill for details.

GEMM probe: `tools/powershell/build-cssc-gemm.ps1` compiles the CSS-C GEMM runner and checks D3D11 results against a CPU reference.

---

## Adding a new CSS-ML program

1. Write `.cssc` source (see `examples/mnist.cssc` for structure)
2. Compile: `node .CSS-C/css-ml-runtime/bin/cssml-compile.js <source.cssc> <output-dir>`
3. Run: `node .CSS-C/css-ml-runtime/bin/cssml-run.js <output-dir>`
4. To expose in the dashboard: register the compiled build dir and update the dashboard's WebView2 navigation target
