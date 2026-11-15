---
name: powernaut
description: Powernaut infographic system — K3D PowerShell module, SVG→PNG→frames pipeline, and WPF dashboard apps (Micronaut.ps1, WebGL2 trainer, factory dashboard). Use when working on infographics, visual assets, or any of the PS1 WPF apps in this project.
---

# Powernaut — infographics + WPF apps

Powernaut in this project refers to two related things:
1. The **K3D PowerShell module** (`Kuhul3D.psm1`) for rendering SVG → PNG frames
2. The family of **WPF PowerShell apps** (chat UI, trainer dashboards, factory dashboard)

> Note: `powernaut_glsl_transport.js` in kuhul-es is a separate GPU transport that shares the name — see the `kuhul-daemon` skill for that.

---

## Powernaut K3D module

**Location:** `E:\models\_khanary_inspect\.Powernaut-v1.0.0\Kuhul3D.psm1` (not in the repo)

**Import:**
```powershell
Import-Module "E:\models\_khanary_inspect\.Powernaut-v1.0.0\Kuhul3D.psm1" -Force
```

**Key cmdlets:**
| Cmdlet | Purpose |
|--------|---------|
| `ConvertFrom-K3DSvg -Svg <string>` | Parse SVG text into a K3D scene object |
| `Export-K3DFrame -Path <string>` | Render the scene and write a PNG frame |

**Reference script:** `tools/powershell/render-kuhul-infographic.ps1`

---

## SVG → PNG pipeline

### Simple path (no K3D — uses Inkscape / ImageMagick / Chrome headless)

```powershell
# Default width: 2400px; SVG must have a valid viewBox
pwsh -File tools\powershell\svg-to-png.ps1 `
  -InputSvg  data\apps\saturn-system-infographic.svg `
  -OutputPng data\apps\saturn-system-infographic.png `
  -Width 2400
```

Renderer priority: Inkscape → ImageMagick → headless Edge/Chrome. The script throws if none is found.

### K3D path (Powernaut module, adds style/font overrides)

```powershell
pwsh -File tools\powershell\render-kuhul-infographic.ps1 `
  -InputSvg       data\apps\kuhul-infographic.svg `
  -OutputPng      data\apps\kuhul-infographic.png `
  -PowernautModule "$env:USERPROFILE\.Powernaut-v1.0.0\Kuhul3D.psm1"
```

The K3D path runs `ConvertFrom-K3DSvg` → applies font/color styles → `Export-K3DFrame`.

### Frames workflow (SVG → PNG → animation frames)

1. Edit the SVG source in `data/apps/` for structure/layout changes
2. Edit JSON facts in `data/facts/` for data changes
3. Regenerate PNG: run `svg-to-png.ps1` or `render-kuhul-infographic.ps1`
4. For animated sequences: generate one PNG per keyframe, then composite into frames

### Infographic assets

| File | Purpose |
|------|---------|
| `data/apps/saturn-system-infographic.svg` | Saturn interactive 3D infographic source |
| `data/apps/saturn-system-infographic.png` | Rendered PNG |
| `data/apps/saturn-system-explorer.html` | Interactive HTML app with orbit view |
| `data/apps/kuhul-infographic.svg` | K'UHUL phase diagram source |
| `data/apps/kuhul-infographic.png` | Rendered PNG |
| `data/apps/css-gemm-infographic.svg` | CSS-C GEMM diagram source |
| `data/facts/saturn-moon-count.json` | Saturn facts data |
| `data/tracks/kuhul_track_suite*.zip` | Semantic track archives |

---

## WPF PowerShell apps

**All WPF apps require PowerShell 7+ in STA mode:**
```powershell
pwsh -STA -File .\<script>.ps1
```
Never use regular `powershell.exe` — WPF will hang without `-STA`.

### Micronaut.ps1 — chat UI

```powershell
pwsh -STA -File .\Micronaut.ps1
# Custom daemon path:
pwsh -STA -File .\Micronaut.ps1 -CliPath "..\bin\eliza-µ.exe"
```

Default CLI path: `C:\Users\canna\.micronauts\models\micronauts\native\micronaut.exe`

### WebGL2 Trainer Dashboard

Two versions exist — prefer the one in `tools/trainer-dashboard/`:
```powershell
pwsh -STA -File .\tools\trainer-dashboard\webgl2-trainer-dashboard.ps1
# Also at:
pwsh -STA -File .\tools\dashboard\webgl2-trainer-dashboard.ps1
```

**WebView2 SDK** is loaded from `.CSS-C/webview2_sdk/` (bundled, no install needed). The dashboard maps `.CSS-C` to `https://cssml.local` as a virtual HTTPS origin.

**Ports used:**
- kuhul-server (WebGL2 single-session): 8764
- kuhul-server (default): 8776

**Training lanes available from the dashboard:**
| Button | What it runs |
|--------|-------------|
| Start XSHARD | `kuhul-es.js train-xshard` |
| Start HF Tensors | `kuhul-es.js train-webgl2-sweep --all-tensors` |
| Start Native GPU | Full-model GPT via D3D11 |
| Start Training | WebGL2 single-session probe on port 8764 |
| CSS-ML Demo | `.CSS-C/demo/gsnr-universe.html` (synthetic MNIST only) |

**Error log:** `tools/trainer-dashboard/trainer-dashboard-error.log`

### Micronaut Factory + Evolution Dashboard

```powershell
pwsh -STA -File .\tools\trainer-dashboard\micronaut-factory-dashboard.ps1
```

**Ports: kuhul_engine=17474, BOSS=8764. NEVER use port 8080.**

**Paths (all repo-relative, resolved from `$PSScriptRoot\..\..`):**
- Trainer exe: `tools\bin\gpt2_trainer.exe`
- Trainer work dir: `tools\d3d11-build`
- Micronaut registry: `micronauts\registry.json`
- Models: `models\from_zero\`

**Error log:** `tools/trainer-dashboard/micronaut-factory-error.log`

### MX2 Integration

```powershell
pwsh -STA -File .\tools\trainer-dashboard\mx2_integration.ps1
```

MX2LM bridge integration for the trainer dashboard.

### CSS Micronaut PIGCCP Bridge

```powershell
pwsh -STA -File .\tools\trainer-dashboard\css_micronaut_pigccp_bridge.ps1
```

CSS-C / micronaut PIGCCP protocol bridge.

---

## Infographic authoring workflow

1. **Data** → edit `data/facts/<topic>.json` or `data/apps/<topic>.data.json`
2. **Illustration** → edit `data/apps/<topic>.svg` (keep text ≥22px for readability; include a scale/scope note)
3. **Render** → `tools/powershell/svg-to-png.ps1` (simple) or `render-kuhul-infographic.ps1` (K3D)
4. **App manifest** → update `data/apps/<topic>.asx-app.json` and key-grammar bindings in `data/apps/<topic>.key-grammar.jsonl`
5. **Link** → add interactive app reference to the AIML answer card or semantic track
