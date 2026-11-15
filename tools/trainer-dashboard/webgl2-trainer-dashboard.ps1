#Requires -Version 5.1

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

# Use the local WebView2 WPF SDK for the CSS-ML browser trainer.
$script:WebView2Available = $false
$script:WebView2Status = 'WebView2 SDK/runtime unavailable'
$script:CssMlWebView = $null
$webViewSdkRoot = Join-Path $PSScriptRoot '..\..\.CSS-C\webview2_sdk'
$webViewManaged = Join-Path $webViewSdkRoot 'lib_manual\netcoreapp3.0'
$webViewNativeArch = if ([Environment]::Is64BitProcess) { 'win-x64' } else { 'win-x86' }
$webViewNativeDir = Join-Path $webViewSdkRoot "runtimes\$webViewNativeArch\native"
try {
    Add-Type -Path (Join-Path $webViewManaged 'Microsoft.Web.WebView2.Core.dll') -ErrorAction Stop
    Add-Type -Path (Join-Path $webViewManaged 'Microsoft.Web.WebView2.Wpf.dll') -ErrorAction Stop
    $env:PATH = "$webViewNativeDir;$env:PATH"
    $version = [Microsoft.Web.WebView2.Core.CoreWebView2Environment]::GetAvailableBrowserVersionString()
    $script:WebView2Available = $true
    $script:WebView2Status = "Edge WebView2 $version"
} catch {
    $script:WebView2Status = "WebView2 unavailable: $($_.Exception.Message)"
}

trap {
    $msg = @(
        $_.Exception.ToString()
        $_.InvocationInfo.PositionMessage
        "Script stack: $($_.ScriptStackTrace)"
    ) -join [Environment]::NewLine
    $msg | Out-File (Join-Path $PSScriptRoot 'trainer-dashboard-error.log') -Append -Encoding UTF8
    [System.Windows.MessageBox]::Show($msg, 'Trainer Dashboard Error', 'OK', 'Error') | Out-Null
    break
}

# ── paths ─────────────────────────────────────────────────────────────────────
$script:RepoRoot         = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script:ServerBaseUrl    = 'http://127.0.0.1:8776'
$script:CurrentSessionId = ''
$script:EventCursor      = 0
$script:IsBusy           = $false
$script:NativeProcess    = $null
$script:D3D11Process     = $null

$script:KuhulEsRoot      = Join-Path $PSScriptRoot 'kuhul-es'
$script:WebView2SmokeExe = Join-Path $script:KuhulEsRoot 'tools\webview2-smoke-test\bin\Debug\net8.0-windows\WebView2Smoke.exe'
$script:KuhulEsCli       = Join-Path $script:KuhulEsRoot 'bin\kuhul-es.js'
$script:GemmaScratchTrainer = Join-Path $script:RepoRoot 'tools\train_gemma3_scratch.py'
$script:GemmaBaselineDir    = Join-Path $script:RepoRoot 'build\gemma3-reasoning-opencl-300m-24h'
$script:GemmaTokenBin       = Join-Path $script:RepoRoot 'build\gemma3-chat-reasoning\chat.tokens.bin'
$script:D3D11WorkDir     = Join-Path $script:RepoRoot 'build'
$script:D3D11TrainerExe  = Join-Path $script:D3D11WorkDir 'Release\gpt2_trainer.exe'
# The inspect trainer and the daemon checkout use different build layouts.
# Prefer their conventional Release folders, then keep the UI usable even if
# this checkout has not built the D3D11 trainer yet.
if (-not (Test-Path -LiteralPath $script:D3D11TrainerExe -PathType Leaf)) {
    $alternateTrainer = Join-Path $script:D3D11WorkDir 'gml-stage1\Release\gpt2_trainer.exe'
    if (Test-Path -LiteralPath $alternateTrainer -PathType Leaf) {
        $script:D3D11TrainerExe = $alternateTrainer
    }
}

# ── model catalog ─────────────────────────────────────────────────────────────
$script:ModelCatalog = @(
    [pscustomobject]@{
        Name        = 'GPT-2 Small'
        Family      = 'mini-GPT'
        Arch        = 'GPT-2 * 124M params'
        Status      = 'TRAINING'
        StatusColor = '#F0883E'
        TypeLabel   = 'GPT-2'
        Lines       = @(
            'gpt2_merged_chat_tool  Q2K  79 MB'
            'gpt2_merged_chat_tool  Q4  345 MB'
            'gpt2_merged_chat_tool  Q8  384 MB'
            'gpt2_small_lite_tool (webgl2 / native)'
        )
        Tags        = @('CHAT','TOOL','Q2K','Q4','Q8','TRAINING')
        StatusNote  = 'Phase 1 running  -- stack corpus 10K steps'
        Path        = 'E:\models\GPT2\mini-GPT'
    }
    [pscustomobject]@{
        Name        = 'GPT-2 Medium'
        Family      = 'med-GPT'
        Arch        = 'GPT-2 * 355M params'
        Status      = 'READY'
        StatusColor = '#3FB950'
        TypeLabel   = 'GPT-2'
        Lines       = @(
            'gpt2_medium_ft_toolcall_q8   704 MB'
            'adapter.json registered'
            'tokens_toolcall_v5.bin  9.3 MB'
        )
        Tags        = @('TOOLCALL','FINETUNE','Q8')
        StatusNote  = 'ft_toolcall Q8 * adapter ready'
        Path        = 'E:\models\GPT2\med-GPT'
    }
    [pscustomobject]@{
        Name        = 'GPT-2 Large'
        Family      = 'lg-GPT2'
        Arch        = 'GPT-2 * 774M params'
        Status      = 'READY'
        StatusColor = '#3FB950'
        TypeLabel   = 'GPT-2'
        Lines       = @(
            'model.rebuilt.gguf        3.1 GB'
            'lg-gpt2-f32.xshard        3.1 GB'
            'xshard.adapt.jsonl available'
        )
        Tags        = @('LARGE','XSHARD','GGUF')
        StatusNote  = 'F32 xshard + adapt.jsonl'
        Path        = 'E:\models\GPT2\lg-GPT2'
    }
    [pscustomobject]@{
        Name        = 'Gemma 3 1B'
        Family      = 'gemma-3-1b-it'
        Arch        = 'Gemma3 * 1B params'
        Status      = 'ACTIVE'
        StatusColor = '#0aff76'
        TypeLabel   = 'GEMMA'
        Lines       = @(
            'Q4    729 MB   Q8  1020 MB   F16  1.9 GB'
            'xshard 722 MB  xshard-f32  3.8 GB'
            'adapt.jsonl available'
        )
        Tags        = @('DEFAULT','POP','YAX','CHEN','Q4','Q8','XSHARD')
        StatusNote  = 'Default model  -- Pop/Yax/Ch''en folds * port 17474'
        Path        = 'E:\models\GPT2\gemma-3-1b-it'
    }
    [pscustomobject]@{
        Name        = 'Gemma 3 Reasoning 300M'
        Family      = 'gemma3-reasoning-scratch'
        Arch        = 'Gemma3 text * 303,995,904 params'
        Status      = '24H BASELINE'
        StatusColor = '#3FB950'
        TypeLabel   = 'GEMMA 3'
        Lines       = @(
            'model.safetensors  1,216,001,416 bytes'
            '24h CPU forward/backward + OpenCL AdamW update'
            'sequence length 32  |  18,183 optimizer steps'
            'training loss 0.5808  |  validation loss 1.7404'
            'CSS-ML WebGL2 full Gemma training is not wired yet'
        )
        Tags        = @('300M','SCRATCH','24H','OPENCL','CHECKPOINT')
        StatusNote  = 'Current Gemma training baseline · build\gemma3-reasoning-opencl-300m-24h'
        Path        = Join-Path $script:RepoRoot 'build\gemma3-reasoning-opencl-300m-24h'
    }
    [pscustomobject]@{
        Name        = 'Qwen2.5 0.5B Coder'
        Family      = 'qwen'
        Arch        = 'Qwen2.5 * 0.5B params'
        Status      = 'TRAINING'
        StatusColor = '#F0883E'
        TypeLabel   = 'QWEN'
        Lines       = @(
            '[RETIRED] model.gguf + all xshards -- old ASX F32, contaminated'
            '[RETIRED] Qwen-Coder.gguf -- same corrupt ASX source'
            'qwen2.5-0.5b-instruct-q8_0.gguf  644 MB  CLEAN TRAIN BASE (story/creative)'
            'qwen2.5-instruct-q8.xshard -- to be created at first slice run'
            'mm-coder lane: Qwen3-4B-Q8_0 (grounded, active on :25500)'
        )
        Tags        = @('CODER','AST','XSHARD','D3D11','SLICE-TRAIN','CLEAN-BASE')
        StatusNote  = 'Train base: qwen2.5-0.5b-instruct-q8_0  |  Active lane: Qwen3-4B'
        Path        = 'E:\models\GPT2'
    }
)

# ── dataset catalog ───────────────────────────────────────────────────────────
$script:DatasetCatalog = @(
    [pscustomobject]@{
        Name        = 'stack_phase1'
        File        = 'E:\data\train\stack_phase1.bin'
        Lines       = @(
            '1,421,235 seq x 128 tok * 694 MB'
            '482K prose pairs * Q:/A:<|endoftext|>'
            'distil + chat + opcode + jrom_mem'
        )
        Tags        = @('PHASE-1','PROSE','GPT-2-BPE','STACK')
        TypeLabel   = 'BIN'
        StatusNote  = 'Active  -- phase 1 training in progress'
        StatusColor = '#F0883E'
    }
    [pscustomobject]@{
        Name        = 'stack_phase2'
        File        = 'E:\data\train\stack_phase2.bin'
        Lines       = @(
            '26,382 seq x 128 tok * 12.9 MB'
            '11.6K valid JSON tool pairs'
            'completion-only fine-tune target'
        )
        Tags        = @('PHASE-2','TOOLS','JSON','COMPLETION-ONLY')
        TypeLabel   = 'BIN'
        StatusNote  = 'Pending  -- run after phase 1 completes'
        StatusColor = '#8B949E'
    }
    [pscustomobject]@{
        Name        = 'kuhul_tokens'
        File        = 'E:\data\kuhul_tokens.bin'
        Lines       = @(
            'KUHUL fold/phase token sequences'
            'GPT-2 BPE tokenized'
        )
        Tags        = @('KUHUL','FOLD','PHASE')
        TypeLabel   = 'BIN'
        StatusNote  = 'Stack grammar pre-training'
        StatusColor = '#3FB950'
    }
    [pscustomobject]@{
        Name        = 'coder_ast_seq256'
        File        = 'E:\models\GPT2\coder_micronaut\coder_ast_json_seq256_tokens.bin'
        Lines       = @(
            '[CORRUPT] do not use for training'
            'source of corrupt Qwen-Coder model'
        )
        Tags        = @('CORRUPT','RETIRED')
        TypeLabel   = 'BIN'
        StatusNote  = '[CORRUPT] Retired -- produced bad Qwen-Coder weights'
        StatusColor = '#DA3633'
    }
    [pscustomobject]@{
        Name        = 'qwen_ast_tokens'
        File        = 'E:\models\GPT2\qwen\qwen_ast_tokens.bin'
        Lines       = @(
            '686 MB * Qwen2.5 tokenizer'
            'AST + code sequences'
            'qwen-ast-grad.xshard source'
        )
        Tags        = @('AST','QWEN','CODER','LARGE')
        TypeLabel   = 'BIN'
        StatusNote  = 'Qwen2.5 coder training tokens'
        StatusColor = '#3FB950'
    }
    [pscustomobject]@{
        Name        = 'tokens_toolcall_v5'
        File        = 'E:\models\GPT2\med-GPT\tokens_toolcall_v5.bin'
        Lines       = @(
            '9.3 MB * seq=128'
            'harvested codex + gemini + log'
        )
        Tags        = @('TOOLCALL','MEDIUM','V5')
        TypeLabel   = 'BIN'
        StatusNote  = 'med-GPT toolcall fine-tune tokens'
        StatusColor = '#3FB950'
    }
    [pscustomobject]@{
        Name        = 'kuhul_flat'
        File        = 'E:\data\kuhul_flat.bin'
        Lines       = @(
            'Flat KUHUL corpus binary'
            'Phase/fold sequences'
        )
        Tags        = @('KUHUL','FLAT','FOLD')
        TypeLabel   = 'BIN'
        StatusNote  = 'KUHUL flat binary training data'
        StatusColor = '#3FB950'
    }
    [pscustomobject]@{
        Name        = 'coder_outputs_seq256'
        File        = 'E:\models\GPT2\coder_micronaut\coder_outputs_seq256_tokens.bin'
        Lines       = @(
            '[CORRUPT] do not use for training'
            'derived from corrupt coder_ast_seq256'
        )
        Tags        = @('CORRUPT','RETIRED')
        TypeLabel   = 'BIN'
        StatusNote  = '[CORRUPT] Retired -- same corrupt source as coder_ast_seq256'
        StatusColor = '#DA3633'
    }
)

