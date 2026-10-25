# Changelog — Rich Music Premium Update

## Added
- API `GET /api/lyrics/search` for multi-candidate lyrics from LRCLIB plus available NetEase, lyrics.ovh, and Textyl results.
- Lyrics source selector with local persistence of the chosen lyrics per track.
- Cached lyric text/LRC fallback when online lyrics lookup fails.
- Local Audio Lab: local-file offline playback with a real Web Audio `AnalyserNode` frequency spectrum.
- Automatic immersive lyrics view when the player is open and the screen rotates to landscape.
- Capacitor starter config for later Android packaging; this is not a built or verified APK.

## Validation
- `node --check` passes for the frontend and backend JavaScript files.
- Duplicate HTML `id` check passes for `public/index.html`.
- Runtime HTTP/API smoke test could not be completed because `express` was not installed in the test environment; `npm ci` timed out. Install dependencies and run `npm test` before deployment.

## Known limitations
- YouTube IFrame audio cannot be connected to Web Audio spectrum analysis due to cross-origin restrictions. Real spectrum analysis is provided for user-selected local audio files only.
- Online streaming, online lyrics lookup, and the external MP3 converter require internet access and provider availability.
- Downloading is not the same as offline playback. For offline playback, select an audio file saved on the device in Local Audio Lab.
- The Android project and background playback service have not been built or tested. Reliable background playback needs native Android MediaSession/foreground-service implementation.
