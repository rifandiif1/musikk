# RichMusic v9.12 — Native Playback & Notification Diagnostics

- Native Android playback now waits for actual Media3 state (`active` + `playing`) before marking the song as native/background-capable. A successful Capacitor call alone is not treated as proof of playback.
- Native service reports Media3 playback errors to the web UI, enables ExoPlayer wake mode/audio-noisy handling, and adds a tap-to-open activity intent to the media session.
- Native MediaSession notification controls are expected only while Media3 is actually playing a local file or a supported direct audio URL.

## Important YouTube limitation
The main music catalog plays official YouTube IFrame videos. A YouTube video ID/watch URL is not a direct audio stream, so Media3 cannot play it as native audio. When a direct-audio resolver cannot find a matching supported source, RichMusic stays in the embedded YouTube player; that mode cannot guarantee background audio or a native RichMusic media notification. This package does not claim to solve that platform limitation.

## Build and verification
Push the source to GitHub and run Actions → Build Android APK. `npm test` and shell syntax checks validate source wiring only. This environment cannot verify an APK on the user's device.
