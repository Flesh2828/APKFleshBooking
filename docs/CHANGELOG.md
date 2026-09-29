# Changelog — RoomBook

Semua perubahan tercatat pada dokumen ini dengan standar [Keep a Changelog](https://keepachangelog.com/).

---

## [1.0.0] - 2026-09-29 (Rilis Prototipe / MVP)

### Ditambahkan:
- **Autentikasi & Akun Role-Based:**
  - Role Mahasiswa, Dosen, Staf, dan Administrator.
  - Quick Role Switcher untuk demonstrasi dan evaluasi instan.
- **Katalog Ruangan:**
  - Tampilan grid responsif dengan gambar representatif, gedung, lantai, kapasitas, fasilitas, dan jam buka-tutup.
  - Pencarian teks nama/gedung dan filter kapasitas.
- **Cek Ketersediaan Interaktif:**
  - Kalender interaktif untuk memilih tanggal.
  - Timeline slot waktu per jam dengan visualisasi status: *Available*, *Pending*, *Booked*, dan *Maintenance*.
- **Formulir Pengajuan Reservasi:**
  - Validasi otomatis: kapasitas melebihi kuota, jam operasional, waktu selesai <= waktu mulai, dan bentrok dengan reservasi yang disetujui.
  - Dukungan pengisian kebutuhan fasilitas tambahan dan catatan.
- **Modul Persetujuan Administrator:**
  - Antrean pengajuan berstatus `PENDING`.
  - Fitur Setujui (*Approve*) dengan validasi ulang bentrok jadwal.
  - Fitur Tolak (*Reject*) dengan isian wajib alasan penolakan.
- **Riwayat & Pelacakan Status Pengguna:**
  - Halaman "Reservasi Saya" untuk memantau status secara langsung.
  - Fitur pembatalan pengajuan oleh pemesan.
- **Log Audit & Notifikasi:**
  - Pencatatan seluruh perubahan status ke log riwayat.
  - Dropdown notifikasi in-app untuk pembaruan status pemesanan.
- **Manajemen Ruangan Admin:**
  - Tambah ruangan baru dan aktivasi/penonaktifan ruangan.
- **Dokumentasi Lengkap:**
  - Panduan 14 dokumen arsitektur, PRD, database, API, keamanan, pengujian, dan deployment di folder `docs/`.
