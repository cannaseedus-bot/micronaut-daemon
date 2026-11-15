#Requires -Version 5.1
# reason.bindings.psm1 — bindings for REASON-µ
# Semantic fold reasoning: graph queries, hylomorphism/semfold, ELIZA-1 operator application
# Authority: proposal_only — results require XCFE admission before dispatch
# Drivers: Micronaut.Core.dll, CFPC.Patterns.dll, Field.Patterns.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_ReasonId = 'REASON-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-ReasonMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/reason.micronaut.json'
}

function Test-ReasonHealth {
    Test-MicronautHealth -Id $script:_ReasonId
}

function Get-ReasonIdentity {
    Get-MicronautIdentity -Id $script:_ReasonId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-ReasonMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_ReasonId -Text $Text -Topic $Topic
}

function Invoke-ReasonAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_ReasonId -Text $Text -Topic $Topic -That $That
}

function Invoke-ReasonThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_ReasonId -Text $Text -Context $Context
}

function Read-ReasonRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_ReasonId -Key $Key -Category $Category
}

# ── Semantic deltas (read-only — proposal_only) ───────────────────────────────

function Invoke-ReasonRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_ReasonId -Resource $Resource -Params $Params
}

function Invoke-ReasonGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_ReasonId -ResourceId $ResourceId -Params $Params
}

function Invoke-ReasonList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_ReasonId -Scope $Scope -Filter $Filter
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-ReasonQuery {
    # Yax/Sek-phase: semantic graph query over relation graph, returns ranked subgraph
    param([Parameter(Mandatory)][string]$Query, [string]$Axis = '', [int]$Depth = 2)
    $p = @{ query = $Query; depth = $Depth }
    if ($Axis) { $p['axis'] = $Axis }
    Invoke-AtomicKey -Key 'reason.query' -Payload $p
}

function Invoke-ReasonFold {
    # Sek-phase: apply hylomorphism/semfold to collapse a fold chain into semantic output
    param([Parameter(Mandatory)][hashtable]$FoldState, [string]$Phase = 'Sek')
    Invoke-AtomicKey -Key 'reason.fold' -Payload @{ fold_state = $FoldState; phase = $Phase }
}

function Invoke-ReasonApply {
    # Sek-phase: apply ELIZA-1 operator set to input text; operator_ref: ELIZA-1.semantic-tracks.v1.json
    param([Parameter(Mandatory)][string]$Input, [string]$Operator = '', [hashtable]$Captures = @{})
    $p = @{ input = $Input }
    if ($Operator)         { $p['operator']  = $Operator }
    if ($Captures.Count)   { $p['captures']  = $Captures }
    Invoke-AtomicKey -Key 'reason.apply' -Payload $p
}

function Get-ReasonStatus {
    Invoke-AtomicKey -Key 'reason.health' -Payload @{}
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_ReasonDrivers = @('Micronaut.Core.dll', 'CFPC.Patterns.dll', 'Field.Patterns.dll')

function Import-ReasonDrivers { Import-MicronautDrivers -DriverNames $script:_ReasonDrivers }

Export-ModuleMember -Function `
    Register-ReasonMicronaut, Test-ReasonHealth, Get-ReasonIdentity, `
    Invoke-ReasonMatch, Invoke-ReasonAgent, Invoke-ReasonThink, Read-ReasonRecall, `
    Invoke-ReasonRead, Invoke-ReasonGet, Invoke-ReasonList, `
    Invoke-ReasonQuery, Invoke-ReasonFold, Invoke-ReasonApply, Get-ReasonStatus, `
    Import-ReasonDrivers
