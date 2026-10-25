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


## v6 — Android bundle, safe areas and lyrics fullscreen
- Bundle the local frontend in the APK while routing API calls to the hosted backend.
- Configure native status bar non-overlay behavior and keep the Android system status bar visible.
- Hide in-app chrome during immersive lyrics, add an exit button, and offset mini-player above mobile navigation.
- Add Android launcher/splash icon generation and a dedicated monochrome playback notification icon.
- Document that a foreground service alone cannot guarantee YouTube IFrame background playback.


## v6 — Bundle UI, safe areas, icons and immersive lyrics
- APK now bundles the local frontend rather than loading the hosted site, so UI source changes are included in each build.
- API requests and thumbnails route to the deployed Vercel backend; CORS headers were added for the native app origin. Redeploy Vercel to activate them.
- Keep Android status bar visible and prevent WebView overlay; hide in-app Now Playing header, tabs and lyric toolbar during fullscreen lyrics, with a compact exit control.
- Move the mini-player above the mobile navigation bar.
- Generate Android launcher/splash assets from `resources/icon.png` and `resources/splash.png`; use a dedicated monochrome notification icon.
- Background playback is still not guaranteed: current audio is supplied by YouTube IFrame and the foreground service does not own the audio stream.


## v7 — Android local audio background player

- Added a native Android file picker and `MediaPlayer` service for local audio playback independent of the WebView lifecycle.
- Added native `MediaSession` state/metadata and notification pause, resume, and stop actions.
- Added wake-lock and Android 13+ notification permission declarations/request.
- Added Android-only background-player controls to Local Audio Lab; existing web audio, IndexedDB, EQ, and spectrum remain available.
- Corrected Android safe-area double-padding and polished immersive lyrics layout and Android mini-player spacing.
- Explicitly stopped presenting the foreground service as a way to keep YouTube IFrame audio alive. YouTube IFrame background playback remains unsupported/unverified.

## v8 — UI personalization and queue tools
- Added a top-bar appearance panel with six accent presets, compact/comfortable density, and reduced-motion preference.
- Included new appearance preferences in library backup and restore.
- Added save-current-queue-as-local-playlist workflow.
- Added keyboard shortcuts for shuffle, repeat, and volume adjustments.
- Bumped service-worker cache to v26 and expanded static smoke tests.
- `npm test` passes; APK build and physical-device testing have not been performed in this environment.

## v8.0.1 — Capacitor ActivityResult import hotfix
- Fixed the generated `BackgroundAudioPlugin.java` import to use `androidx.activity.result.ActivityResult`, which is the Activity Result API type expected by Capacitor's `@ActivityCallback` method signature.
- This resolves the reported `cannot find symbol: class ActivityResult` compilation error at the source level. A full Gradle build is still required to verify the complete Android dependency/toolchain configuration.


## v9 — Native playback improvements
- Native local player timeline with seek support.
- Android audio focus handling for interruption, ducking, and focus restoration.
- Service worker cache bumped to v27.
- Source tests passed; Gradle APK build and physical-device testing are not yet verified.
