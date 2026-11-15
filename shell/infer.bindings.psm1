#Requires -Version 5.1
# infer.bindings.psm1 — bindings for INFER-µ
# Evidence scoring, Bayesian accumulation, Ch'en-phase provenance auditing
# Authority: proposal_only — inference results require XCFE admission
# Drivers: Micronaut.Core.dll, CFPC.Patterns.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_InferId = 'INFER-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-InferMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/infer.micronaut.json'
}

function Test-InferHealth {
    Test-MicronautHealth -Id $script:_InferId
}

function Get-InferIdentity {
    Get-MicronautIdentity -Id $script:_InferId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-InferMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_InferId -Text $Text -Topic $Topic
}

function Invoke-InferAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_InferId -Text $Text -Topic $Topic -That $That
}

function Invoke-InferThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_InferId -Text $Text -Context $Context
}

# ── Semantic deltas (read-only — proposal_only) ───────────────────────────────

function Invoke-InferRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_InferId -Resource $Resource -Params $Params
}

function Invoke-InferGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_InferId -ResourceId $ResourceId -Params $Params
}

function Invoke-InferList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_InferId -Scope $Scope -Filter $Filter
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-InferScore {
    # Yax/Ch'en-phase: score an input claim against evidence graph — returns score, confidence, source_ids
    param([Parameter(Mandatory)][string]$Claim, [string[]]$SourceIds = @())
    $p = @{ claim = $Claim }
    if ($SourceIds.Count) { $p['source_ids'] = $SourceIds }
    Invoke-AtomicKey -Key 'infer.score' -Payload $p
}

function Add-InferAccumulate {
    # Ch'en-phase: Bayesian accumulation — push a new evidence item into the active accumulator
    param([Parameter(Mandatory)][string]$Evidence, [float]$Prior = 0.5, [string]$Category = '')
    $p = @{ evidence = $Evidence; prior = $Prior }
    if ($Category) { $p['category'] = $Category }
    Invoke-AtomicKey -Key 'infer.accumulate' -Payload $p
}

function Get-InferProvenance {
    # Ch'en-phase: return full provenance chain for a scored claim or accumulator output
    param([Parameter(Mandatory)][string]$ClaimId)
    Invoke-AtomicKey -Key 'infer.provenance' -Payload @{ claim_id = $ClaimId }
}

function Get-InferStatus {
    Invoke-AtomicKey -Key 'infer.health' -Payload @{}
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_InferDrivers = @('Micronaut.Core.dll', 'CFPC.Patterns.dll')

function Import-InferDrivers { Import-MicronautDrivers -DriverNames $script:_InferDrivers }

Export-ModuleMember -Function `
    Register-InferMicronaut, Test-InferHealth, Get-InferIdentity, `
    Invoke-InferMatch, Invoke-InferAgent, Invoke-InferThink, `
    Invoke-InferRead, Invoke-InferGet, Invoke-InferList, `
    Invoke-InferScore, Add-InferAccumulate, Get-InferProvenance, Get-InferStatus, `
    Import-InferDrivers
