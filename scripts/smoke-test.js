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
assert.match(server, /Access-Control-Allow-Origin/, 'bundled Android frontend needs API CORS headers');
assert.match(sw, /rich-music-shell-v29/, 'service worker cache version should be bumped after asset changes');

const capacitor = JSON.parse(read('capacitor.config.json'));
const workflow = read('.github/workflows/android-apk.yml');
assert.equal(capacitor.appId, 'com.richmusic.app', 'Capacitor app ID should be stable');
assert.equal(capacitor.webDir, 'public', 'Android APK should bundle the current local UI instead of loading a stale hosted UI');
assert.ok(!capacitor.server, 'Capacitor must not override the bundled UI with a remote server URL');
assert.match(app, /https:\/\/musikk-delta\.vercel\.app/, 'native API requests should still use the deployed backend');
assert.match(workflow, /assembleDebug/, 'Android workflow should build a debug APK');
assert.match(workflow, /upload-artifact@v4/, 'Android workflow should publish the APK artifact');
assert.match(workflow, /install-android-background\.sh/, 'Android workflow should install the native background service');
const nativeScript = read('scripts/install-android-background.sh');
assert.match(nativeScript, /extends MediaSessionService/, 'Android native playback must run in a MediaSessionService');
assert.match(nativeScript, /new ExoPlayer\.Builder\(this\)\.build\(\)/, 'Media3 ExoPlayer must own native audio playback');
assert.match(nativeScript, /new MediaSession\.Builder\(this, player\)\.build\(\)/, 'Media3 session must be bound to the actual player');
assert.match(nativeScript, /onGetSession\(/, 'system media clients must be able to discover the session');
assert.match(nativeScript, /media3-exoplayer:1\.8\.0/, 'generated Android project must include Media3 ExoPlayer');
assert.match(nativeScript, /media3-session:1\.8\.0/, 'generated Android project must include Media3 session');
assert.match(nativeScript, /ACTION_SEEK/, 'native playback should support seeking');
assert.match(nativeScript, /import androidx\.activity\.result\.ActivityResult;/, 'Capacitor activity callback should use AndroidX ActivityResult');
assert.doesNotMatch(nativeScript, /import com\.getcapacitor\.ActivityResult;/, 'invalid Capacitor ActivityResult import must not return');
assert.match(nativeScript, /FOREGROUND_SERVICE_MEDIA_PLAYBACK/, 'native player should use media-playback foreground service type');
assert.match(nativeScript, /POST_NOTIFICATIONS/, 'Android 13+ notification permission should be declared and requested');
assert.match(app, /syncAndroidBackgroundPlayback/, 'YouTube background limitation should be documented in playback bridge');
assert.match(app, /bridge\?\.pickAudio/, 'Android local file picker should be wired');
assert.match(app, /playLocal\(\{ uri: picked\.uri/, 'native local audio should pass the selected content URI to the service');
assert.match(app, /seekLocal\?\.\(\{ position:/, 'native audio timeline should send seek positions to Android');
assert.match(html, /id="android-native-audio"/, 'native background player controls should exist');
for (const id of ['android-audio-pick', 'android-audio-pause', 'android-audio-resume', 'android-audio-stop', 'android-audio-status', 'android-audio-seek', 'android-audio-position', 'android-audio-duration']) assert.match(html, new RegExp(`id="${id}"`), `native player control ${id} should exist`);
assert.match(css, /capacitor-native #nowplaying \.np-inner/, 'native Android should reserve system-bar safe area');
assert.match(css, /body\.lyrics-focus #nowplaying \.np-tabs/, 'immersive lyrics should hide the app tab bar');
assert.match(css, /#miniplayer \{[^}]*bottom: calc\(var\(--navm-h\)/s, 'mini-player should sit above mobile navigation');
assert.match(css, /body\.lyrics-focus #nowplaying \.np-topbar,[\s\S]*?display:none !important/, 'immersive lyrics should hide the player header');
assert.match(css, /html\.capacitor-native body \{ padding-top:0 !important; padding-bottom:0 !important; \}/, 'native safe area should not double-pad the WebView');
assert.ok(fs.existsSync(path.join(root, 'resources/icon.png')), 'native launcher icon source must exist');
assert.match(html, /id="lyrics-focus-exit"/, 'immersive lyrics needs an exit control');
assert.match(css, /lyric-line\.active/, 'lyrics should have premium active-line styling');
assert.match(css, /#modal \{[^}]*z-index: 760/, 'Now Playing menus should render above the player overlay');
assert.match(app, /html\.replace\('Your Library<\/span>', 'Library<\/span>'\)/, 'mobile navigation should use a compact Library label');
assert.match(html, /id="appearance-settings"/, 'appearance settings must be reachable from the top bar');
assert.match(app, /ACCENT_PRESETS = \[/, 'custom accent palette should be available');
assert.match(app, /function applyAppearanceSettings\(\)/, 'appearance preferences should apply to the UI');
assert.match(css, /html\[data-density="compact"\]/, 'compact density mode should have dedicated styling');
assert.match(css, /html\[data-motion="reduced"\]/, 'reduced motion mode should reduce UI animations');
assert.match(app, /q-save-playlist/, 'queue can be saved as a playlist');
assert.match(app, /e\.code === 'KeyS'/, 'keyboard shortcuts should include shuffle');
assert.match(app, /e\.code === 'KeyR'/, 'keyboard shortcuts should include repeat');

// Catch duplicate IDs in the actual HTML document.
const ids = [...html.matchAll(/\bid=["']([^"']+)["']/g)].map((m) => m[1]);
const duplicates = ids.filter((id, i) => ids.indexOf(id) !== i);
assert.deepEqual([...new Set(duplicates)], [], `duplicate HTML IDs found: ${[...new Set(duplicates)].join(', ')}`);

console.log('Rich Music smoke tests passed: source copies, offline UI wiring, IndexedDB, EQ, lyrics/download routes, service-worker cache, Capacitor Android workflow, unique IDs, appearance settings, queue-to-playlist, keyboard controls, native seek timeline, Media3 service generation, and background playback wiring.');
