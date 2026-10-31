'use strict';

const {
  app, BrowserWindow, Tray, Menu, ipcMain, nativeImage, screen, globalShortcut, shell
} = require('electron');
const fs = require('node:fs');
const path = require('node:path');
const { execFile } = require('node:child_process');
const { renderIcon } = require('./lib/icon');

const TASK_NAME = 'TempSticky Sensor';
const SENSOR_DIR = path.join(process.env.LOCALAPPDATA || app.getPath('appData'), 'TempSticky');
const SENSOR_FILE = path.join(SENSOR_DIR, 'sensor.json');
const LOG_FILE = path.join(SENSOR_DIR, 'app.log');
const STALE_MS = 12000;
const POLL_MS = 2000;

const COLORS = {
  cool: '#38bdf8',
  optimal: '#34d399',
  warm: '#fbbf24',
  high: '#f87171',
  unknown: '#94a3b8',
  offline: '#64748b'
};

const DEFAULTS = {
  coolMax: 50,
  warmMax: 75,
  hotMin: 88,
  opacity: 0.94,
  alwaysOnTop: true,
  mini: false,
  autoStart: true,
  showGpu: true,
  hideTipShown: false,
  bounds: null
};

const WINDOW_SIZE = { width: 292, height: 368 };
const MINI_SIZE = { width: 168, height: 66 };

let win = null;
let tray = null;
let settings = { ...DEFAULTS };
let snapshot = null;
let history = [];
let pollTimer = null;
let lastRestart = 0;
let trayKey = '';
let trayMenuKey = '';
let sensorInstalled = false;
let quitting = false;

function log(...args) {
  try {
    fs.mkdirSync(SENSOR_DIR, { recursive: true });
    fs.appendFileSync(LOG_FILE, `${new Date().toISOString()} ${args.join(' ')}\n`);
  } catch { /* ignore */ }
}

/* ------------------------------------------------------------------ settings */

function settingsPath() {
  return path.join(app.getPath('userData'), 'settings.json');
}

function loadSettings() {
  try {
    const raw = JSON.parse(fs.readFileSync(settingsPath(), 'utf8'));
    settings = { ...DEFAULTS, ...raw };
  } catch {
    settings = { ...DEFAULTS };
  }
  normalizeSettings();
}

function normalizeSettings() {
  const s = settings;
  s.coolMax = clamp(num(s.coolMax, 50), 20, 80);
  s.warmMax = clamp(num(s.warmMax, 75), s.coolMax + 2, 100);
  s.hotMin = clamp(num(s.hotMin, 88), s.warmMax + 2, 110);
  s.opacity = clamp(num(s.opacity, 0.94), 0.5, 1);
  s.alwaysOnTop = s.alwaysOnTop !== false;
  s.mini = !!s.mini;
  s.autoStart = !!s.autoStart;
  s.showGpu = s.showGpu !== false;
  s.hideTipShown = !!s.hideTipShown;
}

function saveSettings() {
  try {
    fs.mkdirSync(path.dirname(settingsPath()), { recursive: true });
    fs.writeFileSync(settingsPath(), JSON.stringify(settings, null, 2));
  } catch (e) {
    log('saveSettings failed', e.message);
  }
}

function num(v, d) {
  const n = Number(v);
  return Number.isFinite(n) ? n : d;
}

function clamp(v, lo, hi) {
  return Math.min(hi, Math.max(lo, v));
}

/* -------------------------------------------------------------------- sensor */

function readSensor() {
  try {
    const data = JSON.parse(fs.readFileSync(SENSOR_FILE, 'utf8'));
    if (!data || typeof data.ts !== 'number') return null;
    data.age = Date.now() - data.ts;
    return data;
  } catch {
    return null;
  }
}

function levelFor(cpu) {
  if (cpu == null || !Number.isFinite(cpu)) return 'unknown';
  if (cpu < settings.coolMax) return 'cool';
  if (cpu < settings.warmMax) return 'optimal';
  if (cpu < settings.hotMin) return 'warm';
  return 'high';
}