# ── XAML ──────────────────────────────────────────────────────────────────────
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="KUHUL TRAINER  |  CSS-ML  |  WebGL2  |  D3D11  |  PyTorch"
        Height="960" Width="1340" MinHeight="720" MinWidth="1000"
        WindowStartupLocation="CenterScreen"
        Background="#03120b" FontFamily="Consolas">
  <Window.Resources>

    <!-- ── tab item style ─────────────────────────────────────────────── -->
    <Style TargetType="{x:Type TabItem}">
      <Setter Property="Background"   Value="#03120b"/>
      <Setter Property="Foreground"   Value="#0aff76"/>
      <Setter Property="BorderBrush"  Value="#0aff76"/>
      <Setter Property="FontFamily"   Value="Consolas"/>
      <Setter Property="FontSize"     Value="12"/>
      <Setter Property="FontWeight"   Value="Bold"/>
      <Setter Property="Padding"      Value="20,8"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="{x:Type TabItem}">
            <Border x:Name="TabBorder"
                    Background="#03120b"
                    BorderBrush="#1a4a2e"
                    BorderThickness="1,1,1,0"
                    CornerRadius="6,6,0,0"
                    Padding="20,7,20,7"
                    Margin="2,4,2,0">
              <ContentPresenter ContentSource="Header"
                                HorizontalAlignment="Center"
                                VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsSelected" Value="True">
                <Setter TargetName="TabBorder" Property="Background"    Value="#0a1c10"/>
                <Setter TargetName="TabBorder" Property="BorderBrush"   Value="#0aff76"/>
                <Setter TargetName="TabBorder" Property="BorderThickness" Value="1,1,1,0"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="TabBorder" Property="BorderBrush" Value="#0aff76"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- ── combo box item style ──────────────────────────────────────── -->
    <Style x:Key="GreenComboItemStyle" TargetType="{x:Type ComboBoxItem}">
      <Setter Property="Foreground" Value="#0aff76"/>
      <Setter Property="Background" Value="#03120b"/>
      <Setter Property="Padding"    Value="8,4"/>
      <Setter Property="FontFamily" Value="Consolas"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="{x:Type ComboBoxItem}">
            <Border x:Name="CB" Background="{TemplateBinding Background}" Padding="{TemplateBinding Padding}">
              <ContentPresenter/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsHighlighted" Value="True">
                <Setter TargetName="CB" Property="Background" Value="#0d4a1e"/>
              </Trigger>
              <Trigger Property="IsSelected" Value="True">
                <Setter TargetName="CB" Property="Background" Value="#0d2415"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- ── combo box style ───────────────────────────────────────────── -->
    <Style x:Key="GreenComboStyle" TargetType="{x:Type ComboBox}">
      <Setter Property="Foreground"          Value="#0aff76"/>
      <Setter Property="Background"          Value="#03120b"/>
      <Setter Property="BorderBrush"         Value="#1a4a2e"/>
      <Setter Property="BorderThickness"     Value="1"/>
      <Setter Property="Padding"             Value="6,3"/>
      <Setter Property="FontFamily"          Value="Consolas"/>
      <Setter Property="FontSize"            Value="11"/>
      <Setter Property="ItemContainerStyle"  Value="{StaticResource GreenComboItemStyle}"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="{x:Type ComboBox}">
            <Grid>
              <ToggleButton x:Name="TG" Focusable="False"
                            OverridesDefaultStyle="True"
                            IsChecked="{Binding IsDropDownOpen, RelativeSource={RelativeSource TemplatedParent}, Mode=TwoWay}">
                <ToggleButton.Template>
                  <ControlTemplate TargetType="ToggleButton">
                    <ContentPresenter/>
                  </ControlTemplate>
                </ToggleButton.Template>
                <Border x:Name="BD" Background="{TemplateBinding Background}"
                        BorderBrush="{TemplateBinding BorderBrush}"
                        BorderThickness="{TemplateBinding BorderThickness}">
                  <Grid>
                    <Grid.ColumnDefinitions>
                      <ColumnDefinition Width="*"/>
                      <ColumnDefinition Width="20"/>
                    </Grid.ColumnDefinitions>
                    <ContentPresenter Grid.Column="0" Margin="6,0,2,0"
                                      VerticalAlignment="Center"
                                      Content="{TemplateBinding SelectionBoxItem}"/>
                    <Border Grid.Column="1" Background="#0a1c10" BorderBrush="#1a4a2e" BorderThickness="1,0,0,0">
                      <Path Data="M 0 0 L 4 4 L 8 0 Z" Fill="#0aff76"
                            HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Border>
                  </Grid>
                </Border>
              </ToggleButton>
              <Popup x:Name="Popup" Placement="Bottom"
                     IsOpen="{TemplateBinding IsDropDownOpen}"
                     AllowsTransparency="True" Focusable="False" PopupAnimation="Fade">
                <Border Background="#0a1c10" BorderBrush="#0aff76" BorderThickness="1">
                  <ScrollViewer CanContentScroll="True">
                    <StackPanel IsItemsHost="True"
                                KeyboardNavigation.DirectionalNavigation="Contained"/>
                  </ScrollViewer>
                </Border>
              </Popup>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsKeyboardFocusWithin" Value="True">
                <Setter TargetName="BD" Property="BorderBrush" Value="#0aff76"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

    <!-- ── ExplicitComboBoxStyle alias (kept for existing code) ──────── -->
    <Style x:Key="ExplicitComboBoxStyle" TargetType="{x:Type ComboBox}"
           BasedOn="{StaticResource GreenComboStyle}"/>

    <!-- ── button style ──────────────────────────────────────────────── -->
    <Style x:Key="GreenBtn" TargetType="{x:Type Button}">
      <Setter Property="Foreground"      Value="#0aff76"/>
      <Setter Property="BorderBrush"     Value="#0aff76"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="FontFamily"      Value="Consolas"/>
      <Setter Property="FontSize"        Value="11"/>
      <Setter Property="Cursor"          Value="Hand"/>
      <Setter Property="Padding"         Value="12,5"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="{x:Type Button}">
            <Border x:Name="BtnBd"
                    Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    CornerRadius="4"
                    Padding="{TemplateBinding Padding}">
              <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="BtnBd" Property="Opacity" Value="0.8"/>
              </Trigger>
              <Trigger Property="IsPressed" Value="True">
                <Setter TargetName="BtnBd" Property="Opacity" Value="0.6"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>

  </Window.Resources>

  <Grid>
    <Grid.RowDefinitions>
      <RowDefinition Height="50"/>
      <RowDefinition Height="*"/>
      <RowDefinition Height="28"/>
    </Grid.RowDefinitions>

    <!-- ══ HEADER ══════════════════════════════════════════════════════════ -->
    <Border Grid.Row="0" Background="#0a1c10"
            BorderBrush="#0aff76" BorderThickness="0,0,0,1" Padding="12,0">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="Auto"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>

        <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
          <Image x:Name="LogoImage" Width="26" Height="26" Margin="0,0,10,0" VerticalAlignment="Center"
                 RenderOptions.BitmapScalingMode="HighQuality"/>
          <TextBlock Text="KUHUL TRAINER" Foreground="#0aff76" FontSize="14" FontWeight="Bold"
                     VerticalAlignment="Center" Margin="0,0,24,0"/>
          <TextBlock Text="SERVER" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,0"/>
          <TextBox x:Name="ServerUrlBox" Width="230" Height="26"
                   Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e"
                   FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"
                   Text="http://127.0.0.1:8776"/>
          <Ellipse x:Name="ServerDot" Width="8" Height="8" Fill="#DA3633"
                   Margin="10,0,5,0" VerticalAlignment="Center"/>
          <TextBlock x:Name="ServerStatusText" Text="OFFLINE"
                     Foreground="#07cc5e" FontFamily="Consolas" FontSize="11" VerticalAlignment="Center"/>
        </StackPanel>

        <Button x:Name="CheckServerBtn" Grid.Column="1" Content="CHECK"
                Margin="8,0,0,0" Height="26" Style="{StaticResource GreenBtn}"
                Background="#0d2415"/>
        <Button x:Name="SmokeBtn" Grid.Column="2" Content="WEBVIEW2 SMOKE"
                Margin="8,0,0,0" Height="26" Style="{StaticResource GreenBtn}"
                Background="#0d2415"/>
        <TextBlock x:Name="D3D11StatusBadge" Grid.Column="3"
                   Text="D3D11: IDLE" Foreground="#07cc5e"
                   FontFamily="Consolas" FontSize="11" VerticalAlignment="Center"
                   Margin="16,0,8,0"/>
        <TextBlock x:Name="SessionStatusText" Grid.Column="4"
                   Text="Session: (none)" Foreground="#0aff76"
                   FontFamily="Consolas" FontSize="11" VerticalAlignment="Center"
                   Margin="0,0,4,0"/>
      </Grid>
    </Border>

    <!-- ══ TABS ════════════════════════════════════════════════════════════ -->
    <TabControl Grid.Row="1" x:Name="MainTabs"
                Background="#03120b" Foreground="#0aff76"
                BorderBrush="#1a4a2e" BorderThickness="0,0,0,0">

      <!-- ── MODELS TAB ─────────────────────────────────────────────────── -->
      <TabItem Header="  MODELS  ">
        <Grid Background="#03120b">
          <Grid.RowDefinitions>
            <RowDefinition Height="40"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>
          <Border Grid.Row="0" Background="#0a1c10" BorderBrush="#1a4a2e" BorderThickness="0,0,0,1" Padding="12,0">
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
              <TextBlock Text="MODEL REGISTRY" Foreground="#0aff76" FontWeight="Bold" FontSize="12" VerticalAlignment="Center" Margin="0,0,24,0"/>
              <TextBlock x:Name="ModelCountText" Text="6 models" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center"/>
            </StackPanel>
          </Border>
          <ScrollViewer Grid.Row="1" Background="#03120b" VerticalScrollBarVisibility="Auto">
            <WrapPanel x:Name="ModelsPanel" Orientation="Horizontal" Margin="8,8,8,8"/>
          </ScrollViewer>
        </Grid>
      </TabItem>

      <!-- ── DATASETS TAB ───────────────────────────────────────────────── -->
      <TabItem Header=" DATASETS ">
        <Grid Background="#03120b">
          <Grid.RowDefinitions>
            <RowDefinition Height="40"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>
          <Border Grid.Row="0" Background="#0a1c10" BorderBrush="#1a4a2e" BorderThickness="0,0,0,1" Padding="12,0">
            <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
              <TextBlock Text="DATASET REGISTRY" Foreground="#0aff76" FontWeight="Bold" FontSize="12" VerticalAlignment="Center" Margin="0,0,24,0"/>
              <TextBlock x:Name="DatasetCountText" Text="8 datasets" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center"/>
            </StackPanel>
          </Border>
          <ScrollViewer Grid.Row="1" Background="#03120b" VerticalScrollBarVisibility="Auto">
            <WrapPanel x:Name="DatasetsPanel" Orientation="Horizontal" Margin="8,8,8,8"/>
          </ScrollViewer>
        </Grid>
      </TabItem>

      <!-- ── TRAINER TAB ────────────────────────────────────────────────── -->
      <TabItem Header="  TRAINER ">
        <ScrollViewer Background="#03120b" VerticalScrollBarVisibility="Auto">
          <StackPanel Margin="10,8,10,8">

            <!-- CSS-ML / WebGL2 capability and model-size boundary -->
            <Border Margin="0,0,0,8" Background="#0a1c10"
                    BorderBrush="#4db8ff" BorderThickness="1" CornerRadius="6" Padding="12">
              <StackPanel>
                <TextBlock Text="CSS-ML WEBGL2  *  GPU TENSOR RUNTIME"
                           Foreground="#4db8ff" FontWeight="Bold" FontSize="12" Margin="0,0,0,6"/>
                <TextBlock Text="WebGL2 executor: GEMM, linear, and ReLU forward kernels. Backpropagation and AdamW currently use the CPU reference. The connected demo trains a small synthetic MNIST graph; it does not yet train the Gemma 3 300M checkpoint."
                           Foreground="#b9d9f2" FontSize="11" TextWrapping="Wrap"/>
                <TextBlock Text="Large checkpoint tensor sweeps remain available through the existing WebGL2 sweep route. The model catalog includes the 300M Gemma baseline and the larger GPT-2/Gemma/Qwen models."
                           Foreground="#07cc5e" FontSize="11" TextWrapping="Wrap" Margin="0,5,0,0"/>
                <ContentControl x:Name="CssMlWebViewHost" Height="430" Visibility="Collapsed" Margin="0,10,0,0"/>
              </StackPanel>
            </Border>

            <!-- D3D11 GPT-2 Section -->
            <Border Margin="0,0,0,8" Background="#0a1c10"
                    BorderBrush="#0aff76" BorderThickness="1" CornerRadius="6" Padding="12">
              <StackPanel>
                <TextBlock Text="D3D11 GPT-2 TRAINER  *  INTEL HD 4600"
                           Foreground="#0aff76" FontWeight="Bold" FontSize="12" Margin="0,0,0,10"/>
                <Grid>
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="90"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="80"/>
                    <ColumnDefinition Width="190"/>
                  </Grid.ColumnDefinitions>
                  <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                  </Grid.RowDefinitions>

                  <TextBlock Grid.Row="0" Grid.Column="0" Text="Preset" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,5"/>
                  <ComboBox x:Name="D3D11PresetBox" Grid.Row="0" Grid.Column="1" Height="26" Margin="0,0,8,5"
                            Style="{StaticResource GreenComboStyle}">
                    <ComboBoxItem Content="gpt2-small (124M, est 2166 MB)" IsSelected="True"/>
                    <ComboBoxItem Content="gpt2-medium (355M, Phase-1 CPU)"/>
                    <ComboBoxItem Content="gpt2-large  (774M, Phase-1 CPU)"/>
                    <ComboBoxItem Content="distilgpt2  (82M, Phase-3 GPU)"/>
                  </ComboBox>
                  <TextBlock Grid.Row="0" Grid.Column="2" Text="Steps" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,5"/>
                  <TextBox x:Name="D3D11StepsBox" Grid.Row="0" Grid.Column="3" Height="26" Text="10000"
                           Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"
                           Margin="0,0,0,5" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="1" Grid.Column="0" Text="Data bin" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,5"/>
                  <TextBox x:Name="D3D11DataBox" Grid.Row="1" Grid.Column="1" Height="26"
                           Text="E:\data\train\stack_phase1.bin"
                           Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"
                           Margin="0,0,8,5" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="1" Grid.Column="2" Text="Batch" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,5"/>
                  <TextBox x:Name="D3D11BatchBox" Grid.Row="1" Grid.Column="3" Height="26" Text="4"
                           Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"
                           Margin="0,0,0,5" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="2" Grid.Column="0" Text="Output" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,5"/>
                  <TextBox x:Name="D3D11OutputBox" Grid.Row="2" Grid.Column="1" Height="26"
                           Text="E:\models\GPT2\mini-GPT\stack-train\mini_stack_phase1.safetensors"
                           Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"
                           Margin="0,0,8,5" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="2" Grid.Column="2" Text="LR" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,5"/>
                  <TextBox x:Name="D3D11LrBox" Grid.Row="2" Grid.Column="3" Height="26" Text="2e-5"
                           Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"
                           Margin="0,0,0,5" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="3" Grid.Column="0" Text="Log file" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,0"/>
                  <TextBox x:Name="D3D11LogPathBox" Grid.Row="3" Grid.Column="1" Height="26"
                           Text="E:\models\GPT2\mini-GPT\stack-train\train_phase1.err"
                           Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"
                           Margin="0,0,8,0" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="3" Grid.Column="2" Text="Block / Save" Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,6,0"/>
                  <StackPanel Grid.Row="3" Grid.Column="3" Orientation="Horizontal">
                    <TextBox x:Name="D3D11BlockBox" Width="60" Height="26" Text="128"
                             Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"
                             VerticalContentAlignment="Center" Margin="0,0,6,0"/>
                    <TextBox x:Name="D3D11SaveEveryBox" Width="60" Height="26" Text="500"
                             Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"
                             VerticalContentAlignment="Center"/>
                  </StackPanel>
                </Grid>

                <!-- D3D11 action row -->
                <StackPanel Orientation="Horizontal" Margin="0,10,0,0">
                  <Button x:Name="D3D11Phase1Btn" Content="&#x25B6; PHASE 1  SCRATCH"
                          Style="{StaticResource GreenBtn}" Background="#0d4a1e"
                          Margin="0,0,8,0"/>
                  <Button x:Name="D3D11Phase2Btn" Content="&#x25B6; PHASE 2  FINE-TUNE"
                          Style="{StaticResource GreenBtn}"
                          Foreground="#a0ff60" BorderBrush="#a0ff60" Background="#1a380a"
                          Margin="0,0,8,0"/>
                  <Button x:Name="D3D11KillBtn" Content="&#x25FC; KILL D3D11"
                          Style="{StaticResource GreenBtn}"
                          Foreground="#ff5555" BorderBrush="#ff5555" Background="#3a0a0a"
                          Margin="0,0,16,0"/>
                  <TextBlock x:Name="D3D11ProcText" Text="" Foreground="#0aff76"
                             FontFamily="Consolas" FontSize="11" VerticalAlignment="Center"/>
                </StackPanel>

                <!-- Live log tail -->
                <TextBlock Text="LIVE LOG" Foreground="#07cc5e" FontSize="10"
                           FontWeight="Bold" Margin="0,12,0,4"/>
                <TextBox x:Name="D3D11LogTail" Height="130"
                         Background="#020e06" Foreground="#0aff76"
                         BorderBrush="#1a4a2e" BorderThickness="1"
                         FontFamily="Consolas" FontSize="11"
                         IsReadOnly="True" TextWrapping="NoWrap"
                         HorizontalScrollBarVisibility="Auto"
                         VerticalScrollBarVisibility="Auto"/>
              </StackPanel>
            </Border>

            <!-- Training parameters (existing) -->
            <Border Margin="0,0,0,8" Background="#0a1c10"
                    BorderBrush="#1a4a2e" BorderThickness="1" CornerRadius="6" Padding="12">
              <StackPanel>
                <TextBlock Text="TRAINING PARAMETERS  *  CSS-ML WebGL2 sweeps / Native / PyTorch"
                           Foreground="#07cc5e" FontWeight="Bold" FontSize="11" Margin="0,0,0,8"/>
                <Grid>
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="120"/>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="130"/>
                    <ColumnDefinition Width="220"/>
                  </Grid.ColumnDefinitions>
                  <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                  </Grid.RowDefinitions>

                  <TextBlock Grid.Row="0" Grid.Column="0" Text="Input model"    Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="InputBox"  Grid.Row="0" Grid.Column="1" Height="26" Margin="0,0,8,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="0" Grid.Column="2" Text="Browser"        Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <ComboBox  x:Name="BrowserBox" Grid.Row="0" Grid.Column="3" Height="26" Margin="0,0,0,5" Style="{StaticResource GreenComboStyle}">
                    <ComboBoxItem Content="auto" IsSelected="True"/>
                    <ComboBoxItem Content="edge"/>
                    <ComboBoxItem Content="chrome"/>
                  </ComboBox>

                  <TextBlock Grid.Row="1" Grid.Column="0" Text="Output model"   Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="OutputBox" Grid.Row="1" Grid.Column="1" Height="26" Margin="0,0,8,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="1" Grid.Column="2" Text="Tensor filter"  Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="TensorBox" Grid.Row="1" Grid.Column="3" Height="26" Margin="0,0,0,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="2" Grid.Column="0" Text="XJSL output"    Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="XjslOutBox" Grid.Row="2" Grid.Column="1" Height="26" Margin="0,0,8,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="2" Grid.Column="2" Text="Train dim"      Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="TrainDimBox" Grid.Row="2" Grid.Column="3" Height="26" Text="1024" Margin="0,0,0,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="3" Grid.Column="0" Text="Token bins"     Foreground="#07cc5e" FontSize="11" VerticalAlignment="Top" Margin="0,3,8,0"/>
                  <TextBox   x:Name="TokenBinsBox" Grid.Row="3" Grid.Column="1" Grid.RowSpan="2" Height="60" Margin="0,0,8,5"
                             AcceptsReturn="True" TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"
                             Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11"/>
                  <TextBlock Grid.Row="3" Grid.Column="2" Text="Batch"          Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="BatchBox"  Grid.Row="3" Grid.Column="3" Height="26" Text="16"   Margin="0,0,0,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="4" Grid.Column="2" Text="Steps"          Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="StepsBox"  Grid.Row="4" Grid.Column="3" Height="26" Text="300"  Margin="0,0,0,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="5" Grid.Column="0" Text="Learning rate"  Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="LrBox"     Grid.Row="5" Grid.Column="1" Height="26" Text="0.00035" Margin="0,0,8,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="5" Grid.Column="2" Text="Seed"           Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="SeedBox"   Grid.Row="5" Grid.Column="3" Height="26" Text="1337" Margin="0,0,0,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="6" Grid.Column="0" Text="Timeout ms"    Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="TimeoutBox" Grid.Row="6" Grid.Column="1" Height="26" Text="600000" Margin="0,0,8,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="6" Grid.Column="2" Text="Prog interval"  Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="ProgressIntervalBox" Grid.Row="6" Grid.Column="3" Height="26" Text="4" Margin="0,0,0,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="7" Grid.Column="0" Text="Block"          Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="BlockBox"  Grid.Row="7" Grid.Column="1" Height="26" Text="256"  Margin="0,0,8,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="7" Grid.Column="2" Text="Shards"         Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="NumShardsBox" Grid.Row="7" Grid.Column="3" Height="26" Text="6" Margin="0,0,0,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="8" Grid.Column="0" Text="Save every"    Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="SaveEveryBox" Grid.Row="8" Grid.Column="1" Height="26" Text="200" Margin="0,0,8,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="8" Grid.Column="2" Text="Shard every"   Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="ShardEveryBox" Grid.Row="8" Grid.Column="3" Height="26" Text="500" Margin="0,0,0,5" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>

                  <TextBlock Grid.Row="9" Grid.Column="0" Text="Max samples"   Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox   x:Name="MaxSamplesBox" Grid.Row="9" Grid.Column="1" Height="26" Margin="0,0,8,0" ToolTip="Blank = all" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="11" VerticalContentAlignment="Center"/>
                  <TextBlock Grid.Row="9" Grid.Column="2" Text="Tokenizer"     Foreground="#07cc5e" FontSize="11" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <ComboBox  x:Name="TokenizerBox" Grid.Row="9" Grid.Column="3" Height="26" Style="{StaticResource GreenComboStyle}">
                    <ComboBoxItem Content="word" IsSelected="True"/>
                    <ComboBoxItem Content="glyph"/>
                  </ComboBox>
                </Grid>
              </StackPanel>
            </Border>

            <!-- Action buttons -->
            <Border Margin="0,0,0,8" Background="#0a1c10"
                    BorderBrush="#1a4a2e" BorderThickness="1" CornerRadius="6" Padding="10">
              <StackPanel>
                <WrapPanel Orientation="Horizontal" Margin="0,0,0,6">
                  <TextBlock Text="TRAINING MODE" Foreground="#07cc5e" FontSize="11" FontWeight="Bold" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <ComboBox x:Name="TrainerModeBox" Width="340" Height="27" Margin="0,0,8,0" Style="{StaticResource GreenComboStyle}">
                    <ComboBoxItem Content="CSS-ML / WebGL2 model trainer" IsSelected="True"/>
                    <ComboBoxItem Content="PyTorch / OpenCL Gemma 3 300M"/>
                  </ComboBox>
                  <Button x:Name="RunTrainerModeBtn" Content="RUN SELECTED MODE" Background="#0d3a1a" Style="{StaticResource GreenBtn}"/>
                </WrapPanel>
                <WrapPanel Orientation="Horizontal" Margin="0,0,0,5">
                  <TextBlock Text="PyTorch output" Foreground="#07cc5e" FontSize="10" VerticalAlignment="Center" Margin="0,0,8,0"/>
                  <TextBox x:Name="GemmaOutputBox" Width="520" Height="25" Margin="0,0,10,0" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="10" VerticalContentAlignment="Center"/>
                  <TextBlock Text="Hours" Foreground="#07cc5e" FontSize="10" VerticalAlignment="Center" Margin="0,0,6,0"/>
                  <TextBox x:Name="GemmaHoursBox" Width="54" Height="25" Text="96" Background="#03120b" Foreground="#0aff76" BorderBrush="#1a4a2e" FontFamily="Consolas" FontSize="10" VerticalContentAlignment="Center"/>
                </WrapPanel>
                <TextBlock x:Name="TrainerScriptText" Text="CSS-ML script: .CSS-C demo + css-ml-runtime WebGL2 executor in WebView2"
                           Foreground="#b9d9f2" FontSize="10" TextWrapping="Wrap"/>
              </StackPanel>
            </Border>
            <Border Margin="0,0,0,8" Background="#0a1c10"
                    BorderBrush="#1a4a2e" BorderThickness="1" CornerRadius="6" Padding="10">
              <WrapPanel Orientation="Horizontal">
                <Button x:Name="HfTensorsBtn"   Content="WEBGL2 LARGE MODEL SWEEP" Margin="0,0,6,0" Background="#0d3a1a" Style="{StaticResource GreenBtn}" ToolTip="Run kuhul-es train-webgl2-sweep over the selected Safetensors model"/>
                <Button x:Name="StopBtn"        Content="STOP SESSION"      Margin="0,0,6,0" Background="#3a0a0a" Style="{StaticResource GreenBtn}" Foreground="#ff5555" BorderBrush="#ff5555"/>
                <Button x:Name="NativeGpuBtn"   Content="NATIVE GPU"        Margin="0,0,6,0" Background="#2a1060" Style="{StaticResource GreenBtn}" Foreground="#c084fc" BorderBrush="#c084fc"/>
                <Button x:Name="XShardBtn"      Content="XSHARD"            Margin="0,0,6,0" Background="#3a1f00" Style="{StaticResource GreenBtn}" Foreground="#F0883E" BorderBrush="#F0883E"/>
                <Button x:Name="PrepareFourBtn" Content="PREPARE 4 LANES"   Margin="0,0,6,0" Background="#1a0a40" Style="{StaticResource GreenBtn}" Foreground="#a571f7" BorderBrush="#a571f7" ToolTip="Register tool_call/memory/coder/chat FP16 hot-swap lanes"/>
                <Button x:Name="ClearLogBtn"    Content="CLEAR LOG"         Margin="0,0,0,0" Background="#0d2415" Style="{StaticResource GreenBtn}" Foreground="#07cc5e" BorderBrush="#07cc5e"/>
              </WrapPanel>
            </Border>

            <!-- Events log -->
            <Border Background="#020e06" BorderBrush="#1a4a2e" BorderThickness="1" CornerRadius="6" MinHeight="180">
              <Grid>
                <Grid.RowDefinitions>
                  <RowDefinition Height="30"/>
                  <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <Border Grid.Row="0" Background="#0a1c10" BorderBrush="#1a4a2e" BorderThickness="0,0,0,1" CornerRadius="6,6,0,0">
                  <TextBlock Text="EVENTS" Foreground="#0aff76" FontWeight="Bold" FontSize="11"
                             Margin="10,0,0,0" VerticalAlignment="Center"/>
                </Border>
                <ListBox x:Name="EventsList" Grid.Row="1" Margin="6,4,6,6"
                         Background="#020e06" Foreground="#0aff76"
                         BorderThickness="0" FontFamily="Consolas" FontSize="11"/>
              </Grid>
            </Border>

          </StackPanel>
        </ScrollViewer>
      </TabItem>

    </TabControl>

    <!-- ══ STATUS BAR ══════════════════════════════════════════════════════ -->
    <Border Grid.Row="2" Background="#0a1c10"
            BorderBrush="#0aff76" BorderThickness="0,1,0,0" Padding="12,0">
      <Grid>
        <TextBlock x:Name="StatusBarLeft"
                   Text="KUHUL TRAINER  *  CSS-ML WebGL2  *  HD 4600 D3D11  *  Native / PyTorch"
                   Foreground="#07cc5e" FontFamily="Consolas" FontSize="10"
                   VerticalAlignment="Center"/>
        <TextBlock x:Name="StatusBarRight"
                   Text="entropy=0.21  *  port 17474/8764/8776"
                   Foreground="#07cc5e" FontFamily="Consolas" FontSize="10"
                   VerticalAlignment="Center" HorizontalAlignment="Right"/>
      </Grid>
    </Border>

  </Grid>
