# Rich Music

Rich Music adalah antarmuka pemutar musik berbasis web dengan tema gelap, inspirasi desain music streaming modern, pemutar **Now Playing** layar penuh, serta tampilan lirik/karaoke.

> **Catatan penting:** paket ini berisi frontend (`index.html`, `app.js`, dan `styles.css`). Fitur musik seperti Home, pencarian, chart, rekomendasi, dan beberapa data pemutar menggunakan endpoint backend `/api/...`. Karena kode backend tidak disertakan dalam paket ini, aplikasi tidak akan berfungsi penuh jika hanya diunggah sebagai situs statis ke GitHub Pages. Jalankan bersama backend yang kompatibel atau sesuaikan endpoint API di `app.js`.

## Fitur

- **Home** dengan banner, aksen hijau, dan bagian musik.
- Pemutar **Now Playing** layar penuh dengan tab **Song**, **Lyrics**, **Queue**, dan **Related**.
- Lirik dengan dukungan pencarian sumber lirik, tampilan sinkron/karaoke jika data bertimestamp tersedia, dan **Lyrics Studio** untuk mengedit atau menyelaraskan lirik.
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
