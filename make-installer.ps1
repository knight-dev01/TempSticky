# TempSticky Simple Installer Creator

Write-Host "Creating TempSticky Installer..." -ForegroundColor Cyan

# Check if build exists
if (-not (Test-Path "dist\win-unpacked\TempSticky.exe")) {
    Write-Host "ERROR: Build not found! Run: npm run build:win" -ForegroundColor Red
    exit 1
}

# Prepare installer directory
$installerDir = "dist\TempSticky-Installer"
if (Test-Path $installerDir) {
    Remove-Item $installerDir -Recurse -Force
}
New-Item -ItemType Directory -Path $installerDir -Force | Out-Null

# Copy all files
Write-Host "Copying files..." -ForegroundColor Yellow
Copy-Item "dist\win-unpacked\*" -Destination $installerDir -Recurse -Force
Copy-Item "SETUP.bat" -Destination $installerDir -Force
Copy-Item "START.bat" -Destination $installerDir -Force
Copy-Item "README_FOR_USERS.txt" -Destination "$installerDir\README.txt" -Force

# Create installer batch file
$installBat = @'
@echo off
title TempSticky Setup
cls
echo.
echo ========================================
echo   TempSticky v1.0.0 Installer
echo ========================================
echo.
echo This will install TempSticky on your computer.
echo.
echo Click YES when Windows asks for permission.
echo.
pause

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0install-script.ps1"
'@

Set-Content -Path "$installerDir\Install TempSticky.bat" -Value $installBat

# Create PowerShell installer script  
$installPS1 = @'
# Request admin if needed
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

$installDir = "$env:ProgramFiles\TempSticky"
$scriptDir = Split-Path -Parent $PSCommandPath

Write-Host "Installing TempSticky to: $installDir" -ForegroundColor Green
New-Item -ItemType Directory -Path $installDir -Force | Out-Null
Copy-Item "$scriptDir\*" -Destination $installDir -Recurse -Force

Write-Host "Creating shortcuts..." -ForegroundColor Yellow
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\TempSticky.lnk")
$shortcut.TargetPath = "$installDir\TempSticky.exe"
$shortcut.Save()

Write-Host "Setting up sensor..." -ForegroundColor Yellow
Set-Location $installDir
& powershell -NoProfile -ExecutionPolicy Bypass -File "$installDir\resources\scripts\setup-sensor.ps1"

Write-Host ""
Write-Host "Installation complete!" -ForegroundColor Green
Write-Host "Starting TempSticky..." -ForegroundColor Yellow
Start-Process "$installDir\TempSticky.exe"
Start-Sleep -Seconds 2
'@

Set-Content -Path "$installerDir\install-script.ps1" -Value $installPS1

# Create ZIP
Write-Host "Creating ZIP package..." -ForegroundColor Yellow
$zipPath = "dist\TempSticky-Setup-1.0.0.zip"
if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($installerDir, $zipPath)

$size = [math]::Round((Get-Item $zipPath).Length / 1MB, 2)
Write-Host ""
Write-Host "SUCCESS! Created: TempSticky-Setup-1.0.0.zip ($size MB)" -ForegroundColor Green
Write-Host ""
Write-Host "Users: Extract ZIP and run 'Install TempSticky.bat'" -ForegroundColor Cyan
explorer "dist"
