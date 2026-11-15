#Requires -Version 7
# Micronaut.ps1 — WPF chat shell with local Gemma bridge bus
# Launch: pwsh -STA -File .\Micronaut.ps1

param(
    [string]$CliPath = "C:\Users\canna\.micronauts\models\micronauts\native\micronaut.exe"
)

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

# Load the local WebView2 SDK for modern in-chat HTML/WebGL2 content.
$script:WebView2Available = $false
$script:WebView2Status = 'WebView2 SDK/runtime unavailable'
$webViewSdkRoot = Join-Path $PSScriptRoot '.CSS-C\webview2_sdk'
$webViewManaged = Join-Path $webViewSdkRoot 'lib_manual\netcoreapp3.0'
$webViewNativeArch = if ([Environment]::Is64BitProcess) { 'win-x64' } else { 'win-x86' }
$webViewNativeLoader = Join-Path $webViewSdkRoot "runtimes\$webViewNativeArch\native\WebView2Loader.dll"
try {
    Add-Type -Path (Join-Path $webViewManaged 'Microsoft.Web.WebView2.Core.dll') -ErrorAction Stop
    Add-Type -Path (Join-Path $webViewManaged 'Microsoft.Web.WebView2.Wpf.dll') -ErrorAction Stop
    $script:WebView2LoaderHandle = [System.Runtime.InteropServices.NativeLibrary]::Load($webViewNativeLoader)
    $webViewVersion = [Microsoft.Web.WebView2.Core.CoreWebView2Environment]::GetAvailableBrowserVersionString()
    $script:WebView2Available = $true
    $script:WebView2Status = "Edge WebView2 $webViewVersion"
} catch {
    $script:WebView2Status = "WebView2 unavailable: $($_.Exception.Message)"
}

# ── XAML ──────────────────────────────────────────────────────────────────────
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Micronaut — Gemma Bridge"
        Height="800" Width="1390" MinWidth="970" MinHeight="520"
        WindowStartupLocation="CenterScreen"
        Background="#0D1117" FontFamily="Consolas">
  <Grid>
    <Grid.ColumnDefinitions>
      <ColumnDefinition Width="240" MinWidth="190"/>
      <ColumnDefinition Width="5"/>
      <ColumnDefinition Width="2.5*" MinWidth="420"/>
      <ColumnDefinition Width="5"/>
      <ColumnDefinition Width="1*"   MinWidth="220"/>
    </Grid.ColumnDefinitions>

    <!-- Left navigation and chat history -->
    <Grid Grid.Column="0" Background="#111820">
      <Grid.RowDefinitions>
        <RowDefinition Height="54"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>
      <Border Background="#161B22" BorderBrush="#21262D" BorderThickness="0,0,0,1">
        <TextBlock Text="⟁ MICRONAUT" Foreground="#E6EDF3" FontSize="15" FontWeight="Bold"
                   VerticalAlignment="Center" Margin="16,0"/>
      </Border>
      <StackPanel Grid.Row="1" Margin="10,12,10,8">
        <Button x:Name="NewChatBtn" Content="＋  New chat" Height="36" Margin="0,0,0,6"
                Background="#238636" Foreground="White" BorderThickness="0" Cursor="Hand"/>
      </StackPanel>
      <Grid Grid.Row="2">
        <Grid.RowDefinitions><RowDefinition Height="34"/><RowDefinition Height="*"/></Grid.RowDefinitions>
        <TextBlock Text="CHAT HISTORY" Foreground="#8B949E" FontSize="10" FontWeight="Bold"
                   VerticalAlignment="Center" Margin="16,0"/>
        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
          <StackPanel x:Name="HistoryPanel" Margin="8,0,8,8"/>
        </ScrollViewer>
      </Grid>
      <Border Grid.Row="3" Margin="10,8,10,12" Padding="10" CornerRadius="8"
              Background="#1C2631" BorderBrush="#303D4B" BorderThickness="1">
        <DockPanel>
          <Border Width="34" Height="34" CornerRadius="17" Background="#1F6FEB" DockPanel.Dock="Left">
            <TextBlock Text="µ" Foreground="White" FontSize="18" FontWeight="Bold"
                       HorizontalAlignment="Center" VerticalAlignment="Center"/>
          </Border>
          <StackPanel Margin="10,0,0,0" VerticalAlignment="Center">
            <TextBlock x:Name="ProfileName" Text="Local profile" Foreground="#E6EDF3" FontSize="11" FontWeight="Bold"/>
            <TextBlock Text="Gemma Bridge · local" Foreground="#8B949E" FontSize="10"/>
          </StackPanel>
        </DockPanel>
      </Border>
    </Grid>
    <GridSplitter Grid.Column="1" Width="5" Background="#21262D" HorizontalAlignment="Stretch"/>

    <!-- Main chat panel -->
    <Grid Grid.Column="2">
      <Grid.RowDefinitions>
        <RowDefinition Height="42"/>
        <RowDefinition Height="*"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="60"/>
      </Grid.RowDefinitions>

      <!-- Header -->
      <Border Background="#161B22" BorderBrush="#21262D" BorderThickness="0,0,0,1">
        <DockPanel Margin="14,0">
          <Ellipse x:Name="StatusDot" Width="9" Height="9" Fill="#3FB950"
                   VerticalAlignment="Center" Margin="0,0,9,0"/>
          <TextBlock Text="Gemma Bridge" Foreground="#E6EDF3"
                     FontSize="13" FontWeight="Bold" VerticalAlignment="Center"/>
          <TextBlock x:Name="StatusLabel" Text="  ready"
                     Foreground="#8B949E" FontSize="11" VerticalAlignment="Center"/>
        </DockPanel>
      </Border>

      <!-- Chat feed -->
      <ScrollViewer Grid.Row="1" x:Name="FeedScroll"
                    VerticalScrollBarVisibility="Auto" Background="#0D1117">
        <StackPanel x:Name="Feed" Margin="14,8,14,8"/>
      </ScrollViewer>

      <!-- Options panel (multi-select, hidden by default) -->
      <Border Grid.Row="2" x:Name="OptionsPanel" Visibility="Collapsed"
              Background="#161B22" BorderBrush="#30363D" BorderThickness="0,1,0,0"
              Padding="14,10">
        <WrapPanel x:Name="OptionsWrap"/>
      </Border>

      <!-- Slash commands, shown while typing a command -->
      <Border Grid.Row="3" x:Name="CommandPanel" Visibility="Collapsed"
              Background="#161B22" BorderBrush="#30363D" BorderThickness="0,1,0,0"
              Padding="10,6" MaxHeight="240">
        <ScrollViewer VerticalScrollBarVisibility="Auto">
          <StackPanel x:Name="CommandList"/>
        </ScrollViewer>
      </Border>

      <!-- Input bar -->
      <Border Grid.Row="4" Background="#161B22" BorderBrush="#21262D" BorderThickness="0,1,0,0">
        <Grid Margin="10,10">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
            <ColumnDefinition Width="Auto"/>
          </Grid.ColumnDefinitions>
          <TextBox x:Name="InputBox"
                   Background="#0D1117" Foreground="#E6EDF3" CaretBrush="#58A6FF"
                   BorderBrush="#30363D" BorderThickness="1"
                   FontSize="13" Padding="10,6" Height="38" VerticalContentAlignment="Center"
                   ToolTip="Type a message — Enter or Send"/>
          <Button x:Name="SendBtn" Grid.Column="1" Content="  Send  "
                  Background="#238636" Foreground="White" BorderThickness="0"
                  FontSize="13" FontWeight="SemiBold" Height="38"
                  Margin="8,0,0,0" Cursor="Hand"/>
        </Grid>
      </Border>
    </Grid>

    <!-- Splitter -->
    <GridSplitter Grid.Column="3" Width="5" Background="#21262D" HorizontalAlignment="Stretch"/>

    <!-- ═══ RIGHT: Todo + Model Manager ═══ -->
    <Grid Grid.Column="4" Background="#0D1117">
      <Grid.RowDefinitions>
        <RowDefinition Height="42"/>
        <RowDefinition Height="Auto"/>
        <RowDefinition Height="*" MinHeight="60"/>
        <RowDefinition Height="42"/>
        <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <Border Grid.Row="1" Background="#111820" BorderBrush="#21262D" BorderThickness="0,0,0,1" Padding="12,9">
        <StackPanel>
          <TextBlock Text="ACTIVE ROUTE" Foreground="#8B949E" FontSize="10" FontWeight="Bold"/>
          <TextBlock x:Name="ActiveRouteName" Text="Gemma Bridge · ready" Foreground="#E6EDF3"
                     FontSize="12" FontWeight="Bold" Margin="0,5,0,0" TextWrapping="Wrap"/>
          <TextBlock x:Name="ActiveRouteDetail" Text="Waiting for a response" Foreground="#8B949E"
                     FontSize="10" Margin="0,3,0,0" TextWrapping="Wrap"/>
          <TextBlock x:Name="RankerStatus" Text="EmbeddingGemma 2 · rank only" Foreground="#58A6FF"
                     FontSize="10" Margin="0,8,0,0" TextWrapping="Wrap"/>
          <TextBlock x:Name="NeuralStatus" Text="Gemma 3 local · checking" Foreground="#8B949E"
                     FontSize="10" Margin="0,3,0,0" TextWrapping="Wrap"/>
        </StackPanel>
      </Border>

      <!-- TODO header -->
      <Border Grid.Row="0" Background="#161B22" BorderBrush="#21262D" BorderThickness="0,0,0,1">
        <TextBlock Text="📋  TODO" Foreground="#E6EDF3" FontSize="12" FontWeight="Bold"
                   VerticalAlignment="Center" Margin="14,0"/>
      </Border>
      <!-- TODO list -->
      <ScrollViewer Grid.Row="2" VerticalScrollBarVisibility="Auto" Padding="0">
        <StackPanel x:Name="TodoPanel" Margin="8,8,8,8"/>
      </ScrollViewer>

      <!-- MODELS header -->
      <Border Grid.Row="3" Background="#161B22" BorderBrush="#21262D" BorderThickness="0,1,0,1">
        <DockPanel Margin="10,0">
          <TextBlock Text="🧠  LLAMA.CPP" Foreground="#E6EDF3" FontSize="12" FontWeight="Bold"
                     VerticalAlignment="Center"/>
          <Button x:Name="RefreshModelsBtn" Content="⟳" DockPanel.Dock="Right"
                  HorizontalAlignment="Right" Background="#161B22" Foreground="#58A6FF"
                  BorderThickness="0" FontSize="13" Padding="6,1" Cursor="Hand"
                  VerticalAlignment="Center" ToolTip="Refresh models"/>
          <Button x:Name="StartGemmaBtn" Content="Start" DockPanel.Dock="Right"
                  Background="#21262D" Foreground="#3FB950" BorderBrush="#30363D"
                  BorderThickness="1" FontSize="10" Padding="7,3" Margin="0,0,4,0"
                  Cursor="Hand" VerticalAlignment="Center" ToolTip="Start local llama-server.exe via gemma.bat"/>
        </DockPanel>
      </Border>
      <!-- MODEL list -->
      <Border Grid.Row="4" BorderBrush="#21262D" BorderThickness="0,0,0,1" MaxHeight="200">
        <ScrollViewer VerticalScrollBarVisibility="Auto">
          <StackPanel x:Name="ModelPanel" Margin="6,4,6,6"/>
        </ScrollViewer>
      </Border>
    </Grid>
  </Grid>
