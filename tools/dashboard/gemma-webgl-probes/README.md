# Gemma WebGL2 Probes

Run from the repository root on Windows with PyTorch, `safetensors`, .NET 8, and the WebView2 runtime installed.

```powershell
python tools\dashboard\gemma-webgl-probes\make_torch_reference.py
dotnet build tools\trainer-dashboard\webview2-smoke-test\WebView2Smoke.csproj --no-restore
& tools\trainer-dashboard\webview2-smoke-test\bin\Debug\net8.0-windows\WebView2Smoke.exe (Get-Location).Path 8765 tools/dashboard/gemma-webgl-probes/gelu.html
& tools\trainer-dashboard\webview2-smoke-test\bin\Debug\net8.0-windows\WebView2Smoke.exe (Get-Location).Path 8766 tools/dashboard/gemma-webgl-probes/index.html
```

The GELU page checks forward and backward against PyTorch float32 reference values. The two-layer page reads only the needed checkpoint tensor byte ranges, then compares the emitted graph output with a PyTorch CPU reference. The Python helper generates `input.f32` and `expected.f32` in this folder; those generated files are intentionally not committed. The WebView2 host prints a `PCRE2_STATUS` JSON result and exits after the page reports.
