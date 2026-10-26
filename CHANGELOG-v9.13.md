# v9.13
- Added automatic Android handoff to YouTube Music / YouTube / ReVanced when native direct-audio resolution fails.
- Prevents falling back to embedded YouTube playback on Android in the failure path, since that cannot guarantee notification controls or background continuation.
- Keeps Media3 native playback as the first choice for compatible direct audio and local files.
- Bumped service worker cache to v37.
