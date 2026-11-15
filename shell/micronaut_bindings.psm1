#Requires -Version 5.1
<#
  micronaut_bindings.psm1 — Micronaut bus
  All micronauts call these functions instead of hardcoding daemon URLs or manifest paths.
  Import this module once; per-micronaut PSM1 files re-export named wrappers on top of it.
#>

$script:BusRoot     = $PSScriptRoot | Split-Path -Parent
$script:KitRoot     = Join-Path $script:BusRoot 'key-grammar-kit'
$script:TracksRoot  = Join-Path $script:KitRoot  'data\tracks'
$script:BridgesRoot = Join-Path $script:KitRoot  'data\micronauts'
$script:DriversRoot = Join-Path $script:BusRoot  'drivers'
$script:ShellRoot   = $PSScriptRoot

$script:BusConfig = @{
    AimlApiBase  = 'http://127.0.0.1:3217'
    AppHostBase  = 'http://127.0.0.1:17885'
    PreviewBase  = 'http://127.0.0.1:5000'
    Timeout      = 15
}

$script:BusRegistry   = [System.Collections.Generic.Dictionary[string,hashtable]]::new()
$script:LoadedDrivers = [System.Collections.Generic.HashSet[string]]::new()

# optional local AIML matcher fallback (loaded on first use if daemon is offline)
$script:LocalMatcher  = $null

function _EnsureLocalMatcher {
    if ($null -eq $script:LocalMatcher) {
        $matcherMod = Join-Path $script:ShellRoot 'aiml_matcher.psm1'
        if (Test-Path $matcherMod) {
            try {
                Import-Module $matcherMod -Force -ErrorAction Stop
                $script:LocalMatcher = New-AimlMatcher
            } catch {
                Write-Warning "bus: aiml_matcher.psm1 load failed: $($_.Exception.Message)"
            }
        }
    }
    return $script:LocalMatcher
}


# ── Config ────────────────────────────────────────────────────────────────────

function Set-BusConfig {
    param(
        [string]$AimlApiBase,
        [string]$AppHostBase,
        [string]$PreviewBase,
        [int]$Timeout
    )
    if ($AimlApiBase) { $script:BusConfig.AimlApiBase = $AimlApiBase }
    if ($AppHostBase) { $script:BusConfig.AppHostBase = $AppHostBase }
    if ($PreviewBase) { $script:BusConfig.PreviewBase = $PreviewBase }
    if ($Timeout -gt 0) { $script:BusConfig.Timeout = $Timeout }
}

function Get-BusConfig { $script:BusConfig.Clone() }


# ── Internal HTTP ─────────────────────────────────────────────────────────────

function _BusPost([string]$Url, [hashtable]$Body) {
    try {
        $json = $Body | ConvertTo-Json -Depth 8 -Compress
        $resp = Invoke-RestMethod -Method POST -Uri $Url `
                    -Body $json -ContentType 'application/json; charset=utf-8' `
                    -TimeoutSec $script:BusConfig.Timeout -ErrorAction Stop
        return $resp
    } catch {
        return @{ error = $_.Exception.Message; ok = $false }
    }
}

