#Requires -Version 5.1
<#
  tensor_bindings.psm1 — tensor map layer for KHANARY / XCFE / gguf-py

  Three layers, no invented ports:

  1. xcfe_gl_ops op code bindings — programmable dispatch table
       Register-XcfeOpBinding  maps  op_code_name → shader/kernel path + backend
       Invoke-XcfeOp            dispatches by op code name
       Initialize-XcfeTensorBindings  pre-registers the 7 tensor:unified_tensor_rpc:v1 ops

  2. Static config readers (read JSON from disk — no server)
       Get-TensorFoldMap        → kuhul.fold-tensor-map.json
       Get-TensorShapeContract  → tensor.shape.json
       Get-TensorManifest       → tensor.manifest.json
       Get-TensorSlotRegistry   → micronaut_tensor_slots.json

  3. gguf-py tensor map (Python subprocess, local gguf-py library)
       Read-GgufTensorMap       → gguf_reader.py — names, shapes, dtypes, offsets
       Get-GgufModelInfo        → gguf metadata (arch, hidden_size, n_heads, context)
       Test-GgufFile            → magic bytes check (local, no Python)

  Khanary inference server: http://127.0.0.1:9000  (llama-server / khanary-server.exe)
  GEMMA inference server:   http://127.0.0.1:3217  (serve_models.py)

  Drivers loaded by the calling micronaut — NOT re-declared here.
  xcfe_gl_ops.dll, dml_gemm.dll, DirectML.dll already in gemma/xjson-ml driver lists.

  Standard op shader paths from kuhul.fold-tensor-map.json and tensor.manifest.json:
    tensor_gemm                     → opencl_1_2/matrix5x4.cl  |  DirectML fallback
    tensor_slot_materialize         → data/shaders/attention.hlsl  (d3d11)
    attention_shader_tensor_slot_modifier → src/gpu/gram_gpu_scorer.cpp shader
    cs_bone_argsort                 → opencl_1_2/kson_fold_node_expert.cl
    cs_fold_kernel_compute          → opencl_1_2/matrix5x4.cl
    cs_fold_route_matmul            → opencl_1_2/training.cl
    kson_expert_correction_webgl2   → drivers/webgl2/kson_expert_correction.frag
    semantic_cube                   → dist/GPU-TRAINER/semantic_cube.cso
#>

$script:_KitRoot   = Join-Path (Split-Path $PSScriptRoot -Parent) 'key-grammar-kit'
$script:_GgufPyDir = Join-Path $script:_KitRoot 'tools\gguf-py'
$script:_KhanaryBase = 'http://127.0.0.1:9000'

# op code binding table: op_name → @{ shader, backend, fold, reads, writes }
$script:_XcfeOpTable = [System.Collections.Generic.Dictionary[string,hashtable]]::new()

# static config cache
$script:_ConfigCache = [System.Collections.Generic.Dictionary[string,object]]::new()


# ── xcfe_gl_ops op code binding table ────────────────────────────────────────
# xcfe_gl_ops.dll exposes a programmable dispatch table. Each named op code is
# bound to a shader/kernel path and backend. Dispatch by name at runtime.

function Register-XcfeOpBinding {
    <#.SYNOPSIS Bind a named op code to a shader/kernel path and execution backend.
    Called at module load to pre-register standard ops; also callable by callers to extend.
    -Backend: directml | opencl_1_2 | d3d11 | webgl2 | cpu
    -Fold:    which C6 phase this op executes in (for validation/sequencing)#>
    param(
        [Parameter(Mandatory)][string]$OpCode,
        [Parameter(Mandatory)][string]$ShaderPath,
        [ValidateSet('directml','opencl_1_2','d3d11','webgl2','cpu')][string]$Backend = 'directml',
        [string]$Fold    = '',
        [string[]]$Reads  = @(),
        [string[]]$Writes = @()
    )
    $script:_XcfeOpTable[$OpCode] = @{
        shader  = $ShaderPath
        backend = $Backend
        fold    = $Fold
        reads   = $Reads
        writes  = $Writes
    }
}

