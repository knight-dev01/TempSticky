'use strict';

const api = window.tempsticky;
const $ = (id) => document.getElementById(id);

const COLORS = {
  cool: '#38bdf8',
  optimal: '#34d399',
  warm: '#fbbf24',
  high: '#f87171',
  unknown: '#94a3b8',
  offline: '#64748b'
};

const LABELS = {
  cool: 'COOL',
  optimal: 'OPTIMAL',
  warm: 'WARM',
  high: 'HIGH',
  unknown: 'WAITING',
  offline: 'OFFLINE'
};

const el = {
  body: document.body,
  temp: $('temp'),
  state: $('state'),
  min: $('min'),
  max: $('max'),
  load: $('load'),
  gpu: $('gpu'),
  gpuStat: $('gpu-stat'),
  source: $('source'),
  updated: $('updated'),
  marker: $('marker'),
  band: document.querySelector('.band'),
  bandHot: $('band-hot'),
  chart: $('spark'),
  chartEmpty: $('chart-empty'),
  offlineBar: $('offline-bar'),
  offlineText: $('offline-text'),
  btnFix: $('btn-fix'),
  miniTemp: $('mini-temp'),
  miniDot: $('mini-dot'),
  panel: $('panel'),
  btnPin: $('btn-pin')
};

const ctx = el.chart.getContext('2d');
let W = 260;
let H = 60;
let settings = null;
let snapshot = null;
let lastLevel = null;

/* ------------------------------------------------------------------ canvas */

function fitCanvas() {
  const dpr = window.devicePixelRatio || 1;
  const rect = el.chart.getBoundingClientRect();
  W = Math.max(1, rect.width);
  H = Math.max(1, rect.height);
  el.chart.width = Math.round(W * dpr);
  el.chart.height = Math.round(H * dpr);
  ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
}

function tracePath(values, xAt, yAt) {
  ctx.beginPath();
  ctx.moveTo(xAt(0), yAt(values[0]));
  for (let i = 1; i < values.length; i++) {
    const xc = (xAt(i - 1) + xAt(i)) / 2;
    const yc = (yAt(values[i - 1]) + yAt(values[i])) / 2;
    ctx.quadraticCurveTo(xAt(i - 1), yAt(values[i - 1]), xc, yc);
  }
  ctx.lineTo(xAt(values.length - 1), yAt(values[values.length - 1]));
}

function drawSpark(values, accent, thresholds) {
  ctx.clearRect(0, 0, W, H);
  if (!values || values.length < 2) {
    el.chartEmpty.hidden = false;
    return;
  }
  el.chartEmpty.hidden = true;

  const pad = 7;
  let min = Math.min(...values);
  let max = Math.max(...values);
  if (max - min < 5) {
    const mid = (max + min) / 2;
    min = mid - 2.5;
    max = mid + 2.5;
  }
  const xAt = (i) => 1 + (i / (values.length - 1)) * (W - 2);
  const yAt = (v) => H - pad - ((v - min) / (max - min)) * (H - pad * 2);

  // warning line
  if (thresholds && thresholds.hotMin > min && thresholds.hotMin < max) {
    const y = yAt(thresholds.hotMin);
    ctx.save();
    ctx.setLineDash([3, 4]);
    ctx.strokeStyle = 'rgba(248,113,113,0.45)';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.moveTo(0, y);
    ctx.lineTo(W, y);
    ctx.stroke();
    ctx.restore();
  }

  // area
  tracePath(values, xAt, yAt);
  ctx.lineTo(xAt(values.length - 1), H);
  ctx.lineTo(xAt(0), H);
  ctx.closePath();
  const grad = ctx.createLinearGradient(0, 0, 0, H);
  grad.addColorStop(0, accent + '4d');
  grad.addColorStop(1, accent + '00');
  ctx.fillStyle = grad;
  ctx.fill();

  // line
  tracePath(values, xAt, yAt);
  ctx.strokeStyle = accent;
  ctx.lineWidth = 1.8;
  ctx.lineJoin = 'round';
  ctx.lineCap = 'round';
  ctx.stroke();

  // leading dot
  const lx = xAt(values.length - 1);
  const ly = yAt(values[values.length - 1]);
  ctx.beginPath();
  ctx.arc(lx, ly, 2.6, 0, Math.PI * 2);
  ctx.fillStyle = accent;
  ctx.fill();
  ctx.beginPath();
  ctx.arc(lx, ly, 4.6, 0, Math.PI * 2);
  ctx.fillStyle = accent + '33';
  ctx.fill();
}

/* ------------------------------------------------------------------- state */

function setAccent(color) {
  document.documentElement.style.setProperty('--accent', color);
}

