---
name: run-daemon
description: Run eliza-µ (the micronaut daemon) in JSONL, chat, or HTTP mode. Use when launching or testing the daemon in this project.
disable-model-invocation: true
---

# Run daemon — eliza-µ

Binary is at `../bin/eliza-µ.exe` (NOT in `build/`). Run from the project root.

## Corpus prerequisite

The daemon needs a compiled corpus before it will respond to chat ops:
```powershell
python aiml_to_gguf.py aiml-en-us-foundation-alice build\alice.aiml.jsonl
```
Or set `MICRONAUT_AIML_CORPUS` to point at an existing `.jsonl` or `.gguf` corpus file.

## JSONL mode (pipe)

```powershell
echo {"@kind":"micronaut.request.v1","op":"chat.generate","id":"r1","prompt":"Hello","stream":true} | ..\bin\eliza-µ.exe
```

Expected output format:
```json
{"@kind":"micronaut.event.v1","id":"r1","type":"token","data":{"token":"...","index":0}}
{"@kind":"micronaut.result.v1","ok":true,"id":"r1","op":"chat.generate","result":{"text":"..."}}
```

## Chat mode

```powershell
..\bin\eliza-µ.exe --chat "Hello"
# Explicit corpus:
..\bin\eliza-µ.exe --aiml-corpus build\alice.aiml.jsonl --chat "Hello"
```

## HTTP mode

```powershell
..\bin\eliza-µ.exe --http          # default port 9879
..\bin\eliza-µ.exe --http 8080     # custom port
```

Endpoints:
- `GET  /health`
- `POST /api/chat` — `{ "prompt": "..." }`
- `POST /v1/chat/completions` — OpenAI-compatible chat request

## WPF chat UI

```powershell
pwsh -STA -File .\Micronaut.ps1
# Custom daemon path:
pwsh -STA -File .\Micronaut.ps1 -CliPath "..\bin\eliza-µ.exe"
```

Requires PowerShell 7+ in STA mode. The `-STA` flag is mandatory for WPF.

## Env vars

| Var | Purpose |
|-----|---------|
| `MICRONAUT_AIML_CORPUS` | Override corpus path at runtime |
| `MICRONAUT_GEMMA_ATTEST_KEY` | Set from `.env` — required for Gemma bridge attestation |
