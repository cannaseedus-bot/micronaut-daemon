#Requires -Version 5.1
# Read-only bindings between grammar assets, bus routes, and native targets.
$script:TopologyRoot = Split-Path $PSScriptRoot -Parent

function Get-KeyGrammarTopology {
    $glyph = [char]0x27c1
    $rows = @(
        @{ key = "${glyph}GRAMMAR:KUHUL"; grammar = 'data/grammar/kuhul.runtime-grammar.ebnf'; route = 'GET /api/bindings'; binary = 'eliza' },
        @{ key = "${glyph}GRAMMAR:KEY_JSON_V4"; grammar = 'data/grammar/key-grammar-json.runtime.v4.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'eliza' },
        @{ key = "${glyph}GRAMMAR:GML"; grammar = 'data/grammar/gml.khanary.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'gml.exe' },
        @{ key = "${glyph}GRAMMAR:VECTOR"; grammar = 'data/grammar/kuhul-fold-algebra.ebnf'; route = 'POST /api/chat'; binary = 'vector_plan_cli.exe' },
        @{ key = "${glyph}GRAMMAR:GEMMA"; grammar = 'data/grammar/key-grammar-json.runtime.v4.ebnf'; route = 'POST /api/chat'; binary = 'gemma_bridge_request_cli.exe' }
        @{ key = "${glyph}GRAMMAR:KUHUL_FOLD"; grammar = 'data/grammar/kuhul-fold-algebra.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'eliza' }
        @{ key = "${glyph}GRAMMAR:KUHUL_BASE"; grammar = 'data/grammar/kuhul-grammar.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'eliza' }
        @{ key = "${glyph}CONTRACT:BEHAVIOR"; grammar = 'data/grammar/daemon-behavior-modes.contracts.json'; route = 'POST /api/bindings/invoke'; binary = 'eliza' }
        @{ key = "${glyph}DATA:BEHAVIOR"; grammar = 'data/grammar/daemon-behavior-modes.v1.json'; route = 'POST /api/bindings/invoke'; binary = 'eliza' }
        @{ key = "${glyph}CONTRACT:TRACE"; grammar = 'data/grammar/daemon-bot.trace.contracts.json'; route = 'POST /api/bindings/invoke'; binary = 'eliza' }
        @{ key = "${glyph}DATA:SOCIALSPHERE"; grammar = 'data/grammar/socialsphere.key-grammar.jsonl'; route = 'POST /api/bindings/invoke'; binary = 'eliza' }
        @{ key = "${glyph}GRAMMAR:FIELD2D_GRAPH"; grammar = 'data/grammar/2d-key-graph-execution-field.runtime-grammar.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'gml.exe' }
        @{ key = "${glyph}GRAMMAR:FIELD2D_GRAPH_V1"; grammar = 'data/grammar/2d-key-graph-execution-field.runtime-grammar.v1.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'gml.exe' }
        @{ key = "${glyph}GRAMMAR:FIELD2D_GRAPH_V2"; grammar = 'data/grammar/2d-key-graph-execution-field.runtime-grammar.v2.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'gml.exe' }
        @{ key = "${glyph}GRAMMAR:FIELD2D"; grammar = 'data/grammar/field2d.runtime-grammar.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'gml.exe' }
        @{ key = "${glyph}GRAMMAR:FOLDGRAPH"; grammar = 'data/grammar/foldgraph.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'gml.exe' }
        @{ key = "${glyph}GRAMMAR:GRAPHSCRIPT_LEX"; grammar = 'data/grammar/graphscript.lexical-grammar.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'gml.exe' }
        @{ key = "${glyph}GRAMMAR:GRAPHSCRIPT_RUNTIME"; grammar = 'data/grammar/graphscript.runtime-grammar.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'gml.exe' }
        @{ key = "${glyph}GRAMMAR:KEY_JSON"; grammar = 'data/grammar/key-grammar-json.runtime.ebnf'; route = 'POST /api/bindings/invoke'; binary = 'eliza' }
    )
    $bindings = foreach ($row in $rows) {
        $grammar = Join-Path $script:TopologyRoot $row.grammar
        $binary = if ($row.binary -eq 'eliza') { 'eliza-' + [char]0x00b5 + '.exe' } else { $row.binary }
        $built = Join-Path $script:TopologyRoot "build/gml-stage1/Release/$binary"
        $installed = Join-Path $script:TopologyRoot "bin/$binary"
        $grammarPresent = Test-Path -LiteralPath $grammar -PathType Leaf
        $builtPresent = Test-Path -LiteralPath $built -PathType Leaf
        $installedPresent = Test-Path -LiteralPath $installed -PathType Leaf
        $builtHash = if ($builtPresent) { (Get-FileHash -LiteralPath $built -Algorithm SHA256).Hash.ToLowerInvariant() } else { $null }
        $installedHash = if ($installedPresent) { (Get-FileHash -LiteralPath $installed -Algorithm SHA256).Hash.ToLowerInvariant() } else { $null }
        [pscustomobject]@{
            key = $row.key; grammar = $row.grammar; busRoute = $row.route
            buildTarget = "build/gml-stage1/Release/$binary"
            binTarget = "bin/$binary"
            grammarPresent = $grammarPresent; buildPresent = $builtPresent
            binPresent = $installedPresent; binariesMatch = ($builtPresent -and $installedPresent -and $builtHash -eq $installedHash)
            authority = 'binding_metadata_only'; executable = $false
        }
    }
    [pscustomobject]@{ schema = 'micronaut.key-grammar-topology.v1'; authority = 'binding_metadata_only'; bindings = @($bindings) }
}

function Resolve-KeyGrammarTopology {
    param([Parameter(Mandatory)][string]$Key)
    $matches = @( (Get-KeyGrammarTopology).bindings | Where-Object { $_.key -ceq $Key })
    if ($matches.Count -ne 1) { throw "Unknown topology key: $Key" }
    return $matches[0]
}

Export-ModuleMember -Function Get-KeyGrammarTopology,Resolve-KeyGrammarTopology
