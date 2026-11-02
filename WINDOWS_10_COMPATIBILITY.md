# Windows 10 compatibility

TempSticky is fully compatible with both Windows 10 and Windows 11.

## System requirements

- Windows 10 (version 1809 or newer) or Windows 11, 64-bit
- .NET Framework 4.7.2 or newer (pre-installed on Windows 10 1803 and later)
- 50 MB RAM
- About 200 MB free disk space

Node.js is only required to build TempSticky from source. The installer
includes everything users need.

## Supported features

- Real-time CPU and GPU temperature monitoring
- System tray integration
- Always-on-top sticky note
- Compact pill mode
- Color-coded temperature states
- Auto-start at login
- Keyboard shortcut: Ctrl + Alt + T
- LibreHardwareMonitor integration
- PawnIO driver (compatible with Memory Integrity / HVCI)

## Windows 10 versions tested

- Windows 10 21H2 (build 19044)
- Windows 10 22H2 (build 19045)

Earlier versions should work but are not officially tested.

## Windows 10 compared with Windows 11

| Feature | Windows 10 | Windows 11 | Notes |
| --- | --- | --- | --- |
| Temperature monitoring | Yes | Yes | Identical |
| Tray icon | Yes | Yes | Works in both system trays |
| Auto-start | Yes | Yes | Uses Task Scheduler |
| Keyboard shortcuts | Yes | Yes | Same shortcuts |
| UI rendering | Yes | Yes | Electron works identically |
| Memory Integrity | Yes | Yes | PawnIO driver compatible |

## Installation

The process is identical on Windows 10 and Windows 11:

1. Download `TempSticky-Setup-1.0.0.exe`.
2. Double-click it and choose **Yes** when Windows asks for permission.
3. Wait a few seconds. TempSticky starts automatically.

The installer sets up the app, shortcuts, temperature sensor, and the sensor
background task. No ZIP extraction and no separate setup step are needed.

## Verified components

### Electron

Electron 33.x supports Windows 10 (1809 and newer) and Windows 11. Hardware
acceleration works on both.

### .NET Framework

TempSticky targets .NET Framework 4.7.2, which ships with Windows 10 1803 and
later. Windows Update can install it if it is missing.

### LibreHardwareMonitor

Works on Windows 10 and 11, with both Intel and AMD CPUs, and supports modern
sensor chips.

### PawnIO driver

The kernel driver is signed for Windows 10 and 11, is compatible with Memory
Integrity (HVCI), and has no Secure Boot conflicts.

## Known issues

1. GPU temperature is not available on every GPU. For example, Intel UHD 620
   does not expose a GPU temperature.
2. The tray icon may start in the hidden-icons overflow. Drag it onto the
   taskbar once to keep it visible.

## Performance

| Metric | Windows 10 | Windows 11 |
| --- | --- | --- |
| CPU usage | about 0.5 to 1% | about 0.5 to 1% |
| RAM usage | about 50 to 70 MB | about 50 to 70 MB |
| Startup time | about 2 to 3 seconds | about 2 to 3 seconds |
| Sensor polling | every 2 seconds | every 2 seconds |

Performance is identical on both platforms.

## Troubleshooting

### Check the .NET Framework version

```powershell
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' |
  Get-ItemPropertyValue -Name Release
```

A value of 461808 or higher means .NET Framework 4.7.2 or newer is installed.

### Check the Windows version

```powershell
[System.Environment]::OSVersion.Version
```

The result should be 10.0.17763 or higher.

### Check the Node.js version for source builds

```powershell
node --version
```

Node.js 14 or higher is required to build from source.

## Upgrading from Windows 10 to Windows 11

TempSticky continues to work without changes. No reinstallation is needed,
settings are preserved, and the sensor task keeps running.

## Support statement

Windows 10 (1809 and newer) and Windows 11 are officially supported. Both
platforms have feature parity, and TempSticky is tested on both.

## FAQ

**Do I need to do anything different on Windows 10?**

No. Installation and usage are identical.

**Will it slow down my Windows 10 PC?**

No. Resource usage is minimal, around 1% CPU and 50 MB RAM.

**Can I use it on Windows 10 LTSC?**

Yes, as long as .NET Framework 4.7.2 or newer is available.

**Does it work with Windows 10 Home?**

Yes. Home, Pro, and Enterprise editions are supported.

**What about Windows 8.1 or Windows 7?**

They are not officially supported. Windows 10 (1809 and newer) is the minimum.
