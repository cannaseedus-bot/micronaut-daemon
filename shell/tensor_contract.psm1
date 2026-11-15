#Requires -Version 5.1
<#
  tensor_contract.psm1 — K'UHUL tensor contract execution engine

  Architecture (three distinct layers):
    Tensor     = representation   — holds rank, shape, dtype, data
    Contract   = constraints      — declares what is allowed (the authority layer)
    Operator   = computation      — MAP / FILTER / FOLD / REDUCE

  Execution lifecycle (C6 phase wheel):
    Pop    → receive_tensor, receive_context
    Wo     → bind_dtype, bind_rank, bind_shape, bind_operator, bind_accumulator
    Yax    → prepare_accumulator, initialize_identity
    Sek    → require_authorization (gate), dispatch_{fold|map|filter|reduce}
    Ch'en  → verify_rank, verify_shape, verify_dtype, verify_output_contract
    Xul    → close_accumulator, emit_result

  Schema:  data/schema/cfpc-tensor-contract.schema.json
  Example: data/cfpc/tensor.fold.accumulate.cfpc-tensor-contract.v1.json

  Operator semantics (from schema description field):
    MAP     → Tensor → Tensor          element-wise transform; output rank = input rank
    FILTER  → Tensor → Tensor/Selection  select matching values; shape may change
    FOLD    → Accumulator × Value → Accumulator   stateful; carries accumulator through sequence
    REDUCE  → Tensor → Result          combine along axes; may use FOLD internally

  FOLD vs REDUCE distinction:
    FOLD  carries accumulator state through a sequence — state is first-class
    REDUCE combines values into a result — may use a fold internally, state not exposed

  Pattern Induction Guard — grammar-level invariant, not a runtime policy:
    promote_generated_facts MUST be false. Engine rejects contracts with true.

  Operator dispatch routes through xcfe_gl_ops (tensor_bindings.psm1):
    FOLD   → tensor_gemm / cs_fold_kernel_compute
    MAP    → tensor_map  op
    FILTER → tensor_filter op
    REDUCE → tensor_reduce op
#>

Import-Module "$PSScriptRoot\tensor_bindings.psm1" -Force

$script:_KitRoot            = Join-Path (Split-Path $PSScriptRoot -Parent) 'key-grammar-kit'
$script:_PhaseOrder         = @('Pop','Wo','Yax','Sek',"Ch'en",'Xul')
$script:_ContractFrameStore = [System.Collections.Generic.Dictionary[string,hashtable]]::new()


# ── Contract construction ─────────────────────────────────────────────────────

