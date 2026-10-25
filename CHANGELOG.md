# Changelog — Rich Music Premium

## 2026-10-25 — Offline Library & Audio Lab refinement

### Added
- Persistent **Local Audio Library** backed by IndexedDB. Users can save an audio file selected from the device, list saved tracks, play a saved track, and remove it from the local library.
- Three-band EQ for local files (bass shelf, mid peaking filter, treble shelf), with slider values persisted locally.
- Offline library status messages and error handling for unsupported browsers, unavailable storage, and storage quota failures.
- Sleep timer now also pauses Local Audio Lab playback, not only the YouTube IFrame player.
- Static smoke-test script covering root/public file parity, offline controls, IndexedDB wiring, EQ nodes, lyrics/download routes, service worker cache version, and duplicate HTML IDs.

### Changed
- Updated the service-worker cache key to `rich-music-shell-v21` so previously cached app assets are invalidated.
- Kept root `app.js`, `index.html`, and `styles.css` synchronized with their `public/` copies for Node/Vercel workflows.
- Added responsive AMOLED-styled layouts for the offline library and equalizer.
- Added a single-source playback safeguard: starting a local audio file pauses the YouTube IFrame player when it is ready.

### Verification
- `npm run check`: passed (Node syntax checks for server, frontend, service worker, and Vercel entry).
- `node scripts/smoke-test.js`: passed (static wiring and file-consistency checks).
- `npm test`: passed after the smoke test was corrected.
- `npm ci --ignore-scripts --no-audit --no-fund`: timed out in this environment; backend runtime and live provider integrations could not be tested here.
- No APK was built or tested on a physical Android device in this update.

### Known limitations
- The Local Audio Library stores files in the browser/WebView's IndexedDB origin. Clearing site/app data or uninstalling the app may remove those files; this is not yet an Android shared-storage download manager.
- Real-time spectrum and EQ apply to Local Audio Lab files only. YouTube IFrame audio is cross-origin and cannot be routed directly through Web Audio API.
- Reliable background playback with Android lock-screen controls still requires a native Android MediaSession/foreground service implementation and device-level validation.
- MP3 download depends on the configured third-party conversion service and may fail when that service changes, rate-limits, or rejects a video.
- LRC timing quality and candidate availability depend on external lyric catalogues.

## v1.2.0 — Android build pipeline preparation
- Added a manual and push-triggered GitHub Actions workflow to generate a Capacitor Android wrapper, run the source smoke tests, build a debug APK, and upload it as an artifact.
- Configured the wrapper to load the existing Vercel deployment so relative API calls continue to reach the hosted backend.
- Documented the hosted-wrapper architecture and its current limitations: internet requirement, WebView-scoped offline storage, and no native background MediaSession yet.
- APK build/device testing is pending; no successful APK build is claimed from this environment.


## v4 — Android mobile UI fixes
- Redesigned the phone bottom navigation with a glass surface, active state, improved spacing, and a compact “Library” label.
- Raised the shared modal layer above Now Playing and immersive lyrics so the three-dot More menu is not hidden behind the player.
- Bumped the service-worker shell cache to v22 so updated web assets can be fetched.
- Added smoke checks for the navigation and modal layering fixes.
- Background playback caveat remains: this APK loads the hosted website inside a WebView and uses the YouTube IFrame player. Reliable playback after the Android app is minimized requires changing the playback architecture to a native-supported audio source with Android MediaSession/foreground service; a CSS/JavaScript change alone cannot guarantee it.

## v5 — Premium Now Playing, lyrics and Android background-service foundation
- Redesigned Now Playing surfaces with glass-like tabs, refined artwork frame, premium controls, subtle ambient gradients and improved spacing.
- Improved synced lyrics focus, active-line treatment, translation readability and touch scrolling.
- Added native-wrapper safe-area spacing so Now Playing and fullscreen lyrics leave room for Android status/navigation bars.
- Fixed modal stacking order so the More menu can appear above the fullscreen Now Playing overlay.
- Added a Capacitor Android foreground service and notification, registered through a native plugin and driven by YouTube player PLAYING/PAUSED events.
- Bumped service-worker shell cache to v23.
- Background playback caveat: the service keeps the Android app process at foreground-service priority, but the web player is still the YouTube IFrame. Continuation can vary by YouTube embed behavior, Android version and device power policy; this is not equivalent to a native audio engine and requires device testing.
