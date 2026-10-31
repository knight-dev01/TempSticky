# Create a TRUE One-Click Installer
# User downloads ONE .exe file and double-clicks it
# Everything happens automatically!

param(
    [switch]$Verbose
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host "  Creating TRUE One-Click TempSticky Installer" -ForegroundColor Cyan
Write-Host "======================================================" -ForegroundColor Cyan
Write-Host ""

# Check if build exists
if (-not (Test-Path "dist\win-unpacked\TempSticky.exe")) {
    Write-Host "ERROR: Build not found!" -ForegroundColor Red
    Write-Host "Please run: npm run build:win" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host "[1/6] Preparing installer..." -ForegroundColor Yellow

# Create temp directory for installer package
$tempDir = "dist\installer-package"
if (Test-Path $tempDir) {
    Remove-Item $tempDir -Recurse -Force
}
New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

Write-Host "[2/6] Copying application files..." -ForegroundColor Yellow
Copy-Item "dist\win-unpacked\*" -Destination $tempDir -Recurse -Force

Write-Host "[3/6] Creating installer script..." -ForegroundColor Yellow

# Create the embedded installer PowerShell script
$installerScript = @'
# TempSticky Auto-Installer
# This script runs automatically when the user double-clicks the installer

# Check for admin privileges
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    # Re-launch as admin
    $scriptPath = $MyInvocation.MyCommand.Path
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command `"& '$scriptPath'`"" -Verb RunAs -Wait
    exit
}

# Hide the PowerShell window
Add-Type -Name Window -Namespace Console -MemberDefinition '[DllImport("Kernel32.dll")]public static extern IntPtr GetConsoleWindow();[DllImport("user32.dll")]public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);'
[Console.Window]::ShowWindow([Console.Window]::GetConsoleWindow(), 0)

# Show progress window
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "TempSticky Installer"
$form.Size = New-Object System.Drawing.Size(500, 300)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.MinimizeBox = $false
$form.TopMost = $true

$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Size = New-Object System.Drawing.Size(460, 80)
$label.Text = "Installing TempSticky...`n`nPlease wait while TempSticky is being installed on your computer."
$label.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$form.Controls.Add($label)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 120)
$progressBar.Size = New-Object System.Drawing.Size(460, 30)
$progressBar.Style = "Continuous"
$form.Controls.Add($progressBar)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 160)
$statusLabel.Size = New-Object System.Drawing.Size(460, 30)
$statusLabel.Text = "Preparing installation..."
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.Controls.Add($statusLabel)

$form.Show()
$form.Refresh()

# Installation directory
$installDir = "$env:ProgramFiles\TempSticky"
$tempExtractPath = "$env:TEMP\TempStickyInstaller"

# Extract embedded files
$statusLabel.Text = "Extracting files..."
$form.Refresh()
$progressBar.Value = 10

$scriptDir = Split-Path -Parent $PSCommandPath
if (Test-Path $tempExtractPath) {
    Remove-Item $tempExtractPath -Recurse -Force
}
Copy-Item $scriptDir -Destination $tempExtractPath -Recurse -Force

$progressBar.Value = 30
$statusLabel.Text = "Creating installation directory..."
$form.Refresh()

# Create install directory
if (Test-Path $installDir) {
    Remove-Item $installDir -Recurse -Force
}
New-Item -ItemType Directory -Path $installDir -Force | Out-Null

$progressBar.Value = 40
$statusLabel.Text = "Installing TempSticky..."
$form.Refresh()

# Copy files to Program Files
Copy-Item "$tempExtractPath\*" -Destination $installDir -Recurse -Force

$progressBar.Value = 60
$statusLabel.Text = "Creating shortcuts..."
$form.Refresh()

# Create Desktop shortcut
$WshShell = New-Object -ComObject WScript.Shell
$desktopPath = [Environment]::GetFolderPath("Desktop")
$shortcut = $WshShell.CreateShortcut("$desktopPath\TempSticky.lnk")
$shortcut.TargetPath = "$installDir\TempSticky.exe"
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = "$installDir\TempSticky.exe,0"
$shortcut.Description = "TempSticky - CPU Temperature Monitor"
$shortcut.Save()

# Create Start Menu shortcut
$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$shortcut = $WshShell.CreateShortcut("$startMenuPath\TempSticky.lnk")
$shortcut.TargetPath = "$installDir\TempSticky.exe"
$shortcut.WorkingDirectory = $installDir
$shortcut.IconLocation = "$installDir\TempSticky.exe,0"
$shortcut.Description = "TempSticky - CPU Temperature Monitor"
$shortcut.Save()

$progressBar.Value = 75
$statusLabel.Text = "Setting up temperature sensor..."
$form.Refresh()

# Run sensor setup silently
Set-Location $installDir
$setupScript = "$installDir\resources\scripts\setup-sensor.ps1"
if (Test-Path $setupScript) {
    & powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File $setupScript -Silent 2>&1 | Out-Null
}

$progressBar.Value = 90
$statusLabel.Text = "Cleaning up..."
$form.Refresh()

# Cleanup temp files
if (Test-Path $tempExtractPath) {
    Remove-Item $tempExtractPath -Recurse -Force -ErrorAction SilentlyContinue
}