function _BusGet([string]$Url) {
    try {
        return Invoke-RestMethod -Method GET -Uri $Url `
                   -TimeoutSec $script:BusConfig.Timeout -ErrorAction Stop
    } catch {
        return @{ error = $_.Exception.Message; ok = $false }
    }
}


# ── Path resolution ───────────────────────────────────────────────────────────

function Resolve-BusPath([string]$RelPath) {
    if ([IO.Path]::IsPathRooted($RelPath)) { return $RelPath }
    $fromKit  = Join-Path $script:KitRoot $RelPath
    if (Test-Path $fromKit) { return $fromKit }
    $fromRoot = Join-Path $script:BusRoot $RelPath
    if (Test-Path $fromRoot) { return $fromRoot }
    return $fromKit
}


# ── Registry ──────────────────────────────────────────────────────────────────

function Register-Micronaut {
    <#.SYNOPSIS Load a bridge JSON and its track, add to the bus registry.#>
    param(
        [Parameter(Mandatory)][string]$BridgePath,
        [switch]$Force
    )
    $abs = Resolve-BusPath $BridgePath
    if (-not (Test-Path $abs)) { Write-Warning "Register-Micronaut: bridge not found: $abs"; return $null }

    $bridge = Get-Content $abs -Raw | ConvertFrom-Json
    $id = [string]($bridge.identity.id)
    if (-not $id) { $id = [string]($bridge.id) }   # kuhul.micronaut.atomic.v1 uses top-level id
    if (-not $id) { Write-Warning "Register-Micronaut: bridge has no identity.id or id"; return $null }

    if ($script:BusRegistry.ContainsKey($id) -and -not $Force) { return $script:BusRegistry[$id] }

    $track = $null
    if ($bridge.track_ref) {
        $trackAbs = Resolve-BusPath $bridge.track_ref
        if (Test-Path $trackAbs) {
            $track = Get-Content $trackAbs -Raw | ConvertFrom-Json
        }
    }

    $entry = @{
        id          = $id
        bridge      = $bridge
        track       = $track
        bridge_path = $abs
        loaded_at   = [datetime]::UtcNow
    }
    $script:BusRegistry[$id] = $entry
    return $entry
}

function Unregister-Micronaut([string]$Id) {
    $script:BusRegistry.Remove($Id) | Out-Null
}

function Get-MicronautBridge([string]$Id) {
    if ($script:BusRegistry.ContainsKey($Id)) { return $script:BusRegistry[$Id].bridge }
    return $null
}

function Get-MicronautTrack([string]$Id) {
    if ($script:BusRegistry.ContainsKey($Id)) { return $script:BusRegistry[$Id].track }
    return $null
}

function Get-MicronautList {
    $script:BusRegistry.Keys | Sort-Object
}

function Get-MicronautEntry([string]$Id) {
    if ($script:BusRegistry.ContainsKey($Id)) { return $script:BusRegistry[$Id] }
    return $null
}


# ── Match / Atomic ────────────────────────────────────────────────────────────

function Invoke-MicronautMatch {
    <#.SYNOPSIS Route text through a micronaut — sets topic scope, calls AIML match.
    Falls back to the local aiml_matcher.psm1 when the daemon is unreachable.#>
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Text,
        [string]$Topic = ''
    )
    $entry = $script:BusRegistry[$Id]
    if (-not $entry) { return @{ error = "micronaut '$Id' not registered"; matched = $false } }

    $bridge   = $entry.bridge
    $topicVal = if ($Topic) { $Topic } elseif ($bridge.patterns.topic_scope) { [string]$bridge.patterns.topic_scope } else { '' }

    $url  = "$($script:BusConfig.AimlApiBase -replace '/$','')/match"
    $body = @{ text = $Text; topic = $topicVal; micronaut_id = $Id }
    $result = _BusPost $url $body

    # local fallback when daemon is offline
    if ($result.error -and (_EnsureLocalMatcher)) {
        $hit = $script:LocalMatcher.Match($Text, $topicVal, '')
        if ($hit.Hit) {
            return @{
                matched      = $true
                micronaut_id = $hit.MicronautId
                pattern      = $hit.MatchedPattern
                stars        = $hit.Stars
                confidence   = $hit.Confidence
                source       = 'local_matcher'
            }
        }
        return @{ matched = $false; source = 'local_matcher' }
    }

    return $result
}

function Invoke-AtomicKey {
    <#.SYNOPSIS Call any atomic key via POST /api/atomic/call.#>
    param(
        [Parameter(Mandatory)][string]$Key,
        [hashtable]$Payload = @{}
    )
    $Payload['key'] = $Key
    $url = "$($script:BusConfig.PreviewBase -replace '/$','')/api/atomic/call"
    return _BusPost $url $Payload
}

function Invoke-MicronautAtomicKey {
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$KeySuffix,
        [hashtable]$Payload = @{}
    )
    $entry = $script:BusRegistry[$Id]
    if (-not $entry) { return @{ error = "micronaut '$Id' not registered" } }
    $ns  = [string]$entry.bridge.api.namespace
    return Invoke-AtomicKey -Key "$ns.$KeySuffix" -Payload $Payload
}


# ── Health ────────────────────────────────────────────────────────────────────

function Test-MicronautHealth {
    param([string]$Id = '')
    $url = "$($script:BusConfig.AimlApiBase -replace '/$','')/health"
    $result = _BusGet $url
    if ($Id -and $script:BusRegistry.ContainsKey($Id)) {
        $result | Add-Member -NotePropertyName 'micronaut_id' -NotePropertyValue $Id -Force
    }
    return $result
}

function Get-AimlStats {
    $url = "$($script:BusConfig.AimlApiBase -replace '/$','')/stats"
    return _BusGet $url
}

function Invoke-AimlReload {
    $url = "$($script:BusConfig.AimlApiBase -replace '/$','')/reload"
    return _BusPost $url @{}
}


# ── Drivers ───────────────────────────────────────────────────────────────────

function Import-MicronautDrivers {
    <#.SYNOPSIS Load driver DLLs from drivers/ for a micronaut. Skips already-loaded.#>
    param([string[]]$DriverNames)
    $loaded = @()
    $failed = @()
    foreach ($name in $DriverNames) {
        if ($script:LoadedDrivers.Contains($name)) { $loaded += $name; continue }
        $path = Join-Path $script:DriversRoot $name
        if (-not (Test-Path $path)) { $failed += $name; continue }
        try {
            [System.Reflection.Assembly]::LoadFrom($path) | Out-Null
            [void]$script:LoadedDrivers.Add($name)
            $loaded += $name
        } catch {
            $failed += $name
            Write-Warning "Import-MicronautDrivers: failed to load '$name': $($_.Exception.Message)"
        }
    }
    return @{ loaded = $loaded; failed = $failed }
}

function Get-LoadedDrivers { [array]$script:LoadedDrivers }

function Import-RegisteredDrivers {
    <#.SYNOPSIS Load drivers declared in a registered micronaut's program_contract.drivers.#>
    param([Parameter(Mandatory)][string]$Id)
    $bridge = Get-MicronautBridge $Id
    if (-not $bridge) { return @{ error = "micronaut '$Id' not registered" } }
    $driverList = @($bridge.program_contract.drivers)
    if ($driverList.Count -eq 0) { return @{ loaded = @(); failed = @() } }
    return Import-MicronautDrivers -DriverNames $driverList
}


# ── Scaffold helpers ──────────────────────────────────────────────────────────

function New-MicronautBindingsFile {
    <#.SYNOPSIS Scaffold a per-micronaut PSM1 in shell/ for a newly created micronaut.#>
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Namespace,
        [string[]]$AtomicKeys = @(),
        [string]$Category = 'advisory'
    )
    $ns      = if ($Namespace) { $Namespace } else { $Id.ToLower() -replace '[^\w]','-' }
    $safeName = $ns -replace '-','_'
    $fileName = "$($ns).bindings.psm1"
    $outPath  = Join-Path $script:ShellRoot $fileName

    $keyFunctions = ($AtomicKeys | ForEach-Object {
        $suffix = $_ -replace "^$([regex]::Escape($ns))\.",'' -replace '[^\w]','_'
        $funcName = "Invoke-$($Id -replace '[^A-Za-z0-9]','')$(($suffix -split '_' | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) }) -join '')"
"
function $funcName {
    param([hashtable]`$Payload = @{})
    Import-Module `"`$PSScriptRoot\micronaut_bindings.psm1`" -Force
    return Invoke-AtomicKey -Key '$_' -Payload `$Payload
}"
    }) -join "`n"

    $content = @"
