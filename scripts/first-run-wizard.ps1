# TempSticky First-Run Setup Wizard
# This script guides non-technical users through setup

param(
    [switch]$Silent = $false
)

$ErrorActionPreference = "Stop"

# Colors for better UX
function Write-Success { Write-Host $args -ForegroundColor Green }
function Write-Info { Write-Host $args -ForegroundColor Cyan }
function Write-Warning { Write-Host $args -ForegroundColor Yellow }
function Write-Error { Write-Host $args -ForegroundColor Red }

# Banner
function Show-Banner {
    Clear-Host
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║                                                        ║" -ForegroundColor Cyan
    Write-Host "║         🌡️  TempSticky Setup Wizard  🌡️                ║" -ForegroundColor Cyan
    Write-Host "║                                                        ║" -ForegroundColor Cyan
    Write-Host "║     Temperature Monitor for Your Desktop              ║" -ForegroundColor Cyan
    Write-Host "║                                                        ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

# Welcome message
function Show-Welcome {
    if (-not $Silent) {
        Show-Banner
        Write-Info "Welcome to TempSticky! 👋"
        Write-Host ""
        Write-Host "This wizard will help you set up TempSticky in just a few steps."
        Write-Host ""
        Write-Host "What TempSticky does:"
        Write-Host "  • Shows your CPU temperature in real-time"
        Write-Host "  • Lives in your system tray"
        Write-Host "  • Changes color based on temperature"
        Write-Host "  • Runs automatically when Windows starts"
        Write-Host ""
        Write-Host "Press any key to continue..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
}

# Check if running as admin
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Request admin if needed
function Request-Admin {
    if (-not (Test-Admin)) {
        Show-Banner
        Write-Warning "⚠️  Administrator access required"
        Write-Host ""
        Write-Host "TempSticky needs administrator access to install the temperature sensor."
        Write-Host "This is a one-time requirement for setup."
        Write-Host ""
        Write-Host "Click 'Yes' on the next prompt to continue..." -ForegroundColor Yellow
        Write-Host ""
        
        Start-Sleep -Seconds 2
        
        # Re-launch as admin
        $scriptPath = $MyInvocation.MyCommand.Path
        Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
        exit
    }
}

# Check .NET Framework
function Test-DotNetFramework {
    Show-Banner
    Write-Info "Step 1 of 4: Checking system requirements..."
    Write-Host ""
    
    try {
        $release = Get-ItemPropertyValue -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release -ErrorAction Stop
        
        if ($release -ge 461808) {
            Write-Success "✓ .NET Framework 4.7.2 or higher installed"
            return $true
        } else {
            Write-Warning "⚠️  .NET Framework 4.7.2 or higher required"
            Write-Host ""
            Write-Host "Would you like to download it now? (Y/N): " -NoNewline -ForegroundColor Yellow
            $response = Read-Host
            
            if ($response -eq 'Y' -or $response -eq 'y') {
                Start-Process "https://dotnet.microsoft.com/download/dotnet-framework/net472"
                Write-Info "Please install .NET Framework and run this setup again."
                exit
            }
            return $false
        }
    } catch {
        Write-Warning "⚠️  Could not detect .NET Framework"
        return $false
    }
    
    Start-Sleep -Seconds 1
}

# Install sensor
function Install-Sensor {
    Show-Banner
    Write-Info "Step 2 of 4: Installing temperature sensor..."
    Write-Host ""
    Write-Host "This will:"
    Write-Host "  • Download LibreHardwareMonitor library"
    Write-Host "  • Install PawnIO driver (for reading CPU sensors)"
    Write-Host "  • Create a background task"
    Write-Host ""
    Write-Host "Installing..." -ForegroundColor Yellow
    
    try {
        $scriptPath = Join-Path $PSScriptRoot "setup-sensor.ps1"
        & $scriptPath -Silent
        
        Write-Success "✓ Temperature sensor installed successfully!"
        Start-Sleep -Seconds 2
        return $true
    } catch {
        Write-Error "✗ Sensor installation failed: $_"
        Write-Host ""
        Write-Host "Press any key to continue anyway..." -ForegroundColor Yellow
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        return $false
    }
}

# Test sensor
function Test-Sensor {
    Show-Banner
    Write-Info "Step 3 of 4: Testing temperature sensor..."
    Write-Host ""
    
    # Wait for sensor to write data
    Write-Host "Waiting for sensor reading..." -NoNewline
    Start-Sleep -Seconds 3
    Write-Host " Done!" -ForegroundColor Green
    
    $sensorFile = "$env:LOCALAPPDATA\TempSticky\sensor.json"
    
    if (Test-Path $sensorFile) {
        try {
            $data = Get-Content $sensorFile -Raw | ConvertFrom-Json
            
            if ($data.cpu -and $data.cpu.temp) {
                $temp = $data.cpu.temp
                Write-Success "✓ Sensor is working! Current CPU temperature: $temp°C"
                
                # Visual temperature indicator
                Write-Host ""
                if ($temp -lt 50) {
                    Write-Host "    Status: COOL 🔵" -ForegroundColor Cyan
                } elseif ($temp -lt 75) {
                    Write-Host "    Status: OPTIMAL 🟢" -ForegroundColor Green
                } elseif ($temp -lt 88) {
                    Write-Host "    Status: WARM 🟡" -ForegroundColor Yellow
                } else {
                    Write-Host "    Status: HOT 🔴" -ForegroundColor Red
                }
                
                Start-Sleep -Seconds 3
                return $true
            }
        } catch {
            Write-Warning "⚠️  Could not read sensor data"
        }
    } else {
        Write-Warning "⚠️  Sensor file not found"
    }
    
    Write-Host ""
    Write-Host "The sensor may need a moment to start."
    Write-Host "TempSticky will continue to work once it's ready."
    Start-Sleep -Seconds 2
    return $false
}

# Configure autostart
function Set-AutoStart {
    Show-Banner
    Write-Info "Step 4 of 4: Configuration"
    Write-Host ""
    Write-Host "Would you like TempSticky to start automatically when Windows boots?"
    Write-Host ""
    Write-Host "  (Y) Yes - Start with Windows (Recommended)" -ForegroundColor Green
    Write-Host "  (N) No  - Start manually"
    Write-Host ""
    Write-Host "Your choice (Y/N): " -NoNewline -ForegroundColor Yellow
    
    $response = Read-Host
    
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Host ""
        Write-Host "Setting up auto-start..." -ForegroundColor Yellow
        
        # Create startup shortcut
        $WshShell = New-Object -ComObject WScript.Shell
        $StartupPath = [System.Environment]::GetFolderPath('Startup')
        $ShortcutPath = Join-Path $StartupPath "TempSticky.lnk"
        
        # Find TempSticky.exe in program files
        $exePath = "${env:ProgramFiles}\TempSticky\TempSticky.exe"
        if (-not (Test-Path $exePath)) {
            $exePath = "${env:ProgramFiles(x86)}\TempSticky\TempSticky.exe"
        }
        
        if (Test-Path $exePath) {
            $Shortcut = $WshShell.CreateShortcut($ShortcutPath)
            $Shortcut.TargetPath = $exePath
            $Shortcut.WorkingDirectory = Split-Path $exePath
            $Shortcut.Save()
            
            Write-Success "✓ Auto-start enabled"
        } else {
            Write-Warning "⚠️  Could not find TempSticky.exe"
        }
    } else {
        Write-Info "Auto-start disabled. You can enable it later from the tray menu."
    }
    
    Start-Sleep -Seconds 2
}

# Completion
function Show-Completion {
    Show-Banner
    Write-Success "🎉 Setup Complete!"
    Write-Host ""
    Write-Host "TempSticky is ready to use!"
    Write-Host ""
    Write-Host "Quick Guide:" -ForegroundColor Cyan
    Write-Host "  • Look for the temperature icon in your system tray"
    Write-Host "  • The sticky note shows your CPU temperature"
    Write-Host "  • Click X to hide (it stays in the tray)"
    Write-Host "  • Press Ctrl + Alt + T to show/hide"
    Write-Host "  • Right-click the tray icon for settings"
    Write-Host ""
    Write-Host "Color Guide:" -ForegroundColor Cyan
    Write-Host "  🔵 Cool    - Below 50°C"
    Write-Host "  🟢 Optimal - 50-75°C"
    Write-Host "  🟡 Warm    - 75-88°C"
    Write-Host "  🔴 Hot     - 88°C and above"
    Write-Host ""
    Write-Host "TempSticky will now start..." -ForegroundColor Yellow
    Write-Host ""
    Start-Sleep -Seconds 3
}

# Main execution
try {
    Show-Welcome
    Request-Admin
    
    # Step 1: Check .NET
    if (-not (Test-DotNetFramework)) {
        Write-Error "Setup cannot continue without .NET Framework."
        exit 1
    }
    
    # Step 2: Install sensor
    Install-Sensor
    
    # Step 3: Test sensor
    Test-Sensor
    
    # Step 4: Configure
    if (-not $Silent) {
        Set-AutoStart
    }
    
    # Complete
    Show-Completion
    
    exit 0
    
} catch {
    Write-Error "Setup failed: $_"
    Write-Host ""
    Write-Host "Press any key to exit..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
}
