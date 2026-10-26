## v9.4 Online + Offline Background Playback
See `README-v9.4.md` for online Internet Archive audio search, native Media3 queue integration, limitations, and validation notes.

# RichMusic v9.3 — Native background playback queue

## Perubahan v9.3

- Android Background Player sekarang dapat memilih **beberapa file audio lokal sekaligus**.
- File yang dipilih dikirim sebagai playlist ke AndroidX Media3 ExoPlayer di dalam `MediaSessionService`, bukan diputar dari WebView.
- Metadata judul/artis diperbarui saat item playlist berganti. Kontrol media sistem memanfaatkan playlist native untuk previous/next serta play/pause.
- Dukungan seek, status pemutar, stop, dan pemutaran URL audio HTTP(S) langsung yang sah/diizinkan tetap tersedia.
- Cache PWA dinaikkan ke `rich-music-shell-v30`.

## Menguji pemutaran lokal

1. Ganti source repo dengan isi ZIP ini.
2. Jalankan GitHub Actions → **Build Android APK**; pastikan `Build debug APK` sukses.
3. Unduh artifact `rich-music-android-debug` dari run tersebut dan instal APK hasil build terbaru.
4. Izinkan notifikasi jika diminta, lalu buka **Local Audio Lab → Android Background Player → Pilih & putar file**.
5. Pilih satu atau beberapa file. Pastikan audio terdengar dan kartu media muncul pada panel notifikasi/Quick Settings.
6. Uji play/pause, next/previous (jika antrean memiliki track yang sesuai), minimize, lalu kunci layar.

## Batasan YouTube online yang tidak boleh disamarkan

Pemutar katalog utama tetap memakai **YouTube IFrame Player API**. Audio tersebut dimiliki oleh player YouTube di WebView, bukan Media3. Android MediaSession/foreground service tidak dapat mengambil alih stream dari iframe, dan membuat notifikasi palsu saja tidak akan menjaga audio iframe tetap berjalan saat layar dikunci atau Activity/WebView dihentikan. Karena itu, versi ini **belum menjamin background playback untuk trek YouTube yang dimainkan melalui IFrame**.

Agar online background playback benar-benar didukung, aplikasi perlu menggunakan URL audio langsung yang memang boleh diputar oleh aplikasi atau integrasi streaming resmi yang menyediakan hak/fitur background playback. Plugin `BackgroundAudio.playUrl` menerima URL media langsung HTTP(S), bukan URL halaman YouTube atau ID video. Tidak ada klaim bahwa URL YouTube bisa diubah menjadi stream native.

## Validasi yang dilakukan untuk source ini

- `npm test` — lulus (pemeriksaan sintaks JavaScript dan smoke tests).
- `bash -n scripts/install-android-background.sh` — lulus.
- Fixture generator Android — lulus: service/plugin Java, dependency Media3, permission, manifest, dan queue berhasil dibuat.
- Integritas ZIP — harus diperiksa setelah arsip dibuat.
- **Gradle `assembleDebug`, kompilasi Java Android sesungguhnya, notifikasi di perangkat, serta playback saat layar terkunci belum diuji di lingkungan ini.** Build APK dan uji perangkat tetap diperlukan; jangan menganggap keberhasilan source test sebagai bukti APK berjalan.
