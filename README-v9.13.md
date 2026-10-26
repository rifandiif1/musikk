# RichMusic v9.13 — Background Playback Fallback

## Behavior
- Android first tries RichMusic's native Media3 player for compatible direct audio streams. When native playback actually starts, Android should expose RichMusic media controls in the system notification.
- If a catalog track has no compatible direct stream, the app automatically opens the track in YouTube Music / YouTube / a compatible ReVanced app instead of starting the embedded WebView player. The destination app owns its notification and background playback.
- Local files continue to use the native Media3 service.

## Important requirements
No app can force an unsupported streaming provider to continue audio in the background. For the external fallback, install a YouTube Music / YouTube client that supports background playback and configure its background-playback setting/patch. The official YouTube app may require Premium for background playback. In external mode, RichMusic does not own the audio session, so lyrics/progress/queue controls in RichMusic may not stay synchronized; use the destination app's notification.

## Validation
Run `npm test`. The source package does not represent a verified APK: build the APK through GitHub Actions and test on the Android device.
