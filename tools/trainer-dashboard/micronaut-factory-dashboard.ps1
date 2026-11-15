#Requires -Version 5.1
# micronaut-factory-dashboard.ps1  -- Micronaut Factory + Evolution Dashboard
# Ports: kuhul_engine=17474, BOSS=8764. NEVER 8080.
# Launch: pwsh -STA -File .\micronaut-factory-dashboard.ps1

Add-Type -AssemblyName PresentationFramework -ErrorAction SilentlyContinue

trap {
    $msg = $_.Exception.ToString()
    $msg | Out-File (Join-Path $PSScriptRoot 'micronaut-factory-error.log') -Append -Encoding UTF8
    [System.Windows.MessageBox]::Show($msg, 'Micronaut Factory Error', 'OK', 'Error') | Out-Null
    break
}

Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms

$script:RepoRoot    = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$script:Micronauts  = Join-Path $script:RepoRoot 'micronauts'
$script:RepoModels  = Join-Path $script:RepoRoot 'models\from_zero'
$script:Registry    = Join-Path $script:Micronauts 'registry.json'
$script:TrainerExe  = Join-Path $script:RepoRoot 'tools\bin\gpt2_trainer.exe'
$script:TrainerWork = Join-Path $script:RepoRoot 'tools\d3d11-build'
$script:NativeProcess = $null
$script:OutputQueue   = [System.Collections.Concurrent.ConcurrentQueue[string]]::new()
$script:TrainTimer    = $null

$script:Folds      = @('(none)', 'Pop', 'Wo', 'Yax', 'Sek', "Ch'en", 'Xul')
$script:Categories = @('specialist', 'system', 'persona', 'meta', 'stack', 'fold')
$script:QuantTiers = @('fast', 'standard', 'quality')

