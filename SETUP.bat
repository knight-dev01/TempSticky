@echo off
REM TempSticky - Easy Setup Launcher
REM Just double-click this file to set up TempSticky!

title TempSticky Setup

echo.
echo ========================================
echo    TempSticky - First Time Setup
echo ========================================
echo.
echo This will set up the temperature sensor.
echo.
echo Click YES when Windows asks for permission.
echo.
echo Press any key to continue...
pause > nul

REM Run the setup wizard with admin privileges
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process powershell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""resources\scripts\first-run-wizard.ps1""' -Verb RunAs"

echo.
echo Setup wizard launched!
echo Follow the on-screen instructions.
echo.
pause
