#Requires -Version 5.1
# eliza.bindings.psm1 — bindings for ELIZA-µ
# Field-biased pattern engine: 6-field routing (eliza-bias.gml), SRAI bridge, xcfe_gated_read_only
# Drivers: Micronaut.Core.dll, CFPC.Patterns.dll, Field.Patterns.dll, ELIZA.Patterns.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_ElizaId = 'ELIZA-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-ElizaMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/eliza.micronaut.json'
}

function Test-ElizaHealth {
    Test-MicronautHealth -Id $script:_ElizaId
}

function Get-ElizaIdentity {
    Get-MicronautIdentity -Id $script:_ElizaId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-ElizaMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_ElizaId -Text $Text -Topic $Topic
}

function Invoke-ElizaAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_ElizaId -Text $Text -Topic $Topic -That $That
}

function Invoke-ElizaCall {
    param([Parameter(Mandatory)][string]$ToId, [Parameter(Mandatory)][string]$Text, [int]$Depth = 1)
    Invoke-MicronautCall -FromId $script:_ElizaId -ToId $ToId -Text $Text -Depth $Depth
}

function Set-ElizaTopic {
    param([Parameter(Mandatory)][string]$Topic)
    Set-MicronautTopic -Id $script:_ElizaId -Topic $Topic
}

function Invoke-ElizaThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_ElizaId -Text $Text -Context $Context
}

function Read-ElizaRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_ElizaId -Key $Key -Category $Category
}

function Invoke-ElizaDecide {
    param([Parameter(Mandatory)][array]$Options)
    Invoke-MicronautDecide -Id $script:_ElizaId -Options $Options
}

# ── Semantic deltas (read + post — xcfe_gated_read_only, no Write/Delete/Save) ─

function Invoke-ElizaRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_ElizaId -Resource $Resource -Params $Params
}

function Invoke-ElizaGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_ElizaId -ResourceId $ResourceId -Params $Params
}

function Invoke-ElizaList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_ElizaId -Scope $Scope -Filter $Filter
}

function Invoke-ElizaPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_ElizaId -Action $Action -Body $Body
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-ElizaBank {
    # Pop-phase pattern dispatch: synonym_collapse → manifest_lookup → field-scoped best match
    param([Parameter(Mandatory)][string]$Input, [string]$ActiveField = '')
    $p = @{ input = $Input }
    if ($ActiveField) { $p['active_field'] = $ActiveField }
    Invoke-AtomicKey -Key 'eliza.bank' -Payload $p
}

function Invoke-ElizaFieldRoute {
    # Wo-phase: routes input to one of 6 fields (⟁GENERAL_QA/⟁REFLECTION/⟁CONVERSATION/⟁KNOWLEDGE/⟁REASONING/⟁FALLBACK)
    param([Parameter(Mandatory)][string]$Input)
    Invoke-AtomicKey -Key 'eliza.field' -Payload @{ input = $Input }
}

function Invoke-ElizaBiasRank {
    # Wo-phase: applies eliza-bias.gml default_bias weights to rank candidates in active field
    param([Parameter(Mandatory)][string]$Input, [string]$ActiveField = '')
    $p = @{ input = $Input; op = 'bias_rank' }
    if ($ActiveField) { $p['active_field'] = $ActiveField }
    Invoke-AtomicKey -Key 'eliza.field' -Payload $p
}

function Invoke-ElizaRule {
    # Yax-phase: ELIZA:IF/THEN/ELSE rule check, emits kuhul.eliza.chen_accumulator
    param([Parameter(Mandatory)][string]$Input, [string]$Candidate = '', [string]$ActiveField = '')
    $p = @{ input = $Input }
    if ($Candidate)   { $p['candidate']    = $Candidate }
    if ($ActiveField) { $p['active_field'] = $ActiveField }
    Invoke-AtomicKey -Key 'eliza.rule' -Payload $p
}

function Invoke-ElizaOperator {
    # Pop/Sek-phase: detects one of 16 ELIZA-1 reasoning operators in input
    param([Parameter(Mandatory)][string]$Input)
    Invoke-AtomicKey -Key 'eliza.operator' -Payload @{ input = $Input }
}

function Invoke-ElizaSrai {
    # Ch'en-phase: SRAI bridge — receives chen_accumulator, resolves <srai> chain, emits routing proposal
    param([Parameter(Mandatory)][hashtable]$ChenAccumulator)
    Invoke-AtomicKey -Key 'eliza.srai' -Payload $ChenAccumulator
}

function Invoke-ElizaReflect {
    # Xul-phase: template fill + gramWrite — requires xcfe_admitted guard
    param([Parameter(Mandatory)][string]$Input, [hashtable]$Captures = @{})
    $p = @{ input = $Input }
    if ($Captures.Count -gt 0) { $p['wildcard_captures'] = $Captures }
    Invoke-AtomicKey -Key 'eliza.reflect' -Payload $p
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_ElizaDrivers = @(
    'Micronaut.Core.dll',
    'CFPC.Patterns.dll',
    'Field.Patterns.dll',
    'ELIZA.Patterns.dll'
)

function Import-ElizaDrivers {
    Import-MicronautDrivers -DriverNames $script:_ElizaDrivers
}

function Import-ElizaDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-ElizaMicronaut, Test-ElizaHealth, Get-ElizaIdentity, `
    Invoke-ElizaMatch, Invoke-ElizaAgent, Invoke-ElizaCall, `
    Set-ElizaTopic, Invoke-ElizaThink, Read-ElizaRecall, Invoke-ElizaDecide, `
    Invoke-ElizaRead, Invoke-ElizaGet, Invoke-ElizaList, Invoke-ElizaPost, `
    Invoke-ElizaBank, Invoke-ElizaFieldRoute, Invoke-ElizaBiasRank, `
    Invoke-ElizaRule, Invoke-ElizaOperator, Invoke-ElizaSrai, Invoke-ElizaReflect, `
    Import-ElizaDrivers, Import-ElizaDriver