# ── XAML ─────────────────────────────────────────────────────────────────────
[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Micronaut Factory + Evolution"
        Height="830" Width="1340" MinHeight="660" MinWidth="1000"
        WindowStartupLocation="CenterScreen"
        Background="#0D1117" FontFamily="Consolas">
  <Window.Resources>
    <!-- TabControl: dark header strip + content area -->
    <Style TargetType="TabControl">
      <Setter Property="Background"      Value="#0D1117"/>
      <Setter Property="BorderBrush"     Value="#30363D"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Padding"         Value="0"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="TabControl">
            <Grid>
              <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
              </Grid.RowDefinitions>
              <Border Grid.Row="0" Background="#0D1117"
                      BorderBrush="#30363D" BorderThickness="0,0,0,1">
                <TabPanel IsItemsHost="True" Background="Transparent" Margin="4,0,0,0"/>
              </Border>
              <Border Grid.Row="1" Background="#0D1117"
                      BorderBrush="#30363D" BorderThickness="0">
                <ContentPresenter x:Name="PART_SelectedContentHost"
                                  ContentSource="SelectedContent"/>
              </Border>
            </Grid>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <!-- TabItem: green bottom-border indicator on active tab -->
    <Style x:Key="DarkTab" TargetType="TabItem">
      <Setter Property="Foreground"      Value="#8B949E"/>
      <Setter Property="Background"      Value="Transparent"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Padding"         Value="16,9"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="TabItem">
            <Grid x:Name="Root" MinWidth="80">
              <Border x:Name="Bd" Background="Transparent" Padding="{TemplateBinding Padding}"
                      BorderThickness="0">
                <ContentPresenter ContentSource="Header"
                                  HorizontalAlignment="Center" VerticalAlignment="Center"
                                  TextBlock.FontFamily="Consolas" TextBlock.FontSize="12"
                                  TextBlock.Foreground="{Binding Foreground,
                                      RelativeSource={RelativeSource TemplatedParent}}"/>
              </Border>
              <!-- Green indicator line, bottom of active tab -->
              <Rectangle x:Name="Indicator" Height="2" VerticalAlignment="Bottom"
                         Fill="#39FF14" Visibility="Collapsed" RadiusX="1" RadiusY="1"/>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsSelected" Value="True">
                <Setter TargetName="Bd"        Property="Background" Value="#161B22"/>
                <Setter Property="Foreground"  Value="#39FF14"/>
                <Setter TargetName="Indicator" Property="Visibility" Value="Visible"/>
              </Trigger>
              <Trigger Property="IsMouseOver" Value="True">
                <Setter TargetName="Bd"       Property="Background" Value="#1C2128"/>
                <Setter Property="Foreground" Value="#E6EDF3"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style x:Key="Btn" TargetType="Button">
      <Setter Property="Foreground" Value="White"/>
      <Setter Property="BorderThickness" Value="0"/>
      <Setter Property="Padding" Value="12,6"/>
      <Setter Property="Cursor" Value="Hand"/>
    </Style>
    <Style x:Key="Lbl" TargetType="TextBlock">
      <Setter Property="Foreground" Value="#8B949E"/>
      <Setter Property="VerticalAlignment" Value="Center"/>
      <Setter Property="Margin" Value="0,0,8,0"/>
    </Style>
    <Style x:Key="Fld" TargetType="TextBox">
      <Setter Property="Background" Value="#0D1117"/>
      <Setter Property="Foreground" Value="#E6EDF3"/>
      <Setter Property="BorderBrush" Value="#30363D"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding" Value="6,4"/>
    </Style>
    <Style x:Key="Cmb" TargetType="ComboBox">
      <Setter Property="Background"   Value="#161B22"/>
      <Setter Property="Foreground"   Value="#E6EDF3"/>
      <Setter Property="BorderBrush"  Value="#30363D"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding"      Value="6,4"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="ComboBox">
            <Grid>
              <!-- Dark toggle button (the whole box body) -->
              <ToggleButton x:Name="ToggleButton" Focusable="False" ClickMode="Press"
                            IsChecked="{Binding IsDropDownOpen, Mode=TwoWay,
                                        RelativeSource={RelativeSource TemplatedParent}}">
                <ToggleButton.Template>
                  <ControlTemplate TargetType="ToggleButton">
                    <Grid>
                      <Grid.ColumnDefinitions>
                        <ColumnDefinition/>
                        <ColumnDefinition Width="22"/>
                      </Grid.ColumnDefinitions>
                      <Border x:Name="Bd" Grid.ColumnSpan="2"
                              Background="#161B22" BorderBrush="#30363D" BorderThickness="1"/>
                      <Path x:Name="Arrow" Grid.Column="1" Data="M 0 0 L 5 5 L 10 0 Z"
                            Fill="#8B949E" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                    </Grid>
                    <ControlTemplate.Triggers>
                      <Trigger Property="IsMouseOver" Value="True">
                        <Setter TargetName="Bd"    Property="Background"   Value="#1C2128"/>
                        <Setter TargetName="Bd"    Property="BorderBrush"  Value="#58A6FF"/>
                        <Setter TargetName="Arrow" Property="Fill"         Value="#E6EDF3"/>
                      </Trigger>
                      <Trigger Property="IsChecked" Value="True">
                        <Setter TargetName="Bd"    Property="Background"   Value="#0D1117"/>
                        <Setter TargetName="Bd"    Property="BorderBrush"  Value="#39FF14"/>
                        <Setter TargetName="Arrow" Property="Fill"         Value="#39FF14"/>
                      </Trigger>
                    </ControlTemplate.Triggers>
                  </ControlTemplate>
                </ToggleButton.Template>
              </ToggleButton>
              <!-- Selected item label (non-editable) -->
              <ContentPresenter x:Name="ContentSite" IsHitTestVisible="False"
                                Content="{TemplateBinding SelectionBoxItem}"
                                ContentTemplate="{TemplateBinding SelectionBoxItemTemplate}"
                                Margin="8,4,26,4" VerticalAlignment="Center"
                                HorizontalAlignment="Left"
                                TextBlock.Foreground="#E6EDF3"/>
              <!-- Editable text box (visible only when IsEditable=True) -->
              <TextBox x:Name="PART_EditableTextBox" Visibility="Hidden"
                       Margin="6,3,26,3" BorderThickness="0"
                       Background="Transparent" Foreground="#E6EDF3"
                       CaretBrush="#E6EDF3"
                       IsReadOnly="{TemplateBinding IsReadOnly}"/>
              <!-- Dropdown popup -->
              <Popup x:Name="Popup" Placement="Bottom"
                     IsOpen="{TemplateBinding IsDropDownOpen}"
                     AllowsTransparency="True" Focusable="False"
                     PopupAnimation="Slide">
                <Border x:Name="DropBorder"
                        MinWidth="{Binding ActualWidth, RelativeSource={RelativeSource TemplatedParent}}"
                        MaxHeight="{TemplateBinding MaxDropDownHeight}"
                        Background="#161B22" BorderBrush="#39FF14" BorderThickness="1">
                  <ScrollViewer SnapsToDevicePixels="True">
                    <StackPanel IsItemsHost="True"
                                KeyboardNavigation.DirectionalNavigation="Contained"/>
                  </ScrollViewer>
                </Border>
              </Popup>
            </Grid>
            <ControlTemplate.Triggers>
              <Trigger Property="IsEditable" Value="True">
                <Setter TargetName="PART_EditableTextBox" Property="Visibility" Value="Visible"/>
                <Setter TargetName="ContentSite"          Property="Visibility" Value="Hidden"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <!-- TextBox with Tag-based placeholder + focus ring -->
    <Style x:Key="FldHint" TargetType="TextBox">
      <Setter Property="Background"      Value="#0D1117"/>
      <Setter Property="Foreground"      Value="#E6EDF3"/>
      <Setter Property="BorderBrush"     Value="#30363D"/>
      <Setter Property="BorderThickness" Value="1"/>
      <Setter Property="Padding"         Value="6,4"/>
      <Setter Property="CaretBrush"      Value="#E6EDF3"/>
      <Setter Property="SelectionBrush"  Value="#1F6FEB"/>
      <Setter Property="Template">
        <Setter.Value>
          <ControlTemplate TargetType="TextBox">
            <Border x:Name="Bd"
                    Background="{TemplateBinding Background}"
                    BorderBrush="{TemplateBinding BorderBrush}"
                    BorderThickness="{TemplateBinding BorderThickness}"
                    Padding="{TemplateBinding Padding}">
              <Grid>
                <TextBlock x:Name="Hint" Text="{TemplateBinding Tag}"
                           Foreground="#484F58" IsHitTestVisible="False"
                           VerticalAlignment="Top" TextWrapping="Wrap" FontStyle="Italic">
                  <TextBlock.Style>
                    <Style TargetType="TextBlock">
                      <Setter Property="Visibility" Value="Collapsed"/>
                      <Style.Triggers>
                        <DataTrigger Binding="{Binding Text,
                                     RelativeSource={RelativeSource TemplatedParent}}"
                                     Value="">
                          <Setter Property="Visibility" Value="Visible"/>
                        </DataTrigger>
                      </Style.Triggers>
                    </Style>
                  </TextBlock.Style>
                </TextBlock>
                <ScrollViewer x:Name="PART_ContentHost"/>
              </Grid>
            </Border>
            <ControlTemplate.Triggers>
              <Trigger Property="IsFocused" Value="True">
                <Setter TargetName="Bd" Property="BorderBrush" Value="#39FF14"/>
              </Trigger>
              <Trigger Property="IsReadOnly" Value="True">
                <Setter TargetName="Bd" Property="Opacity" Value="0.6"/>
              </Trigger>
            </ControlTemplate.Triggers>
          </ControlTemplate>
        </Setter.Value>
      </Setter>
    </Style>
    <Style TargetType="ComboBoxItem">
      <Setter Property="Background" Value="#161B22"/>
      <Setter Property="Foreground" Value="#E6EDF3"/>
      <Setter Property="Padding"    Value="8,4"/>
      <Style.Triggers>
        <Trigger Property="IsHighlighted" Value="True">
          <Setter Property="Background" Value="#1F6FEB"/>
          <Setter Property="Foreground" Value="White"/>
        </Trigger>
        <Trigger Property="IsSelected" Value="True">
          <Setter Property="Background" Value="#238636"/>
          <Setter Property="Foreground" Value="White"/>
        </Trigger>
      </Style.Triggers>
    </Style>
  </Window.Resources>

  <Grid Margin="10">
    <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="*"/>
    </Grid.RowDefinitions>

    <!-- Header bar -->
    <Border Grid.Row="0" Background="#161B22" BorderBrush="#30363D" BorderThickness="1"
            CornerRadius="6" Padding="10,6" Margin="0,0,0,8">
      <Grid>
        <Grid.ColumnDefinitions>
          <ColumnDefinition Width="*"/>
          <ColumnDefinition Width="Auto"/>
        </Grid.ColumnDefinitions>
        <TextBlock Text="Micronaut Factory + Evolution" Foreground="#E6EDF3"
                   FontSize="13" FontWeight="Bold" VerticalAlignment="Center"/>
        <StackPanel Grid.Column="1" Orientation="Horizontal">
          <Ellipse x:Name="KuhulDot" Width="9" Height="9" Fill="#DA3633"
                   VerticalAlignment="Center" Margin="0,0,6,0"/>
          <TextBlock x:Name="KuhulStatus" Text="kuhul:17474" Foreground="#8B949E"
                     VerticalAlignment="Center" Margin="0,0,16,0"/>
          <TextBlock x:Name="RegistryCount" Text="0 micronauts" Foreground="#39FF14"
                     VerticalAlignment="Center"/>
        </StackPanel>
      </Grid>
    </Border>

    <!-- Main tabs -->
    <TabControl x:Name="MainTabControl" Grid.Row="1" Background="#0D1117" BorderBrush="#30363D">

      <!-- ══════════════════════════════════════════════════════ TAB 1: FACTORY -->
      <TabItem Header="   Factory" Style="{StaticResource DarkTab}">
        <Grid Margin="10">
          <Grid.ColumnDefinitions>
            <ColumnDefinition Width="370"/>
            <ColumnDefinition Width="*"/>
          </Grid.ColumnDefinitions>

          <!-- LEFT: identity + sampling -->
          <Grid Grid.Column="0" Margin="0,0,12,0">
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
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="110"/>
              <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <TextBlock Grid.Row="0"  Grid.Column="0" Text="Name"         Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="0"  Grid.Column="1" x:Name="FName"       Height="28" Margin="0,0,0,5"
                       Style="{StaticResource FldHint}"
                       Tag="e.g.  code-specialist"/>

            <TextBlock Grid.Row="1"  Grid.Column="0" Text="Category"     Style="{StaticResource Lbl}"/>
            <ComboBox  Grid.Row="1"  Grid.Column="1" x:Name="FCategory"  Height="28" Margin="0,0,0,5" Style="{StaticResource Cmb}"/>

            <TextBlock Grid.Row="2"  Grid.Column="0" Text="Fold phase"   Style="{StaticResource Lbl}"/>
            <ComboBox  Grid.Row="2"  Grid.Column="1" x:Name="FFold"      Height="28" Margin="0,0,0,5" Style="{StaticResource Cmb}"/>

            <TextBlock Grid.Row="3"  Grid.Column="0" Text="Quant tier"   Style="{StaticResource Lbl}"/>
            <ComboBox  Grid.Row="3"  Grid.Column="1" x:Name="FQuantTier" Height="28" Margin="0,0,0,5" Style="{StaticResource Cmb}"/>

            <TextBlock Grid.Row="4"  Grid.Column="0" Text="Confidence"   Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="4"  Grid.Column="1" x:Name="FConfidence" Height="28" Margin="0,0,0,5"
                       Style="{StaticResource FldHint}" Tag="0.0 - 1.0  (default 0.75)"/>

            <TextBlock Grid.Row="5"  Grid.Column="0" Text="Temperature"  Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="5"  Grid.Column="1" x:Name="FTemperature" Height="28" Margin="0,0,0,5"
                       Style="{StaticResource FldHint}" Tag="0.0 - 2.0  (creative ↑)"/>

            <TextBlock Grid.Row="6"  Grid.Column="0" Text="Rep. penalty" Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="6"  Grid.Column="1" x:Name="FRepPenalty" Height="28" Margin="0,0,0,5"
                       Style="{StaticResource FldHint}" Tag="1.0 = off  1.1 = mild  1.3 = strong"/>

            <TextBlock Grid.Row="7"  Grid.Column="0" Text="Rep. last N"  Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="7"  Grid.Column="1" x:Name="FRepLastN"  Height="28" Margin="0,0,0,5"
                       Style="{StaticResource FldHint}" Tag="token window for repeat penalty (64)"/>

            <TextBlock Grid.Row="8"  Grid.Column="0" Text="Stop tokens"  Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="8"  Grid.Column="1" x:Name="FStop"      Height="28" Margin="0,0,0,5"
                       Style="{StaticResource FldHint}" Tag="e.g.  &lt;/s&gt;, &lt;EOT&gt;, &lt;XUL&gt;"/>

            <TextBlock Grid.Row="9"  Grid.Column="0" Text="Capabilities" Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="9"  Grid.Column="1" x:Name="FCapabilities" Height="28" Margin="0,0,0,5"
                       Style="{StaticResource FldHint}" Tag="e.g.  code-gen, refactor, debugging, tool-use"/>

            <TextBlock Grid.Row="10" Grid.Column="0" Text="Token bin"    Style="{StaticResource Lbl}"/>
            <ComboBox  Grid.Row="10" Grid.Column="1" x:Name="FTokenBin"  Height="28" Margin="0,0,0,5"
                       IsEditable="True" Style="{StaticResource Cmb}"
                       ToolTip="Training .bin for this expert (auto-filled from tokens/ dir)"/>

            <TextBlock Grid.Row="11" Grid.Column="0" Text="Base model"   Style="{StaticResource Lbl}"/>
            <ComboBox  Grid.Row="11" Grid.Column="1" x:Name="FBaseModel" Height="28" Margin="0,0,0,5"
                       IsEditable="True" Style="{StaticResource Cmb}"
                       ToolTip="Safetensors checkpoint to train from (from_zero_v0.6 recommended)"/>

            <TextBlock Grid.Row="12" Grid.Column="0" Text="Steps"        Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="12" Grid.Column="1" x:Name="FSteps"     Height="28" Margin="0,0,0,5"
                       Style="{StaticResource FldHint}" Tag="training steps  (500 = light  2000 = thorough)"/>

            <TextBlock Grid.Row="13" Grid.Column="0" Text="LR"           Style="{StaticResource Lbl}"/>
            <TextBox   Grid.Row="13" Grid.Column="1" x:Name="FLr"        Height="28" Margin="0,0,0,8"
                       Style="{StaticResource FldHint}" Tag="learning rate  (3e-5 standard)"/>

            <StackPanel Grid.Row="14" Grid.Column="0" Grid.ColumnSpan="2"
                        Orientation="Horizontal" Margin="0,6,0,0">
              <Button x:Name="CreateBtn"    Content="Create"         Height="30" MinWidth="80"
                      Style="{StaticResource Btn}" Background="#238636" Margin="0,0,6,0"/>
              <Button x:Name="TrainNewBtn"  Content="Create + Train" Height="30" MinWidth="110"
                      Style="{StaticResource Btn}" Background="#8957E5" Margin="0,0,6,0"/>
              <Button x:Name="ClearFormBtn" Content="Clear"          Height="30" MinWidth="60"
                      Style="{StaticResource Btn}" Background="#30363D"/>
            </StackPanel>
          </Grid>

          <!-- RIGHT: description + system prompt + status -->
          <Grid Grid.Column="1">
            <Grid.RowDefinitions>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="Auto"/>
              <RowDefinition Height="*"/>
              <RowDefinition Height="Auto"/>
            </Grid.RowDefinitions>

            <!-- Description row: label + AI buttons -->
            <Grid Grid.Row="0" Margin="0,0,0,4">
              <Grid.ColumnDefinitions>
                <ColumnDefinition Width="*"/>
                <ColumnDefinition Width="Auto"/>
                <ColumnDefinition Width="Auto"/>
              </Grid.ColumnDefinitions>
              <TextBlock Grid.Column="0" Text="Description" Foreground="#8B949E"
                         VerticalAlignment="Center"/>
              <Button x:Name="AISuggestBtn" Grid.Column="1"
                      Content="✦ Suggest All" Height="24" FontSize="10" MinWidth="90"
                      Style="{StaticResource Btn}" Background="#1F6FEB" Margin="0,0,6,0"
                      ToolTip="Ask kuhul_engine to suggest name, description, capabilities and system prompt"/>
              <Button x:Name="AISystemBtn" Grid.Column="2"
                      Content="↻ System" Height="24" FontSize="10" MinWidth="70"
                      Style="{StaticResource Btn}" Background="#30363D"
                      ToolTip="Regenerate system prompt from current name + description"/>
            </Grid>
            <TextBox   Grid.Row="1" x:Name="FDescription" Height="54" Margin="0,0,0,8"
                       Style="{StaticResource FldHint}" AcceptsReturn="True" TextWrapping="Wrap"
                       VerticalScrollBarVisibility="Auto"
                       Tag="Short one-line description for registry (what does this expert do?)"/>

            <Grid Grid.Row="2">
              <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
              </Grid.RowDefinitions>
              <TextBlock Grid.Row="0" Text="System prompt" Foreground="#8B949E" Margin="0,0,0,4"/>
              <TextBox   Grid.Row="1" x:Name="FSystem"
                         Style="{StaticResource FldHint}" AcceptsReturn="True" TextWrapping="Wrap"
                         VerticalScrollBarVisibility="Auto" Margin="0,0,0,8"
                         Tag="You are a focused expert at... Respond concisely. (plain English  -- no stack terms)"/>
            </Grid>

            <Border Grid.Row="3" Background="#161B22" BorderBrush="#30363D" BorderThickness="1"
                    CornerRadius="4" Padding="8,6">
              <TextBlock x:Name="FactoryStatus"
                         Text="Ready -- fill fields and click Create"
                         Foreground="#39FF14" FontSize="11" TextWrapping="Wrap"/>
            </Border>
          </Grid>
        </Grid>
      </TabItem>

      <!-- ══════════════════════════════════════════════════════ TAB 2: EVOLUTION -->
      <TabItem Header="   Evolution" Style="{StaticResource DarkTab}">
        <Grid Margin="10">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>

          <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,8">
            <Button x:Name="ReloadBtn"    Content="Reload"               Style="{StaticResource Btn}" Background="#1F6FEB" Margin="0,0,6,0"/>
            <Button x:Name="EditEvoBtn"   Content="Edit in Factory"      Style="{StaticResource Btn}" Background="#F0883E" Margin="0,0,6,0"/>
            <Button x:Name="TrainEvoBtn"  Content="Train Selected"       Style="{StaticResource Btn}" Background="#8957E5" Margin="0,0,6,0"/>
            <Button x:Name="PromoteBtn"   Content="Promote Latest Ckpt"  Style="{StaticResource Btn}" Background="#238636" Margin="0,0,6,0"/>
            <Button x:Name="InspectBtn"   Content="Inspect JSON"         Style="{StaticResource Btn}" Background="#30363D" Margin="0,0,6,0"/>
            <Button x:Name="DeleteEvoBtn" Content="Remove from Registry" Style="{StaticResource Btn}" Background="#DA3633"/>
          </StackPanel>

          <Grid Grid.Row="1">
            <Grid.ColumnDefinitions>
              <ColumnDefinition Width="300"/>
              <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <Border Grid.Column="0" Background="#161B22" BorderBrush="#30363D"
                    BorderThickness="1" CornerRadius="6" Margin="0,0,8,0">
              <Grid>
                <Grid.RowDefinitions>
                  <RowDefinition Height="Auto"/>
                  <RowDefinition Height="*"/>
                </Grid.RowDefinitions>
                <TextBlock Grid.Row="0" Text="Registry" Foreground="#39FF14"
                           FontWeight="Bold" Margin="8,6,0,4"/>
                <ListBox x:Name="MicronautList" Grid.Row="1"
                         Background="#0D1117" Foreground="#E6EDF3"
                         BorderThickness="0" FontSize="11" Margin="2,0,2,4"
                         FontFamily="Consolas"/>
              </Grid>
            </Border>

            <!-- Detail panel -->
            <Grid Grid.Column="1">
              <Grid.RowDefinitions>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="Auto"/>
                <RowDefinition Height="*"/>
              </Grid.RowDefinitions>

              <Border Grid.Row="0" Background="#161B22" BorderBrush="#30363D"
                      BorderThickness="1" CornerRadius="6" Padding="12,8" Margin="0,0,0,8">
                <Grid>
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="Auto"/>
                  </Grid.ColumnDefinitions>
                  <StackPanel>
                    <TextBlock x:Name="DetName"        Text="--"  Foreground="#E6EDF3" FontSize="15" FontWeight="Bold"/>
                    <TextBlock x:Name="DetDescription" Text=""    Foreground="#8B949E" FontSize="11" TextWrapping="Wrap" Margin="0,4,0,0"/>
                  </StackPanel>
                  <StackPanel Grid.Column="1" HorizontalAlignment="Right">
                    <TextBlock x:Name="DetFold"     Text="" Foreground="#39FF14" FontWeight="Bold" HorizontalAlignment="Right"/>
                    <TextBlock x:Name="DetCategory" Text="" Foreground="#8B949E" FontSize="11"     HorizontalAlignment="Right"/>
                  </StackPanel>
                </Grid>
              </Border>

              <Border Grid.Row="1" Background="#161B22" BorderBrush="#30363D"
                      BorderThickness="1" CornerRadius="6" Padding="12,8" Margin="0,0,0,8">
                <Grid>
                  <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="*"/>
                    <ColumnDefinition Width="*"/>
                  </Grid.ColumnDefinitions>
                  <StackPanel Grid.Column="0">
                    <TextBlock Text="Sampling" Foreground="#8B949E" FontSize="11" Margin="0,0,0,4"/>
                    <TextBlock x:Name="DetSampling" Text="" Foreground="#E6EDF3" FontSize="11" TextWrapping="Wrap"/>
                  </StackPanel>
                  <StackPanel Grid.Column="1" Margin="12,0,0,0">
                    <TextBlock Text="Status" Foreground="#8B949E" FontSize="11" Margin="0,0,0,4"/>
                    <TextBlock x:Name="DetStatus" Text="" Foreground="#E6EDF3" FontSize="11" TextWrapping="Wrap"/>
                  </StackPanel>
                </Grid>
              </Border>

              <Border Grid.Row="2" Background="#161B22" BorderBrush="#30363D"
                      BorderThickness="1" CornerRadius="6" Padding="12,8" Margin="0,0,0,8">
                <Grid>
                  <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="Auto"/>
                  </Grid.RowDefinitions>
                  <TextBlock Grid.Row="0" Text="Checkpoint lineage" Foreground="#8B949E" FontSize="11" Margin="0,0,0,4"/>
                  <ListBox x:Name="CheckpointList" Grid.Row="1"
                           Background="#0D1117" Foreground="#E6EDF3"
                           BorderThickness="0" FontSize="11" MaxHeight="88"/>
                </Grid>
              </Border>

              <Border Grid.Row="3" Background="#0D1117" BorderBrush="#30363D"
                      BorderThickness="1" CornerRadius="6" Padding="8">
                <Grid>
                  <Grid.RowDefinitions>
                    <RowDefinition Height="Auto"/>
                    <RowDefinition Height="*"/>
                  </Grid.RowDefinitions>
                  <TextBlock Grid.Row="0" Text="JSON preview" Foreground="#8B949E" FontSize="11" Margin="0,0,0,4"/>
                  <TextBox x:Name="JsonPreview" Grid.Row="1"
                           Background="#0D1117" Foreground="#39FF14" BorderThickness="0"
                           FontSize="11" IsReadOnly="True" AcceptsReturn="True"
                           TextWrapping="Wrap" VerticalScrollBarVisibility="Auto"/>
                </Grid>
              </Border>
            </Grid>
          </Grid>
        </Grid>
      </TabItem>

      <!-- ══════════════════════════════════════════════════════ TAB 3: TRAINING LOG -->
      <TabItem Header="   Training" Style="{StaticResource DarkTab}">
        <Grid Margin="10">
          <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
          </Grid.RowDefinitions>
          <StackPanel Grid.Row="0" Orientation="Horizontal" Margin="0,0,0,8">
            <Button x:Name="StopTrainBtn" Content="Stop"      Style="{StaticResource Btn}" Background="#DA3633" Margin="0,0,6,0"/>
            <Button x:Name="ClearLogBtn"  Content="Clear Log" Style="{StaticResource Btn}" Background="#30363D" Margin="0,0,14,0"/>
            <TextBlock x:Name="TrainStatus" Text="No training session active"
                       Foreground="#39FF14" VerticalAlignment="Center"/>
          </StackPanel>
          <Border Grid.Row="1" Background="#0D1117" BorderBrush="#30363D"
                  BorderThickness="1" CornerRadius="6">
            <ListBox x:Name="TrainLog" Background="#0D1117" Foreground="#39FF14"
                     BorderThickness="0" FontSize="11"/>
          </Border>
        </Grid>
      </TabItem>

    </TabControl>
  </Grid>
