# Deterministic terminal intent routing. Produces route proposals only.
function Resolve-TerminalRoute {
    param([Parameter(Mandatory)][string]$Text)
    $text = $Text.Trim()
    if (-not $text -or $text.Length -gt 4096) { throw 'Terminal route text must be 1..4096 characters.' }
    $route = 'chat'; $mode = ''; $cliVerb = ''; $argument = ''; $mutating = $false
    if ($text -match '(?i)^/(code|generate)\b|\b(show|write|generate|create|build)\b.*\b(code|function|class|script|web ?page|html|typescript|javascript|python|c\+\+)\b') {
        $route = 'model_code'; $mode = 'code_local_v1'
    } elseif ($text -match '(?i)^/(gemma|model)\b|\b(use|ask|query)\s+(the\s+)?(local\s+)?(gemma|model)\b') {
        $route = 'model'; $mode = 'neural_local_v1'
    } elseif ($text -match '(?i)^/(vector|search|retrieve)\b|\b(search|retrieve|look up)\b') {
        $route = 'retrieval'; $mode = 'vector_extended_v1'
    } elseif ($text -match '(?i)\b(run|execute|install|delete|remove|build|test)\b.*\b(command|terminal|shell|process|file|package|project)\b') {
        $route = 'terminal_guidance'
    }
    if ($text -match '(?i)\b(show|run|execute)\s+(stats|statistics)\b') { $cliVerb = 'stats'; $route = 'terminal_command' }
    elseif ($text -match '(?i)\b(show|run|execute)\s+help\b') { $cliVerb = 'help'; $route = 'terminal_command' }
    elseif ($route -eq 'terminal_guidance') { $cliVerb = 'help' }
    $mutating = $cliVerb -notin @('','help','stats')
    return [pscustomobject]@{ schema = 'micronaut.terminal-route.v1'; route = $route;
        responseMode = $mode; intent = $text; authority = 'route_proposal'; executes_command = $false;
        command = $cliVerb; argument = $argument; mutating = $mutating }
}
Export-ModuleMember -Function Resolve-TerminalRoute
