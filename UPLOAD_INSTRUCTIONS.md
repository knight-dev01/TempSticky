# 📤 Upload Instructions for GitHub Releases

## 🎯 What to Upload

**File:** `TempSticky-Setup-1.0.0.zip`  
**Location:** `C:\Users\DELL\Documents\Default Project\TempSticky\dist\TempSticky-Setup-1.0.0.zip`  
**Size:** 110 MB

---

## 🚀 How to Upload (5 minutes)

### Step 1: Open Releases Page

Click this link:
```
https://github.com/knight-dev01/TempSticky/releases/new
```

### Step 2: Fill in Release Information

**Tag version:**
```
v1.0.0
```
*(Type this and select "Create new tag: v1.0.0 on publish")*

**Release title:**
```
TempSticky v1.0.0 - One-Click Installer
```

**Description:** *(Copy everything below)*

```markdown
# 🌡️ TempSticky v1.0.0 - Auto-Installing Edition

Monitor your CPU temperature beautifully! Installation takes just 3 clicks.

## 📥 Download & Install

### One Simple Download - Everything Included!

**No technical knowledge needed - the installer does everything automatically!**

## 🚀 Installation - Just 3 Steps!

### Step 1: Download
Click "TempSticky-Setup-1.0.0.zip" below (110 MB)

### Step 2: Extract  
Right-click the ZIP → "Extract All" → Choose any location

### Step 3: Run Installer
Open the extracted folder → Double-click **"Install TempSticky.bat"**

**That's it!** The installer automatically:
- ✅ Asks for administrator permission (click "Yes")
- ✅ Installs TempSticky to Program Files
- ✅ Sets up the temperature sensor
- ✅ Creates desktop shortcut
- ✅ Creates Start Menu shortcut  
- ✅ Starts TempSticky

**Total time: ~1 minute**

No manual configuration needed - everything is automatic!

---

## ✨ What You Get

- 🌡️ **Real-time Temperature Monitoring** - Updates every 2 seconds
- 🎨 **Color-Coded States** - Instantly see if your PC is cool, optimal, warm, or hot
- 📌 **Always-On-Top Display** - Floating note that stays visible
- 🔔 **System Tray Integration** - Live temperature icon
- ⌨️ **Keyboard Shortcuts** - Ctrl+Alt+T to show/hide
- 💨 **Super Lightweight** - Uses only 50MB RAM and ~1% CPU
- 🔧 **Fully Customizable** - Adjust temperature thresholds and colors
- 🚀 **Auto-Start Option** - Optional boot with Windows

---

## 🌡️ Temperature States

| State | Temperature Range | Color | Icon |
|-------|------------------|-------|------|
| **Cool** | Below 50°C | Blue | 🔵 |
| **Optimal** | 50°C - 75°C | Green | 🟢 |
| **Warm** | 75°C - 88°C | Yellow | 🟡 |
| **Hot** | 88°C and above | Red (pulsing) | 🔴 |

---

## 💻 System Requirements

- **Operating System:** Windows 10 (build 1809+) or Windows 11
- **Disk Space:** 200 MB
- **Memory:** 50 MB RAM
- **.NET Framework:** 4.7.2+ (pre-installed on Windows 10/11)

---

## 🎮 How to Use

### After Installation

TempSticky starts automatically! Look for the 🌡️ icon in your system tray.

### Controls

**Show/Hide Note:**
- Press `Ctrl + Alt + T`
- Or double-click the tray icon

**Compact Mode:**
- Click the `—` minimize button on the note
- Shrinks to a slim pill showing just the temperature

**Settings:**
- Right-click the tray icon
- Click "Settings" to customize

**Auto-Start:**
- Right-click tray icon
- Toggle "Run at login"

**Quit:**
- Right-click tray icon
- Click "Quit TempSticky"
- *(Note: Clicking X just hides it to the tray!)*

---

## 🌐 Website

Beautiful landing page with full details:  
**https://knight-dev01.github.io/TempSticky/**

---

## 📖 Full Documentation

Complete guide, troubleshooting, and advanced features:  
**https://github.com/knight-dev01/TempSticky/blob/main/README.md**

---

## 🔧 Troubleshooting

### Can't See the Tray Icon?
- Click the `^` (Show hidden icons) arrow in your system tray
- Drag the TempSticky icon to the main tray area
- It will stay there permanently

### Temperature Shows "N/A"?
- Some laptops don't expose temperature sensors
- Try updating your chipset/motherboard drivers
- Check if sensors work: Run `resources\scripts\probe-sensors.ps1` from install folder

### Windows SmartScreen Warning?
- Click "More info"
- Click "Run anyway"  
- This is normal for new software that hasn't been widely downloaded yet

### Sensor Not Working?
- The installer should set it up automatically
- If issues persist, right-click tray icon → "Reinstall Sensor"

---

## 🗑️ Uninstall

### Option 1: Windows Settings
1. Right-click tray icon → Quit
2. Open Settings → Apps → Apps & features
3. Find "TempSticky" → Uninstall

### Option 2: Start Menu
1. Right-click tray icon → Quit
2. Start Menu → TempSticky folder → "Uninstall TempSticky"

### Complete Removal
To remove all data:
1. Uninstall (above)
2. Delete folder: `C:\Users\[YourName]\AppData\Local\TempSticky`
3. Delete folder: `C:\Users\[YourName]\AppData\Roaming\temp-sticky`

---

## 🐛 Found a Bug? Have a Suggestion?

Report issues or request features:  
**https://github.com/knight-dev01/TempSticky/issues**

---

## ⭐ Support This Project

If you find TempSticky useful:
- ⭐ **Star this repository** - Helps others discover it
- 📢 **Share with friends** - Spread the word
- 🐛 **Report bugs** - Help improve it
- 💡 **Suggest features** - Share your ideas

---

## 📜 License

**MIT License** - Free and Open Source

You're free to:
- ✅ Use commercially
- ✅ Modify
- ✅ Distribute
- ✅ Use privately

---

## 🙏 Credits

**Author:** knight-dev01  
**Version:** 1.0.0  
**Released:** November 1, 2026

Built with ❤️ using:
- Electron
- LibreHardwareMonitor
- PawnIO Driver

---

**Enjoy monitoring your temperature!** 🌡️✨
```

