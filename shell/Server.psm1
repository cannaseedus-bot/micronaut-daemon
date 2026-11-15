#Requires -Version 5.1
# Loopback REST bus for the WPF Micronaut shell. Chat state is process-local.

$script:BusRoot = Split-Path $PSScriptRoot -Parent
$script:Sessions = [ordered]@{}
$script:BindingHandlers = @{}

function ConvertFrom-BusJson([string]$Text) {
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        return $Text | ConvertFrom-Json -AsHashtable -ErrorAction Stop
    }
    Add-Type -AssemblyName System.Web.Extensions
    $serializer = New-Object System.Web.Script.Serialization.JavaScriptSerializer
    $serializer.MaxJsonLength = 10485760
    return $serializer.DeserializeObject($Text)
}

function Register-MicronautBusBinding {
    param([Parameter(Mandatory)][ValidatePattern('^[a-z][a-z0-9_.-]{0,63}$')][string]$Name,
          [Parameter(Mandatory)][scriptblock]$Handler)
    $script:BindingHandlers[$Name] = $Handler
}

Register-MicronautBusBinding -Name 'gemma.identity' -Handler {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        $descriptor = ConvertFrom-BusJson ([IO.File]::ReadAllText((Join-Path $script:BusRoot 'data/micronauts/gemma.micronaut.json')))
        return $descriptor.identity
    }
    Import-Module (Join-Path $script:BusRoot 'shell/gemma.bindings.psm1') -Force
    Register-GemmaMicronaut | Out-Null
    Get-GemmaIdentity
}
Register-MicronautBusBinding -Name 'vector.identity' -Handler {
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        $descriptor = ConvertFrom-BusJson ([IO.File]::ReadAllText((Join-Path $script:BusRoot 'data/micronauts/vector.micronaut.json')))
        return @{ id = $descriptor.id; authority = $descriptor.xcfe.authority }
    }
    Import-Module (Join-Path $script:BusRoot 'shell/vector.bindings.psm1') -Force
    Register-VectorMicronaut | Out-Null
    Get-VectorIdentity
}
Register-MicronautBusBinding -Name 'key-grammar.topology' -Handler {
    Import-Module (Join-Path $script:BusRoot 'shell/key-grammar-topology.psm1') -Force
    Get-KeyGrammarTopology
}
Register-MicronautBusBinding -Name 'key-grammar.resolve' -Handler {
    param($body)
    Import-Module (Join-Path $script:BusRoot 'shell/key-grammar-topology.psm1') -Force
    if (-not $body.key -or -not ($body.key -is [string])) { throw 'A key string is required.' }
    Resolve-KeyGrammarTopology -Key $body.key
}
Register-MicronautBusBinding -Name 'key-grammar.rank' -Handler {
    param($body)
    $prompt = [string]$body.prompt
    if (-not $prompt.Trim() -or $prompt.Length -gt 4096 -or $prompt -ne $prompt.Trim()) {
        throw 'A trimmed prompt of at most 4096 characters is required.'
    }
    $topK = if ($body.topK) { [int]$body.topK } else { 5 }
    if ($topK -lt 1 -or $topK -gt 20) { throw 'topK must be 1..20.' }
    $launcher = Join-Path $script:BusRoot 'tools/gemma_bridge_host.ps1'
    $attestedText = @(& $launcher -Mode Attest -Utterance $prompt) -join "`n"
    if (-not $attestedText.Trim()) { throw 'Query attestor returned no vector.' }
    $attested = ConvertFrom-BusJson $attestedText
    $rankingTool = Join-Path $script:BusRoot 'tools/key_grammar_fields.py'
    $rankedText = @(($attested | ConvertTo-Json -Depth 10 -Compress) | & python $rankingTool rank --top-k $topK) -join "`n"
    if ($LASTEXITCODE -ne 0 -or -not $rankedText.Trim()) { throw 'Key grammar field ranking failed.' }
    ConvertFrom-BusJson $rankedText
}
Register-MicronautBusBinding -Name 'gemma.neural.health' -Handler {
    Import-Module (Join-Path $script:BusRoot 'shell/GemmaNeural.psm1') -Force
    @{ available = [bool](Test-GemmaNeuralHealth); model = 'gemma-3-1B-it-QAT-Q4_0.gguf' }
}
Register-MicronautBusBinding -Name 'gemma.neural.identity' -Handler {
    @{ id = 'GEMMA-3-LOCAL'; role = 'text_continuation';
        model = 'gemma-3-1B-it-QAT-Q4_0.gguf'; authority = 'model_output_unverified';
        route = 'neural_local_v1'; requires = 'explicit_response_mode_and_vector_fallback' }
}
Register-MicronautBusBinding -Name 'factory.draft' -Handler {
    param($body)
    Import-Module (Join-Path $script:BusRoot 'shell/factory.psm1') -Force
    Invoke-MicronautFactoryDraft -CapabilityGap ([string]$body.capabilityGap)
}
Register-MicronautBusBinding -Name 'coder.grammar' -Handler {
    param($body)
    $operation = [string]$body.operation
    $language = [string]$body.language
    if ($operation -notin 'compile','parse','generate','validate_ast' -or $language -notin 'cpp','typescript') {
        throw 'coder.grammar requires operation compile|parse|generate|validate_ast and language cpp|typescript.'
    }
    $args = @((Join-Path $script:BusRoot 'tools/coder_grammar.py'), $operation, '--language', $language)
    if ($operation -in 'parse','validate_ast') {
        $source = [string]$body.source
        if ($source.Length -gt 16384) { throw 'Source exceeds 16384 characters.' }
        $args += @('--source', $source)
    }
    if ($operation -eq 'generate') { $args += @('--name', [string]$body.identifier) }
    if ($operation -eq 'validate_ast') {
        if ($null -eq $body.ast) { throw 'An AST proposal is required.' }
        $astJson = $body.ast | ConvertTo-Json -Depth 20 -Compress
        if ($astJson.Length -gt 65536) { throw 'AST proposal exceeds 65536 characters.' }
        $args += @('--ast-json', '-')
    }
    $resultText = if ($operation -eq 'validate_ast') {
        @($astJson | & python @args) -join "`n"
    } else { @(& python @args) -join "`n" }
    if ($LASTEXITCODE -ne 0 -or -not $resultText.Trim()) { throw 'CODER grammar operation failed.' }
    ConvertFrom-BusJson $resultText
}
Register-MicronautBusBinding -Name 'terminal.route' -Handler {
    param($body)
    Import-Module (Join-Path $script:BusRoot 'shell/terminal.bindings.psm1') -Force
    Resolve-TerminalRoute -Text ([string]$body.text)
}
Register-MicronautBusBinding -Name 'css-gemm.driver.status' -Handler {
    $runtime = Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runtime/webgl2.js'
    $sdk = Join-Path $script:BusRoot '.CSS-C/webview2_sdk'
    $sdkCore = Join-Path $sdk 'lib/net462/Microsoft.Web.WebView2.Core.dll'
    $sdkWpf = Join-Path $sdk 'lib/net462/Microsoft.Web.WebView2.Wpf.dll'
    $loader = Join-Path $sdk 'runtimes/win-x64/native/WebView2Loader.dll'
    return @{
        id = 'CSS-GEMM-WEBGL2'
        role = 'webgl2_forward_tensor_executor'
        authority = 'forward_compute_only'
        webgl2_executor_present = Test-Path -LiteralPath $runtime -PathType Leaf
        trainer_entrypoint_present = Test-Path -LiteralPath (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runner/webgl2-model-trainer.js') -PathType Leaf
        webview2_sdk_present = (Test-Path -LiteralPath $sdkCore -PathType Leaf) -and
            (Test-Path -LiteralPath $sdkWpf -PathType Leaf) -and
            (Test-Path -LiteralPath $loader -PathType Leaf)
        browser_gpu_status = 'client_probe_required'
        demo_url = 'http://127.0.0.1:9880/css-gemm/demo'
        trainer_url = 'http://127.0.0.1:9880/css-gemm/runtime/trainer.js'
        graph_url = 'http://127.0.0.1:9880/css-gemm/graph/mnist.json'
        kernels = @('gemm','linear_forward','activation_relu')
        fallback = 'cpu_reference'
        gradient_authority = 'cpu'
        optimizer_authority = 'cpu'
    }
}

function Get-MicronautBusBindings {
    $files = @(Get-ChildItem -LiteralPath $PSScriptRoot -Filter '*.bindings.psm1' -File |
        Sort-Object Name | ForEach-Object {
            [pscustomobject]@{ name = $_.BaseName; file = $_.Name; updatedUtc = $_.LastWriteTimeUtc.ToString('o') }
        })
    return [pscustomobject]@{ modules = $files; registered = @($script:BindingHandlers.Keys | Sort-Object) }
}

function New-BusSession {
    $id = [guid]::NewGuid().ToString('N')
    $session = [ordered]@{ id = $id; title = 'New chat'; updatedUtc = [DateTime]::UtcNow.ToString('o'); messages = [System.Collections.ArrayList]::new() }
    $script:Sessions[$id] = $session
    return $session
}

function Get-BusSession([string]$id) {
    if (-not $id -or -not $script:Sessions.Contains($id)) { return $null }
    return $script:Sessions[$id]
}

function ConvertFrom-CfpcAimlMarker([string]$Text) {
    $match = [regex]::Match($Text, '^CFPC1\|([a-z-]+)\|([^|]+)\|(\d+)\|(.+)$')
    if (-not $match.Success) { return $null }
    $captures = @{}
    foreach ($entry in ($match.Groups[4].Value -split '\|')) {
        $pair = $entry -split '=', 2
        if ($pair.Count -ne 2 -or -not $pair[1].Trim()) { return $null }
        $captures[$pair[0]] = $pair[1].Trim()
    }
    $contractPath = Join-Path $script:BusRoot "data/cfpc/$($match.Groups[1].Value).cfpc-pattern.v1.json"
    $contract = ConvertFrom-BusJson ([IO.File]::ReadAllText($contractPath))
    return @{ id = $match.Groups[1].Value; phase = $match.Groups[2].Value; max_hops = [int]$match.Groups[3].Value;
        question_templates = @($contract.question_templates); context_template = [string]$contract.context_template;
        captures = $captures; epistemic_status = 'UNKNOWN'; route_only = $true }
}

function Resolve-CfpcFactCandidates([hashtable]$Route) {
    if ($Route.id -ne 'how-many' -or -not $Route.captures.subject -or -not $Route.captures.quantity) { return $null }
    $manifestPath = Join-Path $script:BusRoot 'data/manifest/facts.manifest.json'
    $manifest = ConvertFrom-BusJson ([IO.File]::ReadAllText($manifestPath))
    $normalize = { param($value) ([string]$value).ToLowerInvariant() -replace '[^a-z0-9]', '' }
    $subject = & $normalize $Route.captures.subject
    $quantity = & $normalize $Route.captures.quantity
    $entityKey = $null; $quantityKey = $null
    foreach ($key in $manifest.Keys) {
        if ($key -like 'entity:*' -and $null -eq $entityKey) {
            $tokens = @($manifest[$key] | Where-Object { $_ -match '^(canonical|alias):' } | ForEach-Object { ($_ -split ':', 2)[1] })
            if (@($tokens | ForEach-Object { & $normalize $_ }) -contains $subject) { $entityKey = $key }
        }
        if ($key -like 'quantity:*' -and $null -eq $quantityKey) {
            $tokens = @($manifest[$key] | Where-Object { $_ -match '^(canonical|alias):' } | ForEach-Object { ($_ -split ':', 2)[1] })
            if (@($tokens | ForEach-Object { & $normalize $_ }) -contains $quantity) { $quantityKey = $key }
        }
    }
    if (-not $entityKey -or -not $quantityKey) { return $null }
    $factKey = $null
    foreach ($key in $manifest.Keys) {
        if ($key -notlike 'fact:*') { continue }
        $tokens = @($manifest[$key])
        if ($tokens -contains "subject:$entityKey" -and $tokens -contains "quantity:$quantityKey" -and
            ($tokens -contains 'kind:temporal_fact_key')) { $factKey = $key; break }
    }
    if (-not $factKey) { return $null }
    $factTokens = @($manifest[$factKey])
    $recordRef = [string](@($factTokens | Where-Object { $_ -like 'record:*' } | Select-Object -First 1)[0])
    $recordRelative = $recordRef -replace '^record:', ''
    $recordPath = [IO.Path]::GetFullPath((Join-Path $script:BusRoot $recordRelative))
    $rootPath = [IO.Path]::GetFullPath($script:BusRoot).TrimEnd('\') + '\'
    if (-not $recordPath.StartsWith($rootPath, [StringComparison]::OrdinalIgnoreCase) -or
        -not (Test-Path -LiteralPath $recordPath -PathType Leaf)) { return $null }
    $record = ConvertFrom-BusJson ([IO.File]::ReadAllText($recordPath))
    $candidateKeys = @($factTokens | Where-Object { $_ -like 'candidate_observation:*' } | ForEach-Object { ($_ -split ':', 2)[1] })
    $observations = @($record.observations | Where-Object { $candidateKeys -contains $_.key } | ForEach-Object {
        @{ key = $_.key; value = $_.value; effective = $_.effective; source = $_.source;
            status = $_.status; verified = [bool]$_.verified; statement = $_.statement }
    })
    return @{ fact_key = $factKey; temporal_class = [string]$record.temporal_class;
        current_state = $record.current_state;
        freshness_required = ([string]$record.temporal_class -eq 'MUTABLE');
        answer_requires_verified_observation = $true; observations = $observations }
}

function Invoke-GemmaBusChat([string]$prompt, [string]$responseMode = '') {
    if ($responseMode -and $responseMode -notin 'vector_extended_v1','neural_local_v1','code_local_v1') {
        throw 'Unsupported response mode.'
    }
    Import-Module (Join-Path $PSScriptRoot 'MathML.psm1') -Force
    $math = Resolve-MicronautMathML -Text $prompt
    if ($null -ne $math -and -not $math.symbolic) {
        return [pscustomobject]@{
            text = $math.text
            trace = @{ selection = $math.route; verified = $math.verified;
                authority = $math.authority; mathml = $math.mathml }
        }
    }
    $launcher = Join-Path $script:BusRoot 'tools/gemma_bridge_host.ps1'
    $requestCli = Join-Path $script:BusRoot 'build/gml-stage1/Release/gemma_bridge_request_cli.exe'
    if (-not (Test-Path -LiteralPath $requestCli -PathType Leaf)) {
        throw 'gemma_bridge_request_cli.exe is missing; build the gemma_bridge_request_cli target.'
    }
    $attestedText = @(& $launcher -Mode Attest -Utterance $prompt) -join "`n"
    if (-not $attestedText.Trim()) { throw 'Query attestor returned no vector.' }
    $attested = ConvertFrom-BusJson $attestedText
    if (-not $responseMode) {
        $replyTool = Join-Path $script:BusRoot 'tools/key_grammar_fields.py'
        $replyInput = @{ query_vector = $attested.query_vector; prompt = $prompt } | ConvertTo-Json -Depth 10 -Compress
        $replyText = @($replyInput | & python $replyTool reply) -join "`n"
        if ($LASTEXITCODE -ne 0 -or -not $replyText.Trim()) { throw 'Key grammar response validation failed.' }
        $keyReply = ConvertFrom-BusJson $replyText
        if ($keyReply.selection -in 'verified_literal_greeting','verified_control_description') {
            return [pscustomobject]@{ text = [string]$keyReply.text; trace = $keyReply }
        }
    }
    $attested['utterance'] = $prompt
    $cliInput = $attested | ConvertTo-Json -Depth 20 -Compress
    $bridgeText = @($cliInput | & $requestCli) -join "`n"
    if ($LASTEXITCODE -ne 0 -or -not $bridgeText.Trim()) { throw 'Pinned retrieval request builder failed.' }
    $bridge = ConvertFrom-BusJson $bridgeText
    $request = @{ id = [guid]::NewGuid().ToString('N'); op = 'chat.generate'; prompt = $prompt; bridge = $bridge }
    if ($responseMode -eq 'vector_extended_v1') {
        $request.response_mode = $responseMode
    }
    $requestJson = $request | ConvertTo-Json -Depth 30 -Compress
    $requestPath = [IO.Path]::GetTempFileName()
    try {
        [IO.File]::WriteAllText($requestPath, "$requestJson`n", [Text.UTF8Encoding]::new($false))
        $output = @(& $launcher -Mode Daemon -RequestFile $requestPath)
    } finally {
        Remove-Item -LiteralPath $requestPath -Force -ErrorAction SilentlyContinue
    }
    $result = $null
    foreach ($line in $output) {
        if (-not $line.Trim()) { continue }
        $item = ConvertFrom-BusJson $line
        if ($item['@kind'] -eq 'micronaut.result.v1' -and $item.id -eq $request.id) { $result = $item }
    }
    if ($null -eq $result) { throw 'Daemon did not return a chat result.' }
    if (-not $result.ok) { throw "Daemon chat rejected: $($result.error.code): $($result.error.message)" }
    if ($result.result.bridge.selection -eq 'existing_aiml') {
        $cfpcRoute = ConvertFrom-CfpcAimlMarker ([string]$result.result.text)
        if ($null -ne $cfpcRoute) {
            $factEvidence = Resolve-CfpcFactCandidates $cfpcRoute
            if ($null -ne $factEvidence) { $cfpcRoute.fact_evidence = $factEvidence }
            $trace = $result.result.bridge
            $trace.cfpc = $cfpcRoute
            if ($responseMode -in 'neural_local_v1','code_local_v1') {
                Import-Module (Join-Path $PSScriptRoot 'GemmaNeural.psm1') -Force
                $neural = Invoke-GemmaNeuralContinuation -Prompt $prompt -Hits @($bridge.retrieval.hits) `
                    -CodeMode:($responseMode -eq 'code_local_v1') -CfpcRoute $cfpcRoute
                $trace.selection = $neural.selection
                $trace.neural = @{ schema = $neural.schema; authority = $neural.authority; model = $neural.model }
                return [pscustomobject]@{ text = $neural.text; trace = $trace }
            }
            $summary = ($cfpcRoute.captures.GetEnumerator() | ForEach-Object { "$($_.Key): $($_.Value)" }) -join '; '
            $trace.selection = 'cfpc_pattern_route'
            $factNote = ''
            if ($factEvidence -and $factEvidence.observations.Count -gt 0) {
                $candidateSummary = @($factEvidence.observations | ForEach-Object {
                    "$($_.value) ($($_.source), $($_.effective), $($_.status), verified=$($_.verified))"
                }) -join '; '
                $state = $factEvidence.current_state
                if ($state -and $state.status -eq 'verified_unresolved' -and $state.verified -and $null -eq $state.current_value) {
                    $factNote = " Verified repository state ($($state.effective)): no current count is verified. Candidate observations: $candidateSummary; none is a verified current count."
                } else {
                    $factNote = " Fact-store candidates: $candidateSummary. The fact requires verified current observations, so none is presented as the current count."
                }
            }
            if ($cfpcRoute.id -eq 'which-have-property') {
                $factNote = ' The repository has no admitted, verified roster for this property yet. “Atmosphere” may mean a substantial persistent atmosphere, a very tenuous exosphere, or transient plume gas; the answer must state which definition it uses and whether the list is complete.'
            }
            return [pscustomobject]@{
                text = "CFPC recognized the '$($cfpcRoute.id)' question pattern ($summary). No verified answer matched in the current corpus.$factNote Use /gemma to request a local model response."
                trace = $trace
            }
        }
        Import-Module (Join-Path $PSScriptRoot 'GemmaFallback.psm1') -Force
        $fallback = Resolve-GemmaRankFallback -Prompt $prompt -Trace $result.result.bridge `
            -ExistingText ([string]$result.result.text)
        if ($responseMode -in 'neural_local_v1','code_local_v1') {
            Import-Module (Join-Path $PSScriptRoot 'GemmaNeural.psm1') -Force
            $neural = Invoke-GemmaNeuralContinuation -Prompt $prompt -Hits @($bridge.retrieval.hits) `
                -CodeMode:($responseMode -eq 'code_local_v1')
            $fallback.trace.selection = $neural.selection
            $fallback.trace.neural = @{ schema = $neural.schema; authority = $neural.authority; model = $neural.model }
            return [pscustomobject]@{ text = $neural.text; trace = $fallback.trace }
        }
        return $fallback
    }
    return [pscustomobject]@{ text = [string]$result.result.text; trace = $result.result.bridge }
}

function Write-BusJson($context, [int]$status, $value) {
    $json = $value | ConvertTo-Json -Depth 40 -Compress
    $bytes = [Text.Encoding]::UTF8.GetBytes($json)
    $context.Response.StatusCode = $status
    $context.Response.ContentType = 'application/json; charset=utf-8'
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.Close()
}

function Write-BusFile($context, [string]$Path, [string]$ContentType) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    $context.Response.StatusCode = 200
    $context.Response.ContentType = $ContentType
    $context.Response.Headers['Cache-Control'] = 'no-store'
    if ($ContentType -like 'text/javascript*') { $context.Response.Headers['Access-Control-Allow-Origin'] = '*' }
    $context.Response.ContentLength64 = $bytes.Length
    $context.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    $context.Response.Close()
}

function Read-BusBody($request) {
    if ($request.ContentLength64 -gt 1048576) { throw 'Request body exceeds 1 MiB.' }
    $reader = [IO.StreamReader]::new($request.InputStream, [Text.Encoding]::UTF8)
    try { $text = $reader.ReadToEnd() } finally { $reader.Dispose() }
    if ($text.Length -gt 1048576) { throw 'Request body exceeds 1 MiB.' }
    return ConvertFrom-BusJson $text
}

function Start-MicronautBusServer {
    param([ValidateRange(1,65535)][int]$Port = 9880,
          [string]$ShutdownToken = '')
    $listener = [Net.HttpListener]::new()
    $listener.Prefixes.Add("http://127.0.0.1:$Port/")
    $listener.Start()
    $running = $true
    try {
        while ($running -and $listener.IsListening) {
            $context = $listener.GetContext()
            try {
                $method = $context.Request.HttpMethod
                $path = $context.Request.Url.AbsolutePath.TrimEnd('/')
                if (-not $path) { $path = '/' }
                switch ("$method $path") {
                    'GET /health' {
                        Write-BusJson $context 200 @{ schema = 'micronaut.bus.health.v1'; ok = $true; route = 'gemma_bridge'; sessions = $script:Sessions.Count }
                    }
                    'POST /_internal/shutdown' {
                        if ($ShutdownToken -and $context.Request.Headers['X-Micronaut-Shutdown'] -eq $ShutdownToken) {
                            Write-BusJson $context 200 @{ stopped = $true }
                            $running = $false
                        } else { Write-BusJson $context 403 @{ error = 'shutdown_denied' } }
                    }
                    'GET /api/routes' {
                        Write-BusJson $context 200 @{ routes = @('GET /health','GET /api/routes','GET /api/bindings','POST /api/bindings/refresh','POST /api/bindings/invoke','GET /api/sessions','POST /api/sessions','GET /api/history','POST /api/chat','GET /css-gemm/demo','GET /css-gemm/www/js/gpu/css_gemm_demo.js','GET /css-gemm/runtime/trainer.js','GET /css-gemm/runtime/gate.js','GET /css-gemm/runtime/dispatcher.js','GET /css-gemm/runtime/loop.js','GET /css-gemm/runtime/autograd.js','GET /css-gemm/runtime/tensors.js','GET /css-gemm/runtime/webgl2.js','GET /css-gemm/runtime/cpu.js','GET /css-gemm/graph/mnist.json') }
                    }
                    'GET /css-gemm/demo' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/demo/gsnr-universe.html') 'text/html; charset=utf-8'
                    }
                    'GET /css-gemm/www/js/gpu/css_gemm_demo.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/demo/www/js/gpu/css_gemm_demo.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/runtime/webgl2.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runtime/webgl2.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/runtime/trainer.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runner/webgl2-model-trainer.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/runtime/gate.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runner/gate.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/runtime/dispatcher.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runner/dispatcher.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/runtime/loop.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runner/loop.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/runtime/autograd.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runner/autograd.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/runtime/tensors.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runner/tensors.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/runtime/cpu.js' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/src/runtime/cpu.js') 'text/javascript; charset=utf-8'
                    }
                    'GET /css-gemm/graph/mnist.json' {
                        Write-BusFile $context (Join-Path $script:BusRoot '.CSS-C/css-ml-runtime/build/mnist/graph.json') 'application/json; charset=utf-8'
                    }
                    'GET /api/bindings' { Write-BusJson $context 200 (Get-MicronautBusBindings) }
                    'POST /api/bindings/refresh' { Write-BusJson $context 200 (Get-MicronautBusBindings) }
                    'POST /api/bindings/invoke' {
                        $body = Read-BusBody $context.Request
                        $name = [string]$body.name
                        if (-not $script:BindingHandlers.ContainsKey($name)) {
                            Write-BusJson $context 404 @{ error = 'binding_not_registered' }
                        } else {
                            $value = & $script:BindingHandlers[$name] $body
                            Write-BusJson $context 200 @{ name = $name; result = $value }
                        }
                    }
                    'GET /api/sessions' {
                        $list = @($script:Sessions.Values | ForEach-Object { @{ id = $_.id; title = $_.title; updatedUtc = $_.updatedUtc; count = $_.messages.Count } })
                        Write-BusJson $context 200 @{ sessions = $list }
                    }
                    'POST /api/sessions' {
                        $session = New-BusSession
                        Write-BusJson $context 201 @{ sessionId = $session.id; title = $session.title }
                    }
                    'GET /api/history' {
                        $session = Get-BusSession $context.Request.QueryString['sessionId']
                        if ($null -eq $session) { Write-BusJson $context 404 @{ error = 'session_not_found' } }
                        else { Write-BusJson $context 200 @{ sessionId = $session.id; messages = @($session.messages) } }
                    }
                    'POST /api/chat' {
                        $body = Read-BusBody $context.Request
                        $prompt = [string]$body.prompt
                        if (-not $prompt.Trim() -or $prompt.Length -gt 4096 -or $prompt -ne $prompt.Trim()) {
                            Write-BusJson $context 400 @{ error = 'invalid_prompt' }
                            break
                        }
                        $session = if ($body.sessionId) { Get-BusSession ([string]$body.sessionId) } else { $null }
                        if ($body.sessionId -and $null -eq $session) {
                            Write-BusJson $context 404 @{ error = 'session_not_found' }
                            break
                        }
                        if ($null -eq $session) { $session = New-BusSession }
                        $responseMode = if ($body.responseMode) { [string]$body.responseMode } else { '' }
                        $answer = Invoke-GemmaBusChat $prompt $responseMode
                        $now = [DateTime]::UtcNow.ToString('o')
                        if ($session.title -eq 'New chat') { $session.title = if ($prompt.Length -le 36) { $prompt } else { $prompt.Substring(0,36) + '…' } }
                        [void]$session.messages.Add(@{ role = 'user'; content = $prompt; atUtc = $now })
                        [void]$session.messages.Add(@{ role = 'assistant'; content = $answer.text; atUtc = $now })
                        $session.updatedUtc = $now
                        $source = if ($answer.trace.selection -eq 'gemma_mu_no_verified_answer') { 'gemma_mu' }
                            elseif ($answer.trace.selection -eq 'verified_vector_response') { 'vector_mu' }
                            elseif ($answer.trace.selection -in 'verified_literal_greeting','verified_control_description') { 'key_grammar' }
                            elseif ($answer.trace.response_source -eq 'aiml_corpus') { 'aiml_corpus' }
                            elseif ($answer.trace.selection -eq 'gemma_neural_local') { 'gemma_neural' }
                            elseif ($answer.trace.selection -like 'ARITHMETIC:*') { 'math_mu' }
                            else { 'gemma_bridge' }
                        Write-BusJson $context 200 @{ sessionId = $session.id; text = $answer.text; trace = $answer.trace; source = $source }
                    }
                    default { Write-BusJson $context 404 @{ error = 'route_not_found' } }
                }
            } catch {
                if ($context.Response.OutputStream.CanWrite) {
                    Write-BusJson $context 502 @{ error = 'bus_request_failed'; message = [string]$_; location = $_.ScriptStackTrace }
                }
            }
        }
    } finally {
        $listener.Stop();$listener.Close()
    }
}

Export-ModuleMember -Function Start-MicronautBusServer,Get-MicronautBusBindings,Register-MicronautBusBinding