function Get-XcfeOpBindings {
    <#.SYNOPSIS List all registered op code bindings.#>
    param([string]$Filter = '')
    $entries = $script:_XcfeOpTable.GetEnumerator() | ForEach-Object {
        @{ op_code=$_.Key } + $_.Value
    }
    if ($Filter) { return $entries | Where-Object { $_.op_code -like "*$Filter*" } }
    return $entries
}

function Invoke-XcfeOp {
    <#.SYNOPSIS Dispatch a named op code via xcfe_gl_ops. The DLL routes to the
    registered shader/kernel for the backend declared at binding time.
    Returns the op result or @{error} if the op is not registered.#>
    param(
        [Parameter(Mandatory)][string]$OpCode,
        [hashtable]$Inputs   = @{},
        [string]$OverrideBackend = ''
    )
    if (-not $script:_XcfeOpTable.ContainsKey($OpCode)) {
        return @{ error="op '$OpCode' not registered — call Register-XcfeOpBinding first"; ok=$false }
    }
    $binding = $script:_XcfeOpTable[$OpCode]
    $backend = if ($OverrideBackend) { $OverrideBackend } else { $binding.backend }

    # call through to Khanary RPC — the server dispatches to the xcfe_gl_ops DLL
    return _KhanaryPost '/xcfe/dispatch' @{
        op_code = $OpCode
        shader  = $binding.shader
        backend = $backend
        inputs  = $Inputs
    }
}

