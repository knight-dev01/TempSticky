# TempSticky

A persistent desktop temperature overlay for Windows 10/11. It shows the real CPU
package temperature as a floating note, a compact pill, and a tray badge that
changes colour as the machine moves between **cool → optimal → warm → high**.

```
┌──────────────────────────────┐
│ ● SYSTEM TEMP                 _  X │
│                              │
│            62 °C             │
│         [ OPTIMAL ]          │
│   ╭───────╮                  │
│   ╰─ sparkline ───────────╮  │
│   MIN 55°  MAX 82°  LOAD 14% │
│   ▬▬▬▬▬▬▬▬▬▬●▬▬▬▬▬▬▬▬▬▬▬▬     │
│   LibreHardwareMonitor·CPU…  │
└──────────────────────────────┘
```

## Install on Windows

Download `TempSticky-Setup-1.0.0.exe` from the
[latest release](https://github.com/knight-dev01/TempSticky/releases/latest),
double-click it, and approve the Windows permission prompt. The installer sets
up the app, the desktop and Start Menu shortcuts, and the temperature sensor
task, then starts TempSticky automatically.

Windows SmartScreen may warn that the file "isn't commonly downloaded." Choose
**More info**, then **Run anyway**. This is a reputation warning for a new
unsigned installer, not a virus detection. Compare your download against
[SHA256SUMS.txt](https://github.com/knight-dev01/TempSticky/releases/download/v1.0.0/SHA256SUMS.txt)
if you want to confirm it is intact.

The rest of this document describes how to run and develop TempSticky from
source.

## Run from source

```powershell
cd "C:\Users\DELL\Documents\Default Project\TempSticky"
npm start
```

The note is draggable, stays on top, and hides to the tray with the **X** button.
`Ctrl + Alt + T` shows/hides it, and double-clicking the tray icon does the same.
The first time you hide it, a notification reminds you where it went.

**Note seems to have disappeared?** Any of these brings it back:

1. Click the tray icon (if it is in the hidden-icons `^` overflow, drag it onto the taskbar once).
2. Press `Ctrl + Alt + T`.
3. Launch the **TempSticky** desktop shortcut again — it re-shows the running copy instead of starting a second one.
4. Tray menu → **Reset note size & position** if it ended up off-screen or as a tiny pill.

`X` hides; it does **not** quit. Use tray menu → **Quit TempSticky** to stop it.

It is already set to **run at login**; toggle that (and every other option) from
the gear menu or the tray menu.

## Modes

| Mode | How | Size |
| --- | --- | --- |
| Full note | default | 292 × 368 |
| Compact pill | **—** button | 168 × 66 |
| Tray badge | always | 16/32 px, digits + state colour |

The tray icon is a coloured badge with the current temperature, and its tooltip
shows CPU, GPU and load. The tray menu also has a live reading at the top.

## States and thresholds

| State | Default range | Colour |
| --- | --- | --- |
| Cool | below 50 °C | cyan |
| Optimal | 50 – 75 °C | green |
| Warm | 75 – 88 °C | amber |
| High | 88 °C and above | red (pulsing dot) |

Change them live in **Settings → Cool below / Optimal up to / High above**. Settings
are saved to `%APPDATA%\temp-sticky\settings.json`.

## How it works

```
TempSensor.exe (elevated, hidden)
        │  reads CPU/GPU sensors through LibreHardwareMonitor + PawnIO
        ▼
%LOCALAPPDATA%\TempSticky\sensor.json   ← written every 2 s
        ▼
Electron app (no admin) → note window + tray badge
```

* **TempSensor.exe** — small C# helper (`sensor/TempSensor.cs`) compiled with
  the .NET Framework compiler that ships with Windows.
* **LibreHardwareMonitor** library — the sensor database.
* **PawnIO** — signed kernel driver LHM uses to read the CPU. It is compatible
  with Memory Integrity (HVCI), unlike the old WinRing0 driver, so nothing has
  to be weakened to get real temperatures.
* The helper is started at login by the hidden scheduled task
  **TempSticky Sensor** (highest privileges, no UAC prompt). That is why the
  overlay itself can run as a normal, unprivileged app.

If the sensor stops, the app automatically restarts the task; the red bar at the
bottom of the note offers **Restart** / **Install** as well.

## Python helper

```powershell
python tools\temp.py            # one line
python tools\temp.py --watch    # live, updates every 2 s
python tools\temp.py --json     # raw feed
```

## Files

```
TempSticky/
├─ src/
│  ├─ main.js              Electron main process (window, tray, polling)
│  ├─ preload.js           context-isolated IPC bridge
│  ├─ lib/icon.js          PNG tray-icon renderer (no native deps)
│  └─ renderer/            note UI (HTML/CSS/JS)
├─ sensor/TempSensor.cs    sensor helper source
├─ scripts/
│  ├─ setup-sensor.ps1     elevated installer (LHM + PawnIO + task)
│  ├─ uninstall.ps1        removes the task
│  ├─ probe-sensors.ps1    diagnostics: what can this PC read?
│  ├─ stress-test.ps1      load test to check the sensor reacts
│  └─ ui-check.mjs         headless UI check over CDP
└─ tools/temp.py           Python reader
```

## Troubleshooting

**Note says "Temperature sensor not installed"** — run the setup once:

```powershell
powershell -ExecutionPolicy Bypass -File scripts\setup-sensor.ps1
```

Approve the UAC prompt. It installs PawnIO (if missing), compiles the helper,
registers the task and verifies a reading.

**Note says "Sensor stopped — trying to restart"** — the app retries every
20 s. You can also run `schtasks /Run /TN "TempSticky Sensor"`.

**Check what the sensor sees:**

```powershell
Get-Content "$env:LOCALAPPDATA\TempSticky\sensor.json" -Raw
```

**GPU shows nothing** — this laptop's Intel UHD 620 does not expose a GPU
temperature sensor. The GPU column hides itself when there is no reading.

**Change the port / inspect the UI** — `npx electron . --remote-debugging-port=9222`
then `node scripts/ui-check.mjs`.

## Uninstall

```powershell
# remove the background sensor task (elevated)
powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1

# remove task + downloaded LHM/sensor data
powershell -ExecutionPolicy Bypass -File scripts\uninstall.ps1 -RemoveData
```

Turn off **Run at login** in the tray menu first if you want the app to stop
starting with Windows, then delete this folder.
