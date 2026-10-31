@echo off
REM Create TRUE One-Click .EXE Installer using IExpress (built into Windows)
REM User downloads ONE .exe file and double-clicks it - everything automatic!

title TempSticky - Creating One-Click Installer

echo.
echo ========================================
echo   Creating One-Click .EXE Installer
echo ========================================
echo.

REM Check if build exists
if not exist "dist\win-unpacked\TempSticky.exe" (
    echo ERROR: Build not found!
    echo Please run: npm run build:win
    pause
    exit /b 1
)

echo [1/5] Preparing files...

REM Create installer package directory
if exist "dist\installer-pkg" rmdir /s /q "dist\installer-pkg"
mkdir "dist\installer-pkg"

REM Copy application files
echo [2/5] Copying application files...
xcopy "dist\win-unpacked\*" "dist\installer-pkg\" /E /I /Y /Q > nul

REM Create the auto-install script
echo [3/5] Creating installation script...

(
echo @echo off
echo title TempSticky Setup
echo.
echo REM Get admin privileges
echo net session ^>nul 2^>^&1
echo if %%errorLevel%% NEQ 0 (
echo     powershell -Command "Start-Process '%~f0' -Verb RunAs"
echo     exit /b
echo ^)
echo.
echo cls
echo echo ========================================
echo echo   Installing TempSticky...
echo echo ========================================
echo echo.
echo.
echo set "INSTALL_DIR=%%ProgramFiles%%\TempSticky"
echo.
echo echo Creating installation directory...
echo if exist "%%INSTALL_DIR%%" rmdir /s /q "%%INSTALL_DIR%%"
echo mkdir "%%INSTALL_DIR%%"
echo.
echo echo Copying files...
echo xcopy "%%~dp0*" "%%INSTALL_DIR%%\" /E /I /Y /Q ^> nul
echo.
echo echo Creating desktop shortcut...
echo powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%%USERPROFILE%%\Desktop\TempSticky.lnk'^); $SC.TargetPath = '%%INSTALL_DIR%%\TempSticky.exe'; $SC.WorkingDirectory = '%%INSTALL_DIR%%'; $SC.Save(^)"
echo.
echo echo Creating Start Menu shortcut...
echo powershell -Command "$WS = New-Object -ComObject WScript.Shell; $SC = $WS.CreateShortcut('%%APPDATA%%\Microsoft\Windows\Start Menu\Programs\TempSticky.lnk'^); $SC.TargetPath = '%%INSTALL_DIR%%\TempSticky.exe'; $SC.WorkingDirectory = '%%INSTALL_DIR%%'; $SC.Save(^)"
echo.
echo echo Setting up temperature sensor...
echo cd /d "%%INSTALL_DIR%%"
echo powershell -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "resources\scripts\setup-sensor.ps1" -Silent 2^>nul
echo.
echo cls
echo echo ========================================
echo echo   Installation Complete!
echo echo ========================================
echo echo.
echo echo TempSticky has been installed to:
echo echo   %%INSTALL_DIR%%
echo echo.
echo echo Desktop shortcut created!
echo echo.
echo echo Starting TempSticky...
echo timeout /t 2 ^> nul
echo.
echo start "" "%%INSTALL_DIR%%\TempSticky.exe"
echo.
echo timeout /t 2 ^> nul
echo exit
) > "dist\installer-pkg\install.bat"

REM Create IExpress SED configuration file
echo [4/5] Creating IExpress configuration...

(
echo [Version]
echo Class=IEXPRESS
echo SEDVersion=3
echo [Options]
echo PackagePurpose=InstallApp
echo ShowInstallProgramWindow=0
echo HideExtractAnimation=1
echo UseLongFileName=1
echo InsideCompressed=0
echo CAB_FixedSize=0
echo CAB_ResvCodeSigning=0
echo RebootMode=N
echo InstallPrompt=%%InstallPrompt%%
echo DisplayLicense=%%DisplayLicense%%
echo FinishMessage=%%FinishMessage%%
echo TargetName=%%TargetName%%
echo FriendlyName=%%FriendlyName%%
echo AppLaunched=%%AppLaunched%%
echo PostInstallCmd=%%PostInstallCmd%%
echo AdminQuietInstCmd=%%AdminQuietInstCmd%%
echo UserQuietInstCmd=%%UserQuietInstCmd%%
echo SourceFiles=%%SourceFiles%%
echo [Strings]
echo InstallPrompt=
echo DisplayLicense=
echo FinishMessage=
echo TargetName=%cd%\dist\TempSticky-Installer-1.0.0.exe
echo FriendlyName=TempSticky v1.0.0 Installer
echo AppLaunched=cmd /c install.bat
echo PostInstallCmd=^<None^>
echo AdminQuietInstCmd=
echo UserQuietInstCmd=
echo FILE0="install.bat"
echo SourceFiles0=%cd%\dist\installer-pkg\
echo [SourceFiles]
echo SourceFiles0=%%SourceFiles0%%
echo [SourceFiles0]
echo %%FILE0%%=
) > "dist\installer-config.sed"

REM Add all files from installer-pkg to SED file
set filecount=1
setlocal enabledelayedexpansion
for /r "dist\installer-pkg" %%f in (*) do (
    set "filepath=%%f"
    set "filepath=!filepath:%cd%\dist\installer-pkg\=!"
    echo FILE!filecount!="!filepath!" >> "dist\installer-config.sed"
    set /a filecount+=1
)

echo [5/5] Building self-extracting installer...
echo This may take 2-5 minutes...
echo.

REM Run IExpress to create the installer
iexpress /N /Q "dist\installer-config.sed"

REM Check if successful
if exist "dist\TempSticky-Installer-1.0.0.exe" (
    echo.
    echo ========================================
    echo   SUCCESS!
    echo ========================================
    echo.
    echo One-click installer created:
    echo   dist\TempSticky-Installer-1.0.0.exe
    echo.
    for %%A in ("dist\TempSticky-Installer-1.0.0.exe") do echo File size: %%~zA bytes
    echo.
    echo USERS JUST:
    echo   1. Download this ONE .exe file
    echo   2. Double-click it
    echo   3. Done! Everything automatic!
    echo.
    echo No ZIP extraction!
    echo No manual setup!
    echo Just download and run!
    echo.
    echo Opening dist folder...
    start explorer "dist"
) else (
    echo.
    echo ERROR: Installer creation failed!
    echo.
)

echo.
pause