</Window>
"@

# ── load XAML ─────────────────────────────────────────────────────────────────
$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# logo
$logoImage = $window.FindName('LogoImage')
$logoPath  = Join-Path $script:RepoRoot 'kuhulpi-micronaut.png'
if (Test-Path $logoPath) {
    try {
        $bmp = [System.Windows.Media.Imaging.BitmapImage]::new()
        $bmp.BeginInit()
        $bmp.UriSource  = [Uri]::new($logoPath, [System.UriKind]::Absolute)
        $bmp.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bmp.EndInit()
        $logoImage.Source = $bmp
    } catch {}
}

# header controls
$serverUrlBox        = $window.FindName('ServerUrlBox')
$serverDot           = $window.FindName('ServerDot')
$serverStatusText    = $window.FindName('ServerStatusText')
$checkServerBtn      = $window.FindName('CheckServerBtn')
$smokeBtn            = $window.FindName('SmokeBtn')
$d3d11StatusBadge    = $window.FindName('D3D11StatusBadge')
$sessionStatusText   = $window.FindName('SessionStatusText')
$statusBarLeft       = $window.FindName('StatusBarLeft')
$statusBarRight      = $window.FindName('StatusBarRight')
$modelCountText      = $window.FindName('ModelCountText')
$datasetCountText    = $window.FindName('DatasetCountText')