function New-TensorContract {
    <#.SYNOPSIS Build a tensor contract document from parameters.
    Returns a hashtable matching khanary.tensor.contract.v1 schema.
    Enforces the Pattern Induction Guard — promote_generated_facts is always false.#>
    param(
        [Parameter(Mandatory)][string]$Id,
        [ValidateSet('MAP','FILTER','FOLD','REDUCE','STACK')][string]$Operator = 'FOLD',
        [ValidateSet('float32','float16','int32','int8','bool')][string]$Dtype = 'float32',
        # InputShape: array of ints (fixed) or strings (symbolic: 'N','batch').
        # Rank-0 scalar = @(1) by convention; rank is always InputShape.Count.
        [Parameter(Mandatory)]$InputShape,
        [Parameter(Mandatory)]$OutputShape,
        [ValidateSet('define','explain','verify','resolve','generate')][string]$Intent = 'resolve',
        [ValidateSet('Pop','Wo','Yax','Sek',"Ch'en",'Xul')][string]$PhaseEntry = 'Pop',
        $AccumulatorShape           = @(),
        [ValidateSet('zeros','ones','neg_inf','pos_inf','none')][string]$Identity = 'zeros',
        [ValidateSet('add','multiply','max','min','concat','logical_and','logical_or')][string]$Combine = 'add',
        $Axis                       = $null,   # int, int[], or null (reduce all)
        [int]$MaxDepth              = 4,
        [bool]$AllowPartialShape    = $false,
        [bool]$RetainProvenance     = $true,
        [bool]$RetainGaps           = $true,
        [string]$DominantField      = '',
        [string]$DominantPhase      = 'Sek'
    )

    # normalize shapes to arrays — accept int[], string[], or mixed
    $InputShape    = @($InputShape)
    $OutputShape   = @($OutputShape)
    $AccumulatorShape = @($AccumulatorShape)

    $inputRank  = $InputShape.Count
    $outputRank = $OutputShape.Count

    # rank transformation tag — explicit in the contract, not implied
    $rankEffect = switch ($Operator) {
        'MAP'    { 'preserving' }   # rank-preserving: 3→3
        'FILTER' { 'preserving' }   # preserving or variable-length (mask case)
        'FOLD'   { 'preserving' }   # stateful, carries full rank: 3→3
        'REDUCE' {                  # rank-reducing: 3→2 when axis is specified
            if ($null -ne $Axis) { 'reducing' } else { 'collapsing' }  # collapsing = →scalar
        }
        'STACK'  { 'increasing' }   # rank-increasing: two rank-2 → one rank-3
    }

    # accumulator shape: for FOLD it must match output; for REDUCE it tracks intermediate
    $accSh = if ($AccumulatorShape.Count -gt 0) { $AccumulatorShape }
             elseif ($Operator -eq 'FOLD')   { $OutputShape }   # FOLD: acc rank = output rank
             elseif ($Operator -eq 'REDUCE') { $InputShape  }   # REDUCE: intermediate = full input
             else                            { $OutputShape }

    $dispatchStep = @{
        MAP    = 'dispatch_map'
        FILTER = 'dispatch_filter'
        FOLD   = 'dispatch_fold'
        REDUCE = 'dispatch_reduce'
        STACK  = 'dispatch_stack'
    }[$Operator]

    $lifecycle = @{
        'Pop'    = @('receive_tensor','receive_context')
        'Wo'     = @('bind_dtype','bind_rank','bind_shape','bind_operator','bind_accumulator')
        'Yax'    = @('prepare_accumulator','initialize_identity')
        'Sek'    = @('require_authorization', $dispatchStep)
        "Ch'en"  = @('verify_rank','verify_shape','verify_dtype','verify_output_contract')
        'Xul'    = @('close_accumulator','emit_result')
    }

    $domOperatorMap = @{ MAP='map'; FILTER='map'; FOLD='accumulate'; REDUCE='reduce'; STACK='stack' }
    $routing = @{
        dominant_operator = $domOperatorMap[$Operator]
        dominant_phase    = $DominantPhase
        depth_norm_min    = 0.0
    }
    if ($DominantField) { $routing['dominant_field'] = $DominantField }

    $op = @{
        name              = $Operator
        output_shape      = $OutputShape
        accumulator_shape = $accSh
        identity          = $Identity
        combine           = $Combine
        rank_effect       = $rankEffect     # preserving | reducing | collapsing | increasing
        input_rank        = $inputRank
        output_rank       = $outputRank
    }
    if ($null -ne $Axis) { $op['axis'] = $Axis }

    return @{
        '@kind'       = 'khanary.tensor.contract.v1'
        'id'          = $Id
        'intent'      = $Intent
        'phase_entry' = $PhaseEntry
        '@tensor'     = @{ dtype=$Dtype; rank=$rank; shape=$InputShape }
        '@operator'   = $op
        '@lifecycle'  = $lifecycle
        '@routing'    = $routing
        '@policy'     = @{
            max_depth              = $MaxDepth
            cycle_detection        = $true
            allow_partial_shape    = $AllowPartialShape
            promote_generated_facts= $false   # Pattern Induction Guard — invariant
        }
        '@result'     = @{
            retain_provenance     = $RetainProvenance
            retain_gaps           = $RetainGaps
            allow_pattern_candidates = $false
        }
    }
}

