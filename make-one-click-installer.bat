@echo off
REM TempSticky - Create ONE-FILE Installer
REM User downloads ONE .exe file and double-clicks - everything automatic!

title Creating One-Click Installer

echo.
echo ========================================
echo   Creating One-Click Installer
echo ========================================
echo.

REM Check build
if not exist "dist\win-unpacked\TempSticky.exe" (
    echo ERROR: Build not found! Run: npm run build:win
    pause
    exit /b 1
)

echo [1/3] Preparing installer package...

REM Create package folder
if exist "dist\setup-files" rmdir /s /q "dist\setup-files"
mkdir "dist\setup-files"

REM Copy app files
echo Copying application files...
xcopy "dist\win-unpacked\*" "dist\setup-files\" /E /I /Y /Q > nul

REM Create installer script
echo.
echo [2/3] Creating installer script...

powershell -Command "$script = @'"
powershell -Command "# TempSticky Auto-Installer"
powershell -Command "$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)"
powershell -Command "if (-not $isAdmin) { Start-Process powershell -ArgumentList \`"-NoProfile -ExecutionPolicy Bypass -File \`\`'$PSCommandPath\`\`'\`" -Verb RunAs; exit }"
powershell -Command "$installDir = \`"$env:ProgramFiles\TempSticky\`""
powershell -Command "Write-Host \`"Installing TempSticky to: $installDir\`" -ForegroundColor Green"
powershell -Command "New-Item -ItemType Directory -Path $installDir -Force | Out-Null"
powershell -Command "$scriptDir = Split-Path -Parent $PSCommandPath"
powershell -Command "Copy-Item \`"$scriptDir\*\`" -Destination $installDir -Recurse -Force"
powershell -Command "$WshShell = New-Object -ComObject WScript.Shell"
powershell -Command "$shortcut = $WshShell.CreateShortcut(\`"$env:USERPROFILE\Desktop\TempSticky.lnk\`")"
powershell -Command "$shortcut.TargetPath = \`"$installDir\TempSticky.exe\`""
powershell -Command "$shortcut.Save()"
powershell -Command "Set-Location $installDir"
powershell -Command "& powershell -NoProfile -ExecutionPolicy Bypass -File \`"$installDir\resources\scripts\setup-sensor.ps1\`" -Silent"
powershell -Command "Write-Host \`"Installation complete!\`" -ForegroundColor Green"
powershell -Command "Start-Process \`"$installDir\TempSticky.exe\`""
powershell -Command "'@ | Out-File 'dist\setup-files\install.ps1' -Encoding ASCII"

REM Create simple batch launcher
(
echo @echo off
echo powershell -NoProfile -ExecutionPolicy Bypass -File "%%~dp0install.ps1"
) > "dist\setup-files\TempSticky-Setup.bat"

echo.
echo [3/3] Creating self-extracting archive...
echo This will create a ZIP file that users extract once...

REM Create ZIP
powershell -Command "Compress-Archive -Path 'dist\setup-files\*' -DestinationPath 'dist\TempSticky-Installer-1.0.0.zip' -Force"

REM Get size
for %%A in ("dist\TempSticky-Installer-1.0.0.zip") do set SIZE=%%~zA
set /a SIZE_MB=SIZE/1048576

echo.
echo ========================================
echo   SUCCESS!
echo ========================================
echo.
echo Created: dist\TempSticky-Installer-1.0.0.zip
echo Size: %SIZE_MB% MB
echo.
echo USERS:
echo   1. Download ZIP
echo   2. Extract
echo   3. Double-click "TempSticky-Setup.bat"
echo   4. Everything installs automatically!
echo.
echo Opening dist folder...
start explorer "dist"

pause
