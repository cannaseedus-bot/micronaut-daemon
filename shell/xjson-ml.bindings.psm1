#Requires -Version 5.1
# xjson-ml.bindings.psm1 — bindings for XJSON-ML-µ
# Full kuhul verb surface: @pattern @agent @call @topic @condition @think @remember @recall @learn @decide @eval @identity
# Drivers: DirectML.dll, dml_gemm.dll, dxcompiler.dll, xcfe_gl_ops.dll, d3d11_infer.dll, gl_infer_driver.dll, Micronaut.Core.dll, Micronaut.Compute.dll, json_runtime_lib.dll, qwen_infer_driver.dll

Import-Module "$PSScriptRoot\micronaut_bindings.psm1" -Force
Import-Module "$PSScriptRoot\tensor_bindings.psm1"   -Force   # gguf-py tensor map layer — drivers declared here, not re-listed

$script:_XjsonMLId = 'XJSON-ML-µ'

# ── Lifecycle ─────────────────────────────────────────────────────────────────

function Register-XjsonMLMicronaut {
    Register-Micronaut -BridgePath 'data/micronauts/xjson-ml.json'
}

function Test-XjsonMLHealth {
    Test-MicronautHealth -Id $script:_XjsonMLId
}

function Get-XjsonMLIdentity {
    Get-MicronautIdentity -Id $script:_XjsonMLId
}

# ── Verb surface ──────────────────────────────────────────────────────────────

function Invoke-XjsonMLMatch {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '')
    Invoke-MicronautMatch -Id $script:_XjsonMLId -Text $Text -Topic $Topic
}

function Invoke-XjsonMLAgent {
    param([Parameter(Mandatory)][string]$Text, [string]$Topic = '', [string]$That = '')
    Invoke-MicronautAgent -Id $script:_XjsonMLId -Text $Text -Topic $Topic -That $That
}

function Invoke-XjsonMLCall {
    param([Parameter(Mandatory)][string]$ToId, [Parameter(Mandatory)][string]$Text, [int]$Depth = 1)
    Invoke-MicronautCall -FromId $script:_XjsonMLId -ToId $ToId -Text $Text -Depth $Depth
}

function Set-XjsonMLTopic {
    param([Parameter(Mandatory)][string]$Topic)
    Set-MicronautTopic -Id $script:_XjsonMLId -Topic $Topic
}

function Test-XjsonMLCondition {
    param([Parameter(Mandatory)][string]$That, [string]$Topic = '')
    Test-MicronautCondition -Id $script:_XjsonMLId -That $That -Topic $Topic
}

function Invoke-XjsonMLThink {
    param([Parameter(Mandatory)][string]$Text, [hashtable]$Context = @{})
    Invoke-MicronautThink -Id $script:_XjsonMLId -Text $Text -Context $Context
}

function Write-XjsonMLRemember {
    param([Parameter(Mandatory)][string]$Key, [Parameter(Mandatory)]$Value, [string]$Category = '')
    Write-MicronautRemember -Id $script:_XjsonMLId -Key $Key -Value $Value -Category $Category
}

function Read-XjsonMLRecall {
    param([Parameter(Mandatory)][string]$Key, [string]$Category = '')
    Read-MicronautRecall -Id $script:_XjsonMLId -Key $Key -Category $Category
}

function Add-XjsonMLLearn {
    param([Parameter(Mandatory)][string]$Pattern, [Parameter(Mandatory)][string]$Response, [string]$Topic = '')
    Add-MicronautLearn -Id $script:_XjsonMLId -Pattern $Pattern -Response $Response -Topic $Topic
}

function Invoke-XjsonMLDecide {
    param([Parameter(Mandatory)][array]$Options)
    Invoke-MicronautDecide -Id $script:_XjsonMLId -Options $Options
}

function Invoke-XjsonMLEval {
    param([Parameter(Mandatory)][string]$Text, [ValidateSet('person','formal','uppercase','lowercase')][string]$Transform = 'person')
    Invoke-MicronautEval -Id $script:_XjsonMLId -Text $Text -Transform $Transform
}

# ── Semantic deltas ───────────────────────────────────────────────────────────

function Invoke-XjsonMLRead {
    param([string]$Resource = '', [hashtable]$Params = @{})
    Invoke-MicronautRead -Id $script:_XjsonMLId -Resource $Resource -Params $Params
}

