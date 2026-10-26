# RichMusic v9.8 — Startup Splash Hotfix

This patch addresses a startup failure mode where the black splash overlay could remain visible if the main JavaScript failed before registering its own hide timer. Both `public/index.html` and root `index.html` now include an independent 3.5-second splash fail-safe and release the splash early on a window error or unhandled promise rejection.

## Build
1. Replace repository files with this ZIP.
2. Run the GitHub Actions workflow **Build Android APK**.
3. Install the newly generated APK (uninstall the old APK first if needed).

The fail-safe prevents the splash overlay from hiding the page forever; it does not prove every app feature initialized successfully. If the screen is still blank after 4 seconds, collect the GitHub Actions build log and Android WebView/Logcat error. APK/device verification is still required.
