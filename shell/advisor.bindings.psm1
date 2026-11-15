#Requires -Version 5.1
# advisor.bindings.psm1 — bindings for ADVISOR-µ
# Escalation advisor: Qwen3-4B at http://127.0.0.1:8081/ for coding/reasoning MISS
# Authority: none / proposal_only — all outputs are xcfe_status: pending_admission
# Drivers: Micronaut.Core.dll, CFPC.Patterns.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_AdvisorId  = 'ADVISOR-µ'
$script:_AdvisorBot = Resolve-BusPath 'micronaut/mx2lm-wpf-cli-v1/agents/advisor_bot.py'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-AdvisorMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/advisor.micronaut.json'
}

function Test-AdvisorHealth {
    Test-MicronautHealth -Id $script:_AdvisorId
}

function Get-AdvisorIdentity {
    Get-MicronautIdentity -Id $script:_AdvisorId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-AdvisorMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_AdvisorId -Text $Text -Topic $Topic
}

function Invoke-AdvisorThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_AdvisorId -Text $Text -Context $Context
}

function Read-AdvisorRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_AdvisorId -Key $Key -Category $Category
}

# ── Semantic deltas (read-only — proposal_only / authority none) ───────────────

function Invoke-AdvisorRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_AdvisorId -Resource $Resource -Params $Params
}

function Invoke-AdvisorGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_AdvisorId -ResourceId $ResourceId -Params $Params
}

function Invoke-AdvisorList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_AdvisorId -Scope $Scope -Filter $Filter
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-AdvisorClassify {
    # Pop-phase: matches input against advisor-map.json routes, returns cue type
    param([Parameter(Mandatory)][string]$Input)
    Invoke-AtomicKey -Key 'advisor.classify' -Payload @{ input = $Input }
}

function Invoke-AdvisorQwenEscalate {
    <#.SYNOPSIS
    Sek-phase Qwen3-4B escalation via advisor_bot.py.
    Returns typed proposal (xcfe_status: pending_admission, phase: Sek).
    Cue "reasoning" activates /think chain-of-thought; "coding"/"general" use /no_think.
    #>
    param(
        [Parameter(Mandatory)][string]$Query,
        [ValidateSet('coding','reasoning','general')][string]$Cue = 'general',
        [string]$Context   = '',
        [int]   $MaxTokens = 1024,
        [string]$QwenUrl   = 'http://127.0.0.1:8081'
    )
    if (-not (Test-Path $script:_AdvisorBot)) {
        Write-Warning "Invoke-AdvisorQwenEscalate: advisor_bot.py not found at $script:_AdvisorBot"
        return @{ ok = $false; error = 'advisor_bot.py not found'; source = 'ADVISOR-µ' }
    }
    $pyArgs = @('--query', $Query, '--cue', $Cue, '--max-tokens', $MaxTokens, '--qwen-url', $QwenUrl)
    if (-not [string]::IsNullOrWhiteSpace($Context)) { $pyArgs += @('--context', $Context) }
    try {
        $raw    = & python $script:_AdvisorBot @pyArgs 2>$null
        $result = $raw | ConvertFrom-Json -ErrorAction Stop
        return $result
    } catch {
        return @{ ok = $false; error = $_.Exception.Message; source = 'ADVISOR-µ' }
    }
}

function Invoke-AdvisorPropose {
    # Sek-phase: wraps response into advisor_proposal, writes to gram store
    param([Parameter(Mandatory)][string]$Input, [string]$Cue = '')
    $p = @{ input = $Input }
    if ($Cue) { $p['cue'] = $Cue }
    Invoke-AtomicKey -Key 'advisor.propose' -Payload $p
}

function Invoke-AdvisorVerify {
    # Ch'en-phase: confirms evidence_and_target_present before xcfe admission
    param([Parameter(Mandatory)][hashtable]$Proposal)
    Invoke-AtomicKey -Key 'advisor.verify' -Payload $Proposal
}

function Get-AdvisorStatus {
    # Pop-phase diagnostics: Qwen endpoint liveness, model ID, available cues
    Invoke-AtomicKey -Key 'advisor.health' -Payload @{}
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_AdvisorDrivers = @(
    'Micronaut.Core.dll',
    'CFPC.Patterns.dll'
)

function Import-AdvisorDrivers {
    Import-MicronautDrivers -DriverNames $script:_AdvisorDrivers
}

function Import-AdvisorDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-AdvisorMicronaut, Test-AdvisorHealth, Get-AdvisorIdentity, `
    Invoke-AdvisorMatch, Invoke-AdvisorThink, Read-AdvisorRecall, `
    Invoke-AdvisorRead, Invoke-AdvisorGet, Invoke-AdvisorList, `
    Invoke-AdvisorClassify, Invoke-AdvisorQwenEscalate, `
    Invoke-AdvisorPropose, Invoke-AdvisorVerify, Get-AdvisorStatus, `
    Import-AdvisorDrivers, Import-AdvisorDriver
