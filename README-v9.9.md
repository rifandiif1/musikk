# RichMusic v9.9 — Playback Handoff & Splash Revert

This release removes the v9.8 forced splash timeout. That timeout could remove the splash before the application UI had successfully initialized, leaving an apparently blank or unfinished screen. The app's existing splash lifecycle now controls dismissal again.

For Android online tracks, RichMusic first tries known YouTube/YouTube Music package IDs. If the installed ReVanced build uses a custom package ID, Android's app chooser is opened so the user can select the correct app. The destination app owns the audio session, background behavior, and media notification; RichMusic cannot embed ReVanced's private playback stream or mirror its controls.

## Verification
- `npm test`
- `bash -n scripts/install-android-background.sh`
- `node --check public/app.js`
- Android generator fixture and ZIP integrity check

An actual Gradle APK build and physical-device background playback test require Android SDK/Gradle and a device; they are not claimed here.
