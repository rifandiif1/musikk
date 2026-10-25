'use strict';
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const root = path.resolve(__dirname, '..');
const read = (p) => fs.readFileSync(path.join(root, p), 'utf8');

const html = read('public/index.html');
const app = read('public/app.js');
const css = read('public/styles.css');
const sw = read('public/service-worker.js');
const server = read('server.js');

// The static and root copies are used by different hosting/build workflows; keep them identical.
assert.equal(read('app.js'), app, 'root app.js must match public/app.js');
assert.equal(read('index.html'), html, 'root index.html must match public/index.html');
assert.equal(read('styles.css'), css, 'root styles.css must match public/styles.css');

// New offline audio UI must have exactly one matching element and a wired implementation.
for (const id of [
  'local-audio-save', 'local-audio-status', 'local-audio-library',
  'local-eq-bass', 'local-eq-mid', 'local-eq-treble',
  'local-eq-bass-value', 'local-eq-mid-value', 'local-eq-treble-value',
]) {
  const count = (html.match(new RegExp(`\\bid=["']${id}["']`, 'g')) || []).length;
  assert.equal(count, 1, `expected exactly one #${id} in HTML`);
  assert.ok(app.includes(`#${id}`) || app.includes(`'${id}'`), `expected app.js to reference ${id}`);
}
assert.match(app, /const DB_NAME = 'rich-music-local-library'/, 'offline library database should be named');
assert.match(app, /indexedDB\.open\(DB_NAME/, 'offline library should use IndexedDB');
assert.match(app, /createBiquadFilter\(\)/, 'local EQ should use Web Audio filters');
assert.match(app, /getByteFrequencyData\(bins\)/, 'visualizer should use real analyser frequency data');
assert.match(app, /RichLocalAudioPause/, 'sleep timer should be able to pause local audio');
assert.match(server, /\/api\/lyrics\/search/, 'multi-candidate lyrics endpoint should exist');
assert.match(server, /\/api\/download-start/, 'download start endpoint should exist');
assert.match(sw, /rich-music-shell-v21/, 'service worker cache version should be bumped after asset changes');

const capacitor = JSON.parse(read('capacitor.config.json'));
const workflow = read('.github/workflows/android-apk.yml');
assert.equal(capacitor.appId, 'com.richmusic.app', 'Capacitor app ID should be stable');
assert.equal(capacitor.server.url, 'https://musikk-delta.vercel.app', 'Android wrapper should use the deployed app so hosted API routes work');
assert.match(workflow, /assembleDebug/, 'Android workflow should build a debug APK');
assert.match(workflow, /upload-artifact@v4/, 'Android workflow should publish the APK artifact');

// Catch duplicate IDs in the actual HTML document.
const ids = [...html.matchAll(/\bid=["']([^"']+)["']/g)].map((m) => m[1]);
const duplicates = ids.filter((id, i) => ids.indexOf(id) !== i);
assert.deepEqual([...new Set(duplicates)], [], `duplicate HTML IDs found: ${[...new Set(duplicates)].join(', ')}`);

console.log('Rich Music smoke tests passed: source copies, offline UI wiring, IndexedDB, EQ, lyrics/download routes, service-worker cache, Capacitor Android workflow, unique IDs.');
