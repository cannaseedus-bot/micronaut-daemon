#Requires -Version 5.1
# memory.bindings.psm1 — bindings for MEMORY-µ
# Long-term semantic memory: Xul-phase xcfe-gated save/forget, Pop/Yax recall/journal
# Authority: xcfe_gated_read_only — memory.save and memory.forget require XCFE admission
# Drivers: Micronaut.Core.dll, Micronaut.Memory.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_MemoryId = 'MEMORY-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-MemoryMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/memory.micronaut.json'
}

function Test-MemoryHealth {
    Test-MicronautHealth -Id $script:_MemoryId
}

function Get-MemoryIdentity {
    Get-MicronautIdentity -Id $script:_MemoryId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-MemoryMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_MemoryId -Text $Text -Topic $Topic
}

function Invoke-MemoryThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_MemoryId -Text $Text -Context $Context
}

function Read-MemoryRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_MemoryId -Key $Key -Category $Category
}

# ── Semantic deltas ───────────────────────────────────────────────────────────

function Invoke-MemoryRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_MemoryId -Resource $Resource -Params $Params
}

function Invoke-MemoryGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_MemoryId -ResourceId $ResourceId -Params $Params
}

function Invoke-MemoryList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_MemoryId -Scope $Scope -Filter $Filter
}

function Invoke-MemoryPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_MemoryId -Action $Action -Body $Body
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Save-MemorySave {
    # Xul-phase: persist a long-term memory item — xcfe_required
    # categories: preference | session_context | micronaut_data
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)][object]$Value,
          [ValidateSet('preference','session_context','micronaut_data')][string]$Category = 'session_context',
          [string]$Topic = '')
    $p = @{ key = $Key; value = $Value; category = $Category }
    if ($Topic) { $p['topic'] = $Topic }
    Invoke-AtomicKey -Key 'memory.save' -Payload $p
}

function Get-MemoryRecall {
    # Pop/Yax-phase: semantic recall from long-term memory
    param([string]$Topic = '', [string]$Category = '', [int]$Limit = 10)
    $p = @{ limit = $Limit }
    if ($Topic)    { $p['topic']    = $Topic }
    if ($Category) { $p['category'] = $Category }
    Invoke-AtomicKey -Key 'memory.recall' -Payload $p
}

function Remove-MemoryForget {
    # Xul-phase: remove a long-term memory entry — xcfe_required
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    $p = @{ key = $Key }
    if ($Category) { $p['category'] = $Category }
    Invoke-AtomicKey -Key 'memory.forget' -Payload $p
}

function Get-MemoryJournal {
    # Pop-phase: return recent memory journal entries (read-only)
    param([int]$Limit = 20, [string]$Since = '')
    $p = @{ limit = $Limit }
    if ($Since) { $p['since'] = $Since }
    Invoke-AtomicKey -Key 'memory.journal' -Payload $p
}

function Get-MemoryStatus {
    Invoke-AtomicKey -Key 'memory.health' -Payload @{}
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_MemoryDrivers = @('Micronaut.Core.dll', 'Micronaut.Memory.dll')

function Import-MemoryDrivers { Import-MicronautDrivers -DriverNames $script:_MemoryDrivers }

Export-ModuleMember -Function `
    Register-MemoryMicronaut, Test-MemoryHealth, Get-MemoryIdentity, `
    Invoke-MemoryMatch, Invoke-MemoryThink, Read-MemoryRecall, `
    Invoke-MemoryRead, Invoke-MemoryGet, Invoke-MemoryList, Invoke-MemoryPost, `
    Save-MemorySave, Get-MemoryRecall, Remove-MemoryForget, Get-MemoryJournal, Get-MemoryStatus, `
    Import-MemoryDrivers
