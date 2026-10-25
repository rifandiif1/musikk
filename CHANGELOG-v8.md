# Changelog — Rich Music Premium v8

## UI & personalisasi
- Menambahkan tombol pengaturan tampilan di top bar.
- Menambahkan 6 preset warna aksen yang disimpan lokal dan diterapkan melalui CSS custom properties.
- Menambahkan mode kepadatan Nyaman/Ringkas untuk mengatur jarak dan ukuran beberapa elemen.
- Menambahkan preferensi animasi penuh/dikurangi untuk perangkat yang lebih ringan.
- Memastikan pengaturan baru ikut dalam ekspor dan pemulihan backup library.

## Fitur musik
- Menambahkan aksi **Simpan sebagai playlist** pada tab Queue. Lagu dalam antrean aktif disimpan ke playlist lokal bernama pilihan pengguna.
- Menambahkan pintasan `S` untuk shuffle, `R` untuk repeat, serta panah atas/bawah untuk mengubah volume 5%.
- Memperbarui dialog bantuan pintasan keyboard.

## Pemeliharaan
- Service worker dinaikkan ke `rich-music-shell-v26`.
- Memperbarui smoke test untuk menguji pengaturan tampilan, mode ringkas, mode animasi dikurangi, queue-to-playlist, dan pintasan keyboard.
- Menjaga `app.js`, `index.html`, `styles.css`, dan `service-worker.js` di root tetap sama dengan salinan `public/`.

## Validasi
- `npm test`: lulus.
- `bash -n scripts/install-android-background.sh`: perlu tetap dijalankan bila skrip native diubah; skrip tersebut tidak berubah pada rilis ini.
- ZIP integritas akan diperiksa sebelum paket didistribusikan.
- Belum ada klaim APK berhasil dibangun atau diuji di perangkat fisik pada rilis ini.
