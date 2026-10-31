// Evaluate one expression in the running overlay and print the result.
// Usage: node scripts/cdp-eval.mjs "window.tempsticky.windowInfo()"
const port = process.argv[2] || '9222';
const expr = process.argv[3];
if (!expr) { console.error('usage: node cdp-eval.mjs [port] "<js>"'); process.exit(1); }

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

const res = await new Promise((resolve) => {
  const id = ++seq;
  pending.set(id, resolve);
  ws.send(JSON.stringify({
    id,
    method: 'Runtime.evaluate',
    params: { expression: expr, returnByValue: true, awaitPromise: true }
  }));
});

const value = res.result?.result?.value;
console.log(typeof value === 'string' ? value : JSON.stringify(value, null, 2));
ws.close();
process.exit(0);