#Requires -Version 5.1
# $fileName — bindings for $Id
# Auto-scaffolded by micronaut-trainer. Import micronaut_bindings.psm1 for the full bus.

Import-Module "`$PSScriptRoot\micronaut_bindings.psm1" -Force

function Register-${safeName}Micronaut {
    Register-Micronaut -BridgePath "data/micronauts/$($ns).micronaut.json"
}

function Test-${safeName}Health {
    Test-MicronautHealth -Id '$Id'
}

function Invoke-${safeName}Match {
    param([Parameter(Mandatory)][string]`$Text, [string]`$Topic = '')
    Invoke-MicronautMatch -Id '$Id' -Text `$Text -Topic `$Topic
}
$keyFunctions

Export-ModuleMember -Function Register-${safeName}Micronaut, Test-${safeName}Health, Invoke-${safeName}Match$(if ($AtomicKeys) { ", $($AtomicKeys | ForEach-Object { $suffix = $_ -replace "^$([regex]::Escape($ns))\.",'' -replace '[^\w]','_'; "Invoke-$($Id -replace '[^A-Za-z0-9]','')$(($suffix -split '_' | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) }) -join '')" } | Select-Object -Unique)" })
"@

    Set-Content -LiteralPath $outPath -Value $content -Encoding UTF8
    return $outPath
}

# ── Semantic deltas (READ WRITE PATCH LIST GET POST DELETE SAVE) ──────────────
# Each routes through the micronaut's atomic key namespace: {ns}.{verb}
# GET-style deltas (read, list, get) use app-host REST; mutation deltas POST via atomic/call.

