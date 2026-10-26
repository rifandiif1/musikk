# RichMusic v9.14

## Fix
- Fixed Android Java compilation failure in `BackgroundAudioService.java`: added the missing `android.os.Build` import used by the `PendingIntent.FLAG_IMMUTABLE` SDK-version check in the generated service.

## Validation
- `npm test`
- `bash -n scripts/install-android-background.sh`
- Generated-service fixture check confirms `import android.os.Build;` is emitted in `BackgroundAudioService.java`.

A successful source test is not a substitute for building the APK with GitHub Actions or testing playback on a physical Android device.
