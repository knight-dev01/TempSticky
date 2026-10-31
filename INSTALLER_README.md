# 📥 TempSticky - Download & Install

## For Non-Technical Users

TempSticky is now available as a **one-click installer**! No coding required.

## 🎯 Quick Start (3 Steps)

### 1️⃣ Download the Installer

Choose one of these download links:

**Primary (Recommended):**
- 🔗 [GitHub Releases](https://github.com/knight-dev01/TempSticky/releases/latest) - Fast, unlimited downloads

**Alternatives:**
- 🔗 [SourceForge](https://sourceforge.net/projects/tempsticky/) - Large file support
- 🔗 [Google Drive](LINK_HERE) - Familiar interface

**File:** `TempSticky-Setup-1.0.0.exe` (~100 MB)

### 2️⃣ Run the Installer

1. **Double-click** the downloaded file
2. Click **"Yes"** when Windows asks "Do you want to allow this app to make changes?"
3. Follow the **setup wizard**:
   - Choose install location (or use default)
   - Choose if you want auto-start
   - Wait for installation (~30 seconds)

### 3️⃣ You're Done! 🎉

TempSticky will:
- ✅ Start automatically
- ✅ Show your CPU temperature
- ✅ Appear in your system tray

## 🖥️ What You'll See

After installation:

```
Your Desktop:
  📁 TempSticky shortcut

Your System Tray:
  🌡️ Temperature icon (shows current temp)

Floating Note:
  ╔════════════════════════╗
  ║  🌡️ SYSTEM TEMP        ║
  ║                        ║
  ║       62 °C            ║
  ║     [OPTIMAL]          ║
  ╚════════════════════════╝
```

## 🎮 How to Use

### Basic Controls

- **Drag** the note to move it
- **Click X** to hide (stays in tray)
- **Double-click tray icon** to show/hide
- **Right-click tray icon** for menu
- **Ctrl + Alt + T** keyboard shortcut

### Temperature Colors

| Color | Temperature | Meaning |
|-------|-------------|---------|
| 🔵 Blue | Below 50°C | Cool |
| 🟢 Green | 50-75°C | Optimal |
| 🟡 Yellow | 75-88°C | Warm |
| 🔴 Red | 88°C+ | Hot |

### Common Tasks

**Change settings:**
1. Right-click tray icon
2. Click "Settings"
3. Adjust temperature thresholds, colors, etc.

**Toggle auto-start:**
1. Right-click tray icon
2. Check/uncheck "Run at login"

**Compact mode:**
- Click the **—** button on the note
- Changes to slim pill (168 × 66 pixels)

**Quit the app:**
1. Right-click tray icon
2. Click "Quit TempSticky"

## ⚙️ System Requirements

### Minimum

- **OS:** Windows 10 (build 1809+) or Windows 11
- **Disk:** 200 MB free space
- **RAM:** 50 MB (minimal!)
- **.NET:** Framework 4.7.2+ (installer will prompt if needed)

### Recommended

- Windows 10/11 up-to-date
- Modern CPU (Intel/AMD with temperature sensors)

## ❓ Troubleshooting

### "Windows protected your PC" message

This is normal for new software. Click **"More info"** → **"Run anyway"**

Why? The app isn't widely downloaded yet, so Windows doesn't recognize it.

### "Temperature sensor not installed"

The installer should handle this automatically. If you see this:

1. Right-click tray icon
2. Click "Reinstall Sensor"
3. Click "Yes" on UAC prompt

### Can't see the tray icon

1. Click the **^** arrow in system tray (shows hidden icons)
2. Drag TempSticky icon to main tray area
3. It will stay there permanently

### Temperature shows "N/A"

Some laptops/PCs don't expose temperature sensors. Try:
1. Update your motherboard/chipset drivers
2. Check if BIOS/UEFI has sensor support enabled

### App won't start

1. Check Task Manager (Ctrl + Shift + Esc)
2. Look for "TempSticky" process
3. If found, it's already running! Check system tray.

## 🗑️ Uninstall

### Standard Method

1. Open **Settings** → **Apps**
2. Search "TempSticky"
3. Click **Uninstall**

### Complete Removal

To remove all data:

1. Uninstall via Settings (above)
2. Delete these folders:
   - `C:\Users\[YourName]\AppData\Local\TempSticky`
   - `C:\Users\[YourName]\AppData\Roaming\temp-sticky`

## 🔒 Is It Safe?

**Yes!** TempSticky is:
- ✅ **Open source** - [View the code](https://github.com/knight-dev01/TempSticky)
- ✅ **No ads** - Completely free
- ✅ **No tracking** - No data collection
- ✅ **No network** - Works offline
- ✅ **Minimal permissions** - Only reads temperature

The installer requires admin access **once** to install the temperature sensor driver. After that, the app runs as a normal user.

## 💡 Tips & Tricks

### Keyboard Shortcuts

- `Ctrl + Alt + T` - Show/hide note
- `Win + T` - Focus system tray (then arrow keys to TempSticky)

### Positioning

The note **stays where you put it**. Position it once, and it remembers!

### Multiple Monitors

Works great with multiple monitors. The note stays on whichever screen you place it.

### Performance

TempSticky uses:
- **~0.5-1% CPU** (mostly idle)
- **~50-70 MB RAM** (very light)
- **No disk writes** (except saving settings)

### Auto-Start

Enable/disable from tray menu. Uses Windows Task Scheduler (not registry startup folder).

## 📖 More Information

- **GitHub:** https://github.com/knight-dev01/TempSticky
- **Report Issues:** https://github.com/knight-dev01/TempSticky/issues
- **Full Documentation:** See README.md in the repository

## 🎉 You're All Set!

Enjoy monitoring your system temperature with TempSticky!

If you find it useful, consider:
- ⭐ Starring the GitHub repository
- 📢 Sharing with friends
- 🐛 Reporting bugs or suggesting features

---

**Version:** 1.0.0  
**License:** MIT (Free & Open Source)  
**Author:** knight-dev01