function Initialize-XcfeTensorBindings {
    <#.SYNOPSIS Pre-register the 7 standard tensor:unified_tensor_rpc:v1 ops and
    the fold shader bindings from kuhul.fold-tensor-map.json.
    Call once after loading drivers. Idempotent.#>

    # four primary operators — rank-aware dispatch
    # MAP    rank-preserving:   Tensor → Tensor (element-wise)
    # FILTER rank-preserving:   Tensor → Tensor/Selection
    # FOLD   rank-preserving:   Accumulator × Value → Accumulator (stateful, carries full rank)
    # REDUCE rank-reducing:     Tensor → Result along axes
    # STACK  rank-increasing:   N×rank-k → rank-(k+1)
    Register-XcfeOpBinding 'tensor_map'    'xcfe_gl_ops.dll::tensor_map'    -Backend 'directml' -Fold 'Sek'
    Register-XcfeOpBinding 'tensor_filter' 'xcfe_gl_ops.dll::tensor_filter' -Backend 'directml' -Fold 'Sek'
    Register-XcfeOpBinding 'tensor_fold'   'xcfe_gl_ops.dll::tensor_fold'   -Backend 'directml' -Fold 'Sek'
    Register-XcfeOpBinding 'tensor_reduce' 'xcfe_gl_ops.dll::tensor_reduce' -Backend 'directml' -Fold 'Sek'
    Register-XcfeOpBinding 'tensor_stack'  'xcfe_gl_ops.dll::tensor_stack'  -Backend 'directml' -Fold 'Sek'

    # tensor:unified_tensor_rpc:v1 ops (from tensor.manifest.json)
    Register-XcfeOpBinding 'tensor_register'    'xcfe_gl_ops.dll::tensor_register'    -Backend 'directml' -Fold 'Pop'
    Register-XcfeOpBinding 'tensor_info'        'xcfe_gl_ops.dll::tensor_info'        -Backend 'directml' -Fold 'Wo'
    Register-XcfeOpBinding 'tensor_list'        'xcfe_gl_ops.dll::tensor_list'        -Backend 'directml' -Fold 'Wo'
    Register-XcfeOpBinding 'tensor_stats'       'xcfe_gl_ops.dll::tensor_stats'       -Backend 'directml' -Fold 'Sek'
    Register-XcfeOpBinding 'tensor_gemm' `
        (Join-Path $script:_KitRoot 'drivers\opencl_1_2\matrix5x4.cl') `
        -Backend 'opencl_1_2' -Fold 'Sek' `
        -Reads  @('tensor:routed_hidden[B,T,H]') `
        -Writes @('tensor:bounded_correction[B,T,H]')
    Register-XcfeOpBinding 'tensor_slot_materialize' `
        (Join-Path $script:_KitRoot 'data\shaders\attention.hlsl') `
        -Backend 'd3d11' -Fold 'Sek' `
        -Reads  @('tensor:bone_ids[T,4]','tensor:bone_weights[T,4]') `
        -Writes @('tensor:P_buf[T,5,4]')
    Register-XcfeOpBinding 'attention_shader_tensor_slot_modifier' `
        'src/gpu/gram_gpu_scorer.cpp' `
        -Backend 'd3d11' -Fold 'Sek' `
        -Reads  @('tensor:fold_scores[6]','tensor:node_scores[6]','tensor:semantic_summary[5,4]') `
        -Writes @('tensor:semantic_signal[1]','tensor:semantic_confidence[1]')

    # fold shader bindings from kuhul.fold-tensor-map.json / shader_bindings
    Register-XcfeOpBinding 'cs_bone_argsort' `
        (Join-Path $script:_KitRoot 'drivers\opencl_1_2\kson_fold_node_expert.cl') `
        -Backend 'opencl_1_2' -Fold 'Wo' `
        -Reads  @('tensor:bone_ids[T,4]') `
        -Writes @('tensor:sorted_idx[T]','tensor:cluster_start[64]','tensor:cluster_count[64]')
    Register-XcfeOpBinding 'cs_fold_kernel_compute' `
        (Join-Path $script:_KitRoot 'drivers\opencl_1_2\matrix5x4.cl') `
        -Backend 'opencl_1_2' -Fold 'Sek' `
        -Reads  @('tensor:sorted_idx[T]','tensor:bone_ids[T,4]','tensor:bone_weights[T,4]','tensor:P_buf[T,5,4]') `
        -Writes @('tensor:P_buf[T,5,4]')
    Register-XcfeOpBinding 'cs_fold_route_matmul' `
        (Join-Path $script:_KitRoot 'drivers\opencl_1_2\training.cl') `
        -Backend 'opencl_1_2' -Fold 'Sek' `
        -Reads  @('tensor:sorted_idx[T]','tensor:routed_hidden[B,T,H]') `
        -Writes @('tensor:bounded_correction[B,T,H]')
    Register-XcfeOpBinding 'cs_gravity_field_layer' `
        (Join-Path $script:_KitRoot 'drivers\opencl_1_2\training.cl') `
        -Backend 'opencl_1_2' -Fold "Ch'en" `
        -Reads  @('tensor:P_buf[T,5,4]','tensor:bone_ids[T,4]','tensor:bone_weights[T,4]') `
        -Writes @('tensor:bounded_correction[B,T,H]','state:validation_status')
    Register-XcfeOpBinding 'semantic_cube' `
        (Join-Path $script:_KitRoot 'dist\GPU-TRAINER\semantic_cube.cso') `
        -Backend 'd3d11' -Fold 'Yax' `
        -Reads  @('tensor:fold_scores[6]','tensor:node_scores[6]','tensor:semantic_summary[5,4]') `
        -Writes @('tensor:semantic_signal[1]','tensor:semantic_confidence[1]')
    Register-XcfeOpBinding 'kson_expert_correction_webgl2' `
        (Join-Path $script:_KitRoot 'drivers\webgl2\kson_expert_correction.frag') `
        -Backend 'webgl2' -Fold 'Wo' `
        -Reads  @('tensor:routed_hidden[B,T,H]','tensor:fold_scores[6]','tensor:node_scores[6]') `
        -Writes @('tensor:bounded_correction[B,T,H]')

    Write-Verbose "xcfe tensor bindings initialized: $($script:_XcfeOpTable.Count) ops registered"
}


# ── tensor:unified_tensor_rpc:v1 — named dispatch ────────────────────────────

function Invoke-TensorRegister {
    param([Parameter(Mandatory)][string]$Name, [Parameter(Mandatory)][hashtable]$Shape)
    return Invoke-XcfeOp 'tensor_register' @{ name=$Name; shape=$Shape }
}

