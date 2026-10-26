# Rich Music Premium v9.2 — Background Playback Repair

## Apa yang berubah

- Pemutar audio native lokal dipindahkan ke **AndroidX Media3 ExoPlayer + MediaSessionService**. Service terpisah dari Activity/WebView dan bertanggung jawab atas audio serta sesi media.
- Notifikasi media dihasilkan oleh `MediaSessionService` berdasarkan status player sebenarnya, termasuk metadata lagu dan kontrol sistem; tidak lagi membuat notifikasi manual yang dapat terlepas dari player.
- Plugin native tetap menyediakan pilih file, play/pause/resume/stop, status dan seek.
- Ditambahkan metode native `playUrl` untuk **URL audio HTTP(S) langsung** yang memang dapat diakses sebagai media. Tautan halaman web dan ID/URL halaman YouTube bukan URL audio langsung.
- Manifest menyatakan `mediaPlayback` foreground service dan permission yang relevan. Dependensi Media3 ditambahkan oleh generator saat workflow membuat proyek Android.
- Cache service worker dinaikkan ke `rich-music-shell-v29`.

## Cara menguji pemutar lokal

1. Ganti source repo dengan isi ZIP ini.
2. Jalankan GitHub Actions → **Build Android APK** dan pastikan job `Build debug APK` benar-benar berstatus sukses.
3. Unduh artifact `rich-music-android-debug` dari run yang sama, instal APK itu, lalu izinkan notifikasi jika Android memintanya.
4. Buka **Local Audio Lab → Android Background Player → Pilih & putar file**.
5. Pastikan audio terdengar, kartu media muncul di panel notifikasi/Quick Settings, dan tombol pause/resume/stop berfungsi.
6. Pindah ke Home atau kunci layar; audio lokal harus tetap berjalan. Uji juga dengan menutup aplikasi dari Recent Apps.
7. Jika gagal, simpan logcat dari proses `com.richmusic.app` dan hasil Gradle build. Jangan menguji APK lama dari run sebelumnya.

## Batasan penting untuk pemutaran online

Player utama RichMusic menggunakan **YouTube IFrame Player API**. Audio itu dimiliki WebView/YouTube, bukan oleh ExoPlayer native. Service foreground tidak bisa mengambil alih stream audio dari iframe, sehingga menambahkan notifikasi saja tidak dapat membuat pemutaran YouTube tetap berjalan secara andal setelah aplikasi ditutup. Metode `playUrl` hanya mendukung URL media langsung yang sah/diizinkan oleh penyedianya; ia tidak mengubah URL video YouTube menjadi stream audio. Untuk background playback pada katalog online, sumber streaming harus menyediakan URL audio yang boleh diputar di aplikasi atau integrasi resmi yang mendukung background playback.

## Status validasi

- Source test dan generator script dapat diperiksa secara lokal.
- **Build Gradle dan pengujian perangkat belum diverifikasi di lingkungan pembuatan ZIP ini.** Jangan anggap APK berhasil sebelum workflow GitHub Actions menyelesaikan `assembleDebug` dan APK diuji pada perangkat.
