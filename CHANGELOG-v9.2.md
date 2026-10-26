# Changelog v9.2

- Replaced the hand-built MediaPlayer/MediaStyle notification path with Media3 ExoPlayer and MediaSessionService.
- Let the MediaSessionService generate/update the system media notification from the actual player state.
- Preserved local file picker and native controls; added direct HTTP(S) media URL bridge API.
- Explicitly documented that YouTube IFrame playback cannot be transferred to native ExoPlayer and is not guaranteed to continue in background.
- Bumped service-worker cache to `rich-music-shell-v29`.
- Gradle build and device runtime remain unverified until CI/device testing.
