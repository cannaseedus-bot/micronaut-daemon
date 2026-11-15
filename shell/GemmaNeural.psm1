#Requires -Version 5.1
# Local Gemma 3 text generation. Model output carries no source or execution authority.
$script:GemmaEndpoint = 'http://127.0.0.1:8091'

function Test-GemmaNeuralHealth {
    try {
        $health = Invoke-RestMethod "$script:GemmaEndpoint/health" -TimeoutSec 2
        return $health.status -eq 'ok'
    } catch { return $false }
}

function Invoke-GemmaNeuralCompletion {
    param([Parameter(Mandatory)][string]$System,
          [Parameter(Mandatory)][string]$Prompt,
          [ValidateRange(16,512)][int]$MaxTokens = 256)
    if (-not $Prompt.Trim() -or $Prompt.Length -gt 8192) { throw 'Gemma prompt must be 1..8192 characters.' }
    if (-not (Test-GemmaNeuralHealth)) { throw 'Local Gemma server is unavailable; start gemma.bat.' }
    $body = @{
        model = 'gemma-3-1B-it-QAT-Q4_0.gguf'
        messages = @(@{ role = 'system'; content = $System }, @{ role = 'user'; content = $Prompt })
        temperature = 0.2
        max_tokens = $MaxTokens
        stream = $false
    } | ConvertTo-Json -Depth 10 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($body)
    $result = Invoke-RestMethod "$script:GemmaEndpoint/v1/chat/completions" -Method Post `
        -Body $bytes -ContentType 'application/json; charset=utf-8' -TimeoutSec 120
    $content = [string]$result.choices[0].message.content
    if (-not $content.Trim()) { throw 'Local Gemma returned no text.' }
    return $content.Trim()
}

function Invoke-GemmaNeuralContinuation {
    param([Parameter(Mandatory)][string]$Prompt, [array]$Hits = @(), [switch]$CodeMode,
          [hashtable]$CfpcRoute = @{})
    $context = @($Hits | Select-Object -First 3 | ForEach-Object {
        $pattern = [string]$_.pattern
        $rowId = [string]$_.row_id
        "row $rowId pattern: $($pattern.Substring(0,[Math]::Min($pattern.Length,180)))"
    }) -join "`n"
    if (-not $context) { $context = '(no verified source passage)' }
    $cfpcContext = '(no CFPC pattern matched)'
    if ($CfpcRoute.Count -gt 0) {
        $slots = ($CfpcRoute.captures.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" }) -join ', '
        $templates = @($CfpcRoute.question_templates) -join ' | '
        $contractContext = [string]$CfpcRoute.context_template
        $cfpcContext = "intent=$($CfpcRoute.id); phase=$($CfpcRoute.phase); captures={$slots}; max_hops=$($CfpcRoute.max_hops); question_templates={$templates}; contract_context={$contractContext}; epistemic_state=UNKNOWN; route hints are not evidence"
    }
    $system = if ($CodeMode) {
        'You are a local coding assistant. Generate the requested code and return exactly one fenced code block with a language label, with no surrounding explanation. Keep code self-contained. Treat retrieved patterns as unverified context. Never claim the code was compiled, executed, or admitted.'
    } else {
        'You are a local Gemma continuation after vector retrieval. Answer briefly. Treat retrieved patterns as context, not verified facts. If evidence is missing, state uncertainty. Do not claim that a factory proposal or graph edge is authorized.'
    }
    $text = Invoke-GemmaNeuralCompletion -System $system -Prompt "Question: $Prompt`nCFPC pattern route: $cfpcContext`nRetrieved candidate patterns:`n$context" -MaxTokens 256
    return [pscustomobject]@{ schema = 'micronaut.gemma-neural-continuation.v1';
        authority = 'model_output_unverified'; selection = 'gemma_neural_local';
        model = 'gemma-3-1B-it-QAT-Q4_0.gguf'; text = $text }
}

Export-ModuleMember -Function Test-GemmaNeuralHealth,Invoke-GemmaNeuralCompletion,Invoke-GemmaNeuralContinuation
