'use strict';

const zlib = require('node:zlib');

const CRC_TABLE = (() => {
  const t = new Uint32Array(256);
  for (let n = 0; n < 256; n++) {
    let c = n;
    for (let k = 0; k < 8; k++) c = c & 1 ? 0xedb88320 ^ (c >>> 1) : c >>> 1;
    t[n] = c >>> 0;
  }
  return t;
})();

function crc32(buf) {
  let c = 0xffffffff;
  for (let i = 0; i < buf.length; i++) c = CRC_TABLE[(c ^ buf[i]) & 0xff] ^ (c >>> 8);
  return (c ^ 0xffffffff) >>> 0;
}

function chunk(type, data) {
  const len = Buffer.alloc(4);
  len.writeUInt32BE(data.length, 0);
  const typeBuf = Buffer.from(type, 'ascii');
  const crc = Buffer.alloc(4);
  crc.writeUInt32BE(crc32(Buffer.concat([typeBuf, data])), 0);
  return Buffer.concat([len, typeBuf, data, crc]);
}

function encodePNG(width, height, rgba) {
  const stride = width * 4;
  const raw = Buffer.alloc((stride + 1) * height);
  for (let y = 0; y < height; y++) {
    raw[y * (stride + 1)] = 0;
    Buffer.from(rgba.buffer, rgba.byteOffset + y * stride, stride).copy(raw, y * (stride + 1) + 1);
  }
  const ihdr = Buffer.alloc(13);
  ihdr.writeUInt32BE(width, 0);
  ihdr.writeUInt32BE(height, 4);
  ihdr[8] = 8;
  ihdr[9] = 6;
  const idat = zlib.deflateSync(raw, { level: 9 });
  return Buffer.concat([
    Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]),
    chunk('IHDR', ihdr),
    chunk('IDAT', idat),
    chunk('IEND', Buffer.alloc(0))
  ]);
}

const FONT = {
  '0': ['111', '101', '101', '101', '111'],
  '1': ['010', '110', '010', '010', '111'],
  '2': ['111', '001', '111', '100', '111'],
  '3': ['111', '001', '111', '001', '111'],
  '4': ['101', '101', '111', '001', '001'],
  '5': ['111', '100', '111', '001', '111'],
  '6': ['111', '100', '111', '101', '111'],
  '7': ['111', '001', '010', '010', '010'],
  '8': ['111', '101', '111', '101', '111'],
  '9': ['111', '101', '111', '001', '111']
};

function hexToRgb(hex) {
  const h = hex.replace('#', '');
  return [parseInt(h.slice(0, 2), 16), parseInt(h.slice(2, 4), 16), parseInt(h.slice(4, 6), 16)];
}

/**
 * Draws a round temperature badge (e.g. "62") and returns a PNG buffer.
 * Rendered at 8x then box-filtered down for clean edges on the Windows tray.
 */
function renderIcon(text, colorHex, size = 16) {
  const ss = 8;
  const S = size * ss;
  const buf = new Uint8Array(S * S * 4);
  const [r, g, b] = hexToRgb(colorHex);
  const cx = S / 2;
  const cy = S / 2;
  const radius = S * 0.475;

  for (let y = 0; y < S; y++) {
    for (let x = 0; x < S; x++) {
      const dx = x - cx + 0.5;
      const dy = y - cy + 0.5;
      if (dx * dx + dy * dy <= radius * radius) {
        const i = (y * S + x) * 4;
        buf[i] = r;
        buf[i + 1] = g;
        buf[i + 2] = b;
        buf[i + 3] = 255;
      }
    }
  }

  const chars = (text || '').slice(0, 2).split('').filter((c) => FONT[c]);
  if (chars.length) {
    const px = 2; // font pixel size in base px
    const gap = 1;
    const digitW = 3 * px;
    const totalW = chars.length * digitW + (chars.length - 1) * gap;
    const startX = Math.round((size - totalW) / 2 * ss);
    const startY = Math.round((size - 5 * px) / 2 * ss);
    const ink = [8, 17, 31, 255];

    chars.forEach((ch, idx) => {
      const glyph = FONT[ch];
      const ox = startX + idx * (digitW + gap) * ss;
      for (let row = 0; row < 5; row++) {
        for (let col = 0; col < 3; col++) {
          if (glyph[row][col] !== '1') continue;
          const x0 = ox + col * px * ss;
          const y0 = startY + row * px * ss;
          for (let yy = 0; yy < px * ss; yy++) {
            for (let xx = 0; xx < px * ss; xx++) {
              const x = x0 + xx;
              const y = y0 + yy;
              if (x < 0 || y < 0 || x >= S || y >= S) continue;
              const i = (y * S + x) * 4;
              buf[i] = ink[0];
              buf[i + 1] = ink[1];
              buf[i + 2] = ink[2];
              buf[i + 3] = 255;
            }
          }
        }
      }
    });
  }

  // Box-filter down to the requested size (premultiplied, so no dark fringes).
  const out = new Uint8Array(size * size * 4);
  const factor = ss;
  for (let y = 0; y < size; y++) {
    for (let x = 0; x < size; x++) {
      let sa = 0, sr = 0, sg = 0, sb = 0;
      for (let yy = 0; yy < factor; yy++) {
        for (let xx = 0; xx < factor; xx++) {
          const i = ((y * factor + yy) * S + (x * factor + xx)) * 4;
          const a = buf[i + 3];
          sa += a;
          sr += buf[i] * a;
          sg += buf[i + 1] * a;
          sb += buf[i + 2] * a;
        }
      }
      const o = (y * size + x) * 4;
      if (sa > 0) {
        out[o] = Math.round(sr / sa);
        out[o + 1] = Math.round(sg / sa);
        out[o + 2] = Math.round(sb / sa);
        out[o + 3] = Math.round(sa / (factor * factor));
      }
    }
  }

  return encodePNG(size, size, out);
}

module.exports = { renderIcon, encodePNG };
