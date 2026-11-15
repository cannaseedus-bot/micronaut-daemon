#Requires -Version 5.1
# gen-guidance.ps1 -- produce a clean grad xshard for runtime guidance injection
#
# Runs xshard_backward ONLY (no xshard_adapt, no --apply).
# Output: E:\models\GPT2\guidance\${Name}_guidance_${Fold}_${timestamp}.xshard
#
# The Name prefix is the personality/behavior identity of the guidance file —
# it can be a model id, a behaviour archetype, or any label that describes
# what the delta encodes. The server resolves files by name, not by architecture.
#
# Usage:
#   .\gen-guidance.ps1 -Fold Sek
#   .\gen-guidance.ps1 -Name toolcall  -Fold Sek
#   .\gen-guidance.ps1 -Name reasoning -Fold Yax -DataBin E:\models\GPT2\qwen\qwen_ast_tokens.bin
#   .\gen-guidance.ps1 -Name gemma     -Fold Pop -BaseXShard E:\models\GPT2\gemma\gemma-3-1b-f32.xshard

param(
    [string] $Name       = 'qwen',   # personality/behavior label — any string, no restrictions
    [ValidateSet('Sek','Wo','Yax','Pop','Chen','Xul')][string]$Fold = 'Sek',
    [string] $DataBin,               # default: qwen toolcall tokens
    [string] $BaseXShard,            # default: resolved from known-xshard table by Name
    [float]  $GradScale   = 1e-3,
    [float]  $WeightScale = 1e-4,
    [int]    $MaxShards   = 294,
    [switch] $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# -- known base xshards (add entries as new model xshards are generated) -------
$KNOWN_XSHARDS = @{
    qwen  = 'E:\models\GPT2\qwen2.5-instruct-f32.xshard'
    gemma = 'E:\models\GPT2\gemma\gemma-3-1b-f32.xshard'
    lfm   = 'E:\models\GPT2\lfm\lfm2-1.2b-f32.xshard'
    oss   = 'E:\models\GPT2\oss\gpt-oss-20b-f32.xshard'
    qwen3 = 'E:\models\GPT2\qwen3\qwen3-1.7b-f32.xshard'
}

# Fold-specific token bins: matched to the semantic role of each phase.
# All exist under E:\models\.gpu_trainer\bin\; Chen also has a scratch copy.
$FOLD_DEFAULT_BIN = @{
    Pop  = 'E:\models\.gpu_trainer\bin\tokens.bin'          # perceive / embed — general
    Wo   = 'E:\models\.gpu_trainer\bin\tokens_instruct.bin' # FFN gate/up — instruction
    Yax  = 'E:\models\.gpu_trainer\bin\tokens_code.bin'     # FFN down/proj — code
    Sek  = 'E:\models\.gpu_trainer\bin\tokens_instruct.bin' # attn Q/K/V/O — instruction
    Chen = 'E:\models\.gpu_trainer\bin\tokens_instruct.bin' # layer-norm — instruction
    Xul  = 'E:\models\.gpu_trainer\bin\tokens.bin'          # lm_head — general
}

# Resolve base xshard: explicit > known table by Name > known table by first token of Name
if (-not $BaseXShard) {
    if ($KNOWN_XSHARDS.ContainsKey($Name)) {
        $BaseXShard = $KNOWN_XSHARDS[$Name]
    } else {
        $base = ($Name -split '[_-]')[0].ToLower()
        if ($KNOWN_XSHARDS.ContainsKey($base)) { $BaseXShard = $KNOWN_XSHARDS[$base] }
    }
}
if (-not $DataBin) { $DataBin = $FOLD_DEFAULT_BIN[$Fold] }

$TRAINER  = Join-Path $PSScriptRoot 'build\Release'
$BACKWARD = Join-Path $TRAINER 'xshard_backward.exe'

$OUT_DIR  = 'E:\models\GPT2\guidance'
if (-not (Test-Path $OUT_DIR)) { New-Item -ItemType Directory -Path $OUT_DIR | Out-Null }

$Stamp   = (Get-Date -Format 'yyyyMMdd_HHmmss')
$OutFile = Join-Path $OUT_DIR "${Name}_guidance_${Fold}_${Stamp}.xshard"

# -- checks -------------------------------------------------------------------
if (-not $BaseXShard)             { throw "base xshard not resolved for '$Name' -- pass -BaseXShard explicitly or add to KNOWN_XSHARDS." }
if (-not (Test-Path $BaseXShard)) { throw "base xshard not found: $BaseXShard`n  Run gguf_to_xshard.py --input <gguf> --output $BaseXShard --dequantize first." }
if (-not (Test-Path $DataBin))    { throw "token bin not found: $DataBin" }
if (-not (Test-Path $BACKWARD))   { throw "xshard_backward.exe not found: $BACKWARD" }

Write-Host "[gen-guidance] name=$Name  fold=$Fold  max-shards=$MaxShards  grad-scale=$GradScale" -ForegroundColor Cyan
Write-Host "[gen-guidance] base  : $BaseXShard"
Write-Host "[gen-guidance] data  : $DataBin"
Write-Host "[gen-guidance] output: $OutFile"
if ($DryRun) { Write-Host "[gen-guidance] DRY RUN -- no file written" -ForegroundColor Yellow; return }

$bwArgs = @(
    $BaseXShard,
    '--token-bin',    $DataBin,
    '--output',       $OutFile,
    '--fold',         $Fold,
    '--max-shards',   $MaxShards,
    '--grad-scale',   $GradScale,
    '--weight-scale', $WeightScale
)

& $BACKWARD @bwArgs
if ($LASTEXITCODE -ne 0) { throw "xshard_backward failed (exit $LASTEXITCODE)" }

Write-Host ""
Write-Host "[gen-guidance] guidance xshard ready:" -ForegroundColor Green
Write-Host "  $OutFile"
Write-Host ""
Write-Host "Load via swap route:" -ForegroundColor Yellow
Write-Host "  Invoke-RestMethod -Method POST -Uri http://localhost:17474/v1/guidance/swap ``"
Write-Host "    -ContentType 'application/json' ``"
Write-Host "    -Body (ConvertTo-Json @{ source='xshard'; fold='$Fold'; model='$Name'; scale=0.1 })"
