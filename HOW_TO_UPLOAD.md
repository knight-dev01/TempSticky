# 📤 How to Upload Your Files to GitHub

## 🎯 Quick Summary

You have **2 files** to upload:

1. **ZIP file** (106 MB) → Upload to GitHub Releases
2. **GitHub Pages** → Already committed (will auto-deploy)

---

## 📦 Step 1: Upload ZIP to GitHub Releases

### Your ZIP file location:
```
C:\Users\DELL\Documents\Default Project\TempSticky\dist\TempSticky-1.0.0-win.zip
```

### Upload Steps:

1. **Open this link in your browser:**
   ```
   https://github.com/knight-dev01/TempSticky/releases/new
   ```

2. **Fill in the form:**
   - **Choose a tag:** Type `v1.0.0` and select "Create new tag: v1.0.0"
   - **Release title:** `TempSticky v1.0.0 - Portable Edition`
   - **Description:** Copy from below

3. **Attach the ZIP file:**
   - Scroll down to "Attach binaries by dropping them here or selecting them"
   - Click "choose them"
   - Navigate to: `C:\Users\DELL\Documents\Default Project\TempSticky\dist\`
   - Select `TempSticky-1.0.0-win.zip`
   - Wait for upload (106 MB, ~1-2 minutes)

4. **Publish:**
   - Check ✓ "Set as the latest release"
   - Click **"Publish release"**

5. **Done!** Your download link will be:
   ```
   https://github.com/knight-dev01/TempSticky/releases/download/v1.0.0/TempSticky-1.0.0-win.zip
   ```

---

## 📝 Release Description (Copy This)

```markdown
# 🌡️ TempSticky v1.0.0 - Portable Edition

Monitor your CPU temperature with ease! No installation required.

## 📥 Download

**Windows 10/11 Portable Edition** (106 MB)

### What's New
- ✨ Initial release
- 🌡️ Real-time CPU/GPU temperature monitoring
- 🎨 Color-coded temperature states
- 📌 Sticky note overlay
- 🔔 System tray integration
- ⌨️ Keyboard shortcuts (Ctrl+Alt+T)
- 💨 Lightweight (50MB RAM, ~1% CPU)

## 🚀 Quick Start

### 1. Download & Extract
Download the ZIP file above and extract it to any folder

### 2. First-Time Setup (One-time)
- Navigate to the extracted folder
- Right-click `resources\scripts\setup-sensor.ps1`
- Choose **"Run with PowerShell"**
- Click **"Yes"** when prompted
- Wait for setup to complete (~30 seconds)

### 3. Run TempSticky
- Double-click `TempSticky.exe`
- The temperature monitor appears!
- Look for the 🌡️ icon in your system tray

## 💡 Features

- ✅ Real-time temperature monitoring (updates every 2 seconds)
- ✅ Color-coded states (Cool/Optimal/Warm/Hot)
- ✅ Always-on-top sticky note
- ✅ System tray integration with live temperature
- ✅ Compact pill mode
- ✅ Keyboard shortcuts (Ctrl+Alt+T)
- ✅ Auto-start option
- ✅ Customizable temperature thresholds
- ✅ GPU temperature support
- ✅ Minimal resource usage
- ✅ Portable - no installation needed

## 🌡️ Temperature States

| State | Temperature | Color |
|-------|-------------|-------|
| Cool | Below 50°C | 🔵 Blue |
| Optimal | 50-75°C | 🟢 Green |
| Warm | 75-88°C | 🟡 Yellow |
| Hot | 88°C+ | 🔴 Red |

## 💻 System Requirements

- **OS:** Windows 10 (build 1809+) or Windows 11
- **Disk:** 200 MB free space
- **RAM:** 50 MB
- **.NET:** Framework 4.7.2+ (pre-installed on Windows 10/11)

## 🎮 How to Use

**Show/Hide:** Press `Ctrl + Alt + T` or double-click tray icon  
**Compact Mode:** Click the `—` button  
**Settings:** Right-click tray icon  
**Quit:** Right-click tray icon → "Quit TempSticky"

## 🔧 Troubleshooting

**"Temperature sensor not installed"**
- Run `setup-sensor.ps1` again (see step 2 above)

**Can't see tray icon**
- Click the `^` arrow in system tray
- Drag TempSticky icon to main area

**Temperature shows N/A**
- Update your chipset drivers
- Some hardware doesn't expose sensors

