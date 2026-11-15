#Requires -Version 7
param([Parameter(Mandatory)][string]$Prompt,[int]$TopK=5)
$ErrorActionPreference='Stop'
$root=(Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$launcher=Join-Path $root 'tools/gemma_bridge_host.ps1'
$cli=Join-Path $root 'build/gml-stage1/Release/gemma_bridge_request_cli.exe'
$attested=(@(& $launcher -Mode Attest -Utterance $Prompt) -join "`n")|ConvertFrom-Json -AsHashtable
$attested.utterance=$Prompt
$attested.top_k=$TopK
$bridge=(@(($attested|ConvertTo-Json -Depth 20 -Compress)|& $cli) -join "`n")|ConvertFrom-Json -AsHashtable
@($bridge.retrieval.hits|ForEach-Object {
    [pscustomobject]@{row=$_.row_id;score=[math]::Round($_.pattern_score,6);pattern=$_.pattern;
        template=([string]$_.template).Substring(0,[math]::Min(100,([string]$_.template).Length))}
})|ConvertTo-Json -Depth 4 -Compress
