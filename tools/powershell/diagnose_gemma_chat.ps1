#Requires -Version 7
param([Parameter(Mandatory)][string]$Prompt,[int]$Port=9883)
$ErrorActionPreference='Stop'
$module=(Resolve-Path (Join-Path $PSScriptRoot '../shell/Server.psm1')).Path
$token=[guid]::NewGuid().ToString('N')
$base="http://127.0.0.1:$Port"
$job=Start-ThreadJob -ScriptBlock {
    param($m,$p,$t) Import-Module $m -Force; Start-MicronautBusServer -Port $p -ShutdownToken $t
} -ArgumentList $module,$Port,$token
try {
    $ready=$false
    for($i=0;$i -lt 40;$i++){
        try { $null=Invoke-RestMethod "$base/health" -TimeoutSec 1;$ready=$true;break }
        catch { Start-Sleep -Milliseconds 200 }
    }
    if(-not $ready){throw 'Bus not ready'}
    $body=@{prompt=$Prompt}|ConvertTo-Json -Compress
    try {
        $answer=Invoke-RestMethod "$base/api/chat" -Method Post -Body $body -ContentType 'application/json' -TimeoutSec 240
        $trace=$answer.trace
        [pscustomobject]@{
            prompt=$Prompt; text=$answer.text; selection=$trace.selection;
            mode=$trace.proposal.mode; reason=$trace.proposal.reason;
            rule=$trace.proposal.decision.rule;
            top_score=$trace.proposal.decision.top_score;
            runner_up=$trace.proposal.decision.runner_up_score;
            retrieval_verified=$trace.retrieval_verified;
            attestation_verified=$trace.attestation_verified;
            row_id=$trace.row_id
        } | ConvertTo-Json -Depth 5 -Compress
    } catch {
        $response=$_.ErrorDetails.Message
        [pscustomobject]@{prompt=$Prompt;error=$_.Exception.Message;body=$response}|
            ConvertTo-Json -Depth 5 -Compress
    }
} finally {
    try { Invoke-RestMethod "$base/_internal/shutdown" -Method Post -Body '{}' -Headers @{'X-Micronaut-Shutdown'=$token} -ContentType 'application/json' -TimeoutSec 3 | Out-Null } catch {}
    if($job.State -in 'Completed','Failed','Stopped'){Remove-Job $job -Force -ErrorAction SilentlyContinue}
}
