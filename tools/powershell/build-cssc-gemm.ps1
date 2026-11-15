[CmdletBinding()]
param(
    [string]$Source = (Join-Path $PSScriptRoot '..\.CSS-C\native\cssc_matmul_run.cpp'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '..\build\css-c-native'),
    [string]$VsInstallPath = ''
)

$ErrorActionPreference = 'Stop'
$sourcePath = (Resolve-Path -LiteralPath $Source).Path
$outputPath = [IO.Path]::GetFullPath($OutputDirectory)
if (-not (Test-Path -LiteralPath $outputPath -PathType Container)) {
    New-Item -ItemType Directory -Path $outputPath -Force | Out-Null
}

if (-not (Get-Command cl.exe -ErrorAction SilentlyContinue)) {
    if (-not $VsInstallPath) {
        $vswhere = 'C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe'
        if (-not (Test-Path -LiteralPath $vswhere -PathType Leaf)) {
            throw 'Visual Studio vswhere.exe was not found. Pass -VsInstallPath or start from an x64 Developer PowerShell.'
        }
        $VsInstallPath = (& $vswhere -latest -products '*' -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath | Select-Object -First 1)
        if (-not $VsInstallPath) { throw 'No Visual Studio installation with x64 C++ tools was found.' }
    }

    $devShell = Join-Path $VsInstallPath 'Common7\Tools\Microsoft.VisualStudio.DevShell.dll'
    if (-not (Test-Path -LiteralPath $devShell -PathType Leaf)) { throw "Visual Studio developer shell not found: $devShell" }
    Import-Module -Name $devShell -ErrorAction Stop
    Enter-VsDevShell -VsInstallPath $VsInstallPath -DevCmdArguments '-arch=x64 -host_arch=x64' -SkipAutomaticLocation
}

$exePath = Join-Path $outputPath 'cssc_matmul_run.exe'
$objectPath = Join-Path $outputPath 'cssc_matmul_run.obj'
& cl.exe /nologo /std:c++17 /EHsc /O2 /DNDEBUG "/Fo$objectPath" "/Fe$exePath" $sourcePath d3d11.lib d3dcompiler.lib dxguid.lib
if ($LASTEXITCODE -ne 0) { throw "CSS-C GEMM compilation failed with exit code $LASTEXITCODE." }

Get-Item -LiteralPath $exePath | Select-Object FullName, Length
