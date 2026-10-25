# Rich Music

Rich Music adalah antarmuka pemutar musik berbasis web dengan tema gelap, inspirasi desain music streaming modern, pemutar **Now Playing** layar penuh, serta tampilan lirik/karaoke.

> **Catatan penting:** paket ini menyertakan frontend dan backend Express (`server.js`, `api/index.js`). Untuk fitur online, jalankan backend Node.js atau deploy dengan konfigurasi Vercel yang disertakan. Situs statis saja tidak menyediakan endpoint API.

## Fitur

- **Home** dengan banner, aksen hijau, dan bagian musik.
- Pemutar **Now Playing** layar penuh dengan tab **Song**, **Lyrics**, **Queue**, dan **Related**.
- Lirik dengan sinkronisasi/karaoke jika timestamp tersedia, **pilihan kandidat lirik dari beberapa sumber**, cache lirik untuk pembacaan offline, dan **Lyrics Studio** untuk mengedit atau menyelaraskan lirik.
- **Local Audio Lab**: memutar file lokal, menyimpan file ke pustaka offline IndexedDB, memutar/menghapus lagu tersimpan, serta spectrum analyzer Web Audio real-time. Data pustaka tersimpan pada origin browser/WebView ini dan bisa hilang jika data aplikasi dihapus.
- Equalizer tiga band (bass, mid, treble) untuk file Local Audio Lab; pengaturan EQ disimpan lokal.
- Sleep timer menghentikan pemutaran YouTube dan audio lokal saat timer berakhir.
- Unduhan MP3 menggunakan konverter pihak ketiga yang sudah ada; keberhasilan dan ketersediaannya bergantung pada layanan eksternal.
- Mode lirik otomatis immersive saat pemutar terbuka dan orientasi berubah ke landscape.
- Pencarian musik, chart, mood, related tracks, dan queue melalui backend API.
- Playlist dan preferensi lokal yang disimpan di browser.
- Floating player dan pintasan keyboard.
- Desain responsif untuk desktop dan layar yang lebih kecil.

## Teknologi

- HTML5
- CSS3
- JavaScript (vanilla, tanpa framework frontend)
- YouTube IFrame Player API untuk pemutaran
- LRCLIB untuk pencarian lirik tertentu
- Google Fonts (Figtree)

## Struktur file

```text
rich-music/
├── index.html
├── app.js
├── styles.css
└── README.md
```

## Menjalankan aplikasi

### 1. Siapkan backend

Frontend memanggil beberapa endpoint relatif, termasuk:

- `/api/home`
- `/api/search`
- `/api/suggest`
- `/api/charts`
- `/api/moods`
- `/api/browse`
- `/api/resolve`
- `/api/next`
- `/api/related`
- `/api/lyrics`
- `/api/sponsorblock`

Ada juga endpoint terkait unduhan seperti `/api/download-start` dan `/api/download-progress`. Backend harus menyediakan endpoint yang diperlukan sesuai format data yang diharapkan oleh `app.js`.

### 2. Letakkan frontend di direktori yang disajikan server

Salin `index.html`, `app.js`, dan `styles.css` ke direktori frontend milik backend, lalu jalankan server tersebut. Buka alamat lokal yang disediakan server di browser.

**Jangan hanya membuka `index.html` melalui `file://`**: permintaan `/api/...` membutuhkan server yang berjalan.

### 3. Hosting di GitHub

1. Buat repository baru di GitHub.
2. Unggah `README.md`, `index.html`, `app.js`, dan `styles.css`.
3. Hubungkan repository dengan backend yang kompatibel dan konfigurasi hosting agar request `/api/...` diteruskan ke backend.
4. Jika memakai GitHub Pages saja, halaman statis mungkin dapat tampil, tetapi fitur yang membutuhkan endpoint backend tidak akan bekerja sampai API tersedia dan konfigurasi request disesuaikan.

## Pintasan keyboard

| Tombol | Fungsi |
| --- | --- |
| `Space` | Putar / jeda |
| `←` / `→` | Mundur / maju 5 detik |
| `Shift` + `←` / `→` | Lagu sebelumnya / berikutnya |
| `M` | Mute / pulihkan volume |
| `L` | Buka lirik fullscreen |
| `E` | Buka Lyrics Studio |
| `P` | Buka / tutup floating player |
| `Esc` | Minimalkan pemutar dan kembali ke Home |
| `?` | Tampilkan bantuan pintasan |

Pintasan tertentu tidak dijalankan ketika fokus berada di input, textarea, select, atau tombol.

## Konfigurasi dan penyimpanan

Preferensi dan data lokal tertentu disimpan di `localStorage` browser. Menghapus data situs/browser dapat menghapus data lokal tersebut.

## Kredit dan layanan eksternal

Rich Music menggunakan layanan eksternal sesuai fitur yang dipakai, termasuk YouTube IFrame Player API, LRCLIB, dan Google Fonts. Ketersediaan serta kebijakan layanan tersebut mengikuti penyedia masing-masing.

## Status proyek

