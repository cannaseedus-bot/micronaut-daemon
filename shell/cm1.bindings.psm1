#Requires -Version 5.1
# cm1.bindings.psm1 — bindings for CM-1-µ (control micronaut)
# Full kuhul verb surface: @pattern @agent @call @topic @condition @think @remember @recall @learn @decide @eval @identity
# Drivers: Micronaut.Core.dll, Sheogorath.Daemon.dll, micronaut_factory_core.dll, micronaut_factory_bridge.dll, Pattern.Log.dll, micronaut_evolution.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_CM1Id = 'CM-1-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-CM1Micronaut {
    Register-Micronaut -BridgePath 'data/micronauts/control-micronaut-1.json'
}

function Test-CM1Health {
    Test-MicronautHealth -Id $script:_CM1Id
}

function Get-CM1Identity {
    Get-MicronautIdentity -Id $script:_CM1Id
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-CM1Match {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_CM1Id -Text $Text -Topic $Topic
}

function Invoke-CM1Agent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_CM1Id -Text $Text -Topic $Topic -That $That
}

function Invoke-CM1Call {
    param([Parameter(Mandatory)][string]$ToId, [Parameter(Mandatory)][string]$Text, [int]$Depth = 1)
    Invoke-MicronautCall -FromId $script:_CM1Id -ToId $ToId -Text $Text -Depth $Depth
}

function Set-CM1Topic {
    param([Parameter(Mandatory)][string]$Topic)
    Set-MicronautTopic -Id $script:_CM1Id -Topic $Topic
}

function Test-CM1Condition {
    param([Parameter(Mandatory)][string]$That, [string]$Topic = '')
    Test-MicronautCondition -Id $script:_CM1Id -That $That -Topic $Topic
}

function Invoke-CM1Think {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_CM1Id -Text $Text -Context $Context
}

function Write-CM1Remember {
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)]$Value, [string]$Category = '')
    Write-MicronautRemember -Id $script:_CM1Id -Key $Key -Value $Value -Category $Category
}

function Read-CM1Recall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_CM1Id -Key $Key -Category $Category
}

function Add-CM1Learn {
    param([Parameter(Mandatory)][string]$Pattern, [Parameter(Mandatory)][string]$Response, [string]$Topic = '')
    Add-MicronautLearn -Id $script:_CM1Id -Pattern $Pattern -Response $Response -Topic $Topic
}

function Invoke-CM1Decide {
    param([Parameter(Mandatory)][array]$Options)
    Invoke-MicronautDecide -Id $script:_CM1Id -Options $Options
}

function Invoke-CM1Eval {
    param([Parameter(Mandatory)][string]$Text, [ValidateSet('person','formal','uppercase','lowercase')][string]$Transform = 'person')
    Invoke-MicronautEval -Id $script:_CM1Id -Text $Text -Transform $Transform
}

# ── Semantic deltas ───────────────────────────────────────────────────────────

function Invoke-CM1Read {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_CM1Id -Resource $Resource -Params $Params
}

function Invoke-CM1Get {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_CM1Id -ResourceId $ResourceId -Params $Params
}

function Invoke-CM1List {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_CM1Id -Scope $Scope -Filter $Filter
}

function Invoke-CM1Write {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Body)
    Invoke-MicronautWrite -Id $script:_CM1Id -Resource $Resource -Body $Body
}

function Invoke-CM1Patch {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Delta)
    Invoke-MicronautPatch -Id $script:_CM1Id -Resource $Resource -Delta $Delta
}

function Invoke-CM1Post {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_CM1Id -Action $Action -Body $Body
}

function Invoke-CM1Delete {
    param([Parameter(Mandatory)][string]$ResourceId, [switch]$Confirm)
    Invoke-MicronautDelete -Id $script:_CM1Id -ResourceId $ResourceId -Confirm:$Confirm
}

function Invoke-CM1Save {
    param([string]$Scope = '', [hashtable]$Meta = @{})
    Invoke-MicronautSave -Id $script:_CM1Id -Scope $Scope -Meta $Meta
}

# ── Domain-specific: control stream and π-tick ────────────────────────────────

function Invoke-CM1ControlStream {
    <#.SYNOPSIS Encode a control program string and dispatch through the CM-1 control stream.#>
    param([Parameter(Mandatory)][string]$ControlProgram)
    Invoke-AtomicKey -Key 'cm1.control_stream' -Payload @{ program = $ControlProgram }
}

function Invoke-CM1PiTick {
    param([string]$Phase = 'PI/2')
    Invoke-AtomicKey -Key 'cm1.pi_tick' -Payload @{ phase = $Phase }
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_CM1Drivers = @(
    'Micronaut.Core.dll',
    'Sheogorath.Daemon.dll',
    'micronaut_factory_core.dll',
    'micronaut_factory_bridge.dll',
    'Pattern.Log.dll',
    'micronaut_evolution.dll'
)

function Import-CM1Drivers {
    Import-MicronautDrivers -DriverNames $script:_CM1Drivers
}

function Import-CM1Driver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-CM1Micronaut, Test-CM1Health, Get-CM1Identity, `
    Invoke-CM1Match, Invoke-CM1Agent, Invoke-CM1Call, `
    Set-CM1Topic, Test-CM1Condition, Invoke-CM1Think, `
    Write-CM1Remember, Read-CM1Recall, Add-CM1Learn, `
    Invoke-CM1Decide, Invoke-CM1Eval, `
    Invoke-CM1Read, Invoke-CM1Get, Invoke-CM1List, `
    Invoke-CM1Write, Invoke-CM1Patch, Invoke-CM1Post, `
    Invoke-CM1Delete, Invoke-CM1Save, `
    Invoke-CM1ControlStream, Invoke-CM1PiTick, `
    Import-CM1Drivers, Import-CM1Driver