function Invoke-MicronautRead {
    # Fetch a named resource from the micronaut's data store (GET semantic)
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Resource = '',
        [hashtable]$Params = @{}
    )
    $p = @{ resource = $Resource }
    foreach ($k in $Params.Keys) { $p[$k] = $Params[$k] }
    return Invoke-MicronautAtomicKey -Id $Id -KeySuffix 'read' -Payload $p
}

function Invoke-MicronautGet {
    # Fetch a single resource by URI/id (GET by key — stricter than Read)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$ResourceId,
        [hashtable]$Params = @{}
    )
    $p = @{ resource_id = $ResourceId }
    foreach ($k in $Params.Keys) { $p[$k] = $Params[$k] }
    return Invoke-MicronautAtomicKey -Id $Id -KeySuffix 'get' -Payload $p
}

function Invoke-MicronautList {
    # Enumerate available resources (tracks, patterns, keys, grammar entries)
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Scope = '',
        [hashtable]$Filter = @{}
    )
    $p = @{ scope = $Scope }
    foreach ($k in $Filter.Keys) { $p[$k] = $Filter[$k] }
    return Invoke-MicronautAtomicKey -Id $Id -KeySuffix 'list' -Payload $p
}

function Invoke-MicronautWrite {
    # Write/replace a resource (PUT semantic — full replacement)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Resource,
        [Parameter(Mandatory)][hashtable]$Body
    )
    $p = @{ resource = $Resource }
    foreach ($k in $Body.Keys) { $p[$k] = $Body[$k] }
    return Invoke-MicronautAtomicKey -Id $Id -KeySuffix 'write' -Payload $p
}

function Invoke-MicronautPatch {
    # Partial update of a resource (PATCH semantic — merge, not replace)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Resource,
        [Parameter(Mandatory)][hashtable]$Delta
    )
    $p = @{ resource = $Resource; delta = $Delta }
    return Invoke-MicronautAtomicKey -Id $Id -KeySuffix 'patch' -Payload $p
}

function Invoke-MicronautPost {
    # Submit/create a new resource or trigger an action (POST semantic)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Action,
        [hashtable]$Body = @{}
    )
    $p = @{ action = $Action }
    foreach ($k in $Body.Keys) { $p[$k] = $Body[$k] }
    return Invoke-MicronautAtomicKey -Id $Id -KeySuffix 'post' -Payload $p
}

function Invoke-MicronautDelete {
    # Remove a resource (DELETE semantic)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$ResourceId,
        [switch]$Confirm
    )
    return Invoke-MicronautAtomicKey -Id $Id -KeySuffix 'delete' -Payload @{
        resource_id = $ResourceId; confirm = [bool]$Confirm
    }
}

function Invoke-MicronautSave {
    # Persist/commit current state (transaction save — append-only to track)
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Scope = '',
        [hashtable]$Meta = @{}
    )
    $p = @{ scope = $Scope }
    foreach ($k in $Meta.Keys) { $p[$k] = $Meta[$k] }
    return Invoke-MicronautAtomicKey -Id $Id -KeySuffix 'save' -Payload $p
}


# ── Verb dispatch (full AIML/kuhul verb surface) ──────────────────────────────

function Invoke-MicronautAgent {
    # @agent — emit template response (Xul close_only)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Text,
        [string]$Topic = '',
        [string]$That  = ''
    )
    $entry = $script:BusRegistry[$Id]
    if (-not $entry) { return @{ error="micronaut '$Id' not registered"; ok=$false } }
    $topicVal = if ($Topic) { $Topic } elseif ($entry.bridge.patterns.topic_scope) { [string]$entry.bridge.patterns.topic_scope } else { '' }
    $body = @{ id=$Id; text=$Text }
    if ($topicVal) { $body['topic'] = $topicVal }
    if ($That)     { $body['that']  = $That }
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/agent" $body
}

function Invoke-MicronautCall {
    # @call — SRAI redirect (Yax expand, redirect_only, max depth 16)
    param(
        [Parameter(Mandatory)][string]$FromId,
        [Parameter(Mandatory)][string]$ToId,
        [Parameter(Mandatory)][string]$Text,
        [int]$Depth = 1
    )
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/srai" @{
        from=$FromId; to=$ToId; text=$Text; depth=$Depth
    }
}

function Set-MicronautTopic {
    # @topic — set/update topic scope (match_only, Yax)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Topic
    )
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/topic" @{ id=$Id; topic=$Topic }
}

function Invoke-MicronautThink {
    # @think — hidden reasoning (Sek rank_only, no output authority)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Text,
        [hashtable]$Context = @{}
    )
    $body = @{ id=$Id; text=$Text }
    foreach ($k in $Context.Keys) { $body[$k] = $Context[$k] }
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/think" $body
}

