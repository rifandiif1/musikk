# v9.10 — Keep Now Playing visible during Android playback
- Removed the eager Android YouTube/ReVanced handoff that returned from `startCurrent()` before the shared player UI update ran.
- Android online playback now tries RichMusic's native Media3 direct-audio resolver first; external YouTube/ReVanced handoff remains a fallback when no supported direct audio source can be resolved.
- The selected track metadata, mini-player, queue, tint, and media-session metadata are updated through the normal shared player path instead of being skipped by the early return.
- Updated smoke tests to guard against reintroducing the early-return handoff regression.

## Validation
- `npm test` passed, including JavaScript syntax checks and static smoke tests.
- APK build and real-device playback/background tests were not performed in this environment.
- YouTube IFrame fallback still cannot guarantee background playback; native background continuation requires the selected song to resolve to a supported direct audio URL.
