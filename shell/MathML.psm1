#Requires -Version 5.1
# Bounded numeric compiler for the repository's Content MathML 3 subset.

$script:MathTokens = @()
$script:MathIndex = 0
$script:MathCulture = [Globalization.CultureInfo]::InvariantCulture
$script:MathRoot = Split-Path $PSScriptRoot -Parent

function Test-MathMLHostContract {
    $contractPath = Join-Path $script:MathRoot 'build/mathml-host-admission.v1.json'
    if ((Get-FileHash -LiteralPath $contractPath -Algorithm SHA256).Hash.ToLowerInvariant() -ne
        '3b10e1fef0ed81942281d80c61e18378deafbf232d941e71a94ec252c1c3968f') { return $false }
    $contract = Get-Content -LiteralPath $contractPath -Raw | ConvertFrom-Json
    if ($contract.schema -ne 'micronaut.mathml.host-admission.v1' -or
        $contract.authority -ne 'host_selected_read_only' -or
        $contract.track -ne 'MATH-µ' -or $contract.max_expression_length -ne 128 -or
        $contract.fallback -ne 'gemma_bridge' -or $contract.mutation) { return $false }
    foreach ($item in @(
        @('mathml.compiler.ebnf', $contract.compiler_sha256),
        @('mathml.parser.ebnf', $contract.parser_sha256),
        @('mathml.generator.ebnf', $contract.generator_sha256))) {
        $file = Join-Path $script:MathRoot "data/grammar/$($item[0])"
        if ((Get-FileHash -LiteralPath $file -Algorithm SHA256).Hash.ToLowerInvariant() -ne $item[1]) { return $false }
    }
    return $true
}

