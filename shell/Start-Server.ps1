#Requires -Version 7
param([ValidateRange(1,65535)][int]$Port = 9880)
Import-Module (Join-Path $PSScriptRoot 'Server.psm1') -Force
Start-MicronautBusServer -Port $Port
