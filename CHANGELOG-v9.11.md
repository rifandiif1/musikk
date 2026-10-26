# RichMusic v9.11 — Stay in App Playback Fix

- Removed automatic YouTube Music/ReVanced/browser handoff from the main Play path.
- If Android Media3 cannot resolve a supported direct-audio source, playback falls back to the embedded YouTube player in RichMusic.
- Added a bounded wait for the embedded YouTube player to become ready before trying fallback playback.
- Tightened Internet Archive matching so weakly related results are not silently selected as background audio.
- Kept Now Playing / mini-player rendering independent from asynchronous native source resolution.
- Updated smoke tests to forbid automatic external handoff.

## Important limitation
This fix prevents an automatic browser/app switch. YouTube IFrame playback inside a WebView is not guaranteed to continue when minimized. Background playback is designed for local files or supported direct audio URLs that Media3 can actually play. This source has not been built as an APK or tested on a physical Android device in this environment.

## Checks
`npm test`, shell syntax check, ZIP integrity check. These are source-level checks only, not Android device validation.
