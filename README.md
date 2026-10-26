# RichMusic v9.7 — ReVanced External Playback Mode

## Behavior
- Keeps RichMusic's existing UI, search, queue display, and lyrics screen.
- On Android, selecting an online YouTube track opens that track in the installed YouTube Music/YouTube app first. A compatible ReVanced-patched app can then provide its own background playback and media notification.
- Local audio remains on RichMusic's native Media3 player and can continue in the background.
- Web/PWA continues using the embedded YouTube player.

## Important limitations
ReVanced is not exposed as a public audio-source API. RichMusic cannot directly take ReVanced's audio stream and play it inside its own player. Online playback is therefore an external handoff: the destination app owns audio, its notification, play/pause/seek, and next/previous controls. RichMusic keeps its UI when the user returns to it, but online progress, synced lyrics, transport controls, and automatic queue advancement are not guaranteed to follow the external session. Use the destination app's media notification for audio controls.

The handoff tries common package IDs for ReVanced and official YouTube Music/YouTube installations. For the intended behavior, install a compatible ReVanced YouTube Music or YouTube build and enable its background playback patch. The app package name depends on how the patched app was built.

## Build and validation
Run `npm ci`, `npm test`, then the GitHub Actions workflow `Build Android APK`. The workflow generates the Capacitor Android project, installs the native plugin, and runs `assembleDebug`.

Source syntax and smoke tests can be run locally with `npm test`; the ZIP itself is not a verified APK. An Android SDK/Gradle build and physical-device test were not performed in this environment. Test on device by selecting an online track, confirming it opens in the intended ReVanced app, returning to RichMusic, then minimizing/locking the phone and controlling audio through the external app's media notification.