</Window>
"@

# ── Build window ───────────────────────────────────────────────────────────────
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window    = [System.Windows.Markup.XamlReader]::Load($reader)
$feed      = $window.FindName('Feed')
$scroll    = $window.FindName('FeedScroll')
$inputBox  = $window.FindName('InputBox')
$sendBtn   = $window.FindName('SendBtn')
$statusLbl = $window.FindName('StatusLabel')
$statusDot = $window.FindName('StatusDot')
$optPanel  = $window.FindName('OptionsPanel')
$optWrap   = $window.FindName('OptionsWrap')
$commandPanel = $window.FindName('CommandPanel')
$commandList = $window.FindName('CommandList')
$activeRouteName = $window.FindName('ActiveRouteName')
$activeRouteDetail = $window.FindName('ActiveRouteDetail')
$rankerStatus = $window.FindName('RankerStatus')
$neuralStatus = $window.FindName('NeuralStatus')
$todoPanel        = $window.FindName('TodoPanel')
$modelPanel       = $window.FindName('ModelPanel')
$refreshModelsBtn = $window.FindName('RefreshModelsBtn')
$startGemmaBtn = $window.FindName('StartGemmaBtn')
$historyPanel     = $window.FindName('HistoryPanel')
$newChatBtn       = $window.FindName('NewChatBtn')
$profileName      = $window.FindName('ProfileName')
$profileName.Text = if ($env:USERNAME) { $env:USERNAME } else { 'Local profile' }

$script:BusBase = 'http://127.0.0.1:9880'
$script:BusJob = $null
$script:BusShutdownToken = $null
$script:CurrentSession = $null
$script:TerminalAutoReadOnly = $false

function Add-CommandApproval([string]$command, [bool]$mutating) {
    if (-not $command) { return }
    $card = [System.Windows.Controls.Border]::new()
    $card.Margin = [System.Windows.Thickness]::new(0,6,0,4); $card.Padding = [System.Windows.Thickness]::new(12,8,12,8)
    $card.CornerRadius = [System.Windows.CornerRadius]::new(8)
    $card.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(22,27,34))
    $stack = [System.Windows.Controls.StackPanel]::new()
    $label = [System.Windows.Controls.TextBlock]::new(); $label.Text = "Would you like to execute the command?`n$command"
    $label.Foreground = [System.Windows.Media.Brushes]::White; $label.TextWrapping = 'Wrap'; $stack.Children.Add($label) | Out-Null
    $buttons = [System.Windows.Controls.StackPanel]::new(); $buttons.Orientation = 'Horizontal'; $buttons.Margin = [System.Windows.Thickness]::new(0,8,0,0)
    foreach ($choice in 'YES','NO','AUTO') {
        $button = [System.Windows.Controls.Button]::new(); $button.Content = $choice; $button.Margin = [System.Windows.Thickness]::new(0,0,8,0); $button.Padding = [System.Windows.Thickness]::new(12,4,12,4)
        $button.Tag = @{ Choice=$choice; Command=$command; Mutating=$mutating; Card=$card }
        $button.Add_Click({
            $item = $this.Tag; $item.Card.IsEnabled = $false
            if ($item.Choice -eq 'NO') { $item.Card.Visibility='Collapsed'; Add-ActionMsg 'command declined'; return }
            if ($item.Choice -eq 'AUTO') { $script:TerminalAutoReadOnly=$true }
            if ($item.Mutating -and $item.Choice -ne 'YES') { Add-ActionMsg 'AUTO is limited to read-only commands'; return }
            $item.Card.Visibility='Collapsed'
            Invoke-CLI $item.Command
        }.GetNewClosure())
        $buttons.Children.Add($button) | Out-Null
    }
    $stack.Children.Add($buttons) | Out-Null; $card.Child=$stack; $feed.Children.Add($card) | Out-Null; $scroll.ScrollToBottom()
}

function Test-MicronautBus {
    try {
        $health = Invoke-RestMethod -Uri "$script:BusBase/health" -TimeoutSec 2
        return ($health.schema -eq 'micronaut.bus.health.v1' -and $health.ok)
    } catch { return $false }
}

function Start-MicronautBus {
    if (Test-MicronautBus) { return $true }
    $serverModule = Join-Path $PSScriptRoot 'shell/Server.psm1'
    $script:BusShutdownToken = [guid]::NewGuid().ToString('N')
    $script:BusJob = Start-ThreadJob -ScriptBlock {
        param($module,$port,$token)
        Import-Module $module -Force
        Start-MicronautBusServer -Port $port -ShutdownToken $token
    } -ArgumentList $serverModule,9880,$script:BusShutdownToken
    for ($i = 0; $i -lt 30; $i++) {
        if (Test-MicronautBus) { return $true }
        Start-Sleep -Milliseconds 150
    }
    return $false
}

function Refresh-MicronautHistory {
    $historyPanel.Children.Clear()
    try {
        $sessions = @((Invoke-RestMethod -Uri "$script:BusBase/api/sessions" -TimeoutSec 3).sessions |
            Where-Object { $null -ne $_ })
    }
    catch { return }
    foreach ($session in $sessions) {
        $button = [System.Windows.Controls.Button]::new()
        $button.Content = if ($session.title) { [string]$session.title } else { 'New chat' }
        $button.HorizontalContentAlignment = 'Left'
        $button.Padding = [System.Windows.Thickness]::new(10,7,6,7)
        $button.Margin = [System.Windows.Thickness]::new(0,1,0,1)
        $button.Background = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString(
                $(if ($session.id -eq $script:CurrentSession) { '#263B52' } else { '#161B22' })))
        $button.Foreground = [System.Windows.Media.Brushes]::White
        $button.BorderThickness = [System.Windows.Thickness]::new(0)
        $button.Cursor = [System.Windows.Input.Cursors]::Hand
        $capturedId = [string]$session.id
        $button.Add_Click(({ Open-MicronautHistory $capturedId }).GetNewClosure())
        [void]$historyPanel.Children.Add($button)
    }
}

function Open-MicronautHistory([string]$sessionId) {
    try {
        $history = Invoke-RestMethod -Uri "$script:BusBase/api/history?sessionId=$sessionId" -TimeoutSec 3
        $script:CurrentSession = $sessionId
        $feed.Children.Clear()
        foreach ($message in $history.messages) {
            if ($message.role -eq 'user') { Add-UserMsg ([string]$message.content) }
            else { Add-AiMsg ([string]$message.content) }
        }
        Refresh-MicronautHistory
    } catch { Add-AiMsg "History unavailable: $($_.Exception.Message)" }
}