</Window>
'@

$reader = [System.Xml.XmlNodeReader]::new($xaml)
$window = [System.Windows.Markup.XamlReader]::Load($reader)

# ── Find controls ─────────────────────────────────────────────────────────────
$mainTab        = $window.FindName('MainTabControl')
$kuhulDot       = $window.FindName('KuhulDot')
$kuhulStatus    = $window.FindName('KuhulStatus')
$registryCount  = $window.FindName('RegistryCount')

$fName          = $window.FindName('FName')
$fCategory      = $window.FindName('FCategory')
$fFold          = $window.FindName('FFold')
$fConfidence    = $window.FindName('FConfidence')
$fQuantTier     = $window.FindName('FQuantTier')
$fTemperature   = $window.FindName('FTemperature')
$fRepPenalty    = $window.FindName('FRepPenalty')
$fRepLastN      = $window.FindName('FRepLastN')
$fStop          = $window.FindName('FStop')
$fCapabilities  = $window.FindName('FCapabilities')
$fTokenBin      = $window.FindName('FTokenBin')
$fBaseModel     = $window.FindName('FBaseModel')
$fSteps         = $window.FindName('FSteps')
$fLr            = $window.FindName('FLr')
$fDescription   = $window.FindName('FDescription')
$fSystem        = $window.FindName('FSystem')
$factoryStatus  = $window.FindName('FactoryStatus')
$createBtn      = $window.FindName('CreateBtn')
$trainNewBtn    = $window.FindName('TrainNewBtn')
$clearFormBtn   = $window.FindName('ClearFormBtn')
$aiSuggestBtn   = $window.FindName('AISuggestBtn')
$aiSystemBtn    = $window.FindName('AISystemBtn')

