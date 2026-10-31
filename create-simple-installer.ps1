# TempSticky Simple Installer Creator
# Creates a one-click installer for non-technical users

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================"
Write-Host "  Creating TempSticky Installer"
Write-Host "========================================"
Write-Host ""

# Check if build exists
if (-not (Test-Path "dist\win-unpacked\TempSticky.exe")) {
    Write-Host "ERROR: Build not found!" -ForegroundColor Red
    Write-Host "Please run: npm run build:win" -ForegroundColor Yellow
    pause
    exit 1
}

# Prepare installer directory
Write-Host "[1/4] Preparing installer files..." -ForegroundColor Cyan
$installerDir = "dist\TempSticky-Installer"
if (Test-Path $installerDir) {
    Remove-Item $installerDir -Recurse -Force
}
New-Item -ItemType Directory -Path $installerDir -Force | Out-Null

# Copy all files
Write-Host "[2/4] Copying application files..." -ForegroundColor Cyan
Copy-Item "dist\win-unpacked\*" -Destination $installerDir -Recurse -Force

# Copy helper files
Copy-Item "SETUP.bat" -Destination $installerDir -Force
Copy-Item "START.bat" -Destination $installerDir -Force
Copy-Item "README_FOR_USERS.txt" -Destination "$installerDir\README.txt" -Force

# Create the master installer script
Write-Host "[3/4] Creating installer..." -ForegroundColor Cyan

$installerScript = @'
# TempSticky One-Click Installer
# This script installs TempSticky automatically

$ErrorActionPreference = "Stop"

# Check for admin
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Requesting administrator access..." -ForegroundColor Yellow
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# ASCII Art
Clear-Host
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                        ║" -ForegroundColor Cyan  
Write-Host "║    🌡️  TempSticky Installer  🌡️          ║" -ForegroundColor Cyan
Write-Host "║                                        ║" -ForegroundColor Cyan
Write-Host "║         Version 1.0.0                  ║" -ForegroundColor Cyan
Write-Host "║                                        ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Installation directory
$installDir = "$env:ProgramFiles\TempSticky"

Write-Host "Installing TempSticky..." -ForegroundColor Green
Write-Host ""
Write-Host "Installation directory:" -ForegroundColor Yellow
Write-Host "  $installDir"
Write-Host ""

# Create directory
Write-Host "[1/5] Creating installation directory..." -ForegroundColor Cyan
if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
}
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

# Copy files
Write-Host "[2/5] Copying application files..." -ForegroundColor Cyan
$scriptDir = Split-Path -Parent $PSCommandPath
Copy-Item "$scriptDir\*" -Destination $installDir -Recurse -Force -Exclude "INSTALL.ps1"

# Create desktop shortcut
Write-Host "[3/5] Creating desktop shortcut..." -ForegroundColor Cyan
$WshShell = New-Object -ComObject WScript.Shell
$desktopShortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\TempSticky.lnk")
$desktopShortcut.TargetPath = "$installDir\TempSticky.exe"
$desktopShortcut.WorkingDirectory = $installDir
$desktopShortcut.IconLocation = "$installDir\TempSticky.exe"
$desktopShortcut.Description = "TempSticky - CPU Temperature Monitor"
$desktopShortcut.Save()

# Create Start Menu shortcut
Write-Host "[4/5] Creating Start Menu shortcut..." -ForegroundColor Cyan
$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$startMenuShortcut = $WshShell.CreateShortcut("$startMenuPath\TempSticky.lnk")
$startMenuShortcut.TargetPath = "$installDir\TempSticky.exe"
$startMenuShortcut.WorkingDirectory = $installDir
$startMenuShortcut.IconLocation = "$installDir\TempSticky.exe"
$startMenuShortcut.Description = "TempSticky - CPU Temperature Monitor"
$startMenuShortcut.Save()

# Run sensor setup
Write-Host "[5/5] Setting up temperature sensor..." -ForegroundColor Cyan
Write-Host ""
Set-Location $installDir
& powershell -NoProfile -ExecutionPolicy Bypass -File "$installDir\resources\scripts\setup-sensor.ps1" -Silent

# Success
Write-Host ""
Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║                                        ║" -ForegroundColor Green
Write-Host "║    ✅  Installation Complete!  ✅        ║" -ForegroundColor Green
Write-Host "║                                        ║" -ForegroundColor Green
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""
Write-Host "TempSticky has been installed to:" -ForegroundColor White
Write-Host "  $installDir" -ForegroundColor Yellow
Write-Host ""
Write-Host "Shortcuts created:" -ForegroundColor White
Write-Host "  ✓ Desktop" -ForegroundColor Green
Write-Host "  ✓ Start Menu" -ForegroundColor Green
Write-Host ""
Write-Host "Starting TempSticky..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

# Start the application
Start-Process "$installDir\TempSticky.exe"

Write-Host ""
Write-Host "Look for the 🌡️ icon in your system tray!" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
'@

Set-Content -Path "$installerDir\INSTALL.ps1" -Value $installerScript -Force

# Create a simple batch launcher
$batchLauncher = @'
@echo off
title TempSticky Installer
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0INSTALL.ps1"
'@

Set-Content -Path "$installerDir\Install TempSticky.bat" -Value $batchLauncher -Force

# Create ZIP
Write-Host "[4/4] Creating installer package..." -ForegroundColor Cyan
$zipPath = "dist\TempSticky-Setup-1.0.0.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory(
    (Resolve-Path $installerDir).Path,
    (Resolve-Path "dist").Path + "\TempSticky-Setup-1.0.0.zip"
)

# Get file size
$zipSize = (Get-Item $zipPath).Length / 1MB

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  SUCCESS!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installer created:" -ForegroundColor White
Write-Host "  dist\TempSticky-Setup-1.0.0.zip" -ForegroundColor Yellow
Write-Host ""
Write-Host "Size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "Users just need to:" -ForegroundColor White
Write-Host "  1. Download the ZIP" -ForegroundColor Cyan
Write-Host "  2. Extract it" -ForegroundColor Cyan
Write-Host "  3. Double-click 'Install TempSticky.bat'" -ForegroundColor Cyan
Write-Host "  4. Done! Everything installs automatically" -ForegroundColor Green
Write-Host ""
Write-Host "Opening dist folder..." -ForegroundColor Yellow
Start-Process "dist"
Write-Host ""
pause
'@

Set-Content -Path "create-simple-installer.ps1" -Value $installerScript -Force
