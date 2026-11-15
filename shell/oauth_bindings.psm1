#Requires -Version 5.1
<#
  oauth_bindings.psm1 — Central OAuth2 binding for all generated apps
  Architecture:
    - One OAuth server at app-host (17885) handles ALL app registrations
    - Each app registers once, gets login/callback/admin pages injected automatically
    - User only needs to paste Google client_id + secret — we handle the rest
    - After auth: redirect back to the app with a session token

  Supported providers: Google (primary), GitHub (secondary)
  Flow: PKCE + state nonce (no client secret exposed to browser)

  Callback URL to give users for Google Console:
    http://127.0.0.1:17885/oauth/callback/{APP_ID}
#>

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:OAuthBase     = 'http://127.0.0.1:17885'
$script:OAuthRegistry = [System.Collections.Generic.Dictionary[string,hashtable]]::new()
$script:KitRoot       = Join-Path $PSScriptRoot '..\key-grammar-kit'
$script:OAuthDataDir  = Join-Path $script:KitRoot 'data\host\oauth'


# ── Internal HTTP ─────────────────────────────────────────────────────────────

function _OAuthPost([string]$Path, [hashtable]$Body) {
    try {
        $json = $Body | ConvertTo-Json -Depth 6 -Compress
        return Invoke-RestMethod -Method POST -Uri "$($script:OAuthBase)$Path" `
                   -Body $json -ContentType 'application/json; charset=utf-8' `
                   -TimeoutSec 15 -ErrorAction Stop
    } catch { return @{ error = $_.Exception.Message; ok = $false } }
}