$micronautList  = $window.FindName('MicronautList')
$detName        = $window.FindName('DetName')
$detDescription = $window.FindName('DetDescription')
$detFold        = $window.FindName('DetFold')
$detCategory    = $window.FindName('DetCategory')
$detSampling    = $window.FindName('DetSampling')
$detStatus      = $window.FindName('DetStatus')
$checkpointList = $window.FindName('CheckpointList')
$jsonPreview    = $window.FindName('JsonPreview')
$reloadBtn      = $window.FindName('ReloadBtn')
$editEvoBtn     = $window.FindName('EditEvoBtn')
$trainEvoBtn    = $window.FindName('TrainEvoBtn')
$promoteBtn     = $window.FindName('PromoteBtn')
$inspectBtn     = $window.FindName('InspectBtn')
$deleteEvoBtn   = $window.FindName('DeleteEvoBtn')

$stopTrainBtn   = $window.FindName('StopTrainBtn')
$clearLogBtn    = $window.FindName('ClearLogBtn')
$trainStatus    = $window.FindName('TrainStatus')
$trainLog       = $window.FindName('TrainLog')

# ── Dropdowns ─────────────────────────────────────────────────────────────────
foreach ($v in $script:Categories) {
    $i = [System.Windows.Controls.ComboBoxItem]::new(); $i.Content = $v
    $fCategory.Items.Add($i) | Out-Null
}
$fCategory.SelectedIndex = 0