function Get-TensorInfo {
    param([Parameter(Mandatory)][string]$Name)
    return Invoke-XcfeOp 'tensor_info' @{ name=$Name }
}

function Get-TensorList {
    param([string]$Fold = '', [string]$Group = '')
    $inputs = @{}
    if ($Fold)  { $inputs['fold']  = $Fold }
    if ($Group) { $inputs['group'] = $Group }
    return Invoke-XcfeOp 'tensor_list' $inputs
}

function Get-TensorStats {
    param([Parameter(Mandatory)][string]$Name)
    return Invoke-XcfeOp 'tensor_stats' @{ name=$Name }
}

function Invoke-TensorGemm {
    <#.SYNOPSIS GEMM via xcfe_gl_ops → opencl_1_2/matrix5x4.cl or DirectML fallback.
    C = alpha*A*B + beta*C  with optional transpose flags.#>
    param(
        [Parameter(Mandatory)][string]$TensorA,
        [Parameter(Mandatory)][string]$TensorB,
        [string]$TensorC   = '',
        [float]$Alpha      = 1.0,
        [float]$Beta       = 0.0,
        [switch]$TransposeA,
        [switch]$TransposeB,
        [ValidateSet('directml','opencl_1_2')][string]$Backend = 'opencl_1_2'
    )
    return Invoke-XcfeOp 'tensor_gemm' @{
        a         = $TensorA
        b         = $TensorB
        c         = $TensorC
        alpha     = $Alpha
        beta      = $Beta
        trans_a   = $TransposeA.IsPresent
        trans_b   = $TransposeB.IsPresent
    } -OverrideBackend $Backend
}

function Invoke-TensorSlotMaterialize {
    <#.SYNOPSIS Materialize a micronaut tensor slot → attention.hlsl (d3d11).
    slot_id identifies the entry in micronaut_tensor_slots.json.
    Returns @{ slot_id, micronaut_id, tensor_id, shape }.#>
    param(
        [Parameter(Mandatory)][string]$SlotId,
        [Parameter(Mandatory)][string]$MicronautId,
        [hashtable]$Shape = @{}
    )
    return Invoke-XcfeOp 'tensor_slot_materialize' @{
        slot_id      = $SlotId
        micronaut_id = $MicronautId
        shape        = $Shape
    }
}

function Invoke-AttentionShaderTensorSlotModifier {
    <#.SYNOPSIS gram_gpu_scorer attention shader modifier — applies tensor mass,
    alignment, health, and enabled channels from the tensor slot registry.#>
    param(
        [Parameter(Mandatory)][string]$SlotId,
        [float]$TensorMass      = 1.0,
        [float]$TensorAlignment = 1.0,
        [float]$TensorHealth    = 1.0,
        [bool]$TensorEnabled    = $true
    )
    return Invoke-XcfeOp 'attention_shader_tensor_slot_modifier' @{
        slot_id          = $SlotId
        tensor_mass      = $TensorMass
        tensor_alignment = $TensorAlignment
        tensor_health    = $TensorHealth
        tensor_enabled   = $TensorEnabled
    }
}


# ── Static config readers ─────────────────────────────────────────────────────

function _ReadConfig([string]$Key, [string]$RelPath) {
    if ($script:_ConfigCache.ContainsKey($Key)) { return $script:_ConfigCache[$Key] }
    $full = Join-Path $script:_KitRoot $RelPath
    if (-not (Test-Path $full)) { Write-Warning "tensor: config not found: $full"; return $null }
    try {
        $obj = Get-Content $full -Raw | ConvertFrom-Json
        $script:_ConfigCache[$Key] = $obj
        return $obj
    } catch { Write-Warning "tensor: parse error $RelPath`: $($_.Exception.Message)"; return $null }
}

