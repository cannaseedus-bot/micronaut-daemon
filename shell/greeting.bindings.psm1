#Requires -Version 5.1
# greeting.bindings.psm1 — bindings for GREETING-µ
# Semantic intake pipeline: prompt decomposition → WordKeyField → intent graph → CFPC gap →
# routing proposal → xcfe_admitted dispatch. Logs all transitions via Pattern.Log.dll.
# Authority: xcfe_gated_read_only / proposal_only (greeting.route is xcfe_required)
# Drivers: Micronaut.Core.dll, CFPC.Patterns.dll, Field.Patterns.dll, Micronaut.Patterns.dll, Pattern.Log.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_GreetingId = 'GREETING-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-GreetingMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/greeting.micronaut.json'
}

function Test-GreetingHealth {
    Test-MicronautHealth -Id $script:_GreetingId
}

function Get-GreetingIdentity {
    Get-MicronautIdentity -Id $script:_GreetingId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-GreetingMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_GreetingId -Text $Text -Topic $Topic
}

function Invoke-GreetingAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_GreetingId -Text $Text -Topic $Topic -That $That
}

function Invoke-GreetingCall {
    param([Parameter(Mandatory)][string]$ToId, [Parameter(Mandatory)][string]$Text, [int]$Depth = 1)
    Invoke-MicronautCall -FromId $script:_GreetingId -ToId $ToId -Text $Text -Depth $Depth
}

function Set-GreetingTopic {
    param([Parameter(Mandatory)][string]$Topic)
    Set-MicronautTopic -Id $script:_GreetingId -Topic $Topic
}

function Invoke-GreetingThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_GreetingId -Text $Text -Context $Context
}

function Read-GreetingRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_GreetingId -Key $Key -Category $Category
}

function Write-GreetingRemember {
    # gramWrite allowed for lingo absorption and ngram archival (observe_only learning)
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)]$Value, [string]$Category = '')
    Write-MicronautRemember -Id $script:_GreetingId -Key $Key -Value $Value -Category $Category
}

# ── Semantic deltas (read + post; gramWrite via Write-GreetingRemember) ────────

function Invoke-GreetingRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_GreetingId -Resource $Resource -Params $Params
}

function Invoke-GreetingGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_GreetingId -ResourceId $ResourceId -Params $Params
}

function Invoke-GreetingList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_GreetingId -Scope $Scope -Filter $Filter
}

function Invoke-GreetingPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_GreetingId -Action $Action -Body $Body
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-GreetingBank {
    # Pop-phase quick key: selects phase-keyed template from greeting-bank.json
    # GREETING_ONLY intent resolves here and suppresses escalation
    param([Parameter(Mandatory)][string]$Input, [string]$Cue = '', [string]$Lingo = '')
    $p = @{ input = $Input }
    if ($Cue)   { $p['cue']   = $Cue }
    if ($Lingo) { $p['lingo'] = $Lingo }
    Invoke-AtomicKey -Key 'greeting.bank' -Payload $p
}

function Invoke-GreetingIntent {
    # Wo-phase: intent-graph.gml traversal, bigram candidate unfolding, max_depth 4
    param([Parameter(Mandatory)][string]$Input, [int]$MaxDepth = 4)
    Invoke-AtomicKey -Key 'greeting.intent' -Payload @{ input = $Input; max_depth = $MaxDepth }
}

function Invoke-GreetingCfpc {
    # Yax-phase: CFPC gap bitmap — Resolved/IntentGap/QueryGap/KnowledgeGapNoKeys/KnowledgeGapNoValues
    param([Parameter(Mandatory)][string]$Input)
    Invoke-AtomicKey -Key 'greeting.cfpc' -Payload @{ input = $Input }
}

function Invoke-GreetingEscalate {
    # Sek-phase: gyro_abi track scoring + xcfe routing proposal to top-ranked µ-track
    # Pass IntentDimension to constrain: ⟁EVIDENCE, ⟁INFER, ⟁FIELD, ⟁VERIFY
    param([Parameter(Mandatory)][string]$Input, [string]$IntentDimension = '')
    $p = @{ input = $Input }
    if ($IntentDimension) { $p['intent_dimension'] = $IntentDimension }
    Invoke-AtomicKey -Key 'greeting.escalate' -Payload $p
}

function Invoke-GreetingLingo {
    # Xul-phase: absorb lingo cues, archive greeting ngrams, adapt style for future templates
    param([Parameter(Mandatory)][string]$Input)
    Invoke-AtomicKey -Key 'greeting.lingo' -Payload @{ input = $Input }
}

function Get-GreetingStatus {
    # Pop-phase diagnostics: intent-graph traversal, greeting-bank coverage, gyro_abi map, CFPC status, Pattern.Log.dll status, WordKeyField schema version
    Invoke-AtomicKey -Key 'greeting.health' -Payload @{}
}

# ── Decompose / Route / Log (v2 pipeline) ─────────────────────────────────────

function Invoke-GreetingDecompose {
    # Pop-phase prompt decomposition → kuhul.word-key-field.v1 payload.
    # Tokenize → n-gram extraction (1–4) → ⟁KEY assignment → semantic role tagging →
    # typed edge construction → code_signal detection → anaphoric tagging → unresolved set.
    # Runs for ALL inputs before any other greeting key. Logs to Pattern.Log.dll.
    param(
        [Parameter(Mandatory)][string]$Input,
        [string]$SessionId = ''
    )
    $p = @{ input = $Input }
    if ($SessionId) { $p['session_id'] = $SessionId }
    Invoke-AtomicKey -Key 'greeting.decompose' -Payload $p
}

