@echo off
REM TempSticky - Quick Launcher
REM Double-click this to run TempSticky!

title TempSticky

REM Check if TempSticky.exe exists
if not exist "TempSticky.exe" (
    echo ERROR: TempSticky.exe not found!
    echo.
    echo Make sure you're running this from the TempSticky folder.
    echo.
    pause
    exit /b 1
)

REM Start TempSticky
start "" "TempSticky.exe"

exit
