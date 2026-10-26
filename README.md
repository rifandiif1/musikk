# RichMusic v9.15 — Android Background Playback

RichMusic uses two playback paths on Android:

- **Online catalog / YouTube tracks:** open the selected track in the installed YouTube Music, YouTube, or ReVanced app. That app owns background playback and the Android media notification.
- **Local audio files:** play through RichMusic's native Media3 `ExoPlayer` + `MediaSessionService`, modeled on the architecture in LyraPlayer's `PlaybackService.kt`. The native media notification is provided while that service is actually playing audio.
- **Web/PWA:** keeps the embedded YouTube IFrame path.

## Important limitations

A YouTube video ID is not a direct audio URL. RichMusic cannot turn an embedded YouTube IFrame into a native Media3 session. Online tracks are therefore handed off to the destination app, and the destination app's notification owns play/pause/next/previous. RichMusic cannot guarantee background playback if that app does not support it. Use a compatible YouTube Music/ReVanced installation configured for background playback. External progress, lyrics synchronization, in-app transport controls, and RichMusic queue advancement are not guaranteed to follow the external app's session.

## Build and test

1. Run `npm ci` and `npm test`.
2. Run the GitHub Actions **Build Android APK** workflow.
3. Install the APK and allow notifications if prompted.
4. Test a local audio file using RichMusic's Android local-audio panel; verify the Media3 notification appears and audio continues when minimized.
5. Test an online catalog song; choose YouTube Music/ReVanced if Android asks. Verify the destination app's own notification and background behavior.

Source tests are not a substitute for an Android Gradle build or a physical-device test. No APK/device test was performed in this environment.
