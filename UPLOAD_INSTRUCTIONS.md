# Uploading a TempSticky release

This guide is for the maintainer. It covers building the one-click installer
and publishing it on GitHub.

## Build the installer

```powershell
# From the repository root
npm install
$env:CSC_IDENTITY_AUTO_DISCOVERY = "false"
npx electron-builder --win nsis --x64 --publish never
```

Output:

```
dist/TempSticky-Setup-1.0.0.exe
```

The installer is a one-click NSIS package. It installs to Program Files,
creates desktop and Start Menu shortcuts, sets up the temperature sensor, and
launches the app when it finishes.

## Publish with the GitHub website

1. Open https://github.com/knight-dev01/TempSticky/releases
2. Choose the release, or create a new tag such as `v1.0.1`.
3. Edit the release.
4. Upload `dist/TempSticky-Setup-<version>.exe` under Assets.
5. Remove any older ZIP, portable EXE, or loose DLL assets so users cannot
   download the wrong file.
6. Replace the description with the release notes below.
7. Save the release.

The download URL will be:

```
https://github.com/knight-dev01/TempSticky/releases/download/v1.0.1/TempSticky-Setup-1.0.1.exe
```

## Release notes template

```markdown
A persistent desktop temperature overlay for Windows 10 and 11.

## Download

**[TempSticky-Setup-1.0.1.exe](DOWNLOAD_URL_HERE)** (78 MB)

## Install

1. Download the installer.
2. Double-click `TempSticky-Setup-1.0.1.exe`.
3. Choose **Yes** when Windows asks for permission.
4. Wait a few seconds. TempSticky starts automatically.

The installer places the app in Program Files, creates desktop and Start Menu
shortcuts, and sets up the temperature sensor and its background task. There is
no ZIP file, no extraction, and no separate setup step.

If Windows SmartScreen appears, click **More info**, then **Run anyway**.

## Features

- Real-time CPU temperature, updated every 2 seconds
- Color-coded states: cool, optimal, warm, and hot
- Always-on-top sticky note that can be dragged anywhere
- Compact pill mode and a live temperature tray badge
- Keyboard shortcut: Ctrl + Alt + T to show or hide the note
- Optional run at Windows login
- Lightweight: about 50 MB RAM and roughly 1% CPU
- Adjustable temperature thresholds and colors

## System requirements

- Windows 10 (1809 or newer) or Windows 11, 64-bit
- 200 MB disk space
- 50 MB RAM
- .NET Framework 4.7.2 or newer

## Uninstall

1. Right-click the tray icon and choose Quit TempSticky.
2. Open Settings, then Apps, then Installed apps.
3. Find TempSticky and choose Uninstall.

## Links

- Website: https://knight-dev01.github.io/TempSticky/
- Source: https://github.com/knight-dev01/TempSticky
- Issues: https://github.com/knight-dev01/TempSticky/issues

## License

MIT License. Free and open source.
```

## Publish with the GitHub API

If the GitHub CLI is available:

```powershell
gh release upload v1.0.1 "dist/TempSticky-Setup-1.0.1.exe" --clobber
```

Without the CLI, use the website steps above. GitHub's asset upload endpoint
also works with a personal access token:

```powershell
$token = "<your token>"
$releaseId = "<numeric release id>"
Invoke-WebRequest `
  -Uri "https://uploads.github.com/repos/knight-dev01/TempSticky/releases/$releaseId/assets?name=TempSticky-Setup-1.0.1.exe" `
  -Method Post `
  -Headers @{ Authorization = "token $token" } `
  -ContentType "application/octet-stream" `
  -InFile "dist/TempSticky-Setup-1.0.1.exe"
```

## Check the download

After publishing, open the asset URL in a private browser window and confirm
that the file downloads and its size matches `dist`.

## Website

The landing page lives in `docs/index.html`. GitHub Pages serves it from the
`main` branch, `/docs` folder:

1. Open https://github.com/knight-dev01/TempSticky/settings/pages
2. Set Source to `Deploy from a branch`.
3. Choose branch `main` and folder `/docs`.
4. Save.

The page is published at https://knight-dev01.github.io/TempSticky/.

When you release a new version, update the download link in `docs/index.html`
and the version number shown on the page.