function Invoke-GreetingRoute {
    # Yax/Sek-phase routing proposal — consults gyro_track_map keyed by top intent.
    # Requires WordKeyField (from Invoke-GreetingDecompose) with gap_type set by Invoke-GreetingCfpc.
    # Produces WordKeyField.routing: primary_target, escalation_path, xcfe_status=pending_admission.
    # xcfe_required: XCFE must admit before greeting.escalate fires. Logs to Pattern.Log.dll.
    param(
        [Parameter(Mandatory)][hashtable]$WordKeyField,
        [string]$IntentOverride = ''
    )
    $p = @{ word_key_field = $WordKeyField }
    if ($IntentOverride) { $p['intent_override'] = $IntentOverride }
    Invoke-AtomicKey -Key 'greeting.route' -Payload $p
}

function Write-GreetingLog {
    # Append-only log entry to Pattern.Log.dll via greeting.log atomic key.
    # source_hash is the correlation key — supply it for every entry in a pipeline run.
    param(
        [Parameter(Mandatory)][string]$Operation,
        [Parameter(Mandatory)][string]$Phase,
        [hashtable]$Payload     = @{},
        [string]$SourceHash     = '',
        [string]$SessionId      = ''
    )
    $entry = @{
        micronaut  = $script:_GreetingId
        operation  = $Operation
        phase      = $Phase
        timestamp  = (Get-Date).ToUniversalTime().ToString('o')
    }
    if ($SourceHash) { $entry['source_hash'] = $SourceHash }
    if ($SessionId)  { $entry['session_id']  = $SessionId }
    if ($Payload.Count) { $entry['payload_summary'] = $Payload }
    Invoke-AtomicKey -Key 'greeting.log' -Payload $entry
}

function Invoke-GreetingPipeline {
    # Full GREETING-µ pipeline: decompose → intent → cfpc → (bank for GREETING_ONLY | route for all others).
    # Returns the WordKeyField with routing populated, or the bank response for pure salutations.
    param(
        [Parameter(Mandatory)][string]$Input,
        [string]$SessionId   = '',
        [string]$Cue         = '',
        [switch]$LogSteps
    )
    $wkf = Invoke-GreetingDecompose -Input $Input -SessionId $SessionId
    if ($LogSteps) { Write-GreetingLog -Operation 'decompose' -Phase 'Pop' -SourceHash $wkf.source_hash -SessionId $SessionId }

    $intentResult = Invoke-GreetingIntent -Input $Input
    if ($LogSteps) { Write-GreetingLog -Operation 'intent_graph_traverse' -Phase 'Wo' -SourceHash $wkf.source_hash -Payload @{ top_intent = $intentResult.top_intent } }

    $cfpcResult = Invoke-GreetingCfpc -Input $Input
    if ($LogSteps) { Write-GreetingLog -Operation 'cfpc_gap_classify' -Phase 'Wo' -SourceHash $wkf.source_hash -Payload @{ gap_type = $cfpcResult.gap_type } }

    # Fast-path: pure salutation stays with ELIZA-µ via greeting.bank
    $topIntent = $intentResult.top_intent
    $gapType   = $cfpcResult.gap_type
    if ($topIntent -eq 'GREETING_ONLY' -and $gapType -eq 'Resolved') {
        $bankResult = Invoke-GreetingBank -Input $Input -Cue $Cue
        if ($LogSteps) { Write-GreetingLog -Operation 'greeting_bank_select' -Phase 'Yax' -SourceHash $wkf.source_hash }
        return $bankResult
    }

    # All other intents: produce routing proposal
    $routeResult = Invoke-GreetingRoute -WordKeyField $wkf
    if ($LogSteps) { Write-GreetingLog -Operation 'route' -Phase 'Yax' -SourceHash $wkf.source_hash -Payload @{ primary_target = $routeResult.routing.primary_target; gap_type = $gapType } }
    return $routeResult
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_GreetingDrivers = @(
    'Micronaut.Core.dll',
    'CFPC.Patterns.dll',
    'Field.Patterns.dll',
    'Micronaut.Patterns.dll',
    'Pattern.Log.dll'
)

function Import-GreetingDrivers {
    Import-MicronautDrivers -DriverNames $script:_GreetingDrivers
}

function Import-GreetingDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-GreetingMicronaut, Test-GreetingHealth, Get-GreetingIdentity, `
    Invoke-GreetingMatch, Invoke-GreetingAgent, Invoke-GreetingCall, `
    Set-GreetingTopic, Invoke-GreetingThink, `
    Read-GreetingRecall, Write-GreetingRemember, `
    Invoke-GreetingRead, Invoke-GreetingGet, Invoke-GreetingList, Invoke-GreetingPost, `
    Invoke-GreetingBank, Invoke-GreetingIntent, Invoke-GreetingCfpc, `
    Invoke-GreetingEscalate, Invoke-GreetingLingo, Get-GreetingStatus, `
    Invoke-GreetingDecompose, Invoke-GreetingRoute, Write-GreetingLog, Invoke-GreetingPipeline, `
    Import-GreetingDrivers, Import-GreetingDriver