function Peek-MathToken {
    if ($script:MathIndex -ge $script:MathTokens.Count) { return '' }
    return [string]$script:MathTokens[$script:MathIndex]
}
function Take-MathToken {
    $value = Peek-MathToken
    if ($value) { $script:MathIndex++ }
    return $value
}
function Expect-MathToken([string]$expected) {
    if ((Take-MathToken) -cne $expected) { throw "Expected $expected" }
}
function New-MathApply([string]$op,[object[]]$arguments) {
    return @{ tag='apply'; op=$op; args=$arguments }
}
function Parse-MathPrimary {
    $token = Take-MathToken
    if ($token -eq '(') {
        $inner = Parse-MathAdd
        Expect-MathToken ')'
        return $inner
    }
    if ($token -cmatch '^(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$') {
        $value = [double]::Parse($token,[Globalization.NumberStyles]::Float,$script:MathCulture)
        return @{ tag='cn'; value=$value; raw=$token }
    }
    if ($token -cmatch '^[A-Za-z][A-Za-z0-9_]*$') {
        $name = $token.ToLowerInvariant()
        if ((Peek-MathToken) -eq '(') {
            [void](Take-MathToken)
            $argument = Parse-MathAdd
            Expect-MathToken ')'
            $ops = @{
                sqrt='root'; cbrt='root'; abs='abs'; sin='sin'; cos='cos'; tan='tan'
                asin='arcsin'; acos='arccos'; atan='arctan'; exp='exp'; ln='ln'
                log='log'; log10='log'; log2='log'; floor='floor'; ceil='ceiling'; round='round'
            }
            if (-not $ops.ContainsKey($name)) { throw 'Unsupported MathML function.' }
            if ($name -eq 'sqrt' -or $name -eq 'cbrt') {
                $degree = if ($name -eq 'sqrt') { 2.0 } else { 3.0 }
                return New-MathApply 'root' @(@{tag='cn';value=$degree;raw=[string][int]$degree},$argument)
            }
            if ($name -eq 'log2') {
                return New-MathApply 'log' @(@{tag='cn';value=2.0;raw='2'},$argument)
            }
            return New-MathApply $ops[$name] @($argument)
        }
        switch ($name) {
            'pi'  { return @{ tag='cn';value=[math]::PI;raw=[math]::PI.ToString('G17',$script:MathCulture) } }
            'e'   { return @{ tag='cn';value=[math]::E;raw=[math]::E.ToString('G17',$script:MathCulture) } }
            'tau' { return @{ tag='cn';value=2*[math]::PI;raw=(2*[math]::PI).ToString('G17',$script:MathCulture) } }
            default { return @{ tag='ci';name=$token } }
        }
    }
    throw 'Unsupported MathML primary expression.'
}
function Parse-MathPower {
    $left = Parse-MathPrimary
    if ((Peek-MathToken) -eq '^') {
        [void](Take-MathToken)
        $right = Parse-MathUnary
        return New-MathApply 'power' @($left,$right)
    }
    return $left
}
function Parse-MathUnary {
    $token = Peek-MathToken
    if ($token -eq '+' -or $token -eq '-') {
        [void](Take-MathToken)
        $operand = Parse-MathUnary
        if ($token -eq '+') { return $operand }
        return New-MathApply 'minus' @($operand)
    }
    return Parse-MathPower
}
function Parse-MathMul {
    $left = Parse-MathUnary
    while ((Peek-MathToken) -in @('*','/','%')) {
        $operator = Take-MathToken
        $right = Parse-MathUnary
        $name = @{ '*'='times';'/'='divide';'%'='rem' }[$operator]
        $left = New-MathApply $name @($left,$right)
    }
    return $left
}
function Parse-MathAdd {
    $left = Parse-MathMul
    while ((Peek-MathToken) -in @('+','-')) {
        $operator = Take-MathToken
        $right = Parse-MathMul
        $name = if ($operator -eq '+') { 'plus' } else { 'minus' }
        $left = New-MathApply $name @($left,$right)
    }
    return $left
}
function Test-MathSymbolic($node) {
    if ($node.tag -eq 'ci') { return $true }
    if ($node.tag -eq 'apply') {
        foreach ($argument in $node.args) { if (Test-MathSymbolic $argument) { return $true } }
    }
    return $false
}
function Convert-MathNodeToXml($node) {
    if ($node.tag -eq 'cn') {
        $value = [string]$node.raw
        if ($value -match '[.eE]') { return "<cn type=`"double`">$value</cn>" }
        return "<cn>$value</cn>"
    }
    if ($node.tag -eq 'ci') { return "<ci>$($node.name)</ci>" }
    $content = '<apply><' + $node.op + '/>'
    foreach ($argument in $node.args) { $content += Convert-MathNodeToXml $argument }
    return $content + '</apply>'
}
function Get-MathNodeValue($node) {
    if ($node.tag -eq 'cn') { return [double]$node.value }
    if ($node.tag -eq 'ci') { throw 'Symbolic value cannot be evaluated.' }
    $values = @($node.args | ForEach-Object { Get-MathNodeValue $_ })
    $a = [double]$values[0]
    $b = if ($values.Count -gt 1) { [double]$values[1] } else { 0.0 }
    switch ($node.op) {
        'plus'    { return $a + $b }
        'minus'   { if ($values.Count -eq 1) { return -$a }; return $a - $b }
        'times'   { return $a * $b }
        'divide'  { if ($b -eq 0) { if ($a -eq 0) { return [double]::NaN }; return $(if ($a -lt 0) { [double]::NegativeInfinity } else { [double]::PositiveInfinity }) }; return $a / $b }
        'rem'     { if ($b -eq 0) { return [double]::NaN }; return $a % $b }
        'power'   { return [math]::Pow($a,$b) }
        'root'    { if ($a -eq 0) { return [double]::NaN }; return [math]::Pow($b,1.0/$a) }
        'abs'     { return [math]::Abs($a) }
        'sin'     { return [math]::Sin($a) }
        'cos'     { return [math]::Cos($a) }
        'tan'     { return [math]::Tan($a) }
        'arcsin'  { return [math]::Asin($a) }
        'arccos'  { return [math]::Acos($a) }
        'arctan'  { return [math]::Atan($a) }
        'exp'     { return [math]::Exp($a) }
        'ln'      { return [math]::Log($a) }
        'log'     { if ($values.Count -gt 1) { return [math]::Log($b,$a) }; return [math]::Log10($a) }
        'floor'   { return [math]::Floor($a) }
        'ceiling' { return [math]::Ceiling($a) }
        'round'   { return [math]::Round($a,0,[MidpointRounding]::AwayFromZero) }
        default   { throw 'Unsupported MathML operator.' }
    }
}

function Resolve-MicronautMathML {
    param([Parameter(Mandatory)][string]$Text)
    if (-not (Test-MathMLHostContract)) { throw 'MathML host contract or grammar digest mismatch.' }
    $expression = $Text.Trim()
    $expression = $expression -replace "(?i)^(?:what(?:'s|\s+(?:is|does|equals?))\s+|calculate\s+|compute\s+|evaluate\s+|find\s+)",''
    $expression = ($expression -replace '[?!.=]+$','').Trim()
    if (-not $expression -or $expression.Length -gt 128) { return $null }
    if ($expression -notmatch '[0-9+*/%^()]') { return $null }
    $matches = [regex]::Matches($expression,'\s+|(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?|[A-Za-z][A-Za-z0-9_]*|[+\-*/%^()]')
    if (($matches | ForEach-Object Value) -join '' -cne $expression) { return $null }
    $script:MathTokens = @($matches | Where-Object { $_.Value -notmatch '^\s+$' } | ForEach-Object Value)
    $script:MathIndex = 0
    try {
        $ast = Parse-MathAdd
        if ($script:MathIndex -ne $script:MathTokens.Count) { return $null }
        $mathml = '<math xmlns="http://www.w3.org/1998/Math/MathML">' +
            (Convert-MathNodeToXml $ast) + '</math>'
        [xml]$document = $mathml
        if ($document.DocumentElement.LocalName -ne 'math') { return $null }
        $symbolic = Test-MathSymbolic $ast
        if ($symbolic) { return [pscustomobject]@{ symbolic=$true; result=$null; mathml=$mathml; display=$expression } }
        $value = [double](Get-MathNodeValue $ast)
        if ([double]::IsNaN($value)) { return $null }
        $result = if ([double]::IsPositiveInfinity($value)) { 'Infinity' }
            elseif ([double]::IsNegativeInfinity($value)) { '-Infinity' }
            else { $value.ToString('G10',$script:MathCulture) }
        return [pscustomobject]@{
            symbolic=$false; result=$result; display=$expression; mathml=$mathml;
            text="$expression = $result"; route='ARITHMETIC:local_eval · TRACK:MATH-µ';
            authority='host_selected_read_only'; verified=$true
        }
    } catch { return $null }
}

Export-ModuleMember -Function Resolve-MicronautMathML,Test-MathMLHostContract