function render(snap) {
  snapshot = snap;
  const level = snap.level || 'unknown';
  const color = COLORS[level] || COLORS.unknown;

  if (level !== lastLevel) {
    lastLevel = level;
    el.body.classList.toggle('high', level === 'high');
  }
  setAccent(color);

  const hasTemp = snap.cpu != null;
  el.temp.textContent = hasTemp ? String(Math.round(snap.cpu)) : '--';
  el.state.textContent = LABELS[level] || 'WAITING';

  el.min.textContent = snap.stats && snap.stats.min != null ? `${Math.round(snap.stats.min)}°` : '--';
  el.max.textContent = snap.stats && snap.stats.max != null ? `${Math.round(snap.stats.max)}°` : '--';
  el.load.textContent = snap.load != null ? `${Math.round(snap.load)}%` : '--';

  const showGpu = snap.showGpu && snap.gpu != null;
  el.gpuStat.classList.toggle('hidden', !showGpu);
  if (showGpu) el.gpu.textContent = `${Math.round(snap.gpu)}°`;

  el.miniTemp.textContent = hasTemp ? `${Math.round(snap.cpu)}°` : '--°';

  el.source.textContent = level === 'offline'
    ? 'sensor offline'
    : [snap.source, snap.cpuName].filter(Boolean).join(' · ');

  el.updated.textContent = snap.age == null ? '--' : snap.age <= 1 ? 'live' : `${snap.age}s ago`;

  const thresholds = snap.thresholds || (settings || {});
  el.bandHot.textContent = `${Math.round(thresholds.hotMin || 88)}°`;
  el.marker.style.left = `${Math.max(0, Math.min(100, hasTemp ? snap.cpu : 0))}%`;
  el.band.style.background = bandGradient(thresholds);

  drawSpark(snap.history, color, thresholds);

  const offline = level === 'offline';
  el.offlineBar.hidden = !offline;
  if (offline) {
    el.offlineText.textContent = snap.sensorInstalled
      ? 'Sensor stopped — trying to restart'
      : 'Temperature sensor not installed';
    el.btnFix.textContent = snap.sensorInstalled ? 'Restart' : 'Install';
  }
}

function bandGradient(t) {
  const p = (v) => Math.max(0, Math.min(100, Number(v) || 0));
  const coolMax = p(t.coolMax ?? 50);
  const warmMax = p(t.warmMax ?? 75);
  const hotMin = p(t.hotMin ?? 88);
  return `linear-gradient(90deg,
    #38bdf8 0%, #38bdf8 ${coolMax}%,
    #34d399 ${coolMax}%, #34d399 ${warmMax}%,
    #fbbf24 ${warmMax}%, #fbbf24 ${hotMin}%,
    #f87171 ${hotMin}%, #f87171 100%)`;
}

/* ---------------------------------------------------------------- settings */

function applySettings(s) {
  settings = s;
  document.documentElement.style.setProperty('--alpha', String(s.opacity));
  el.body.classList.toggle('mini', !!s.mini);
  el.btnPin.classList.toggle('active', !!s.alwaysOnTop);

  setRange('coolMax', s.coolMax);
  setRange('warmMax', s.warmMax);
  setRange('hotMin', s.hotMin);
  setRange('opacity', s.opacity, (v) => `${Math.round(v * 100)}%`);

  $('alwaysOnTop').checked = !!s.alwaysOnTop;
  $('autoStart').checked = !!s.autoStart;
  $('showGpu').checked = s.showGpu !== false;

  if (snapshot) {
    snapshot.thresholds = { coolMax: s.coolMax, warmMax: s.warmMax, hotMin: s.hotMin };
    snapshot.showGpu = s.showGpu !== false;
    render(snapshot);
  }
}

function setRange(id, value, fmt) {
  const input = $(id);
  if (!input) return;
  if (document.activeElement !== input) input.value = value;
  const out = $(`${id}-v`);
  if (out) out.textContent = fmt ? fmt(Number(value)) : `${Math.round(value)}°`;
}

function bindRange(id, key, fmt) {
  const input = $(id);
  input.addEventListener('input', () => {
    const value = Number(input.value);
    const out = $(`${id}-v`);
    if (out) out.textContent = fmt ? fmt(value) : `${Math.round(value)}°`;
    api.action('settings', { [key]: value });
  });
}

/* ------------------------------------------------------------------ events */

$('btn-hide').addEventListener('click', () => api.action('hide'));
$('btn-mini').addEventListener('click', () => api.action('mini', true));
$('btn-expand').addEventListener('click', () => api.action('mini', false));
$('btn-pin').addEventListener('click', () => {
  api.action('settings', { alwaysOnTop: !(settings && settings.alwaysOnTop) });
});

$('btn-settings').addEventListener('click', () => {
  el.panel.classList.add('open');
  el.panel.setAttribute('aria-hidden', 'false');
});
$('panel-close').addEventListener('click', closePanel);
$('btn-reset-pos').addEventListener('click', () => api.action('reset-note'));
$('btn-setup2').addEventListener('click', () => api.action('setup'));
$('btn-fix').addEventListener('click', () => {
  api.action(snapshot && snapshot.sensorInstalled ? 'refresh' : 'setup');
});

function closePanel() {
  el.panel.classList.remove('open');
  el.panel.setAttribute('aria-hidden', 'true');
}

document.addEventListener('keydown', (e) => {
  if (e.key === 'Escape') closePanel();
});

$('alwaysOnTop').addEventListener('change', (e) => api.action('settings', { alwaysOnTop: e.target.checked }));
$('autoStart').addEventListener('change', (e) => api.action('settings', { autoStart: e.target.checked }));
$('showGpu').addEventListener('change', (e) => api.action('settings', { showGpu: e.target.checked }));

bindRange('coolMax', 'coolMax');
bindRange('warmMax', 'warmMax');
bindRange('hotMin', 'hotMin');
bindRange('opacity', 'opacity', (v) => `${Math.round(v * 100)}%`);

window.addEventListener('resize', () => {
  fitCanvas();
  if (snapshot) drawSpark(snapshot.history, COLORS[snapshot.level] || COLORS.unknown, snapshot.thresholds);
});

/* -------------------------------------------------------------------- boot */

fitCanvas();

api.onState(render);
api.onSettings(applySettings);

api.getState().then(({ settings: s, snapshot: snap }) => {
  applySettings(s);
  if (snap) render(snap);
});
