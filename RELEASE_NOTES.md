# TempSticky v1.0.0

A persistent desktop temperature overlay for Windows 10 and 11.

## Download

Download `TempSticky-Setup-1.0.0.exe` (78 MB) from the release assets.

## Install

1. Download the installer.
2. Double-click `TempSticky-Setup-1.0.0.exe`.
3. Choose **Yes** when Windows asks for permission.
4. Wait a few seconds. TempSticky starts automatically.

The installer places the app in Program Files, creates desktop and Start Menu
shortcuts, and sets up the temperature sensor and its background task. There is
no ZIP file, no extraction, and no separate setup step.

### If Windows shows a warning

TempSticky is new, so Windows SmartScreen may say the file "isn't commonly
downloaded" or show "Windows protected your PC." This is a reputation warning,
not a virus detection.

1. If Edge shows the download in its menu, choose **Keep**.
2. In the SmartScreen dialog, click **More info**, then **Run anyway**.

To confirm the download is intact, compare the SHA-256 hash:

```
382D0863A4A8BD7DB7F575097993C854B2FE48BA5805CABCB970B2E80DD3D098
```

The same value is in [SHA256SUMS.txt](https://github.com/knight-dev01/TempSticky/releases/download/v1.0.0/SHA256SUMS.txt).
In PowerShell, run:

```powershell
Get-FileHash .\TempSticky-Setup-1.0.0.exe -Algorithm SHA256
```

The warning fades as the installer builds download reputation. The permanent fix
is code signing or Microsoft Store distribution.

## Features

- Real-time CPU temperature, updated every 2 seconds
- Color-coded states: cool, optimal, warm, and hot
- Always-on-top sticky note that can be dragged anywhere
- Compact pill mode and a live temperature tray badge
- Keyboard shortcut: Ctrl + Alt + T to show or hide the note
- Optional run at Windows login
- Lightweight: about 50 MB RAM and roughly 1% CPU
- Adjustable temperature thresholds and colors

## Temperature states

| State | Default range | Color |
| --- | --- | --- |
| Cool | below 50 C | cyan |
| Optimal | 50 to 75 C | green |
| Warm | 75 to 88 C | amber |
| Hot | 88 C and above | red |

## System requirements

- Windows 10 (1809 or newer) or Windows 11, 64-bit
- 200 MB disk space
- 50 MB RAM
- .NET Framework 4.7.2 or newer (included with Windows 10 and 11)

## How to use

- Drag the note to reposition it.
- Press Ctrl + Alt + T or double-click the tray icon to show or hide it.
- Click the minus button to switch to compact pill mode.
- Right-click the tray icon for settings, auto-start, sensor restart, and quit.
- The X button hides the note to the tray. Use Quit TempSticky to exit.

## Uninstall

1. Right-click the tray icon and choose Quit TempSticky.
2. Open Settings, then Apps, then Installed apps.
3. Find TempSticky and choose Uninstall.

The uninstaller also removes the temperature sensor task.

## Known issues

- GPU temperature is not available on all hardware. For example, Intel UHD 620
  does not expose a GPU temperature.
- Some laptops do not expose CPU temperature sensors. Updating the chipset or
  motherboard drivers may help.

## Links

- Website: https://knight-dev01.github.io/TempSticky/
- Source: https://github.com/knight-dev01/TempSticky
- Issues: https://github.com/knight-dev01/TempSticky/issues

## License

MIT License. Free and open source.
