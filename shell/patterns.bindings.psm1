#Requires -Version 5.1
# patterns.bindings.psm1 — bindings for PATTERNS-µ
# Pattern matching, CFPC intent routing, CHEESE reinforcement scoring, Sheogorath/Jyggalag entropy pipeline
# Sheogorath daemon: port 3213 (Sheogorath.Daemon.dll)
# Authority: xcfe_gated_read_only
# Drivers: Sheogorath.Patterns.dll, Sheogorath.Daemon.dll, Cheese.Critic.dll, CFPC.Patterns.dll, Field.Patterns.dll, Micronaut.Patterns.dll, Pattern.Log.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_PatternsId = 'PATTERNS-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-PatternsMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/patterns.micronaut.json'
}

function Test-PatternsHealth {
    Test-MicronautHealth -Id $script:_PatternsId
}

function Get-PatternsIdentity {
    Get-MicronautIdentity -Id $script:_PatternsId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-PatternsMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_PatternsId -Text $Text -Topic $Topic
}

function Invoke-PatternsAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_PatternsId -Text $Text -Topic $Topic -That $That
}

function Set-PatternsTopic {
    param([Parameter(Mandatory)][string]$Topic)
    Set-MicronautTopic -Id $script:_PatternsId -Topic $Topic
}

function Invoke-PatternsThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_PatternsId -Text $Text -Context $Context
}

function Read-PatternsRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_PatternsId -Key $Key -Category $Category
}

# ── Semantic deltas (read-only — xcfe_gated_read_only) ────────────────────────

function Invoke-PatternsRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_PatternsId -Resource $Resource -Params $Params
}

function Invoke-PatternsGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_PatternsId -ResourceId $ResourceId -Params $Params
}

function Invoke-PatternsList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_PatternsId -Scope $Scope -Filter $Filter
}

function Invoke-PatternsPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_PatternsId -Action $Action -Body $Body
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-PatternsMatchKey {
    # General micronaut pattern match — Micronaut.Patterns.dll → Field.Patterns.dll
    param([Parameter(Mandatory)][string]$Input, [string]$ActiveField = '')
    $p = @{ input = $Input }
    if ($ActiveField) { $p['active_field'] = $ActiveField }
    Invoke-AtomicKey -Key 'patterns.match' -Payload $p
}

function Invoke-PatternsCfpc {
    # CFPC neighborhood_resolve with wildcard captures — context_text, question_templates, field candidate
    param([Parameter(Mandatory)][string]$Input, [int]$MaxHops = 1)
    Invoke-AtomicKey -Key 'patterns.cfpc' -Payload @{ input = $Input; max_hops = $MaxHops }
}

function Invoke-PatternsField {
    # Field-category routing through eliza-field categories via eliza-bias.gml
    param([Parameter(Mandatory)][string]$Input)
    Invoke-AtomicKey -Key 'patterns.field' -Payload @{ input = $Input }
}

function Invoke-PatternsCheese {
    # CHEESE reinforcement score: sqrt(novelty × coherence) — returns score, novelty, coherence, verdict
    param([Parameter(Mandatory)][string]$Candidate, [float]$JyggalagThreshold = 0.85)
    Invoke-AtomicKey -Key 'patterns.cheese' -Payload @{ candidate = $Candidate; jyggalag_threshold = $JyggalagThreshold }
}

function Invoke-PatternsGreymarch {
    # Full Sheogorath entropy expansion (T=0.97 Xul) → CHEESE filter → Jyggalag collapse
    # Sheogorath and Jyggalag are a matched pair — always invoked together
    param([Parameter(Mandatory)][string]$Input, [float]$Temperature = 0.97)
    Invoke-AtomicKey -Key 'patterns.greymarch' -Payload @{ input = $Input; temperature = $Temperature }
}

function Get-PatternsLog {
    # Pattern audit log — recent decisions by query pattern, phase, or outcome
    param([string]$Pattern = '', [string]$Phase = '', [string]$Outcome = '', [int]$Limit = 20)
    $p = @{ limit = $Limit }
    if ($Pattern) { $p['pattern'] = $Pattern }
    if ($Phase)   { $p['phase']   = $Phase }
    if ($Outcome) { $p['outcome'] = $Outcome }
    Invoke-AtomicKey -Key 'patterns.log' -Payload $p
}

function Get-PatternsStatus {
    Invoke-AtomicKey -Key 'patterns.health' -Payload @{}
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_PatternsDrivers = @(
    'Sheogorath.Patterns.dll',
    'Sheogorath.Daemon.dll',
    'Cheese.Critic.dll',
    'CFPC.Patterns.dll',
    'Field.Patterns.dll',
    'Micronaut.Patterns.dll',
    'Pattern.Log.dll'
)

function Import-PatternsDrivers {
    Import-MicronautDrivers -DriverNames $script:_PatternsDrivers
}

function Import-PatternsDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-PatternsMicronaut, Test-PatternsHealth, Get-PatternsIdentity, `
    Invoke-PatternsMatch, Invoke-PatternsAgent, Set-PatternsTopic, `
    Invoke-PatternsThink, Read-PatternsRecall, `
    Invoke-PatternsRead, Invoke-PatternsGet, Invoke-PatternsList, Invoke-PatternsPost, `
    Invoke-PatternsMatchKey, Invoke-PatternsCfpc, Invoke-PatternsField, `
    Invoke-PatternsCheese, Invoke-PatternsGreymarch, Get-PatternsLog, Get-PatternsStatus, `
    Import-PatternsDrivers, Import-PatternsDriver
