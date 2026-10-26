# RichMusic v9.5 — Main Player Background Route

This version changes Android main-player playback: when a YouTube Music search result is selected, the Android app attempts to find a matching direct audio file in Internet Archive and hands that file to the native Media3 ExoPlayer queue. It does not extract or convert YouTube audio.

- Android: Media3 ExoPlayer + MediaSessionService handles supported direct audio URLs and local files, including the system media session and notification controls.
- Web/PWA: keeps the existing YouTube IFrame player.
- If a direct audio source cannot be found, Android falls back to YouTube foreground playback and shows a message; that fallback is not background-capable.
- Internet Archive does not contain every commercial track, so background support depends on whether a suitable direct audio file exists and can be played.

## Build

Run `npm ci`, `npm test`, then use the GitHub Actions workflow `Build Android APK`. The workflow generates the Capacitor Android project, installs the native service, and runs `assembleDebug`.

## Validation status

Source checks and the Android project generator fixture have been run successfully. An Android SDK/Gradle build and physical-device background playback test were not available in this environment; do not treat the ZIP as a verified APK. Test on an Android device: select a song, confirm the media notification appears, minimize/lock the phone, and test Play/Pause/Next/Previous.