function New-MicronautChat {
    try {
        $session = Invoke-RestMethod -Uri "$script:BusBase/api/sessions" -Method Post `
            -Body '{}' -ContentType 'application/json' -TimeoutSec 3
        $script:CurrentSession = [string]$session.sessionId
        $feed.Children.Clear()
        Update-ActiveRoute
        Refresh-MicronautHistory
    } catch { Add-AiMsg "Could not create chat: $($_.Exception.Message)" }
}

# ── Status helpers ─────────────────────────────────────────────────────────────
function Set-Status([string]$text, [string]$color = '#8B949E') {
    $statusLbl.Text = "  $text"
    $statusDot.Fill = [System.Windows.Media.SolidColorBrush]::new(
        [System.Windows.Media.ColorConverter]::ConvertFromString($color)
    )
}
function Set-Busy  { Set-Status 'thinking...' '#F0883E' }
function Set-Ready { Set-Status 'ready'        '#3FB950' }

function Update-ActiveRoute([string]$selection = '') {
    switch ($selection) {
        'gemma_neural_local' {
            $activeRouteName.Text = 'Gemma 3 1B · local neural'
            $activeRouteDetail.Text = 'Generated text · unverified model output'
        }
        'verified_literal_greeting' {
            $activeRouteName.Text = 'Key grammar · greeting'
            $activeRouteDetail.Text = 'EmbeddingGemma 2 ranked a validated literal response'
        }
        'verified_control_description' {
            $activeRouteName.Text = 'Key grammar · control'
            $activeRouteDetail.Text = 'EmbeddingGemma 2 ranked a validated description'
        }
        'gemma_mu_no_verified_answer' {
            $activeRouteName.Text = 'GEMMA-µ · vector ranker'
            $activeRouteDetail.Text = 'No verified response operation matched'
        }
        'cfpc_pattern_route' {
            $activeRouteName.Text = 'CFPC-µ · pattern route'
            $activeRouteDetail.Text = 'Intent recognized; answer remains unverified'
        }
        default {
            if ($selection -like 'ARITHMETIC:*') {
                $activeRouteName.Text = 'MathML · local evaluator'
                $activeRouteDetail.Text = 'Deterministic arithmetic response'
            } elseif ($selection) {
                $activeRouteName.Text = 'Gemma Bridge · AIML/vector'
                $activeRouteDetail.Text = "Selection: $selection"
            } else {
                $activeRouteName.Text = 'Gemma Bridge · ready'
                $activeRouteDetail.Text = 'Waiting for a response'
            }
        }
    }
}

function Refresh-ActiveModelStatus {
    $rankerStatus.Text = 'EmbeddingGemma 2 · rank only'
    try {
        $health = Invoke-RestMethod -Uri "$script:BusBase/api/bindings/invoke" -Method Post `
            -Body '{"name":"gemma.neural.health"}' -ContentType 'application/json' -TimeoutSec 3
        $neuralStatus.Text = if ($health.result.available) {
            'Gemma 3 1B · local server ready (/gemma)'
        } else { 'Gemma 3 1B · offline (start gemma.bat)' }
    } catch { $neuralStatus.Text = 'Gemma 3 1B · status unavailable' }
}

# ── Model manager state ────────────────────────────────────────────────────────
$script:ShardsHome       = if ($env:SHARDS_HOME) { $env:SHARDS_HOME } `
                           else { Join-Path $HOME '.shards' }
$script:GemmaServerExe = 'C:\Users\canna\.llama-win-cpu-x64\llama-server.exe'
$script:GemmaModelFile = 'C:\Users\canna\.models\gemma-3-1B-it-QAT-Q4_0.gguf'

# SW-1 swarm port map: label -> port
$script:SwarmPorts = [ordered]@{
    'PM-1'  = 8000
    'BR-1'  = 3172
    'VM-1'  = 3173
    'OV-1'  = 3174
    'KX-1'  = 3175
    'FG-1'  = 3176
    'DX-1'  = 3177
}

function Test-TcpPort([int]$port) {
    try {
        $tcp = [System.Net.Sockets.TcpClient]::new()
        $ar  = $tcp.BeginConnect('127.0.0.1', $port, $null, $null)
        $ok  = $ar.AsyncWaitHandle.WaitOne(300, $false)
        if ($ok -and $tcp.Connected) { $tcp.Close(); return $true }
        $tcp.Close(); return $false
    } catch { return $false }
}

function Populate-Models {
    $modelPanel.Children.Clear()
    $shardsDir    = $PSScriptRoot
    $modelsDir    = Join-Path $shardsDir 'models'
    $superDir     = Join-Path $shardsDir 'supernaut'

    # ── Section header helper ──────────────────────────────────────────────────
    function Add-SectionHeader([string]$title) {
        $hdr = [System.Windows.Controls.TextBlock]::new()
        $hdr.Text      = $title
        $hdr.FontSize  = 8
        $hdr.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString('#484F58'))
        $hdr.Margin    = [System.Windows.Thickness]::new(8, 6, 4, 2)
        $modelPanel.Children.Add($hdr) | Out-Null
    }

    # backend label helper
    function Get-BackendLabel([string]$name) {
        if ($name -match '\.s7$')   { return '🧠' }
        if ($name -match '\.gguf$') { return '⚡' }
        if ($name -match 'validator|verif') { return '✅' }
        if ($name -match '\.zst$')  { return '📦' }
        if ($name -match '\.bin$')  { return '💾' }
        return '  '
    }

    function Add-ModelRow([string]$displayName, [bool]$loaded = $false, [string]$badge = '') {
        $row = [System.Windows.Controls.Border]::new()
        $row.CornerRadius = [System.Windows.CornerRadius]::new(4)
        $row.Margin  = [System.Windows.Thickness]::new(0, 2, 0, 2)
        $row.Padding = [System.Windows.Thickness]::new(8, 5, 8, 5)
        $rowBgColor = if ($loaded) { '#1F3A2A' } else { '#161B22' }
        $row.Background = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString($rowBgColor))
        $dp = [System.Windows.Controls.DockPanel]::new()
        $dot = [System.Windows.Controls.TextBlock]::new()
        $dot.Text     = if ($loaded) { "●  " } else { "○  " }
        $dot.FontSize = 9
        $dot.Margin   = [System.Windows.Thickness]::new(0, 0, 4, 0)
        $dot.VerticalAlignment = 'Center'
        $dotFgColor = if ($loaded) { '#3FB950' } else { '#8B949E' }
        $dot.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString($dotFgColor))
        $lbl = [System.Windows.Controls.TextBlock]::new()
        $lbl.Text         = if ($badge) { "$badge $displayName" } else { $displayName }
        $lbl.FontSize     = 10
        $lbl.TextTrimming = 'CharacterEllipsis'
        $lbl.VerticalAlignment = 'Center'
        $lblFgColor = if ($loaded) { '#E6EDF3' } else { '#8B949E' }
        $lbl.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString($lblFgColor))
        $dp.Children.Add($dot) | Out-Null
        $dp.Children.Add($lbl) | Out-Null
        $row.Child = $dp
        $modelPanel.Children.Add($row) | Out-Null
    }

    function Add-Separator {
        $sep = [System.Windows.Controls.Separator]::new()
        $sep.Margin     = [System.Windows.Thickness]::new(4, 3, 4, 3)
        $sep.Background = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString('#21262D'))
        $modelPanel.Children.Add($sep) | Out-Null
    }

    # ── Section 1: SW-1 Swarm status (live TCP checks) ────────────────────────
    Add-SectionHeader "SW-1 SWARM"
    foreach ($entry in $script:SwarmPorts.GetEnumerator()) {
        $svcName = $entry.Key
        $port    = $entry.Value
        $alive   = Test-TcpPort $port
        $stRow = [System.Windows.Controls.Border]::new()
        $stRow.Margin  = [System.Windows.Thickness]::new(0, 1, 0, 1)
        $stRow.Padding = [System.Windows.Thickness]::new(8, 2, 8, 2)
        $stDp  = [System.Windows.Controls.DockPanel]::new()
        $stDot = [System.Windows.Controls.TextBlock]::new()
        $stDot.Text     = "● "
        $stDot.FontSize = 8
        $stDot.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString(
                ($alive ? '#3FB950' : '#484F58')))
        $stDot.VerticalAlignment = 'Center'
        $stLbl = [System.Windows.Controls.TextBlock]::new()
        $stLbl.Text     = "$svcName :$port"
        $stLbl.FontSize = 9
        $stLbl.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString(
                ($alive ? '#8B949E' : '#484F58')))
        $stLbl.VerticalAlignment = 'Center'
        $stDp.Children.Add($stDot) | Out-Null
        $stDp.Children.Add($stLbl) | Out-Null
        $stRow.Child = $stDp
        $modelPanel.Children.Add($stRow) | Out-Null
    }
    Add-Separator

    # ── Section 2: local llama.cpp server and configured Gemma model ─────────
    Add-SectionHeader "LOCAL LLAMA.CPP SERVER"
    $serverReady = $false
    try { $serverReady = (Invoke-RestMethod -Uri 'http://127.0.0.1:8091/health' -TimeoutSec 2).status -eq 'ok' } catch { }
    Add-ModelRow -displayName "llama-server.exe :8091 $(if ($serverReady) { 'ready' } else { 'offline' })" -loaded $serverReady -badge '⚡'
    Add-ModelRow -displayName (Split-Path $script:GemmaModelFile -Leaf) -loaded $serverReady -badge '🧠'
    if (-not (Test-Path -LiteralPath $script:GemmaServerExe -PathType Leaf)) {
        Add-ModelRow -displayName 'llama-server.exe missing' -badge '!'
    }
    Add-Separator

    # ── CSS-GEMM WebGL2 driver contract and SDK artifacts ─────────────────────
    Add-SectionHeader 'CSS-GEMM · WEBGL2 DRIVER'
    try {
        $cssGemm = Invoke-RestMethod -Uri "$script:BusBase/api/bindings/invoke" -Method Post `
            -Body '{"name":"css-gemm.driver.status"}' -ContentType 'application/json' -TimeoutSec 3
        $driver = $cssGemm.result
        Add-ModelRow -displayName "CSS-ML WebGL2 executor · $(if ($driver.webgl2_executor_present) { 'installed' } else { 'missing' })" `
            -loaded $false -badge '◇'
        Add-ModelRow -displayName "WebView2 SDK · $(if ($driver.webview2_sdk_present) { 'installed' } else { 'missing' })" `
            -loaded $false -badge '▣'
        Add-ModelRow -displayName $script:WebView2Status -loaded $script:WebView2Available -badge '▣'
        Add-ModelRow -displayName 'WebGL2 GPU · probe required in browser' -loaded $false -badge '…'
        Add-ModelRow -displayName "JS model trainer · $(if ($driver.trainer_entrypoint_present) { 'declared' } else { 'missing' })" `
            -loaded $false -badge 'µ'
        Add-ModelRow -displayName 'Gradients / AdamW · CPU reference' -loaded $true -badge '∇'
    } catch {
        Add-ModelRow -displayName 'CSS-GEMM driver status unavailable' -loaded $false -badge '!'
    }
    Add-Separator

    # ── Section 3: compiled daemon tools and OpenCL kernels ──────────────────
    $binDir = Join-Path $PSScriptRoot 'bin'
    Add-SectionHeader 'MICRONAUT BIN · ON DISK'
    $binArtifacts = @(
        @{ Name = 'eliza-µ.exe'; Role = 'AIML/vector daemon'; Badge = 'µ' },
        @{ Name = 'chen_vector_plan_cli.exe'; Role = 'Chen vector plans'; Badge = '⌁' },
        @{ Name = 'ccc4_infer.exe'; Role = 'CCC4 inference'; Badge = '→' },
        @{ Name = 'ccc4_train.exe'; Role = 'CCC4 training'; Badge = '↻' },
        @{ Name = 'attention.cl'; Role = 'OpenCL attention'; Badge = '◇' },
        @{ Name = 'gradients.cl'; Role = 'OpenCL gradients'; Badge = '◇' },
        @{ Name = 'micronaut.cl'; Role = 'OpenCL micronaut'; Badge = '◇' },
        @{ Name = 'vector_lane.cl'; Role = 'OpenCL vector lane'; Badge = '◇' }
    )
    foreach ($artifact in $binArtifacts) {
        $present = Test-Path -LiteralPath (Join-Path $binDir $artifact.Name) -PathType Leaf
        $state = if ($present) { 'present' } else { 'missing' }
        Add-ModelRow -displayName "$($artifact.Name) · $($artifact.Role) · $state" `
            -loaded $present -badge $artifact.Badge
    }
    Add-Separator

    # ── Section 4: Local model files ──────────────────────────────────────────
    $files = @()
    # tiny.x from SHARDS_HOME
    $tinyX = Join-Path $script:ShardsHome 'tiny.x'
    if (Test-Path $tinyX) {
        $files += [System.IO.FileInfo]::new($tinyX)
    }
    if (Test-Path $modelsDir) {
        $files += Get-ChildItem $modelsDir -File |
                  Where-Object { $_.Extension -in @('.gguf', '.zst', '.bin') }
    }
    $files += Get-ChildItem $shardsDir -File |
              Where-Object { $_.Extension -eq '.s7' }
    if (Test-Path $superDir) {
        $files += Get-ChildItem $superDir -File |
                  Where-Object { $_.Extension -eq '.s7' }
    }
    $files = $files | Sort-Object Name

    if ($files.Count -gt 0) {
        Add-SectionHeader "LOCAL MODELS"
        foreach ($f in $files) {
            $name  = $f.Name
            $badge = Get-BackendLabel $name
            Add-ModelRow -displayName $name -loaded $false -badge $badge
        }
    }
}

