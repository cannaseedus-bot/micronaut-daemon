# Micronaut JSONL Runtime

This is a concrete C++ skeleton for `micronaut.exe`.

The Alice AIML corpus is converted to `build/alice.aiml.jsonl`. `chat.generate` loads these JSONL records and runs the indexed category/template runtime. The source XML directory is not needed after the corpus file has been built.

## Contract

One JSON line in:

```json
{"@kind":"micronaut.request.v1","op":"chat.generate","id":"r1","payload":{"prompt":"Hi","stream":true}}
```

One or more JSON lines out:

```json
{"@kind":"micronaut.event.v1","id":"r1","type":"token","data":{"token":"Micronaut","index":0}}
{"@kind":"micronaut.result.v1","ok":true,"id":"r1","op":"chat.generate","result":{"text":"..."}}
```

## Build

```powershell
cmake -S . -B build
cmake --build build --config Release
```

Convert the AIML corpus to JSONL records before starting the daemon. This is the daemon's native line-oriented data transport:

```powershell
python aiml_to_gguf.py aiml-en-us-foundation-alice build\alice.aiml.jsonl
```

## Run

```powershell
echo {"@kind":"micronaut.request.v1","op":"chat.generate","id":"r1","prompt":"Hello","stream":true} | .\build\Release\micronaut.exe
```

Or:

```powershell
.\build\Release\micronaut.exe --chat "Hello"
```

To select a corpus explicitly, pass `--aiml-corpus PATH` before `--http`, `--chat`, or JSONL mode. The JSONL corpus is preferred automatically. Set `MICRONAUT_AIML_CORPUS` to override its path. GGUF remains an optional packaged form, produced by choosing an `.gguf` output extension; the daemon can read either form.

## Render basic AIML with Jinja

`render_aiml.py` renders the daemon's supported basic AIML constructs from a JSON manifest using `templates/aiml_macros.jinja`. The binding whitelist is in `aiml_bindings.v1.json`; it covers patterns, templates, categories, `<star/>`, `<that/>`, `<topicstar/>`, `<srai>`, `<random>`, `<condition>/<li>`, predicates (`<get>`, `<set>`, `<think>`), and bot properties. It intentionally does not implement advanced AIML extensions such as runtime `<learnf>` ingestion.

```powershell
python micronaut_daemon\render_aiml.py `
  --manifest micronaut_daemon\examples\aiml_basic_brain.json `
  --output micronaut_daemon\build\daemon_basic.aiml

New-Item -ItemType Directory -Force micronaut_daemon\build\jinja_source | Out-Null
Copy-Item micronaut_daemon\build\daemon_basic.aiml micronaut_daemon\build\jinja_source\daemon_basic.aiml -Force
python micronaut_daemon\aiml_to_gguf.py `
  micronaut_daemon\build\jinja_source `
  micronaut_daemon\build\daemon_basic.jsonl
```

The renderer validates manifest nodes against the binding whitelist, escapes XML text/attributes, and parses its own output before writing. The generated XML then follows the same JSONL compilation and `chat.generate` runtime path as other AIML categories. Each brain may provide top-level categories and topic-scoped categories; categories and topics are composed without adding daemon-specific template syntax.

## Files

- `input.cpp` — stdin/CLI ingestion
- `output.cpp` — JSONL event/result emission
- `process.cpp` — external process runner
- `chat.cpp` — session history and `chat.generate` integration
- `aiml_runtime.cpp` / `aiml_runtime.h` — JSONL/GGUF corpus reader, category matcher, AIML session/template runtime
- `batches.cpp` — batch envelope handler
- `threads.cpp` — async job registry
- `scheduler.cpp` — deterministic job ordering
- `canvas.cpp` — terminal projection
- `frames.cpp` — redraw scheduler
- `xcfe_router.cpp` — op routing layer
- `scxq2_runtime.cpp` — JSONL → SCXQ2 frame → XCFE route
- `aiml_to_gguf.py` — converts Alice AIML sources to runtime JSONL or optional GGUF package
# Phase-gated attention kernel

`SEK_PI_RADIUS` (glyph `⊙`) consumes `positions` shaped `[points, dimensions]` and a positive `radius` scalar. It writes `pi_radius_weights` shaped `[points, points]` using the compact-support cosine radial function `0.5 * (1 + cos(pi * distance / radius))` for `distance <= radius`, and zero outside the radius. The kernel only executes while the shared `kuhul::phase::Name` is `Sek`.

The phase helpers are split across `pop.cpp`, `wo.cpp`, `yax.cpp`, `sek.cpp`, `chen.cpp`, and `xul.cpp`. Each helper validates its current phase and advances only along the legal cycle declared in `phase.hpp`. Call `pop`, `wo`, and `yax`, execute the Sek kernel, then call `sek`, `chen`, and `xul` to complete the phase trace.

