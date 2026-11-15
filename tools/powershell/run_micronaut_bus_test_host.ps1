#Requires -Version 5.1
param([int]$Port, [string]$ShutdownToken)
Import-Module (Join-Path $PSScriptRoot '../shell/Server.psm1') -Force
Start-MicronautBusServer -Port $Port -ShutdownToken $ShutdownToken
