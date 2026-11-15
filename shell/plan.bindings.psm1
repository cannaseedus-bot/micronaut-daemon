#Requires -Version 5.1
# plan.bindings.psm1 — bindings for PLAN-µ
# Task decomposition, ordering, kuhul.plan.v1 emission — Wo/Yax/Sek/Ch'en phases
# Authority: proposal_only — plan.emit requires XCFE admission
# Drivers: Micronaut.Core.dll, CFPC.Patterns.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_PlanId = 'PLAN-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-PlanMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/plan.micronaut.json'
}

function Test-PlanHealth {
    Test-MicronautHealth -Id $script:_PlanId
}

function Get-PlanIdentity {
    Get-MicronautIdentity -Id $script:_PlanId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-PlanMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_PlanId -Text $Text -Topic $Topic
}

function Invoke-PlanAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_PlanId -Text $Text -Topic $Topic -That $That
}

function Invoke-PlanThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_PlanId -Text $Text -Context $Context
}

function Read-PlanRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_PlanId -Key $Key -Category $Category
}

# ── Semantic deltas (read-only — proposal_only) ───────────────────────────────

function Invoke-PlanRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_PlanId -Resource $Resource -Params $Params
}

function Invoke-PlanGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_PlanId -ResourceId $ResourceId -Params $Params
}

function Invoke-PlanList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_PlanId -Scope $Scope -Filter $Filter
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-PlanDecompose {
    # Wo/Yax-phase: decompose a goal into discrete subtasks with phase assignments
    param([Parameter(Mandatory)][string]$Goal, [int]$MaxTasks = 8)
    Invoke-AtomicKey -Key 'plan.decompose' -Payload @{ goal = $Goal; max_tasks = $MaxTasks }
}

function Invoke-PlanOrder {
    # Yax-phase: sort and dependency-chain a decomposed task list
    param([Parameter(Mandatory)][hashtable[]]$Tasks)
    Invoke-AtomicKey -Key 'plan.order' -Payload @{ tasks = $Tasks }
}

function Invoke-PlanEmit {
    # Sek-phase: emit a kuhul.plan.v1 structured plan proposal — xcfe_required
    param([Parameter(Mandatory)][string]$Goal, [hashtable[]]$Tasks = @(), [string]$Domain = '')
    $p = @{ goal = $Goal; tasks = $Tasks }
    if ($Domain) { $p['domain'] = $Domain }
    Invoke-AtomicKey -Key 'plan.emit' -Payload $p
}

function Invoke-PlanVerify {
    # Ch'en-phase: verify a plan proposal for completeness, phase validity, and dependency integrity
    param([Parameter(Mandatory)][hashtable]$Plan)
    Invoke-AtomicKey -Key 'plan.verify' -Payload $Plan
}

function Get-PlanStatus {
    Invoke-AtomicKey -Key 'plan.health' -Payload @{}
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_PlanDrivers = @('Micronaut.Core.dll', 'CFPC.Patterns.dll')

function Import-PlanDrivers { Import-MicronautDrivers -DriverNames $script:_PlanDrivers }

Export-ModuleMember -Function `
    Register-PlanMicronaut, Test-PlanHealth, Get-PlanIdentity, `
    Invoke-PlanMatch, Invoke-PlanAgent, Invoke-PlanThink, Read-PlanRecall, `
    Invoke-PlanRead, Invoke-PlanGet, Invoke-PlanList, `
    Invoke-PlanDecompose, Invoke-PlanOrder, Invoke-PlanEmit, Invoke-PlanVerify, Get-PlanStatus, `
    Import-PlanDrivers