$refreshModelsBtn.Add_Click({ Populate-Models; Refresh-ActiveModelStatus })
$startGemmaBtn.Add_Click({
    if (Test-TcpPort 8091) { Populate-Models; Refresh-ActiveModelStatus; return }
    $launcher = Join-Path $PSScriptRoot 'gemma.bat'
    if (-not (Test-Path -LiteralPath $launcher -PathType Leaf)) {
        Add-AiMsg 'gemma.bat is missing.'; return
    }
    Start-Process -FilePath $env:ComSpec -ArgumentList @('/c',"`"$launcher`"") `
        -WorkingDirectory $PSScriptRoot -WindowStyle Hidden | Out-Null
    $neuralStatus.Text = 'Gemma 3 1B · starting llama-server.exe'
    Add-ActionMsg 'Starting local Gemma 3 server on port 8091'
    $attempts = 0
    $poll = [System.Windows.Threading.DispatcherTimer]::new()
    $poll.Interval = [TimeSpan]::FromSeconds(1)
    $poll.Add_Tick(({
        $attempts++
        if ((Test-TcpPort 8091) -or $attempts -ge 30) {
            $poll.Stop()
            Populate-Models
            Refresh-ActiveModelStatus
        }
    }).GetNewClosure())
    $poll.Start()
})

# ── Chat bubble helpers ────────────────────────────────────────────────────────
function New-Bubble([string]$text, [string]$bgHex, [string]$fgHex = '#E6EDF3', [bool]$right = $false) {
    $br = [System.Windows.Controls.Border]::new()
    $br.CornerRadius = [System.Windows.CornerRadius]::new(10)
    $br.Margin    = [System.Windows.Thickness]::new(0, 4, 0, 0)
    $br.Padding   = [System.Windows.Thickness]::new(12, 8, 12, 8)
    $br.MaxWidth  = 580
    $br.Background = [System.Windows.Media.SolidColorBrush]::new(
        [System.Windows.Media.ColorConverter]::ConvertFromString($bgHex))
    $tb = [System.Windows.Controls.TextBlock]::new()
    $tb.Text        = $text
    $tb.Foreground  = [System.Windows.Media.SolidColorBrush]::new(
        [System.Windows.Media.ColorConverter]::ConvertFromString($fgHex))
    $tb.FontSize     = 13
    $tb.TextWrapping = 'Wrap'
    $br.Child = $tb
    $dp = [System.Windows.Controls.DockPanel]::new()
    $dp.HorizontalAlignment = if ($right) { 'Right' } else { 'Left' }
    $dp.Children.Add($br) | Out-Null
    return $dp
}

function Add-UserMsg([string]$text) {
    $feed.Children.Add((New-Bubble $text '#1F6FEB' '#FFFFFF' $true)) | Out-Null
    $scroll.ScrollToBottom()
}

function Add-AiMsg([string]$text) {
    $match = [regex]::Match($text, '(?s)^\s*(?:```(?<lang>[\w.+-]*)\s*\r?\n(?<code>.*?)\r?\n```|<code(?:\s+language="(?<taglang>[\w.+-]+)")?>(?<tagcode>.*?)</code>)\s*$')
    if ($match.Success) {
        $codeText = if ($match.Groups['code'].Success) { $match.Groups['code'].Value } else { [System.Net.WebUtility]::HtmlDecode($match.Groups['tagcode'].Value) }
        $language = if ($match.Groups['lang'].Success) { $match.Groups['lang'].Value } elseif ($match.Groups['taglang'].Success) { $match.Groups['taglang'].Value } else { 'code' }
        $container = [System.Windows.Controls.Border]::new()
        $container.CornerRadius = [System.Windows.CornerRadius]::new(8)
        $container.Margin = [System.Windows.Thickness]::new(0,4,0,0)
        $container.MaxWidth = 700
        $container.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(13,17,23))
        $container.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(48,54,61))
        $container.BorderThickness = [System.Windows.Thickness]::new(1)
        $layout = [System.Windows.Controls.DockPanel]::new()
        $toolbar = [System.Windows.Controls.StackPanel]::new()
        $toolbar.Orientation = 'Horizontal'; $toolbar.HorizontalAlignment = 'Right'
        foreach ($action in @('Copy','Download')) {
            $button = [System.Windows.Controls.Button]::new()
            $button.Content = $action; $button.Margin = [System.Windows.Thickness]::new(0,0,6,0)
            $button.Padding = [System.Windows.Thickness]::new(8,3,8,3)
            $button.Foreground = [System.Windows.Media.Brushes]::White
            $button.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(33,38,45))
            $button.Tag = $codeText
            if ($action -eq 'Copy') { $button.Add_Click({ [System.Windows.Clipboard]::SetText([string]$this.Tag) }) }
            else {
                $button.Tag = @{ Text = $codeText; Language = $language }
                $button.Add_Click({
                    $data = $this.Tag
                    $dialog = [Microsoft.Win32.SaveFileDialog]::new()
                    $ext = switch -Regex ($data.Language) { '^cpp$|^c\+\+$' { '.cpp'; break } '^typescript$|^ts$' { '.ts'; break } default { '.txt' } }
                    $dialog.FileName = "generated$ext"
                    if ($dialog.ShowDialog()) { [System.IO.File]::WriteAllText($dialog.FileName,[string]$data.Text,[System.Text.UTF8Encoding]::new($false)) }
                })
            }
            $toolbar.Children.Add($button) | Out-Null
        }
        [System.Windows.Controls.DockPanel]::SetDock($toolbar,'Top')
        $layout.Children.Add($toolbar) | Out-Null
        $editor = [System.Windows.Controls.TextBox]::new()
        $editor.Text = $codeText; $editor.IsReadOnly = $true; $editor.AcceptsReturn = $true
        $editor.TextWrapping = 'NoWrap'; $editor.FontFamily = 'Consolas'; $editor.FontSize = 12
        $editor.Padding = [System.Windows.Thickness]::new(10); $editor.MinHeight = 70
        $editor.Foreground = [System.Windows.Media.Brushes]::White
        $editor.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(13,17,23))
        $layout.Children.Add($editor) | Out-Null
        $container.Child = $layout
        $feed.Children.Add($container) | Out-Null
    } else { $feed.Children.Add((New-Bubble $text '#21262D' '#E6EDF3' $false)) | Out-Null }
    $scroll.ScrollToBottom()
}

