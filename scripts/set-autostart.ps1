# Creates or removes the TempSticky startup shortcut (no admin needed).
param(
  [switch]$Disable,
  [string]$Target,
  [string]$AppPath,
  [string]$Icon
)

$ErrorActionPreference = 'SilentlyContinue'
$lnk = Join-Path ([Environment]::GetFolderPath('Startup')) 'TempSticky.lnk'

if ($Disable) {
  Remove-Item $lnk -Force
  exit 0
}

if (-not $Target -or -not $AppPath) { exit 1 }

$shell = New-Object -ComObject WScript.Shell
$shortcut = $shell.CreateShortcut($lnk)
$shortcut.TargetPath = $Target
$shortcut.Arguments = "`"$AppPath`""
$shortcut.WorkingDirectory = $AppPath
if ($Icon -and (Test-Path $Icon)) { $shortcut.IconLocation = "$Icon,0" }
$shortcut.Description = 'TempSticky temperature overlay'
$shortcut.Save()
