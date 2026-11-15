#Requires -Version 5.1
# vector.bindings.psm1 — bindings for VECTOR-µ
# EmbeddingGemma-backed AIML similarity matching, SRAI chain, mesh feature projection
# Authority: data_only — vector similarity does NOT establish executability; XCFE must validate
# Script: agents/vector_match_bot.py (port 3220)
# Drivers: Micronaut.Core.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_VectorId   = 'VECTOR-µ'
$script:_VectorBot  = Resolve-BusPath 'key-grammar-kit/agents/vector_match_bot.py'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-VectorMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/vector.micronaut.json'
}

function Test-VectorHealth {
    Test-MicronautHealth -Id $script:_VectorId
}

function Get-VectorIdentity {
    Get-MicronautIdentity -Id $script:_VectorId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-VectorMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_VectorId -Text $Text -Topic $Topic
}

function Invoke-VectorAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_VectorId -Text $Text -Topic $Topic -That $That
}

function Invoke-VectorThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_VectorId -Text $Text -Context $Context
}

# ── Semantic deltas (read-only — data_only) ───────────────────────────────────

function Invoke-VectorRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_VectorId -Resource $Resource -Params $Params
}

function Invoke-VectorGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_VectorId -ResourceId $ResourceId -Params $Params
}

function Invoke-VectorList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_VectorId -Scope $Scope -Filter $Filter
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Search-VectorMatch {
    # Wo/Yax-phase: cosine similarity match against AIML category corpus
    # Returns top-K candidates: pattern, template, score, field_scope, wildcard_count
    param([Parameter(Mandatory)][string]$Input, [int]$TopK = 5, [string]$FieldScope = '')
    $p = @{ input = $Input; topk = $TopK }
    if ($FieldScope) { $p['field_scope'] = $FieldScope }
    Invoke-AtomicKey -Key 'vector.match' -Payload $p
}

function Invoke-VectorProject {
    # Wo-phase: mesh_feature_projection_gate — relation-conditioned geometry projection
    # Returns semantic_geodesic_distance; does not establish executability
    param([Parameter(Mandatory)][hashtable]$FoldState, [string]$PrincipalDirection = '')
    $p = @{ fold_state = $FoldState }
    if ($PrincipalDirection) { $p['principal_direction'] = $PrincipalDirection }
    Invoke-AtomicKey -Key 'vector.project' -Payload $p
}

function Invoke-VectorSrai {
    # Yax-phase: recursive SRAI chain (max_depth 3) — EMBED→RETRIEVE→FILTER→RANK→FOLD
    # xcfe_required — proposal is xcfe_status: pending_admission on return
    param([Parameter(Mandatory)][string]$Input, [int]$MaxDepth = 3)
    Invoke-AtomicKey -Key 'vector.srai' -Payload @{ input = $Input; max_depth = $MaxDepth }
}

function Get-VectorEmbed {
    # Wo-phase: generate 256-dim L2-normalised float32 EmbeddingGemma vector
    param([Parameter(Mandatory)][string]$Input)
    Invoke-AtomicKey -Key 'vector.embed' -Payload @{ input = $Input }
}

function Get-VectorStatus {
    Invoke-AtomicKey -Key 'vector.health' -Payload @{}
}

# ── Direct script call (bypass daemon — health/test only) ─────────────────────

function Test-VectorBotDirect {
    param([string]$Input = 'ping', [int]$Port = 3220)
    if (-not $script:_VectorBot) { Write-Warning 'vector_match_bot.py path not resolved'; return $null }
    & python $script:_VectorBot '--input' $Input '--port' $Port 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_VectorDrivers = @('Micronaut.Core.dll')

function Import-VectorDrivers { Import-MicronautDrivers -DriverNames $script:_VectorDrivers }

Export-ModuleMember -Function `
    Register-VectorMicronaut, Test-VectorHealth, Get-VectorIdentity, `
    Invoke-VectorMatch, Invoke-VectorAgent, Invoke-VectorThink, `
    Invoke-VectorRead, Invoke-VectorGet, Invoke-VectorList, `
    Search-VectorMatch, Invoke-VectorProject, Invoke-VectorSrai, `
    Get-VectorEmbed, Get-VectorStatus, Test-VectorBotDirect, `
    Import-VectorDrivers
