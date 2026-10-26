# Rich Music v9.4 — Online + Offline Background Playback

## What changed
- Added online audio search using Internet Archive's public advanced search and metadata endpoints.
- Resolved playable direct audio files and sends an online queue to the Android Media3 native player.
- Existing local Android file queue remains on Media3 `ExoPlayer` + `MediaSessionService`, with platform media notification and media-session controls.
- Existing YouTube IFrame remains available for foreground playback, but is not falsely advertised as background-capable. The official IFrame does not expose its audio stream to the native player.

## Limitations
- Internet Archive is an archive catalog, not a complete commercial music catalog. Search results and playback depend on available files, network access, and each item's rights/availability.
- On Android APK, local files and supported direct online audio files use the native service. YouTube IFrame playback is still foreground-only under this architecture.
- Web/PWA playback uses the browser audio element; reliable locked-screen playback is only expected from the Android native service and must be verified on device.

## Validation
`npm test` checks JavaScript syntax and source-level wiring. Android Gradle build and physical-device playback must still be run in GitHub Actions/device; do not treat source tests as proof of runtime background playback.
