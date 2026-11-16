#Requires -Version 7
# identity-dashboard.ps1 — AI-µ Identity Dashboard (WPF + WebView2)
# Launch: pwsh -STA -File .\tools\dashboard\identity-dashboard.ps1
#
# Ports:
#   9879  eliza-µ HTTP runtime  (started if not already up)
#   9882  static file server    (serves identity-dashboard/ + proxies /api/chat)
#
# NEVER 8080.  BOSS=8764  kuhul_engine=17474

param(
    [int]    $RuntimePort   = 9879,
    [int]    $DashboardPort = 9882,
    [string] $CliPath       = "$env:USERPROFILE\.micronaut_daemon\..\bin\eliza-µ.exe"
)

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

trap {
    $msg = $_.Exception.ToString()
    $msg | Out-File (Join-Path $PSScriptRoot 'identity-dashboard-error.log') -Append -Encoding UTF8
    [System.Windows.MessageBox]::Show($msg, 'AI-µ Dashboard Error', 'OK', 'Error') | Out-Null
    break
}

$script:RepoRoot  = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script:DashDir   = Join-Path $PSScriptRoot 'identity-dashboard'
$script:CliPath   = $CliPath
$script:DashUrl   = "http://127.0.0.1:${DashboardPort}?runtime=${RuntimePort}"

# ── WebView2 SDK ───────────────────────────────────────────────────────────────
$script:WebView2Available = $false
$script:WebView2Status    = 'WebView2 SDK unavailable'

$webViewSdkRoot     = Join-Path $script:RepoRoot '.CSS-C\webview2_sdk'
$webViewManaged     = Join-Path $webViewSdkRoot 'lib_manual\netcoreapp3.0'
$webViewNativeArch  = if ([Environment]::Is64BitProcess) { 'win-x64' } else { 'win-x86' }
$webViewNativeLoader = Join-Path $webViewSdkRoot "runtimes\$webViewNativeArch\native\WebView2Loader.dll"

try {
    Add-Type -Path (Join-Path $webViewManaged 'Microsoft.Web.WebView2.Core.dll') -ErrorAction Stop
    Add-Type -Path (Join-Path $webViewManaged 'Microsoft.Web.WebView2.Wpf.dll')  -ErrorAction Stop
    $null = [System.Runtime.InteropServices.NativeLibrary]::Load($webViewNativeLoader)
    $webViewVersion = [Microsoft.Web.WebView2.Core.CoreWebView2Environment]::GetAvailableBrowserVersionString()
    $script:WebView2Available = $true
    $script:WebView2Status    = "Edge WebView2 $webViewVersion"
} catch {
    $script:WebView2Status = "WebView2 unavailable: $($_.Exception.Message)"
}

# ── MIME helper ────────────────────────────────────────────────────────────────
function Get-MimeType([string]$path) {
    switch ([System.IO.Path]::GetExtension($path).ToLower()) {
        '.html' { 'text/html; charset=utf-8' }
        '.tsx'  { 'application/javascript; charset=utf-8' }
        '.ts'   { 'application/javascript; charset=utf-8' }
        '.js'   { 'application/javascript; charset=utf-8' }
        '.mjs'  { 'application/javascript; charset=utf-8' }
        '.css'  { 'text/css; charset=utf-8' }
        '.json' { 'application/json; charset=utf-8' }
        '.svg'  { 'image/svg+xml' }
        '.png'  { 'image/png' }
        default { 'application/octet-stream' }
    }
}

# ── Static HTTP server + /api/chat proxy (background runspace) ────────────────
$script:Listener = [System.Net.HttpListener]::new()
$script:Listener.Prefixes.Add("http://127.0.0.1:${DashboardPort}/")
$script:Listener.Start()

