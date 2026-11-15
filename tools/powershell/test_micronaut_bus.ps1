#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
$module = (Resolve-Path (Join-Path $PSScriptRoot '../shell/Server.psm1')).Path
$token = [guid]::NewGuid().ToString('N')
$port = 9881
$base = "http://127.0.0.1:$port"
$job = $null
$hostProcess = $null
if ($PSVersionTable.PSVersion.Major -lt 7) {
    $hostScript = (Resolve-Path (Join-Path $PSScriptRoot 'run_micronaut_bus_test_host.ps1')).Path
    $hostProcess = Start-Process -FilePath (Get-Command powershell.exe).Source -WindowStyle Hidden `
        -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File',$hostScript,
            '-Port',[string]$port,'-ShutdownToken',$token) -PassThru
} else {
    $job = Start-ThreadJob -ScriptBlock {
        param($modulePath,$listenPort,$shutdownToken)
        Import-Module $modulePath -Force
        Start-MicronautBusServer -Port $listenPort -ShutdownToken $shutdownToken
    } -ArgumentList $module,$port,$token
}
try {
    $ready = $false
    for ($i=0; $i -lt 40; $i++) {
        try {
            $health = Invoke-RestMethod "$base/health" -TimeoutSec 1
            if ($health.schema -eq 'micronaut.bus.health.v1') { $ready = $true; break }
        } catch { Start-Sleep -Milliseconds 200 }
    }
    if (-not $ready) {
        $jobOutput = if ($job) { Receive-Job $job -ErrorAction Continue 2>&1 | Out-String } else { "Host process exited: $($hostProcess.HasExited)" }
        throw "Bus did not become ready. $jobOutput"
    }
    $bindings = Invoke-RestMethod "$base/api/bindings" -TimeoutSec 3
    if (-not (@($bindings.modules.name) -contains 'gemma.bindings')) { throw 'Gemma binding not discovered.' }
    $refreshed = Invoke-RestMethod "$base/api/bindings/refresh" -Method Post -Body '{}' `
        -ContentType 'application/json' -TimeoutSec 3
    if (-not (@($refreshed.registered) -contains 'vector.identity')) { throw 'Binding refresh lost registered routes.' }
    $identity = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"gemma.identity"}' -ContentType 'application/json' -TimeoutSec 5
    if (-not $identity.result.id.StartsWith('GEMMA-')) { throw 'Gemma binding invocation failed.' }
    $vectorIdentity = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"vector.identity"}' -ContentType 'application/json' -TimeoutSec 5
    if (-not $vectorIdentity.result.id.StartsWith('VECTOR-')) { throw 'Vector binding invocation failed.' }
    $topology = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"key-grammar.topology"}' -ContentType 'application/json' -TimeoutSec 10
    if ($topology.result.schema -ne 'micronaut.key-grammar-topology.v1' -or
        @($topology.result.bindings).Count -lt 5 -or
        @($topology.result.bindings | Where-Object { -not $_.binariesMatch }).Count -ne 0) {
        throw 'Key grammar topology binding failed.'
    }
    $resolved = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"key-grammar.resolve","key":"\u27c1GRAMMAR:GML"}' `
        -ContentType 'application/json' -TimeoutSec 10
    if ($resolved.result.buildTarget -ne 'build/gml-stage1/Release/gml.exe' -or
        $resolved.result.executable) { throw 'Key grammar resolution failed.' }
    $ranked = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"key-grammar.rank","prompt":"hello","topK":3}' `
        -ContentType 'application/json' -TimeoutSec 240
    if ($ranked.result.schema -ne 'micronaut.key-grammar-field-ranking.v1' -or
        @($ranked.result.hits).Count -ne 3 -or
        $ranked.result.hits[0].score -lt $ranked.result.hits[1].score) {
        throw 'Key grammar field ranking failed.'
    }
    $created = Invoke-RestMethod "$base/api/sessions" -Method Post -Body '{}' `
        -ContentType 'application/json' -TimeoutSec 3
    $body = @{ prompt = 'WHO CREATED AIML'; sessionId = $created.sessionId } | ConvertTo-Json -Compress
    $answer = Invoke-RestMethod "$base/api/chat" -Method Post -Body $body `
        -ContentType 'application/json' -TimeoutSec 240
    if (-not $answer.text -or -not $answer.trace.attestation_verified -or
        -not $answer.trace.retrieval_verified) { throw 'Gemma chat response was not verified.' }
    $mathBody = @{ prompt = 'What is 5*25='; sessionId = $created.sessionId } | ConvertTo-Json -Compress
    $mathAnswer = Invoke-RestMethod "$base/api/chat" -Method Post -Body $mathBody `
        -ContentType 'application/json' -TimeoutSec 10
    if ($mathAnswer.text -ne '5*25 = 125' -or
        -not $mathAnswer.trace.selection.StartsWith('ARITHMETIC:local_eval') -or
        $mathAnswer.trace.mathml -notmatch '<times/>') { throw 'MathML chat route failed.' }
    $greetingBody = @{ prompt = 'hello'; sessionId = $created.sessionId } | ConvertTo-Json -Compress
    $greeting = Invoke-RestMethod "$base/api/chat" -Method Post -Body $greetingBody `
        -ContentType 'application/json' -TimeoutSec 240
    if ($greeting.source -ne 'key_grammar' -or
        $greeting.trace.selection -ne 'verified_literal_greeting' -or
        $greeting.trace.key -ne 'GREETING:POP:1') { throw 'Key grammar greeting response failed.' }
    $controlBody = @{ prompt = 'what does if mean'; sessionId = $created.sessionId } | ConvertTo-Json -Compress
    $control = Invoke-RestMethod "$base/api/chat" -Method Post -Body $controlBody `
        -ContentType 'application/json' -TimeoutSec 240
    if ($control.source -ne 'key_grammar' -or
        $control.trace.selection -ne 'verified_control_description' -or
        $control.trace.key -ne 'control:if' -or
        $control.text -notmatch 'if <condition> then <consequence>') {
        throw 'Key grammar control description failed.'
    }
    $history = Invoke-RestMethod "$base/api/history?sessionId=$($created.sessionId)" -TimeoutSec 3
    if (@($history.messages).Count -ne 8 -or $history.messages[0].role -ne 'user' -or
        $history.messages[7].role -ne 'assistant') { throw 'Chat history is incomplete.' }
    $neuralHealth = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"gemma.neural.health"}' -ContentType 'application/json' -TimeoutSec 5
    $neuralIdentity = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"gemma.neural.identity"}' -ContentType 'application/json' -TimeoutSec 5
    if ($neuralIdentity.result.authority -ne 'model_output_unverified' -or
        $neuralIdentity.result.route -ne 'neural_local_v1' -or
        $identity.result.authority_claim -ne 'rank_only') {
        throw 'Gemma ranker and neural continuation identities are conflated.'
    }
    $coderCompile = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"coder.grammar","operation":"compile","language":"cpp"}' `
        -ContentType 'application/json' -TimeoutSec 10
    if ($coderCompile.result.token_count -lt 1 -or
        $coderCompile.result.authority -ne 'validation_only') { throw 'CODER grammar compile failed.' }
    $coderGenerate = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body '{"name":"coder.grammar","operation":"generate","language":"typescript","identifier":"demo"}' `
        -ContentType 'application/json' -TimeoutSec 10
    if ($coderGenerate.result.authority -ne 'proposal_only' -or
        @($coderGenerate.result.parsed.nodes | Where-Object { $_.type -eq 'function_decl' }).Count -lt 1) {
        throw 'CODER grammar generation and parse failed.'
    }
    $astRequest = @{ name = 'coder.grammar'; operation = 'validate_ast'; language = 'typescript';
        source = $coderGenerate.result.source; ast = $coderGenerate.result.parsed } | ConvertTo-Json -Depth 20 -Compress
    $astCheck = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
        -Body $astRequest -ContentType 'application/json' -TimeoutSec 10
    if (-not $astCheck.result.valid -or $astCheck.result.authority -ne 'validation_only') {
        throw 'CODER proposed AST validation failed.'
    }
    if ($neuralHealth.result.available) {
        $neuralBody = @{ prompt = 'What is organics?'; responseMode = 'neural_local_v1' } | ConvertTo-Json -Compress
        $neural = Invoke-RestMethod "$base/api/chat" -Method Post -Body $neuralBody `
            -ContentType 'application/json' -TimeoutSec 240
        if (-not $neural.text -or $neural.source -ne 'gemma_neural' -or
            $neural.trace.selection -ne 'gemma_neural_local' -or
            $neural.trace.neural.authority -ne 'model_output_unverified') {
            throw 'Local Gemma continuation failed.'
        }
        $draft = Invoke-RestMethod "$base/api/bindings/invoke" -Method Post `
            -Body '{"name":"factory.draft","capabilityGap":"space questions lack a verified expert"}' `
            -ContentType 'application/json' -TimeoutSec 240
        if (-not $draft.result.draft -or $draft.result.authority -ne 'proposal_only' -or
            $draft.result.registered) { throw 'Factory neural draft failed.' }
    }
    Write-Output 'Micronaut REST bus, key grammar ranking and replies, history, Gemma chat, and MathML route passed'
} finally {
    try {
        Invoke-RestMethod "$base/_internal/shutdown" -Method Post -Body '{}' `
            -Headers @{ 'X-Micronaut-Shutdown' = $token } -ContentType 'application/json' `
            -TimeoutSec 3 | Out-Null
    } catch { }
    if ($job -and $job.State -in 'Completed','Failed','Stopped') { Remove-Job $job -Force -ErrorAction SilentlyContinue }
    if ($hostProcess -and -not $hostProcess.HasExited) { Stop-Process -Id $hostProcess.Id -Force -ErrorAction SilentlyContinue }
}
