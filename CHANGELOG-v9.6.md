# RichMusic v9.6 — ReVanced-compatible handoff

- Added Android native handoff for YouTube Music/YouTube links when no direct audio source is available.
- Tries common YouTube Music / ReVanced package IDs first, then Android's default link handler (custom package names supported through the default handler).
- Main player still prefers direct audio with Media3 when a valid stream is found.
- When direct audio resolution fails, the selected YouTube track opens in the external app rather than silently pretending the embedded IFrame is background-capable.
- Bumped service worker shell cache to v33.

Important: this does not copy or embed ReVanced patches into RichMusic. Background playback for the handed-off track depends on the installed destination app; use a compatible ReVanced YouTube Music/YouTube build with background playback enabled. The RichMusic and destination-app players are separate, so playback controls/lyrics inside RichMusic are not guaranteed to remain synchronized after handoff.