$rs = [runspacefactory]::CreateRunspace()
$rs.Open()
$ps = [powershell]::Create()
$ps.Runspace = $rs
$null = $ps.AddScript({
    param($listener, $dashDir, $runtimePort, $appsDir)

    function MimeFor([string]$p) {
        switch ([System.IO.Path]::GetExtension($p).ToLower()) {
            '.html' { 'text/html; charset=utf-8' }
            '.tsx'  { 'application/javascript; charset=utf-8' }
            '.ts'   { 'application/javascript; charset=utf-8' }
            '.js'   { 'application/javascript; charset=utf-8' }
            '.css'  { 'text/css; charset=utf-8' }
            '.json' { 'application/json; charset=utf-8' }
            '.svg'  { 'image/svg+xml' }
            '.png'  { 'image/png' }
            default { 'application/octet-stream' }
        }
    }

    function SendBytes($resp, [byte[]]$buf, [string]$ct) {
        $resp.ContentType       = $ct
        $resp.ContentLength64   = $buf.Length
        $resp.Headers.Add('Access-Control-Allow-Origin', '*')
        $resp.OutputStream.Write($buf, 0, $buf.Length)
        $resp.OutputStream.Close()
    }

    while ($listener.IsListening) {
        try {
            $ctx  = $listener.GetContext()
            $req  = $ctx.Request
            $resp = $ctx.Response

            # OPTIONS preflight
            if ($req.HttpMethod -eq 'OPTIONS') {
                $resp.Headers.Add('Access-Control-Allow-Origin',  '*')
                $resp.Headers.Add('Access-Control-Allow-Methods', 'GET,POST,OPTIONS')
                $resp.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')
                $resp.StatusCode = 204
                $resp.OutputStream.Close()
                continue
            }

            $urlPath = $req.Url.AbsolutePath.TrimStart('/')

            # /api/chat — proxy to eliza-µ runtime
            if ($urlPath -eq 'api/chat' -and $req.HttpMethod -eq 'POST') {
                try {
                    $body = (New-Object System.IO.StreamReader($req.InputStream, $req.ContentEncoding)).ReadToEnd()
                    $wc   = [System.Net.WebClient]::new()
                    $wc.Headers.Add('Content-Type', 'application/json')
                    $result = $wc.UploadString("http://127.0.0.1:${runtimePort}/api/chat", $body)
                    SendBytes $resp ([System.Text.Encoding]::UTF8.GetBytes($result)) 'application/json; charset=utf-8'
                } catch {
                    $errBody = '{"error":"runtime unavailable","offline":true}'
                    SendBytes $resp ([System.Text.Encoding]::UTF8.GetBytes($errBody)) 'application/json; charset=utf-8'
                }
                continue
            }

            # /health
            if ($urlPath -eq 'health') {
                $ok = '{"status":"ok","service":"ai-mu-identity-dashboard"}'
                SendBytes $resp ([System.Text.Encoding]::UTF8.GetBytes($ok)) 'application/json; charset=utf-8'
                continue
            }

            # /infographics/* — serve SVG assets from data/apps/
            if ($urlPath.StartsWith('infographics/')) {
                $assetFile = $urlPath.Substring('infographics/'.Length)
                $filePath  = Join-Path $appsDir $assetFile
            } else {
                # Static files from dashboard dir
                $filePath = Join-Path $dashDir ($urlPath -replace '/', [System.IO.Path]::DirectorySeparatorChar)
                if ([string]::IsNullOrEmpty($urlPath) -or $urlPath -eq '/') {
                    $filePath = Join-Path $dashDir 'index.html'
                }
            }
            if (Test-Path $filePath -PathType Leaf) {
                $bytes = [System.IO.File]::ReadAllBytes($filePath)
                SendBytes $resp $bytes (MimeFor $filePath)
            } else {
                $resp.StatusCode = 404
                $buf = [System.Text.Encoding]::UTF8.GetBytes("not found: $urlPath")
                $resp.ContentLength64 = $buf.Length
                $resp.OutputStream.Write($buf, 0, $buf.Length)
                $resp.OutputStream.Close()
            }
        } catch [System.Net.HttpListenerException] {
            # Listener stopped — exit loop
            break
        } catch {
            try { $ctx.Response.StatusCode = 500; $ctx.Response.OutputStream.Close() } catch {}
        }
    }
}).AddArgument($script:Listener).AddArgument($script:DashDir).AddArgument($RuntimePort).AddArgument((Join-Path $script:RepoRoot 'data\apps'))

