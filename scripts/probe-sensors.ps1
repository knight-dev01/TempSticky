param(
  [string]$Out = "$env:LOCALAPPDATA\TempSticky\probe.json"
)

$ErrorActionPreference = 'SilentlyContinue'
$dir = Split-Path -Parent $Out
if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }

$result = [ordered]@{
  isAdmin    = $false
  timestamp  = (Get-Date).ToString('o')
  acpi       = @()
  acpiError  = $null
  lhm        = $false
  ohm        = $false
  cpuLoad    = $null
  osCaption  = $null
}

$id = [Security.Principal.WindowsIdentity]::GetCurrent()
$result.isAdmin = ([Security.Principal.WindowsPrincipal]$id).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
$result.osCaption = (Get-CimInstance Win32_OperatingSystem).Caption

# --- ACPI thermal zones -------------------------------------------------
try {
  $zones = Get-CimInstance -Namespace 'root/WMI' -ClassName MSAcpi_ThermalZoneTemperature -ErrorAction Stop
  foreach ($z in $zones) {
    $c = [math]::Round(($z.CurrentTemperature / 10) - 273.15, 1)
    $result.acpi += [ordered]@{ name = $z.InstanceName; celsius = $c; raw = $z.CurrentTemperature }
  }
  if (-not $zones) { $result.acpiError = 'Class returned zero zones' }
} catch {
  $result.acpiError = $_.Exception.Message
}

# --- Third-party sensor namespaces -------------------------------------
foreach ($ns in @('LibreHardwareMonitor', 'OpenHardwareMonitor')) {
  try {
    $s = Get-CimInstance -Namespace "root/$ns" -ClassName Sensor -ErrorAction Stop
    if ($ns -eq 'LibreHardwareMonitor') { $result.lhm = [bool]$s } else { $result.ohm = [bool]$s }
    if ($s) {
      $result["${ns}_temps"] = @(
        $s | Where-Object { $_.SensorType -eq 'Temperature' } |
          Select-Object -First 40 |
          ForEach-Object { [ordered]@{ name = $_.Name; value = $_.Value; parent = $_.Parent; id = $_.Identifier } }
      )
    }
  } catch { }
}

# --- CPU load -----------------------------------------------------------
try {
  $p = Get-CimInstance Win32_PerfFormattedData_PerfOS_Processor -Filter "Name='_Total'" -ErrorAction Stop
  $result.cpuLoad = $p.PercentProcessorTime
} catch { }

$result | ConvertTo-Json -Depth 6 | Set-Content -Path $Out -Encoding UTF8