### Step 3: Upload the ZIP File

1. Scroll down to **"Attach binaries by dropping them here or selecting them"**
2. Click **"choose them"** or drag and drop
3. Navigate to:
   ```
   C:\Users\DELL\Documents\Default Project\TempSticky\dist\
   ```
4. Select **TempSticky-Setup-1.0.0.zip**
5. Wait for upload (~1-2 minutes for 110 MB)

### Step 4: Publish

1. Check ✅ **"Set as the latest release"**
2. Click **"Publish release"**

---

## ✅ After Publishing

### Your Download Link Will Be:
```
https://github.com/knight-dev01/TempSticky/releases/download/v1.0.0/TempSticky-Setup-1.0.0.zip
```

### Enable GitHub Pages

1. Go to: https://github.com/knight-dev01/TempSticky/settings/pages
2. Under "Source":
   - Branch: **main**
   - Folder: **/docs**
3. Click **Save**
4. Wait 1-2 minutes
5. Your website will be live at:
   ```
   https://knight-dev01.github.io/TempSticky/
   ```

---

## 📢 Share Your Release!

### For Reddit, Forums, Discord:

```
🌡️ TempSticky v1.0.0 - Free CPU Temperature Monitor

Auto-installing edition for Windows 10/11!

📥 Download:
https://github.com/knight-dev01/TempSticky/releases/latest

🌐 Website:
https://knight-dev01.github.io/TempSticky/

Installation is super easy:
1. Download ZIP
2. Extract
3. Run "Install TempSticky.bat"
4. Done!

Features:
✨ Real-time CPU temperature
🎨 Color-coded states (Cool/Optimal/Warm/Hot)
📌 Always-on-top sticky note
⌨️ Keyboard shortcuts (Ctrl+Alt+T)
💨 Lightweight (~50MB RAM, 1% CPU)
🔧 Fully customizable

100% Free & Open Source (MIT License)
```

### For Twitter/X:

```
🌡️ Just released TempSticky v1.0.0!

Free CPU temperature monitor for Windows 10/11
✨ Auto-installer included
🎨 Color-coded states
📌 Always-on-top display
💨 Super lightweight

Download: https://knight-dev01.github.io/TempSticky/

#Windows #FreeTools #OpenSource
```

---

## 🎉 You're Done!

Once you upload and enable GitHub Pages, you'll have:

✅ Professional installer ready for download  
✅ Beautiful website for users  
✅ Complete documentation  
✅ Easy sharing links  
✅ Download statistics on GitHub  

**Your app is ready for the world!** 🚀
