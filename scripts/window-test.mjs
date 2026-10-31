// Verifies hide / minimize / restore behaviour over CDP.
const port = process.argv[2] || '9222';
const targets = await (await fetch(`http://127.0.0.1:${port}/json/list`)).json();
const page = targets.find((t) => t.type === 'page' && t.url.includes('index.html'));
if (!page) { console.error('no page'); process.exit(1); }

const ws = new WebSocket(page.webSocketDebuggerUrl);
let seq = 0;
const pending = new Map();
ws.addEventListener('message', (ev) => {
  const m = JSON.parse(ev.data);
  if (m.id && pending.has(m.id)) { pending.get(m.id)(m); pending.delete(m.id); }
});
await new Promise((r) => ws.addEventListener('open', r, { once: true }));

const send = (method, params = {}) => new Promise((resolve) => {
  const id = ++seq;
  pending.set(id, resolve);
  ws.send(JSON.stringify({ id, method, params }));
});
const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
const evaluate = async (expression) => {
  const r = await send('Runtime.evaluate', { expression, returnByValue: true, awaitPromise: true });
  return r.result?.result?.value;
};
const info = () => evaluate('window.tempsticky.windowInfo()');

await send('Runtime.enable');
console.log('initial      ', JSON.stringify(await info()));

// Hide via the app's own action
await evaluate("window.tempsticky.action('hide')");
await sleep(700);
console.log('after hide   ', JSON.stringify(await info()));

await evaluate("window.tempsticky.action('show')");
await sleep(700);
console.log('after show   ', JSON.stringify(await info()));

// Minimize through the browser domain (same as Win+D / taskbar minimize)
const win = await send('Browser.getWindowForTarget', { targetId: page.id });
if (win.result?.windowId) {
  await send('Browser.setWindowBounds', { windowId: win.result.windowId, bounds: { windowState: 'minimized' } });
  await sleep(700);
  console.log('after minimize', JSON.stringify(await info()));

  await evaluate("window.tempsticky.action('show')");
  await sleep(900);
  console.log('after restore ', JSON.stringify(await info()));
} else {
  console.log('Browser.getWindowForTarget unavailable:', JSON.stringify(win));
}

ws.close();
process.exit(0);
