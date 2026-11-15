#Requires -Version 7
$ErrorActionPreference = 'Stop'
$file = (Resolve-Path (Join-Path $PSScriptRoot '../Micronaut.ps1')).Path
$tokens = $null
$errors = $null
[System.Management.Automation.Language.Parser]::ParseFile($file,[ref]$tokens,[ref]$errors) | Out-Null
if ($errors.Count) { throw (($errors | ForEach-Object Message) -join '; ') }
$source = [IO.File]::ReadAllText($file)
$begin = $source.IndexOf('[xml]$xaml = @"')
$end = $source.IndexOf('"@', $begin + 15)
if ($begin -lt 0 -or $end -lt 0) { throw 'XAML block not found.' }
$body = $source.Substring($begin + 15, $end - $begin - 15)
[xml]$xaml = $body
Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase
$reader = [Xml.XmlNodeReader]::new($xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
foreach ($name in @('HistoryPanel','NewChatBtn','BindingsBtn','ProfileName','Feed','InputBox')) {
    if (-not $window.FindName($name)) { throw "Missing WPF control: $name" }
}
Write-Output 'Micronaut WPF syntax and XAML passed'