# panels
$modelsPanel   = $window.FindName('ModelsPanel')
$datasetsPanel = $window.FindName('DatasetsPanel')

# D3D11 controls
$d3d11PresetBox   = $window.FindName('D3D11PresetBox')
$d3d11DataBox     = $window.FindName('D3D11DataBox')
$d3d11OutputBox   = $window.FindName('D3D11OutputBox')
$d3d11LrBox       = $window.FindName('D3D11LrBox')
$d3d11StepsBox    = $window.FindName('D3D11StepsBox')
$d3d11BatchBox    = $window.FindName('D3D11BatchBox')
$d3d11BlockBox    = $window.FindName('D3D11BlockBox')
$d3d11SaveEveryBox = $window.FindName('D3D11SaveEveryBox')
$d3d11LogPathBox  = $window.FindName('D3D11LogPathBox')
$d3d11Phase1Btn   = $window.FindName('D3D11Phase1Btn')
$d3d11Phase2Btn   = $window.FindName('D3D11Phase2Btn')
$d3d11KillBtn     = $window.FindName('D3D11KillBtn')
$d3d11ProcText    = $window.FindName('D3D11ProcText')
$d3d11LogTail     = $window.FindName('D3D11LogTail')

# existing trainer controls
$inputBox            = $window.FindName('InputBox')
$outputBox           = $window.FindName('OutputBox')
$xjslOutBox          = $window.FindName('XjslOutBox')
$tokenBinsBox        = $window.FindName('TokenBinsBox')
$tensorBox           = $window.FindName('TensorBox')
$trainDimBox         = $window.FindName('TrainDimBox')
$batchBox            = $window.FindName('BatchBox')
$stepsBox            = $window.FindName('StepsBox')
$lrBox               = $window.FindName('LrBox')
$seedBox             = $window.FindName('SeedBox')
$browserBox          = $window.FindName('BrowserBox')
$timeoutBox          = $window.FindName('TimeoutBox')
$progressIntervalBox = $window.FindName('ProgressIntervalBox')
$blockBox            = $window.FindName('BlockBox')
$numShardsBox        = $window.FindName('NumShardsBox')
$saveEveryBox        = $window.FindName('SaveEveryBox')
$shardEveryBox       = $window.FindName('ShardEveryBox')
$maxSamplesBox       = $window.FindName('MaxSamplesBox')
$tokenizerBox        = $window.FindName('TokenizerBox')
$trainerModeBox      = $window.FindName('TrainerModeBox')
$runTrainerModeBtn   = $window.FindName('RunTrainerModeBtn')
$gemmaOutputBox      = $window.FindName('GemmaOutputBox')
$gemmaHoursBox       = $window.FindName('GemmaHoursBox')
$trainerScriptText   = $window.FindName('TrainerScriptText')
$cssMlWebViewHost    = $window.FindName('CssMlWebViewHost')
$stopBtn             = $window.FindName('StopBtn')
$nativeGpuBtn        = $window.FindName('NativeGpuBtn')
$xShardBtn           = $window.FindName('XShardBtn')
$hfTensorsBtn        = $window.FindName('HfTensorsBtn')
$prepareFourBtn      = $window.FindName('PrepareFourBtn')
$clearLogBtn         = $window.FindName('ClearLogBtn')
$eventsList          = $window.FindName('EventsList')

$script:GreenBrush  = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#0aff76')
$script:DimBrush    = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#07cc5e')
$script:OrangeBrush = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#F0883E')

