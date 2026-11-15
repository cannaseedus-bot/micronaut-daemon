#Requires -Version 5.1
$ErrorActionPreference = 'Stop'
Import-Module (Join-Path $PSScriptRoot '../shell/Server.psm1') -Force
$module = Get-Module Server
$generated = & $module {
    & $script:BindingHandlers['coder.grammar'] @{ operation = 'generate'; language = 'typescript'; identifier = 'demo' }
}
$checked = & $module {
    param($source, $ast)
    & $script:BindingHandlers['coder.grammar'] @{ operation = 'validate_ast'; language = 'typescript'; source = $source; ast = $ast }
} $generated.source $generated.parsed
if (-not $checked.valid) { throw 'Generated AST did not validate.' }
'CODER grammar binding and AST validation passed'
