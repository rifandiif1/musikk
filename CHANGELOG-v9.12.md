# v9.12

- Wait for confirmed Media3 playback instead of assuming `playQueue()` means the audio started.
- Expose native player errors through `getState()` to prevent false background-playback UI state.
- Add MediaSession activity intent, ExoPlayer wake mode, and audio-noisy handling for supported native sources.
- Bump service-worker cache to v36.
- Document that embedded YouTube IFrame playback cannot be guaranteed in the background or represented as a native RichMusic media session.