# ── card builder ──────────────────────────────────────────────────────────────
function New-HolotapeCard {
    param(
        [string]   $Title,
        [string]   $Arch,
        [string[]] $Lines,
        [string[]] $Tags,
        [string]   $StatusNote,
        [string]   $StatusColor = '#3FB950',
        [string]   $TypeLabel   = 'MODEL',
        [double]   $CardWidth   = 296
    )
    $conv = [System.Windows.Media.BrushConverter]::new()

    $card = [System.Windows.Controls.Border]::new()
    $card.Width           = $CardWidth
    $card.Background      = $conv.ConvertFromString('#0a1c10')
    $card.BorderBrush     = $conv.ConvertFromString('#0aff76')
    $card.BorderThickness = [System.Windows.Thickness]::new(1)
    $card.CornerRadius    = [System.Windows.CornerRadius]::new(8)
    $card.Padding         = [System.Windows.Thickness]::new(14)
    $card.Margin          = [System.Windows.Thickness]::new(6)

    $root = [System.Windows.Controls.StackPanel]::new()

    # ── header row: dot * title * type badge ─────────────────────────────
    $hdrGrid = [System.Windows.Controls.Grid]::new()
    $c1 = [System.Windows.Controls.ColumnDefinition]::new()
    $c1.Width = [System.Windows.GridLength]::new(1, [System.Windows.GridUnitType]::Star)
    $c2 = [System.Windows.Controls.ColumnDefinition]::new()
    $c2.Width = [System.Windows.GridLength]::Auto
    # Cast to the exact WPF collection item types. Windows PowerShell 5.1's
    # method binder can otherwise fail to resolve Add() for these collections.
    [void]$hdrGrid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]$c1)
    [void]$hdrGrid.ColumnDefinitions.Add([System.Windows.Controls.ColumnDefinition]$c2)

    $titleRow = [System.Windows.Controls.StackPanel]::new()
    $titleRow.Orientation = [System.Windows.Controls.Orientation]::Horizontal

    $dot = [System.Windows.Shapes.Ellipse]::new()
    $dot.Width   = 9
    $dot.Height  = 9
    $dot.Fill    = $conv.ConvertFromString($StatusColor)
    $dot.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $dot.Margin  = [System.Windows.Thickness]::new(0,0,8,0)
    [void]$titleRow.Children.Add([System.Windows.UIElement]$dot)

    $titleTb = [System.Windows.Controls.TextBlock]::new()
    $titleTb.Text       = $Title
    $titleTb.Foreground = $conv.ConvertFromString('#0aff76')
    $titleTb.FontWeight = [System.Windows.FontWeights]::Bold
    $titleTb.FontSize   = 13
    $titleTb.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
    $titleTb.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    [void]$titleRow.Children.Add([System.Windows.UIElement]$titleTb)

    [System.Windows.Controls.Grid]::SetColumn($titleRow, 0)
    [void]$hdrGrid.Children.Add([System.Windows.UIElement]$titleRow)

    $badge = [System.Windows.Controls.Border]::new()
    $badge.BorderBrush     = $conv.ConvertFromString('#0aff76')
    $badge.BorderThickness = [System.Windows.Thickness]::new(1)
    $badge.CornerRadius    = [System.Windows.CornerRadius]::new(4)
    $badge.Padding         = [System.Windows.Thickness]::new(6,2,6,2)
    $badge.VerticalAlignment = [System.Windows.VerticalAlignment]::Center
    $badgeTb = [System.Windows.Controls.TextBlock]::new()
    $badgeTb.Text       = $TypeLabel
    $badgeTb.Foreground = $conv.ConvertFromString('#0aff76')
    $badgeTb.FontSize   = 10
    $badgeTb.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
    $badge.Child = $badgeTb
    [System.Windows.Controls.Grid]::SetColumn($badge, 1)
    [void]$hdrGrid.Children.Add([System.Windows.UIElement]$badge)
    [void]$root.Children.Add([System.Windows.UIElement]$hdrGrid)

    # arch / family subtitle
    if ($Arch) {
        $archTb = [System.Windows.Controls.TextBlock]::new()
        $archTb.Text       = $Arch
        $archTb.Foreground = $conv.ConvertFromString('#07cc5e')
        $archTb.FontSize   = 11
        $archTb.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
        $archTb.Margin     = [System.Windows.Thickness]::new(17,4,0,0)
        [void]$root.Children.Add([System.Windows.UIElement]$archTb)
    }

    # separator
    $sep = [System.Windows.Shapes.Rectangle]::new()
    $sep.Height = 1
    $sep.Fill   = $conv.ConvertFromString('#1a4a2e')
    $sep.Margin = [System.Windows.Thickness]::new(0,8,0,8)
    [void]$root.Children.Add([System.Windows.UIElement]$sep)

    # detail lines
    foreach ($ln in $Lines) {
        $lineTb = [System.Windows.Controls.TextBlock]::new()
        $lineTb.Text        = $ln
        $lineTb.Foreground  = $conv.ConvertFromString('#52cc80')
        $lineTb.FontSize    = 11
        $lineTb.FontFamily  = [System.Windows.Media.FontFamily]::new('Consolas')
        $lineTb.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $lineTb.Margin      = [System.Windows.Thickness]::new(0,1,0,1)
        [void]$root.Children.Add([System.Windows.UIElement]$lineTb)
    }

    # tags
    if ($Tags -and $Tags.Count -gt 0) {
        $tagWrap = [System.Windows.Controls.WrapPanel]::new()
        $tagWrap.Orientation = [System.Windows.Controls.Orientation]::Horizontal
        $tagWrap.Margin      = [System.Windows.Thickness]::new(0,8,0,0)
        foreach ($tag in $Tags) {
            $tb = [System.Windows.Controls.Border]::new()
            $tb.BorderBrush     = $conv.ConvertFromString('#0aff76')
            $tb.BorderThickness = [System.Windows.Thickness]::new(1)
            $tb.CornerRadius    = [System.Windows.CornerRadius]::new(4)
            $tb.Padding         = [System.Windows.Thickness]::new(6,2,6,2)
            $tb.Margin          = [System.Windows.Thickness]::new(0,0,4,4)
            $ttb = [System.Windows.Controls.TextBlock]::new()
            $ttb.Text       = $tag
            $ttb.Foreground = $conv.ConvertFromString('#0aff76')
            $ttb.FontSize   = 10
            $ttb.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
            $tb.Child = $ttb
            [void]$tagWrap.Children.Add([System.Windows.UIElement]$tb)
        }
        [void]$root.Children.Add([System.Windows.UIElement]$tagWrap)
    }

    # status note footer
    if ($StatusNote) {
        $noteBorder = [System.Windows.Controls.Border]::new()
        $noteBorder.Background  = $conv.ConvertFromString('#0d2415')
        $noteBorder.CornerRadius = [System.Windows.CornerRadius]::new(4)
        $noteBorder.Padding     = [System.Windows.Thickness]::new(8,4,8,4)
        $noteBorder.Margin      = [System.Windows.Thickness]::new(0,8,0,0)
        $noteTb = [System.Windows.Controls.TextBlock]::new()
        $noteTb.Text        = $StatusNote
        $noteTb.Foreground  = $conv.ConvertFromString($StatusColor)
        $noteTb.FontSize    = 10
        $noteTb.FontFamily  = [System.Windows.Media.FontFamily]::new('Consolas')
        $noteTb.TextWrapping = [System.Windows.TextWrapping]::Wrap
        $noteBorder.Child   = $noteTb
        [void]$root.Children.Add([System.Windows.UIElement]$noteBorder)
    }

    $card.Child = $root
    return $card
}

# ── populate model cards ──────────────────────────────────────────────────────
foreach ($m in $script:ModelCatalog) {
    $card = New-HolotapeCard `
        -Title       $m.Name `
        -Arch        $m.Arch `
        -Lines       $m.Lines `
        -Tags        $m.Tags `
        -StatusNote  $m.StatusNote `
        -StatusColor $m.StatusColor `
        -TypeLabel   $m.TypeLabel
    [void]$modelsPanel.Children.Add([System.Windows.UIElement]$card)
}
$modelCountText.Text = "$($script:ModelCatalog.Count) models registered"

# ── populate dataset cards ────────────────────────────────────────────────────
foreach ($d in $script:DatasetCatalog) {
    $shortFile = Split-Path $d.File -Leaf
    $card = New-HolotapeCard `
        -Title       $d.Name `
        -Arch        $shortFile `
        -Lines       $d.Lines `
        -Tags        $d.Tags `
        -StatusNote  $d.StatusNote `
        -StatusColor $d.StatusColor `
        -TypeLabel   $d.TypeLabel
    [void]$datasetsPanel.Children.Add([System.Windows.UIElement]$card)
}
$datasetCountText.Text = "$($script:DatasetCatalog.Count) datasets registered"

# ── UI helpers ────────────────────────────────────────────────────────────────
function Set-ServerStatus([string]$text, [string]$color) {
    $serverStatusText.Text = $text
    $safeColor = if ([string]::IsNullOrWhiteSpace($color)) { '#DA3633' } else { $color.Trim() }
    try {
        $brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($safeColor)
        if ($brush -is [System.Windows.Media.Brush]) { $serverDot.Fill = $brush; return }
    } catch {}
    $serverDot.Fill = [System.Windows.Media.Brushes]::OrangeRed
}

function Add-EventLog([string]$line) {
    $item = [System.Windows.Controls.ListBoxItem]::new()
    $item.Content    = $line
    $item.Foreground = $script:GreenBrush
    [void]$eventsList.Items.Add([object]$item)
    $eventsList.ScrollIntoView($item)
}

function Update-SessionStatusText([string]$status, [string]$sessionId, [string]$progressText) {
    $sessionStatusText.Text = "Session: $sessionId | $status | $progressText"
}

function Get-SelectedBrowser {
    if ($browserBox.SelectedItem -and $browserBox.SelectedItem.Content) {
        return $browserBox.SelectedItem.Content.ToString().Trim().ToLower()
    }
    return 'auto'
}

function Split-TokenBins([string]$raw) {
    if (-not $raw) { return @() }
    ($raw -split "[`r`n;,]") | ForEach-Object { $_.Trim() } | Where-Object { $_ } | Select-Object -Unique
}

function Quote-NativeArg([string]$value) {
    if ($null -eq $value) { return '""' }
    return '"' + ($value -replace '\\(?=\\*")', '$0' -replace '"', '\"') + '"'
}

function Get-NativeOutputPath([string]$inputPath, [string]$outputPath) {
    if ($outputPath -and $outputPath -like '*.webgl2.dashboard.safetensors') { return $outputPath }
    $dir  = [System.IO.Path]::GetDirectoryName($inputPath)
    $name = [System.IO.Path]::GetFileNameWithoutExtension($inputPath)
    if ($outputPath -and [string]::IsNullOrWhiteSpace([System.IO.Path]::GetExtension($outputPath))) {
        return [System.IO.Path]::Combine($outputPath, "$name.native_gpu.dashboard.safetensors")
    }
    return [System.IO.Path]::Combine($dir, "$name.native_gpu.dashboard.safetensors")
}

function Get-XShardOutputPath([string]$inputPath, [string]$outputPath) {
    if ($outputPath -and $outputPath -like '*.xshard') { return $outputPath }
    if ($outputPath -and [string]::IsNullOrWhiteSpace([System.IO.Path]::GetExtension($outputPath))) {
        return [System.IO.Path]::Combine($outputPath, "$(([System.IO.Path]::GetFileNameWithoutExtension($inputPath))).dashboard.trained.xshard")
    }
    $dir  = [System.IO.Path]::GetDirectoryName($inputPath)
    return [System.IO.Path]::Combine($dir, "$(([System.IO.Path]::GetFileNameWithoutExtension($inputPath))).dashboard.trained.xshard")
}

function Get-HfTensorOutputPath([string]$inputPath, [string]$outputPath) {
    if ($outputPath -and $outputPath -like '*.safetensors') { return $outputPath }
    if ($outputPath -and [string]::IsNullOrWhiteSpace([System.IO.Path]::GetExtension($outputPath))) {
        return [System.IO.Path]::Combine($outputPath, "$(([System.IO.Path]::GetFileNameWithoutExtension($inputPath))).hf_tensors.dashboard.safetensors")
    }
    $dir  = [System.IO.Path]::GetDirectoryName($inputPath)
    return [System.IO.Path]::Combine($dir, "$(([System.IO.Path]::GetFileNameWithoutExtension($inputPath))).hf_tensors.dashboard.safetensors")
}

function Invoke-JsonApi {
    param([string]$Method, [string]$Url, [object]$Body = $null, [int]$TimeoutSec = 30)
    if ($null -ne $Body) {
        return Invoke-RestMethod -Method $Method -Uri $Url -Body ($Body | ConvertTo-Json -Depth 12) -ContentType 'application/json' -TimeoutSec $TimeoutSec
    }
    return Invoke-RestMethod -Method $Method -Uri $Url -TimeoutSec $TimeoutSec
}

function Test-KuhulServer {
    $baseUrl = $serverUrlBox.Text.Trim().TrimEnd('/')
    if (-not $baseUrl) { Set-ServerStatus 'MISSING URL' '#DA3633'; return $false }
    try {
        $h = Invoke-JsonApi -Method 'GET' -Url "$baseUrl/health" -TimeoutSec 5
        if ($h.status -eq 'ok') { Set-ServerStatus "ONLINE pid=$($h.pid)" '#0aff76' }
        else                     { Set-ServerStatus 'REACHABLE' '#F0883E' }
        return $true
    } catch {
        Set-ServerStatus "OFFLINE: $($_.Exception.Message.Split([char]10)[0])" '#DA3633'
        return $false
    }
}

function Build-StartPayload {
    $inputPath  = $inputBox.Text.Trim()
    $outputPath = $outputBox.Text.Trim()
    if (-not $inputPath)  { throw 'Input model path is required.' }
    if (-not $outputPath) { throw 'Output model path is required.' }
    if ([string]::IsNullOrWhiteSpace([System.IO.Path]::GetExtension($outputPath))) {
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($inputPath) -replace '\.webgl2\.dashboard$',''
        $outputPath = Join-Path $outputPath ($stem + '.webgl2.dashboard.safetensors')
    }
    $payload = @{
        input             = $inputPath
        output            = $outputPath
        tensor            = $tensorBox.Text.Trim()
        xjsl_out          = $xjslOutBox.Text.Trim()
        train_dim         = [int]$trainDimBox.Text.Trim()
        batch             = [int]$batchBox.Text.Trim()
        steps             = [int]$stepsBox.Text.Trim()
        lr                = [double]$lrBox.Text.Trim()
        seed              = [int]$seedBox.Text.Trim()
        browser           = Get-SelectedBrowser
        timeout_ms        = [int]$timeoutBox.Text.Trim()
        progress_interval = [int]$progressIntervalBox.Text.Trim()
    }
    $bins = Split-TokenBins $tokenBinsBox.Text
    if ($bins.Count -gt 0) { $payload.token_bins = $bins }
    if (-not $payload.tensor)   { $null = $payload.Remove('tensor') }
    if (-not $payload.xjsl_out) { $null = $payload.Remove('xjsl_out') }
    return $payload
}

function Format-EventStamp([object]$stampRaw) {
    if ($null -eq $stampRaw) { return (Get-Date).ToString('MM/dd HH:mm:ss.fff') }
    if ($stampRaw -is [datetime]) { return $stampRaw.ToString('MM/dd HH:mm:ss.fff') }
    try { return ([datetime][string]$stampRaw).ToString('MM/dd HH:mm:ss.fff') } catch { return [string]$stampRaw }
}