function Add-TopicInfoCard([string]$answerText,[string]$headingText,[string]$imageName,[string]$imageTooltip,[string]$buttonText,[string]$appName,[string]$appPath = '',[switch]$EmbedInteractive) {
    $card = [System.Windows.Controls.Border]::new()
    $card.CornerRadius = [System.Windows.CornerRadius]::new(12)
    $card.Margin = [System.Windows.Thickness]::new(0,4,0,0)
    $card.Padding = [System.Windows.Thickness]::new(12)
    $card.MaxWidth = 760
    $card.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(16,28,45))
    $card.BorderBrush = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(41,66,93))
    $card.BorderThickness = [System.Windows.Thickness]::new(1)
    $stack = [System.Windows.Controls.StackPanel]::new()
    $heading = [System.Windows.Controls.TextBlock]::new()
    $heading.Text = $headingText
    $heading.Foreground = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(125,226,208))
    $heading.FontSize = 10; $heading.FontWeight = 'Bold'; $heading.Margin = [System.Windows.Thickness]::new(0,0,0,8)
    $stack.Children.Add($heading) | Out-Null
    $answer = [System.Windows.Controls.TextBlock]::new()
    $answer.Text = $answerText; $answer.TextWrapping = 'Wrap'; $answer.FontSize = 13
    $answer.Foreground = [System.Windows.Media.Brushes]::White; $answer.Margin = [System.Windows.Thickness]::new(0,0,0,10)
    $stack.Children.Add($answer) | Out-Null

    $embedded = $false
    if ($EmbedInteractive -and $script:WebView2Available) {
        try {
            $cssRoot = Join-Path $PSScriptRoot '.CSS-C'
            $webView = [Microsoft.Web.WebView2.Wpf.WebView2]::new()
            $webView.Width = 720; $webView.Height = 430
            $webView.HorizontalAlignment = 'Left'
            $webView.Margin = [System.Windows.Thickness]::new(0,0,0,8)
            $creation = [Microsoft.Web.WebView2.Wpf.CoreWebView2CreationProperties]::new()
            $creation.UserDataFolder = Join-Path $env:LOCALAPPDATA 'Micronaut\WebView2'
            $webView.CreationProperties = $creation
            $stack.Children.Add($webView) | Out-Null
            $webView.Add_Loaded(({
                $control = $this
                $target = 'https://cssml.local/demo/gsnr-universe.html#css-gemm-card'
                $task = $control.EnsureCoreWebView2Async($null)
                $timer = [System.Windows.Threading.DispatcherTimer]::new()
                $timer.Interval = [TimeSpan]::FromMilliseconds(100)
                $timer.Add_Tick(({
                    if ($task.IsCompleted) {
                        $timer.Stop()
                        if ($task.IsFaulted) {
                            Add-ActionMsg "WebView2 initialization failed: $($task.Exception.GetBaseException().Message)"
                            return
                        }
                        try {
                            $control.CoreWebView2.SetVirtualHostNameToFolderMapping(
                                'cssml.local',
                                $cssRoot,
                                [Microsoft.Web.WebView2.Core.CoreWebView2HostResourceAccessKind]::Allow
                            )
                            $control.CoreWebView2.add_WebMessageReceived({
                                param($sender, $eventArgs)
                                try {
                                    $payload = [string]$eventArgs.TryGetWebMessageAsString()
                                    if ($payload.Length -le 2048) {
                                        $message = $payload | ConvertFrom-Json -ErrorAction Stop
                                        if ($message.source -eq 'css-gemm' -and $message.type -in 'gemm.completed','trainer.completed') {
                                            $summary = if ($message.type -eq 'trainer.completed') {
                                                "WebView2 trainer · $($message.steps) step(s) · loss $($message.loss) · $($message.renderer)"
                                            } else {
                                                "WebView2 GEMM · max error $($message.maxError) · $($message.renderer)"
                                            }
                                            Add-ActionMsg $summary
                                        }
                                    }
                                } catch { }
                            })
                            $control.CoreWebView2.Navigate($target)
                        } catch {
                            Add-ActionMsg "WebView2 page load failed: $($_.Exception.Message)"
                        }
                    }
                }).GetNewClosure())
                $timer.Start()
            }).GetNewClosure())
            $embedded = $true
        } catch {
            Add-ActionMsg "WebView2 card unavailable: $($_.Exception.Message)"
        }
    }

    $imagePath = Join-Path $PSScriptRoot ("data\apps\{0}.png" -f $imageName)
    if (-not (Test-Path -LiteralPath $imagePath -PathType Leaf)) { $imagePath = Join-Path $PSScriptRoot ("data\apps\{0}.svg" -f $imageName) }
    if (-not $embedded -and (Test-Path -LiteralPath $imagePath -PathType Leaf)) {
        try {
            if ([IO.Path]::GetExtension($imagePath) -ieq '.svg') {
                $image = [System.Windows.Controls.WebBrowser]::new()
                $image.Width = 720; $image.Height = 425; $image.HorizontalAlignment = 'Left'
                $image.Navigate([Uri]::new($imagePath))
            } else {
                $bitmap = [System.Windows.Media.Imaging.BitmapImage]::new()
                $bitmap.BeginInit(); $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
                $bitmap.UriSource = [Uri]::new($imagePath); $bitmap.EndInit(); $bitmap.Freeze()
                $image = [System.Windows.Controls.Image]::new()
                $image.Source = $bitmap; $image.Stretch = [System.Windows.Media.Stretch]::Uniform
                $image.MaxWidth = 720; $image.MaxHeight = 450; $image.HorizontalAlignment = 'Left'
                $image.ToolTip = $imageTooltip
            }
            $stack.Children.Add($image) | Out-Null
        } catch { }
    }
    $open = [System.Windows.Controls.Button]::new()
    $open.Content = $buttonText; $open.Margin = [System.Windows.Thickness]::new(0,9,0,0)
    $open.Padding = [System.Windows.Thickness]::new(10,5,10,5); $open.HorizontalAlignment = 'Left'
    $open.Foreground = [System.Windows.Media.Brushes]::White
    $open.Background = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(35,134,54))
    $open.Tag = if ($appPath) { $appPath } else { Join-Path $PSScriptRoot ("data\apps\{0}.html" -f $appName) }
    $open.Add_Click({
        $target = [string]$this.Tag
        if ($target -match '^https?://') { Start-Process -FilePath $target }
        elseif (Test-Path -LiteralPath $target -PathType Leaf) { Start-Process -FilePath $target }
    })
    $stack.Children.Add($open) | Out-Null
    $card.Child = $stack
    $feed.Children.Add($card) | Out-Null
    $scroll.ScrollToBottom()
}

function Add-SaturnSystemCard([string]$answerText) {
    Add-TopicInfoCard $answerText 'SATURN SYSTEM · ANSWER + INFOGRAPHIC' 'saturn-system-infographic' 'Saturn, selected moons, and atmosphere types; orbital scale is illustrative.' 'Open interactive Saturn explorer' 'saturn-system-explorer'
}

function Add-KuhulInfoCard([string]$answerText) {
    Add-TopicInfoCard $answerText 'KUHUL · ANSWER + INFOGRAPHIC' 'kuhul-infographic' 'KUHUL phases and the separate host admission boundary.' 'Open KUHUL runtime explorer' 'kuhul-explorer'
}

function Add-CssGemmInfoCard([string]$answerText) {
    Add-TopicInfoCard $answerText 'CSS-GEMM · GPU ANSWER + INFOGRAPHIC' 'css-gemm-infographic' `
        'CSS-GEMM tensor flow: WebGL2 forward pass with CPU gradient and AdamW authority.' `
        'Open interactive CSS-GEMM demo' 'gsnr-universe' 'http://127.0.0.1:9880/css-gemm/demo' -EmbedInteractive
}

function Add-ActionMsg([string]$text) {
    $tb = [System.Windows.Controls.TextBlock]::new()
    $tb.Text       = "  ⚡ $text"
    $tb.Foreground = [System.Windows.Media.SolidColorBrush]::new(
        [System.Windows.Media.ColorConverter]::ConvertFromString('#58A6FF'))
    $tb.FontSize = 11
    $tb.Margin   = [System.Windows.Thickness]::new(4, 6, 0, 2)
    $feed.Children.Add($tb) | Out-Null
    $scroll.ScrollToBottom()
}

