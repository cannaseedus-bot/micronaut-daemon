#Requires -Version 5.1
# gemma.bindings.psm1 — bindings for GEMMA-µ (EmbeddingGemma-2)
# Authority: rank_only — Sek phase vector ranker for π routing
# Embedding: 768-dim, mean pool, cosine, multimodal (text/image/audio/video/message)
# Full kuhul verb surface + semantic deltas (READ/GET/LIST/POST only — WRITE/DELETE forbidden for rank_only)
# Inference server: Python at http://127.0.0.1:3217 — Start-GemmaMicronaut launches it; Import-GemmaDrivers auto-starts if not running
# Drivers (GPU inference stack):
#   DirectML.dll, dml_gemm.dll          — DirectML high-level ML ops + GEMM
#   dxcompiler.dll                      — DX shader compiler for HLSL ML kernels
#   d3d11_infer.dll                     — D3D11 inference execution layer
#   xcfe_gl_ops.dll                     — XCFE GL-layer ops (cross-platform GL compute)
#   qwen_infer_driver.dll               — inference driver shared with Qwen architecture
#   NeuralGrammar.Core.dll              — neural grammar integration
#   Micronaut.Core.dll, Micronaut.Compute.dll — micronaut runtime + compute
#   json_runtime_lib.dll                — fast embedding result serialization
#   dag.dll                             — DAG routing for π head

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force
Import-Module "$PSScriptRoot\tensor_bindings.psm1"   -Force   # gguf-py tensor map layer — drivers declared here, not re-listed

$script:_GemmaId    = 'GEMMA-µ'
$script:_GemmaCache = 'C:/Users/canna/.cache/huggingface/hub/models--google--embeddinggemma-2/snapshots/f9972ac22e696a105c482202646979e33e4b5a1e'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

$script:_GemmaPort    = 3217
$script:_GemmaProcess = $null   # holds the System.Diagnostics.Process when we launched it

function Test-GemmaServer {
    <#.SYNOPSIS Fast TCP probe to port 3217 — returns $true if the inference server is accepting connections.#>
    try {
        $tcp = [System.Net.Sockets.TcpClient]::new()
        $ar  = $tcp.BeginConnect('127.0.0.1', $script:_GemmaPort, $null, $null)
        $ok  = $ar.AsyncWaitHandle.WaitOne(500)   # 500 ms timeout
        $tcp.Close()
        return $ok
    } catch { return $false }
}

