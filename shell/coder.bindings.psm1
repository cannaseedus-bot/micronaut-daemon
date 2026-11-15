#Requires -Version 5.1
# coder.bindings.psm1 — bindings for CODER-µ
# Full kuhul verb surface: @pattern @agent @call @topic @condition @think @remember @recall @learn @decide @eval @identity
# Drivers: Micronaut.Core.dll, Micronaut.Grammar.dll, Micronaut.Patterns.dll, Micronaut.Compute.dll, NeuralGrammar.Core.dll, Sheogorath.Patterns.dll, native_glyph_engine.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_CoderId = 'CODER-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-CoderMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/micronaut-coder.native.json'
}

function Test-CoderHealth {
    Test-MicronautHealth -Id $script:_CoderId
}

function Get-CoderIdentity {
    Get-MicronautIdentity -Id $script:_CoderId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-CoderMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_CoderId -Text $Text -Topic $Topic
}

function Invoke-CoderAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_CoderId -Text $Text -Topic $Topic -That $That
}

function Invoke-CoderCall {
    param([Parameter(Mandatory)][string]$ToId, [Parameter(Mandatory)][string]$Text, [int]$Depth = 1)
    Invoke-MicronautCall -FromId $script:_CoderId -ToId $ToId -Text $Text -Depth $Depth
}

function Set-CoderTopic {
    param([Parameter(Mandatory)][string]$Topic)
    Set-MicronautTopic -Id $script:_CoderId -Topic $Topic
}

function Test-CoderCondition {
    param([Parameter(Mandatory)][string]$That, [string]$Topic = '')
    Test-MicronautCondition -Id $script:_CoderId -That $That -Topic $Topic
}

function Invoke-CoderThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_CoderId -Text $Text -Context $Context
}

function Write-CoderRemember {
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)]$Value, [string]$Category = '')
    Write-MicronautRemember -Id $script:_CoderId -Key $Key -Value $Value -Category $Category
}

function Read-CoderRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_CoderId -Key $Key -Category $Category
}

function Add-CoderLearn {
    param([Parameter(Mandatory)][string]$Pattern, [Parameter(Mandatory)][string]$Response, [string]$Topic = '')
    Add-MicronautLearn -Id $script:_CoderId -Pattern $Pattern -Response $Response -Topic $Topic
}

function Invoke-CoderDecide {
    param([Parameter(Mandatory)][array]$Options)
    Invoke-MicronautDecide -Id $script:_CoderId -Options $Options
}

function Invoke-CoderEval {
    param([Parameter(Mandatory)][string]$Text, [ValidateSet('person','formal','uppercase','lowercase')][string]$Transform = 'person')
    Invoke-MicronautEval -Id $script:_CoderId -Text $Text -Transform $Transform
}

# ── Semantic deltas ───────────────────────────────────────────────────────────

function Invoke-CoderRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_CoderId -Resource $Resource -Params $Params
}

function Invoke-CoderGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_CoderId -ResourceId $ResourceId -Params $Params
}

function Invoke-CoderList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_CoderId -Scope $Scope -Filter $Filter
}

function Invoke-CoderWrite {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Body)
    Invoke-MicronautWrite -Id $script:_CoderId -Resource $Resource -Body $Body
}

function Invoke-CoderPatch {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Delta)
    Invoke-MicronautPatch -Id $script:_CoderId -Resource $Resource -Delta $Delta
}

function Invoke-CoderPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_CoderId -Action $Action -Body $Body
}

function Invoke-CoderDelete {
    param([Parameter(Mandatory)][string]$ResourceId, [switch]$Confirm)
    Invoke-MicronautDelete -Id $script:_CoderId -ResourceId $ResourceId -Confirm:$Confirm
}

function Invoke-CoderSave {
    param([string]$Scope = '', [hashtable]$Meta = @{})
    Invoke-MicronautSave -Id $script:_CoderId -Scope $Scope -Meta $Meta
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-CoderToolPlan {
    param([Parameter(Mandatory)][string]$Text, [string]$AstContext = '')
    $payload = @{ input = $Text }
    if ($AstContext) { $payload['ast_ctx'] = $AstContext }
    Invoke-AtomicKey -Key 'coder.tool_plan' -Payload $payload
}

function Invoke-CoderQuery {
    param([Parameter(Mandatory)][string]$Text)
    Invoke-AtomicKey -Key 'coder.query' -Payload @{ input = $Text }
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_CoderDrivers = @(
    'Micronaut.Core.dll',
    'Micronaut.Grammar.dll',
    'Micronaut.Patterns.dll',
    'Micronaut.Compute.dll',
    'NeuralGrammar.Core.dll',
    'Sheogorath.Patterns.dll',
    'native_glyph_engine.dll'
)

function Import-CoderDrivers {
    Import-MicronautDrivers -DriverNames $script:_CoderDrivers
}

function Import-CoderDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-CoderMicronaut, Test-CoderHealth, Get-CoderIdentity, `
    Invoke-CoderMatch, Invoke-CoderAgent, Invoke-CoderCall, `
    Set-CoderTopic, Test-CoderCondition, Invoke-CoderThink, `
    Write-CoderRemember, Read-CoderRecall, Add-CoderLearn, `
    Invoke-CoderDecide, Invoke-CoderEval, `
    Invoke-CoderRead, Invoke-CoderGet, Invoke-CoderList, `
    Invoke-CoderWrite, Invoke-CoderPatch, Invoke-CoderPost, `
    Invoke-CoderDelete, Invoke-CoderSave, `
    Invoke-CoderToolPlan, Invoke-CoderQuery, `
    Import-CoderDrivers, Import-CoderDriver