# ── Multi-select options ───────────────────────────────────────────────────────
function Show-Options([string[]]$choices) {
    $optWrap.Children.Clear()
    foreach ($c in $choices) {
        $btn = [System.Windows.Controls.Button]::new()
        $btn.Content          = $c
        $btn.Background       = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(33,38,45))
        $btn.Foreground       = [System.Windows.Media.Brushes]::White
        $btn.BorderBrush      = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(48,54,61))
        $btn.BorderThickness  = [System.Windows.Thickness]::new(1)
        $btn.Margin           = [System.Windows.Thickness]::new(0,0,8,4)
        $btn.Padding          = [System.Windows.Thickness]::new(14,6,14,6)
        $btn.Cursor           = [System.Windows.Input.Cursors]::Hand
        $captured = $c
        $btn.Add_Click({
            $optPanel.Visibility = 'Collapsed'
            switch ($captured) {
                'Run stats'            { Invoke-CLI 'stats' }
                'Ingest shards folder'  { Start-FullIngest }
                'Ingest real data'      { Start-RealDataIngest }
                'Train structural MoE'  { Start-MoETraining }
                'Show weights path'     { Add-AiMsg "Weights: ..\models\qwen2-0_5b-instruct-q8_0.gguf" }
                'Help'                  { Invoke-CLI 'help' }
                default                 { Submit-Input $captured }
            }
        })
        $optWrap.Children.Add($btn) | Out-Null
    }
    $optPanel.Visibility = 'Visible'
}

# ── Todo panel ─────────────────────────────────────────────────────────────────
$script:TodosFile = Join-Path $PSScriptRoot 'micronaut-todos.json'
$script:Todos     = [System.Collections.Generic.List[hashtable]]::new()

function Save-Todos {
    $arr = $script:Todos | ForEach-Object { [ordered]@{ text = $_.text; status = $_.status } }
    $arr | ConvertTo-Json -Depth 3 | Set-Content -Path $script:TodosFile -Encoding UTF8
}

function Load-Todos {
    if (-not (Test-Path $script:TodosFile)) { return }
    try {
        $raw = Get-Content $script:TodosFile -Raw | ConvertFrom-Json
        $script:Todos.Clear()
        foreach ($item in $raw) {
            $script:Todos.Add(@{ text = $item.text; status = $item.status })
        }
    } catch { <# corrupt file — ignore, start fresh #> }
}

function New-TodoCard([string]$text, [string]$status) {
    $borderColor = switch ($status) {
        'active' { [System.Windows.Media.Color]::FromRgb(0,220,120)  }
        'done'   { [System.Windows.Media.Color]::FromRgb(48,54,61)   }
        default  { [System.Windows.Media.Color]::FromRgb(56,68,77)   }
    }
    $brush = [System.Windows.Media.SolidColorBrush]::new($borderColor)

    if ($status -eq 'active') {
        $anim = [System.Windows.Media.Animation.ColorAnimation]::new()
        $anim.From            = [System.Windows.Media.Color]::FromRgb(0,255,140)
        $anim.To              = [System.Windows.Media.Color]::FromRgb(0,70,40)
        $anim.Duration        = [System.Windows.Duration]::new([TimeSpan]::FromSeconds(0.85))
        $anim.AutoReverse     = $true
        $anim.RepeatBehavior  = [System.Windows.Media.Animation.RepeatBehavior]::Forever
        $brush.BeginAnimation([System.Windows.Media.SolidColorBrush]::ColorProperty, $anim)
    }

    $border = [System.Windows.Controls.Border]::new()
    $border.CornerRadius    = [System.Windows.CornerRadius]::new(6)
    $border.Margin          = [System.Windows.Thickness]::new(0,0,0,6)
    $border.Padding         = [System.Windows.Thickness]::new(10,8,10,8)
    $border.BorderThickness = [System.Windows.Thickness]::new(1)
    $border.BorderBrush     = $brush
    $border.Background      = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(22,27,34))

    $sp = [System.Windows.Controls.StackPanel]::new()

    if ($status -eq 'active') {
        $lbl = [System.Windows.Controls.TextBlock]::new()
        $lbl.Text       = '▶  ACTIVE'
        $lbl.FontSize   = 9
        $lbl.FontWeight = 'Bold'
        $lbl.Foreground = [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(0,220,120))
        $lbl.Margin     = [System.Windows.Thickness]::new(0,0,0,4)
        $sp.Children.Add($lbl) | Out-Null
    }

    $tb = [System.Windows.Controls.TextBlock]::new()
    $tb.Text = switch ($status) {
        'done'    { "✓  $text" }
        'active'  { $text }
        default   { "→  $text" }
    }
    $tb.Foreground  = if ($status -eq 'done') {
        [System.Windows.Media.SolidColorBrush]::new([System.Windows.Media.Color]::FromRgb(80,92,104))
    } else { [System.Windows.Media.Brushes]::White }
    $tb.FontSize    = 12
    $tb.TextWrapping = 'Wrap'
    $sp.Children.Add($tb) | Out-Null

    $border.Child = $sp
    return $border
}

function Refresh-Todos {
    $todoPanel.Children.Clear()
    foreach ($g in @('active','next','done')) {
        foreach ($t in ($script:Todos | Where-Object { $_.status -eq $g })) {
            $todoPanel.Children.Add((New-TodoCard $t.text $t.status)) | Out-Null
        }
    }
}

function Add-Todo([string]$text, [string]$status = 'next') {
    $script:Todos.Add(@{ text = $text; status = $status })
    Refresh-Todos
}

function Set-ActiveTodo([int]$index) {
    for ($i = 0; $i -lt $script:Todos.Count; $i++) {
        if ($script:Todos[$i].status -eq 'active') {
            $script:Todos[$i] = @{ text = $script:Todos[$i].text; status = 'done' }
        }
    }
    if ($index -ge 0 -and $index -lt $script:Todos.Count) {
        $script:Todos[$index] = @{ text = $script:Todos[$index].text; status = 'active' }
    }
    Refresh-Todos
}

# ── Background CLI runner (Start-ThreadJob + DispatcherTimer) ──────────────────
# mode "args" : micronaut.exe <cmd> <args>   (query/train/ingest-jsonl/help/call)
# mode "pipe" : echo "cmd\nexit" | micronaut.exe  (stats/save/load/weight)
function Start-CliTask {
    param([string]$cliArgs, [int]$timeoutMs = 30000, [scriptblock]$onResult,
          [string]$mode = 'args')
    $exe = $CliPath
    $job = Start-ThreadJob -ScriptBlock {
        param($exe, $ca, $to, $m)
        if (-not (Test-Path $exe)) { return "[error] CLI not found: $exe" }
        try {
            $psi = [System.Diagnostics.ProcessStartInfo]::new()
            $psi.FileName               = $exe
            $psi.RedirectStandardOutput = $true
            $psi.RedirectStandardError  = $true
            $psi.UseShellExecute        = $false
            $psi.CreateNoWindow         = $true
            $psi.EnvironmentVariables['MICRONAUT_HOME'] = 'C:\Users\canna\.micronauts\models\micronauts'

            if ($m -eq 'pipe') {
                # K-shell stdin pipe: send command + exit, filter prompt lines
                $psi.RedirectStandardInput = $true
                $psi.Arguments            = ''
            } else {
                $psi.Arguments = $ca
            }

            $p = [System.Diagnostics.Process]::Start($psi)
            if ($m -eq 'pipe') {
                $p.StandardInput.WriteLine($ca)
                $p.StandardInput.WriteLine('exit')
                $p.StandardInput.Close()
            }

            $outTask = $p.StandardOutput.ReadToEndAsync()
            $errTask = $p.StandardError.ReadToEndAsync()
            $p.WaitForExit($to) | Out-Null
            if (-not $p.HasExited) { try { $p.Kill() } catch {} }

            $out = $outTask.Result
            $err = $errTask.Result

            # Strip K-shell prompt lines and banner from pipe output
            if ($m -eq 'pipe') {
                $out = ($out -split "`n" |
                    Where-Object { $_ -notmatch '^ksh>' -and
                                   $_ -notmatch '^micronaut-cli' -and
                                   $_ -notmatch "^home:" -and
                                   $_ -notmatch "^type 'help'" }) -join "`n"
            }

            if ($out.Trim()) { $out.Trim() }
            elseif ($err.Trim()) { "[stderr] $($err.Trim())" }
            else { '(no response)' }
        } catch { "[exception] $_" }
    } -ArgumentList $exe, $cliArgs, $timeoutMs, $mode

    $tmr = [System.Windows.Threading.DispatcherTimer]::new()
    $tmr.Interval = [TimeSpan]::FromMilliseconds(150)
    $tmr.Add_Tick(({
        if ($job.State -in 'Completed','Failed','Stopped') {
            $tmr.Stop()
            $result = (Receive-Job $job -ErrorAction SilentlyContinue) -join "`n"
            Remove-Job $job -Force
            & $onResult $result.Trim()
        }
    }).GetNewClosure())
    $tmr.Start()
}

# ── CLI integration ────────────────────────────────────────────────────────────