function Format-EventLine([object]$evt) {
    $stamp = Format-EventStamp $evt.timestamp
    $name  = if ($evt.event) { [string]$evt.event } else { 'event' }
    switch ($name) {
        'progress'       { return "[$stamp] progress step=$($evt.step)/$($evt.steps) $($evt.percent)%" }
        'browser_launch' { return "[$stamp] browser_launch requested=$($evt.requested_browser) actual=$($evt.browser)" }
        'result'         { return "[$stamp] result loss=$($evt.loss_before)->$($evt.loss_after) gpu_ms=$($evt.gpu_ms) output=$($evt.output)" }
        'finalizing'     { return "[$stamp] finalizing output=$($evt.output) size=$([math]::Round($evt.output_bytes/1MB,2))MB" }
        'error'          { return "[$stamp] ERROR $($evt.message)" }
        'session_started'{ return "[$stamp] session_started pid=$($evt.pid)" }
        'session_exit'   { return "[$stamp] session_exit code=$($evt.exit_code)" }
        default          { return "[$stamp] $name" }
    }
}

# ── D3D11 trainer ─────────────────────────────────────────────────────────────
function Get-D3D11ModelArg {
    $sel = $d3d11PresetBox.SelectedItem
    if ($sel -and $sel.Content) {
        $txt = $sel.Content.ToString()
        if ($txt -match '^(gpt2-small|gpt2-medium|gpt2-large|distilgpt2)') { return $Matches[1] }
    }
    # fallback: treat input box as safetensors path
    return $inputBox.Text.Trim()
}

function Start-D3D11Training([string]$phase) {
    if (-not (Test-Path $script:D3D11TrainerExe)) { throw "gpt2_trainer.exe not found: $($script:D3D11TrainerExe)" }
    $modelArg   = Get-D3D11ModelArg
    $dataPath   = $d3d11DataBox.Text.Trim()
    $outPath    = $d3d11OutputBox.Text.Trim()
    $steps      = [int]$d3d11StepsBox.Text.Trim()
    $batch      = [int]$d3d11BatchBox.Text.Trim()
    $lr         = $d3d11LrBox.Text.Trim()
    $block      = [int]$d3d11BlockBox.Text.Trim()
    $saveEvery  = [int]$d3d11SaveEveryBox.Text.Trim()
    $logFile    = $d3d11LogPathBox.Text.Trim()

    if ($phase -eq 'phase2') {
        $lr        = '1e-5'
        $steps     = [math]::Min($steps, 2000)
        $d3d11LrBox.Text = $lr
        $d3d11StepsBox.Text = [string]$steps
        $outPath = $outPath -replace 'phase1','phase2'
        $d3d11OutputBox.Text = $outPath
        $dataPath = $d3d11DataBox.Text -replace 'stack_phase1','stack_phase2'
        $d3d11DataBox.Text = $dataPath
        $logFile  = $logFile -replace 'phase1','phase2'
        $d3d11LogPathBox.Text = $logFile
    }

    if (-not $dataPath)  { throw 'D3D11: Data bin path is required.' }
    if (-not $outPath)   { throw 'D3D11: Output path is required.' }
    if (-not (Test-Path $dataPath)) { throw "D3D11: Data bin not found: $dataPath" }

    # ensure output directory exists
    $outDir = [System.IO.Path]::GetDirectoryName($outPath)
    if ($outDir -and -not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir -Force | Out-Null }
    if ($logFile -and $logFile -ne '') {
        $logDir = [System.IO.Path]::GetDirectoryName($logFile)
        if ($logDir -and -not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }
    }

    $argList = @('--model', $modelArg, '--data', $dataPath, '--out', $outPath,
                 '--steps', [string]$steps, '--batch', [string]$batch,
                 '--lr', $lr, '--block', [string]$block, '--save-every', [string]$saveEvery)
    if ($phase -eq 'phase2') { $argList += '--completion-only' }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName         = $script:D3D11TrainerExe
    $psi.Arguments        = $argList -join ' '
    $psi.WorkingDirectory = $script:D3D11WorkDir
    $psi.UseShellExecute          = $false
    $psi.RedirectStandardOutput   = $true
    $psi.RedirectStandardError    = $true
    $psi.CreateNoWindow           = $true

    $proc = [System.Diagnostics.Process]::new()
    $proc.StartInfo          = $psi
    $proc.EnableRaisingEvents = $true

    $outputAction = {
        if ($EventArgs.Data) {
            $line = $EventArgs.Data
            $window.Dispatcher.BeginInvoke([Action[string]]{
                param($l)
                Add-EventLog ("[D3D11] $l")
            }, $line) | Out-Null
        }
    }
    Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action $outputAction | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived  -Action $outputAction | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName Exited -Action {
        $code = $Event.Sender.ExitCode
        $window.Dispatcher.BeginInvoke([Action[int]]{
            param($ec)
            $script:D3D11Process = $null
            $d3d11StatusBadge.Text = "D3D11: EXIT $ec"
            $d3d11ProcText.Text    = ''
            Add-EventLog ("[D3D11] session_exit code=$ec")
        }, $code) | Out-Null
    } | Out-Null

    if (-not $proc.Start()) { throw 'D3D11: Failed to start gpt2_trainer.exe' }
    $proc.BeginOutputReadLine()
    $proc.BeginErrorReadLine()
    $script:D3D11Process   = $proc
    $d3d11StatusBadge.Text = "D3D11: RUNNING PID $($proc.Id)"
    $d3d11ProcText.Text    = "pid=$($proc.Id)  $phase"
    Add-EventLog ("[D3D11] started pid=$($proc.Id) model=$modelArg data=$dataPath steps=$steps lr=$lr $phase")
}

# D3D11 log tail refresh
function Update-D3D11LogTail {
    $logPath = $d3d11LogPathBox.Text.Trim()
    if (-not $logPath -or -not (Test-Path $logPath)) { return }
    try {
        $lines = Get-Content $logPath -Tail 20 -Encoding UTF8 -ErrorAction SilentlyContinue
        if ($lines) { $d3d11LogTail.Text = ($lines -join [Environment]::NewLine) }
        # update badge with last step if found
        $lastStep = $lines | Select-String 'step=(\d+)' | Select-Object -Last 1
        if ($lastStep -and $script:D3D11Process -and -not $script:D3D11Process.HasExited) {
            $d3d11StatusBadge.Text = "D3D11: STEP $($lastStep.Matches[0].Groups[1].Value)"
        }
    } catch {}
}

# ── native GPU training ───────────────────────────────────────────────────────
function Start-NativeGpuTraining {
    $inputPath = $inputBox.Text.Trim()
    if (-not $inputPath) { throw 'Input model path is required.' }
    if (-not (Test-Path $inputPath)) { throw "Input model not found: $inputPath" }
    if (-not (Test-Path $script:KuhulEsCli)) { throw "kuhul-es CLI not found: $($script:KuhulEsCli)" }
    $bins = @(Split-TokenBins $tokenBinsBox.Text)
    if ($bins.Count -lt 1) { throw 'At least one token bin required.' }
    $dataPath = $bins[0]
    if (-not (Test-Path $dataPath)) { throw "Token bin not found: $dataPath" }
    $nativeOut = Get-NativeOutputPath $inputPath $outputBox.Text.Trim()
    $steps = [int]$stepsBox.Text.Trim()
    $lr    = [double]$lrBox.Text.Trim()
    $args  = @(
        (Quote-NativeArg $script:KuhulEsCli)
        'train-native'
        '--model', (Quote-NativeArg $inputPath)
        '--data',  (Quote-NativeArg $dataPath)
        '--out',   (Quote-NativeArg $nativeOut)
        '--steps', [string]$steps
        '--batch', '1'
        '--block', '128'
        '--lr',    [string]$lr
        '--save-every', [string]([Math]::Max(1,[Math]::Min($steps,200)))
        '--gpu-fwd','--fullseq','--think-bias','--gravity-sync'
    )
    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName = 'node.exe'; $psi.Arguments = ($args -join ' ')
    $psi.WorkingDirectory = $script:RepoRoot
    $psi.UseShellExecute = $false; $psi.RedirectStandardOutput = $true; $psi.RedirectStandardError = $true; $psi.CreateNoWindow = $true
    $proc = [System.Diagnostics.Process]::new(); $proc.StartInfo = $psi; $proc.EnableRaisingEvents = $true
    Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action { if ($EventArgs.Data) { $window.Dispatcher.BeginInvoke([Action[string]]{ param($l); Add-EventLog("[native] $l") }, $EventArgs.Data) | Out-Null } } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived  -Action { if ($EventArgs.Data) { $window.Dispatcher.BeginInvoke([Action[string]]{ param($l); Add-EventLog("[native-err] $l") }, $EventArgs.Data) | Out-Null } } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName Exited -Action { $c=$Event.Sender.ExitCode; $window.Dispatcher.BeginInvoke([Action[int]]{ param($ec); $script:NativeProcess=$null; Add-EventLog("[native] exit $ec") }, $c) | Out-Null } | Out-Null
    if (-not $proc.Start()) { throw 'Failed to start native trainer.' }
    $proc.BeginOutputReadLine(); $proc.BeginErrorReadLine()
    $script:NativeProcess = $proc
    Update-SessionStatusText -status 'running' -sessionId 'native-gpu' -progressText "pid=$($proc.Id)"
    Add-EventLog("[native] started pid=$($proc.Id) data=$dataPath out=$nativeOut")
}

function Start-XShardTraining {
    $inputPath = $inputBox.Text.Trim()
    if (-not $inputPath) { throw 'Input model path is required.' }
    if ([System.IO.Path]::GetExtension($inputPath).ToLowerInvariant() -ne '.xshard') { throw 'XSHARD requires a prepared .xshard input.' }
    if (-not (Test-Path $inputPath)) { throw "Input XSHARD not found: $inputPath" }
    if (-not (Test-Path $script:KuhulEsCli)) { throw "kuhul-es CLI not found: $($script:KuhulEsCli)" }
    $bins = @(Split-TokenBins $tokenBinsBox.Text); if ($bins.Count -lt 1) { throw 'Token bin required.' }
    $dataPath = $bins[0]; if (-not (Test-Path $dataPath)) { throw "Token bin not found: $dataPath" }
    $xshardOut = Get-XShardOutputPath $inputPath $outputBox.Text.Trim()
    $workDir   = [System.IO.Path]::GetDirectoryName($xshardOut)
    if (-not $workDir) { $workDir = $script:RepoRoot }
    $args = @( (Quote-NativeArg $script:KuhulEsCli),'train-xshard','--input',(Quote-NativeArg $inputPath),'--token-bin',(Quote-NativeArg $dataPath),'--output',(Quote-NativeArg $xshardOut),'--steps',([string][int]$stepsBox.Text.Trim()),'--max-shards','1','--lr',([string][double]$lrBox.Text.Trim()),'--work-dir',(Quote-NativeArg $workDir) )
    $psi = [System.Diagnostics.ProcessStartInfo]::new(); $psi.FileName='node.exe'; $psi.Arguments=($args -join ' '); $psi.WorkingDirectory=$script:RepoRoot; $psi.UseShellExecute=$false; $psi.RedirectStandardOutput=$true; $psi.RedirectStandardError=$true; $psi.CreateNoWindow=$true
    $proc = [System.Diagnostics.Process]::new(); $proc.StartInfo=$psi; $proc.EnableRaisingEvents=$true
    Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action { if ($EventArgs.Data) { $window.Dispatcher.BeginInvoke([Action[string]]{ param($l); Add-EventLog("[xshard] $l") }, $EventArgs.Data) | Out-Null } } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived  -Action { if ($EventArgs.Data) { $window.Dispatcher.BeginInvoke([Action[string]]{ param($l); Add-EventLog("[xshard-err] $l") }, $EventArgs.Data) | Out-Null } } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName Exited -Action { $c=$Event.Sender.ExitCode; $window.Dispatcher.BeginInvoke([Action[int]]{ param($ec); $script:NativeProcess=$null; Add-EventLog("[xshard] exit $ec") }, $c) | Out-Null } | Out-Null
    if (-not $proc.Start()) { throw 'Failed to start XSHARD trainer.' }
    $proc.BeginOutputReadLine(); $proc.BeginErrorReadLine()
    $script:NativeProcess = $proc
    Update-SessionStatusText -status 'running' -sessionId 'xshard' -progressText "pid=$($proc.Id)"
    Add-EventLog("[xshard] started pid=$($proc.Id) data=$dataPath out=$xshardOut")
}

