#Requires -Version 5.1
# app.bindings.psm1 — bindings for APP-µ
# App lifecycle + binding-chain auditor: spec definition, scaffold proposals, registry load,
# 6-point completeness audit (micronaut JSON / track JSON / PSM1 / commands action / registry node / name_map)
# Authority: xcfe_gated_read_only / proposal_only
# Drivers: Micronaut.Core.dll, CFPC.Patterns.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force

$script:_AppId   = 'APP-µ'
$script:_KitRoot = Join-Path ($PSScriptRoot | Split-Path -Parent) 'key-grammar-kit'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-AppMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/app.micronaut.json'
}

function Test-AppHealth {
    Test-MicronautHealth -Id $script:_AppId
}

function Get-AppIdentity {
    Get-MicronautIdentity -Id $script:_AppId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-AppMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_AppId -Text $Text -Topic $Topic
}

function Invoke-AppAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_AppId -Text $Text -Topic $Topic -That $That
}

function Invoke-AppThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_AppId -Text $Text -Context $Context
}

function Read-AppRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_AppId -Key $Key -Category $Category
}

# ── Semantic deltas (read-only — proposal_only / xcfe_gated_read_only) ────────

function Invoke-AppRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_AppId -Resource $Resource -Params $Params
}

function Invoke-AppGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_AppId -ResourceId $ResourceId -Params $Params
}

function Invoke-AppList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_AppId -Scope $Scope -Filter $Filter
}

function Invoke-AppPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_AppId -Action $Action -Body $Body
}

# ── Domain-specific atomic keys ───────────────────────────────────────────────

function Invoke-AppSpec {
    # Pop/Wo-phase: define or validate a kuhul.app-spec.v1 — emits typed spec proposal
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Role        = '',
        [string[]]$Phases    = @('Pop','Wo','Yax','Sek','Ch''en','Xul'),
        [string[]]$AtomicKeys = @(),
        [string]$Authority   = 'xcfe_gated_read_only',
        [string[]]$Drivers   = @('Micronaut.Core.dll'),
        [string]$Namespace   = ''
    )
    $spec = @{
        id          = "$($Name.ToUpper())-µ"
        name        = $Name.ToLower()
        role        = $Role
        phases      = $Phases
        atomic_keys = $AtomicKeys
        authority   = $Authority
        drivers     = $Drivers
    }
    if ($Namespace) { $spec['namespace'] = $Namespace }
    Invoke-AtomicKey -Key 'app.spec' -Payload $spec
}

function Invoke-AppScaffold {
    # Yax/Sek-phase: generate scaffold proposals for the full 6-point binding chain
    # Returns proposal text for each artifact — does not write files
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Id      = '',
        [string]$Action  = '',
        [string]$Role    = '',
        [string[]]$Phases = @('Pop','Wo','Yax','Sek','Ch''en','Xul'),
        [string[]]$AtomicKeys = @()
    )
    $p = @{
        name        = $Name.ToLower()
        id          = if ($Id)     { $Id }     else { "$($Name.ToUpper())-µ" }
        action      = if ($Action) { $Action } else { $Name.ToLower() }
        role        = $Role
        phases      = $Phases
        atomic_keys = $AtomicKeys
    }
    Invoke-AtomicKey -Key 'app.scaffold' -Payload $p
}

function Invoke-AppLoad {
    # Pop-phase: Register-Micronaut for a named micronaut — requires xcfe_admitted
    param([Parameter(Mandatory)][string]$Name)
    Invoke-AtomicKey -Key 'app.load' -Payload @{ name = $Name.ToLower() }
}

function Invoke-AppAudit {
    # Yax-phase daemon-side audit — calls app.audit atomic key
    param([string]$Target = 'all', [switch]$Brief)
    $p = @{ target = $Target }
    if ($Brief) { $p['brief'] = $true }
    Invoke-AtomicKey -Key 'app.audit' -Payload $p
}

function Get-AppStatus {
    Invoke-AtomicKey -Key 'app.health' -Payload @{}
}

# ── Local 6-point binding-chain audit (no daemon required) ────────────────────

