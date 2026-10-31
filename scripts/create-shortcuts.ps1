# Creates Desktop and Start Menu shortcuts for TempSticky (no admin needed).
$ErrorActionPreference = 'Stop'

$root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$exe = Join-Path $root 'node_modules\electron\dist\electron.exe'
$icon = Join-Path $root 'assets\tempsticky.ico'

if (-not (Test-Path $exe)) { throw "Electron not found at $exe. Run 'npm install' first." }

$shell = New-Object -ComObject WScript.Shell

$targets = @(
  (Join-Path ([Environment]::GetFolderPath('Desktop')) 'TempSticky.lnk'),
  (Join-Path ([Environment]::GetFolderPath('Programs')) 'TempSticky.lnk')
)

foreach ($lnk in $targets) {
  $shortcut = $shell.CreateShortcut($lnk)
  $shortcut.TargetPath = $exe
  $shortcut.Arguments = "`"$root`""
  $shortcut.WorkingDirectory = $root
  if (Test-Path $icon) { $shortcut.IconLocation = "$icon,0" }
  $shortcut.Description = 'Persistent system temperature overlay'
  $shortcut.Save()
  Write-Host "Created $lnk"
}
