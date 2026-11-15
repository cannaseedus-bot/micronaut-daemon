#Requires -Version 5.1
# gen-adapt.ps1 -- apply guidance xshards to a working copy via xshard_adapt (Adam/SGD)
#
# Pipeline:
#   1. Copy BaseXShard -> WorkingCopy  (preserves base; satisfies delta-W=0 invariant)
#   2. For each fold: xshard_adapt WorkingCopy --grad-xshard <latest guidance xshard> --fold F --apply
#   3. Writes per-fold adapt ledger alongside WorkingCopy (<name>.adapt_<Fold>.jsonl)
#
# Usage:
#   .\gen-adapt.ps1                                         # all 6 folds, qwen base
#   .\gen-adapt.ps1 -Folds Sek,Yax                         # specific folds only
#   .\gen-adapt.ps1 -LR 5e-6 -WeightDecay 1e-4             # custom hypers
#   .\gen-adapt.ps1 -WorkingCopy E:\...\existing.xshard    # resume into existing copy
#   .\gen-adapt.ps1 -DryRun                                 # preview without writing

param(
    [string]   $Name        = 'qwen',
    [string]   $BaseXShard  = 'E:\models\GPT2\qwen2.5-instruct-f32.xshard',
    [string]   $GuidanceDir = 'E:\models\GPT2\guidance',
    [string]   $OutDir      = 'E:\models\GPT2\adapted',
    [string]   $WorkingCopy = '',
    [string[]] $Folds       = @('Pop','Wo','Yax','Sek','Chen','Xul'),
    [float]    $LR          = 1e-5,
    [float]    $WeightDecay = 0.0,
    [switch]   $SGD,
    [switch]   $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$TRAINER = Join-Path $PSScriptRoot 'build\Release'
$ADAPT   = Join-Path $TRAINER 'xshard_adapt.exe'
$SHADER  = Join-Path $PSScriptRoot 'build\shaders\xshard_adapt_fold.cso'

# Shard counts per fold (from xshard_info on qwen2.5-instruct-f32.xshard, 295 total)
$FOLD_SHARDS = @{
    Pop  = 3
    Wo   = 48
    Yax  = 24
    Sek  = 168
    Chen = 49
    Xul  = 3
}

function Get-LatestGuidance([string]$fold) {
    $pattern = "${Name}_guidance_${fold}_*.xshard"
    $hits = @(Get-ChildItem $GuidanceDir -Filter $pattern -ErrorAction SilentlyContinue |
              Sort-Object LastWriteTime -Descending)
    if ($hits.Count -eq 0) { return $null }
    return $hits[0].FullName
}

# -- pre-flight ---------------------------------------------------------------
if (-not (Test-Path $ADAPT))  { throw "xshard_adapt.exe not found: $ADAPT" }
if (-not (Test-Path $SHADER)) { throw "xshard_adapt_fold.cso not found: $SHADER" }

# Resolve working copy path
if (-not $WorkingCopy) {
    if (-not (Test-Path $BaseXShard)) { throw "base xshard not found: $BaseXShard" }
    if (-not (Test-Path $OutDir)) { New-Item -ItemType Directory -Path $OutDir | Out-Null }
    $Stamp = (Get-Date -Format 'yyyyMMdd_HHmmss')
    $WorkingCopy = Join-Path $OutDir "${Name}_adapted_${Stamp}.xshard"
}

$opt = if ($SGD) { 'SGD' } else { 'Adam' }
Write-Host "[gen-adapt] base         : $BaseXShard" -ForegroundColor Cyan
Write-Host "[gen-adapt] working copy : $WorkingCopy"
Write-Host "[gen-adapt] guidance dir : $GuidanceDir"
Write-Host "[gen-adapt] folds        : $($Folds -join ', ')"
Write-Host "[gen-adapt] lr=$LR  wd=$WeightDecay  opt=$opt"
Write-Host ""

# Copy base -> working copy (skip if already exists or DryRun)
if (-not (Test-Path $WorkingCopy)) {
    Write-Host "[gen-adapt] copying base -> working copy..." -ForegroundColor Yellow
    if ($DryRun) {
        Write-Host "  [dry-run] would copy $BaseXShard"
        Write-Host "        ->  $WorkingCopy"
    } else {
        Copy-Item $BaseXShard $WorkingCopy
        Write-Host "  copied OK  ($([math]::Round((Get-Item $WorkingCopy).Length / 1GB, 2)) GB)"
    }
    Write-Host ""
} else {
    Write-Host "[gen-adapt] working copy already exists -- resuming" -ForegroundColor Yellow
    Write-Host ""
}

# -- fold loop ----------------------------------------------------------------
$results = @()
$sep = '-' * 60

foreach ($fold in $Folds) {
    Write-Host "--- fold: $fold $sep" -ForegroundColor Magenta

    $gradXShard = Get-LatestGuidance $fold
    if (-not $gradXShard) {
        $msg = "no guidance xshard for fold=$fold in $GuidanceDir -- run gen-guidance.ps1 first"
        Write-Host "  SKIP: $msg" -ForegroundColor Yellow
        $results += [PSCustomObject]@{ Fold=$fold; OK=$false; Error=$msg }
        continue
    }
    Write-Host "  grad : $gradXShard"

    $maxShards = $FOLD_SHARDS[$fold]
    $ledger    = [System.IO.Path]::ChangeExtension($WorkingCopy, '') + "adapt_${fold}.jsonl"

    $adaptArgs = @(
        $WorkingCopy,
        '--grad-xshard', $gradXShard,
        '--fold',        $fold,
        '--max-shards',  $maxShards,
        '--lr',          $LR,
        '--shader',      $SHADER,
        '--ledger',      $ledger,
        '--apply'
    )
    if ($WeightDecay -gt 0) { $adaptArgs += @('--weight-decay', $WeightDecay) }
    if ($SGD)               { $adaptArgs += '--sgd' }

    if ($DryRun) {
        Write-Host "  [dry-run] xshard_adapt $($adaptArgs -join ' ')" -ForegroundColor Yellow
        $results += [PSCustomObject]@{ Fold=$fold; OK=$true; Error='' }
        Write-Host ""
        continue
    }

    Write-Host "  max-shards=$maxShards  ledger=$(Split-Path $ledger -Leaf)"
    try {
        & $ADAPT @adaptArgs
        if ($LASTEXITCODE -ne 0) { throw "exit $LASTEXITCODE" }
        Write-Host "  done" -ForegroundColor Green
        $results += [PSCustomObject]@{ Fold=$fold; OK=$true; Error='' }
    } catch {
        Write-Host "  FAILED: $($_.Exception.Message)" -ForegroundColor Red
        $results += [PSCustomObject]@{ Fold=$fold; OK=$false; Error=$_.Exception.Message }
    }
    Write-Host ""
}

# -- summary ------------------------------------------------------------------
Write-Host ""
Write-Host "--- Summary $sep" -ForegroundColor Cyan
foreach ($r in $results) {
    $color  = if ($r.OK) { 'Green' } else { 'Red' }
    $status = if ($r.OK) { 'OK  ' } else { 'FAIL' }
    Write-Host "  $status  $($r.Fold)  $($r.Error)" -ForegroundColor $color
}

$failed = @($results | Where-Object { -not $_.OK })
Write-Host ""
if ($failed.Count -gt 0) {
    throw "$($failed.Count) fold(s) failed: $(($failed | ForEach-Object { $_.Fold }) -join ', ')"
}

Write-Host "Adapted xshard: $WorkingCopy" -ForegroundColor Green
Write-Host ""
Write-Host "Convert to GGUF for inference:" -ForegroundColor Yellow
Write-Host "  python tools/xshard_to_gguf.py --input $WorkingCopy --output E:\models\GPT2\adapted\${Name}_adapted.gguf"
Write-Host ""
Write-Host "Or load as runtime guidance delta (scale=1.0 = full adapt, <1.0 = blend):" -ForegroundColor Yellow
foreach ($fold in $Folds) {
    $jbody = '{"source":"file","fold":"' + $fold + '","model":"' + $Name + '","path":"' + $WorkingCopy.Replace('\','\\') + '","scale":1.0}'
    Write-Host "  Invoke-RestMethod -Method POST http://localhost:17474/v1/guidance/swap -Body $jbody"
}