function Start-GemmaMicronaut {
    <#.SYNOPSIS Start the EmbeddingGemma-2 inference server if it isn't already running.
    Locates serve_models.py under the ui-shell tree, launches Python in the background,
    and waits up to -WaitSeconds for port 3217 to become responsive.
    Returns: @{ already_running, started, pid, server_url }#>
    param(
        [int]$WaitSeconds  = 20,
        [switch]$Force         # kill any existing process we launched and restart
    )

    if (-not $Force -and (Test-GemmaServer)) {
        return @{ already_running=$true; started=$false; pid=$null; server_url="http://127.0.0.1:$($script:_GemmaPort)" }
    }

    # kill our own previous launch if Force
    if ($Force -and $null -ne $script:_GemmaProcess) {
        try { $script:_GemmaProcess.Kill() } catch {}
        $script:_GemmaProcess = $null
    }

    # locate serve_models.py — check a few canonical spots under the ui-shell root
    $uiRoot = Split-Path $PSScriptRoot -Parent
    $candidates = @(
        (Join-Path $uiRoot 'micronaut-v4\atomic\serve_models.py'),
        (Join-Path $uiRoot 'atomic\serve_models.py'),
        (Join-Path $uiRoot 'serve_models.py'),
        (Join-Path $uiRoot 'shell\serve_models.py')
    )
    $servePy = $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $servePy) {
        Write-Warning "Start-GemmaMicronaut: serve_models.py not found under $uiRoot — tried: $($candidates -join ', ')"
        Write-Warning "Start-GemmaMicronaut: start the GEMMA server manually: python serve_models.py"
        return @{ already_running=$false; started=$false; pid=$null; server_url=$null; error='serve_models.py not found' }
    }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName               = 'python'
    $psi.Arguments              = "`"$servePy`""
    $psi.WorkingDirectory       = Split-Path $servePy -Parent
    $psi.UseShellExecute        = $false
    $psi.RedirectStandardOutput = $false
    $psi.RedirectStandardError  = $false
    $psi.CreateNoWindow         = $true

    try {
        $script:_GemmaProcess = [System.Diagnostics.Process]::Start($psi)
    } catch {
        Write-Warning "Start-GemmaMicronaut: failed to start Python: $($_.Exception.Message)"
        return @{ already_running=$false; started=$false; pid=$null; error=$_.Exception.Message }
    }

    # poll until port answers or timeout
    $deadline = [datetime]::UtcNow.AddSeconds($WaitSeconds)
    $ready    = $false
    while ([datetime]::UtcNow -lt $deadline) {
        Start-Sleep -Milliseconds 500
        if (Test-GemmaServer) { $ready = $true; break }
    }

    if (-not $ready) {
        Write-Warning "Start-GemmaMicronaut: server did not respond on port $($script:_GemmaPort) within ${WaitSeconds}s"
    }

    return @{
        already_running = $false
        started         = $ready
        pid             = $script:_GemmaProcess.Id
        server_url      = "http://127.0.0.1:$($script:_GemmaPort)"
        serve_script    = $servePy
    }
}

function Stop-GemmaMicronaut {
    <#.SYNOPSIS Stop the inference server process that was launched by Start-GemmaMicronaut.
    Has no effect on servers started externally.#>
    if ($null -ne $script:_GemmaProcess) {
        try { $script:_GemmaProcess.Kill(); $script:_GemmaProcess = $null; return @{ stopped=$true } }
        catch { return @{ stopped=$false; error=$_.Exception.Message } }
    }
    return @{ stopped=$false; note='no process tracked — server was not started by this module' }
}

function Register-GemmaMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/gemma.micronaut.json'
}

function Test-GemmaHealth {
    Test-MicronautHealth -Id $script:_GemmaId
}

function Get-GemmaIdentity {
    Get-MicronautIdentity -Id $script:_GemmaId
}

# ── Core embedding operations ─────────────────────────────────────────────────

function Invoke-GemmaEmbed {
    <#.SYNOPSIS Embed a single input (text, image path, audio path, etc.) → 768-dim vector.
    Use -Task to select the appropriate task prefix (Retrieval, STS, Classification, etc.)#>
    param(
        [Parameter(Mandatory)][string]$Input,
        [ValidateSet('Retrieval','Retrieval-document','STS','Classification','Clustering',
                     'Reranking','QuestionAnswering','CodeRetrieval','FactChecking','Document','')]
        [string]$Task = '',
        [ValidateSet('text','image','audio','video','message')]
        [string]$Modality = 'text'
    )
    $payload = @{ input = $Input; modality = $Modality }
    if ($Task) { $payload['task'] = $Task }
    Invoke-AtomicKey -Key 'gemma.embed' -Payload $payload
}

function Invoke-GemmaBatchEmbed {
    <#.SYNOPSIS Embed an array of inputs in one forward pass.#>
    param(
        [Parameter(Mandatory)][string[]]$Inputs,
        [string]$Task     = '',
        [string]$Modality = 'text'
    )
    $payload = @{ inputs = $Inputs; modality = $Modality }
    if ($Task) { $payload['task'] = $Task }
    Invoke-AtomicKey -Key 'gemma.batch_embed' -Payload $payload
}

function Invoke-GemmaRank {
    <#.SYNOPSIS Rank candidates against a query. Returns list sorted by cosine score descending.#>
    param(
        [Parameter(Mandatory)][string]$Query,
        [Parameter(Mandatory)][string[]]$Candidates,
        [string]$Task = 'Retrieval'
    )
    Invoke-AtomicKey -Key 'gemma.rank' -Payload @{
        query      = $Query
        candidates = $Candidates
        task       = $Task
    }
}

function Invoke-GemmaScore {
    <#.SYNOPSIS Pairwise cosine similarity between two texts or pre-computed vectors.#>
    param(
        [Parameter(Mandatory)][string]$TextA,
        [Parameter(Mandatory)][string]$TextB,
        [string]$Task = 'STS'
    )
    Invoke-AtomicKey -Key 'gemma.score' -Payload @{ a = $TextA; b = $TextB; task = $Task }
}

function Invoke-GemmaPiRank {
    <#.SYNOPSIS π routing rank — feeds V_π head (hidden_size=32, 43 glyphs, weighted L1 gamma channel).#>
    param(
        [Parameter(Mandatory)][string]$Input,
        [hashtable]$PiContext = @{}
    )
    $payload = @{ input = $Input }
    foreach ($k in $PiContext.Keys) { $payload[$k] = $PiContext[$k] }
    Invoke-AtomicKey -Key 'gemma.pi_rank' -Payload $payload
}

# ── AIML verb surface (rank_only — Match and Think are primary; Agent/Call forbidden) ─────

function Invoke-GemmaMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_GemmaId -Text $Text -Topic $Topic
}

function Invoke-GemmaThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_GemmaId -Text $Text -Context $Context
}

function Read-GemmaRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_GemmaId -Key $Key -Category $Category
}

function Invoke-GemmaDecide {
    param([Parameter(Mandatory)][array]$Options)
    Invoke-MicronautDecide -Id $script:_GemmaId -Options $Options
}

function Invoke-GemmaEval {
    param([Parameter(Mandatory)][string]$Text, [ValidateSet('person','formal','uppercase','lowercase')][string]$Transform = 'person')
    Invoke-MicronautEval -Id $script:_GemmaId -Text $Text -Transform $Transform
}

# ── Semantic deltas (READ/GET/LIST/POST only — rank_only forbids WRITE/DELETE/SAVE) ───────

function Invoke-GemmaRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_GemmaId -Resource $Resource -Params $Params
}

function Invoke-GemmaGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_GemmaId -ResourceId $ResourceId -Params $Params
}

function Invoke-GemmaList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_GemmaId -Scope $Scope -Filter $Filter
}

function Invoke-GemmaPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_GemmaId -Action $Action -Body $Body
}

# ── Key vocabulary / app generation ──────────────────────────────────────────

function _GemmaTokenizeKeyName([string]$KeyName) {
    # ⟁APP:DOG_PARK/⟁WIDGET:MAP → "dog park map"
    $clean = $KeyName -replace '⟁',',' -replace '[:/]',' '
    $words = ($clean -split '[\s_,]+' | Where-Object { $_ -and $_ -notmatch '^(APP|WIDGET|INPUT|ACTION|PROGRAM)$' } |
              ForEach-Object { $_.ToLower() }) -join ' '
    return $words.Trim()
}

function Invoke-GemmaKeyAlign {
    <#.SYNOPSIS Embed every ⟁APP vocabulary cluster from a key-grammar JSONL file.
    Returns a hashtable of app_key → {prompt, embedding, components[]}.
    Warms the gamma channel codebook for V_π head scoring.#>
    param(
        [string]$GrammarPath = '',
        [string]$Task = 'Retrieval'
    )
    $kitRoot = Join-Path $PSScriptRoot '..\key-grammar-kit'
    if (-not $GrammarPath) {
        $GrammarPath = Join-Path $kitRoot 'data\apps\asx-mini-app.key-grammar.jsonl'
    }
    if (-not (Test-Path $GrammarPath)) {
        Write-Warning "Invoke-GemmaKeyAlign: not found: $GrammarPath"; return @{}
    }

    # group JSONL lines by app_key
    $groups = @{}
    foreach ($line in [IO.File]::ReadAllLines($GrammarPath)) {
        $line = $line.Trim()
        if (-not $line -or $line[0] -ne '{') { continue }
        try {
            $obj = $line | ConvertFrom-Json
            $ak  = [string]$obj.app_key
            if (-not $ak) { continue }
            if (-not $groups.ContainsKey($ak)) { $groups[$ak] = @() }
            $groups[$ak] += $obj
        } catch {}
    }

    $codebook = @{}
    foreach ($ak in $groups.Keys) {
        # collect all key name tokens across all components
        $tokens = @($groups[$ak] | ForEach-Object { _GemmaTokenizeKeyName $_.key }) |
                  Where-Object { $_ } | Select-Object -Unique
        $prompt = "task: search result | query: $($tokens -join ' ') app feature"
        $result = Invoke-GemmaEmbed -Input $prompt -Task $Task
        $codebook[$ak] = @{
            prompt     = $prompt
            embedding  = $result
            components = @($groups[$ak] | ForEach-Object { $_.key })
        }
    }
    return $codebook
}

function Invoke-GemmaKeyPrompt {
    <#.SYNOPSIS Compose and embed a semantic prompt from one or more ⟁KEY names.
    Example: Invoke-GemmaKeyPrompt -Keys @('⟁APP:DOG_PARK','⟁WIDGET:MAP','⟁INPUT:SEARCH')
    Returns: @{ prompt, embedding, tokens }#>
    param(
        [Parameter(Mandatory)][string[]]$Keys,
        [string]$Task   = 'Retrieval',
        [string]$Suffix = 'app feature'
    )
    $tokens = ($Keys | ForEach-Object { _GemmaTokenizeKeyName $_ } | Where-Object { $_ } | Select-Object -Unique) -join ' '
    $prompt = "task: search result | query: $tokens $Suffix"
    $embedding = Invoke-GemmaEmbed -Input $prompt -Task $Task
    return @{ prompt = $prompt; embedding = $embedding; tokens = $tokens }
}

function Get-GemmaComponentRegistry {
    <#.SYNOPSIS Load the widget/program/plugin registry. Returns array of registry entries.#>
    param([string]$RegistryPath = '')
    $kitRoot = Join-Path $PSScriptRoot '..\key-grammar-kit'
    if (-not $RegistryPath) {
        $RegistryPath = Join-Path $kitRoot 'data\apps\widget-program-plugin.registry.jsonl'
    }
    if (-not (Test-Path $RegistryPath)) { Write-Warning "registry not found: $RegistryPath"; return @() }
    $entries = @()
    foreach ($line in [IO.File]::ReadAllLines($RegistryPath)) {
        $line = $line.Trim()
        if (-not $line -or $line[0] -ne '{') { continue }
        try { $entries += ($line | ConvertFrom-Json) } catch {}
    }
    return $entries
}

function Invoke-GemmaAppSpec {
    <#.SYNOPSIS Derive an app spec from a domain description.
    Loads the full widget/program/plugin registry, ranks ALL entries by cosine
    similarity to the domain prompt, and assembles the top-N into a JSONL scaffold.
    Validated: "dog park" → Dog Park App.#>
    param(
        [Parameter(Mandatory)][string]$Domain,
        [string[]]$ExtraKeys   = @(),
        [string]$AppId         = '',
        [string]$RegistryPath  = '',
        [string]$Task          = 'Retrieval',
        [int]$TopComponents    = 8
    )
    $safeId = ($AppId.ToUpper() -replace '[^A-Z0-9]','_').Trim('_')
    if (-not $safeId) { $safeId = ($Domain.ToUpper() -replace '[^A-Z0-9]','_').Trim('_') }
    $appKey = "⟁APP:$safeId"

    $domainTokens = ($Domain -split '[\s_]+' | ForEach-Object { $_.ToLower() }) -join ' '
    $extraTokens  = ($ExtraKeys | ForEach-Object { _GemmaTokenizeKeyName $_ }) -join ' '
    $prompt = "task: search result | query: $domainTokens $extraTokens app feature"

    $domainEmbed = Invoke-GemmaEmbed -Input $prompt -Task $Task

    # load full registry and rank ALL entries against the domain prompt
    $registry = Get-GemmaComponentRegistry -RegistryPath $RegistryPath
    $candidates = @($registry | ForEach-Object { "$($_.tokens) $($_.description)" })

    $rankResult = if ($candidates.Count -gt 0) {
        Invoke-GemmaRank -Query $prompt -Task $Task -Candidates $candidates
    } else { $null }

    # map top-N ranked candidates back to registry entries
    $topEntries = @()
    if ($rankResult -and $rankResult.ranked) {
        $topEntries = @($rankResult.ranked | Select-Object -First $TopComponents | ForEach-Object {
            $idx = $rankResult.ranked.IndexOf($_)
            if ($idx -ge 0 -and $idx -lt $registry.Count) { $registry[$idx] }
        } | Where-Object { $_ })
    }
    # always include header + app root regardless of ranking
    $hasHeader = $topEntries | Where-Object { $_.component_type -eq 'toolbar' }
    if (-not $hasHeader) {
        $headerEntry = $registry | Where-Object { $_.id -eq 'widget:header' } | Select-Object -First 1
        if ($headerEntry) { $topEntries = @($headerEntry) + $topEntries }
    }

    # build JSONL from ranked entries
    $appSchema = 'key.grammar.asx-mini-app.v1'
    $spec = @(
        @{ schema=$appSchema; key=$appKey; phase='Pop'; channel='function_gram'; role='app'; app_key=$appKey; component_type='app'; executor='mx.run'; authority='projection_only'; semantic_authority=$false }
    )
    foreach ($entry in $topEntries) {
        $role      = [string]$entry.type   # widget / program / plugin
        $compSlug  = ([string]$entry.id -replace '^(widget|program|plugin):','').ToUpper() -replace '[^A-Z0-9]','_'
        $keyPrefix = switch ($role) {
            'widget' { "⟁WIDGET:$compSlug" }
            'program'{ $safeId.ToLower() + '.' + ($compSlug.ToLower() -replace '_','_') }
            'plugin' { "⟁PLUGIN:$compSlug" }
            default  { $compSlug }
        }
        $spec += @{
            schema            = $appSchema
            key               = "$appKey/$keyPrefix"
            phase             = [string]$entry.phase
            channel           = 'function_gram'
            role              = $role
            app_key           = $appKey
            component_type    = [string]$entry.component_type
            program           = if ($entry.event) { "$($safeId.ToLower()).$($compSlug.ToLower())" } else { '' }
            event             = [string]$entry.event
            executor          = 'mx.run'
            authority         = 'projection_only'
            semantic_authority= $false
        }
    }

    return @{
        app_key    = $appKey
        domain     = $Domain
        prompt     = $prompt
        embedding  = $domainEmbed
        ranked     = $rankResult
        registry   = $topEntries
        spec       = $spec
        jsonl      = ($spec | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 4 }) -join "`n"
    }
}

