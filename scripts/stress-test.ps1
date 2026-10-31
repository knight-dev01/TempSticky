param([string]$Out = "$env:LOCALAPPDATA\TempSticky\stress.json")

$ErrorActionPreference = 'SilentlyContinue'
$dir = Split-Path -Parent $Out
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

function Get-Zone {
  (Get-CimInstance -Namespace 'root/WMI' -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction SilentlyContinue |
    ForEach-Object { [math]::Round(($_.CurrentTemperature / 10) - 273.15, 1) } |
    Measure-Object -Maximum).Maximum
}
function Get-Load {
  (Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'" -ErrorAction SilentlyContinue).PercentProcessorTime
}

$samples = @()
$samples += [ordered]@{ phase = 'idle'; t = Get-Zone; load = Get-Load }
Start-Sleep -Seconds 2
$samples += [ordered]@{ phase = 'idle'; t = Get-Zone; load = Get-Load }

$jobs = 1..8 | ForEach-Object {
  Start-Job -ScriptBlock { $x = 0.0; while ($true) { $x = [math]::Sqrt($x + 1.2345) } }
}

for ($i = 0; $i -lt 10; $i++) {
  Start-Sleep -Seconds 2
  $samples += [ordered]@{ phase = 'load'; t = Get-Zone; load = Get-Load }
}

$jobs | Stop-Job -ErrorAction SilentlyContinue
$jobs | Remove-Job -Force -ErrorAction SilentlyContinue

for ($i = 0; $i -lt 5; $i++) {
  Start-Sleep -Seconds 2
  $samples += [ordered]@{ phase = 'cooldown'; t = Get-Zone; load = Get-Load }
}

[ordered]@{
  samples = $samples
  idle    = ($samples | Where-Object phase -eq 'idle'   | Measure-Object t -Maximum).Maximum
  peak    = ($samples | Where-Object phase -eq 'load'   | Measure-Object t -Maximum).Maximum
  after   = ($samples | Where-Object phase -eq 'cooldown' | Measure-Object t -Minimum).Minimum
} | ConvertTo-Json -Depth 5 | Set-Content -Path $Out -Encoding UTF8
