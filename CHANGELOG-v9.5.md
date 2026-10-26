# RichMusic v9.5 — Main Player Background Route

- Android main-player queue resolves title/artist against Internet Archive direct audio files and starts the Media3 native queue.
- Native playback state drives main-player progress, play/pause and seeking.
- Notification controls use the Media3 queue, including previous/next candidates where matching audio exists.
- If no direct audio source is available, the app reports that limitation instead of silently claiming YouTube background playback.
- PWA/browser playback remains on the existing YouTube IFrame.
- This does not extract YouTube audio; availability depends on Internet Archive.
