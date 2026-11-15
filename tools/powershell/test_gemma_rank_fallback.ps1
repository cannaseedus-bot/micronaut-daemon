#Requires -Version 7
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../shell/GemmaFallback.psm1') -Force
$trace = @{
    selection='existing_aiml'; verified=$true; attestation_verified=$true;
    retrieval_verified=$true; proposal=@{
        verified=$true; mode='fallback'; decision=@{ rule='semantic_top_two_margin' }
    }
}
$answer = Resolve-GemmaRankFallback -Prompt 'what is organics' -Trace $trace `
    -ExistingText 'Let me think about it.'
if ($answer.trace.selection -ne 'gemma_mu_no_verified_answer' -or
    $answer.trace.track -ne 'GEMMA-µ' -or
    $answer.text -match 'Let me think about it' -or
    $answer.text -notmatch 'what is organics') { throw 'Verified miss did not route to GEMMA-µ.' }
$bad = @{ selection='existing_aiml'; verified=$true; attestation_verified=$true;
    retrieval_verified=$false; proposal=@{ verified=$true; mode='fallback'; decision=@{rule='no_hit'} } }
try {
    Resolve-GemmaRankFallback -Prompt 'x' -Trace $bad -ExistingText 'bad' | Out-Null
    throw 'Unverified fallback was accepted.'
} catch {
    if ($_.Exception.Message -eq 'Unverified fallback was accepted.') { throw }
}
Write-Output 'GEMMA-µ verified miss handoff and unverified rejection passed'