function New-GemmaAppFromKeys {
    <#.SYNOPSIS Full pipeline: domain → semantic prompt → GEMMA embed → app spec JSONL → OAuth inject → write to data/apps/.
    Every generated app automatically gets login/callback/admin OAuth pages.
    Returns: path, app_key, domain, components, oauth config.#>
    param(
        [Parameter(Mandatory)][string]$Domain,
        [string[]]$ExtraKeys = @(),
        [string]$AppId       = '',
        [string]$OutputDir   = '',
        [string]$AppBase     = 'http://localhost:5173',
        [switch]$SkipOAuth
    )
    $kitRoot = Join-Path $PSScriptRoot '..\key-grammar-kit'
    if (-not $OutputDir) { $OutputDir = Join-Path $kitRoot 'data\apps' }

    # build the ranked app spec
    $spec = Invoke-GemmaAppSpec -Domain $Domain -ExtraKeys $ExtraKeys -AppId $AppId

    # inject OAuth pages (login + callback + admin) on auto
    $finalSpec = $spec.spec
    $oauthCfg  = $null
    if (-not $SkipOAuth) {
        $oauthMod = Join-Path $PSScriptRoot 'oauth_bindings.psm1'
        if (Test-Path $oauthMod) {
            Import-Module $oauthMod -Force -ErrorAction SilentlyContinue
            if (Get-Command Add-OAuthToAppSpec -ErrorAction SilentlyContinue) {
                $finalSpec = Add-OAuthToAppSpec -AppId ($spec.app_key -replace '⟁APP:','') -Spec $finalSpec -AppBase $AppBase
                $oauthCfg  = Get-OAuthConfig   -AppId ($spec.app_key -replace '⟁APP:','')
            }
        }
    }

    $slug    = $spec.app_key -replace '⟁APP:','' -replace '[^A-Za-z0-9]','-' | ForEach-Object { $_.ToLower().Trim('-') }
    $outPath = Join-Path $OutputDir "$slug.key-grammar.jsonl"
    $jsonl   = ($finalSpec | ForEach-Object { $_ | ConvertTo-Json -Compress -Depth 6 }) -join "`n"

    Set-Content -LiteralPath $outPath -Value $jsonl -Encoding UTF8

    # generate setup wizard HTML if oauth was injected
    $wizardPath = $null
    if ($oauthCfg -and (Get-Command New-OAuthSetupWizardPage -ErrorAction SilentlyContinue)) {
        try { $wizardPath = New-OAuthSetupWizardPage -AppId ($spec.app_key -replace '⟁APP:','') }
        catch {}
    }

    return @{
        path          = $outPath
        app_key       = $spec.app_key
        domain        = $Domain
        components    = $finalSpec.Count
        oauth         = $oauthCfg
        setup_wizard  = $wizardPath
        callback_url  = if ($oauthCfg) { $oauthCfg.callback_url } else { $null }
    }
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_GemmaDrivers = @(
    'DirectML.dll',          # DirectML high-level ML ops
    'dml_gemm.dll',          # GEMM operations via DirectML
    'dxcompiler.dll',        # DX shader compiler for HLSL ML kernels
    'd3d11_infer.dll',       # D3D11 inference execution layer
    'xcfe_gl_ops.dll',       # XCFE GL-layer cross-platform compute ops
    'qwen_infer_driver.dll', # inference driver (shared Qwen/Gemma architecture path)
    'NeuralGrammar.Core.dll',
    'Micronaut.Core.dll',
    'Micronaut.Compute.dll',
    'json_runtime_lib.dll',  # fast embedding result serialization
    'dag.dll'                # DAG routing for V_π head
)

function Import-GemmaDrivers {
    <#.SYNOPSIS Load all GPU inference drivers and ensure the Python inference server is running.
    Pass -NoAutoStart to load drivers only without starting the server.#>
    param([switch]$NoAutoStart)
    Import-MicronautDrivers -DriverNames $script:_GemmaDrivers
    if (-not $NoAutoStart) {
        $result = Start-GemmaMicronaut
        if ($result.already_running) {
            Write-Verbose "GEMMA-µ: inference server already running at port $($script:_GemmaPort)"
        } elseif ($result.started) {
            Write-Verbose "GEMMA-µ: inference server started (pid $($result.pid))"
        } elseif ($result.error) {
            Write-Warning "GEMMA-µ: drivers loaded but server not started — $($result.error)"
            Write-Warning "GEMMA-µ: run manually: python `"$($result.serve_script)`""
        }
    }
}

function Import-GemmaDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

function Get-GemmaModelPath {
    return $script:_GemmaCache
}

Export-ModuleMember -Function `
    Register-GemmaMicronaut, Test-GemmaHealth, Get-GemmaIdentity, `
    Test-GemmaServer, Start-GemmaMicronaut, Stop-GemmaMicronaut, `
    Invoke-GemmaEmbed, Invoke-GemmaBatchEmbed, Invoke-GemmaRank, `
    Invoke-GemmaScore, Invoke-GemmaPiRank, `
    Invoke-GemmaKeyAlign, Invoke-GemmaKeyPrompt, `
    Get-GemmaComponentRegistry, Invoke-GemmaAppSpec, New-GemmaAppFromKeys, `
    Invoke-GemmaMatch, Invoke-GemmaThink, Read-GemmaRecall, `
    Invoke-GemmaDecide, Invoke-GemmaEval, `
    Invoke-GemmaRead, Invoke-GemmaGet, Invoke-GemmaList, Invoke-GemmaPost, `
    Import-GemmaDrivers, Import-GemmaDriver, Get-GemmaModelPath
