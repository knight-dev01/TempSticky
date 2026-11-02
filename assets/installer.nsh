; TempSticky NSIS hooks
;
; The installer runs elevated (perMachine), so the sensor setup script can
; register its scheduled task directly without a second UAC prompt.

!macro customInstall
  DetailPrint "Setting up the TempSticky temperature sensor..."
  nsExec::ExecToLog 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\resources\scripts\setup-sensor.ps1"'
  Pop $0
  DetailPrint "Sensor setup finished (exit code $0)."
!macroend

!macro customUnInstall
  DetailPrint "Removing the TempSticky temperature sensor..."
  nsExec::ExecToLog 'powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$INSTDIR\resources\scripts\uninstall.ps1"'
  Pop $0
!macroend
