[CmdletBinding()]
param(
    [string]$InputSvg = (Join-Path $PSScriptRoot '..\data\apps\kuhul-infographic.svg'),
    [string]$OutputPng = (Join-Path $PSScriptRoot '..\data\apps\kuhul-infographic.png'),
    [string]$PowernautModule = (Join-Path $env:USERPROFILE '.Powernaut-v1.0.0\Kuhul3D.psm1')
)

$ErrorActionPreference = 'Stop'
$svgPath = (Resolve-Path -LiteralPath $InputSvg).Path
$pngPath = [IO.Path]::GetFullPath($OutputPng)
$modulePath = (Resolve-Path -LiteralPath $PowernautModule).Path
Import-Module -Name $modulePath -Force -ErrorAction Stop

$scene = ConvertFrom-K3DSvg -Svg ([IO.File]::ReadAllText($svgPath))
$viewBox = ([string]$scene.attrs.viewBox) -split '[ ,]+' | Where-Object { $_ }
if ($viewBox.Count -lt 4) { throw 'The SVG root needs a valid viewBox.' }
$scene.attrs.width = [double]$viewBox[2]
$scene.attrs.height = [double]$viewBox[3]
$scene.style.fill = '#07111f'

function Set-K3DTextStyle($node) {
    if ($node.type -eq 'text') {
        $classes = ([string]$node.attrs.class).Split(' ', [StringSplitOptions]::RemoveEmptyEntries)
        $fontSize = if ($node.attrs.Contains('font-size')) { [double]([string]$node.attrs['font-size'] -replace 'px','') } else { 22 }
        $fontWeight = if ($node.attrs.Contains('font-weight')) { [string]$node.attrs['font-weight'] } else { 'normal' }
        if ($classes -contains 'caps') { $fontSize = 22; $fontWeight = 'bold' }
        elseif ($classes -contains 'title') { $fontSize = 62; $fontWeight = 'bold' }
        elseif ($classes -contains 'subtitle') { $fontSize = 30 }
        elseif ($classes -contains 'phase') { $fontSize = 32; $fontWeight = 'bold' }
        elseif ($classes -contains 'label') { $fontSize = 24 }

        $node.style.fontSize = $fontSize
        $node.style.fontFamily = 'Segoe UI'
        $node.style.fontWeight = $fontWeight
        if ($classes -contains 'teal') { $node.style.fill = '#76e1d0' }
        if ($classes -contains 'muted') { $node.style.fill = '#b5c6da' }
        if ($node.attrs.Contains('fill')) { $node.style.fill = [string]$node.attrs.fill }
        if ($node.attrs.Contains('y')) { $node.attrs.y = [double]$node.attrs.y - $fontSize }
    }
    foreach ($child in @($node.children)) {
        if ($child -is [System.Collections.IDictionary]) { Set-K3DTextStyle $child }
    }
}

Set-K3DTextStyle $scene
$outputDirectory = Split-Path -Parent $pngPath
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$scene | Export-K3DFrame -Path $pngPath | Out-Null
Get-Item -LiteralPath $pngPath | Select-Object FullName, Length
