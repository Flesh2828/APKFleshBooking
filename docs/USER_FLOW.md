# User Flow Documentation — RoomBook

**Dokumen:** User Journeys, Interaction Flows, and Decision Trees  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Alur Pengguna (Mahasiswa / Dosen / Staf)

```text
[Buka Website]
      |
      v
[Halaman Login] ---> [Autentikasi Akun / Pilih Quick Role]
      |
      v
[Dashboard Pengguna]
  ├── Ringkasan Status Reservasi (Pending / Approved / Rejected)
  ├── Agenda Terdekat Pengguna
  └── Tombol Akses Cepat: "Cari & Pesan Ruangan"
      |
      v
[Daftar & Pencarian Ruangan]
  ├── Filter: Tanggal, Rentang Jam, Kapasitas, Gedung, Fasilitas
  └── Klik Kartu Ruangan
      |
      v
[Detail Ruangan & Cek Ketersediaan]
  ├── Lihat Foto, Spesifikasi, Jam Operasional, Fasilitas
  ├── Tinjau Kalender Jadwal (Slot Kosong vs Terisi)
  └── Klik "Ajukan Reservasi Ruangan Ini"
      |
      v
[Formulir Pengajuan Reservasi]
  ├── Isi Data: Nama, Unit/Organisasi, Tujuan Kegiatan
  ├── Tentukan Tanggal, Jam Mulai & Jam Selesai
  ├── Masukkan Estimasi Jumlah Peserta (Validasi ≤ Kapasitas)
  ├── Opsi: Fasilitas Tambahan & Catatan
  └── Validasi Otomatis (Cek Bentrok Jadwal)
      |
      +---> [Jika Bentrok / Melebihi Kapasitas] ---> Tampilkan Pesan Error & Saran Waktu Lain
      |
      +---> [Jika Lolos Validasi] ---> Klik "Kirim Pengajuan"
      |
      v
[Konfirmasi Pengajuan Berhasil]
  ├── Diterbitkan Kode Booking Unik (contoh: RB-202609-001)
  └── Status Otomatis: "PENDING"
      |
      v
[Halaman 'Reservasi Saya']
  ├── Memantau Status Pengajuan
  ├── Menerima Notifikasi saat Admin Menyetujui atau Menolak
  └── Tombol "Batalkan Pengajuan" (sebelum waktu kegiatan dimulai)
```

---

## 2. Alur Administrator

```text
[Login sebagai Administrator]
      |
      v
[Dashboard Admin]
  ├── Statistik Utama: Total Ruangan Aktif, Pengajuan Pending, Approved Hari Ini
  ├── Kalender Penggunaan Ruangan Global
  └── Daftar Cepat "Pengajuan Menunggu Persetujuan"
      |
      v
[Daftar Pengajuan Reservasi (/admin/approvals)]
  ├── Filter status: Pending, Approved, Rejected, Cancelled
  └── Klik salah satu pengajuan
      |
      v
[Modal / Detail Pengajuan]
  ├── Verifikasi Identitas Pemesan & Organisasi
  ├── Periksa Jadwal, Tujuan, Kapasitas, dan Kebutuhan Fasilitas
  ├── Sistem memverifikasi ulang bentrok jadwal di backend
  │
  ├── [Opsi A: SETUJUI (Approve)]
  │     ├── Sistem mengubah status menjadi "APPROVED"
  │     ├── Slot terkunci dalam kalender publik
  │     ├── Catat log audit persetujuan
  │     └── Kirim notifikasi konfirmasi ke pemesan
  │
  └── [Opsi B: TOLAK (Reject)]
        ├── Admin mengisi "Alasan Penolakan" (Wajib)
        ├── Sistem mengubah status menjadi "REJECTED"
        ├── Catat log audit penolakan beserta alasan
        └── Kirim notifikasi pemberitahuan penolakan ke pemesan

[Menu Manajemen Ruangan (/admin/rooms)]
  ├── Tambah Ruangan Baru (Nama, Gedung, Lantai, Kapasitas, Fasilitas, Foto)
  ├── Edit Spesifikasi Ruangan
  ├── Nonaktifkan Ruangan Sementara
  └── Tetapkan Jadwal Pemeliharaan (Maintenance)
```