function Start-HfTensorSweep {
    $inputPath = $inputBox.Text.Trim()
    if (-not $inputPath) { throw 'Input safetensors path is required.' }
    if (-not (Test-Path $inputPath)) { throw "Input not found: $inputPath" }
    if (-not (Test-Path $script:KuhulEsCli)) { throw "kuhul-es CLI not found: $($script:KuhulEsCli)" }
    $sweepWrapper = Join-Path $script:KuhulEsRoot 'runtime\src\webgl2_hf_safetensor_trainer.cjs'
    $expectedSweepImpl = Join-Path (Split-Path $script:KuhulEsRoot -Parent) 'kuhul-runtime-v1\trainer\webgl2_hf_safetensor_trainer.cjs'
    if (-not (Test-Path -LiteralPath $sweepWrapper -PathType Leaf)) { throw "WebGL2 sweep wrapper missing: $sweepWrapper" }
    if (-not (Test-Path -LiteralPath $expectedSweepImpl -PathType Leaf)) {
        throw "WebGL2 sweep implementation missing: $expectedSweepImpl. The kuhul-es CLI is present, but its wrapper has no trainer implementation to launch."
    }
    $bins = @(Split-TokenBins $tokenBinsBox.Text); if ($bins.Count -lt 1) { throw 'Token bin required.' }
    $dataPath = $bins[0]; if (-not (Test-Path $dataPath)) { throw "Token bin not found: $dataPath" }
    $hfOut  = Get-HfTensorOutputPath $inputPath $outputBox.Text.Trim()
    $filter = $tensorBox.Text.Trim(); if (-not $filter) { $filter = '\.weight$' }
    $args   = @( (Quote-NativeArg $script:KuhulEsCli),'train-webgl2-sweep','--input',(Quote-NativeArg $inputPath),'--output',(Quote-NativeArg $hfOut),'--token-bin',(Quote-NativeArg $dataPath),'--tensor-filter',(Quote-NativeArg $filter),'--all-tensors','--train-dim',([string][int]$trainDimBox.Text.Trim()),'--steps-per-tensor',([string][int]$stepsBox.Text.Trim()),'--batch',([string][int]$batchBox.Text.Trim()),'--lr',([string][double]$lrBox.Text.Trim()),'--seed',([string][int]$seedBox.Text.Trim()),'--browser',(Get-SelectedBrowser),'--timeout-ms',([string][int]$timeoutBox.Text.Trim()),'--progress-interval',([string][int]$progressIntervalBox.Text.Trim()) )
    $psi = [System.Diagnostics.ProcessStartInfo]::new(); $psi.FileName='node.exe'; $psi.Arguments=($args -join ' '); $psi.WorkingDirectory=$script:RepoRoot; $psi.UseShellExecute=$false; $psi.RedirectStandardOutput=$true; $psi.RedirectStandardError=$true; $psi.CreateNoWindow=$true
    $proc = [System.Diagnostics.Process]::new(); $proc.StartInfo=$psi; $proc.EnableRaisingEvents=$true
    Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action { if ($EventArgs.Data) { $window.Dispatcher.BeginInvoke([Action[string]]{ param($l); Add-EventLog("[hf] $l") }, $EventArgs.Data) | Out-Null } } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived  -Action { if ($EventArgs.Data) { $window.Dispatcher.BeginInvoke([Action[string]]{ param($l); Add-EventLog("[hf-err] $l") }, $EventArgs.Data) | Out-Null } } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName Exited -Action { $c=$Event.Sender.ExitCode; $window.Dispatcher.BeginInvoke([Action[int]]{ param($ec); $script:NativeProcess=$null; Add-EventLog("[hf] exit $ec") }, $c) | Out-Null } | Out-Null
    if (-not $proc.Start()) { throw 'Failed to start HF tensor sweep.' }
    $proc.BeginOutputReadLine(); $proc.BeginErrorReadLine()
    $script:NativeProcess = $proc
    Update-SessionStatusText -status 'running' -sessionId 'hf-tensors' -progressText "pid=$($proc.Id) filter=$filter"
    Add-EventLog("[hf] started pid=$($proc.Id) data=$dataPath out=$hfOut")
}

function Start-PyTorchTraining {
    if (-not (Test-Path -LiteralPath $script:GemmaScratchTrainer -PathType Leaf)) { throw "PyTorch Gemma trainer not found: $($script:GemmaScratchTrainer)" }
    if (-not (Test-Path -LiteralPath $script:GemmaTokenBin -PathType Leaf)) { throw "Gemma token bin not found: $($script:GemmaTokenBin)" }
    if (-not (Test-Path -LiteralPath (Join-Path $script:GemmaBaselineDir 'tokenizer.json') -PathType Leaf)) { throw "Gemma 300M baseline/tokenizer not found: $($script:GemmaBaselineDir)" }
    $hours = 0.0
    if (-not [double]::TryParse($gemmaHoursBox.Text.Trim(), [ref]$hours) -or $hours -le 0) { throw 'Training hours must be a positive number.' }
    $runOutput = $gemmaOutputBox.Text.Trim()
    if (-not $runOutput) { throw 'Choose a PyTorch output directory.' }
    if (-not [System.IO.Path]::IsPathRooted($runOutput)) { $runOutput = Join-Path $script:RepoRoot $runOutput }
    $python = (Get-Command 'python.exe' -ErrorAction Stop).Source
    $pyArgs = @(
        (Quote-NativeArg $script:GemmaScratchTrainer),
        '--tokens', (Quote-NativeArg $script:GemmaTokenBin),
        '--tokenizer-dir', (Quote-NativeArg $script:GemmaBaselineDir),
        '--model-config', (Quote-NativeArg (Join-Path $script:GemmaBaselineDir 'config.json')),
        '--output', (Quote-NativeArg $runOutput),
        '--max-hours', ([string]$hours),
        '--checkpoint-every', '1000',
        '--model-preset', '300m',
        '--sequence-length', '32',
        '--optimizer-backend', 'opencl',
        '--threads', '4',
        '--initialize-from', (Quote-NativeArg $script:GemmaBaselineDir)
    )
    $psi = [System.Diagnostics.ProcessStartInfo]::new(); $psi.FileName=$python; $psi.Arguments=($pyArgs -join ' '); $psi.WorkingDirectory=$script:RepoRoot; $psi.UseShellExecute=$false; $psi.RedirectStandardOutput=$true; $psi.RedirectStandardError=$true; $psi.CreateNoWindow=$true
    $proc = [System.Diagnostics.Process]::new(); $proc.StartInfo=$psi; $proc.EnableRaisingEvents=$true
    Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action { if ($EventArgs.Data) { $window.Dispatcher.BeginInvoke([Action[string]]{ param($l); Add-EventLog("[pytorch-opencl] $l") }, $EventArgs.Data) | Out-Null } } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived  -Action { if ($EventArgs.Data) { $window.Dispatcher.BeginInvoke([Action[string]]{ param($l); Add-EventLog("[pytorch-opencl-err] $l") }, $EventArgs.Data) | Out-Null } } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName Exited -Action { $c=$Event.Sender.ExitCode; $window.Dispatcher.BeginInvoke([Action[int]]{ param($ec); $script:NativeProcess=$null; Add-EventLog("[pytorch-opencl] exit $ec") }, $c) | Out-Null } | Out-Null
    if (-not $proc.Start()) { throw 'Failed to start PyTorch/OpenCL Gemma trainer.' }
    $proc.BeginOutputReadLine(); $proc.BeginErrorReadLine()
    $script:NativeProcess = $proc
    Update-SessionStatusText -status 'running' -sessionId 'pytorch-gemma3-300m' -progressText "pid=$($proc.Id)"
    Add-EventLog("[pytorch-opencl] started pid=$($proc.Id) baseline=$($script:GemmaBaselineDir) output=$runOutput hours=$hours checkpoint_every=1000")
}

function Set-CssMlHostMessage([string]$message) {
    $text = [System.Windows.Controls.TextBlock]::new()
    $text.Text = $message
    $text.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#ffb86b')
    $text.FontFamily = [System.Windows.Media.FontFamily]::new('Consolas')
    $text.FontSize = 11
    $text.TextWrapping = [System.Windows.TextWrapping]::Wrap
    $text.Margin = [System.Windows.Thickness]::new(8)
    $cssMlWebViewHost.Content = $text
    $cssMlWebViewHost.Visibility = [System.Windows.Visibility]::Visible
}

function Show-CssMlTrainer {
    if (-not $script:WebView2Available) { throw $script:WebView2Status }
    if (-not $script:CssMlWebView) {
        $control = [Microsoft.Web.WebView2.Wpf.WebView2]::new()
        $control.HorizontalAlignment = [System.Windows.HorizontalAlignment]::Stretch
        $control.VerticalAlignment = [System.Windows.VerticalAlignment]::Stretch
        $control.CreationProperties = [Microsoft.Web.WebView2.Wpf.CoreWebView2CreationProperties]::new()
        $control.CreationProperties.UserDataFolder = Join-Path $env:LOCALAPPDATA 'Micronaut\TrainerWebView2'
        $control.CreationProperties.AdditionalBrowserArguments = '--disable-background-timer-throttling --disable-renderer-backgrounding'
        $script:CssMlWebView = $control
        $cssMlWebViewHost.Content = $control
        $cssRoot = Join-Path $script:RepoRoot '.CSS-C'
        $control.Add_Loaded(({
            $view = $this
            if ($view.CoreWebView2) {
                $view.CoreWebView2.Navigate('https://cssml.local/demo/gsnr-universe.html#css-gemm-card')
                return
            }
            $initTask = $view.EnsureCoreWebView2Async($null)
            $initTimer = [System.Windows.Threading.DispatcherTimer]::new()
            $initTimer.Interval = [TimeSpan]::FromMilliseconds(100)
            $initTimer.Add_Tick(({
                if (-not $initTask.IsCompleted) { return }
                $initTimer.Stop()
                if ($initTask.IsFaulted) {
                    Set-CssMlHostMessage "WebView2 initialization failed: $($initTask.Exception.GetBaseException().Message)"
                    return
                }
                try {
                    $view.CoreWebView2.SetVirtualHostNameToFolderMapping(
                        'cssml.local', $cssRoot,
                        [Microsoft.Web.WebView2.Core.CoreWebView2HostResourceAccessKind]::Allow
                    )
                    $view.CoreWebView2.add_WebMessageReceived({
                        param($sender, $eventArgs)
                        try {
                            $raw = [string]$eventArgs.TryGetWebMessageAsString()
                            if ($raw.Length -gt 2048) { return }
                            $message = $raw | ConvertFrom-Json -ErrorAction Stop
                            if ($message.source -eq 'css-gemm' -and $message.type -eq 'trainer.completed') {
                                Add-EventLog("[css-ml] $($message.renderer) · $($message.steps) step(s) · loss=$($message.loss) · synthetic samples=$($message.samples)")
                            }
                        } catch { }
                    })
                    $view.CoreWebView2.Navigate('https://cssml.local/demo/gsnr-universe.html#css-gemm-card')
                    Add-EventLog('[css-ml] WebView2 mapped cssml.local to the local .CSS-C runtime')
                } catch {
                    Set-CssMlHostMessage "CSS-ML page setup failed: $($_.Exception.Message)"
                }
            }).GetNewClosure())
            $initTimer.Start()
        }).GetNewClosure())
    } else {
        $cssMlWebViewHost.Content = $script:CssMlWebView
        if ($script:CssMlWebView.CoreWebView2) {
            $script:CssMlWebView.CoreWebView2.Navigate('https://cssml.local/demo/gsnr-universe.html#css-gemm-card')
        }
    }
    $cssMlWebViewHost.Visibility = [System.Windows.Visibility]::Visible
    $cssMlWebViewHost.BringIntoView()
    Add-EventLog('[css-ml] in-app WebGL2 demo opened; press TRAIN MODEL inside the page to run its demo graph')
}

function Get-SelectedTrainerMode {
    if ($trainerModeBox.SelectedItem -and $trainerModeBox.SelectedItem.Content) {
        return [string]$trainerModeBox.SelectedItem.Content
    }
    return 'CSS-ML / WebGL2 checkpoint sweep'
}

