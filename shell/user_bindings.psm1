#Requires -Version 5.1
<#
  user_bindings.psm1 — ⟁USER:* resource bindings
  Six resources:
    ⟁USER:ROLE       — role graph (dag.dll — roles inherit, admin > moderator > member > guest)
    ⟁USER:PROFILE    — OAuth-populated profile (name, email, avatar, provider)
    ⟁USER:TABLE      — denormalized user document (json_runtime_lib — fast lookup cache)
    ⟁USER:MEMORY     — per-user key-value memory (MongoDB.Bson — persistent facts)
    ⟁USER:MICRONAUTS — which micronauts a user owns/can call (capability grants)
    ⟁USER:SESSIONS   — session tokens (OAuth sessions + micronaut sessions)

  Drivers: MongoDB.Bson.dll  (BSON doc serialization)
           dag.dll           (role/permission DAG graph)
           json_runtime_lib  (fast in-process JSON cache + MongoDB query bridge)
           Pattern.Log.dll   (automatic prompt/response audit log per user)

  HTTP backend: app-host at 17885  /user/*
  Integrates with: oauth_bindings.psm1 (session bootstrap after OAuth callback)
#>

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:UserBase    = 'http://127.0.0.1:17885'
$script:UserCache   = [System.Collections.Generic.Dictionary[string,hashtable]]::new()
$script:RoleGraph   = $null   # populated by Import-UserDrivers

$script:UserDrivers = @('MongoDB.Bson.dll', 'dag.dll', 'json_runtime_lib.dll', 'Pattern.Log.dll')


# ── Drivers ───────────────────────────────────────────────────────────────────

function Import-UserDrivers {
    Import-MicronautDrivers -DriverNames $script:UserDrivers
}

function Import-UserDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}


# ── Internal HTTP ─────────────────────────────────────────────────────────────

function _UserPost([string]$Path, [hashtable]$Body) {
    try {
        $json = $Body | ConvertTo-Json -Depth 8 -Compress
        return Invoke-RestMethod -Method POST -Uri "$($script:UserBase)$Path" `
                   -Body $json -ContentType 'application/json; charset=utf-8' `
                   -TimeoutSec 15 -ErrorAction Stop
    } catch { return @{ error = $_.Exception.Message; ok = $false } }
}

function _UserGet([string]$Path) {
    try {
        return Invoke-RestMethod -Method GET -Uri "$($script:UserBase)$Path" `
                   -TimeoutSec 15 -ErrorAction Stop
    } catch { return @{ error = $_.Exception.Message; ok = $false } }
}

function _UserDelete([string]$Path) {
    try {
        return Invoke-RestMethod -Method DELETE -Uri "$($script:UserBase)$Path" `
                   -TimeoutSec 15 -ErrorAction Stop
    } catch { return @{ error = $_.Exception.Message; ok = $false } }
}


# ── ⟁USER:PROFILE ─────────────────────────────────────────────────────────────
# OAuth-populated on first login. Fields: user_id, name, email, avatar_url, provider, created_at.

function New-UserProfile {
    <#.SYNOPSIS Create a user profile after OAuth callback. Called automatically by oauth_bindings.#>
    param(
        [Parameter(Mandatory)][string]$UserId,
        [string]$Name      = '',
        [string]$Email     = '',
        [string]$AvatarUrl = '',
        [string]$Provider  = 'google',
        [hashtable]$Extra  = @{}
    )
    $doc = @{ user_id=$UserId; name=$Name; email=$Email; avatar_url=$AvatarUrl; provider=$Provider; created_at=[datetime]::UtcNow.ToString('o') }
    foreach ($k in $Extra.Keys) { $doc[$k] = $Extra[$k] }
    $script:UserCache["profile:$UserId"] = $doc
    return _UserPost '/user/profile' $doc
}

function Get-UserProfile {
    param([Parameter(Mandatory)][string]$UserId)
    if ($script:UserCache.ContainsKey("profile:$UserId")) { return $script:UserCache["profile:$UserId"] }
    $result = _UserGet "/user/profile/$([Uri]::EscapeDataString($UserId))"
    if (-not $result.error) { $script:UserCache["profile:$UserId"] = $result }
    return $result
}

function Set-UserProfile {
    param([Parameter(Mandatory)][string]$UserId, [Parameter(Mandatory)][hashtable]$Delta)
    $Delta['user_id'] = $UserId
    $script:UserCache.Remove("profile:$UserId") | Out-Null
    return _UserPost "/user/profile/$([Uri]::EscapeDataString($UserId))/patch" $Delta
}

function Remove-UserProfile {
    param([Parameter(Mandatory)][string]$UserId)
    $script:UserCache.Remove("profile:$UserId") | Out-Null
    return _UserDelete "/user/profile/$([Uri]::EscapeDataString($UserId))"
}

function Find-UserByEmail {
    param([Parameter(Mandatory)][string]$Email)
    return _UserGet "/user/profile/find?email=$([Uri]::EscapeDataString($Email))"
}


# ── ⟁USER:ROLE ────────────────────────────────────────────────────────────────
# Role hierarchy via dag.dll: admin > moderator > member > guest
# Apps can define custom roles that inherit from base roles.
# DAG edge: child --inherits--> parent

function Get-UserRole {
    param([Parameter(Mandatory)][string]$UserId)
    return _UserGet "/user/role/$([Uri]::EscapeDataString($UserId))"
}

function Set-UserRole {
    param([Parameter(Mandatory)][string]$UserId, [Parameter(Mandatory)][string]$Role, [string]$AppId = '')
    $body = @{ user_id=$UserId; role=$Role }
    if ($AppId) { $body['app_id'] = $AppId }
    $script:UserCache.Remove("table:$UserId") | Out-Null
    return _UserPost '/user/role/set' $body
}

function Test-UserRole {
    <#.SYNOPSIS Check if a user has at least the specified role (respects DAG inheritance).#>
    param([Parameter(Mandatory)][string]$UserId, [Parameter(Mandatory)][string]$MinRole, [string]$AppId = '')
    $qs = "user_id=$([Uri]::EscapeDataString($UserId))&min_role=$([Uri]::EscapeDataString($MinRole))"
    if ($AppId) { $qs += "&app_id=$([Uri]::EscapeDataString($AppId))" }
    return _UserGet "/user/role/check?$qs"
}

function Get-RoleGraph {
    <#.SYNOPSIS Return the full role DAG (admin > moderator > member > guest + any custom roles).#>
    if ($null -ne $script:RoleGraph) { return $script:RoleGraph }
    $script:RoleGraph = _UserGet '/user/role/graph'
    return $script:RoleGraph
}

function Add-RoleEdge {
    <#.SYNOPSIS Add a custom role that inherits from an existing role (via dag.dll).#>
    param([Parameter(Mandatory)][string]$Child, [Parameter(Mandatory)][string]$Parent, [string]$AppId = '')
    $script:RoleGraph = $null
    return _UserPost '/user/role/graph/edge' @{ child=$Child; parent=$Parent; app_id=$AppId }
}

function Get-UsersWithRole {
    param([Parameter(Mandatory)][string]$Role, [string]$AppId = '')
    $qs = "role=$([Uri]::EscapeDataString($Role))"
    if ($AppId) { $qs += "&app_id=$([Uri]::EscapeDataString($AppId))" }
    return _UserGet "/user/role/list?$qs"
}


# ── ⟁USER:TABLE ───────────────────────────────────────────────────────────────
# Denormalized user document — combines profile + role + session refs + app memberships.
# Backed by json_runtime_lib for fast O(1) in-process cache, MongoDB for persistence.

function Get-UserTable {
    <#.SYNOPSIS Get the full denormalized user record by user_id or email.#>
    param([Parameter(Mandatory)][string]$UserId)
    if ($script:UserCache.ContainsKey("table:$UserId")) { return $script:UserCache["table:$UserId"] }
    $result = _UserGet "/user/table/$([Uri]::EscapeDataString($UserId))"
    if (-not $result.error) { $script:UserCache["table:$UserId"] = $result }
    return $result
}

function Get-UserById {
    param([Parameter(Mandatory)][string]$UserId)
    return Get-UserTable -UserId $UserId
}

function Invoke-UserQuery {
    <#.SYNOPSIS Query the user table with a filter document (MongoDB-style JSON query via json_runtime_lib).#>
    param([Parameter(Mandatory)][hashtable]$Filter, [int]$Limit = 50, [int]$Skip = 0)
    return _UserPost '/user/table/query' @{ filter=$Filter; limit=$Limit; skip=$Skip }
}

function Get-UserList {
    param([string]$AppId = '', [int]$Limit = 100, [int]$Skip = 0)
    $qs = "limit=$Limit&skip=$Skip"
    if ($AppId) { $qs += "&app_id=$([Uri]::EscapeDataString($AppId))" }
    return _UserGet "/user/table/list?$qs"
}

function Remove-UserRecord {
    <#.SYNOPSIS Hard delete a user record (all collections). Requires admin role.#>
    param([Parameter(Mandatory)][string]$UserId)
    $script:UserCache.Remove("table:$UserId")  | Out-Null
    $script:UserCache.Remove("profile:$UserId") | Out-Null
    return _UserDelete "/user/table/$([Uri]::EscapeDataString($UserId))"
}

function Clear-UserTableCache {
    $keys = @($script:UserCache.Keys | Where-Object { $_ -like 'table:*' -or $_ -like 'profile:*' })
    foreach ($k in $keys) { $script:UserCache.Remove($k) | Out-Null }
}


# ── ⟁USER:MEMORY ──────────────────────────────────────────────────────────────
# Per-user persistent key-value memory. Backed by MongoDB.Bson via json_runtime_lib.
# Scoped: (user_id, key, category) → value. Integrates with MEMORY-µ micronaut.

function Write-UserMemory {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][string]$Key,
        [Parameter(Mandatory)]$Value,
        [string]$Category  = 'general',
        [double]$Importance = 0.5
    )
    return _UserPost '/user/memory/write' @{
        user_id    = $UserId
        key        = $Key
        value      = $Value
        category   = $Category
        importance = $Importance
        written_at = [datetime]::UtcNow.ToString('o')
    }
}

function Read-UserMemory {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][string]$Key,
        [string]$Category = ''
    )
    $qs = "user_id=$([Uri]::EscapeDataString($UserId))&key=$([Uri]::EscapeDataString($Key))"
    if ($Category) { $qs += "&category=$([Uri]::EscapeDataString($Category))" }
    return _UserGet "/user/memory/read?$qs"
}

function Get-UserMemoryAll {
    param([Parameter(Mandatory)][string]$UserId, [string]$Category = '', [int]$Limit = 100)
    $qs = "user_id=$([Uri]::EscapeDataString($UserId))&limit=$Limit"
    if ($Category) { $qs += "&category=$([Uri]::EscapeDataString($Category))" }
    return _UserGet "/user/memory/all?$qs"
}

function Remove-UserMemory {
    param([Parameter(Mandatory)][string]$UserId, [string]$Key = '', [string]$Category = '')
    $body = @{ user_id=$UserId }
    if ($Key)      { $body['key']      = $Key }
    if ($Category) { $body['category'] = $Category }
    return _UserPost '/user/memory/remove' $body
}

function Search-UserMemory {
    <#.SYNOPSIS Semantic search over a user's memory (uses GEMMA-µ embed if available).#>
    param([Parameter(Mandatory)][string]$UserId, [Parameter(Mandatory)][string]$Query, [int]$TopK = 5)
    return _UserPost '/user/memory/search' @{ user_id=$UserId; query=$Query; top_k=$TopK }
}


# ── ⟁USER:MICRONAUTS ──────────────────────────────────────────────────────────
# Tracks which micronauts a user has registered, owns, or has been granted capability access to.
# Each grant specifies which atomic keys the user can call on that micronaut.

function Get-UserMicronauts {
    param([Parameter(Mandatory)][string]$UserId)
    return _UserGet "/user/micronauts/$([Uri]::EscapeDataString($UserId))"
}

function Grant-UserMicronaut {
    <#.SYNOPSIS Grant a user access to a micronaut (optionally scoped to specific atomic keys).#>
    param(
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][string]$MicronautId,
        [string[]]$AllowedKeys = @(),
        [string]$GrantedBy     = 'admin'
    )
    return _UserPost '/user/micronauts/grant' @{
        user_id      = $UserId
        micronaut_id = $MicronautId
        allowed_keys = $AllowedKeys
        granted_by   = $GrantedBy
        granted_at   = [datetime]::UtcNow.ToString('o')
    }
}

function Revoke-UserMicronaut {
    param([Parameter(Mandatory)][string]$UserId, [Parameter(Mandatory)][string]$MicronautId)
    return _UserPost '/user/micronauts/revoke' @{ user_id=$UserId; micronaut_id=$MicronautId }
}

function Test-UserMicronautAccess {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][string]$MicronautId,
        [string]$AtomicKey = ''
    )
    $qs = "user_id=$([Uri]::EscapeDataString($UserId))&micronaut_id=$([Uri]::EscapeDataString($MicronautId))"
    if ($AtomicKey) { $qs += "&key=$([Uri]::EscapeDataString($AtomicKey))" }
    return _UserGet "/user/micronauts/check?$qs"
}


# ── ⟁USER:SESSIONS ────────────────────────────────────────────────────────────
# Session documents bridging OAuth tokens and micronaut session state.
# OAuth sessions (from oauth_bindings) are linked here with user_id.

function New-UserSession {
    param(
        [Parameter(Mandatory)][string]$UserId,
        [string]$Provider   = 'google',
        [string]$OAuthToken = '',
        [string]$AppId      = '',
        [int]$ExpirySeconds = 86400
    )
    $token   = [System.Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
    $expires = [datetime]::UtcNow.AddSeconds($ExpirySeconds).ToString('o')
    $doc     = @{
        session_token = $token
        user_id       = $UserId
        provider      = $Provider
        oauth_token   = $OAuthToken
        app_id        = $AppId
        created_at    = [datetime]::UtcNow.ToString('o')
        expires_at    = $expires
    }
    $script:UserCache["session:$token"] = $doc
    _UserPost '/user/sessions/create' $doc | Out-Null
    return $doc
}

function Get-UserSession {
    param([Parameter(Mandatory)][string]$SessionToken)
    if ($script:UserCache.ContainsKey("session:$SessionToken")) {
        return $script:UserCache["session:$SessionToken"]
    }
    return _UserGet "/user/sessions/$([Uri]::EscapeDataString($SessionToken))"
}

function Get-UserSessions {
    <#.SYNOPSIS List all active sessions for a user.#>
    param([Parameter(Mandatory)][string]$UserId)
    return _UserGet "/user/sessions/list/$([Uri]::EscapeDataString($UserId))"
}

function Test-UserSession {
    param([Parameter(Mandatory)][string]$SessionToken)
    if ($script:UserCache.ContainsKey("session:$SessionToken")) {
        $cached = $script:UserCache["session:$SessionToken"]
        if ([datetime]$cached.expires_at -gt [datetime]::UtcNow) { return @{ valid=$true; cached=$true } }
        $script:UserCache.Remove("session:$SessionToken") | Out-Null
    }
    return _UserGet "/user/sessions/validate?token=$([Uri]::EscapeDataString($SessionToken))"
}

function Remove-UserSession {
    param([Parameter(Mandatory)][string]$SessionToken)
    $script:UserCache.Remove("session:$SessionToken") | Out-Null
    return _UserDelete "/user/sessions/$([Uri]::EscapeDataString($SessionToken))"
}

function Remove-UserSessions {
    <#.SYNOPSIS Revoke all sessions for a user (logout everywhere).#>
    param([Parameter(Mandatory)][string]$UserId)
    $keys = @($script:UserCache.Keys | Where-Object { $_ -like 'session:*' })
    foreach ($k in $keys) {
        if ($script:UserCache[$k].user_id -eq $UserId) { $script:UserCache.Remove($k) | Out-Null }
    }
    return _UserPost '/user/sessions/revoke-all' @{ user_id=$UserId }
}


# ── Bootstrap: wire OAuth callback → user record ─────────────────────────────

function Initialize-UserFromOAuth {
    <#.SYNOPSIS Called after OAuth callback — creates/updates profile + table + session.
    Returns the full user record with session token.#>
    param(
        [Parameter(Mandatory)][string]$OAuthToken,
        [string]$Provider = 'google',
        [string]$AppId    = ''
    )
    # get user info from oauth provider
    $oauthMod = Join-Path $PSScriptRoot 'oauth_bindings.psm1'
    $userInfo  = $null
    if (Test-Path $oauthMod) {
        Import-Module $oauthMod -Force -ErrorAction SilentlyContinue
        if (Get-Command Get-OAuthSessionUser -ErrorAction SilentlyContinue) {
            $userInfo = Get-OAuthSessionUser -SessionToken $OAuthToken
        }
    }

    if (-not $userInfo -or $userInfo.error) {
        return @{ error='Could not retrieve user info from OAuth provider'; ok=$false }
    }

    $userId = "$Provider`:$($userInfo.sub ?? $userInfo.id ?? $userInfo.email)"

    # upsert profile
    $existing = Get-UserProfile -UserId $userId
    if ($existing.error) {
        New-UserProfile -UserId $userId -Name ([string]$userInfo.name) `
            -Email ([string]$userInfo.email) -AvatarUrl ([string]$userInfo.picture) `
            -Provider $Provider | Out-Null
    } else {
        Set-UserProfile -UserId $userId -Delta @{
            name=$userInfo.name; email=$userInfo.email; last_seen=[datetime]::UtcNow.ToString('o')
        } | Out-Null
    }

    # assign default role if new
    $role = Get-UserRole -UserId $userId
    if ($role.error) { Set-UserRole -UserId $userId -Role 'member' -AppId $AppId | Out-Null }

    # create session
    $session = New-UserSession -UserId $userId -Provider $Provider -OAuthToken $OAuthToken -AppId $AppId

    return @{
        user_id       = $userId
        email         = [string]$userInfo.email
        name          = [string]$userInfo.name
        session_token = $session.session_token
        expires_at    = $session.expires_at
        ok            = $true
    }
}


# ── ⟁USER:LOG (Pattern.Log.dll) ──────────────────────────────────────────────
# Automatic audit log of every prompt sent and response received, keyed by user_id.
# Pattern.Log.dll records interactions as they happen — not deliberate saves like ⟁USER:MEMORY.
# Log entries: user_id, session_token, app_id, micronaut_id, type (prompt|response), content, timestamp.
# Used for: conversation replay, pattern analysis, compliance audit, context injection.

function Write-UserPatternLog {
    <#.SYNOPSIS Append a prompt or response entry to the user's pattern log. Called automatically by micronaut dispatch.#>
    param(
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][ValidateSet('prompt','response','system','error')][string]$Type,
        [Parameter(Mandatory)][string]$Content,
        [string]$SessionToken = '',
        [string]$AppId        = '',
        [string]$MicronautId  = '',
        [string]$AtomicKey    = '',
        [double]$LatencyMs    = 0.0
    )
    return _UserPost '/user/log/write' @{
        user_id       = $UserId
        type          = $Type
        content       = $Content
        session_token = $SessionToken
        app_id        = $AppId
        micronaut_id  = $MicronautId
        atomic_key    = $AtomicKey
        latency_ms    = $LatencyMs
        logged_at     = [datetime]::UtcNow.ToString('o')
    }
}

function Get-UserPatternLog {
    <#.SYNOPSIS Retrieve log entries for a user — full history or filtered by session/app/micronaut.#>
    param(
        [Parameter(Mandatory)][string]$UserId,
        [string]$SessionToken = '',
        [string]$AppId        = '',
        [string]$MicronautId  = '',
        [ValidateSet('prompt','response','system','error','')][string]$Type = '',
        [int]$Limit           = 100,
        [int]$Skip            = 0
    )
    $qs = "user_id=$([Uri]::EscapeDataString($UserId))&limit=$Limit&skip=$Skip"
    if ($SessionToken) { $qs += "&session_token=$([Uri]::EscapeDataString($SessionToken))" }
    if ($AppId)        { $qs += "&app_id=$([Uri]::EscapeDataString($AppId))" }
    if ($MicronautId)  { $qs += "&micronaut_id=$([Uri]::EscapeDataString($MicronautId))" }
    if ($Type)         { $qs += "&type=$([Uri]::EscapeDataString($Type))" }
    return _UserGet "/user/log/list?$qs"
}

function Get-UserConversation {
    <#.SYNOPSIS Return prompt+response pairs for a session — ordered for context injection or replay.#>
    param(
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][string]$SessionToken,
        [int]$LastN = 20
    )
    return _UserGet "/user/log/conversation?user_id=$([Uri]::EscapeDataString($UserId))&session_token=$([Uri]::EscapeDataString($SessionToken))&last_n=$LastN"
}

function Search-UserPatternLog {
    <#.SYNOPSIS Full-text or semantic search over a user's interaction history.#>
    param(
        [Parameter(Mandatory)][string]$UserId,
        [Parameter(Mandatory)][string]$Query,
        [int]$TopK     = 10,
        [string]$AppId = ''
    )
    $body = @{ user_id=$UserId; query=$Query; top_k=$TopK }
    if ($AppId) { $body['app_id'] = $AppId }
    return _UserPost '/user/log/search' $body
}

function Remove-UserPatternLog {
    <#.SYNOPSIS Purge log entries — by session, by age, or all entries for a user (GDPR right to erasure).#>
    param(
        [Parameter(Mandatory)][string]$UserId,
        [string]$SessionToken  = '',
        [string]$OlderThanDays = '',
        [switch]$All
    )
    $body = @{ user_id=$UserId }
    if ($SessionToken)  { $body['session_token']   = $SessionToken }
    if ($OlderThanDays) { $body['older_than_days']  = $OlderThanDays }
    if ($All)           { $body['purge_all']        = $true }
    return _UserPost '/user/log/remove' $body
}


Export-ModuleMember -Function `
    Import-UserDrivers, Import-UserDriver, `
    New-UserProfile, Get-UserProfile, Set-UserProfile, Remove-UserProfile, Find-UserByEmail, `
    Get-UserRole, Set-UserRole, Test-UserRole, Get-RoleGraph, Add-RoleEdge, Get-UsersWithRole, `
    Get-UserTable, Get-UserById, Invoke-UserQuery, Get-UserList, Remove-UserRecord, Clear-UserTableCache, `
    Write-UserMemory, Read-UserMemory, Get-UserMemoryAll, Remove-UserMemory, Search-UserMemory, `
    Get-UserMicronauts, Grant-UserMicronaut, Revoke-UserMicronaut, Test-UserMicronautAccess, `
    New-UserSession, Get-UserSession, Get-UserSessions, Test-UserSession, Remove-UserSession, Remove-UserSessions, `
    Write-UserPatternLog, Get-UserPatternLog, Get-UserConversation, Search-UserPatternLog, Remove-UserPatternLog, `
    Initialize-UserFromOAuth
