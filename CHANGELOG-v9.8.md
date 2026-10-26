# RichMusic v9.8 changelog

- Added an independent startup splash fail-safe to both HTML entry points.
- Splash releases after 3.5 seconds even if main app JavaScript throws before its own boot handler.
- Splash releases early on a window error or unhandled promise rejection.
- Added a smoke test for the fail-safe and kept root/public HTML copies synchronized.
- This is a startup diagnostic hotfix; Android APK build and physical-device testing are not claimed.