function buildSnapshot() {
  const data = readSensor();
  const offline = !data || data.age > STALE_MS;
  const cpu = !offline && Number.isFinite(data.cpu) ? data.cpu : null;
  const level = offline ? 'offline' : levelFor(cpu);

  if (cpu != null) {
    const last = history[history.length - 1];
    if (!last || data.ts - last.t > 900) {
      history.push({ t: data.ts, v: cpu });
      if (history.length > 90) history.shift();
    }
  }

  const values = history.map((h) => h.v);
  const stats = values.length
    ? {
        min: Math.min(...values),
        max: Math.max(...values),
        avg: values.reduce((a, b) => a + b, 0) / values.length
      }
    : { min: null, max: null, avg: null };

  return {
    level,
    color: COLORS[level] || COLORS.unknown,
    cpu,
    gpu: !offline && Number.isFinite(data.gpu) ? data.gpu : null,
    load: !offline && Number.isFinite(data.load) ? data.load : null,
    cpuName: data && data.cpuName ? data.cpuName : null,
    source: data && data.source ? data.source : null,
    admin: !!(data && data.admin),
    error: data && data.error ? data.error : null,
    age: data ? Math.max(0, Math.round(data.age / 1000)) : null,
    ts: data ? data.ts : null,
    stats,
    history: values.slice(-60),
    thresholds: { coolMax: settings.coolMax, warmMax: settings.warmMax, hotMin: settings.hotMin },
    sensorInstalled,
    showGpu: settings.showGpu
  };
}

function maybeRestartSensor() {
  if (Date.now() - lastRestart < 20000) return;
  lastRestart = Date.now();
  execFile('schtasks.exe', ['/Run', '/TN', TASK_NAME], { windowsHide: true }, (err) => {
    if (err) log('schtasks run failed:', err.message);
  });
}

function tick() {
  snapshot = buildSnapshot();
  if (!snapshot.sensorInstalled && snapshot.level === 'offline' && fs.existsSync(SENSOR_FILE)) {
    sensorInstalled = true;
    snapshot.sensorInstalled = true;
  }
  if (snapshot.level === 'offline' && sensorInstalled) maybeRestartSensor();

  if (win && !win.isDestroyed()) win.webContents.send('app:state', snapshot);
  updateTray(snapshot);
}

/* --------------------------------------------------------------------- tray */

function iconFor(text, color, size) {
  return nativeImage.createFromBuffer(renderIcon(text, color, size));
}

function trayImage(snap) {
  const text = snap.cpu != null ? String(Math.min(99, Math.round(snap.cpu))) : '';
  const color = snap.color || COLORS.offline;
  const img = iconFor(text, color, 16);
  try {
    img.addRepresentation({
      scaleFactor: 2,
      width: 32,
      height: 32,
      buffer: renderIcon(text, color, 32)
    });
  } catch { /* older electron */ }
  return img;
}

function trayTooltip(snap) {
  if (snap.level === 'offline') return 'TempSticky — sensor offline';
  const parts = [`CPU ${Math.round(snap.cpu)}°C — ${labelFor(snap.level)}`];
  if (snap.gpu != null) parts.push(`GPU ${Math.round(snap.gpu)}°C`);
  if (snap.load != null) parts.push(`Load ${Math.round(snap.load)}%`);
  return parts.join('\n');
}

function labelFor(level) {
  return {
    cool: 'Cool', optimal: 'Optimal', warm: 'Warm', high: 'High', unknown: 'Unknown', offline: 'Offline'
  }[level] || 'Unknown';
}

function updateTray(snap) {
  if (!tray) return;
  const key = `${snap.level}:${snap.cpu == null ? '-' : Math.round(snap.cpu)}:${snap.sensorInstalled}`;
  if (key !== trayKey) {
    trayKey = key;
    try {
      tray.setImage(trayImage(snap));
    } catch (e) {
      log('tray image failed', e.message);
    }
    tray.setToolTip(trayTooltip(snap));
  }
  const menuKey = `${key}:${win && win.isVisible() ? 1 : 0}:${settings.mini ? 1 : 0}:${settings.alwaysOnTop ? 1 : 0}:${settings.autoStart ? 1 : 0}`;
  if (menuKey !== trayMenuKey) {
    trayMenuKey = menuKey;
    tray.setContextMenu(buildMenu(snap));
  }
}