foreach ($v in $script:Folds) {
    $i = [System.Windows.Controls.ComboBoxItem]::new(); $i.Content = $v
    $fFold.Items.Add($i) | Out-Null
}
$fFold.SelectedIndex = 0

foreach ($v in $script:QuantTiers) {
    $i = [System.Windows.Controls.ComboBoxItem]::new(); $i.Content = $v
    $fQuantTier.Items.Add($i) | Out-Null
}
$fQuantTier.SelectedIndex = 1

function Populate-Pickers {
    $fTokenBin.Items.Clear()
    $fBaseModel.Items.Clear()

    $tokDir = Join-Path $script:RepoModels 'tokens'
    if (Test-Path $tokDir) {
        Get-ChildItem $tokDir -Filter '*.bin' | Sort-Object Name |
            ForEach-Object { $fTokenBin.Items.Add($_.FullName) | Out-Null }
    }

    @('from_zero_v0.6_merged.safetensors','from_zero_v0.5_phase2.safetensors',
      'coder_skeleton.safetensors','ts_coder_v0.1.safetensors') |
    ForEach-Object {
        $p = Join-Path $script:RepoModels $_
        if (Test-Path $p) { $fBaseModel.Items.Add($p) | Out-Null }
    }
    $trainDir = Join-Path $script:RepoModels 'trained'
    if (Test-Path $trainDir) {
        Get-ChildItem $trainDir -Filter '*.safetensors' | Sort-Object Name |
            ForEach-Object { $fBaseModel.Items.Add($_.FullName) | Out-Null }
    }
    if ($fBaseModel.Items.Count -gt 0) { $fBaseModel.SelectedIndex = 0 }
}
Populate-Pickers

# ── Registry helpers ──────────────────────────────────────────────────────────
function Load-Registry {
    if (-not (Test-Path $script:Registry)) { return @() }
    try { return @((Get-Content $script:Registry -Raw | ConvertFrom-Json).micronauts) }
    catch { return @() }
}

function Save-Registry([array]$list) {
    [ordered]@{
        version    = '1.0.0'
        generated  = (Get-Date -Format 'yyyy-MM-dd')
        micronauts = $list
    } | ConvertTo-Json -Depth 8 | Set-Content $script:Registry -Encoding UTF8
}

function Get-MicronautStatus([string]$name) {
    $hasJson  = Test-Path (Join-Path $script:Micronauts "$name.json")
    $binPaths = @(
        (Join-Path $script:RepoModels "tokens\mm-$name.bin")
        (Join-Path $script:RepoModels "tokens\$name.bin")
    )
    $binPath  = $binPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
    $ckpts    = @()
    $tdir     = Join-Path $script:RepoModels 'trained'
    if (Test-Path $tdir) {
        $ckpts = @(Get-ChildItem $tdir -Filter "*$name*.safetensors" | Sort-Object Name)
    }
    [pscustomobject]@{
        HasJson = $hasJson
        HasBin  = ($null -ne $binPath)
        BinPath = $binPath
        Ckpts   = $ckpts
    }
}

# ── Training log (DispatcherTimer drains ConcurrentQueue on UI thread) ────────
function Add-TrainLog([string]$line) {
    $item = [System.Windows.Controls.ListBoxItem]::new()
    $item.Content    = $line
    $item.Foreground = [System.Windows.Media.Brushes]::Lime
    $trainLog.Items.Add($item) | Out-Null
    $trainLog.ScrollIntoView($item)
}

function Start-TrainTimer {
    if ($script:TrainTimer) { $script:TrainTimer.Stop() }
    $script:TrainTimer = [System.Windows.Threading.DispatcherTimer]::new()
    $script:TrainTimer.Interval = [timespan]::FromMilliseconds(400)
    $script:TrainTimer.Add_Tick({
        $line = $null
        while ($script:OutputQueue.TryDequeue([ref]$line)) { Add-TrainLog $line }
        if ($script:NativeProcess -and $script:NativeProcess.HasExited -and $script:OutputQueue.IsEmpty) {
            $script:TrainTimer.Stop()
            Populate-EvolutionList
        }
    })
    $script:TrainTimer.Start()
}

# ── Evolution list ────────────────────────────────────────────────────────────
function Populate-EvolutionList {
    $all = Load-Registry
    $micronautList.Items.Clear()
    $registryCount.Text = "$($all.Count) micronauts"

    foreach ($m in $all) {
        $st    = Get-MicronautStatus $m.name
        $fold  = if ($m.fold) { "[$($m.fold)]" } else { "      " }
        $icons = "$(if ($st.HasJson) {'[J]'} else {'   '}) $(if ($st.HasBin) {'[B]'} else {'   '}) $(if ($st.Ckpts.Count -gt 0) {"[C:$($st.Ckpts.Count)]"} else {''})"
        $item  = [System.Windows.Controls.ListBoxItem]::new()
        $item.Tag     = $m
        $item.Content = "$($m.name.PadRight(20)) $($fold.PadRight(8)) $icons"
        $micronautList.Items.Add($item) | Out-Null
    }
}

