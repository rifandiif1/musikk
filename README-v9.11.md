# RichMusic v9.11

This version keeps the main Play action inside RichMusic. If a native direct-audio source cannot be resolved, the app falls back to the embedded YouTube player rather than opening a browser or YouTube Music automatically.

### Android build
1. Replace repository contents with this ZIP.
2. Push to GitHub.
3. Run Actions → Build Android APK.
4. Install the latest artifact and verify on-device.

### Playback limitation
Media3 background playback requires a supported direct audio URL or local file. A YouTube watch page / video ID is not itself a direct audio URL. Embedded YouTube IFrame playback may stop in the background; this cannot be fixed reliably by a UI-only change.

`npm test` verifies JavaScript syntax and static source wiring only. No APK/device test is claimed.
