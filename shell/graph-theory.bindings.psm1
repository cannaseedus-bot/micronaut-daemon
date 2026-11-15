#Requires -Version 5.1
# graph-theory.bindings.psm1 — bindings for GRAPH-THEORY-µ
# Full kuhul verb surface: @pattern @agent @call @topic @condition @think @remember @recall @learn @decide @eval @identity
# Drivers: dag.dll, NeuralGrammar.Core.dll, Micronaut.Core.dll, Micronaut.Patterns.dll, Micronaut.Grammar.dll, CFPC.Patterns.dll, Field.Patterns.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_GTId = 'micronaut:GRAPH-THEORY'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-GraphTheoryMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/graph-theory-micronaut.v1.json'
}

function Test-GraphTheoryHealth {
    Test-MicronautHealth -Id $script:_GTId
}

function Get-GraphTheoryIdentity {
    Get-MicronautIdentity -Id $script:_GTId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-GraphTheoryMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_GTId -Text $Text -Topic $Topic
}

function Invoke-GraphTheoryAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_GTId -Text $Text -Topic $Topic -That $That
}

function Invoke-GraphTheoryCall {
    param([Parameter(Mandatory)][string]$ToId, [Parameter(Mandatory)][string]$Text, [int]$Depth = 1)
    Invoke-MicronautCall -FromId $script:_GTId -ToId $ToId -Text $Text -Depth $Depth
}

function Set-GraphTheoryTopic {
    param([Parameter(Mandatory)][string]$Topic)
    Set-MicronautTopic -Id $script:_GTId -Topic $Topic
}

function Test-GraphTheoryCondition {
    param([Parameter(Mandatory)][string]$That, [string]$Topic = '')
    Test-MicronautCondition -Id $script:_GTId -That $That -Topic $Topic
}

function Invoke-GraphTheoryThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_GTId -Text $Text -Context $Context
}

function Write-GraphTheoryRemember {
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)]$Value, [string]$Category = '')
    Write-MicronautRemember -Id $script:_GTId -Key $Key -Value $Value -Category $Category
}

function Read-GraphTheoryRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_GTId -Key $Key -Category $Category
}

function Add-GraphTheoryLearn {
    param([Parameter(Mandatory)][string]$Pattern, [Parameter(Mandatory)][string]$Response, [string]$Topic = '')
    Add-MicronautLearn -Id $script:_GTId -Pattern $Pattern -Response $Response -Topic $Topic
}

function Invoke-GraphTheoryDecide {
    param([Parameter(Mandatory)][array]$Options)
    Invoke-MicronautDecide -Id $script:_GTId -Options $Options
}

function Invoke-GraphTheoryEval {
    param([Parameter(Mandatory)][string]$Text, [ValidateSet('person','formal','uppercase','lowercase')][string]$Transform = 'person')
    Invoke-MicronautEval -Id $script:_GTId -Text $Text -Transform $Transform
}

# ── Semantic deltas ───────────────────────────────────────────────────────────

function Invoke-GraphTheoryRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_GTId -Resource $Resource -Params $Params
}

function Invoke-GraphTheoryGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_GTId -ResourceId $ResourceId -Params $Params
}

function Invoke-GraphTheoryList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_GTId -Scope $Scope -Filter $Filter
}

function Invoke-GraphTheoryWrite {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Body)
    Invoke-MicronautWrite -Id $script:_GTId -Resource $Resource -Body $Body
}

function Invoke-GraphTheoryPatch {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Delta)
    Invoke-MicronautPatch -Id $script:_GTId -Resource $Resource -Delta $Delta
}

function Invoke-GraphTheoryPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_GTId -Action $Action -Body $Body
}

function Invoke-GraphTheoryDelete {
    param([Parameter(Mandatory)][string]$ResourceId, [switch]$Confirm)
    Invoke-MicronautDelete -Id $script:_GTId -ResourceId $ResourceId -Confirm:$Confirm
}

function Invoke-GraphTheorySave {
    param([string]$Scope = '', [hashtable]$Meta = @{})
    Invoke-MicronautSave -Id $script:_GTId -Scope $Scope -Meta $Meta
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-GraphTheoryQuery {
    param([Parameter(Mandatory)][string]$Text, [string]$GraphId = '')
    $payload = @{ input = $Text }
    if ($GraphId) { $payload['graph_id'] = $GraphId }
    Invoke-AtomicKey -Key 'graph-theory.query' -Payload $payload
}

function Invoke-GraphNeighborhoodQuery {
    param([string]$GraphId, [string]$NodeId, [int]$Depth = 1)
    Invoke-AtomicKey -Key 'graph-theory.query' -Payload @{
        graph_id = $GraphId; node_id = $NodeId; depth = $Depth; query_type = 'neighborhood'
    }
}

function Invoke-GraphPathQuery {
    param([string]$GraphId, [string]$From, [string]$To)
    Invoke-AtomicKey -Key 'graph-theory.query' -Payload @{
        graph_id = $GraphId; from = $From; to = $To; query_type = 'path'
    }
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_GTDrivers = @(
    'dag.dll',
    'NeuralGrammar.Core.dll',
    'Micronaut.Core.dll',
    'Micronaut.Patterns.dll',
    'Micronaut.Grammar.dll',
    'CFPC.Patterns.dll',
    'Field.Patterns.dll'
)

function Import-GraphTheoryDrivers {
    Import-MicronautDrivers -DriverNames $script:_GTDrivers
}

function Import-GraphTheoryDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-GraphTheoryMicronaut, Test-GraphTheoryHealth, Get-GraphTheoryIdentity, `
    Invoke-GraphTheoryMatch, Invoke-GraphTheoryAgent, Invoke-GraphTheoryCall, `
    Set-GraphTheoryTopic, Test-GraphTheoryCondition, Invoke-GraphTheoryThink, `
    Write-GraphTheoryRemember, Read-GraphTheoryRecall, Add-GraphTheoryLearn, `
    Invoke-GraphTheoryDecide, Invoke-GraphTheoryEval, `
    Invoke-GraphTheoryRead, Invoke-GraphTheoryGet, Invoke-GraphTheoryList, `
    Invoke-GraphTheoryWrite, Invoke-GraphTheoryPatch, Invoke-GraphTheoryPost, `
    Invoke-GraphTheoryDelete, Invoke-GraphTheorySave, `
    Invoke-GraphTheoryQuery, Invoke-GraphNeighborhoodQuery, Invoke-GraphPathQuery, `
    Import-GraphTheoryDrivers, Import-GraphTheoryDriver
