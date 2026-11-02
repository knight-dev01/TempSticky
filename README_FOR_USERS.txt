TempSticky v1.0.0
CPU temperature monitor for Windows 10 and 11

========================================================================
INSTALL
========================================================================

1. Download TempSticky-Setup-1.0.0.exe.

2. Double-click the file.

3. If Windows asks for permission, choose Yes.

4. Wait a few seconds. TempSticky starts automatically.

The installer puts the app in Program Files, creates a desktop shortcut and a
Start Menu entry, and sets up the temperature sensor and its background task.
There is no ZIP file, no extraction, and no separate setup step.

If Windows SmartScreen appears, click "More info", then "Run anyway". This is
normal for a new installer that has not been downloaded very often yet.

========================================================================
USING TEMPSTICKY
========================================================================

The note shows the current CPU temperature. It stays on top of other windows
and can be dragged anywhere on screen.

Show or hide the note:
  Press Ctrl + Alt + T, or double-click the tray icon.

Compact mode:
  Click the minus button on the note to switch to a slim pill.

Settings:
  Right-click the tray icon and choose Settings.

Temperature colours:
  Cool      below 50 C        cyan
  Optimal   50 to 75 C        green
  Warm      75 to 88 C        amber
  Hot       88 C and above    red

Quit:
  Right-click the tray icon and choose Quit TempSticky.
  The X button only hides the note. It does not quit the app.

========================================================================
SYSTEM REQUIREMENTS
========================================================================

  Windows 10 (1809 or newer) or Windows 11, 64-bit
  200 MB free disk space
  50 MB RAM
  .NET Framework 4.7.2 or newer (included with Windows 10 and 11)

========================================================================
TROUBLESHOOTING
========================================================================

Temperature shows N/A:
  Some laptops do not expose CPU sensors. Try updating the chipset or
  motherboard drivers.

Tray icon is hidden:
  Click the ^ arrow in the notification area and drag the TempSticky icon
  onto the taskbar.

Sensor did not start:
  Right-click the tray icon and choose the sensor install or restart option.

========================================================================
UNINSTALL
========================================================================

1. Right-click the tray icon and choose Quit TempSticky.
2. Open Settings, then Apps, then Installed apps.
3. Find TempSticky and choose Uninstall.

The uninstaller also removes the temperature sensor task.

========================================================================
LINKS
========================================================================

Website:  https://knight-dev01.github.io/TempSticky/
Source:   https://github.com/knight-dev01/TempSticky
Issues:   https://github.com/knight-dev01/TempSticky/issues

License: MIT (free and open source)
