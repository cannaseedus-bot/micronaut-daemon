#Requires -Version 5.1
# gen-guidance-all.ps1 -- generate guidance xshards for all 6 folds
#
# Uses qwen2.5-instruct-f32.xshard as the base (only F32 xshard currently available).
# When gemma/lfm/qwen3/oss F32 xshards are created via gguf_to_xshard.py, run with
#   -Name gemma -BaseXShard E:\models\GPT2\gemma\gemma-3-1b-f32.xshard
# etc. to generate model-specific guidance.
#
# Usage:
#   .\gen-guidance-all.ps1                              # all 6 folds, qwen base
#   .\gen-guidance-all.ps1 -Name gemma -BaseXShard ...  # all 6 folds, gemma base
#   .\gen-guidance-all.ps1 -Folds Sek,Chen              # specific folds only
#   .\gen-guidance-all.ps1 -DryRun                      # preview paths without writing

param(
    [string]   $Name       = 'qwen',
    [string]   $BaseXShard = 'E:\models\GPT2\qwen2.5-instruct-f32.xshard',
    [string[]] $Folds      = @('Pop','Wo','Yax','Sek','Chen','Xul'),
    [float]    $GradScale   = 1e-3,
    [float]    $WeightScale = 1e-4,
    [int]      $MaxShards   = 294,
    [switch]   $DryRun
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$GEN = Join-Path $PSScriptRoot 'gen-guidance.ps1'
if (-not (Test-Path $GEN)) { throw "gen-guidance.ps1 not found at $GEN" }

$results = @()
$sep = '-' * 60

foreach ($fold in $Folds) {
    Write-Host ''
    Write-Host "--- fold: $fold $sep" -ForegroundColor Magenta

    $params = @{
        Name        = $Name
        Fold        = $fold
        BaseXShard  = $BaseXShard
        GradScale   = $GradScale
        WeightScale = $WeightScale
        MaxShards   = $MaxShards
    }
    if ($DryRun) { $params['DryRun'] = $true }

    $ok = $true
    $err = ''
    try {
        & $GEN @params
    } catch {
        $ok = $false
        $err = $_.Exception.Message
        Write-Host "[gen-guidance-all] ERROR fold=$fold : $err" -ForegroundColor Red
    }

    $results += [PSCustomObject]@{ Fold = $fold; OK = $ok; Error = $err }
}

Write-Host ''
Write-Host "--- Summary $sep" -ForegroundColor Cyan
foreach ($r in $results) {
    $color  = if ($r.OK) { 'Green' } else { 'Red' }
    $status = if ($r.OK) { 'OK  ' } else { 'FAIL' }
    Write-Host "  $status  $($r.Fold)  $($r.Error)" -ForegroundColor $color
}

Write-Host ''
$failed = @($results | Where-Object { -not $_.OK })
if ($failed.Count -gt 0) {
    throw "$($failed.Count) fold(s) failed: $(($failed | ForEach-Object { $_.Fold }) -join ', ')"
}

Write-Host "All $($Folds.Count) guidance xshards ready in E:\models\GPT2\guidance" -ForegroundColor Green
Write-Host ''
Write-Host 'Register each fold via kuhul-server guidance/swap:' -ForegroundColor Yellow
foreach ($fold in $Folds) {
    $jbody = '{"source":"xshard","fold":"' + $fold + '","model":"' + $Name + '","scale":0.1}'
    Write-Host "  Invoke-RestMethod -Method POST http://localhost:17474/v1/guidance/swap -Body $jbody"
}
