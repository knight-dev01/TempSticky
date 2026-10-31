// Generates assets/icon.png and assets/tempsticky.ico from the tray renderer.
import { mkdirSync, writeFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';

const require = createRequire(import.meta.url);
const { renderIcon } = require('../src/lib/icon.js');

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const assets = join(root, 'assets');
mkdirSync(assets, { recursive: true });

const ACCENT = '#34d399';
const sizes = [16, 24, 32, 48, 64, 128, 256];

const pngs = sizes.map((size) => ({ size, data: renderIcon('72', ACCENT, size) }));

writeFileSync(join(assets, 'icon.png'), pngs[pngs.length - 1].data);

// ICO container with PNG payloads (supported by Windows Vista and later)
const header = Buffer.alloc(6);
header.writeUInt16LE(0, 0);
header.writeUInt16LE(1, 2);
header.writeUInt16LE(pngs.length, 4);

const entries = Buffer.alloc(16 * pngs.length);
let offset = 6 + entries.length;
pngs.forEach(({ size, data }, i) => {
  const o = i * 16;
  entries.writeUInt8(size >= 256 ? 0 : size, o);
  entries.writeUInt8(size >= 256 ? 0 : size, o + 1);
  entries.writeUInt8(0, o + 2);
  entries.writeUInt8(0, o + 3);
  entries.writeUInt16LE(1, o + 4);
  entries.writeUInt16LE(32, o + 6);
  entries.writeUInt32LE(data.length, o + 8);
  entries.writeUInt32LE(offset, o + 12);
  offset += data.length;
});

writeFileSync(
  join(assets, 'tempsticky.ico'),
  Buffer.concat([header, entries, ...pngs.map((p) => p.data)])
);

console.log('wrote assets/icon.png and assets/tempsticky.ico');