# ── Detail panel ──────────────────────────────────────────────────────────────
$micronautList.Add_SelectionChanged({
    $sel = $micronautList.SelectedItem
    if (-not $sel -or -not $sel.Tag) { return }
    $m  = $sel.Tag
    $st = Get-MicronautStatus $m.name

    $detName.Text        = $m.name
    $detDescription.Text = if ($m.description) { $m.description } else { '' }
    $detFold.Text        = if ($m.fold) { $m.fold } else { '--' }
    $detCategory.Text    = if ($m.category) { $m.category } else { '' }

    $s = $m.sampling
    $detSampling.Text = "temp:        $($s.temperature)`nrep_penalty: $($s.repeat_penalty)`nrep_last_n:  $($s.repeat_last_n)`nquant_tier:  $($m.quant_tier)"

    $lines  = @()
    $lines += if ($st.HasJson) { 'OK  JSON file'   } else { 'X   No JSON file' }
    $lines += if ($st.HasBin)  { "OK  Token bin  $([System.IO.Path]::GetFileName($st.BinPath))" } else { 'X   No token bin' }
    $lines += if ($st.Ckpts.Count -gt 0) { "OK  $($st.Ckpts.Count) checkpoint(s)" } else { 'X   Not yet trained' }
    $detStatus.Text = ($lines -join "`n")

    $checkpointList.Items.Clear()
    foreach ($ck in $st.Ckpts) { $checkpointList.Items.Add($ck.Name) | Out-Null }

    $jp = Join-Path $script:Micronauts "$($m.name).json"
    $jsonPreview.Text = if (Test-Path $jp) { Get-Content $jp -Raw } else { "(no $($m.name).json -- create in Factory tab)" }
})

# ── Factory helpers ───────────────────────────────────────────────────────────
function Get-FormName { ($fName.Text.Trim().ToLower()) -replace '[^a-z0-9_-]', '_' }
function Get-FormFold {
    $v = $fFold.SelectedItem.Content
    if ($v -eq '(none)') { return $null }; return $v
}

function Build-FullJson([string]$name) {
    $fold  = Get-FormFold
    $caps  = @($fCapabilities.Text -split '[,;\s]+' | Where-Object { $_ })
    $stops = @($fStop.Text          -split '[,;\s]+' | Where-Object { $_ })
    $samp  = [ordered]@{
        temperature    = [double]$fTemperature.Text
        repeat_penalty = [double]$fRepPenalty.Text
        repeat_last_n  = [int]$fRepLastN.Text
    }
    if ($stops.Count -gt 0) { $samp.stop = $stops }
    $obj = [ordered]@{
        '@kind'    = 'micronaut.v2'
        name       = $name
        system     = $fSystem.Text.Trim()
        sampling   = $samp
        '@fold'    = $fold
        '@node'    = "$name-node"
        '@control' = @(
            [ordered]@{ '@op' = 'FOLD_ENTER'; '@fold' = $fold; '@node' = "$name-node" }
            [ordered]@{ '@op' = 'FOLD_EXIT';  '@fold' = "Ch'en"; '@node' = "$name-node" }
        )
    }
    if ($caps.Count -gt 0) { $obj.capabilities = $caps }
    $obj
}

function Build-RegEntry([string]$name) {
    $fold  = Get-FormFold
    $stops = @($fStop.Text -split '[,;\s]+' | Where-Object { $_ })
    $samp  = [ordered]@{
        temperature    = [double]$fTemperature.Text
        repeat_penalty = [double]$fRepPenalty.Text
        repeat_last_n  = [int]$fRepLastN.Text
    }
    if ($stops.Count -gt 0) { $samp.stop = $stops }
    [ordered]@{
        name        = $name
        fold        = $fold
        category    = $fCategory.SelectedItem.Content
        description = $fDescription.Text.Trim()
        confidence  = [double]$fConfidence.Text
        quant_tier  = $fQuantTier.SelectedItem.Content
        sampling    = $samp
    }
}

function Clear-Form {
    $fName.Text = ''; $fDescription.Text = ''; $fSystem.Text = ''
    $fCapabilities.Text = ''; $fStop.Text = ''
    $fTemperature.Text = '0.7'; $fRepPenalty.Text = '1.1'; $fRepLastN.Text = '64'
    $fConfidence.Text = '0.75'; $fSteps.Text = '500'; $fLr.Text = '0.00003'
    $fCategory.SelectedIndex = 0; $fFold.SelectedIndex = 0; $fQuantTier.SelectedIndex = 1
    $fTokenBin.Text = ''
    $factoryStatus.Text = 'Ready -- fill fields and click Create'
}
$clearFormBtn.Add_Click({ Clear-Form })

# ── AI suggestion helpers ─────────────────────────────────────────────────────
function Get-InferenceUrl {
    # Read active-model.json for the live model port, fall back to MCP gateway (8764)
    $amPath = Join-Path $script:RepoRoot 'active-model.json'
    if (Test-Path $amPath) {
        try {
            $am = Get-Content $amPath -Raw | ConvertFrom-Json
            if ($am.port -and $am.port -ne 0) {
                return "http://127.0.0.1:$($am.port)/v1/chat/completions"
            }
        } catch {}
    }
    return 'http://127.0.0.1:8764/v1/chat/completions'
}

