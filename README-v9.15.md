# RichMusic v9.15 — LyraPlayer-style Android background handoff

## Playback architecture

- **Android online catalog tracks:** RichMusic opens the selected YouTube Music URL in an installed YouTube Music / YouTube / ReVanced app. That app owns the real playback session, background behavior, and system media notification. This avoids pretending a YouTube video ID is a direct audio URL.
- **Android local files:** the Android local-audio picker continues to use Media3 `ExoPlayer` inside `BackgroundAudioService`, registered as a `MediaSessionService`, following the same architecture used by LyraPlayer's `PlaybackService`. Media3 supplies the native media notification while actual local audio is playing.
- **Web/PWA:** remains on the embedded YouTube IFrame path; browsers do not have the same Android native service.

## Important behavior

Online catalog playback on Android switches to the destination music app. The destination app's notification owns play/pause/next/previous. RichMusic cannot reliably control that external session or guarantee background playback if the destination app does not support it. YouTube Music/ReVanced must be installed and configured for background playback. If no known package is found, Android shows an app chooser.

## Build

Run the repository's GitHub Actions Android APK workflow. Install the new APK, allow notifications if prompted, test an Android-picked local audio file, then test an online song and choose YouTube Music/ReVanced when prompted.

Source checks are not a substitute for an actual Gradle build and device test.
