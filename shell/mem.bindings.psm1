#Requires -Version 5.1
# mem.bindings.psm1 — bindings for MEM-µ
# Short-term gram-store: Pop-phase read/recall/replay, Pop/Xul-phase xcfe-gated write
# Authority: xcfe_gated_read_only — mem.store requires XCFE admission
# Drivers: Micronaut.Core.dll, Micronaut.Memory.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_MemId = 'MEM-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-MemMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/mem.micronaut.json'
}

function Test-MemHealth {
    Test-MicronautHealth -Id $script:_MemId
}

function Get-MemIdentity {
    Get-MicronautIdentity -Id $script:_MemId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-MemMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_MemId -Text $Text -Topic $Topic
}

function Invoke-MemThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_MemId -Text $Text -Context $Context
}

function Read-MemRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_MemId -Key $Key -Category $Category
}

# ── Semantic deltas ───────────────────────────────────────────────────────────

function Invoke-MemRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_MemId -Resource $Resource -Params $Params
}

function Invoke-MemGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_MemId -ResourceId $ResourceId -Params $Params
}

function Invoke-MemList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_MemId -Scope $Scope -Filter $Filter
}

function Invoke-MemPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_MemId -Action $Action -Body $Body
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Get-MemRead {
    # Pop-phase: read gram-store record by key/category
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    $p = @{ key = $Key }
    if ($Category) { $p['category'] = $Category }
    Invoke-AtomicKey -Key 'mem.read' -Payload $p
}

function Save-MemStore {
    # Pop/Xul-phase: write record to gram-store — xcfe_required
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)][object]$Value, [string]$Category = '')
    $p = @{ key = $Key; value = $Value }
    if ($Category) { $p['category'] = $Category }
    Invoke-AtomicKey -Key 'mem.store' -Payload $p
}

function Invoke-MemRecall {
    # Pop-phase: semantic recall from gram-store by topic/phase proximity
    param([string]$Topic = '', [string]$Phase = '', [int]$Limit = 5)
    $p = @{ limit = $Limit }
    if ($Topic) { $p['topic'] = $Topic }
    if ($Phase) { $p['phase'] = $Phase }
    Invoke-AtomicKey -Key 'mem.recall' -Payload $p
}

function Invoke-MemReplay {
    # Pop/Wo-phase: replay a stored gram sequence to reconstruct fold context
    param([Parameter(Mandatory)][string]$SessionId, [int]$MaxSteps = 10)
    Invoke-AtomicKey -Key 'mem.replay' -Payload @{ session_id = $SessionId; max_steps = $MaxSteps }
}

function Get-MemStatus {
    Invoke-AtomicKey -Key 'mem.health' -Payload @{}
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_MemDrivers = @('Micronaut.Core.dll', 'Micronaut.Memory.dll')

function Import-MemDrivers { Import-MicronautDrivers -DriverNames $script:_MemDrivers }

Export-ModuleMember -Function `
    Register-MemMicronaut, Test-MemHealth, Get-MemIdentity, `
    Invoke-MemMatch, Invoke-MemThink, Read-MemRecall, `
    Invoke-MemRead, Invoke-MemGet, Invoke-MemList, Invoke-MemPost, `
    Get-MemRead, Save-MemStore, Invoke-MemRecall, Invoke-MemReplay, Get-MemStatus, `
    Import-MemDrivers
