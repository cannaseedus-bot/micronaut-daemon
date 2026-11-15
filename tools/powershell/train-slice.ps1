#Requires -Version 5.1
# train-slice.ps1 -- slice-by-slice xshard training for Qwen or GPT-2 mini
#
# Usage:
#   .\train-slice.ps1 -Model qwen   -DataBin E:\data\train\stack_phase1.bin
#   .\train-slice.ps1 -Model qwen   -DataBin E:\models\GPT2\qwen\qwen_ast_tokens.bin -Fold Sek
#   .\train-slice.ps1 -Model gpt2mini -DataBin E:\data\train\stack_phase1.bin
#   .\train-slice.ps1 -Model gpt2mini -DataBin E:\data\train\stack_phase2.bin -CompletionOnly
#
# Each run does ONE slice: backward -> adapt -> commit. Chain multiple calls
# over your dataset to walk through all folds layer by layer.

param(
    [Parameter(Mandatory)][ValidateSet('qwen','gpt2mini')][string]$Model,
    [Parameter(Mandatory)][string]$DataBin,
    [string]$Fold        = 'Sek',
    [float] $LR          = 1e-5,
    [float] $GradScale   = 1e-3,
    [float] $WeightScale = 1e-4,
    [switch]$CompletionOnly,
    [switch]$DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ROOT     = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$TRAINER  = Join-Path $PSScriptRoot 'build\Release'
$BACKWARD = Join-Path $TRAINER 'xshard_backward.exe'
$ADAPT    = Join-Path $TRAINER 'xshard_adapt.exe'
$SHADER   = Join-Path $PSScriptRoot 'build\shaders\xshard_adapt_fold.cso'

$XSHARDS = @{
    # qwen: F32 xshard from clean Qwen2.5-0.5B-Instruct Q8_0 download (dequantized for xshard_adapt)
    qwen     = 'E:\models\GPT2\qwen2.5-instruct-f32.xshard'
    gpt2mini = 'E:\models\GPT2\mini-GPT\gpt2-mini-f32.xshard'
}

$GGUF_BASES = @{
    qwen     = 'E:\models\GPT2\qwen2.5-0.5b-instruct-q8_0.gguf'
    gpt2mini = 'E:\models\GPT2\mini-GPT\lora_distil_v1.Q8_0.gguf'
}

# -- resolve base xshard -------------------------------------------------------
$BaseXShard = $XSHARDS[$Model]

# auto-create xshard from clean GGUF if not present
if (-not (Test-Path $BaseXShard)) {
    $SrcGguf  = $GGUF_BASES[$Model]
    $IngestPy = Join-Path $ROOT 'tools\gguf_to_xshard.py'
    if (-not (Test-Path $SrcGguf))  { throw "$Model GGUF not found: $SrcGguf" }
    if (-not (Test-Path $IngestPy)) { throw "gguf_to_xshard.py not found: $IngestPy" }
    Write-Host "[train-slice] Creating $Model xshard from GGUF: $SrcGguf" -ForegroundColor Cyan
    python $IngestPy --input $SrcGguf --output $BaseXShard --model $Model --dequantize
}

# -- checks --------------------------------------------------------------------
if (-not (Test-Path $BaseXShard)) { throw "xshard not found: $BaseXShard" }
if (-not (Test-Path $DataBin))    { throw "token bin not found: $DataBin" }
if (-not (Test-Path $BACKWARD))   { throw "xshard_backward.exe not found: $BACKWARD" }
if (-not (Test-Path $ADAPT))      { throw "xshard_adapt.exe not found: $ADAPT" }
if (-not (Test-Path $SHADER))     { throw "adapt shader not found: $SHADER" }

# -- temp grad file ------------------------------------------------------------
$GradXShard = Join-Path $env:TEMP "xshard_grad_${Model}_$([System.IO.Path]::GetRandomFileName()).xshard"

Write-Host "[train-slice] model=$Model  fold=$Fold  lr=$LR" -ForegroundColor Cyan
Write-Host "[train-slice] base   : $BaseXShard"
Write-Host "[train-slice] data   : $DataBin"
Write-Host "[train-slice] grads  : $GradXShard"
if ($DryRun) { Write-Host "[train-slice] DRY RUN -- no weights committed" -ForegroundColor Yellow }

try {
    # Step 1: backward pass (full model — no fold/max-shards filter so grad indices
    #         align with model seq numbers, which xshard_adapt looks up by position)
    Write-Host "[train-slice] step 1/2: backward pass (full model)..." -ForegroundColor Green
    $bwArgs = @($BaseXShard, '--token-bin', $DataBin, '--output', $GradXShard,
                '--max-shards', 294,
                '--grad-scale', $GradScale, '--weight-scale', $WeightScale)
    & $BACKWARD @bwArgs
    if ($LASTEXITCODE -ne 0) { throw "xshard_backward failed (exit $LASTEXITCODE)" }

    # Step 2: adapt -> apply (fold-filtered; process one phase group per slice)
    Write-Host "[train-slice] step 2/2: adapt + commit (fold=$Fold)..." -ForegroundColor Green
    $adArgs = @($BaseXShard, '--grad-xshard', $GradXShard,
                '--shader', $SHADER,
                '--fold', $Fold,
                '--max-shards', 9999,
                '--lr', $LR)
    if (-not $DryRun) { $adArgs += '--apply' }
    & $ADAPT @adArgs
    if ($LASTEXITCODE -ne 0) { throw "xshard_adapt failed (exit $LASTEXITCODE)" }

    Write-Host "[train-slice] fold=$Fold slice committed to $BaseXShard" -ForegroundColor Green
}
finally {
    if (Test-Path $GradXShard) { Remove-Item $GradXShard -Force -ErrorAction SilentlyContinue }
}