**Windows SmartScreen warning**
- This is normal for new apps
- Click "More info" → "Run anyway"

## 🗑️ Uninstall

1. Right-click tray icon → Quit
2. Run `resources\scripts\uninstall.ps1`
3. Delete the TempSticky folder

## 🌐 Website

Visit our website: https://knight-dev01.github.io/TempSticky/

## 📖 Documentation

Full documentation: https://github.com/knight-dev01/TempSticky/blob/main/README.md

## 🐛 Found a Bug?

Report issues: https://github.com/knight-dev01/TempSticky/issues

## ⭐ Show Your Support

If you find TempSticky useful:
- ⭐ Star this repository
- 📢 Share with friends
- 🐛 Report bugs or suggest features

---

**License:** MIT (Free & Open Source)  
**Author:** knight-dev01  
**Version:** 1.0.0
```

---

## 🌐 Step 2: Enable GitHub Pages

### The website is already created! Now enable it:

1. **Go to your repository settings:**
   ```
   https://github.com/knight-dev01/TempSticky/settings/pages
   ```

2. **Under "Source":**
   - Select branch: **main**
   - Select folder: **/docs**
   - Click **Save**

3. **Wait 1-2 minutes** for deployment

4. **Your website will be live at:**
   ```
   https://knight-dev01.github.io/TempSticky/
   ```

---

## ✅ What Happens After Upload

### After uploading ZIP to Releases:

✅ Download button on website will work  
✅ Users can download from: GitHub Releases page  
✅ Direct download link available  
✅ Download statistics visible  

### After enabling GitHub Pages:

✅ Beautiful website at `https://knight-dev01.github.io/TempSticky/`  
✅ Auto-updates when you push changes  
✅ Free hosting forever  
✅ Fast CDN delivery  

---

## 🎯 Complete Workflow

### What You Already Did:
- ✅ Built the ZIP file (106 MB)
- ✅ Created GitHub Pages website
- ✅ Committed and pushed to GitHub

### What You Need to Do:
1. ⏳ Upload ZIP to GitHub Releases (5 minutes)
2. ⏳ Enable GitHub Pages in settings (1 minute)
3. ✅ Done! Share the links!

---

## 📋 Your Links After Setup

### Download Links:
```
Direct Download:
https://github.com/knight-dev01/TempSticky/releases/download/v1.0.0/TempSticky-1.0.0-win.zip

Releases Page:
https://github.com/knight-dev01/TempSticky/releases

Website:
https://knight-dev01.github.io/TempSticky/
```

---

## 🎉 Share These Links!

### For Social Media:
```
🌡️ TempSticky - Free CPU Temperature Monitor for Windows!

Download: https://knight-dev01.github.io/TempSticky/

✨ Real-time monitoring
🎨 Color-coded states
📌 Portable - no install needed
💨 Super lightweight

#Windows #FreeTools #OpenSource
```

### For Forums/Discord:
```
[TempSticky] CPU Temperature Monitor - Portable Edition

Website: https://knight-dev01.github.io/TempSticky/
Download: https://github.com/knight-dev01/TempSticky/releases/latest

Features:
- Real-time CPU temperature monitoring
- Color-coded temperature states
- System tray integration
- Portable (no installation)
- Free & Open Source

Works on Windows 10/11. Just extract and run!
```

---

## 🔍 Quick File Finder

Your files are located at:

### ZIP File (for upload):
```
C:\Users\DELL\Documents\Default Project\TempSticky\dist\TempSticky-1.0.0-win.zip
```

### To open in Explorer:
```powershell
explorer "C:\Users\DELL\Documents\Default Project\TempSticky\dist"
```

Or just navigate to your project folder → `dist` subfolder

---

## ❓ FAQ

**Q: Can users download from the website?**  
A: Yes! The website has a download button that links to GitHub Releases.

**Q: Do I need to upload the EXE separately?**  
A: No! The EXE is inside the ZIP file. Users extract it.

**Q: How do I update the download link on the website?**  
A: It's already set! When you create the v1.0.0 release, the link works automatically.

**Q: Is GitHub Pages free?**  
A: Yes! Completely free for public repositories.

**Q: Can I customize the website later?**  
A: Yes! Edit `docs/index.html` and push to GitHub. It auto-updates.

---

## 🎊 You're Almost Done!

Just two more steps:
1. Upload the ZIP to Releases (follow Step 1 above)
2. Enable GitHub Pages (follow Step 2 above)

Then share your links and enjoy! 🚀