function Update-TrainerModeDescription {
    $mode = Get-SelectedTrainerMode
    if ($mode -like 'PyTorch*') {
        $trainerScriptText.Text = "Script: $($script:GemmaScratchTrainer) · 300M warm-start · CPU forward/backward + OpenCL AdamW"
        $trainerScriptText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#ffb86b')
        $cssMlWebViewHost.Visibility = [System.Windows.Visibility]::Collapsed
    } else {
        $trainerScriptText.Text = "WebView2: .CSS-C/demo/gsnr-universe.html · CSS-ML synthetic graph · WebGL2 forward kernels + CPU backprop/AdamW"
        $trainerScriptText.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString('#b9d9f2')
        $cssMlWebViewHost.Visibility = [System.Windows.Visibility]::Collapsed
    }
}

function Start-SelectedTrainerMode {
    if ($script:NativeProcess -and -not $script:NativeProcess.HasExited) {
        throw "A trainer process is already running (pid=$($script:NativeProcess.Id))."
    }
    $mode = Get-SelectedTrainerMode
    if ($mode -like 'PyTorch*') {
        $cssMlWebViewHost.Visibility = [System.Windows.Visibility]::Collapsed
        Start-PyTorchTraining
    } else {
        Show-CssMlTrainer
    }
}

function Prepare-FourMicronautLanes {
    $baseModel       = 'E:\models\GPT2\coder_micronaut\ultrachat_coder_slerp_0p35.webgl2.dashboard.safetensors'
    $toolCallModel   = 'E:\models\GPT2\mini-GPT\gpt2_small_lite_tool.webgl2.safetensors'
    $resumeCheckpoint= 'E:\models\GPT2\model_fp32.pt'
    $sources         = @('E:\models\GPT2\coder_micronaut\coder_ast_json_seq256_tokens.bin')
    foreach ($p in @($baseModel,$toolCallModel,$resumeCheckpoint)+$sources) {
        if (-not (Test-Path $p)) { throw "Four-lane input not found: $p" }
    }
    $laneRoot     = 'E:\models\GPT2\micronaut_four_lanes_v2'
    $manifestPath = Join-Path $laneRoot 'four-lane-manifest.json'
    New-Item -ItemType Directory -Path $laneRoot -Force | Out-Null
    $lanes = @('tool_call','memory','coder','chat') | ForEach-Object {
        [pscustomobject]@{ name=$_; base_model=$baseModel; tool_call_model=$toolCallModel; resume_checkpoint=$resumeCheckpoint; sources=$sources; output_dir=(Join-Path $laneRoot $_); precision='fp16'; residency='hot_swap_slot' }
    }
    [pscustomobject]@{ schema='khanary.micronaut-four-lanes.v1'; created=(Get-Date).ToString('o'); slots=4; precision='fp16'; lanes=@($lanes) } | ConvertTo-Json -Depth 8 | Set-Content -Path $manifestPath -Encoding UTF8
    $inputBox.Text     = $baseModel
    $outputBox.Text    = $laneRoot
    $tokenBinsBox.Text = $sources -join [Environment]::NewLine
    Add-EventLog("[4-lane] manifest written: $manifestPath")
    Add-EventLog("[4-lane] lanes: tool_call, memory, coder, chat  |  FP16 hot-swap")
}

function Get-FreeTcpPort {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
    try { $listener.Start(); return ([System.Net.IPEndPoint]$listener.LocalEndpoint).Port }
    finally { try { $listener.Stop() } catch {} }
}

# ── timers ─────────────────────────────────────────────────────────────────────
# WebGL2 session poll timer
$pollTimer = [System.Windows.Threading.DispatcherTimer]::new()
$pollTimer.Interval = [TimeSpan]::FromSeconds(1)
$pollTimer.Add_Tick({
    if ($script:IsBusy -or -not $script:CurrentSessionId) { return }
    $script:IsBusy = $true
    try {
        $baseUrl = $serverUrlBox.Text.Trim().TrimEnd('/')
        $sid     = $script:CurrentSessionId
        $sr      = Invoke-JsonApi -Method 'GET' -Url "$baseUrl/v1/train/webgl2/status/$sid" -TimeoutSec 10
        $sess    = $sr.session
        if ($sess) {
            $p    = $sess.progress
            $prog = if ($p) { "step=$($p.step)/$($p.steps) ($($p.percent)%)" } else { 'n/a' }
            Update-SessionStatusText -status $sess.status -sessionId $sid -progressText $prog
        }
        $er = Invoke-JsonApi -Method 'GET' -Url "$baseUrl/v1/train/webgl2/events/$sid" -TimeoutSec 10
        $ev = @($er.events)
        if ($ev.Count -gt $script:EventCursor) {
            for ($i=$script:EventCursor;$i -lt $ev.Count;$i++) { Add-EventLog (Format-EventLine $ev[$i]) }
            $script:EventCursor = $ev.Count
        }
        if ($sess -and $sess.status -ne 'running') { $pollTimer.Stop(); Add-EventLog("[session] finalized: $($sess.status)") }
    } catch { Add-EventLog("[poll-err] $($_.Exception.Message)") }
    finally { $script:IsBusy = $false }
})

# D3D11 log tail timer (2s)
$d3d11LogTimer = [System.Windows.Threading.DispatcherTimer]::new()
$d3d11LogTimer.Interval = [TimeSpan]::FromSeconds(2)
$d3d11LogTimer.Add_Tick({ Update-D3D11LogTail })
$d3d11LogTimer.Start()

# ── button handlers ────────────────────────────────────────────────────────────
$checkServerBtn.Add_Click({ [void](Test-KuhulServer) })

$smokeBtn.Add_Click({
    if (-not (Test-Path $script:WebView2SmokeExe)) { Add-EventLog("[smoke] exe missing: $($script:WebView2SmokeExe)"); return }
    $port = Get-FreeTcpPort
    Add-EventLog("[smoke] launching on port $port")
    Start-Process -FilePath $script:WebView2SmokeExe -ArgumentList @('--headless',$script:RepoRoot,[string]$port) -WorkingDirectory $script:RepoRoot | Out-Null
})

$d3d11Phase1Btn.Add_Click({
    try {
        if ($script:D3D11Process -and -not $script:D3D11Process.HasExited) {
            Add-EventLog("[D3D11] already running pid=$($script:D3D11Process.Id)"); return
        }
        Start-D3D11Training 'phase1'
    } catch { Add-EventLog("[D3D11] error: $($_.Exception.Message)") }
})

$d3d11Phase2Btn.Add_Click({
    try {
        if ($script:D3D11Process -and -not $script:D3D11Process.HasExited) {
            Add-EventLog("[D3D11] already running pid=$($script:D3D11Process.Id)"); return
        }
        Start-D3D11Training 'phase2'
    } catch { Add-EventLog("[D3D11] error: $($_.Exception.Message)") }
})

$d3d11KillBtn.Add_Click({
    if ($script:D3D11Process -and -not $script:D3D11Process.HasExited) {
        try { $pid=$script:D3D11Process.Id; $script:D3D11Process.Kill(); Add-EventLog("[D3D11] killed pid=$pid") } catch { Add-EventLog("[D3D11] kill error: $($_.Exception.Message)") }
        $script:D3D11Process = $null; $d3d11StatusBadge.Text = 'D3D11: IDLE'; $d3d11ProcText.Text = ''
    } else { Add-EventLog("[D3D11] no active process") }
})

$trainerModeBox.Add_SelectionChanged({ Update-TrainerModeDescription })
$runTrainerModeBtn.Add_Click({
    try { Start-SelectedTrainerMode } catch { Add-EventLog("[trainer-mode-err] $($_.Exception.Message)") }
})
$hfTensorsBtn.Add_Click({
    try {
        if ($script:NativeProcess -and -not $script:NativeProcess.HasExited) { throw "A trainer process is already running (pid=$($script:NativeProcess.Id))." }
        Start-HfTensorSweep
    } catch { Add-EventLog("[webgl2-sweep-err] $($_.Exception.Message)") }
})
$nativeGpuBtn.Add_Click({
    try { if ($script:NativeProcess -and -not $script:NativeProcess.HasExited) { Add-EventLog("[native] already running pid=$($script:NativeProcess.Id)"); return }; Start-NativeGpuTraining } catch { Add-EventLog("[native-err] $($_.Exception.Message)") }
})
$xShardBtn.Add_Click({
    try { if ($script:NativeProcess -and -not $script:NativeProcess.HasExited) { Add-EventLog("[xshard] already running pid=$($script:NativeProcess.Id)"); return }; Start-XShardTraining } catch { Add-EventLog("[xshard-err] $($_.Exception.Message)") }
})
$prepareFourBtn.Add_Click({ try { Prepare-FourMicronautLanes } catch { Add-EventLog("[4-lane] error: $($_.Exception.Message)") } })
$clearLogBtn.Add_Click({ $eventsList.Items.Clear() })

$stopBtn.Add_Click({
    if ($script:NativeProcess -and -not $script:NativeProcess.HasExited) {
        try { $pid=$script:NativeProcess.Id; $script:NativeProcess.Kill(); Add-EventLog("[stop] killed pid=$pid") } catch { Add-EventLog("[stop-err] $($_.Exception.Message)") }; return
    }
    if (-not $script:CurrentSessionId) { Add-EventLog("[stop] no active session"); return }
    try { $null=Invoke-JsonApi -Method 'POST' -Url "$($serverUrlBox.Text.Trim().TrimEnd('/'))/v1/train/webgl2/stop/$script:CurrentSessionId" -Body @{} -TimeoutSec 20; Add-EventLog("[stop] stop requested for session $script:CurrentSessionId") } catch { Add-EventLog("[stop-err] $($_.Exception.Message)") }
})

$window.Add_Closed({
    if ($pollTimer.IsEnabled)    { $pollTimer.Stop() }
    if ($d3d11LogTimer.IsEnabled){ $d3d11LogTimer.Stop() }
    if ($script:NativeProcess  -and -not $script:NativeProcess.HasExited)  { try { $script:NativeProcess.Kill()  } catch {} }
    if ($script:D3D11Process   -and -not $script:D3D11Process.HasExited)   { try { $script:D3D11Process.Kill()   } catch {} }
})

# ── defaults ──────────────────────────────────────────────────────────────────
$inputBox.Text            = 'E:\models\GPT2\coder_micronaut\ultrachat_coder_slerp_0p35.webgl2.dashboard.safetensors'
$outputBox.Text           = 'E:\models\GPT2\micronaut_four_lanes_v2'
$gemmaOutputBox.Text       = Join-Path $script:RepoRoot ("build\gemma3-reasoning-opencl-300m-96h-{0}" -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
$gemmaHoursBox.Text        = '96'
$xjslOutBox.Text          = 'E:\models\GPT2\micronaut_four_lanes_v2\four-lane-manifest.json'
$tokenBinsBox.Text        = 'E:\models\GPT2\coder_micronaut\coder_ast_json_seq256_tokens.bin'
$trainDimBox.Text         = '1024'
$batchBox.Text            = '16'
$stepsBox.Text            = '300'
$lrBox.Text               = '0.00035'
$timeoutBox.Text          = '600000'
$progressIntervalBox.Text = '4'
$blockBox.Text            = '256'
$numShardsBox.Text        = '6'
$saveEveryBox.Text        = '200'
$shardEveryBox.Text       = '500'
$maxSamplesBox.Text       = ''
$tokenizerBox.SelectedIndex = 0
Update-TrainerModeDescription

# ── init ──────────────────────────────────────────────────────────────────────
[void](Test-KuhulServer)
Update-D3D11LogTail

Add-EventLog("[init] KUHUL Trainer  -- CSS-ML WebGL2 * HD 4600 D3D11 * Native * PyTorch")
Add-EventLog("[init] Trainer modes: CSS-ML WebGL2 checkpoint sweep or PyTorch/OpenCL Gemma 3 300M")
Add-EventLog("[init] D3D11: gpt2-small phase 1  -- stack corpus 10K steps  -- log tailing every 2s")
Add-EventLog("[init] Gemma 3 1B ACTIVE on port 17474  -- default fold model (Pop/Yax/Ch'en)")
Add-EventLog("[init] tip: Phase 2 auto-fills data=stack_phase2.bin, lr=1e-5, steps=2000, --completion-only")
Add-EventLog("[init] tip: leave Tensor filter blank to auto-select first F32 weight tensor")

$window.ShowDialog() | Out-Null
