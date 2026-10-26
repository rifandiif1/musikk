# v9.15

- Aligned Android online playback with the background-safe approach used by LyraPlayer: hand off YouTube catalog tracks to an installed music app instead of trying to make an embedded IFrame act like a native MediaSession.
- Kept Media3 `MediaSessionService` playback for local files selected in RichMusic's Android audio panel.
- Prevented the WebView's browser MediaSession from registering duplicate/stale controls on Android.
- Bumped service worker shell cache to v38 so updated scripts are loaded.
- No APK build or physical-device test was performed in this environment.
