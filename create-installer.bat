@echo off
REM TempSticky - Create Self-Installing Package
REM This creates a one-click installer for users

echo.
echo ========================================
echo   Creating TempSticky Installer
echo ========================================
echo.

REM Check if the unpacked build exists
if not exist "dist\win-unpacked" (
    echo ERROR: Build not found!
    echo Please run: npm run build:win
    pause
    exit /b 1
)

REM Create a temporary folder for installer files
echo [1/5] Preparing installer files...
if exist "dist\installer-temp" rmdir /s /q "dist\installer-temp"
mkdir "dist\installer-temp"

REM Copy application files
echo [2/5] Copying application files...
xcopy "dist\win-unpacked\*" "dist\installer-temp\" /E /I /Y /Q > nul

REM Copy user-friendly files
echo [3/5] Adding setup scripts...
copy "SETUP.bat" "dist\installer-temp\" > nul
copy "START.bat" "dist\installer-temp\" > nul
copy "README_FOR_USERS.txt" "dist\installer-temp\README.txt" > nul

REM Create an auto-installer script
echo [4/5] Creating installer script...
(
echo @echo off
echo title TempSticky Setup
echo echo.
echo echo ========================================
echo echo   TempSticky v1.0.0 Setup
echo echo ========================================
echo echo.
echo echo Installing TempSticky...
echo echo.
echo.
echo REM Create installation directory
echo set "INSTALL_DIR=%%ProgramFiles%%\TempSticky"
echo if not exist "%%INSTALL_DIR%%" mkdir "%%INSTALL_DIR%%"
echo.
echo REM Copy files
echo xcopy "%%~dp0*" "%%INSTALL_DIR%%\" /E /I /Y /Q
echo.
echo REM Create desktop shortcut
echo powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%USERPROFILE%\Desktop\TempSticky.lnk'^); $SC.TargetPath = '%%INSTALL_DIR%%\TempSticky.exe'; $SC.Save(^)"
echo.
echo REM Create Start Menu shortcut
echo powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\TempSticky.lnk'^); $SC.TargetPath = '%%INSTALL_DIR%%\TempSticky.exe'; $SC.Save(^)"
echo.
echo REM Run sensor setup
echo echo Setting up temperature sensor...
echo cd /d "%%INSTALL_DIR%%"
echo powershell -NoProfile -ExecutionPolicy Bypass -File "resources\scripts\setup-sensor.ps1" -Silent
echo.
echo REM Ask to start
echo echo.
echo echo ========================================
echo echo   Installation Complete!
echo echo ========================================
echo echo.
echo echo TempSticky installed to:
echo echo   %%INSTALL_DIR%%
echo echo.
echo echo Desktop shortcut created!
echo echo.
echo set /p "START=Start TempSticky now? (Y/N): "
echo if /i "%%START%%"=="Y" (
echo     start "" "%%INSTALL_DIR%%\TempSticky.exe"
echo ^)
echo.
echo echo Thank you for installing TempSticky!
echo timeout /t 3 > nul
) > "dist\installer-temp\INSTALL.bat"

REM Create the self-extracting archive using PowerShell
echo [5/5] Creating self-extracting installer...
powershell -Command ^
"$source = 'dist\installer-temp\*'; " ^
"$destination = 'dist\TempSticky-Setup-1.0.0.exe'; " ^
"Add-Type -AssemblyName System.IO.Compression.FileSystem; " ^
"$zip = 'dist\temp.zip'; " ^
"if (Test-Path $zip) { Remove-Item $zip }; " ^
"[System.IO.Compression.ZipFile]::CreateFromDirectory((Resolve-Path 'dist\installer-temp').Path, $zip); " ^
"$zipBytes = [System.IO.File]::ReadAllBytes($zip); " ^
"$sfxStub = @' " ^
"@echo off " ^
"title TempSticky Installer " ^
"echo. " ^
"echo Extracting TempSticky... " ^
"powershell -Command \"Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory('%~f0', '%TEMP%\TempStickySetup')\" " ^
"cd /d \"%TEMP%\TempStickySetup\" " ^
"call INSTALL.bat " ^
"cd /d \"%TEMP%\" " ^
"rmdir /s /q \"%TEMP%\TempStickySetup\" " ^
"exit " ^
"'@; " ^
"[System.IO.File]::WriteAllText($destination, $sfxStub); " ^
"[System.IO.File]::AppendAllBytes($destination, $zipBytes); " ^
"Remove-Item $zip"

echo.
echo ========================================
echo   SUCCESS!
echo ========================================
echo.
echo Installer created:
echo   dist\TempSticky-Setup-1.0.0.exe
echo.
echo Users just need to:
echo   1. Download the .exe file
echo   2. Double-click it
echo   3. Done!
echo.
echo File size: 
dir "dist\TempSticky-Setup-1.0.0.exe" | find "TempSticky-Setup"
echo.
pause
