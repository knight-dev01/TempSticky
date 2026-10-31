<#
  TempSticky sensor setup (run elevated).

  Installs the pieces needed to read real CPU/GPU temperatures on Windows 11
  with Memory Integrity (HVCI) enabled:
    1. LibreHardwareMonitor library (data source)
    2. PawnIO signed kernel driver (what LHM uses to read sensors)
    3. TempSensor.exe helper compiled from sensor/TempSensor.cs
    4. A hidden scheduled task that keeps the helper running at logon

  Writes %LOCALAPPDATA%\TempSticky\setup-result.json when finished.
#>
[CmdletBinding()]
param(
  [switch]$Elevated
)

$ErrorActionPreference = 'Stop'

$root      = Split-Path -Parent $PSScriptRoot
$dataDir   = Join-Path $env:LOCALAPPDATA 'TempSticky'
$lhmDir    = Join-Path $dataDir 'LHM'
$exePath   = Join-Path $lhmDir 'TempSensor.exe'
$sensorOut = Join-Path $dataDir 'sensor.json'
$resultOut = Join-Path $dataDir 'setup-result.json'
$taskName  = 'TempSticky Sensor'
$lhmUrl    = 'https://github.com/LibreHardwareMonitor/LibreHardwareMonitor/releases/download/v0.9.6/LibreHardwareMonitor.zip'

function Write-Result([bool]$ok, [string]$message, $temp = $null) {
  $payload = [ordered]@{
    ok      = $ok
    message = $message
    temp    = $temp
    at      = (Get-Date).ToString('o')
  }
  try {
    New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
    $payload | ConvertTo-Json | Set-Content -Path $resultOut -Encoding UTF8
  } catch { }
  Write-Host $message
}

function Test-Admin {
  $id = [Security.Principal.WindowsIdentity]::GetCurrent()
  ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-Admin)) {
  if ($Elevated) { Write-Result $false 'Elevation failed.'; exit 1 }
  $args = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`"", '-Elevated')
  Start-Process -FilePath 'powershell.exe' -Verb RunAs -ArgumentList $args
  exit 0
}

New-Item -ItemType Directory -Path $dataDir -Force | Out-Null
New-Item -ItemType Directory -Path $lhmDir -Force | Out-Null
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
  # ---------------------------------------------------------------- 1. LHM lib
  if (-not (Test-Path (Join-Path $lhmDir 'LibreHardwareMonitorLib.dll'))) {
    Write-Host 'Downloading LibreHardwareMonitor…'
    $zip = Join-Path $env:TEMP 'lhm-tempsticky.zip'
    Invoke-WebRequest -Uri $lhmUrl -OutFile $zip -UseBasicParsing
    Expand-Archive -Path $zip -DestinationPath $lhmDir -Force
    Remove-Item $zip -Force -ErrorAction SilentlyContinue
  }

  # ----------------------------------------------------------------- 2. PawnIO
  $pawn = Get-Service -Name 'PawnIO' -ErrorAction SilentlyContinue
  if (-not $pawn) {
    Write-Host 'Installing PawnIO driver…'
    $winget = (Get-Command winget.exe -ErrorAction SilentlyContinue).Source
    if ($winget) {
      & $winget install --id namazso.PawnIO --silent --accept-package-agreements --accept-source-agreements --disable-interactivity | Out-Null
    }
    $pawn = Get-Service -Name 'PawnIO' -ErrorAction SilentlyContinue
    if (-not $pawn) {
      # fall back to the signed installer directly
      $setup = Join-Path $env:TEMP 'PawnIO_setup.exe'
      Invoke-WebRequest -Uri 'https://github.com/namazso/PawnIO.Setup/releases/download/2.2.0/PawnIO_setup.exe' -OutFile $setup -UseBasicParsing
      Start-Process -FilePath $setup -ArgumentList '/S' -Wait
      Remove-Item $setup -Force -ErrorAction SilentlyContinue
    }
  }

  # ------------------------------------------------------- 3. compile helper
  $src = Join-Path $root 'sensor\TempSensor.cs'
  if (-not (Test-Path $src)) { throw "Helper source missing: $src" }

  $csc = @(
    'C:\Windows\Microsoft.NET\Framework64\v4.0.30319\csc.exe',
    'C:\Windows\Microsoft.NET\Framework\v4.0.30319\csc.exe'
  ) | Where-Object { Test-Path $_ } | Select-Object -First 1
  if (-not $csc) { throw 'C# compiler (csc.exe) not found.' }

  Write-Host 'Compiling sensor helper…'
  & $csc /nologo /target:winexe /platform:anycpu /optimize+ /out:"$exePath" /r:"$lhmDir\LibreHardwareMonitorLib.dll" $src
  if ($LASTEXITCODE -ne 0) { throw "Compile failed (exit $LASTEXITCODE)" }

  # ------------------------------------------------------ 4. scheduled task
  Write-Host 'Registering scheduled task…'
  Stop-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue
  Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue

  $action = New-ScheduledTaskAction -Execute $exePath -Argument "`"$sensorOut`" 2000" -WorkingDirectory $lhmDir
  $trigger = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
  $principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
  $taskSettings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -ExecutionTimeLimit ([TimeSpan]::Zero)
  $taskSettings.Hidden = $true

  Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger `
    -Principal $principal -Settings $taskSettings -Description 'Live CPU/GPU temperature feed for TempSticky' -Force | Out-Null

  # ----------------------------------------------------------- 5. run + check
  Write-Host 'Starting sensor…'
  if (Test-Path $sensorOut) { Remove-Item $sensorOut -Force -ErrorAction SilentlyContinue }
  Start-ScheduledTask -TaskName $taskName

  $temp = $null
  for ($i = 0; $i -lt 20; $i++) {
    Start-Sleep -Milliseconds 750
    if (Test-Path $sensorOut) {
      try {
        $data = Get-Content $sensorOut -Raw | ConvertFrom-Json
        if ($data.ok -eq $true -and $data.cpu -ne $null) { $temp = $data.cpu; break }
      } catch { }
    }
  }

  if ($temp -ne $null) {
    Write-Result $true "Sensor online: CPU $temp C" $temp
  } else {
    $detail = ''
    if (Test-Path $sensorOut) {
      try { $detail = (Get-Content $sensorOut -Raw | ConvertFrom-Json).error } catch { }
    }
    Write-Result $false ("Sensor started but no temperature reading yet." + $(if ($detail) { " ($detail)" } else { '' }))
  }
} catch {
  Write-Result $false $_.Exception.Message
  exit 1
}
