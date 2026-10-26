# RichMusic v9.7 — ReVanced External Playback Mode

- Changed Android online-track playback to hand off to the installed YouTube Music/YouTube app before attempting the embedded YouTube player.
- Added common custom ReVanced package IDs and made missing supported apps a clear failure rather than silently launching a browser.
- RichMusic keeps its existing UI; local audio continues to use native Media3.
- Online playback is owned by the destination app. RichMusic cannot directly access ReVanced's audio stream, so online progress, lyric synchronization, and transport controls inside RichMusic are not guaranteed. Use the destination app's media notification.
- Bumped service worker shell cache to v34.
