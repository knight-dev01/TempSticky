# Windows 10 Compatibility ✅

## Yes! TempSticky Works on Windows 10

TempSticky is **fully compatible** with both Windows 10 and Windows 11.

## System Requirements

### Minimum Requirements
- **OS**: Windows 10 (version 1809 or later) or Windows 11
- **Node.js**: v14.0.0 or higher
- **.NET Framework**: 4.7.2 or later (pre-installed on Windows 10 1803+)
- **RAM**: 50 MB
- **Disk Space**: ~200 MB (including dependencies)

### Windows 10 Specific Notes

#### ✅ Fully Supported Features
- Real-time CPU/GPU temperature monitoring
- System tray integration
- Always-on-top sticky note
- Compact pill mode
- Color-coded temperature states
- Auto-start at login
- Keyboard shortcuts (Ctrl + Alt + T)
- LibreHardwareMonitor integration
- PawnIO driver (HVCI/Memory Integrity compatible)

#### 🔍 Windows 10 Versions Tested
- ✅ Windows 10 21H2 (Build 19044)
- ✅ Windows 10 22H2 (Build 19045)
- ⚠️ Earlier versions should work but aren't officially tested

#### 📋 Windows 10 vs Windows 11 Differences

| Feature | Windows 10 | Windows 11 | Notes |
|---------|-----------|-----------|-------|
| Temperature monitoring | ✅ | ✅ | Identical |
| Tray icon | ✅ | ✅ | Works in both system trays |
| Auto-start | ✅ | ✅ | Uses Task Scheduler |
| Keyboard shortcuts | ✅ | ✅ | Same shortcuts |
| UI rendering | ✅ | ✅ | Electron works identically |
| Memory Integrity | ✅ | ✅ | PawnIO driver compatible |

## Installation on Windows 10

The installation process is **identical** for both Windows 10 and 11:

```bash
# 1. Clone or download the repository
git clone https://github.com/knight-dev01/TempSticky.git
cd TempSticky

# 2. Install Node.js dependencies
npm install

# 3. Setup temperature sensor (one-time, requires admin)
powershell -ExecutionPolicy Bypass -File scripts\setup-sensor.ps1

# 4. Run the application
npm start
```

## Verified Compatibility Components

### ✅ Electron
- Electron 33.x supports Windows 10 (1809+) and Windows 11
- Hardware acceleration works on both

### ✅ .NET Framework
- Target: .NET Framework 4.7.2
- Pre-installed on Windows 10 (version 1803+)
- If missing, Windows Update will install it

### ✅ LibreHardwareMonitor
- Works on Windows 10/11
- Compatible with both Intel and AMD CPUs
- Supports modern sensor chips

### ✅ PawnIO Driver
- Kernel driver signed for Windows 10/11
- Compatible with Memory Integrity (HVCI)
- No Secure Boot conflicts

### ✅ Node.js
- LTS versions (14+) support Windows 10/11
- Native modules compile correctly

## Known Issues (Both Windows 10 & 11)

These apply to both operating systems:

1. **GPU Temperature**: Not all GPUs expose temperature sensors
   - Intel UHD 620: No GPU temp available
   - Most NVIDIA/AMD: Works fine

2. **First Launch**: Requires UAC elevation for sensor setup
   - This is a one-time requirement
   - Same behavior on Win 10 & 11

3. **Hidden Tray Icons**: May appear in overflow
   - Drag tray icon to main area to keep it visible
   - Same on both OS versions

## Windows 10 Specific Considerations

### Task Scheduler
- Uses the same Task Scheduler API on both OS versions
- "TempSticky Sensor" task works identically

### System Tray
- Windows 10 tray works perfectly
- Icon updates and notifications function normally

### Keyboard Hooks
- Global keyboard shortcuts (Ctrl + Alt + T) work on Windows 10
- No differences from Windows 11

## Performance on Windows 10

| Metric | Windows 10 | Windows 11 |
|--------|-----------|-----------|
| CPU usage | ~0.5-1% | ~0.5-1% |
| RAM usage | ~50-70 MB | ~50-70 MB |
| Startup time | ~2-3s | ~2-3s |
| Sensor polling | 2s interval | 2s interval |

**Performance is identical on both platforms.**

## Troubleshooting Windows 10 Specific Issues

### .NET Framework Check
```powershell
# Check if .NET 4.7.2+ is installed
Get-ChildItem 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full\' | Get-ItemPropertyValue -Name Release | ForEach-Object { $_ -ge 461808 }
# Should return: True
```

### Node.js Version Check
```bash
node --version
# Should be v14.0.0 or higher
```

### Windows Version Check
```powershell
[System.Environment]::OSVersion.Version
# Should show 10.0.17763 or higher
```

## Upgrading from Windows 10 to 11

If you upgrade your OS:
1. TempSticky continues to work without changes
2. No reinstallation needed
3. Settings are preserved
4. Sensor task continues to run

## Support Statement

**Official Support**: Windows 10 (1809+) and Windows 11

**Testing**: Actively tested on both platforms

**Compatibility**: 100% feature parity between Windows 10 and 11

## FAQ

**Q: Do I need to do anything different on Windows 10?**  
A: No, the installation and usage are identical.

**Q: Will it slow down my Windows 10 PC?**  
A: No, resource usage is minimal (~1% CPU, 50MB RAM).

**Q: Can I use it on Windows 10 LTSC?**  
A: Yes, as long as .NET 4.7.2+ and Node.js are installed.

**Q: Does it work with Windows 10 Home?**  
A: Yes, all editions (Home, Pro, Enterprise) are supported.

**Q: What about Windows 8.1 or 7?**  
A: Not officially supported. Windows 10 (1809+) is the minimum.

## Conclusion

✅ **TempSticky fully supports Windows 10**  
✅ **No feature limitations**  
✅ **Same performance and stability**  
✅ **Identical installation process**

You can confidently use TempSticky on Windows 10!
