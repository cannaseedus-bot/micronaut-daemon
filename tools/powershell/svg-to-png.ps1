[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InputSvg,
    [Parameter(Mandatory)][string]$OutputPng,
    [ValidateRange(64,12000)][int]$Width = 2400
)

$ErrorActionPreference = 'Stop'
$source = (Resolve-Path -LiteralPath $InputSvg).Path
$destination = [IO.Path]::GetFullPath($OutputPng)
$outputDirectory = [IO.Path]::GetDirectoryName($destination)
if (-not (Test-Path -LiteralPath $outputDirectory -PathType Container)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}
$readerSettings = [Xml.XmlReaderSettings]::new()
$readerSettings.DtdProcessing = [Xml.DtdProcessing]::Prohibit
$readerSettings.XmlResolver = $null
$stream = [IO.File]::OpenRead($source)
try {
    $xmlReader = [Xml.XmlReader]::Create($stream, $readerSettings)
    try { $document = [Xml.XmlDocument]::new(); $document.XmlResolver = $null; $document.Load($xmlReader) }
    finally { $xmlReader.Dispose() }
} finally { $stream.Dispose() }
$viewBox = ([string]$document.DocumentElement.GetAttribute('viewBox')) -split '[ ,]+' | Where-Object { $_ }
if ($viewBox.Count -ge 4 -and [double]$viewBox[3] -gt 0) {
    $aspectRatio = [double]$viewBox[2] / [double]$viewBox[3]
} else {
    throw 'SVG needs a positive viewBox to preserve its aspect ratio during export.'
}
$height = [int][Math]::Round($Width / $aspectRatio)

$inkscape = Get-Command -Name 'inkscape.exe' -ErrorAction SilentlyContinue
$inkscapePath = if ($null -ne $inkscape) { $inkscape.Source } else { $null }
if (-not $inkscapePath) {
    foreach ($candidate in @(
        'C:\Program Files\Inkscape\bin\inkscape.exe',
        'C:\Program Files (x86)\Inkscape\bin\inkscape.exe'
    )) {
        if (Test-Path -LiteralPath $candidate -PathType Leaf) { $inkscapePath = $candidate; break }
    }
}

if ($inkscapePath) {
    & $inkscapePath --export-type=png "--export-filename=$destination" "--export-width=$Width" $source
    if ($LASTEXITCODE -ne 0) { throw "Inkscape SVG export failed with exit code $LASTEXITCODE." }
} else {
    $magick = Get-Command -Name 'magick.exe' -ErrorAction SilentlyContinue
    if ($null -eq $magick) { $magick = Get-Command -Name 'magick' -ErrorAction SilentlyContinue }
    if ($null -ne $magick) {
        & $magick.Source -background none -density 144 $source -resize "${Width}x" $destination
        if ($LASTEXITCODE -ne 0) { throw "ImageMagick SVG export failed with exit code $LASTEXITCODE." }
    } else {
        $browserPath = $null
        foreach ($browserName in @('chrome.exe','msedge.exe')) {
            $browser = Get-Command -Name $browserName -ErrorAction SilentlyContinue
            if ($null -ne $browser) { $browserPath = $browser.Source; break }
        }
        if (-not $browserPath) {
            foreach ($candidate in @(
                'C:\Program Files\Google\Chrome\Application\chrome.exe',
                'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
                'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
                'C:\Program Files\Microsoft\Edge\Application\msedge.exe'
            )) {
                if (Test-Path -LiteralPath $candidate -PathType Leaf) { $browserPath = $candidate; break }
            }
        }
        if (-not $browserPath) {
            throw 'SVG conversion needs Inkscape, ImageMagick, or Microsoft Edge. Install a renderer or add its executable to PATH.'
        }
        if (Test-Path -LiteralPath $destination -PathType Leaf) { Remove-Item -LiteralPath $destination -Force }
        $preview = Join-Path $outputDirectory ".svg-preview-$PID.html"
        $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
        $profile = [IO.Path]::GetFullPath((Join-Path $tempRoot ".svg-render-profile-$PID"))
        if (-not $profile.StartsWith($tempRoot, [StringComparison]::OrdinalIgnoreCase)) { throw 'Temporary browser profile escaped the temp directory.' }
        $uri = ([Uri]$source).AbsoluteUri
        $html = "<!doctype html><html><head><meta charset='utf-8'><style>*{box-sizing:border-box}html,body{margin:0;width:100%;height:100%;overflow:hidden;background:transparent}img{display:block;width:100%;height:100%;object-fit:contain}</style></head><body><img src='$uri'></body></html>"
        try {
            [IO.File]::WriteAllText($preview, $html, [Text.UTF8Encoding]::new($false))
            $previewUri = ([Uri]$preview).AbsoluteUri
            & $browserPath '--headless=new' '--disable-gpu' '--hide-scrollbars' '--no-first-run' "--user-data-dir=$profile" "--window-size=$Width,$height" "--screenshot=$destination" $previewUri
            $deadline = [DateTime]::UtcNow.AddSeconds(15)
            while (-not (Test-Path -LiteralPath $destination -PathType Leaf) -and [DateTime]::UtcNow -lt $deadline) {
                Start-Sleep -Milliseconds 250
            }
            if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) { throw 'Headless browser did not produce the PNG before timeout.' }
        } finally {
            Remove-Item -LiteralPath $preview -Force -ErrorAction SilentlyContinue
            Remove-Item -LiteralPath $profile -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}

if (-not (Test-Path -LiteralPath $destination -PathType Leaf)) { throw 'SVG converter reported success but produced no PNG.' }
Get-Item -LiteralPath $destination | Select-Object FullName,Length
