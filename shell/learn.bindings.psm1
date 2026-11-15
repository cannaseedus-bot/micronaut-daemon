#Requires -Version 5.1
# learn.bindings.psm1 — bindings for LEARN-µ
# Phase-keyed micronaut evolution, chat scoring, semantic factory, field-query ngram
# Authority: evolve_only — may write .learning/ and evolve seed micronauts
# Drivers: Micronaut.Core.dll, Micronaut.Memory.dll, Micronaut.Reward.dll, Micronaut.Evolution.dll,
#          micronaut_evolution.dll, Micronaut.Compute.dll, micronaut_factory_bridge.dll, micronaut_factory_core.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_LearnId = 'LEARN-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-LearnMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/learn.micronaut.json'
}

function Test-LearnHealth {
    Test-MicronautHealth -Id $script:_LearnId
}

function Get-LearnIdentity {
    Get-MicronautIdentity -Id $script:_LearnId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-LearnMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_LearnId -Text $Text -Topic $Topic
}

function Invoke-LearnThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_LearnId -Text $Text -Context $Context
}

function Read-LearnRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_LearnId -Key $Key -Category $Category
}

function Add-LearnLearn {
    param([Parameter(Mandatory)][string]$Pattern, [Parameter(Mandatory)][string]$Response, [string]$Topic = '')
    Add-MicronautLearn -Id $script:_LearnId -Pattern $Pattern -Response $Response -Topic $Topic
}

# ── Semantic deltas (read + write for evolve_only authority) ──────────────────

function Invoke-LearnRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_LearnId -Resource $Resource -Params $Params
}

function Invoke-LearnGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_LearnId -ResourceId $ResourceId -Params $Params
}

function Invoke-LearnList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_LearnId -Scope $Scope -Filter $Filter
}

function Invoke-LearnPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_LearnId -Action $Action -Body $Body
}

function Invoke-LearnWrite {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Body)
    Invoke-MicronautWrite -Id $script:_LearnId -Resource $Resource -Body $Body
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Get-LearnPhaseState {
    # Read current engine phase state from .learning/phase_state.json
    Invoke-AtomicKey -Key 'learn.phase_state' -Payload @{}
}

function Save-LearnChat {
    # Persist a chat interaction record to .learning/chats/<id>.json
    param([Parameter(Mandatory)][hashtable]$ChatRecord)
    Invoke-AtomicKey -Key 'learn.store_chat' -Payload $ChatRecord
}

function Add-LearnScore {
    # Record a quality evaluation entry (0-100) to .learning/evaluations.jsonl
    param([Parameter(Mandatory)][string]$InteractionId, [Parameter(Mandatory)][float]$Quality,
          [string]$Phase = '', [string]$Topic = '')
    $p = @{ interaction_id = $InteractionId; quality = $Quality }
    if ($Phase) { $p['phase'] = $Phase }
    if ($Topic) { $p['topic'] = $Topic }
    Invoke-AtomicKey -Key 'learn.score' -Payload $p
}

function Get-LearnRecall {
    # Retrieve scored chat records or seed micronauts by topic/phase/quality threshold
    param([string]$Topic = '', [string]$Phase = '', [float]$MinQuality = 0.0, [int]$Limit = 10)
    $p = @{ min_quality = $MinQuality; limit = $Limit }
    if ($Topic) { $p['topic'] = $Topic }
    if ($Phase) { $p['phase'] = $Phase }
    Invoke-AtomicKey -Key 'learn.recall' -Payload $p
}

function Invoke-LearnEvolve {
    # Run Micronaut.Evolution.dll evolution pass on a seed micronaut — xcfe_required
    param([Parameter(Mandatory)][string]$SeedId, [string]$Domain = '', [string]$Phase = '')
    $p = @{ seed_id = $SeedId }
    if ($Domain) { $p['domain'] = $Domain }
    if ($Phase)  { $p['phase']  = $Phase }
    Invoke-AtomicKey -Key 'learn.evolve' -Payload $p
}

function Invoke-LearnFieldQuery {
    # XQuery over data/mx2lm.vectors.safetensors ngram field via field_query.py
    param([Parameter(Mandatory)][string]$Query, [string]$Axis = 'Wo')
    Invoke-AtomicKey -Key 'learn.query_field' -Payload @{ query = $Query; axis = $Axis }
}

function Invoke-LearnFactoryResearch {
    # Create semantic driver JSON from text via factory_research.py
    param([Parameter(Mandatory)][string]$Text, [string]$Slug = '', [switch]$WithEliza, [switch]$WithAiml)
    $p = @{ text = $Text }
    if ($Slug)      { $p['slug']       = $Slug }
    if ($WithEliza) { $p['emit_eliza'] = $true }
    if ($WithAiml)  { $p['emit_aiml']  = $true }
    Invoke-AtomicKey -Key 'learn.factory_research' -Payload $p
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_LearnDrivers = @(
    'Micronaut.Core.dll',
    'Micronaut.Memory.dll',
    'Micronaut.Reward.dll',
    'Micronaut.Evolution.dll',
    'micronaut_evolution.dll',
    'Micronaut.Compute.dll',
    'micronaut_factory_bridge.dll',
    'micronaut_factory_core.dll'
)

function Import-LearnDrivers {
    Import-MicronautDrivers -DriverNames $script:_LearnDrivers
}

function Import-LearnDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-LearnMicronaut, Test-LearnHealth, Get-LearnIdentity, `
    Invoke-LearnMatch, Invoke-LearnThink, Read-LearnRecall, Add-LearnLearn, `
    Invoke-LearnRead, Invoke-LearnGet, Invoke-LearnList, Invoke-LearnPost, Invoke-LearnWrite, `
    Get-LearnPhaseState, Save-LearnChat, Add-LearnScore, Get-LearnRecall, `
    Invoke-LearnEvolve, Invoke-LearnFieldQuery, Invoke-LearnFactoryResearch, `
    Import-LearnDrivers, Import-LearnDriver
