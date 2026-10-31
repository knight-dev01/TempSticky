<#
  Removes the TempSticky sensor task. Run elevated.
    .\uninstall.ps1              # remove task only
    .\uninstall.ps1 -RemoveData  # also delete downloaded LHM + sensor files
#>
[CmdletBinding()]
param([switch]$RemoveData)

$ErrorActionPreference = 'SilentlyContinue'
$taskName = 'TempSticky Sensor'
$dataDir = Join-Path $env:LOCALAPPDATA 'TempSticky'

$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$isAdmin = ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
  Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"") -Wait
  exit
}

Stop-ScheduledTask -TaskName $taskName
Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
Write-Host "Removed scheduled task '$taskName'."

Get-Process -Name 'TempSensor' -ErrorAction SilentlyContinue | Stop-Process -Force

if ($RemoveData) {
  Remove-Item -Path $dataDir -Recurse -Force
  Write-Host "Deleted $dataDir"
}

Write-Host 'Done. The overlay app itself is unaffected; delete the TempSticky folder to remove it.'