function buildMenu(snap) {
  const header = snap.level === 'offline'
    ? 'Sensor offline'
    : `CPU ${Math.round(snap.cpu)}°C · ${labelFor(snap.level)}${snap.load != null ? ` · ${Math.round(snap.load)}% load` : ''}`;

  return Menu.buildFromTemplate([
    { label: header, enabled: false },
    { type: 'separator' },
    { label: win && win.isVisible() ? 'Hide note' : 'Show note', click: () => toggleWindow() },    {
      label: 'Compact mode',
      type: 'checkbox',
      checked: settings.mini,
      click: () => setMini(!settings.mini)
    },
    {
      label: 'Always on top',
      type: 'checkbox',
      checked: settings.alwaysOnTop,
      click: () => applySettings({ alwaysOnTop: !settings.alwaysOnTop })
    },
    {
      label: 'Run at login',
      type: 'checkbox',
      checked: settings.autoStart,
      click: () => applySettings({ autoStart: !settings.autoStart })
    },
    { type: 'separator' },
    { label: 'Restart sensor', click: () => { lastRestart = 0; maybeRestartSensor(); } },
    { label: 'Reset note size & position', click: () => resetNote() },
    { label: 'Sensor setup (admin)…', click: () => openSensorSetup() },
    { label: 'Open data folder', click: () => shell.openPath(SENSOR_DIR) },
    { type: 'separator' },
    { label: 'Quit TempSticky', click: () => { quitting = true; app.quit(); } }
  ]);
}

/* ------------------------------------------------------------------- window */

function defaultBounds() {
  const area = screen.getPrimaryDisplay().workArea;
  return {
    x: Math.round(area.x + area.width - (settings.mini ? MINI_SIZE.width : WINDOW_SIZE.width) - 24),
    y: Math.round(area.y + 24)
  };
}

function safeBounds() {
  const b = settings.bounds || defaultBounds();
  const size = settings.mini ? MINI_SIZE : WINDOW_SIZE;
  const displays = screen.getAllDisplays();
  const visible = displays.some((d) => {
    const a = d.workArea;
    return b.x + 60 > a.x && b.x < a.x + a.width - 60 && b.y + 30 > a.y && b.y < a.y + a.height - 30;
  });
  if (!visible) return defaultBounds();
  return { x: b.x, y: b.y, ...size };
}

function createWindow() {
  const b = safeBounds();
  win = new BrowserWindow({
    x: b.x,
    y: b.y,
    width: settings.mini ? MINI_SIZE.width : WINDOW_SIZE.width,
    height: settings.mini ? MINI_SIZE.height : WINDOW_SIZE.height,
    frame: false,
    transparent: true,
    backgroundColor: '#00000000',
    resizable: false,
    maximizable: false,
    minimizable: false,
    fullscreenable: false,
    alwaysOnTop: settings.alwaysOnTop,
    skipTaskbar: false,
    hasShadow: false,
    show: false,
    title: 'TempSticky',
    icon: path.join(__dirname, '..', 'assets', 'icon.png'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
      sandbox: false,
      backgroundThrottling: false
    }
  });

  win.setAlwaysOnTop(settings.alwaysOnTop, 'floating');
  win.loadFile(path.join(__dirname, 'renderer', 'index.html'));

  win.once('ready-to-show', () => {
    win.showInactive();
    if (snapshot) win.webContents.send('app:state', snapshot);
    win.webContents.send('app:settings', publicSettings());
  });

  let moveTimer = null;
  const remember = () => {
    clearTimeout(moveTimer);
    moveTimer = setTimeout(() => {
      if (!win || win.isDestroyed() || settings.mini) return;
      const [x, y] = win.getPosition();
      settings.bounds = { x, y };
      saveSettings();
    }, 500);
  };
  win.on('moved', remember);
  win.on('close', (e) => {
    if (!quitting) {
      e.preventDefault();
      hideNote();
    }
  });

  // Win+D and other shell actions can still minimize us; treat that as "hide to tray"
  win.on('minimize', (e) => {
    e.preventDefault();
    hideNote();
  });

  win.on('restore', () => {
    win.setAlwaysOnTop(settings.alwaysOnTop, 'floating');
    win.moveTop();
    if (win.webContents) win.webContents.invalidate();
  });

  win.on('show', () => {
    win.setAlwaysOnTop(settings.alwaysOnTop, 'floating');
    win.moveTop();
    if (win.webContents) win.webContents.invalidate();
  });
}

