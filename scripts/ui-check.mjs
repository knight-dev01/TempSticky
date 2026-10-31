// Live UI verification over the Chrome DevTools Protocol.
// Usage: node scripts/ui-check.mjs [port]
import { writeFileSync } from 'node:fs';

const port = process.argv[2] || '9222';
const base = `http://127.0.0.1:${port}`;

const targets = await (await fetch(`${base}/json/list`)).json();
const page = targets.find((t) => t.type === 'page' && t.url.includes('index.html')) ||
  targets.find((t) => t.type === 'page');
if (!page) {
  console.error('No page target found. Targets:', targets.map((t) => t.url));
  process.exit(1);
}

const ws = new WebSocket(page.webSocketDebuggerUrl);
let seq = 0;
const pending = new Map();
const logs = [];

ws.addEventListener('message', (ev) => {
  const msg = JSON.parse(ev.data);
  if (msg.id && pending.has(msg.id)) {
    pending.get(msg.id)(msg);
    pending.delete(msg.id);
    return;
  }
  if (msg.method === 'Runtime.exceptionThrown') {
    logs.push('EXCEPTION: ' + (msg.params.exceptionDetails.exception?.description || msg.params.exceptionDetails.text));
  }
  if (msg.method === 'Log.entryAdded') {
    logs.push(`${msg.params.entry.level}: ${msg.params.entry.text}`);
  }
  if (msg.method === 'Runtime.consoleAPICalled' && msg.params.type === 'error') {
    logs.push('console.error: ' + msg.params.args.map((a) => a.value ?? a.description).join(' '));
  }
});

await new Promise((resolve, reject) => {
  ws.addEventListener('open', resolve, { once: true });
  ws.addEventListener('error', reject, { once: true });
});

function send(method, params = {}) {
  return new Promise((resolve) => {
    const id = ++seq;
    pending.set(id, resolve);
    ws.send(JSON.stringify({ id, method, params }));
  });
}

async function evaluate(expression) {
  const res = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
  if (res.result?.exceptionDetails) return { error: res.result.exceptionDetails.text };
  return res.result?.result?.value;
}

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));

await send('Runtime.enable');
await send('Log.enable');

const snapshot = () => evaluate(`(() => {
  const t = (id) => document.getElementById(id);
  return {
    temp: t('temp').textContent,
    state: t('state').textContent,
    min: t('min').textContent,
    max: t('max').textContent,
    load: t('load').textContent,
    gpu: t('gpu').textContent,
    gpuHidden: t('gpu-stat').classList.contains('hidden'),
    source: t('source').textContent,
    updated: t('updated').textContent,
    accent: getComputedStyle(document.documentElement).getPropertyValue('--accent').trim(),
    tempFont: getComputedStyle(t('temp')).fontSize,
    noteRadius: getComputedStyle(document.getElementById('note')).borderRadius,
    bodyClass: document.body.className,
    offlineHidden: t('offline-bar').hidden,
    canvas: [t('spark').width, t('spark').height],
    windowSize: [window.outerWidth, window.outerHeight],
    chartReady: t('chart-empty').hidden,
    panelOpen: t('panel').classList.contains('open'),
    hasApi: !!window.tempsticky
  };
})()`);

console.log('--- initial ---');
console.log(JSON.stringify(await snapshot(), null, 2));

await sleep(4500);
console.log('--- after 4.5s ---');
console.log(JSON.stringify(await snapshot(), null, 2));

await evaluate("document.getElementById('btn-settings').click()");
await sleep(400);
const panel = await evaluate("document.getElementById('panel').classList.contains('open')");
console.log('settings panel opens:', panel);
await evaluate("document.getElementById('panel-close').click()");

await evaluate("document.getElementById('btn-mini').click()");
await sleep(900);
const mini = await snapshot();
console.log('--- mini mode ---');
console.log(JSON.stringify({ bodyClass: mini.bodyClass, windowSize: mini.windowSize, miniTemp: await evaluate("document.getElementById('mini-temp').textContent") }));

await evaluate("document.getElementById('btn-expand').click()");
await sleep(900);
const full = await snapshot();
console.log('--- expanded ---');
console.log(JSON.stringify({ bodyClass: full.bodyClass, windowSize: full.windowSize }));

const shot = await send('Page.captureScreenshot', { format: 'png' });
if (shot.result?.data) {
  writeFileSync(new URL('../ui-preview.png', import.meta.url), Buffer.from(shot.result.data, 'base64'));
  console.log('screenshot written: ui-preview.png');
}

console.log('--- console/log issues ---');
console.log(logs.length ? logs.join('\n') : 'none');

ws.close();
process.exit(0);