# HTTP API

Run `eliza-µ.exe --http [port]` to start a loopback-only HTTP listener (default port `9879`). It serves `GET /health`, `POST /api/chat` with `{ "prompt": "..." }`, and `POST /v1/chat/completions` with a JSON chat request. The existing JSONL `chat.create`, `chat.history`, and `chat.generate` operations remain available through piped stdin/stdout. Launching the executable interactively without arguments prints usage instead of waiting silently for stdin.

# Alice AIML corpus in GGUF

Optionally package the corpus as GGUF using llama.cpp's bundled `gguf-py` writer:

```powershell
python micronaut_daemon\aiml_to_gguf.py `
  micronaut_daemon\aiml-en-us-foundation-alice `
  micronaut_daemon\build\alice.aiml.gguf
```

The GGUF contains a `micronaut_aiml` data payload with the original UTF-8 AIML source text and an ordered category index. It is a GGUF data container, not neural-network weights and not loadable by llama.cpp as a chat model. The daemon can read it, though JSONL is its native corpus format. Reopen and inspect either format without consulting the AIML directory:

```powershell
python micronaut_daemon\aiml_to_gguf.py --inspect `
  micronaut_daemon\build\alice.aiml.jsonl
```

## Tokenize AIML into a training `.bin`

Build the repository's native tokenizer with binary token output enabled:

```powershell
cmake --build build-haswell --target llama-tokenize --config Release
```

For a Hugging Face model directory, use its tokenizer and chat template together:

```powershell
python micronaut_daemon\tokenize_aiml.py `
  --input micronaut_daemon\build\alice.aiml.jsonl `
  --tokenizer-json E:\models\GPT2\gemma_toolcall\merged\tokenizer.json `
  --tokenizer-config E:\models\GPT2\gemma_toolcall\merged\tokenizer_config.json `
  --model-config E:\models\GPT2\gemma_toolcall\merged\config.json `
  --output micronaut_daemon\build\alice.gemma_toolcall.tokens.bin
```

The Hugging Face path applies the local chat template to each AIML pattern/template pair, including its BOS and turn-ending tokens. Use the **same model tokenizer that the training run will use**. Alternatively, the native llama.cpp tokenizer path accepts a GGUF vocabulary:

```powershell
python micronaut_daemon\tokenize_aiml.py `
  --input micronaut_daemon\build\alice.aiml.jsonl `
  --model path\to\target-tokenizer.gguf `
  --tokenizer build-haswell\bin\llama-tokenize.exe `
  --output micronaut_daemon\build\alice.tokens.bin
```

The `.bin` is a headerless stream of little-endian `uint32` token IDs. Its adjacent `.bin.json` records the tokenizer model, category/token counts, and SHA-256 hashes. IDs are vocabulary-specific; do not train against this file with a different tokenizer. It is tokenized training data, not Safetensors weights. A training program must consume the IDs and produce the model checkpoint separately.

The supplied Gemma config sets `use_bidirectional_attention` to `false`. The token file records this setting, but the training code must still construct the causal attention mask; setting it to `true` would let training positions see future tokens and would not match autoregressive chat generation.

## Train a compact Gemma3 model from scratch on CPU

The GPT-2 D3D11 executable cannot train this Gemma3 token stream. Use the PyTorch/Transformers CPU trainer instead:

```powershell
python micronaut_daemon\train_gemma3_scratch.py `
  --tokens micronaut_daemon\build\alice.gemma_toolcall.tokens.bin `
  --tokenizer-dir E:\models\GPT2\gemma_toolcall\merged `
  --model-config E:\models\GPT2\gemma_toolcall\merged\config.json `
  --output micronaut_daemon\build\alice-gemma3-scratch-cpu `
  --steps 200 --threads 4 --sequence-length 32 `
  --hidden-size 32 --heads 4 --layers 2 --intermediate-size 64
```

This initializes a tiny two-layer Gemma3 causal model randomly, trains it on CPU, and saves `model.safetensors`, `config.json`, the tokenizer files, and `training_report.json`. The AIML pattern is the user turn; visible template text is the assistant turn. `<think>` and `<srai>` contents are omitted; other dynamic AIML constructs are not executed during flattening, so this is an approximate training set. It is intentionally not the 26-layer, width-1152 source model. At 200 steps × 32 tokens, it sees about 6,400 target-token positions (random windows from the corpus), so this produces a valid starter checkpoint, not a capable conversational model. Longer training requires more steps and CPU time.

The current compiled corpus contains 66 sources and 99,524 categories. The runtime supports wildcard pattern matching, topic/that constraints, captures, SRAI, predicates, conditions, random-list cycling, and common text transforms. It never evaluates template code; `<learn>` cannot mutate the loaded read-only corpus. Unsupported AIML behavior may therefore produce different replies from a complete reference AIML interpreter.