function Write-MicronautRemember {
    # @remember — store variable <set> (proposal_only, Xul)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)]$Value,
        [string]$Category = ''
    )
    $body = @{ id=$Id; key=$Key; value=$Value }
    if ($Category) { $body['category'] = $Category }
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/state/set" $body
}

function Read-MicronautRecall {
    # @recall — retrieve variable <get> (match_only, Wo gramRead)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Key,
        [string]$Category = ''
    )
    $qs = "id=$([Uri]::EscapeDataString($Id))&key=$([Uri]::EscapeDataString($Key))"
    if ($Category) { $qs += "&category=$([Uri]::EscapeDataString($Category))" }
    return _BusGet "$($script:BusConfig.AimlApiBase -replace '/$','')/state/get?$qs"
}

function Add-MicronautLearn {
    # @learn — submit learning proposal (proposal_only, Xul append-only)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Pattern,
        [Parameter(Mandatory)][string]$Response,
        [string]$Topic = ''
    )
    $body = @{ id=$Id; pattern=$Pattern; response=$Response }
    if ($Topic) { $body['topic'] = $Topic }
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/learn" $body
}

function Invoke-MicronautDecide {
    # @decide — random selection from scored options <random> (Sek rank_only)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][array]$Options
    )
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/decide" @{ id=$Id; options=$Options }
}

function Invoke-MicronautEval {
    # @eval — perspective/case transform <person>/<formal>/<uppercase>/<lowercase> (Wo match_only)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$Text,
        [ValidateSet('person','formal','uppercase','lowercase')]
        [string]$Transform = 'person'
    )
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/eval" @{
        id=$Id; text=$Text; transform=$Transform
    }
}

function Get-MicronautIdentity {
    # @identity — static identity from loaded bridge (Pop phase, local — no HTTP)
    param([Parameter(Mandatory)][string]$Id)
    $bridge = Get-MicronautBridge $Id
    if (-not $bridge) { return @{ error="micronaut '$Id' not registered" } }
    if ($bridge.identity) { return $bridge.identity }
    # kuhul.micronaut.atomic.v1 stores id at top level and name in manifest
    return [pscustomobject]@{ id = [string]$bridge.id; name = [string]$bridge.manifest.name }
}

function Test-MicronautCondition {
    # @condition — verify that-context against prior response (Ch'en verify, match_only)
    param(
        [Parameter(Mandatory)][string]$Id,
        [Parameter(Mandatory)][string]$That,
        [string]$Topic = ''
    )
    $body = @{ id=$Id; that=$That }
    if ($Topic) { $body['topic'] = $Topic }
    return _BusPost "$($script:BusConfig.AimlApiBase -replace '/$','')/condition" $body
}


# ── Driver enumeration ────────────────────────────────────────────────────────

function Get-AvailableDrivers {
    <#.SYNOPSIS List all DLL names in drivers/ without loading them.#>
    if (-not (Test-Path $script:DriversRoot)) { return @() }
    return @(Get-ChildItem $script:DriversRoot -Filter '*.dll' | Sort-Object Name | ForEach-Object { $_.Name })
}


Export-ModuleMember -Function `
    Set-BusConfig, Get-BusConfig, `
    Resolve-BusPath, `
    Register-Micronaut, Unregister-Micronaut, `
    Get-MicronautBridge, Get-MicronautTrack, Get-MicronautList, Get-MicronautEntry, `
    Invoke-MicronautMatch, Invoke-AtomicKey, Invoke-MicronautAtomicKey, `
    Invoke-MicronautRead, Invoke-MicronautGet, Invoke-MicronautList, `
    Invoke-MicronautWrite, Invoke-MicronautPatch, Invoke-MicronautPost, `
    Invoke-MicronautDelete, Invoke-MicronautSave, `
    Invoke-MicronautAgent, Invoke-MicronautCall, Set-MicronautTopic, `
    Invoke-MicronautThink, Write-MicronautRemember, Read-MicronautRecall, `
    Add-MicronautLearn, Invoke-MicronautDecide, Invoke-MicronautEval, `
    Get-MicronautIdentity, Test-MicronautCondition, `
    Test-MicronautHealth, Get-AimlStats, Invoke-AimlReload, `
    Import-MicronautDrivers, Get-LoadedDrivers, Import-RegisteredDrivers, Get-AvailableDrivers, `
    New-MicronautBindingsFile