function Get-TensorFoldMap {
    <#.SYNOPSIS Load kuhul.fold-tensor-map.json — canonical tensor group and fold read/write map.
    Returns the full document including tensor_groups, folds, shader_bindings, provider_authority.#>
    return _ReadConfig 'fold_map' 'data\programs\kuhul.fold-tensor-map.json'
}

function Get-TensorShapeContract {
    <#.SYNOPSIS Load tensor.shape.json — OpenCL shape/stride/dtype contract for forward pass.
    Returns @{ tensors: { input, h1, h1_norm, logits }, rules, validation }.#>
    return _ReadConfig 'shape_contract' 'data\programs\tensor.shape.json'
}

function Get-TensorManifest {
    <#.SYNOPSIS Load tensor.manifest.json — full TENSOR:* vocabulary and RPC capability map.
    Keys: TENSOR:, @tensor, tensor, TENSOR-µ, tensor:projection_container:v1, tensor:unified_tensor_rpc:v1 …#>
    return _ReadConfig 'manifest' 'data\manifest\tensor.manifest.json'
}

function Get-TensorSlotRegistry {
    <#.SYNOPSIS Load micronaut_tensor_slots.json — per-micronaut tensor slot registry.
    25 micronauts, 8 STB-backed private slots, 17 shared virtual slots.#>
    return _ReadConfig 'slot_registry' 'data\world\micronaut_tensor_slots.json'
}

function Get-SafetensorsInferenceProgram {
    <#.SYNOPSIS Load safetensors.inference.json — D3D11 CS5 inference program contract.#>
    return _ReadConfig 'safetensors_inference' 'data\programs\safetensors.inference.json'
}

function Get-KhanaryGgufAdapter {
    <#.SYNOPSIS Load khanary.gguf.adapter.json — GGUF inference adapter config (port 9000).#>
    return _ReadConfig 'gguf_adapter' 'data\programs\khanary.gguf.adapter.json'
}

function Get-TensorGroup {
    <#.SYNOPSIS Get a named tensor group from the fold map (context, attention, shard_fields, etc.).#>
    param([Parameter(Mandatory)][ValidateSet('context','shard_fields','attention','feed_forward','semantic','sidecar','output')][string]$Group)
    $map = Get-TensorFoldMap
    if ($null -eq $map) { return $null }
    return $map.tensor_groups.$Group
}

function Get-TensorFoldContract {
    <#.SYNOPSIS Get the read/write contract for a specific C6 phase fold.#>
    param([Parameter(Mandatory)][ValidateSet('Pop','Wo','Yax','Sek','Chen','Xul')][string]$Fold)
    $map = Get-TensorFoldMap
    if ($null -eq $map) { return $null }
    return $map.folds.$Fold
}

function Clear-TensorConfigCache {
    $script:_ConfigCache.Clear()
}


# ── gguf-py tensor map (Python subprocess) ────────────────────────────────────

function Test-GgufFile {
    <#.SYNOPSIS Validate GGUF magic bytes and version locally (no Python required).#>
    param([Parameter(Mandatory)][string]$GgufPath)
    if (-not (Test-Path $GgufPath)) { return @{ valid=$false; error="not found: $GgufPath" } }
    try {
        $bytes = [System.IO.File]::ReadAllBytes($GgufPath) | Select-Object -First 8
        $magic = [System.Text.Encoding]::ASCII.GetString($bytes[0..3])
        $ver   = [System.BitConverter]::ToUInt32($bytes, 4)
        return @{ valid=($magic -eq 'GGUF'); magic=$magic; version=$ver; path=$GgufPath }
    } catch { return @{ valid=$false; error=$_.Exception.Message } }
}

function _InvokeGgufPy([string]$Script) {
    # run a Python one-liner against the local gguf-py library
    $env:PYTHONPATH = $script:_GgufPyDir
    try {
        $out = & python -c $Script 2>&1
        return $out | ConvertFrom-Json -ErrorAction SilentlyContinue
    } catch { return @{ error=$_.Exception.Message } }
}