function Invoke-KuhulChat([string]$prompt, [int]$maxTokens = 500) {
    $url = Get-InferenceUrl
    $body = @{
        model       = 'khanary'
        messages    = @(@{ role = 'user'; content = $prompt })
        max_tokens  = $maxTokens
        temperature = 0.75
        stream      = $false
    } | ConvertTo-Json -Depth 5

    $resp = Invoke-RestMethod -Uri $url `
                -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 45
    return $resp.choices[0].message.content
}

function Invoke-AISuggestAll {
    $factoryStatus.Text = 'Querying kuhul_engine...'
    $aiSuggestBtn.IsEnabled = $false

    try {
        $existing = @(Load-Registry | ForEach-Object { $_.name }) -join ', '
        $tiers = 'fast | standard | quality'
        $folds = "Pop | Wo | Yax | Sek | Ch'en | Xul"
        $cats  = 'specialist | system | persona | meta | stack | fold'

        $prompt = @"
You are helping configure a new AI expert module (micronaut) for the K'UHUL GPU inference stack.
Currently registered experts: $existing

Identify an expert that would complement the existing set (code, writing, analysis, creative, tool-use, etc.)
Reply with ONLY a JSON object  -- no markdown fences, no extra text:
{
  "name": "kebab-case-id",
  "category": "$cats",
  "fold": "$folds or null",
  "quant_tier": "$tiers",
  "temperature": 0.0-1.5,
  "repeat_penalty": 1.0-1.3,
  "capabilities": ["cap1","cap2"],
  "description": "one short sentence",
  "system": "You are... (2-4 sentences, plain English, no jargon)"
}
"@
        $raw  = Invoke-KuhulChat $prompt 600
        # Extract first {...} block (model may still wrap in extra text)
        if ($raw -match '(?s)\{[^{}]*"name"[^{}]*\}') {
            $json = $Matches[0] | ConvertFrom-Json

            if ($json.name)         { $fName.Text = $json.name }
            if ($json.description)  { $fDescription.Text = $json.description }
            if ($json.system)       { $fSystem.Text = $json.system }
            if ($json.capabilities) { $fCapabilities.Text = ($json.capabilities -join ', ') }
            if ($json.temperature)  { $fTemperature.Text  = [string]$json.temperature }
            if ($json.repeat_penalty) { $fRepPenalty.Text = [string]$json.repeat_penalty }

            $catI = $fCategory.Items | Where-Object { $_.Content -eq $json.category } | Select-Object -First 1
            if ($catI) { $fCategory.SelectedItem = $catI }

            $foldV = if ($json.fold -and $json.fold -ne 'null') { $json.fold } else { '(none)' }
            $foldI = $fFold.Items | Where-Object { $_.Content -eq $foldV } | Select-Object -First 1
            if ($foldI) { $fFold.SelectedItem = $foldI }

            $qtI = $fQuantTier.Items | Where-Object { $_.Content -eq $json.quant_tier } | Select-Object -First 1
            if ($qtI) { $fQuantTier.SelectedItem = $qtI }

            $factoryStatus.Text = "AI suggestion loaded for '$($json.name)'  -- review and click Create"
        } else {
            $factoryStatus.Text = "AI: could not parse JSON from response. Raw: $($raw.Substring(0,[Math]::Min(120,$raw.Length)))"
        }
    } catch {
        $factoryStatus.Text = "AI suggest failed: $_"
    } finally {
        $aiSuggestBtn.IsEnabled = $true
    }
}

function Invoke-AISystem {
    $name = Get-FormName
    $desc = $fDescription.Text.Trim()
    $caps = $fCapabilities.Text.Trim()
    if (-not $name -and -not $desc) { $factoryStatus.Text = 'Fill name or description first'; return }

    $factoryStatus.Text = 'Generating system prompt...'
    $aiSystemBtn.IsEnabled = $false
    try {
        $prompt = @"
Write a concise system prompt for an AI expert module with the following profile:
Name: $name
Description: $desc
Capabilities: $caps

Rules:
- Plain English only (no technical jargon, no stack-internal terms)
- 2-4 sentences
- Start with "You are a..."
- Focus on behavior and tone, not implementation details
Reply with ONLY the system prompt text, no labels or extra commentary.
"@
        $result = Invoke-KuhulChat $prompt 250
        $fSystem.Text = $result.Trim()
        $factoryStatus.Text = 'System prompt generated  -- review and adjust as needed'
    } catch {
        $factoryStatus.Text = "AI system regen failed: $_"
    } finally {
        $aiSystemBtn.IsEnabled = $true
    }
}

$aiSuggestBtn.Add_Click({ Invoke-AISuggestAll })
$aiSystemBtn.Add_Click({  Invoke-AISystem     })

# ── Create ────────────────────────────────────────────────────────────────────
function Invoke-Create {
    $name = Get-FormName
    if (-not $name)                { $factoryStatus.Text = 'ERROR: Name required'; return $false }
    if (-not $fSystem.Text.Trim()) { $factoryStatus.Text = 'ERROR: System prompt required'; return $false }

    $jp = Join-Path $script:Micronauts "$name.json"
    (Build-FullJson $name) | ConvertTo-Json -Depth 8 | Set-Content $jp -Encoding UTF8

    $all = @(Load-Registry | Where-Object { $_.name -ne $name })
    $all += Build-RegEntry $name
    Save-Registry $all

    $bin = $fTokenBin.Text.Trim()
    if ($bin -and (Test-Path $bin)) {
        $bn  = [System.IO.Path]::GetFileNameWithoutExtension($bin)
        $ft  = if (Get-FormFold) { "fold=$(Get-FormFold)" } else { '' }
        $fc  = ($fCapabilities.Text.Trim() -replace '[,;\s]+', ' ')
        $sys = $fSystem.Text.Trim(); if ($sys.Length -gt 80) { $sys = $sys.Substring(0,80) }
        $ent = "{`"text`": `"<POP> $name $($fCategory.SelectedItem.Content) $ft $fc <THINK> system=${sys}... temp=$($fTemperature.Text) bin=$bn <XUL> micronaut_expert $name portable=true kind=runtime_expert`"}"
        Add-Content (Join-Path $script:RepoModels 'tokens\domain_models.jsonl') $ent -Encoding UTF8
        $factoryStatus.Text = "Created $jp`nRegistry + JSONL updated."
    } else {
        $factoryStatus.Text = "Created $jp`nRegistry updated. (No token bin -- JSONL skipped.)"
    }
    Populate-EvolutionList
    return $true
}

$createBtn.Add_Click({
    try { Invoke-Create | Out-Null } catch { $factoryStatus.Text = "ERROR: $_" }
})

$trainNewBtn.Add_Click({
    try {
        if (-not (Invoke-Create)) { return }
        $name = Get-FormName
        $bin  = $fTokenBin.Text.Trim()
        $base = $fBaseModel.Text.Trim()
        if (-not $bin  -or -not (Test-Path $bin))  { $factoryStatus.Text += "`nERROR: valid token bin required"; return }
        if (-not $base -or -not (Test-Path $base)) { $factoryStatus.Text += "`nERROR: valid base model required"; return }
        Launch-Training -InputModel $base -DataBin $bin `
            -OutputModel (Join-Path $script:RepoModels "trained\mm-$name.safetensors") `
            -Steps ([int]$fSteps.Text) -Lr ([double]$fLr.Text) -Label $name
    } catch { $factoryStatus.Text = "ERROR: $_" }
})

# ── Evolution buttons ─────────────────────────────────────────────────────────
$reloadBtn.Add_Click({ Populate-Pickers; Populate-EvolutionList })

$editEvoBtn.Add_Click({
    $sel = $micronautList.SelectedItem
    if (-not $sel -or -not $sel.Tag) { return }
    $m = $sel.Tag
    $fName.Text        = $m.name
    $fDescription.Text = if ($m.description) { $m.description } else { '' }
    $fConfidence.Text  = [string]$m.confidence

    $catI = $fCategory.Items | Where-Object { $_.Content -eq $m.category }  | Select-Object -First 1
    if ($catI) { $fCategory.SelectedItem = $catI }

    $foldV = if ($m.fold) { $m.fold } else { '(none)' }
    $foldI = $fFold.Items | Where-Object { $_.Content -eq $foldV } | Select-Object -First 1
    if ($foldI) { $fFold.SelectedItem = $foldI }

    $qtI = $fQuantTier.Items | Where-Object { $_.Content -eq $m.quant_tier } | Select-Object -First 1
    if ($qtI) { $fQuantTier.SelectedItem = $qtI }

    $s = $m.sampling
    $fTemperature.Text = [string]$s.temperature
    $fRepPenalty.Text  = [string]$s.repeat_penalty
    $fRepLastN.Text    = [string]$s.repeat_last_n
    $fStop.Text        = if ($s.stop) { ($s.stop -join ', ') } else { '' }

    $jp = Join-Path $script:Micronauts "$($m.name).json"
    if (Test-Path $jp) {
        try {
            $full = Get-Content $jp -Raw | ConvertFrom-Json
            $fSystem.Text = if ($full.system) { $full.system } else { '' }
            if ($full.capabilities) { $fCapabilities.Text = ($full.capabilities -join ', ') }
        } catch {}
    }

    @("mm-$($m.name).bin","$($m.name).bin") |
    ForEach-Object {
        $p = Join-Path $script:RepoModels "tokens\$_"
        if (Test-Path $p) { $fTokenBin.Text = $p; return }
    }

    $factoryStatus.Text = "Editing: $($m.name) -- modify and click Create to save"
    $mainTab.SelectedIndex = 0
})

