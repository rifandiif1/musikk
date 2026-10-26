# Changelog — Rich Music Premium v9.1

## Native playback
- Menambahkan slider seek, waktu saat ini, dan durasi untuk Android Background Player.
- Menambahkan metode plugin `seekLocal` untuk mengirim posisi pemutaran ke service native.
- Menambahkan permintaan dan pelepasan audio focus Android.
- Menangani kehilangan audio focus permanen/sementara, duck sementara, dan pemulihan fokus.

## UI & cache
- Menambahkan gaya timeline native yang responsif dengan aksen dinamis.
- Menangani status timeline ketika playback berhenti atau tidak aktif.
- Service-worker cache dinaikkan dari `rich-music-shell-v26` menjadi `rich-music-shell-v27`.

## Tes
- Memperluas smoke test untuk native seek, audio focus, dan import `androidx.activity.result.ActivityResult`.
- `npm test`: lulus.
- `bash -n scripts/install-android-background.sh`: lulus.
- Build Gradle dan pengujian perangkat Android fisik: belum dijalankan.

## v9.1 — Media notification hotfix
- Mengganti notifikasi biasa dengan Android `Notification.MediaStyle` yang ditautkan ke token `MediaSession`.
- Menampilkan kontrol Jeda/Lanjutkan dan Berhenti dalam tampilan ringkas notifikasi media.
- Menaikkan service-worker cache ke `rich-music-shell-v28`.
- Menambah smoke-test untuk memastikan MediaStyle dan token MediaSession tidak terhapus.


## v9.2 — Native background playback repair

- Switched native local playback to Media3 ExoPlayer + MediaSessionService; media notification is generated from the active session.
- Added direct HTTP(S) media URL bridge API; YouTube iframe background limitation is documented.
- Bumped service-worker cache to v29. Gradle/device testing not yet verified.