function showNote(focus = true) {
  if (!win || win.isDestroyed()) return;
  if (win.isMinimized()) win.restore();
  win.show();
  if (focus) win.focus();

  // Windows can shrink a frameless window while restoring from minimize.
  const target = settings.mini ? MINI_SIZE : WINDOW_SIZE;
  const b = win.getBounds();
  if (Math.abs(b.width - target.width) > 2 || Math.abs(b.height - target.height) > 2) {
    const wasResizable = win.isResizable();
    if (!wasResizable) win.setResizable(true);
    win.setSize(target.width, target.height, false);
    if (!wasResizable) win.setResizable(false);
  }

  win.setAlwaysOnTop(settings.alwaysOnTop, 'floating');
  win.moveTop();
  // Transparent windows occasionally skip a repaint after hide/show.
  if (win.webContents) win.webContents.invalidate();
  updateTray(snapshot || buildSnapshot());
}

function hideNote() {
  if (!win || win.isDestroyed()) return;
  win.hide();
  if (!settings.hideTipShown && tray) {
    settings.hideTipShown = true;
    saveSettings();
    try {
      tray.displayBalloon({
        title: 'TempSticky is still running',
        content: 'Click the tray icon (or Ctrl+Alt+T) to bring the note back.',
        iconType: 'info',
        noSound: true
      });
    } catch { /* balloons are best effort */ }
  }
  updateTray(snapshot || buildSnapshot());
}

function toggleWindow() {
  if (!win || win.isDestroyed()) return;
  if (win.isVisible() && !win.isMinimized()) win.hide();
  else showNote();
  updateTray(snapshot || buildSnapshot());
}

function resetNote() {
  settings.mini = false;
  settings.bounds = defaultBounds();
  settings.alwaysOnTop = true;
  saveSettings();
  if (win && !win.isDestroyed()) {
    setMini(false, true);
    const b = safeBounds();
    win.setPosition(b.x, b.y, false);
    win.setAlwaysOnTop(true, 'floating');
    win.webContents.send('app:settings', publicSettings());
  }
  showNote();
  tick();
}

function setMini(mini, force) {
  if (!win || win.isDestroyed()) return;
  if (!force && settings.mini === mini) return;
  settings.mini = mini;
  saveSettings();
  const size = mini ? MINI_SIZE : WINDOW_SIZE;
  const [x, y] = win.getPosition();
  const wasResizable = win.isResizable();
  if (!wasResizable) win.setResizable(true);
  win.setSize(size.width, size.height, false);
  win.setPosition(x, y, false);
  if (!wasResizable) win.setResizable(false);
  if (win.webContents) win.webContents.invalidate();
  win.webContents.send('app:settings', publicSettings());
  updateTray(snapshot || buildSnapshot());
}

function publicSettings() {
  return {
    ...settings,
    colors: COLORS
  };
}

function applySettings(patch) {
  const prevMini = settings.mini;
  settings = { ...settings, ...patch };
  normalizeSettings();
  saveSettings();

  if (win && !win.isDestroyed()) {
    win.setAlwaysOnTop(settings.alwaysOnTop, 'floating');
    win.webContents.send('app:settings', publicSettings());
  }
  if ('autoStart' in patch) setAutoStart(settings.autoStart);
  if (settings.mini !== prevMini) setMini(settings.mini, true);
  tick();
}

