Set-StrictMode -Version Latest

$script:ProgramsRoot = Split-Path -Parent $PSCommandPath
$script:ProjectRoot = Split-Path -Parent $script:ProgramsRoot

$script:ProgramComponents = [ordered]@{
    JsonRuntime = @{
        Sco = 'dist/json-runtime/build/Release/sco_runtime.exe'
        Scxq2 = 'dist/json-runtime/build/Release/scxq2_runtime.exe'
        Json = 'dist/json-runtime/build/Release/json_runtime.exe'
        Library = 'dist/json-runtime/build/Release/json_runtime_lib.dll'
        Import = 'dist/json-runtime/build/Release/json_runtime_lib.lib'
        Export = 'dist/json-runtime/build/Release/json_runtime_lib.exp'
    }
    Sidecars = @{
        MicronautXjson = 'dist/json-runtime/build/Release/micronaut_xjson.exe'
        MoeGguf = 'versions/kuhul-v1.0.0/bin/runtime/moe_gguf_runtime.exe'
        GlyphCli = 'versions/kuhul-v1.0.0/bin/native/native_glyph_engine_cli.exe'
    }
    Drivers = @{
        Cs5Shaders = 'drivers/cs5_shaders'
        Khl = 'drivers/khl'
    }
    Folds = @{
        Orchestrator = 'dist/kuhul_folds/build/Release/FoldOrchestrator.exe'
        Root = 'dist/kuhul_folds/build/Release'
    }
    Bundles = @{
        Micronaut = 'dist/kuhul-micronaut'
        RuntimeV1 = 'dist/kuhul-runtime-v1'
        TrainerSources = 'dist/json-runtime/src/trainer'
        MX2 = 'dist/MX-2'
        MX2BrainCatalog = 'dist/MX-2/brains/brain_catalog.json'
        MX2JromRegistry = 'dist/MX-2/brains/jrom/registry.json'
        JromBrainAdapter = 'programs/micronauts/mx2-brain-jrom-adapter.json'
        JavaMicronaut = 'dist/json-runtime/build-asx-nmake/java'
        CodeMicronaut = 'dist/micronaut_cpp_runtime/build-nnck/micronaut.exe'
    }
}

function Resolve-ProgramPath {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Path)
    if ([IO.Path]::IsPathRooted($Path)) { return [IO.Path]::GetFullPath($Path) }
    return [IO.Path]::GetFullPath((Join-Path $script:ProjectRoot $Path))
}

function Get-ProgramComponents {
    [CmdletBinding()]
    param([string]$Group)
    if ($Group) {
        if (-not $script:ProgramComponents.Contains($Group)) { throw "Unknown component group: $Group" }
        return $script:ProgramComponents[$Group]
    }
    return $script:ProgramComponents
}

function Get-ProgramDependencyInventory {
    [CmdletBinding()]
    param([string]$Group)
    $selected = if ($Group) { @{ $Group = Get-ProgramComponents $Group } } else { $script:ProgramComponents }
    $items = foreach ($groupName in $selected.Keys) {
        foreach ($name in $selected[$groupName].Keys) {
            $relative = [string]$selected[$groupName][$name]
            $resolved = Resolve-ProgramPath $relative
            [pscustomobject]@{
                Group = $groupName
                Name = $name
                RelativePath = $relative
                Path = $resolved
                Exists = Test-Path -LiteralPath $resolved
                IsContainer = Test-Path -LiteralPath $resolved -PathType Container
            }
        }
    }
    return @($items)
}

function Test-ProgramDependencies {
    [CmdletBinding()]
    param([string]$Group)
    $inventory = @(Get-ProgramDependencyInventory $Group)
    $missing = [object[]]@($inventory | Where-Object { -not $_.Exists })
    $present = [object[]]@($inventory | Where-Object { $_.Exists })
    [pscustomobject]@{
        Ok = ($missing.Count -eq 0)
        Missing = $missing
        Present = $present
        Inventory = $inventory
    }
}

function Get-JsonRuntimeExecutable {
    [CmdletBinding()]
    param([ValidateSet('json','sco','scxq2','fold')][string]$Runtime = 'json')
    $relative = switch ($Runtime) {
        'json' { $script:ProgramComponents.JsonRuntime.Json }
        'sco' { $script:ProgramComponents.JsonRuntime.Sco }
        'scxq2' { $script:ProgramComponents.JsonRuntime.Scxq2 }
        'fold' { $script:ProgramComponents.Folds.Orchestrator }
    }
    $path = Resolve-ProgramPath $relative
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Runtime executable not found: $path" }
    return $path
}

function Get-AsxProgramPath {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$Name)
    $candidate = if ([IO.Path]::IsPathRooted($Name)) { $Name } else { Join-Path $script:ProgramsRoot $Name }
    if ([IO.Path]::GetExtension($candidate) -eq '') { $candidate += '.json' }
    $path = [IO.Path]::GetFullPath($candidate)
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) { throw "Program not found: $path" }
    return $path
}

function Invoke-AsxProgram {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Program,
        [ValidateSet('json','sco','scxq2','fold')][string]$Runtime = 'json',
        [string[]]$Argument = @(),
        [switch]$Wait
    )
    $programPath = Get-AsxProgramPath $Program
    $runtimePath = Get-JsonRuntimeExecutable $Runtime
    $args = @($programPath) + $Argument
    if ($Wait) {
        & $runtimePath @args
        return $LASTEXITCODE
    }
    return Start-Process -FilePath $runtimePath -ArgumentList $args -WorkingDirectory $script:ProjectRoot -PassThru
}

Export-ModuleMember -Function Resolve-ProgramPath,Get-ProgramComponents,Get-ProgramDependencyInventory,Test-ProgramDependencies,Get-JsonRuntimeExecutable,Get-AsxProgramPath,Invoke-AsxProgram
