#Requires -Version 7
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../shell/MathML.psm1') -Force
if (-not (Test-MathMLHostContract)) { throw 'Pinned MathML contract failed.' }
$cases = @(
    @{ input='What is 5*25='; expected='5*25 = 125' },
    @{ input='2+3*4'; expected='2+3*4 = 14' },
    @{ input='2^3^2'; expected='2^3^2 = 512' },
    @{ input='-2^2'; expected='-2^2 = -4' },
    @{ input='(-2)^2'; expected='(-2)^2 = 4' }
)
foreach ($case in $cases) {
    $actual = Resolve-MicronautMathML -Text $case.input
    if ($actual.text -ne $case.expected -or -not $actual.verified -or $actual.mathml -notmatch '<math') {
        throw "MathML case failed: $($case.input), got $($actual.text)"
    }
}
$symbolic = Resolve-MicronautMathML -Text 'x+2'
if (-not $symbolic.symbolic -or $null -ne $symbolic.result) { throw 'Symbolic expression was evaluated.' }
if ($null -ne (Resolve-MicronautMathML -Text '5*25;Remove-Item')) { throw 'Invalid expression was admitted.' }
Write-Output 'Pinned MathML arithmetic, precedence, symbolic, and invalid-input checks passed'