Antarmuka dan fitur dapat berubah seiring pembaruan. Endpoint backend, format respons API, dan dukungan layanan eksternal perlu cocok dengan versi frontend yang digunakan.

## Changelog — Premium Web / Android preparation

### Added
- Endpoint `GET /api/lyrics/search` mengumpulkan kandidat lirik LRCLIB dan menambahkan hasil dari NetEase, lyrics.ovh, dan Textyl jika tersedia.
- Tombol **Pilih lirik** dan dropdown untuk menerapkan kandidat. Pilihan tersimpan per lagu di penyimpanan lokal.
- Cache lirik di `localStorage`, dengan fallback saat endpoint lirik tidak dapat dijangkau.
- **Local Audio Lab** untuk memilih file audio lokal, memutarnya tanpa koneksi internet, dan menampilkan spectrum yang benar-benar dihitung oleh `AnalyserNode` Web Audio.
- Pergantian otomatis ke mode lirik immersive ketika pemutar terbuka lalu orientasi menjadi landscape.
- Service-worker cache version dinaikkan agar aset frontend baru dimuat ulang.

### Important limitations
- YouTube IFrame Player tidak mengekspos PCM audio ke Web Audio API karena batasan lintas-origin. Spectrum real-time pada rilis ini berlaku untuk **file audio lokal** di Local Audio Lab; jangan menyamakan animasi dekoratif dengan analisis audio YouTube.
- Unduhan MP3 bergantung pada konverter eksternal dan hak/ketersediaan konten. Gunakan hanya untuk konten yang memang boleh diunduh.
- Cache PWA dan cache lirik membantu akses offline, tetapi streaming YouTube dan endpoint backend tetap memerlukan internet. File offline diputar melalui Local Audio Lab dengan memilih file dari perangkat.
- APK native belum dibangun atau diuji dalam lingkungan ini. Web source kompatibel dengan deployment Vercel yang ada, sedangkan paket Android native perlu dikonfigurasi dan diuji terpisah.

## Menyiapkan pembungkus Android (opsional)

Proyek saat ini adalah aplikasi web. Untuk membuat proyek pembungkus Android, instal Capacitor di salinan proyek dan arahkan WebView ke deployment Rich Music yang memiliki backend API, atau siapkan API base khusus untuk aplikasi native. Contoh awal:

```bash
npm install @capacitor/core @capacitor/cli @capacitor/android
npx cap init "Rich Music" "com.richmusic.app" --web-dir public
npx cap add android
npx cap sync android
npx cap open android
```

Perintah ini hanya membuat kerangka proyek Android; belum mengaktifkan pemutaran latar belakang native. Untuk playback background yang andal, implementasikan dan uji Android MediaSession/foreground service pada proyek native, karena WebView/YouTube IFrame saja tidak menjaminnya.



## Pemeriksaan dan batasan fitur

Jalankan `npm test` untuk pemeriksaan sintaks JavaScript dan smoke test statis. Smoke test tidak menggantikan uji browser, pengujian API eksternal, atau uji perangkat Android. Untuk fitur online, dependensi harus terpasang (`npm ci`) dan server harus dapat mengakses layanan eksternal.

### Android / Capacitor

`capacitor.config.json` adalah konfigurasi awal, bukan APK siap pakai. Buat platform Android dengan Capacitor setelah dependensi terpasang, lalu buka proyek Android untuk build. Pemutaran yang andal ketika aplikasi diminimalkan, kontrol lock-screen, dan layanan foreground **belum diimplementasikan sebagai layanan native** dalam paket ini dan harus diuji pada perangkat Android.

### Offline

Pustaka audio menggunakan IndexedDB pada origin web atau WebView. Ini berguna untuk pemutaran offline di aplikasi yang sama, tetapi bukan direktori bersama Android; menghapus data aplikasi/browser dapat menghapus lagu yang disimpan. Spectrum analyzer dan EQ hanya bekerja untuk file lokal yang diputar melalui Local Audio Lab, bukan audio YouTube IFrame.

## Android APK via GitHub Actions (new)

This repository includes `.github/workflows/android-apk.yml`. Push the source to GitHub, then open **Actions → Build Android APK → Run workflow**. The workflow runs `npm test`, installs the Capacitor 7 toolchain, generates the Android wrapper, builds a debug APK, and uploads `app-debug.apk` as the `rich-music-android-debug` artifact. A push to `main` or `master` that changes the web app or Capacitor config also triggers the workflow.

**Important architecture note:** this first APK pipeline is a Capacitor wrapper configured to load `https://musikk-delta.vercel.app`, because the current player and lyric/download endpoints are served by that deployment. It is not yet a fully self-contained native music player. Internet is needed to load the hosted app/API; locally saved browser/WebView tracks depend on that WebView's storage and can be cleared with app data. This pipeline does not add native background playback, Android MediaSession controls, or notification controls. Those require a separate native implementation. The APK is not considered verified until the GitHub Actions workflow succeeds and the artifact is installed and tested on a real Android device.
