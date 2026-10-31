@echo off
REM TempSticky Installer Builder
REM Double-click this file to create the Windows installer

echo.
echo ========================================
echo   TempSticky Installer Builder
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
echo [2/3] Building Windows installer...
echo This may take 2-5 minutes...
call npm run build:win
if %errorlevel% neq 0 (
    echo ERROR: Build failed!
    pause
    exit /b 1
)

echo.
echo [3/3] Opening output folder...
start dist

echo.
echo ========================================
echo   SUCCESS!
echo ========================================
echo.
echo Your installer is ready:
echo   dist\TempSticky Setup 1.0.0.exe
echo.
echo You can now upload this file to:
echo   - GitHub Releases
echo   - SourceForge
echo   - Google Drive
echo   - Or any file hosting service
echo.
echo See BUILD_AND_DISTRIBUTE.md for details.
echo.
pause
