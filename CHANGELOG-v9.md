# Changelog — Rich Music Premium v9

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