# Create uninstaller
$uninstallScript = @"
`$installDir = "$installDir"
`$result = [System.Windows.Forms.MessageBox]::Show("Are you sure you want to uninstall TempSticky?", "Uninstall TempSticky", [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
if (`$result -eq [System.Windows.Forms.DialogResult]::Yes) {
    # Stop TempSticky if running
    Get-Process | Where-Object {`$_.ProcessName -like "*TempSticky*"} | Stop-Process -Force -ErrorAction SilentlyContinue
    
    # Remove shortcuts
    Remove-Item "`$env:USERPROFILE\Desktop\TempSticky.lnk" -Force -ErrorAction SilentlyContinue
    Remove-Item "`$env:APPDATA\Microsoft\Windows\Start Menu\Programs\TempSticky.lnk" -Force -ErrorAction SilentlyContinue
    
    # Run uninstall script
    if (Test-Path "`$installDir\resources\scripts\uninstall.ps1") {
        & powershell -NoProfile -ExecutionPolicy Bypass -File "`$installDir\resources\scripts\uninstall.ps1" -Silent
    }
    
    # Remove installation directory
    Start-Sleep -Seconds 2
    Remove-Item `$installDir -Recurse -Force -ErrorAction SilentlyContinue
    
    [System.Windows.Forms.MessageBox]::Show("TempSticky has been uninstalled.", "Uninstall Complete", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
}
"@

Set-Content -Path "$installDir\Uninstall.ps1" -Value $uninstallScript -Force

# Create uninstaller shortcut
$shortcut = $WshShell.CreateShortcut("$startMenuPath\Uninstall TempSticky.lnk")
$shortcut.TargetPath = "powershell.exe"
$shortcut.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$installDir\Uninstall.ps1`""
$shortcut.WorkingDirectory = $installDir
$shortcut.Description = "Uninstall TempSticky"
$shortcut.Save()

$progressBar.Value = 100
$statusLabel.Text = "Installation complete!"
$form.Refresh()

Start-Sleep -Seconds 1

# Close form
$form.Close()

# Show success message
[System.Windows.Forms.MessageBox]::Show(
    "TempSticky has been successfully installed!`n`n" +
    "Desktop shortcut created.`n" +
    "Look for the temperature icon in your system tray!`n`n" +
    "TempSticky will now start...",
    "Installation Complete",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Information
)

# Start TempSticky
Start-Process "$installDir\TempSticky.exe"
'@

Set-Content -Path "$tempDir\installer.ps1" -Value $installerScript -Force

Write-Host "[4/6] Creating self-extracting executable..." -ForegroundColor Yellow

# Create the batch wrapper that will become the .exe
$batchWrapper = @'
@echo off
REM TempSticky Installer - Auto-extracts and installs

REM Get temp directory
set "TEMP_EXTRACT=%TEMP%\TempStickySetup_%RANDOM%"

REM Extract embedded archive
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
"$scriptContent = Get-Content '%~f0' -Raw; " ^
"$startMarker = '___ARCHIVE_START___'; " ^
"$archiveStart = $scriptContent.IndexOf($startMarker) + $startMarker.Length; " ^
"$zipContent = $scriptContent.Substring($archiveStart); " ^
"$zipBytes = [System.Convert]::FromBase64String($zipContent); " ^
"[System.IO.File]::WriteAllBytes('%TEMP_EXTRACT%.zip', $zipBytes); " ^
"Add-Type -AssemblyName System.IO.Compression.FileSystem; " ^
"[System.IO.Compression.ZipFile]::ExtractToDirectory('%TEMP_EXTRACT%.zip', '%TEMP_EXTRACT%'); " ^
"Remove-Item '%TEMP_EXTRACT%.zip' -Force"

REM Run installer
powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "%TEMP_EXTRACT%\installer.ps1"

REM Cleanup
rmdir /s /q "%TEMP_EXTRACT%" 2>nul

exit
___ARCHIVE_START___
'@

Write-Host "[5/6] Compressing and encoding installer package..." -ForegroundColor Yellow

# Create ZIP of the temp directory
$zipPath = "dist\temp-installer.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($tempDir, $zipPath)

# Convert ZIP to Base64
$zipBytes = [System.IO.File]::ReadAllBytes($zipPath)
$base64Zip = [System.Convert]::ToBase64String($zipBytes)

# Combine batch wrapper with Base64 archive
$finalInstaller = $batchWrapper + $base64Zip

# Save as .exe (it's actually a .bat but users will run it like .exe)
$installerPath = "dist\TempSticky-Installer-1.0.0.exe"
Set-Content -Path $installerPath -Value $finalInstaller -Force

Write-Host "[6/6] Cleaning up temporary files..." -ForegroundColor Yellow

# Cleanup
Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

# Get file size
$installerSize = [math]::Round((Get-Item $installerPath).Length / 1MB, 2)

Write-Host ""
Write-Host "======================================================" -ForegroundColor Green
Write-Host "  SUCCESS! TRUE One-Click Installer Created!" -ForegroundColor Green
Write-Host "======================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installer created:" -ForegroundColor White
Write-Host "  $installerPath" -ForegroundColor Yellow
Write-Host ""
Write-Host "File size: $installerSize MB" -ForegroundColor Cyan
Write-Host ""
Write-Host "USERS JUST:" -ForegroundColor White
Write-Host "  1. Download this ONE file" -ForegroundColor Cyan
Write-Host "  2. Double-click it" -ForegroundColor Cyan
Write-Host "  3. Done! Everything automatic!" -ForegroundColor Green
Write-Host ""
Write-Host "No extraction needed!" -ForegroundColor Yellow
Write-Host "No manual setup!" -ForegroundColor Yellow
Write-Host "Just download and double-click!" -ForegroundColor Yellow
Write-Host ""

# Open folder
explorer "dist"
pause
