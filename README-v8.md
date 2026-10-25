# Rich Music Premium v8

Paket source terbaru untuk Rich Music web/PWA dan pembungkus Android Capacitor. Versi ini melanjutkan v7 dan berfokus pada personalisasi UI, aksesibilitas/performa, serta pengelolaan antrean.

## Fitur baru v8

- **Pengaturan tampilan** melalui tombol ⚙ di top bar.
- **6 warna aksen**: Emerald, Ocean, Violet, Rose, Amber, dan Ice. Pilihan diterapkan ke tombol, indikator, dan visualizer serta disimpan lokal.
- **Kepadatan UI**: Nyaman atau Ringkas. Mode Ringkas mengurangi jarak dan ukuran sejumlah elemen agar lebih cocok untuk layar kecil/perangkat ringan.
- **Animasi dikurangi** untuk mengurangi transisi dan animasi antarmuka. Bisa diaktifkan kembali kapan saja.
- **Simpan antrean sebagai playlist** dari tab Queue. Lagu antrean disimpan ke playlist lokal dan dapat dikelola dari Your Library.
- **Pintasan keyboard tambahan**: `S` untuk shuffle, `R` untuk mengganti mode repeat, `↑`/`↓` untuk volume ±5%. Pintasan lama tetap tersedia.
- **Backup/restore preferensi** sekarang menyertakan warna aksen, kepadatan UI, dan preferensi animasi.
- Service-worker cache dinaikkan ke `rich-music-shell-v26` agar aset v8 tidak tertahan cache lama.

## Menggunakan

1. Jalankan atau deploy backend sesuai konfigurasi proyek.
2. Buka Rich Music lalu tekan tombol **⚙** di kanan atas untuk memilih warna aksen, kepadatan UI, dan animasi.
3. Untuk menyimpan antrean, buka **Now Playing → Queue → Simpan sebagai playlist**.
4. Data preferensi dan playlist tersimpan secara lokal di browser/WebView. Ekspor backup secara berkala jika data penting.

## Validasi yang dijalankan

`npm test` lulus untuk pemeriksaan sintaks JavaScript dan smoke test statis: konsistensi file root/`public`, elemen Local Audio Lab, konfigurasi native audio, cache service worker, pengaturan tampilan, simpan antrean menjadi playlist, pintasan keyboard, dan ID HTML unik.

**Batas validasi:** pada versi ini belum dilakukan build Gradle APK nyata atau pengujian pada perangkat Android. Keberhasilan smoke test bukan bukti bahwa APK sudah berhasil dibangun atau seluruh integrasi layanan eksternal berfungsi.

## Batasan penting yang tetap berlaku

- Pemutaran latar belakang native pada v7 hanya untuk file yang dipilih melalui **Android Background Player** di Local Audio Lab. Itu bukan mesin pemutar untuk YouTube IFrame atau lagu dari pustaka IndexedDB web.
- YouTube IFrame dapat berhenti saat aplikasi diminimalkan; jangan menganggap background playback YouTube sudah terjamin.
- Spectrum analyzer dan EQ Web Audio bekerja untuk file lokal yang diputar melalui Local Audio Lab, bukan audio YouTube IFrame.
- Pencarian musik/lirik, chart, related tracks, dan layanan unduhan bergantung pada backend serta penyedia eksternal.