function Import-TensorContract {
    <#.SYNOPSIS Load a .cfpc-tensor-contract.v1.json file from disk.
    Validates the Pattern Induction Guard before returning.#>
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path $Path)) { return @{ error="not found: $Path" } }
    try { $c = Get-Content $Path -Raw | ConvertFrom-Json -AsHashtable }
    catch { return @{ error="parse error: $($_.Exception.Message)" } }
    # Pattern Induction Guard
    if ($c['@policy'] -and $c['@policy']['promote_generated_facts'] -ne $false) {
        return @{ error="Pattern Induction Guard violation: promote_generated_facts must be false" }
    }
    return $c
}

function Get-TensorContractSchema {
    return _ReadTensorConfig 'schema' 'data\schema\cfpc-tensor-contract.schema.json'
}

function _ReadTensorConfig([string]$Key,[string]$Rel) {
    $full = Join-Path $script:_KitRoot $Rel
    if (-not (Test-Path $full)) { return $null }
    try { return Get-Content $full -Raw | ConvertFrom-Json }
    catch { return $null }
}


# ── Tensor value helper ───────────────────────────────────────────────────────

function New-Tensor {
    <#.SYNOPSIS Construct a tensor value descriptor.
    Shape accepts int[] (fixed) or string[] (symbolic) or mixed — same as contract shapes.
    Rank is always Shape.Count. Rank-0 scalar = @(1) by convention.#>
    param(
        [Parameter(Mandatory)]$Shape,          # int[], string[], or mixed
        [ValidateSet('float32','float16','int32','int8','bool')][string]$Dtype = 'float32',
        $Data = $null,                          # array, file path, or buffer key
        [string]$Name = ''
    )
    $sh = @($Shape)
    $n  = 1; foreach ($d in $sh) { if ($d -is [int]) { $n *= $d } }
    return @{
        rank       = $sh.Count
        shape      = $sh
        dtype      = $Dtype
        data       = $Data
        name       = $Name
        n_elements = $n
    }
}

function Get-TensorRankEffect {
    <#.SYNOPSIS Derive the rank transformation a contract's operator performs.
    Returns: preserving | reducing | collapsing | increasing#>
    param([Parameter(Mandatory)][hashtable]$Contract)
    $op = $Contract['@operator']
    if ($op.rank_effect) { return $op.rank_effect }   # explicit in contract
    # derive from input/output rank delta
    $ir = [int]$Contract['@tensor'].rank
    $or = $op.output_shape.Count
    if     ($or -gt $ir) { return 'increasing' }
    elseif ($or -lt $ir) { return if ($or -eq 0) {'collapsing'} else {'reducing'} }
    else                 { return 'preserving' }
}


# ── Contract validation (pre-dispatch) ───────────────────────────────────────

function Test-TensorContract {
    <#.SYNOPSIS Validate that a tensor satisfies a contract's @tensor constraints.
    Returns @{ valid, errors[] } — does NOT dispatch any operations.#>
    param(
        [Parameter(Mandatory)][hashtable]$Contract,
        [Parameter(Mandatory)][hashtable]$Tensor
    )
    $errs = @()

    # Pattern Induction Guard
    if ($Contract['@policy'] -and $Contract['@policy']['promote_generated_facts'] -ne $false) {
        $errs += "Pattern Induction Guard: promote_generated_facts must be false"
    }

    $tc = $Contract['@tensor']
    if ($null -eq $tc) { return @{ valid=$false; errors=@("contract has no @tensor section") } }

    # rank
    if ($Tensor.rank -ne [int]$tc.rank) {
        $errs += "rank mismatch: tensor=$($Tensor.rank) contract=$($tc.rank)"
    }

    # dtype
    if ($Tensor.dtype -ne [string]$tc.dtype) {
        $errs += "dtype mismatch: tensor=$($Tensor.dtype) contract=$($tc.dtype)"
    }

    # shape (integers must match exactly; strings are symbolic/pass)
    $cs = $tc.shape
    if ($Tensor.shape.Count -ne $cs.Count) {
        $errs += "shape rank mismatch: tensor has $($Tensor.shape.Count) dims, contract expects $($cs.Count)"
    } else {
        for ($i = 0; $i -lt $cs.Count; $i++) {
            $cd = $cs[$i]
            if ($cd -is [int] -or ($cd -is [string] -and $cd -match '^\d+$')) {
                if ([int]$Tensor.shape[$i] -ne [int]$cd) {
                    $errs += "shape[$i] mismatch: tensor=$($Tensor.shape[$i]) contract=$cd"
                }
            }
            # string symbolic dims pass — they are constraints, not fixed values
        }
    }

    return @{ valid=($errs.Count -eq 0); errors=$errs }
}


