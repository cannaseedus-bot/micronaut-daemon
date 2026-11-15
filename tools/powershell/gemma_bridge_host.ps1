param(
    [ValidateSet('Daemon', 'Attest')]
    [string]$Mode = 'Daemon',
    [string]$Utterance,
    [string]$RequestFile,
    [string[]]$DaemonArgs = @()
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..')).Path
$envFile = Join-Path $root '.env'
if (-not (Test-Path -LiteralPath $envFile -PathType Leaf)) {
    throw 'Missing workspace .env with MICRONAUT_GEMMA_ATTEST_KEY.'
}
$entries = @([System.IO.File]::ReadAllLines($envFile) | Where-Object { $_.Trim().Length -gt 0 })
$keyMatch = if ($entries.Count -eq 1) {
    [regex]::Match($entries[0], '^MICRONAUT_GEMMA_ATTEST_KEY=([0-9a-f]{64})$')
}
if ($entries.Count -ne 1 -or -not $keyMatch.Success) {
    throw 'Invalid .env: expected one 64-character lowercase hex MICRONAUT_GEMMA_ATTEST_KEY.'
}
$attestKey = $keyMatch.Groups[1].Value
$priorKey = [Environment]::GetEnvironmentVariable('MICRONAUT_GEMMA_ATTEST_KEY', 'Process')
$priorGate = [Environment]::GetEnvironmentVariable('MICRONAUT_GEMMA_BRIDGE', 'Process')
$priorAimlGguf = [Environment]::GetEnvironmentVariable('MICRONAUT_AIML_GGUF', 'Process')

try {
    [Environment]::SetEnvironmentVariable('MICRONAUT_GEMMA_ATTEST_KEY', $attestKey, 'Process')
    Push-Location -LiteralPath $root
    try {
        if ($Mode -eq 'Attest') {
            if ([string]::IsNullOrWhiteSpace($Utterance)) {
                throw 'Attest mode requires -Utterance.'
            }
            $attestor = Join-Path $root 'tools/attest_gemma_query.py'
            if ($PSVersionTable.PSVersion.Major -lt 7) {
                $priorErrorAction = $ErrorActionPreference
                try {
                    $ErrorActionPreference = 'SilentlyContinue'
                    & python $attestor $Utterance 2>$null
                    $attestorExit = $LASTEXITCODE
                } finally {
                    $ErrorActionPreference = $priorErrorAction
                }
                if ($attestorExit -ne 0) { throw "Query attestor exited with code $attestorExit." }
            } else {
                & python $attestor $Utterance 2>$null
                if ($LASTEXITCODE -ne 0) { throw "Query attestor exited with code $LASTEXITCODE." }
            }
        } else {
            [Environment]::SetEnvironmentVariable('MICRONAUT_GEMMA_BRIDGE', '1', 'Process')
            $runtimeGguf = Join-Path $root 'build/alice.aiml.gguf'
            if (Test-Path -LiteralPath $runtimeGguf -PathType Leaf) {
                [Environment]::SetEnvironmentVariable('MICRONAUT_AIML_GGUF', $runtimeGguf, 'Process')
            }
            $daemonName = 'eliza-' + [char]0x00b5 + '.exe'
            $daemon = Join-Path $root "build/gml-stage1/Release/$daemonName"
            if (-not (Test-Path -LiteralPath $daemon -PathType Leaf)) {
                throw "Built daemon not found at build/gml-stage1/Release/$daemonName."
            }
            if ($RequestFile) {
                if (-not (Test-Path -LiteralPath $RequestFile -PathType Leaf)) {
                    throw 'Request file not found.'
                }
                Get-Content -LiteralPath $RequestFile -Encoding UTF8 | & $daemon @DaemonArgs
            } else {
                & $daemon @DaemonArgs
            }
            if ($LASTEXITCODE -ne 0) { throw "Daemon exited with code $LASTEXITCODE." }
        }
    } finally {
        Pop-Location
    }
} finally {
    [Environment]::SetEnvironmentVariable('MICRONAUT_GEMMA_ATTEST_KEY', $priorKey, 'Process')
    [Environment]::SetEnvironmentVariable('MICRONAUT_GEMMA_BRIDGE', $priorGate, 'Process')
    [Environment]::SetEnvironmentVariable('MICRONAUT_AIML_GGUF', $priorAimlGguf, 'Process')
}