function Send-ToAI([string]$text, [string]$responseMode = '') {
    if ([string]::IsNullOrWhiteSpace($text)) { return }
    if (-not (Test-MicronautBus)) {
        Add-AiMsg 'Local Gemma bus is unavailable.'
        return
    }
    if (-not $script:CurrentSession) { New-MicronautChat }
    if (-not $script:CurrentSession) { return }
    Add-UserMsg $text
    Set-Busy
    $inputBox.Text = ''
    $optPanel.Visibility = 'Collapsed'
    $bodyData = @{ prompt = $text; sessionId = $script:CurrentSession }
    if ($responseMode) { $bodyData.responseMode = $responseMode }
    $body = $bodyData | ConvertTo-Json -Compress
    $job = Start-ThreadJob -ScriptBlock {
        param($uri,$json)
        try {
            Invoke-RestMethod -Uri $uri -Method Post -Body $json `
                -ContentType 'application/json; charset=utf-8' -TimeoutSec 180 -ErrorAction Stop
        } catch {
            $detail = $_.ErrorDetails.Message
            if (-not $detail -and $_.Exception.Response) {
                try {
                    $responseStream = $_.Exception.Response.GetResponseStream()
                    if ($responseStream) {
                        $reader = [IO.StreamReader]::new($responseStream)
                        try { $detail = $reader.ReadToEnd() } finally { $reader.Dispose() }
                    }
                } catch { }
            }
            if ($detail) {
                try {
                    $payload = $detail | ConvertFrom-Json -ErrorAction Stop
                    if ($payload.message) { $detail = [string]$payload.message }
                } catch { }
            }
            $message = if ($detail) { "$($_.Exception.Message): $detail" } else { $_.Exception.Message }
            [pscustomobject]@{ error = $message }
        }
    } -ArgumentList "$script:BusBase/api/chat",$body
    $timer = [System.Windows.Threading.DispatcherTimer]::new()
    $timer.Interval = [TimeSpan]::FromMilliseconds(200)
    $timer.Add_Tick(({
        if ($job.State -in 'Completed','Failed','Stopped') {
            $timer.Stop()
            $answer = Receive-Job $job -Wait -ErrorAction SilentlyContinue | Select-Object -Last 1
            Remove-Job $job -Force
            if ($answer -and $answer.text) {
                if ($text -match '(?i)\bSaturn\b') { Add-SaturnSystemCard ([string]$answer.text) }
                elseif ($text -match "(?i)\bK['’]?\s*-?\s*UHUL\b|\bKuhul\b") { Add-KuhulInfoCard ([string]$answer.text) }
                elseif ($text -match '(?i)CSS[- ]?GEMM|WebGL2|GPU tensor') { Add-CssGemmInfoCard ([string]$answer.text) }
                else { Add-AiMsg ([string]$answer.text) }
                if ($answer.trace -and $answer.trace.selection) {
                    Update-ActiveRoute ([string]$answer.trace.selection)
                    if ($answer.trace.selection -eq 'gemma_neural_local') {
                        Add-ActionMsg 'via local Gemma (unverified model output)'
                    } else {
                        Add-ActionMsg "via $($answer.trace.selection)"
                    }
                }
            } else {
                $message = if ($answer.error) { $answer.error } else { 'No response from local bus.' }
                Add-AiMsg "Bridge error: $message"
                $activeRouteName.Text = 'Gemma Bridge · error'
                $activeRouteDetail.Text = $message
            }
            Refresh-MicronautHistory
            Refresh-ActiveModelStatus
            Set-Ready
        }
    }).GetNewClosure())
    $timer.Start()
}

# ── Multi-step ingest pipelines ────────────────────────────────────────────────
$script:ShardsRoot = 'C:\Users\canna\.micronauts\models\micronauts\agentic-micronauts'
$script:TrainingDir = "$script:ShardsRoot\micronaut\training"
$script:RealData    = "$script:TrainingDir\real_data"
$script:XshardPy   = "$script:ShardsRoot\MX-2\xshard_ingest.py"
$script:MX2Dir      = "$script:ShardsRoot\MX-2"

function Start-RealDataIngest {
    Add-ActionMsg 'ingest: sft_mixed.jsonl + rlhf_pairs.jsonl'
    Set-Busy
    $exe  = $CliPath
    $sft  = "$script:RealData\sft_mixed.jsonl"
    $rlhf = "$script:RealData\rlhf_pairs.jsonl"
    $mh   = $script:MX2Dir
    $job  = Start-ThreadJob -ScriptBlock {
        param($exe, $sft, $rlhf, $mh)
        $env:MICRONAUT_HOME = $mh
        $out = @()
        foreach ($f in @($sft, $rlhf)) {
            if (-not (Test-Path $f)) { $out += "[skip] not found: $f"; continue }
            $p = [System.Diagnostics.Process]::Start([System.Diagnostics.ProcessStartInfo]@{
                FileName = $exe; Arguments = "ingest-jsonl `"$f`""
                RedirectStandardOutput = $true; RedirectStandardError = $true
                UseShellExecute = $false; CreateNoWindow = $true
                EnvironmentVariables = @{'MICRONAUT_HOME'=$mh}
            })
            # Append MICRONAUT_HOME to the process env (PS doesn't merge above cleanly)
            $p.StartInfo.EnvironmentVariables['MICRONAUT_HOME'] = $mh
            $stdOut = $p.StandardOutput.ReadToEndAsync()
            $stdErr = $p.StandardError.ReadToEndAsync()
            $p.WaitForExit(600000) | Out-Null
            $txt = $stdOut.Result + $stdErr.Result
            $out += "[$(Split-Path $f -Leaf)] $($txt.Trim())"
        }
        $out -join "`n"
    } -ArgumentList $exe, $sft, $rlhf, $mh

    $tmr = [System.Windows.Threading.DispatcherTimer]::new()
    $tmr.Interval = [TimeSpan]::FromSeconds(1)
    $tmr.Add_Tick({
        if ($job.State -in 'Completed','Failed','Stopped') {
            $tmr.Stop()
            $r = $job | Receive-Job -Wait -AutoRemoveJob
            Add-AiMsg ($r -replace '\s+',' ')
            Set-Ready
        }
    }.GetNewClosure())
    $tmr.Start()
}

function Start-FullIngest {
    Add-ActionMsg 'ingest: xshard corpus (all domains)'
    Set-Busy
    $py   = $script:XshardPy
    $root = $script:ShardsRoot
    $mh   = $script:MX2Dir
    $job  = Start-ThreadJob -ScriptBlock {
        param($py, $root, $mh)
        if (-not (Test-Path $py)) { return "[error] xshard_ingest.py not found: $py" }
        $p = [System.Diagnostics.Process]::Start([System.Diagnostics.ProcessStartInfo]@{
            FileName = 'python'; Arguments = "`"$py`" `"$root`" --home `"$mh`""
            RedirectStandardOutput = $true; RedirectStandardError = $true
            UseShellExecute = $false; CreateNoWindow = $true
        })
        $stdOut = $p.StandardOutput.ReadToEndAsync()
        $stdErr = $p.StandardError.ReadToEndAsync()
        $p.WaitForExit(7200000) | Out-Null   # 2hr max for 309 shards
        ($stdOut.Result + $stdErr.Result).Trim()
    } -ArgumentList $py, $root, $mh

    $tmr = [System.Windows.Threading.DispatcherTimer]::new()
    $tmr.Interval = [TimeSpan]::FromSeconds(2)
    $tmr.Add_Tick({
        if ($job.State -in 'Completed','Failed','Stopped') {
            $tmr.Stop()
            $r = $job | Receive-Job -Wait -AutoRemoveJob
            # Show last 3 lines (summary) to avoid flooding chat
            $lines = ($r -split "`n") | Where-Object { $_ -match '\S' }
            Add-AiMsg ($lines | Select-Object -Last 4 | Out-String).Trim()
            Set-Ready
        }
    }.GetNewClosure())
    $tmr.Start()
}

function Start-MoETraining {
    Add-ActionMsg 'train: StructuralMoE 96m'
    Set-Busy
    $trainDir = $script:TrainingDir
    $cfgFile  = "$trainDir\configs\micronaut_96m.json"
    $dataset  = "$trainDir\sample_data\glyph_programs.jsonl"
    $outFile  = "$trainDir\out\model.pt"
    $realDs   = "$trainDir\real_data\sft_mixed.jsonl"
    # Use real data JSONL if available (for text→glyph synthesis), else sample
    if (Test-Path $realDs) { $dataset = $realDs }
    $job = Start-ThreadJob -ScriptBlock {
        param($trainDir, $cfg, $ds, $out)
        Push-Location $trainDir
        $p = [System.Diagnostics.Process]::Start([System.Diagnostics.ProcessStartInfo]@{
            FileName = 'python'; Arguments = "train_moe.py --config `"$cfg`" --dataset `"$ds`" --save `"$out`" --steps 200"
            RedirectStandardOutput = $true; RedirectStandardError = $true
            UseShellExecute = $false; CreateNoWindow = $true
            WorkingDirectory = $trainDir
        })
        $stdOut = $p.StandardOutput.ReadToEndAsync()
        $stdErr = $p.StandardError.ReadToEndAsync()
        $p.WaitForExit(1800000) | Out-Null  # 30min max
        Pop-Location
        ($stdOut.Result + $stdErr.Result).Trim()
    } -ArgumentList $trainDir, $cfgFile, $dataset, $outFile

    $tmr = [System.Windows.Threading.DispatcherTimer]::new()
    $tmr.Interval = [TimeSpan]::FromSeconds(3)
    $tmr.Add_Tick({
        if ($job.State -in 'Completed','Failed','Stopped') {
            $tmr.Stop()
            $r = $job | Receive-Job -Wait -AutoRemoveJob
            $lines = ($r -split "`n") | Where-Object { $_ -match '\S' }
            Add-AiMsg ($lines | Select-Object -Last 6 | Out-String).Trim()
            Set-Ready
        }
    }.GetNewClosure())
    $tmr.Start()
}

