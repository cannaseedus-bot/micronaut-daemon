#Requires -Version 5.1
# orch.bindings.psm1 — bindings for ORCH-µ
# Orchestration: relational routing, call dispatch, composition planning, knowledge-gap routing
# Authority: proposal_only — dispatch proposals require XCFE admission
# Drivers: Micronaut.Core.dll, CFPC.Patterns.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_OrchId = 'ORCH-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-OrchMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/orch.micronaut.json'
}

function Test-OrchHealth {
    Test-MicronautHealth -Id $script:_OrchId
}

function Get-OrchIdentity {
    Get-MicronautIdentity -Id $script:_OrchId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-OrchMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_OrchId -Text $Text -Topic $Topic
}

function Invoke-OrchAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_OrchId -Text $Text -Topic $Topic -That $That
}

function Invoke-OrchCall {
    param([Parameter(Mandatory)][string]$ToId, [Parameter(Mandatory)][string]$Text, [int]$Depth = 1)
    Invoke-MicronautCall -FromId $script:_OrchId -ToId $ToId -Text $Text -Depth $Depth
}

function Set-OrchTopic {
    param([Parameter(Mandatory)][string]$Topic)
    Set-MicronautTopic -Id $script:_OrchId -Topic $Topic
}

function Invoke-OrchThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_OrchId -Text $Text -Context $Context
}

function Read-OrchRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_OrchId -Key $Key -Category $Category
}

# ── Semantic deltas (read-only — proposal_only) ───────────────────────────────

function Invoke-OrchRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_OrchId -Resource $Resource -Params $Params
}

function Invoke-OrchGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_OrchId -ResourceId $ResourceId -Params $Params
}

function Invoke-OrchList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_OrchId -Scope $Scope -Filter $Filter
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-OrchRoute {
    # Pop/Wo-phase: select target micronaut from governs registry
    param([Parameter(Mandatory)][string]$Input, [int]$TopK = 3)
    Invoke-AtomicKey -Key 'orch.route' -Payload @{ input = $Input; topk = $TopK }
}

function Invoke-OrchPlan {
    # Wo/Yax-phase: compose multi-step dispatch plan
    param([Parameter(Mandatory)][string]$Input, [string[]]$TargetIds = @())
    $p = @{ input = $Input }
    if ($TargetIds.Count -gt 0) { $p['target_ids'] = $TargetIds }
    Invoke-AtomicKey -Key 'orch.plan' -Payload $p
}

function Invoke-OrchDispatch {
    # Ch'en-phase: emit xcfe-gated dispatch call proposal to target micronaut
    param([Parameter(Mandatory)][string]$TargetId, [Parameter(Mandatory)][string]$Input, [string]$Phase = '')
    $p = @{ target_id = $TargetId; input = $Input }
    if ($Phase) { $p['phase'] = $Phase }
    Invoke-AtomicKey -Key 'orch.dispatch' -Payload $p
}

function Invoke-OrchVerify {
    # Ch'en/Xul-phase: verify result returned from dispatched micronaut
    param([Parameter(Mandatory)][hashtable]$Result)
    Invoke-AtomicKey -Key 'orch.verify' -Payload $Result
}

function Get-OrchStatus {
    Invoke-AtomicKey -Key 'orch.health' -Payload @{}
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_OrchDrivers = @('Micronaut.Core.dll', 'CFPC.Patterns.dll')

function Import-OrchDrivers { Import-MicronautDrivers -DriverNames $script:_OrchDrivers }

Export-ModuleMember -Function `
    Register-OrchMicronaut, Test-OrchHealth, Get-OrchIdentity, `
    Invoke-OrchMatch, Invoke-OrchAgent, Invoke-OrchCall, `
    Set-OrchTopic, Invoke-OrchThink, Read-OrchRecall, `
    Invoke-OrchRead, Invoke-OrchGet, Invoke-OrchList, `
    Invoke-OrchRoute, Invoke-OrchPlan, Invoke-OrchDispatch, Invoke-OrchVerify, Get-OrchStatus, `
    Import-OrchDrivers