$trainEvoBtn.Add_Click({
    $sel = $micronautList.SelectedItem
    if (-not $sel -or -not $sel.Tag) { return }
    $m  = $sel.Tag
    $st = Get-MicronautStatus $m.name
    if (-not $st.HasBin) {
        [System.Windows.MessageBox]::Show("No token bin found for '$($m.name)'.`nAdd one in the Factory tab.",'Train','OK','Warning') | Out-Null
        return
    }
    $base = if ($st.Ckpts.Count -gt 0) {
        ($st.Ckpts | Sort-Object Name | Select-Object -Last 1).FullName
    } else {
        $fb = Join-Path $script:RepoModels 'trained\from_zero_v0.6_merged.safetensors'
        if (Test-Path $fb) { $fb } else { $fBaseModel.Text.Trim() }
    }
    $steps   = 500
    $outPath = Join-Path $script:RepoModels "trained\mm-$($m.name)_step$steps.safetensors"
    Launch-Training -InputModel $base -DataBin $st.BinPath -OutputModel $outPath -Steps $steps -Lr 0.00003 -Label $m.name
})

$promoteBtn.Add_Click({
    $sel = $micronautList.SelectedItem
    if (-not $sel -or -not $sel.Tag) { return }
    $m  = $sel.Tag
    $st = Get-MicronautStatus $m.name
    if ($st.Ckpts.Count -eq 0) {
        Add-TrainLog "[$([datetime]::Now.ToString('HH:mm:ss'))] No checkpoints to promote for $($m.name)"
        $mainTab.SelectedIndex = 2; return
    }
    $latest = ($st.Ckpts | Sort-Object Name | Select-Object -Last 1).FullName
    $dest   = Join-Path ([System.IO.Path]::GetDirectoryName($latest)) "mm-$($m.name).safetensors"
    Copy-Item $latest $dest -Force
    Add-TrainLog "[$([datetime]::Now.ToString('HH:mm:ss'))] Promoted $([System.IO.Path]::GetFileName($latest)) -> mm-$($m.name).safetensors"
    Populate-EvolutionList
    $mainTab.SelectedIndex = 2
})

$inspectBtn.Add_Click({
    $sel = $micronautList.SelectedItem
    if (-not $sel -or -not $sel.Tag) { return }
    $m = $sel.Tag
    $jp = Join-Path $script:Micronauts "$($m.name).json"
    $jsonPreview.Text = if (Test-Path $jp) { Get-Content $jp -Raw } else { ConvertTo-Json ([pscustomobject]$m) -Depth 6 }
})

$deleteEvoBtn.Add_Click({
    $sel = $micronautList.SelectedItem
    if (-not $sel -or -not $sel.Tag) { return }
    $m   = $sel.Tag
    $res = [System.Windows.MessageBox]::Show("Remove '$($m.name)' from registry?`n(Files on disk are kept.)",'Remove','YesNo','Warning')
    if ($res -ne 'Yes') { return }
    Save-Registry @(Load-Registry | Where-Object { $_.name -ne $m.name })
    Populate-EvolutionList
})

# ── gpt2_trainer.exe launcher ─────────────────────────────────────────────────
function Launch-Training {
    param(
        [string]$InputModel,
        [string]$DataBin,
        [string]$OutputModel,
        [int]$Steps = 500,
        [double]$Lr = 0.00003,
        [string]$Label = 'micronaut'
    )

    if ($script:NativeProcess -and -not $script:NativeProcess.HasExited) {
        Add-TrainLog "[$([datetime]::Now.ToString('HH:mm:ss'))] trainer already running pid=$($script:NativeProcess.Id)"
        $mainTab.SelectedIndex = 2; return
    }
    if (-not (Test-Path $script:TrainerExe)) {
        Add-TrainLog "[$([datetime]::Now.ToString('HH:mm:ss'))] ERROR: gpt2_trainer.exe not found"
        $mainTab.SelectedIndex = 2; return
    }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName         = $script:TrainerExe
    $psi.Arguments        = "--model `"$InputModel`" --data `"$DataBin`" --out `"$OutputModel`" --steps $Steps --batch 4 --block 128 --lr $Lr --save-every 200"
    $psi.WorkingDirectory = $script:TrainerWork
    $psi.UseShellExecute  = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError  = $true
    $psi.CreateNoWindow   = $true

    $proc = [System.Diagnostics.Process]::new()
    $proc.StartInfo           = $psi
    $proc.EnableRaisingEvents = $true

    $q = $script:OutputQueue
    Register-ObjectEvent -InputObject $proc -EventName OutputDataReceived -Action {
        if ($EventArgs.Data) { $q.Enqueue($EventArgs.Data) }
    } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName ErrorDataReceived -Action {
        if ($EventArgs.Data) { $q.Enqueue($EventArgs.Data) }
    } | Out-Null
    Register-ObjectEvent -InputObject $proc -EventName Exited -Action {
        $code = $Event.Sender.ExitCode
        $q.Enqueue("--- training finished  exit=$code ---")
        $script:NativeProcess = $null
    } | Out-Null

    if (-not $proc.Start()) {
        Add-TrainLog "[$([datetime]::Now.ToString('HH:mm:ss'))] ERROR: failed to start gpt2_trainer.exe"
        return
    }
    $proc.BeginOutputReadLine()
    $proc.BeginErrorReadLine()
    $script:NativeProcess = $proc

    $outN = [System.IO.Path]::GetFileName($OutputModel)
    $binN = [System.IO.Path]::GetFileName($DataBin)
    $inN  = [System.IO.Path]::GetFileName($InputModel)
    $trainStatus.Text = "Training $Label   pid=$($proc.Id)   steps=$Steps   out=$outN"
    Add-TrainLog "[$([datetime]::Now.ToString('HH:mm:ss'))] started  pid=$($proc.Id)  model=$inN  data=$binN  steps=$Steps"

    Start-TrainTimer
    $mainTab.SelectedIndex = 2
}

$stopTrainBtn.Add_Click({
    if ($script:NativeProcess -and -not $script:NativeProcess.HasExited) {
        try { $script:NativeProcess.Kill() } catch {}
        Add-TrainLog "[$([datetime]::Now.ToString('HH:mm:ss'))] stop requested"
    }
})
$clearLogBtn.Add_Click({ $trainLog.Items.Clear() })

# ── kuhul health probe ────────────────────────────────────────────────────────
function Test-Kuhul {
    $ok = $false
    $activePort = 17474
    $amPath = Join-Path $script:RepoRoot 'active-model.json'
    if (Test-Path $amPath) {
        try { $am = Get-Content $amPath -Raw | ConvertFrom-Json; if ($am.port) { $activePort = $am.port } } catch {}
    }
    foreach ($candidate in @($activePort, 8764, 17474)) {
        foreach ($path in @('/health', '/v1/models')) {
            try { Invoke-RestMethod -Uri "http://127.0.0.1:$candidate$path" -Method Get -TimeoutSec 2 | Out-Null; $ok = $true; break } catch {}
        }
        if ($ok) { $activePort = $candidate; break }
    }
    $kuhulDot.Fill    = if ($ok) { [System.Windows.Media.Brushes]::Lime } else { [System.Windows.Media.Brushes]::OrangeRed }
    $kuhulStatus.Text = if ($ok) { "kuhul:$activePort  OK" } else { 'kuhul  --' }
}

$window.Add_Closed({
    if ($script:TrainTimer) { try { $script:TrainTimer.Stop() } catch {} }
    if ($script:NativeProcess -and -not $script:NativeProcess.HasExited) {
        try { $script:NativeProcess.Kill() } catch {}
    }
})

# ── Startup ───────────────────────────────────────────────────────────────────
Clear-Form
Test-Kuhul
Populate-EvolutionList
$window.ShowDialog() | Out-Null