function Invoke-XjsonMLGet {
    param([Parameter(Mandatory)][string]$ResourceId, [hashtable]$Params = @{})
    Invoke-MicronautGet -Id $script:_XjsonMLId -ResourceId $ResourceId -Params $Params
}

function Invoke-XjsonMLList {
    param([string]$Scope = '', [hashtable]$Filter = @{})
    Invoke-MicronautList -Id $script:_XjsonMLId -Scope $Scope -Filter $Filter
}

function Invoke-XjsonMLWrite {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Body)
    Invoke-MicronautWrite -Id $script:_XjsonMLId -Resource $Resource -Body $Body
}

function Invoke-XjsonMLPatch {
    param([Parameter(Mandatory)][string]$Resource, [Parameter(Mandatory)][hashtable]$Delta)
    Invoke-MicronautPatch -Id $script:_XjsonMLId -Resource $Resource -Delta $Delta
}

function Invoke-XjsonMLPost {
    param([Parameter(Mandatory)][string]$Action, [hashtable]$Body = @{})
    Invoke-MicronautPost -Id $script:_XjsonMLId -Action $Action -Body $Body
}

function Invoke-XjsonMLDelete {
    param([Parameter(Mandatory)][string]$ResourceId, [switch]$Confirm)
    Invoke-MicronautDelete -Id $script:_XjsonMLId -ResourceId $ResourceId -Confirm:$Confirm
}

function Invoke-XjsonMLSave {
    param([string]$Scope = '', [hashtable]$Meta = @{})
    Invoke-MicronautSave -Id $script:_XjsonMLId -Scope $Scope -Meta $Meta
}

# ── Domain-specific: ML ops, tensors, inference ───────────────────────────────

function Invoke-XjsonMLOp {
    <#.SYNOPSIS Dispatch an XJSON ML op (MATMUL, CONV2D, SOFTMAX, etc.) via atomic key.#>
    param(
        [Parameter(Mandatory)][string]$Op,
        [hashtable]$Args = @{}
    )
    $payload = $Args.Clone()
    $payload['op'] = $Op.ToUpper()
    Invoke-AtomicKey -Key 'xjson-ml.op' -Payload $payload
}

function Invoke-XjsonMLTensor {
    param([hashtable]$TensorDef)
    Invoke-AtomicKey -Key 'xjson-ml.tensor' -Payload $TensorDef
}

function Invoke-XjsonMLInfer {
    param([hashtable]$InferenceRequest)
    Invoke-AtomicKey -Key 'xjson-ml.infer' -Payload $InferenceRequest
}

# ── Drivers ───────────────────────────────────────────────────────────────────

$script:_XjsonMLDrivers = @(
    'DirectML.dll',
    'dml_gemm.dll',
    'dxcompiler.dll',
    'xcfe_gl_ops.dll',
    'd3d11_infer.dll',
    'gl_infer_driver.dll',
    'Micronaut.Core.dll',
    'Micronaut.Compute.dll',
    'json_runtime_lib.dll',
    'qwen_infer_driver.dll'
)

function Import-XjsonMLDrivers {
    Import-MicronautDrivers -DriverNames $script:_XjsonMLDrivers
}

function Import-XjsonMLDriver {
    param([Parameter(Mandatory)][string]$Name)
    Import-MicronautDrivers -DriverNames @($Name)
}

Export-ModuleMember -Function `
    Register-XjsonMLMicronaut, Test-XjsonMLHealth, Get-XjsonMLIdentity, `
    Invoke-XjsonMLMatch, Invoke-XjsonMLAgent, Invoke-XjsonMLCall, `
    Set-XjsonMLTopic, Test-XjsonMLCondition, Invoke-XjsonMLThink, `
    Write-XjsonMLRemember, Read-XjsonMLRecall, Add-XjsonMLLearn, `
    Invoke-XjsonMLDecide, Invoke-XjsonMLEval, `
    Invoke-XjsonMLRead, Invoke-XjsonMLGet, Invoke-XjsonMLList, `
    Invoke-XjsonMLWrite, Invoke-XjsonMLPatch, Invoke-XjsonMLPost, `
    Invoke-XjsonMLDelete, Invoke-XjsonMLSave, `
    Invoke-XjsonMLOp, Invoke-XjsonMLTensor, Invoke-XjsonMLInfer, `
    Import-XjsonMLDrivers, Import-XjsonMLDriver
