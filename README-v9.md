# Rich Music Premium v9

Paket source web/PWA + Android Capacitor, berdasarkan source v8 hotfix yang tersedia. Fokus rilis ini adalah playback native lokal yang lebih nyaman dan kooperatif terhadap sistem audio Android.

## Perubahan v9

- **Timeline audio native**: slider posisi, waktu berjalan, durasi, dan seek ke posisi yang dipilih untuk file yang sedang diputar melalui Android Background Player.
- **Audio focus Android**: native player meminta audio focus, pause ketika fokus audio hilang, mengurangi volume pada duck sementara, dan memulihkan volume/opsional playback saat fokus kembali.
- **UI Local Audio Lab**: timeline native mengikuti status player melalui polling ketika panel terbuka; kontrol dinonaktifkan jika tidak ada audio aktif.
- **Validasi source**: smoke test mengecek API seek, audio focus, AndroidX `ActivityResult` import, dan cache shell terbaru.
- Service worker cache dinaikkan menjadi `rich-music-shell-v27`.

## Penggunaan

1. Ganti source repository dengan isi ZIP v9.
2. Jalankan workflow GitHub Actions **Build Android APK**.
3. Setelah APK benar-benar berhasil dibangun, instal di perangkat Android 8.0+.
4. Buka **Local Audio Lab → Android Background Player → Pilih & putar file**.
5. Gunakan timeline untuk berpindah posisi; kontrol pause/resume/stop juga tersedia dari UI dan notifikasi Android.

## Batasan

- Native background playback hanya untuk file yang dipilih lewat Android Background Player. Pustaka IndexedDB Web Audio dan YouTube IFrame tetap menggunakan jalur playback terpisah.
- Visualizer dan EQ berbasis Web Audio tidak menganalisis audio native yang diputar oleh MediaPlayer.
- Perilaku background tetap dapat dipengaruhi kebijakan baterai/perangkat. Android 13+ juga memiliki izin notifikasi.
- Timeline UI hanya dipoll ketika Local Audio Lab terbuka; pemutaran native sendiri tidak bergantung pada panel itu.

## Validasi yang dilakukan

`npm test`, `bash -n scripts/install-android-background.sh`, sinkronisasi file root dengan `public/`, dan pemeriksaan integritas ZIP dijalankan pada source ini.

**Build Gradle APK dan pengujian perangkat fisik belum dijalankan dalam lingkungan ini.** Smoke test dan pemeriksaan sintaks bukan bukti bahwa APK sudah terkompilasi atau perilaku runtime sudah terverifikasi.
