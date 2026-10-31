@echo off
REM TempSticky Portable Build (No Installer)
REM Creates a ZIP file that users can extract and run

echo.
echo ========================================
echo   TempSticky Portable Builder
echo ========================================
echo.

REM Check if Node.js is installed
where node >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Node.js is not installed!
    echo.
    echo Please install Node.js from: https://nodejs.org/
    echo.
    pause
    exit /b 1
)

echo [1/3] Installing dependencies...
call npm install
if %errorlevel% neq 0 (
    echo ERROR: Failed to install dependencies!
    pause
    exit /b 1
)

echo.
echo [2/3] Building portable version...
call npm run dist:portable
if %errorlevel% neq 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo [3/3] Creating ZIP package...
powershell -Command "Compress-Archive -Path 'dist\win-unpacked\*' -DestinationPath 'dist\TempSticky-Portable-v1.0.0.zip' -Force"

echo.
echo ========================================
echo   SUCCESS!
echo ========================================
echo.
echo Portable version created:
echo   dist\TempSticky-Portable-v1.0.0.zip
echo.
echo Users can:
echo   1. Extract the ZIP
echo   2. Run TempSticky.exe
echo   3. No installation needed!
echo.
pause
