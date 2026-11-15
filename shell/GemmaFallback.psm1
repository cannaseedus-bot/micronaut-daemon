#Requires -Version 5.1
# Host handoff for a verified retrieval miss. GEMMA-µ is rank-only.
function Resolve-GemmaRankFallback {
    param([Parameter(Mandatory)][string]$Prompt,
          [Parameter(Mandatory)][hashtable]$Trace,
          [Parameter(Mandatory)][AllowEmptyString()][string]$ExistingText)
    if ($Trace.selection -ne 'existing_aiml') {
        return [pscustomobject]@{ text=$ExistingText; trace=$Trace }
    }
    if (-not [string]::IsNullOrWhiteSpace($ExistingText) -and
        $ExistingText.Trim() -ne "I don't know.") {
        $Trace.response_source = 'aiml_corpus'
        return [pscustomobject]@{ text=$ExistingText; trace=$Trace }
    }
    $contractPath = Join-Path (Split-Path $PSScriptRoot -Parent) 'build/gemma-rank-fallback.v1.json'
    $digest = (Get-FileHash -LiteralPath $contractPath -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($digest -ne 'e8228f40b6beaffea974f11fd6de6d98f4e755ca3658962e363ac0b566e437bb') {
        throw 'GEMMA-µ fallback contract is not host-pinned.'
    }
    $contract = if ($PSVersionTable.PSVersion.Major -ge 7) {
        Get-Content -LiteralPath $contractPath -Raw | ConvertFrom-Json -AsHashtable
    } else {
        Add-Type -AssemblyName System.Web.Extensions
        $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
        $serializer.DeserializeObject((Get-Content -LiteralPath $contractPath -Raw))
    }
    if ($contract.schema -ne 'micronaut.gemma-rank-fallback.v1' -or
        $contract.track -ne 'GEMMA-µ' -or
        $contract.authority -ne 'host_selected_read_only' -or
        $contract.trigger -ne 'existing_aiml_after_verified_retrieval' -or
        $contract.selection -ne 'gemma_mu_no_verified_answer' -or
        $contract.response -ne 'explicit_no_verified_answer' -or
        $contract.mutation -ne $false) { throw 'Invalid GEMMA-µ fallback contract.' }
    if (-not $Trace.verified -or -not $Trace.attestation_verified -or
        -not $Trace.retrieval_verified -or -not $Trace.proposal.verified -or
        $Trace.proposal.mode -ne 'fallback') {
        throw 'GEMMA-µ fallback lacks verified retrieval and policy evidence.'
    }
    $safe = $Prompt.Trim()
    if ($safe.Length -gt 160) { $safe = $safe.Substring(0,160) + '…' }
    $Trace.selection = 'gemma_mu_no_verified_answer'
    $Trace.track = 'GEMMA-µ'
    $Trace.fallback_reason = [string]$Trace.proposal.decision.rule
    $Trace.fallback_contract_sha256 = $digest
    return [pscustomobject]@{
        text = "I couldn't find a verified answer for '$safe' in the current AIML/vector store."
        trace = $Trace
    }
}
Export-ModuleMember -Function Resolve-GemmaRankFallback