# ── Execution frame ───────────────────────────────────────────────────────────
# The frame flows through all six phases, accumulating state.

function _NewFrame([hashtable]$Contract, [hashtable]$Tensor, [hashtable]$Context) {
    return @{
        contract    = $Contract
        tensor      = $Tensor
        context     = if ($Context) { $Context } else { @{} }
        accumulator = $null
        authorized  = $false
        output      = $null
        gaps        = @()           # validation failures (retained if retain_gaps=true)
        phase       = $Contract.phase_entry ?? 'Pop'
        closed      = $false
        provenance  = @()           # step trace (retained if retain_provenance=true)
    }
}

function _FrameLog([hashtable]$Frame, [string]$Step, [string]$Phase, $Data = $null) {
    if ($Frame.contract['@result'] -and $Frame.contract['@result']['retain_provenance']) {
        $Frame.provenance += @{ phase=$Phase; step=$Step; at=[datetime]::UtcNow.ToString('o'); data=$Data }
    }
}

function _FrameGap([hashtable]$Frame, [string]$Step, [string]$Reason) {
    $Frame.gaps += @{ step=$Step; reason=$Reason }
}


# ── Phase step handlers ───────────────────────────────────────────────────────

function _RunStep([hashtable]$Frame, [string]$Step, [string]$Phase) {

    _FrameLog $Frame $Step $Phase

    switch ($Step) {

        # ── Pop ──────────────────────────────────────────────────────────────
        'receive_tensor' {
            if ($null -eq $Frame.tensor) { _FrameGap $Frame $Step "no tensor provided" }
        }
        'receive_context' {
            # context is optional — just log that we received it
        }

        # ── Wo ───────────────────────────────────────────────────────────────
        'bind_dtype' {
            $expected = $Frame.contract['@tensor'].dtype
            if ($Frame.tensor.dtype -ne $expected) {
                _FrameGap $Frame $Step "dtype: tensor=$($Frame.tensor.dtype) expected=$expected"
            }
        }
        'bind_rank' {
            $expected = [int]$Frame.contract['@tensor'].rank
            if ($Frame.tensor.rank -ne $expected) {
                _FrameGap $Frame $Step "rank: tensor=$($Frame.tensor.rank) expected=$expected"
            }
        }
        'bind_shape' {
            $v = Test-TensorContract -Contract $Frame.contract -Tensor $Frame.tensor
            foreach ($e in $v.errors) { _FrameGap $Frame $Step $e }
        }
        'bind_operator' {
            $op = $Frame.contract['@operator']
            if ($null -eq $op -or -not $op.name) { _FrameGap $Frame $Step "no @operator declared" }
        }
        'bind_accumulator' {
            $op     = $Frame.contract['@operator']
            $effect = Get-TensorRankEffect -Contract $Frame.contract
            if ($op.name -in @('FOLD','REDUCE') -and -not $op.accumulator_shape) {
                _FrameGap $Frame $Step "FOLD/REDUCE require accumulator_shape"
            }
            # validate rank transformation is consistent with declared rank_effect
            $ir = $Frame.tensor.rank
            $or = $op.output_shape.Count
            $actualEffect = if ($or -gt $ir) {'increasing'} elseif ($or -lt $ir -and $or -eq 0) {'collapsing'} elseif ($or -lt $ir) {'reducing'} else {'preserving'}
            if ($effect -ne $actualEffect) {
                _FrameGap $Frame $Step "rank_effect mismatch: declared=$effect actual=$actualEffect (input_rank=$ir output_rank=$or)"
            }
            # accumulator rank rules:
            #   FOLD    — accumulator.rank must equal output_rank (stateful, full rank)
            #   REDUCE  — accumulator.rank tracks intermediate state = input_rank
            if ($op.name -eq 'FOLD' -and $op.accumulator_shape -and $op.accumulator_shape.Count -ne $or) {
                _FrameGap $Frame $Step "FOLD accumulator_rank=$($op.accumulator_shape.Count) must equal output_rank=$or"
            }
            if ($op.name -eq 'REDUCE' -and $op.accumulator_shape -and $op.accumulator_shape.Count -ne $ir) {
                _FrameGap $Frame $Step "REDUCE accumulator tracks intermediate state: accumulator_rank=$($op.accumulator_shape.Count) should equal input_rank=$ir"
            }
        }

        # ── Yax ──────────────────────────────────────────────────────────────
        'prepare_accumulator' {
            $op  = $Frame.contract['@operator']
            $sh  = if ($op.accumulator_shape) { $op.accumulator_shape } else { $op.output_shape }
            $Frame.accumulator = @{ shape=$sh; dtype=$Frame.contract['@tensor'].dtype; state=$null }
        }
        'initialize_identity' {
            if ($null -ne $Frame.accumulator) {
                $Frame.accumulator.identity = $Frame.contract['@operator'].identity ?? 'zeros'
                $Frame.accumulator.combine  = $Frame.contract['@operator'].combine  ?? 'add'
            }
        }

        # ── Sek ──────────────────────────────────────────────────────────────
        'require_authorization' {
            if ($Frame.gaps.Count -gt 0) {
                _FrameGap $Frame $Step "authorization denied — $($Frame.gaps.Count) gap(s) from prior phases"
                # frame remains unauthorized — dispatch steps will not execute
            } else {
                $Frame.authorized = $true
            }
        }
        'dispatch_fold' {
            if (-not $Frame.authorized) { _FrameGap $Frame $Step "not authorized"; break }
            $op    = $Frame.contract['@operator']
            $result = Invoke-TensorGemm `
                -TensorA ($Frame.tensor.name ?? 'input') `
                -TensorB ($Frame.accumulator.state ?? 'identity') `
                -Alpha   1.0 -Beta 1.0 `
                -Backend 'opencl_1_2'
            $Frame.output = @{ tensor=$result; shape=$op.output_shape; dtype=$Frame.tensor.dtype }
            _FrameLog $Frame $Step 'Sek' $result
        }
        'dispatch_map' {
            if (-not $Frame.authorized) { _FrameGap $Frame $Step "not authorized"; break }
            $result = Invoke-XcfeOp 'tensor_map' @{
                tensor = $Frame.tensor.name ?? 'input'
                shape  = $Frame.tensor.shape
                dtype  = $Frame.tensor.dtype
            }
            $Frame.output = @{ tensor=$result; shape=$Frame.contract['@operator'].output_shape; dtype=$Frame.tensor.dtype }
        }
        'dispatch_filter' {
            if (-not $Frame.authorized) { _FrameGap $Frame $Step "not authorized"; break }
            $result = Invoke-XcfeOp 'tensor_filter' @{
                tensor = $Frame.tensor.name ?? 'input'
                shape  = $Frame.tensor.shape
            }
            $Frame.output = @{ tensor=$result; shape=$Frame.contract['@operator'].output_shape; dtype=$Frame.tensor.dtype }
        }
        'dispatch_reduce' {
            if (-not $Frame.authorized) { _FrameGap $Frame $Step "not authorized"; break }
            $op     = $Frame.contract['@operator']
            $result = Invoke-XcfeOp 'tensor_reduce' @{
                tensor  = $Frame.tensor.name ?? 'input'
                axis    = $op.axis
                combine = $op.combine ?? 'add'
            }
            $Frame.output = @{ tensor=$result; shape=$op.output_shape; dtype=$Frame.tensor.dtype }
        }
        'dispatch_stack' {
            # STACK is rank-increasing: N slices of rank-k → one rank-(k+1) tensor.
            # Slices come from context.stack_inputs (array of tensor names/refs).
            # output_shape[0] = N (number of slices); output_shape[1..] = per-slice shape.
            if (-not $Frame.authorized) { _FrameGap $Frame $Step "not authorized"; break }
            $op     = $Frame.contract['@operator']
            $slices = $Frame.context['stack_inputs']
            if (-not $slices -or $slices.Count -eq 0) {
                # fall back to treating the single input tensor as a one-slice stack
                $slices = @($Frame.tensor.name ?? 'input')
            }
            $expectedN = $op.output_shape[0]
            if ($expectedN -and $slices.Count -ne [int]$expectedN) {
                _FrameGap $Frame $Step "stack slice count: got=$($slices.Count) expected=$expectedN (output_shape[0])"
                break
            }
            $result = Invoke-XcfeOp 'tensor_stack' @{
                inputs       = $slices
                input_shape  = $Frame.tensor.shape   # shape of each slice
                output_shape = $op.output_shape
                dtype        = $Frame.tensor.dtype
            }
            $Frame.output = @{
                tensor = $result
                shape  = $op.output_shape            # rank = input_rank + 1
                dtype  = $Frame.tensor.dtype
                slices = $slices.Count
            }
        }

        # ── Ch'en ─────────────────────────────────────────────────────────────
        'verify_rank' {
            if ($null -eq $Frame.output) { _FrameGap $Frame $Step "no output to verify"; break }
            $expected = $Frame.contract['@operator'].output_shape.Count
            $actual   = $Frame.output.shape.Count
            if ($actual -ne $expected) {
                $effect = Get-TensorRankEffect -Contract $Frame.contract
                _FrameGap $Frame $Step "output rank: got=$actual expected=$expected (rank_effect=$effect input_rank=$($Frame.tensor.rank))"
            }
        }
        'verify_shape' {
            if ($null -eq $Frame.output) { _FrameGap $Frame $Step "no output to verify"; break }
            $cs = $Frame.contract['@operator'].output_shape
            for ($i = 0; $i -lt $cs.Count; $i++) {
                if ($cs[$i] -is [int] -and [int]$Frame.output.shape[$i] -ne [int]$cs[$i]) {
                    _FrameGap $Frame $Step "output shape[$i]: got=$($Frame.output.shape[$i]) expected=$($cs[$i])"
                }
            }
        }
        'verify_dtype' {
            if ($Frame.output -and $Frame.output.dtype -ne $Frame.contract['@tensor'].dtype) {
                _FrameGap $Frame $Step "output dtype: got=$($Frame.output.dtype) expected=$($Frame.contract['@tensor'].dtype)"
            }
        }
        'verify_output_contract' {
            # the output must satisfy the operator's output_shape contract (already covered by verify_shape)
            # additional: accumulator for FOLD must match accumulator_shape
            if ($Frame.contract['@operator'].name -eq 'FOLD' -and $null -ne $Frame.accumulator) {
                $acs = $Frame.contract['@operator'].accumulator_shape
                if ($Frame.accumulator.shape.Count -ne $acs.Count) {
                    _FrameGap $Frame $Step "accumulator shape rank mismatch"
                }
            }
        }

        # ── Xul ──────────────────────────────────────────────────────────────
        'close_accumulator' {
            if ($Frame.contract['@operator'].name -in @('FOLD','REDUCE')) {
                $Frame.accumulator.state = $Frame.output
            }
        }
        'close_contract' {
            $Frame.closed = $true
        }
        'emit_result' {
            $Frame.closed = $true
        }

        default {
            # unknown step — log but do not gap
            _FrameLog $Frame "unknown:$Step" $Phase
        }
    }
}