function Test-AppBindingChain {
    <#.SYNOPSIS
    Local filesystem audit of the 6-point binding chain for a named micronaut.
    Does not require the AIML daemon to be running.
    Points: micronaut_json | track_json | shell_psm1 | commands_action | registry_node | name_map_entry
    #>
    param(
        [Parameter(Mandatory)][string]$Name,
        [string]$Id     = '',
        [string]$Action = ''
    )
    $busRoot = $PSScriptRoot | Split-Path -Parent
    $kitRoot = $script:_KitRoot
    $n       = $Name.ToLower()
    $id      = if ($Id)     { $Id }     else { "$($Name.ToUpper())-µ" }
    $action  = if ($Action) { $Action } else { $n }

    # 1. micronaut_json
    $mjPath = Join-Path $kitRoot "data\micronauts\$n.micronaut.json"
    $mjOk   = Test-Path $mjPath

    # 2. track_json — read track_ref from micronaut JSON (authoritative)
    $trackOk = $false
    if ($mjOk) {
        try {
            $mj       = Get-Content $mjPath -Raw | ConvertFrom-Json
            $trackRef = [string]($mj.track_ref)
            if ($trackRef) {
                $trackOk = Test-Path (Join-Path $kitRoot ($trackRef -replace '/','\'))
            }
        } catch {}
    }

    # 3. shell_psm1
    $psm1Ok = Test-Path (Join-Path $busRoot "shell\$n.bindings.psm1")

    # 4. commands_action — present in ValidateSet in commands.ps1
    $cmdPath = Join-Path $kitRoot "micronaut\mx2lm-wpf-cli-v1\agents\commands.ps1"
    $cmdOk   = $false
    if (Test-Path $cmdPath) {
        $cmdOk = [bool](Select-String -Path $cmdPath -Pattern ([regex]::Escape("`"$action`"")) -Quiet)
    }

    # 5. registry_node — node:{id} key present in micronaut.registry.xjson
    $regPath = Join-Path $kitRoot "micronaut\mx2lm-wpf-cli-v1\micronaut.registry.xjson"
    $nodeOk  = $false
    $nmOk    = $false
    if (Test-Path $regPath) {
        $nodeOk = [bool](Select-String -Path $regPath -Pattern ([regex]::Escape("`"node:$id`"")) -Quiet)
        # 6. name_map_entry — "{action}": present in name_map section
        $nmOk   = [bool](Select-String -Path $regPath -Pattern ([regex]::Escape("`"$action`":")) -Quiet)
    }

    $checks = [ordered]@{
        micronaut_json  = $mjOk
        track_json      = $trackOk
        shell_psm1      = $psm1Ok
        commands_action = $cmdOk
        registry_node   = $nodeOk
        name_map_entry  = $nmOk
    }
    $pass    = @($checks.Values | Where-Object { $_ }).Count
    $missing = @($checks.GetEnumerator() | Where-Object { -not $_.Value } | Select-Object -ExpandProperty Key)
    $complete = $pass -eq 6

    return [pscustomobject]@{
        id       = $id
        name     = $n
        action   = $action
        points   = $checks
        complete = $complete
        missing  = $missing
        score    = "$pass/6"
    }
}

function Test-AllBindingChains {
    <#.SYNOPSIS
    Runs Test-AppBindingChain against every micronaut registered in micronaut.registry.xjson name_map.
    Returns a summary table sorted by score ascending (incomplete first).
    #>
    $kitRoot = $script:_KitRoot
    $regPath = Join-Path $kitRoot "micronaut\mx2lm-wpf-cli-v1\micronaut.registry.xjson"
    if (-not (Test-Path $regPath)) {
        Write-Warning "Test-AllBindingChains: registry not found at $regPath"
        return
    }

    $reg     = Get-Content $regPath -Raw | ConvertFrom-Json
    $nameMap = $reg.name_map
    if (-not $nameMap) { Write-Warning "Test-AllBindingChains: name_map not found in registry"; return }

    $results = @()
    foreach ($prop in $nameMap.PSObject.Properties) {
        $action = $prop.Name
        $id     = [string]$prop.Value
        $name   = ($id -replace '-µ$','' -replace 'µ$','').ToLower()
        $result = Test-AppBindingChain -Name $name -Id $id -Action $action
        $results += $result
    }

    return $results | Sort-Object { [int]($_.score -replace '/6','') }
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_AppDrivers = @(
    'Micronaut.Core.dll',
    'CFPC.Patterns.dll'
)

function Import-AppDrivers {
    Import-MicronautDrivers -DriverNames $script:_AppDrivers
}

function Import-AppDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-AppMicronaut, Test-AppHealth, Get-AppIdentity, `
    Invoke-AppMatch, Invoke-AppAgent, Invoke-AppThink, Read-AppRecall, `
    Invoke-AppRead, Invoke-AppGet, Invoke-AppList, Invoke-AppPost, `
    Invoke-AppSpec, Invoke-AppScaffold, Invoke-AppLoad, `
    Invoke-AppAudit, Get-AppStatus, `
    Test-AppBindingChain, Test-AllBindingChains, `
    Import-AppDrivers, Import-AppDriver