$script:ListenerJob = $ps.BeginInvoke()

# ── Start eliza-µ --http if not already listening on RuntimePort ──────────────
$script:ElizaProcess = $null
$runtimeUp = $false
try {
    $resp = Invoke-WebRequest -Uri "http://127.0.0.1:${RuntimePort}/health" -TimeoutSec 1 -ErrorAction Stop
    $runtimeUp = ($resp.StatusCode -eq 200)
} catch {}

if (-not $runtimeUp) {
    $elizaExe = $script:CliPath
    if (Test-Path $elizaExe) {
        $script:ElizaProcess = Start-Process -FilePath $elizaExe -ArgumentList '--http' `
            -PassThru -WindowStyle Hidden
        Start-Sleep -Milliseconds 1200
    }
}

# ── XAML ──────────────────────────────────────────────────────────────────────
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="AI-µ · Identity Dashboard"
        Height="720" Width="1100" MinHeight="480" MinWidth="760"
        WindowStartupLocation="CenterScreen"
        Background="#01040a">
  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="40"/>
      <RowDefinition Height="*"/>
    </Grid.RowDefinitions>

    <!-- Title bar -->
    <Border Grid.Row="0" Background="#020b12"
            BorderBrush="#30363d" BorderThickness="0,0,0,1">
      <DockPanel Margin="14,0">
        <TextBlock Text="⟁ AI-µ  Identity Dashboard" Foreground="#a855f7"
                   FontSize="13" FontWeight="Bold" VerticalAlignment="Center"/>
        <TextBlock x:Name="StatusText" DockPanel.Dock="Right"
                   Foreground="#6b7280" FontSize="11" VerticalAlignment="Center"
                   HorizontalAlignment="Right"/>
      </DockPanel>
    </Border>

    <!-- Content: WebView2 or fallback -->
    <Border x:Name="ContentBorder" Grid.Row="1" Background="#01040a"/>
  </Grid>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

$statusText   = $window.FindName('StatusText')
$contentBorder = $window.FindName('ContentBorder')

$statusText.Text = $script:WebView2Status

# ── Mount WebView2 or text fallback ───────────────────────────────────────────
if ($script:WebView2Available) {
    $wv = [Microsoft.Web.WebView2.Wpf.WebView2]::new()
    $contentBorder.Child = $wv

    $wv.Add_Loaded({
        try {
            $udFolder = Join-Path $env:LOCALAPPDATA 'AI-mu-WebView2'
            [System.IO.Directory]::CreateDirectory($udFolder) | Out-Null
            $envTask = [Microsoft.Web.WebView2.Core.CoreWebView2Environment]::CreateAsync(
                [string]::Empty, $udFolder, $null)
            $envTask.Wait()
            $wv.EnsureCoreWebView2Async($envTask.Result) | Out-Null
        } catch {
            # fallback: let WebView2 pick its own folder
            $wv.EnsureCoreWebView2Async($null) | Out-Null
        }
    })

    $wv.Add_CoreWebView2InitializationCompleted({
        param($s, $e)
        if ($e.IsSuccess) {
            $wv.CoreWebView2.Navigate($script:DashUrl)
        } else {
            $statusText.Text = "WebView2 init failed: $($e.InitializationException.Message)"
        }
    })
} else {
    $tb = [System.Windows.Controls.TextBlock]::new()
    $tb.Text        = "WebView2 unavailable.`nOpen $($script:DashUrl) in a browser."
    $tb.Foreground  = [System.Windows.Media.Brushes]::Gray
    $tb.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $tb.Margin      = [System.Windows.Thickness]::new(24)
    $contentBorder.Child = $tb
}

# ── Cleanup on close ──────────────────────────────────────────────────────────
$window.Add_Closed({
    try { $script:Listener.Stop() } catch {}
    try { $ps.Stop() } catch {}
    try { $rs.Close() } catch {}
    if ($script:ElizaProcess -and -not $script:ElizaProcess.HasExited) {
        $script:ElizaProcess.Kill()
    }
})

# ── Run WPF (STA required) ────────────────────────────────────────────────────
$null = $window.ShowDialog()