function _OAuthGet([string]$Path) {
    try {
        return Invoke-RestMethod -Method GET -Uri "$($script:OAuthBase)$Path" `
                   -TimeoutSec 15 -ErrorAction Stop
    } catch { return @{ error = $_.Exception.Message; ok = $false } }
}


# ── Registry (local + persisted) ──────────────────────────────────────────────

function _EnsureOAuthDataDir {
    if (-not (Test-Path $script:OAuthDataDir)) {
        New-Item -ItemType Directory -Path $script:OAuthDataDir -Force | Out-Null
    }
}

function _OAuthRegistryPath {
    _EnsureOAuthDataDir
    Join-Path $script:OAuthDataDir 'app-oauth.registry.json'
}

function _LoadOAuthRegistry {
    $path = _OAuthRegistryPath
    if (Test-Path $path) {
        try {
            $data = Get-Content $path -Raw | ConvertFrom-Json
            foreach ($prop in $data.PSObject.Properties) {
                $script:OAuthRegistry[$prop.Name] = @{} + $prop.Value
            }
        } catch {}
    }
}

function _SaveOAuthRegistry {
    $obj = @{}
    foreach ($k in $script:OAuthRegistry.Keys) { $obj[$k] = $script:OAuthRegistry[$k] }
    $obj | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (_OAuthRegistryPath) -Encoding UTF8
}

_LoadOAuthRegistry


# ── App OAuth registration ─────────────────────────────────────────────────────

function Register-AppOAuth {
    <#.SYNOPSIS Register an app with the central OAuth system.
    After calling this, give the user the callback URL to paste into Google Console.
    They only need to provide their Google client_id and secret once.

    Example:
        Register-AppOAuth -AppId 'DOG_PARK' -AppBase 'http://localhost:5173'
    .PARAMETER AppId       The ⟁APP key name (without ⟁APP: prefix)
    .PARAMETER AppBase     Base URL of the app (where to redirect after login)
    .PARAMETER GoogleClientId   Paste from Google Cloud Console (optional — set later via Set-OAuthConfig)
    .PARAMETER GoogleSecret     Paste from Google Cloud Console (optional — set later)
    .PARAMETER Scopes           OAuth scopes (default: openid email profile)
    #>
    param(
        [Parameter(Mandatory)][string]$AppId,
        [string]$AppBase         = 'http://localhost:5173',
        [string]$GoogleClientId  = '',
        [string]$GoogleSecret    = '',
        [string[]]$Scopes        = @('openid','email','profile')
    )
    $safeId      = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    $callbackUrl = "$($script:OAuthBase)/oauth/callback/$safeId"
    $loginUrl    = "$($script:OAuthBase)/oauth/login/$safeId"
    $adminUrl    = "$($script:OAuthBase)/oauth/admin/$safeId"
    $appSlug     = $safeId.ToLower() -replace '_','-'

    $entry = @{
        app_id          = $safeId
        app_base        = $AppBase
        callback_url    = $callbackUrl
        login_url       = $loginUrl
        admin_url       = $adminUrl
        app_slug        = $appSlug
        scopes          = $Scopes
        google_client_id= $GoogleClientId
        google_secret   = $GoogleSecret
        registered_at   = [datetime]::UtcNow.ToString('o')
        status          = if ($GoogleClientId) { 'configured' } else { 'pending_credentials' }
    }

    $script:OAuthRegistry[$safeId] = $entry
    _SaveOAuthRegistry

    # register with live server if available
    _OAuthPost '/oauth/register' @{
        app_id       = $safeId
        app_base     = $AppBase
        callback_url = $callbackUrl
        scopes       = $Scopes
        client_id    = $GoogleClientId
        client_secret= $GoogleSecret
    } | Out-Null

    return @{
        app_id       = $safeId
        status       = $entry.status
        callback_url = $callbackUrl
        login_url    = $loginUrl
        admin_url    = $adminUrl
        setup_note   = "Paste this callback URL into Google Cloud Console → Credentials → OAuth2 → Authorized redirect URIs: $callbackUrl"
    }
}

function Set-OAuthConfig {
    <#.SYNOPSIS Set or update Google OAuth credentials for a registered app.
    Call this once the user has their Google client_id and secret.#>
    param(
        [Parameter(Mandatory)][string]$AppId,
        [Parameter(Mandatory)][string]$GoogleClientId,
        [Parameter(Mandatory)][string]$GoogleSecret,
        [string[]]$Scopes = @()
    )
    $safeId = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    if (-not $script:OAuthRegistry.ContainsKey($safeId)) {
        Write-Warning "Set-OAuthConfig: app '$safeId' not registered — call Register-AppOAuth first"
        return $null
    }
    $entry = $script:OAuthRegistry[$safeId]
    $entry['google_client_id'] = $GoogleClientId
    $entry['google_secret']    = $GoogleSecret
    $entry['status']           = 'configured'
    if ($Scopes) { $entry['scopes'] = $Scopes }
    $script:OAuthRegistry[$safeId] = $entry
    _SaveOAuthRegistry

    _OAuthPost '/oauth/config' @{
        app_id        = $safeId
        client_id     = $GoogleClientId
        client_secret = $GoogleSecret
        scopes        = $entry.scopes
    } | Out-Null

    return @{ app_id=$safeId; status='configured'; callback_url=$entry.callback_url }
}

function Get-OAuthConfig {
    param([Parameter(Mandatory)][string]$AppId)
    $safeId = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    if ($script:OAuthRegistry.ContainsKey($safeId)) { return $script:OAuthRegistry[$safeId] }
    return $null
}

function Get-OAuthAppList {
    return $script:OAuthRegistry.Keys | Sort-Object
}


# ── OAuth URL helpers ─────────────────────────────────────────────────────────

function Get-OAuthLoginUrl {
    <#.SYNOPSIS Get the login URL to send users to. Embed this in your app's login button.#>
    param(
        [Parameter(Mandatory)][string]$AppId,
        [string]$Provider = 'google',
        [string]$ReturnPath = ''
    )
    $safeId = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    $url    = "$($script:OAuthBase)/oauth/login/$safeId?provider=$Provider"
    if ($ReturnPath) { $url += "&return=$([Uri]::EscapeDataString($ReturnPath))" }
    return $url
}

function Get-OAuthCallbackUrl {
    param([Parameter(Mandatory)][string]$AppId)
    $safeId = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    return "$($script:OAuthBase)/oauth/callback/$safeId"
}

function Get-OAuthAdminUrl {
    param([Parameter(Mandatory)][string]$AppId)
    $safeId = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    return "$($script:OAuthBase)/oauth/admin/$safeId"
}


# ── Session management ────────────────────────────────────────────────────────

function Test-OAuthSession {
    <#.SYNOPSIS Validate a session token. Returns user info if valid, null if expired/invalid.#>
    param([Parameter(Mandatory)][string]$SessionToken)
    return _OAuthGet "/oauth/session/validate?token=$([Uri]::EscapeDataString($SessionToken))"
}

function Remove-OAuthSession {
    param([Parameter(Mandatory)][string]$SessionToken)
    return _OAuthPost '/oauth/session/revoke' @{ token = $SessionToken }
}

function Get-OAuthSessionUser {
    param([Parameter(Mandatory)][string]$SessionToken)
    return _OAuthGet "/oauth/session/user?token=$([Uri]::EscapeDataString($SessionToken))"
}


# ── App JSONL injection ───────────────────────────────────────────────────────

function Add-OAuthToAppSpec {
    <#.SYNOPSIS Inject OAuth login/callback/admin JSONL lines into an app spec array.
    Call this inside New-GemmaAppFromKeys — every app gets OAuth on auto.
    Returns the extended spec array.#>
    param(
        [Parameter(Mandatory)][string]$AppId,
        [Parameter(Mandatory)][array]$Spec,
        [string]$AppBase = 'http://localhost:5173'
    )
    $safeId   = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    $appKey   = "⟁APP:$safeId"
    $appSlug  = $safeId.ToLower() -replace '_','-'
    $schema   = 'key.grammar.asx-mini-app.v1'

    # auto-register if not already registered
    if (-not $script:OAuthRegistry.ContainsKey($safeId)) {
        Register-AppOAuth -AppId $safeId -AppBase $AppBase | Out-Null
    }

    $cfg = $script:OAuthRegistry[$safeId]

    $oauthLines = @(
        # login page
        @{ schema=$schema; key="$appKey/⟁PAGE:LOGIN"; phase='Pop'; channel='function_gram'; role='page';
           app_key=$appKey; component_type='oauth-login'; program='oauth.login'; event='oauth.initiate';
           executor='mx.run'; authority='projection_only'; semantic_authority=$false;
           oauth=@{ provider='google'; login_url=$cfg.login_url; scopes=$cfg.scopes } }

        # oauth callback handler (auto — user never sees this directly)
        @{ schema=$schema; key="$appKey/⟁PAGE:CALLBACK"; phase='Wo'; channel='function_gram'; role='page';
           app_key=$appKey; component_type='oauth-callback'; program='oauth.callback'; event='oauth.callback';
           executor='mx.run'; authority='projection_only'; semantic_authority=$false;
           oauth=@{ callback_url=$cfg.callback_url; redirect_to="$AppBase/?session={{session}}" } }

        # admin dashboard (protected — requires valid session with admin scope)
        @{ schema=$schema; key="$appKey/⟁PAGE:ADMIN"; phase='Ch''en'; channel='function_gram'; role='page';
           app_key=$appKey; component_type='admin-dashboard'; program='oauth.admin'; event='admin.load';
           executor='mx.run'; authority='projection_only'; semantic_authority=$false;
           oauth=@{ required_scope='admin'; admin_url=$cfg.admin_url } }

        # oauth programs
        @{ schema=$schema; key="$appKey/$appSlug.oauth_login"; phase='Pop'; channel='function_gram'; role='program';
           app_key=$appKey; program='oauth.login'; event='oauth.initiate'; executor='mx.run';
           authority='projection_only'; semantic_authority=$false }

        @{ schema=$schema; key="$appKey/$appSlug.oauth_callback"; phase='Wo'; channel='function_gram'; role='program';
           app_key=$appKey; program='oauth.callback'; event='oauth.callback'; executor='mx.run';
           authority='projection_only'; semantic_authority=$false }

        @{ schema=$schema; key="$appKey/$appSlug.oauth_logout"; phase='Xul'; channel='function_gram'; role='program';
           app_key=$appKey; program='oauth.logout'; event='oauth.logout'; executor='mx.run';
           authority='projection_only'; semantic_authority=$false }

        @{ schema=$schema; key="$appKey/$appSlug.admin_load"; phase='Ch''en'; channel='function_gram'; role='program';
           app_key=$appKey; program='oauth.admin'; event='admin.load'; executor='mx.run';
           authority='projection_only'; semantic_authority=$false }
    )

    return @($Spec) + $oauthLines
}


# ── Setup wizard (for non-technical users) ───────────────────────────────────

function Get-OAuthSetupGuide {
    <#.SYNOPSIS Print a human-readable OAuth setup guide for an app.
    Tells the user exactly what to do in Google Cloud Console.#>
    param([Parameter(Mandatory)][string]$AppId)
    $safeId = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    $cfg    = Get-OAuthConfig -AppId $safeId
    if (-not $cfg) {
        Write-Host "App '$safeId' not registered yet. Run: Register-AppOAuth -AppId '$safeId'"
        return
    }

    $status = if ($cfg.status -eq 'configured') { 'CONFIGURED' } else { 'NEEDS CREDENTIALS' }
    Write-Host ""
    Write-Host "=== OAuth Setup Guide for $safeId ($status) ===" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "1. Go to: https://console.cloud.google.com/apis/credentials" -ForegroundColor Yellow
    Write-Host "2. Create a new OAuth 2.0 Client ID (Application type: Web application)"
    Write-Host "3. Under 'Authorized redirect URIs', add this URL:"
    Write-Host "   $($cfg.callback_url)" -ForegroundColor Green
    Write-Host "4. Copy your Client ID and Client Secret"
    Write-Host "5. Run this command:"
    Write-Host "   Set-OAuthConfig -AppId '$safeId' -GoogleClientId 'YOUR_CLIENT_ID' -GoogleSecret 'YOUR_SECRET'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Login URL for your app's login button:"
    Write-Host "   $($cfg.login_url)" -ForegroundColor Green
    Write-Host "Admin dashboard:"
    Write-Host "   $($cfg.admin_url)" -ForegroundColor Green
    Write-Host ""
}

function New-OAuthSetupWizardPage {
    <#.SYNOPSIS Generate a self-contained HTML setup wizard page for an app.
    Renders the Google Console steps with the callback URL pre-filled.#>
    param(
        [Parameter(Mandatory)][string]$AppId,
        [string]$OutputPath = ''
    )
    $safeId = $AppId.ToUpper() -replace '[^A-Z0-9]','_'
    $cfg    = Get-OAuthConfig -AppId $safeId
    if (-not $cfg) { Register-AppOAuth -AppId $safeId | Out-Null; $cfg = Get-OAuthConfig $safeId }

    $kitRoot = Join-Path $PSScriptRoot '..\key-grammar-kit'
    if (-not $OutputPath) {
        $dir = Join-Path $kitRoot "data\host\oauth\$($safeId.ToLower())"
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        $OutputPath = Join-Path $dir 'oauth-setup.html'
    }

    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>OAuth Setup — $safeId</title>
<style>
  body { font-family: -apple-system, sans-serif; max-width: 640px; margin: 60px auto; padding: 0 24px; color: #1a1a2e; background: #f8f9ff; }
  h1   { font-size: 1.4rem; color: #4285f4; }
  .step { background: white; border-radius: 8px; padding: 20px; margin: 16px 0; box-shadow: 0 1px 4px rgba(0,0,0,.08); }
  .step h3 { margin: 0 0 8px; font-size: 1rem; }
  .url { background: #e8f0fe; border-radius: 4px; padding: 10px 14px; font-family: monospace; font-size: .9rem; color: #1a56db; cursor: pointer; user-select: all; }
  .cmd { background: #1a1a2e; border-radius: 4px; padding: 10px 14px; font-family: monospace; font-size: .85rem; color: #7dd3fc; }
  .badge { display:inline-block; padding: 2px 10px; border-radius: 12px; font-size:.8rem; }
  .pending { background:#fef3c7; color:#92400e; }
  .configured { background:#d1fae5; color:#065f46; }
  a { color: #4285f4; }
</style>
</head>
<body>
<h1>OAuth Setup — $safeId</h1>
<p>Status: <span class="badge $($cfg.status)">$($cfg.status)</span></p>
<div class="step">
  <h3>Step 1 — Open Google Cloud Console</h3>
  <p>Go to <a href="https://console.cloud.google.com/apis/credentials" target="_blank">console.cloud.google.com/apis/credentials</a> and create a new <strong>OAuth 2.0 Client ID</strong> (Application type: Web application).</p>
</div>
<div class="step">
  <h3>Step 2 — Add this Callback URL</h3>
  <p>Under <em>Authorized redirect URIs</em>, paste exactly:</p>
  <div class="url" title="Click to select">$($cfg.callback_url)</div>
</div>
<div class="step">
  <h3>Step 3 — Run this command with your credentials</h3>
  <div class="cmd">Set-OAuthConfig -AppId '$safeId' ``<br>  -GoogleClientId 'paste_client_id_here' ``<br>  -GoogleSecret 'paste_secret_here'</div>
</div>
<div class="step">
  <h3>Your App URLs</h3>
  <p>Login page (use in your app's login button):</p>
  <div class="url">$($cfg.login_url)</div>
  <p style="margin-top:12px">Admin dashboard:</p>
  <div class="url">$($cfg.admin_url)</div>
</div>
</body>
</html>
"@

    Set-Content -LiteralPath $OutputPath -Value $html -Encoding UTF8
    return $OutputPath
}


Export-ModuleMember -Function `
    Register-AppOAuth, Set-OAuthConfig, Get-OAuthConfig, Get-OAuthAppList, `
    Get-OAuthLoginUrl, Get-OAuthCallbackUrl, Get-OAuthAdminUrl, `
    Test-OAuthSession, Remove-OAuthSession, Get-OAuthSessionUser, `
    Add-OAuthToAppSpec, `
    Get-OAuthSetupGuide, New-OAuthSetupWizardPage