function Read-GgufTensorMap {
    <#.SYNOPSIS Read the full tensor map from a .gguf file via gguf-py.
    Returns array of @{ name, shape, n_elements, dtype, offset_start, offset_end }.#>
    param(
        [Parameter(Mandatory)][string]$GgufPath,
        [switch]$NoCache
    )
    $key = "gguf:$GgufPath"
    if (-not $NoCache -and $script:_ConfigCache.ContainsKey($key)) { return $script:_ConfigCache[$key] }
    $escaped = $GgufPath -replace '\\','\\\\'
    $py = @"
import sys, json
sys.path.insert(0,'$($script:_GgufPyDir -replace '\\','\\\\')');
from gguf.gguf_reader import GGUFReader
r=GGUFReader('$escaped')
print(json.dumps([{'name':str(t.name),'shape':list(t.shape),'n_elements':int(t.n_elements),'dtype':str(t.tensor_type.name),'offset_start':int(t.data_offset),'offset_end':int(t.data_offset+t.nbytes)} for t in r.tensors]))
"@
    $result = _InvokeGgufPy ($py -replace "`n",' ')
    if ($result -and -not $result.error) { $script:_ConfigCache[$key] = $result }
    return $result
}

function Get-GgufModelInfo {
    <#.SYNOPSIS Read metadata from a .gguf file — architecture, hidden_size, n_heads, context_length, quantization.#>
    param([Parameter(Mandatory)][string]$GgufPath)
    $key = "gguf_info:$GgufPath"
    if ($script:_ConfigCache.ContainsKey($key)) { return $script:_ConfigCache[$key] }
    $escaped = $GgufPath -replace '\\','\\\\'
    $py = @"
import sys, json
sys.path.insert(0,'$($script:_GgufPyDir -replace '\\','\\\\')');
from gguf.gguf_reader import GGUFReader
r=GGUFReader('$escaped')
m={f.name:f.parts[-1].tolist() if hasattr(f.parts[-1],'tolist') else str(f.parts[-1]) for f in r.fields.values()}
print(json.dumps({'fields':m,'tensor_count':len(r.tensors)}))
"@
    $result = _InvokeGgufPy ($py -replace "`n",' ')
    if ($result -and -not $result.error) { $script:_ConfigCache[$key] = $result }
    return $result
}

function Get-GgufTensorNames {
    <#.SYNOPSIS List only tensor names from a .gguf file (lightweight — no data).#>
    param([Parameter(Mandatory)][string]$GgufPath)
    $map = Read-GgufTensorMap -GgufPath $GgufPath
    if ($map -and -not $map.error) { return @($map | ForEach-Object { $_.name }) }
    return $map
}

function Measure-GgufModelSize {
    <#.SYNOPSIS Calculate total parameter count and storage size.#>
    param([Parameter(Mandatory)][string]$GgufPath)
    $map = Read-GgufTensorMap -GgufPath $GgufPath
    if (-not $map -or $map.error) { return $map }
    $totalParams = ($map | Measure-Object -Property n_elements -Sum).Sum
    $lastOffset  = ($map | Measure-Object -Property offset_end  -Maximum).Maximum
    return @{
        total_params = $totalParams
        size_bytes   = $lastOffset
        size_gb      = [math]::Round($lastOffset / 1GB, 3)
        tensor_count = $map.Count
    }
}


# ── Khanary server (port 9000) — GGUF inference ───────────────────────────────

function Test-KhanaryServer {
    try {
        $tcp = [System.Net.Sockets.TcpClient]::new()
        $ar  = $tcp.BeginConnect('127.0.0.1', 9000, $null, $null)
        $ok  = $ar.AsyncWaitHandle.WaitOne(500)
        $tcp.Close()
        return $ok
    } catch { return $false }
}

function _KhanaryPost([string]$Path, [hashtable]$Body) {
    try {
        $json = $Body | ConvertTo-Json -Depth 8 -Compress
        return Invoke-RestMethod -Method POST -Uri "$($script:_KhanaryBase)$Path" `
                   -Body $json -ContentType 'application/json; charset=utf-8' `
                   -TimeoutSec 30 -ErrorAction Stop
    } catch { return @{ error=$_.Exception.Message; ok=$false } }
}

