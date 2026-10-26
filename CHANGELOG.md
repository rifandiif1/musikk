# RichMusic changelog

## v9.15 — LyraPlayer-style background playback routing
- Android online catalog tracks are handed directly to an installed YouTube Music / YouTube / ReVanced app so the destination owns the real playback session and notification.
- Local audio continues to use the native Media3 `MediaSessionService` path, matching LyraPlayer's service architecture.
- Avoid registering a duplicate WebView `MediaSession` for Android playback.
- Bumped the service worker cache to v38.
- Source tests pass; APK build and physical-device testing remain unverified.

## Previous releases
See the versioned `CHANGELOG-v9.*.md` files for earlier changes.