# ── Phase runner ──────────────────────────────────────────────────────────────

function Invoke-ContractPhase {
    <#.SYNOPSIS Run all lifecycle steps for a single phase against an execution frame.
    Returns the updated frame. Gaps accumulate but do not throw.#>
    param(
        [Parameter(Mandatory)][hashtable]$Frame,
        [Parameter(Mandatory)][ValidateSet('Pop','Wo','Yax','Sek',"Ch'en",'Xul')][string]$Phase
    )
    $steps = $Frame.contract['@lifecycle'][$Phase]
    if (-not $steps) { return $Frame }
    foreach ($step in $steps) { _RunStep $Frame $step $Phase }
    $Frame.phase = $Phase
    return $Frame
}


# ── Full contract execution ───────────────────────────────────────────────────

function Invoke-TensorContract {
    <#.SYNOPSIS Execute a tensor contract through the full C6 phase lifecycle.
    Pop → Wo → Yax → Sek (gated by require_authorization) → Ch'en → Xul.

    Returns:
      @{ ok, output, accumulator, gaps, provenance, phases_run, authorized, closed }

    A valid tensor is not automatically an authorized operation.
    If require_authorization finds prior gaps, Sek dispatch steps do not run.
    Ch'en verifies output even when dispatch was skipped (gaps accumulate).#>
    param(
        [Parameter(Mandatory)][hashtable]$Contract,
        [Parameter(Mandatory)][hashtable]$Tensor,
        [hashtable]$Context = @{},
        [switch]$StopOnGap       # halt phase progression on first gap (strict mode)
    )

    # Pattern Induction Guard — enforce before any execution
    if ($Contract['@policy'] -and $Contract['@policy']['promote_generated_facts'] -ne $false) {
        return @{ ok=$false; error='Pattern Induction Guard violation: promote_generated_facts must be false'; gaps=@() }
    }

    $frame       = _NewFrame $Contract $Tensor $Context
    $phasesRun   = @()
    $entryPhase  = $Contract.phase_entry ?? 'Pop'
    $entryIdx    = $script:_PhaseOrder.IndexOf($entryPhase)
    if ($entryIdx -lt 0) { $entryIdx = 0 }

    foreach ($phase in ($script:_PhaseOrder | Select-Object -Skip $entryIdx)) {
        $frame = Invoke-ContractPhase -Frame $frame -Phase $phase
        $phasesRun += $phase
        if ($StopOnGap -and $frame.gaps.Count -gt 0) { break }
    }

    $result = @{
        ok          = ($frame.gaps.Count -eq 0 -and $frame.closed -and $frame.authorized)
        output      = $frame.output
        accumulator = $frame.accumulator
        authorized  = $frame.authorized
        closed      = $frame.closed
        phases_run  = $phasesRun
        gaps        = $frame.gaps
    }
    if ($Contract['@result'] -and $Contract['@result']['retain_provenance']) {
        $result['provenance'] = $frame.provenance
    }
    return $result
}


# ── Standard contract loader ──────────────────────────────────────────────────

function Get-TensorAccumulateContract {
    <#.SYNOPSIS Load the canonical tensor.accumulate contract (FOLD float32 [2,3,4]).#>
    return ImportTensorContract (Join-Path $script:_KitRoot `
        'data\cfpc\tensor.fold.accumulate.cfpc-tensor-contract.v1.json')
}

function ImportTensorContract([string]$Path) { Import-TensorContract -Path $Path }


Export-ModuleMember -Function `
    New-TensorContract, Import-TensorContract, Get-TensorContractSchema, `
    New-Tensor, Get-TensorRankEffect, Test-TensorContract, `
    Invoke-ContractPhase, Invoke-TensorContract, `
    Get-TensorAccumulateContract