function _KhanaryGet([string]$Path) {
    try {
        return Invoke-RestMethod -Method GET -Uri "$($script:_KhanaryBase)$Path" `
                   -TimeoutSec 15 -ErrorAction Stop
    } catch { return @{ error=$_.Exception.Message; ok=$false } }
}

function Get-KhanaryHealth  { return _KhanaryGet '/health' }
function Get-KhanaryModels  { return _KhanaryGet '/v1/models' }
function Get-KhanaryProps   { return _KhanaryGet '/props' }

function Start-KhanaryServer {
    <#.SYNOPSIS Start llama-server or khanary-server.exe for GGUF inference.
    Checks port 9000 first — no-op if already running.#>
    param(
        [string]$GgufModelPath = '',
        [int]$WaitSeconds      = 20,
        [switch]$Force
    )
    if (-not $Force -and (Test-KhanaryServer)) {
        return @{ already_running=$true; server_url=$script:_KhanaryBase }
    }

    $adapter = Get-KhanaryGgufAdapter
    $uiRoot  = Split-Path $PSScriptRoot -Parent

    $serverExe = @(
        (Join-Path $uiRoot 'dist\khanary-server\llama-server.exe'),
        (Join-Path $uiRoot 'dist\khanary-server\khanary-server.exe'),
        (Join-Path $uiRoot 'khanary-server.exe')
    ) | Where-Object { Test-Path $_ } | Select-Object -First 1

    if (-not $serverExe) {
        Write-Warning "Start-KhanaryServer: server exe not found under $uiRoot"
        return @{ started=$false; error='khanary-server.exe / llama-server.exe not found' }
    }

    $model = if ($GgufModelPath) { $GgufModelPath }
             elseif ($adapter)   { $adapter.model_selection.current_coder_gguf_baseline }
             else                { '' }
    $args  = if ($model) { "--model `"$model`" --port 9000" } else { "--port 9000" }

    $psi = [System.Diagnostics.ProcessStartInfo]::new()
    $psi.FileName         = $serverExe
    $psi.Arguments        = $args
    $psi.UseShellExecute  = $false
    $psi.CreateNoWindow   = $true

    try { $proc = [System.Diagnostics.Process]::Start($psi) }
    catch { return @{ started=$false; error=$_.Exception.Message } }

    $deadline = [datetime]::UtcNow.AddSeconds($WaitSeconds)
    $ready    = $false
    while ([datetime]::UtcNow -lt $deadline) {
        Start-Sleep -Milliseconds 500
        if (Test-KhanaryServer) { $ready=$true; break }
    }
    if (-not $ready) { Write-Warning "Start-KhanaryServer: port 9000 did not respond within ${WaitSeconds}s" }
    return @{ started=$ready; pid=$proc.Id; server_url=$script:_KhanaryBase; model=$model }
}


# ── Auto-init on module load ──────────────────────────────────────────────────
# Register standard op bindings when this module is imported.
Initialize-XcfeTensorBindings


Export-ModuleMember -Function `
    Register-XcfeOpBinding, Get-XcfeOpBindings, Invoke-XcfeOp, Initialize-XcfeTensorBindings, `
    Invoke-TensorRegister, Get-TensorInfo, Get-TensorList, Get-TensorStats, `
    Invoke-TensorGemm, Invoke-TensorSlotMaterialize, Invoke-AttentionShaderTensorSlotModifier, `
    Get-TensorFoldMap, Get-TensorShapeContract, Get-TensorManifest, `
    Get-TensorSlotRegistry, Get-SafetensorsInferenceProgram, Get-KhanaryGgufAdapter, `
    Get-TensorGroup, Get-TensorFoldContract, Clear-TensorConfigCache, `
    Test-GgufFile, Read-GgufTensorMap, Get-GgufModelInfo, Get-GgufTensorNames, Measure-GgufModelSize, `
    Test-KhanaryServer, Get-KhanaryHealth, Get-KhanaryModels, Get-KhanaryProps, Start-KhanaryServer