function setAutoStart(enabled) {
  // Use a Startup-folder shortcut rather than a Run key: Electron's Run entry
  // does not quote paths, which breaks for folders containing spaces.
  try {
    execFile('reg.exe', ['delete', 'HKCU\\Software\\Microsoft\\Windows\\CurrentVersion\\Run', '/v', 'com.tempsticky.overlay', '/f'], { windowsHide: true }, () => {});

    const script = path.join(__dirname, '..', 'scripts', 'set-autostart.ps1');
    const args = ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', script];
    if (enabled) {
      args.push('-Target', process.execPath, '-AppPath', app.getAppPath(), '-Icon', path.join(__dirname, '..', 'assets', 'tempsticky.ico'));
    } else {
      args.push('-Disable');
    }
    execFile('powershell.exe', args, { windowsHide: true }, (err) => {
      if (err) log('setAutoStart failed', err.message);
    });
  } catch (e) {
    log('setAutoStart failed', e.message);
  }
}

/* -------------------------------------------------------------------- setup */

function openSensorSetup() {
  const script = path.join(__dirname, '..', 'scripts', 'setup-sensor.ps1');
  const safe = script.replace(/'/g, "''");
  const ps = `Start-Process -FilePath powershell.exe -Verb RunAs -ArgumentList @('-NoProfile','-ExecutionPolicy','Bypass','-File','${safe}')`;
  execFile('powershell.exe', ['-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', ps], { windowsHide: true }, (err) => {
    if (err) log('elevation failed', err.message);
  });
}

/* ---------------------------------------------------------------------- ipc */

ipcMain.handle('app:get-state', () => ({
  settings: publicSettings(),
  snapshot: snapshot || buildSnapshot()
}));

ipcMain.handle('app:window-info', () => ({
  visible: !!win && !win.isDestroyed() && win.isVisible(),
  minimized: !!win && !win.isDestroyed() && win.isMinimized(),
  focused: !!win && !win.isDestroyed() && win.isFocused(),
  bounds: win && !win.isDestroyed() ? win.getBounds() : null,
  alwaysOnTop: !!win && !win.isDestroyed() && win.isAlwaysOnTop()
}));

ipcMain.on('app:action', (_e, action, payload) => {
  switch (action) {
    case 'hide':
      hideNote();
      break;
    case 'show':
      showNote();
      break;
    case 'quit':
      quitting = true;
      app.quit();
      break;
    case 'mini':
      setMini(!!payload);
      break;
    case 'settings':
      applySettings(payload || {});
      break;
    case 'refresh':
      lastRestart = 0;
      maybeRestartSensor();
      tick();
      break;
    case 'setup':
      openSensorSetup();
      break;
    case 'open-folder':
      shell.openPath(SENSOR_DIR);
      break;
    case 'reset-position':
    case 'reset-note':
      resetNote();
      break;
    default:
      break;
  }
});

/* --------------------------------------------------------------------- boot */

if (!app.requestSingleInstanceLock()) {
  app.quit();
} else {
  app.setAppUserModelId('com.tempsticky.overlay');

  app.on('second-instance', () => {
    showNote();
  });

  app.whenReady().then(() => {
    loadSettings();
    sensorInstalled = fs.existsSync(SENSOR_FILE);

    if (settings.autoStart) setAutoStart(true);

    createWindow();
    tray = new Tray(trayImage(buildSnapshot()));
    tray.setToolTip('TempSticky — starting…');
    tray.on('click', () => toggleWindow());
    tray.on('double-click', () => toggleWindow());

    tick();
    pollTimer = setInterval(tick, POLL_MS);

    globalShortcut.register('CommandOrControl+Alt+T', () => toggleWindow());

    app.on('activate', () => {
      if (!win || win.isDestroyed()) createWindow();
      else showNote();
    });
  });

  app.on('before-quit', () => {
    quitting = true;
    if (win && !win.isDestroyed() && !settings.mini) {
      const [x, y] = win.getPosition();
      settings.bounds = { x, y };
      saveSettings();
    }
  });

  app.on('will-quit', () => {
    globalShortcut.unregisterAll();
    if (pollTimer) clearInterval(pollTimer);
  });

  app.on('window-all-closed', () => {
    // Keep running in the tray; quitting happens from the tray menu.
  });
}
