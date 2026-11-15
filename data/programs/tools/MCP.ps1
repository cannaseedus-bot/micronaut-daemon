[CmdletBinding()]
param(
    [ValidateSet('status', 'start', 'stop', 'list', 'validate-replay', 'validate-registry', 'validate-cube', 'validate-jrom', 'snapshot-micronauts', 'stop-code-micronaut', 'start-code-micronaut', 'start-micronaut-v4', 'stop-micronaut-v4')]
    [string]$Action = 'status',
    [switch]$IncludeGateway,
    [int]$Port = 8766,
    [string]$Manifest = '',
    [string]$ReplayStream = ''
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$toolsRoot = Join-Path $root 'programs\tools'
$Manifest = if ($Manifest) { $Manifest } else { Join-Path $toolsRoot 'atomic_mcp.manifest.json' }
$ReplayStream = if ($ReplayStream) { $ReplayStream } else { Join-Path $toolsRoot 'replay\tool-events.jsonl' }
$dotnet = 'C:\Program Files\dotnet\dotnet.exe'
$sdkRoot = Join-Path $root 'dist\csharp-sdk'
$launcher = Join-Path $root 'dist\micronauts\micronaut-mcp-cs\launch.bat'
$serverRoot = Join-Path $root 'dist\khanary-mcp-server'
$gatewayLauncher = Join-Path $root 'kuhul-server.bat'
$logDir = Join-Path $root 'logs'
$mcpLog = Join-Path $logDir 'mcp-cs-1.log'
$mcpErr = Join-Path $logDir 'mcp-cs-1.err'
$gatewayPort = 8764
$codeMicronautNativePath = Join-Path $root 'dist\micronaut-coder\code-micronaut\native\build-nnck\Release\code_micronaut_native.exe'
$codeMicronautNativePort = 3167
$codeMicronautNativeLog = Join-Path $logDir 'code-micronaut-native.log'
$codeMicronautNativeErr = Join-Path $logDir 'code-micronaut-native.err'
$micronautV4Path = Join-Path $root 'micronaut-v4\Micronaut.ps1'
$micronautV4RestPort = 17889
$micronautV4PwaPort = 17888
$micronautV4Log = Join-Path $logDir 'micronaut-v4.log'
$micronautV4Err = Join-Path $logDir 'micronaut-v4.err'

function Start-CodeMicronautNative {
    if (-not (Test-Path -LiteralPath $codeMicronautNativePath)) {
        $fallback = Join-Path $root 'dist\micronaut-coder\code-micronaut\code_micronaut_native.exe'
        if (Test-Path -LiteralPath $fallback) { $script:codeMicronautNativePath = $fallback }
    }
    if (-not (Test-Path -LiteralPath $codeMicronautNativePath)) {
        throw "code-micronaut native executable not found: $codeMicronautNativePath"
    }
    if (Test-Port $codeMicronautNativePort) {
        Write-Host "[code-micronaut] native server already listening on :$codeMicronautNativePort"
        return
    }
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    Write-Host "[code-micronaut] starting native server on :$codeMicronautNativePort"
    Start-Process -FilePath $codeMicronautNativePath -WorkingDirectory (Split-Path $codeMicronautNativePath) `
        -WindowStyle Hidden -RedirectStandardOutput $codeMicronautNativeLog -RedirectStandardError $codeMicronautNativeErr | Out-Null
    if (-not (Wait-Port $codeMicronautNativePort 10)) {
        Write-ServiceStatus 'code-micronaut-native' $codeMicronautNativePort "http://127.0.0.1:$codeMicronautNativePort/health"
        if (Test-Path -LiteralPath $codeMicronautNativeErr) {
            Write-Host '[code-micronaut] startup error log:'
            Get-Content -LiteralPath $codeMicronautNativeErr -Tail 20
        }
        throw "code-micronaut native server did not become ready on :$codeMicronautNativePort"
    }
    Write-ServiceStatus 'code-micronaut-native' $codeMicronautNativePort "http://127.0.0.1:$codeMicronautNativePort/health"
}

function Stop-CodeMicronautNative {
    Stop-Port $codeMicronautNativePort 'code-micronaut-native'
}

function Start-MicronautV4 {
    if (-not (Test-Path -LiteralPath $micronautV4Path)) { throw "Micronaut.ps1 not found: $micronautV4Path" }
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    if (Test-Port $micronautV4RestPort) {
        Write-Host "[micronaut-v4] already listening on :$micronautV4RestPort"
        return
    }
    # Find a free PWA port near the default if it is still held by http.sys.
    $pwaPort = $micronautV4PwaPort
    while ($pwaPort -lt 17900 -and ($pwaPort -eq $micronautV4RestPort -or (Test-Port $pwaPort))) { $pwaPort++ }
    Write-Host "[micronaut-v4] starting headless runtime on :$micronautV4RestPort (PWA :$pwaPort)"
    $proc = Start-Process -FilePath pwsh -ArgumentList @('-NoProfile','-File',$micronautV4Path,'-Mode','Headless','-RestPort',$micronautV4RestPort,'-PwaPort',$pwaPort) -WorkingDirectory $root -WindowStyle Hidden -RedirectStandardOutput $micronautV4Log -RedirectStandardError $micronautV4Err -PassThru
    $stateFile = Join-Path $logDir 'micronaut-v4.state.json'
    @{ pid = $proc.Id; restPort = $micronautV4RestPort; pwaPort = $pwaPort } | ConvertTo-Json -Depth 5 -Compress | Set-Content -LiteralPath $stateFile -Encoding utf8
    if (-not (Wait-Port $micronautV4RestPort 15)) {
        Write-ServiceStatus 'micronaut-v4' $micronautV4RestPort "http://127.0.0.1:$micronautV4RestPort/health"
        if (Test-Path -LiteralPath $micronautV4Err) {
            Write-Host '[micronaut-v4] startup error log:'
            Get-Content -LiteralPath $micronautV4Err -Tail 20
        }
        throw "micronaut-v4 did not become ready on :$micronautV4RestPort"
    }
    Write-ServiceStatus 'micronaut-v4' $micronautV4RestPort "http://127.0.0.1:$micronautV4RestPort/health"
}

function Stop-MicronautV4 {
    $stateFile = Join-Path $logDir 'micronaut-v4.state.json'
    $pwaPort = $micronautV4PwaPort
    if (Test-Path -LiteralPath $stateFile) {
        $state = Get-Content -Raw -LiteralPath $stateFile | ConvertFrom-Json
        $processId = $state.pid
        $pwaPort = $state.pwaPort
        $proc = Get-Process -Id $processId -ErrorAction SilentlyContinue
        if ($proc -and $proc.Id -gt 10) {
            Write-Host "[micronaut-v4] stopping runtime PID $($proc.Id)"
            Stop-Process -Id $proc.Id -Force -ErrorAction SilentlyContinue
        }
        Remove-Item -LiteralPath $stateFile -Force -ErrorAction SilentlyContinue
    }
    Stop-Port $micronautV4RestPort 'micronaut-v4-rest'
    Stop-Port $pwaPort 'micronaut-v4-pwa'
}

function Test-JsonFile([string]$Path) {
    if (-not (Test-Path -LiteralPath $Path)) { throw "file not found: $Path" }
    Get-Content -Raw -LiteralPath $Path | ConvertFrom-Json | Out-Null
    Write-Host "[valid] $Path"
}

function Test-Port([int]$CheckPort) {
    # netstat is the same reliable check used by START-SERVERS.bat and also
    # sees localhost listeners when Get-NetTCPConnection is unavailable or
    # temporarily stale in a constrained PowerShell session.
    $line = netstat -ano 2>$null | Select-String -Pattern (":$CheckPort\s+.*LISTENING") | Select-Object -First 1
    if ($line) { return $true }
    $connection = Get-NetTCPConnection -LocalPort $CheckPort -State Listen -ErrorAction SilentlyContinue |
        Select-Object -First 1
    return $null -ne $connection
}

function Write-ServiceStatus([string]$Name, [int]$CheckPort, [string]$Endpoint) {
    if (Test-Port $CheckPort) {
        Write-Host "[UP]   $Name :$CheckPort $Endpoint"
    } else {
        Write-Host "[DOWN] $Name :$CheckPort"
    }
}

function Wait-Port([int]$WaitPort, [int]$TimeoutSeconds = 15) {
    $deadline = (Get-Date).AddSeconds($TimeoutSeconds)
    do {
        if (Test-Port $WaitPort) { return $true }
        Start-Sleep -Milliseconds 500
    } while ((Get-Date) -lt $deadline)
    return $false
}

function Start-McpSidecar {
    if (-not (Test-Path -LiteralPath $dotnet)) { throw "dotnet not found: $dotnet" }
    if (-not (Test-Path -LiteralPath $serverRoot)) { throw "MCP server root not found: $serverRoot" }
    New-Item -ItemType Directory -Force -Path $logDir | Out-Null
    if (Test-Port $Port) {
        Write-Host "[MCP] C# sidecar already listening on :$Port"
        return
    }
    Write-Host "[MCP] starting C# sidecar on :$Port"
    $arguments = @('run', '--project', 'KhanaryMcpServer.csproj', '-c', 'Release', '--no-launch-profile')
    Start-Process -FilePath $dotnet -ArgumentList $arguments -WorkingDirectory $serverRoot -WindowStyle Hidden `
        -RedirectStandardOutput $mcpLog -RedirectStandardError $mcpErr | Out-Null
    if (-not (Wait-Port $Port)) {
        Write-ServiceStatus 'mcp-cs-1' $Port "http://127.0.0.1:$Port/mcp"
        if (Test-Path -LiteralPath $mcpErr) {
            Write-Host '[MCP] startup error log:'
            Get-Content -LiteralPath $mcpErr -Tail 20
        }
        throw "C# MCP sidecar did not become ready on :$Port"
    }
    Write-ServiceStatus 'mcp-cs-1' $Port "http://127.0.0.1:$Port/mcp"
}

function Stop-Port([int]$StopPort, [string]$Name) {
    $connections = @(Get-NetTCPConnection -LocalPort $StopPort -State Listen -ErrorAction SilentlyContinue)
    foreach ($connection in $connections) {
        $process = Get-Process -Id $connection.OwningProcess -ErrorAction SilentlyContinue
        if ($process -and $process.Id -gt 10 -and $process.ProcessName -ne 'System') {
            Write-Host "[MCP] stopping $Name PID $($process.Id) on :$StopPort"
            Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
        }
    }
}

function Test-JromStream {
    $stream = Join-Path $root 'programs\tools\replay\tool-events.jsonl'
    $valid = $false
    if (Test-Path -LiteralPath $stream) {
        $lines = @(Get-Content -LiteralPath $stream -ErrorAction SilentlyContinue)
        Write-Host "[JROM] stream: $stream"
        Write-Host "[JROM] events: $($lines.Count)"
        $valid = $true
    } else {
        Write-Host "[JROM] stream not found: $stream"
    }
    return $valid
}

function Snapshot-MicronautsToJrom {
    $response = Invoke-Mcp 'tools/call' @{ name = 'kuhul_micronaut_registry'; arguments = @{} }
    $response | ConvertTo-Json -Depth 30
}

function Invoke-Mcp([string]$Method, [object]$Params = @{}) {
    $body = @{ jsonrpc = '2.0'; id = 1; method = $Method; params = $Params } |
        ConvertTo-Json -Depth 20 -Compress
    $headers = @{ Accept = 'application/json, text/event-stream' }
    Invoke-RestMethod -Uri "http://127.0.0.1:$Port/mcp" -Method Post `
        -ContentType 'application/json' -Headers $headers -Body $body
}

switch ($Action) {
    'status' {
        Write-Host "[AtomicMCP] manifest: $Manifest"
        Write-ServiceStatus 'mcp-cs-1' $Port "http://127.0.0.1:$Port/mcp"
        if ($IncludeGateway) { Write-ServiceStatus 'kuhul-gateway' $gatewayPort 'http://127.0.0.1:8764/mcp' }
        Test-JromStream | Out-Null
    }
    'start' {
        if (-not (Test-Path -LiteralPath $Manifest)) { throw "manifest not found: $Manifest" }
        Get-Content -Raw -LiteralPath $Manifest | ConvertFrom-Json | Out-Null
        Start-McpSidecar
        if ($IncludeGateway) {
            if (-not (Test-Path -LiteralPath $gatewayLauncher)) { throw "gateway launcher not found: $gatewayLauncher" }
            if (-not (Test-Port $gatewayPort)) {
                Start-Process -FilePath $gatewayLauncher -WorkingDirectory $root -WindowStyle Hidden | Out-Null
                if (-not (Wait-Port $gatewayPort)) {
                    throw "KUHUL gateway did not become ready on :$gatewayPort"
                }
            }
            Write-ServiceStatus 'kuhul-gateway' $gatewayPort 'http://127.0.0.1:8764/mcp'
        }
    }
    'stop' {
        Stop-Port $Port 'mcp-cs-1'
        if ($IncludeGateway) { Stop-Port $gatewayPort 'kuhul-gateway' }
    }
    'list' {
        if (-not (Test-Port $Port)) { throw "MCP sidecar is not listening on :$Port; run -Action start first" }
        Invoke-Mcp 'initialize' @{
            protocolVersion = '2025-06-18'
            capabilities = @{}
            clientInfo = @{ name = 'AtomicMCP.ps1'; version = '1.0.0' }
        } | Out-Null
        $response = Invoke-Mcp 'tools/list'
        $response | ConvertTo-Json -Depth 30
    }
    'validate-replay' {
        $replay = Join-Path $root 'programs\tools\jrom_replay.py'
        if (-not (Test-Path -LiteralPath $replay)) { throw "replay helper not found: $replay" }
        & python $replay --stream $ReplayStream --validate
        if ($LASTEXITCODE -ne 0) { throw "replay validation failed" }
    }
    'validate-registry' {
        Test-JsonFile (Join-Path $toolsRoot 'tool_registry.json')
    }
    'validate-cube' {
        Test-JsonFile (Join-Path $root 'programs\semantic_cube.tool-router.json')
    }
    'validate-jrom' {
        $replay = Join-Path $root 'programs\tools\jrom_replay.py'
        if (-not (Test-Path -LiteralPath $replay)) { throw "jrom replay helper not found: $replay" }
        & python $replay --stream (Join-Path $root 'programs\tools\replay\tool-events.jsonl') --validate
        if ($LASTEXITCODE -ne 0) { throw "jrom validation failed" }
    }
    'snapshot-micronauts' {
        Snapshot-MicronautsToJrom
    }
    'start-code-micronaut' {
        Start-CodeMicronautNative
    }
    'stop-code-micronaut' {
        Stop-CodeMicronautNative
    }
    'start-micronaut-v4' {
        Start-MicronautV4
    }
    'stop-micronaut-v4' {
        Stop-MicronautV4
    }
    default { throw "Unknown action: $Action" }
}
