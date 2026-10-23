# Waktu Sholat

Aplikasi mobile berbasis Flutter untuk menampilkan jadwal sholat harian
sesuai kota yang dipilih. Dibuat sebagai tugas UTS mata kuliah
Pemrograman Multiplatform.

📝 Nama: ALZAINAP LARIZA K | NIM:240605110055| Kelas: A

## Deskripsi Singkat

Waktu Sholat menampilkan jadwal sholat harian (Subuh, Terbit, Dzuhur,
Ashar, Maghrib, dan Isya) yang diambil dari API Aladhan, lengkap dengan
hitung mundur menuju sholat berikutnya. Jadwal yang berhasil dimuat
disimpan di perangkat sehingga tetap dapat dibuka tanpa internet.

## Fitur Utama

- Jadwal sholat harian berdasarkan kota
- Sholat berikutnya dengan hitung mundur
- Pilihan 10 kota dan 3 metode perhitungan (Kemenag RI, Muslim World League, Egyptian General Authority)
- Jadwal tersimpan otomatis dan dapat dihapus (satu atau semua)
- Mode offline saat tidak ada koneksi internet
- Mode gelap
- Pengaturan tersimpan setelah aplikasi ditutup

## Teknologi dan Package

- Flutter dan Dart
- `http` untuk mengambil data dari API Aladhan
- `shared_preferences` untuk menyimpan pengaturan
- `sqflite` dan `path` untuk database SQLite
- `intl` untuk format tanggal

## Penerapan Konsep

- Asynchronous programming: `Future`, `async`, `await` untuk API, database, dan pengaturan
- Data persistence: Shared Preferences (pengaturan) dan SQLite (jadwal tersimpan)

## Cara Menjalankan

1. Pasang Flutter SDK dan pastikan `flutter doctor` tidak ada masalah.
2. Clone repository:
   `git clone https://github.com/USERNAME/waktu_sholat.git`
3. Masuk ke folder project: `cd waktu_sholat`
4. Pasang dependensi: `flutter pub get`
5. Jalankan emulator atau sambungkan perangkat, lalu: `flutter run`

Aplikasi membutuhkan koneksi internet saat pertama kali memuat jadwal.

## Struktur Folder

- `lib/database/` pengelolaan SQLite
- `lib/models/` model data jadwal sholat
- `lib/screens/` halaman aplikasi
- `lib/services/` layanan API dan pengaturan
- `lib/main.dart` titik awal aplikasi