function Invoke-CLI([string]$command, [string]$arg = '') {
    Add-ActionMsg "$command$(if ($arg) { " $arg" })"
    Set-Busy
    # Commands handled as CLI args (single-shot exit)
    $argsMode = $command -in @('query','train','ingest-jsonl','help','--help','call','--version')
    if ($argsMode) {
        $ca = if ($arg) { "$command `"$arg`"" } else { $command }
        Start-CliTask -cliArgs $ca -timeoutMs 60000 -mode 'args' -onResult {
            param($r); Add-AiMsg $r; Set-Ready
        }
    } else {
        # K-shell stdin pipe (stats, save, load, weight, etc.)
        $ca = if ($arg) { "$command $arg" } else { $command }
        Start-CliTask -cliArgs $ca -timeoutMs 15000 -mode 'pipe' -onResult {
            param($r); Add-AiMsg $r; Set-Ready
        }
    }
}

# ── Command router (single entry from input bar + option buttons) ──────────────
$script:SlashCommands = @(
    @{ Name = '/gemma'; Hint = 'Ask local Gemma 3 after vector fallback'; Argument = $true },
    @{ Name = '/code'; Hint = 'Generate code with local Gemma 3'; Argument = $true },
    @{ Name = '/vector'; Hint = 'Use extended vector retrieval'; Argument = $true },
    @{ Name = '/help'; Hint = 'Show available commands'; Argument = $false },
    @{ Name = '/stats'; Hint = 'Show native CLI statistics'; Argument = $false },
    @{ Name = '/save'; Hint = 'Save native CLI state'; Argument = $false },
    @{ Name = '/load'; Hint = 'Load native CLI state'; Argument = $false },
    @{ Name = '/ingest'; Hint = 'Ingest a JSONL file'; Argument = $true },
    @{ Name = '/train'; Hint = 'Train with an argument'; Argument = $true },
    @{ Name = '/call'; Hint = 'Call a native CLI action'; Argument = $true },
    @{ Name = '/weight'; Hint = 'Set a native CLI weight'; Argument = $true },
    @{ Name = '/todo add'; Hint = 'Add a task'; Argument = $true },
    @{ Name = '/todo done'; Hint = 'Complete task number'; Argument = $true },
    @{ Name = '/todo next'; Hint = 'Activate task number'; Argument = $true }
)

function Update-CommandPicker {
    $typed = $inputBox.Text
    $commandList.Children.Clear()
    if (-not $typed.StartsWith('/') -or $typed.Contains("`n")) {
        $commandPanel.Visibility = 'Collapsed'
        return
    }
    $matches = @($script:SlashCommands | Where-Object { $_.Name.StartsWith($typed, [StringComparison]::OrdinalIgnoreCase) })
    if ($matches.Count -eq 0) { $commandPanel.Visibility = 'Collapsed'; return }
    foreach ($cmd in $matches) {
        $button = [System.Windows.Controls.Button]::new()
        $button.Content = "$($cmd.Name)   $($cmd.Hint)"
        $button.HorizontalContentAlignment = 'Left'
        $button.Background = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString('#21262D'))
        $button.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.ColorConverter]::ConvertFromString('#E6EDF3'))
        $button.BorderThickness = [System.Windows.Thickness]::new(0)
        $button.Padding = [System.Windows.Thickness]::new(8,5,8,5)
        $button.Margin = [System.Windows.Thickness]::new(0,1,0,1)
        $name = [string]$cmd.Name
        $needsArg = [bool]$cmd.Argument
        $button.Add_Click(({
            $inputBox.Text = if ($needsArg) { "$name " } else { $name }
            $inputBox.CaretIndex = $inputBox.Text.Length
            $inputBox.Focus() | Out-Null
        }).GetNewClosure())
        $commandList.Children.Add($button) | Out-Null
    }
    $commandPanel.Visibility = 'Visible'
}

function Submit-Input([string]$raw) {
    $t = $raw.Trim()
    if ([string]::IsNullOrWhiteSpace($t)) { return }
    $commandPanel.Visibility = 'Collapsed'
    $inputBox.Text = ''
    switch -Regex ($t) {
        '^/vector\s+(.+)$'          { Send-ToAI $matches[1].Trim() 'vector_extended_v1' }
        '^/gemma\s+(.+)$'           { Send-ToAI $matches[1].Trim() 'neural_local_v1' }
        '^/code\s+(.+)$'            { Send-ToAI $matches[1].Trim() 'code_local_v1' }
        '^/?stats$'                 { Invoke-CLI 'stats' }
        '^/?help$'                  { Add-AiMsg (($script:SlashCommands | ForEach-Object { "$($_.Name) — $($_.Hint)" }) -join "`n"); $inputBox.Text = '' }
        '^/?save$'                  { Invoke-CLI 'save' }
        '^/?load$'                  { Invoke-CLI 'load' }
        '^/?ingest(-jsonl)?\s+(.+)$' { Invoke-CLI 'ingest-jsonl' $matches[2].Trim() }
        '^/?train\s+(.+)$'          { Invoke-CLI 'train' $matches[1].Trim() }
        '^/?call\s+(.+)$'           { Invoke-CLI 'call'  $matches[1].Trim() }
        '^/?weight\s+(.+)$'         { Invoke-CLI 'weight' $matches[1].Trim() }
        '^/?todo add\s+(.+)$'       {
            Add-Todo $matches[1].Trim()
            Save-Todos
            Add-ActionMsg "todo added"
        }
        '^/?todo done\s+(\d+)$'    {
            $i = [int]$matches[1] - 1
            if ($i -ge 0 -and $i -lt $script:Todos.Count) {
                $script:Todos[$i] = @{ text = $script:Todos[$i].text; status = 'done' }
                Refresh-Todos; Save-Todos; Add-ActionMsg "todo $($matches[1]) done"
            }
        }
        '^/?todo next\s+(\d+)$'    { Set-ActiveTodo ([int]$matches[1]-1); Save-Todos }
        '^/'                        { Add-AiMsg 'Unknown or incomplete command. Type / to see available commands.' }
        default {
            $routeMode = ''
            try {
                $routeResult = Invoke-RestMethod -Uri "$script:BusBase/api/bindings/invoke" -Method Post `
                    -Body (@{ name = 'terminal.route'; text = $t } | ConvertTo-Json -Compress) `
                    -ContentType 'application/json' -TimeoutSec 3
                $routeMode = [string]$routeResult.result.responseMode
                Add-ActionMsg "route: $($routeResult.result.route) · proposal"
                if ($routeResult.result.command) {
                    Add-CommandApproval ([string]$routeResult.result.command) ([bool]$routeResult.result.mutating)
                    return
                }
            } catch { }
            Send-ToAI $t $routeMode
        }
    }
}

# ── Seed todos (load from file, or use defaults) ───────────────────────────────
Load-Todos
if ($script:Todos.Count -eq 0) {
    Add-Todo 'Scaffold MX-2 manifest'          'done'
    Add-Todo 'Wire bots.py to native CLI'      'done'
    Add-Todo 'Launch WPF chat UI'              'done'
    Add-Todo 'Hook ingest/train commands'      'done'
    Add-Todo 'Persist todo state to JSON'      'done'
    Add-Todo 'Add WPF question/options widget' 'active'
    Save-Todos
} else {
    Refresh-Todos
}

# ── Bindings ───────────────────────────────────────────────────────────────────
$sendBtn.Add_Click({ Submit-Input $inputBox.Text })
$inputBox.Add_TextChanged({ Update-CommandPicker })
$inputBox.Add_KeyDown({
    if ($_.Key -eq 'Escape' -and $commandPanel.Visibility -eq 'Visible') {
        $commandPanel.Visibility = 'Collapsed'; $_.Handled = $true
    } elseif ($_.Key -eq 'Return') { Submit-Input $inputBox.Text; $_.Handled = $true }
})
$newChatBtn.Add_Click({ New-MicronautChat })
$window.Add_Closed({
    if ($script:BusJob) {
        try {
            Invoke-RestMethod -Uri "$script:BusBase/_internal/shutdown" -Method Post `
                -Headers @{ 'X-Micronaut-Shutdown' = $script:BusShutdownToken } `
                -Body '{}' -ContentType 'application/json' -TimeoutSec 3 | Out-Null
        } catch { }
        Remove-Job $script:BusJob -Force -ErrorAction SilentlyContinue
    }
})

# ── Intro message ──────────────────────────────────────────────────────────────
if (Start-MicronautBus) {
    New-MicronautChat
    Add-AiMsg 'Gemma Bridge is ready. Send a message for verified retrieval, or use /gemma followed by a question for a local model response after retrieval.'
    Set-Ready
    Refresh-ActiveModelStatus
} else {
    Add-AiMsg 'Local Gemma bus could not start. Check shell/Start-Server.ps1 and the built bridge binaries.'
    Set-Status 'bus unavailable' '#F85149'
}

# ── Launch ─────────────────────────────────────────────────────────────────────
Populate-Models
[void]$window.ShowDialog()

