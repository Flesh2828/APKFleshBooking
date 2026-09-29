# Functional Requirements Document — RoomBook

**Dokumen:** Detailed Functional Requirements  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Modul Autentikasi dan Hak Akses (FR-01)
- **FR-01.1:** Sistem harus menyediakan fitur login menggunakan email dan kata sandi.
- **FR-01.2:** Sistem harus mendukung sesi pengguna dengan verifikasi role (`ADMIN`, `MAHASISWA`, `DOSEN`, `STAF`).
- **FR-01.3:** Pengguna non-admin hanya berhak melihat, membuat, dan membatalkan reservasi miliknya sendiri.
- **FR-01.4:** Administrator berhak mengelola seluruh master data ruangan, melihat seluruh reservasi, dan melakukan aksi persetujuan/penolakan.
- **FR-01.5:** Sistem harus menyediakan fitur logout yang menghapus sesi aktif.

---

## 2. Modul Dashboard (FR-02)
- **FR-02.1:** Dashboard Pengguna harus menampilkan counter pengajuan *Pending*, *Approved*, *Rejected*, serta daftar reservasi terdekat pengguna.
- **FR-02.2:** Dashboard Administrator harus menampilkan total ruangan aktif, total pengajuan *Pending* yang perlu diproses, jumlah reservasi yang disetujui, dan agenda pemakaian ruangan hari ini.
- **FR-02.3:** Dashboard harus menyediakan pintasan cepat ke fungsi pencarian ruangan dan persetujuan pengajuan.

---

## 3. Modul Katalog dan Cek Ketersediaan Ruangan (FR-03)
- **FR-03.1:** Sistem harus menampilkan daftar ruangan aktif beserta informasi: foto, nama, gedung, lantai, kapasitas maksimum, jam operasional, dan daftar fasilitas.
- **FR-03.2:** Sistem harus menyediakan filter pencarian berdasarkan teks nama ruangan/gedung, kapasitas minimal, serta pilihan fasilitas.
- **FR-03.3:** Sistem harus menyediakan tampilan kalender jadwal untuk setiap ruangan dengan slot per jam.
- **FR-03.4:** Sistem harus menampilkan indikator status slot waktu:
  - `Available` (Slot kosong, dapat diajukan)
  - `Pending` (Sedang diajukan oleh pengguna lain namun belum disetujui)
  - `Booked` (Telah disetujui / terkunci)
  - `Maintenance` (Sedang dalam masa pemeliharaan ruangan)

---

## 4. Modul Pengajuan Reservasi (FR-04)
- **FR-04.1:** Formulir reservasi wajib memuat field:
  - Nama Pemesan (Teks, Wajib)
  - Unit / Organisasi / Prodi (Teks, Wajib)
  - Pilihan Ruangan (Dropdown/Card, Wajib)
  - Tanggal Penggunaan (Datepicker, Wajib)
  - Waktu Mulai & Waktu Selesai (Timepicker, Wajib)
  - Jumlah Peserta (Angka, Wajib)
  - Tujuan Penggunaan (Teks/Area, Wajib)
  - Fasilitas Tambahan (Teks/Pilihan, Opsional)
  - Catatan Khusus (Teks/Area, Opsional)
- **FR-04.2:** Sistem harus memvalidasi bahwa waktu selesai lebih besar dari waktu mulai.
- **FR-04.3:** Sistem harus menolak pengajuan jika jumlah peserta melebihi kapasitas ruangan.
- **FR-04.4:** Sistem harus memvalidasi bahwa waktu reservasi berada dalam jam operasional ruangan.
- **FR-04.5:** Sistem harus menolak pengajuan jika jadwal berbenturan (*overlap*) dengan reservasi yang berstatus `APPROVED` atau jadwal pemeliharaan.
- **FR-04.6:** Setiap pengajuan yang berhasil disimpan otomatis memperoleh ID unik (contoh: `RB-202609-XXX`) dan berstatus awal `PENDING`.

---

## 5. Modul Persetujuan & Penolakan Reservasi (FR-05)
- **FR-05.1:** Administrator dapat membuka daftar antrean pengajuan berstatus `PENDING`.
- **FR-05.2:** Administrator dapat melihat rincian pemesan, organisasi, keperluan acara, dan jadwal.
- **FR-05.3:** Administrator dapat menyetujui (*Approve*) pengajuan. Saat disetujui, sistem memvalidasi ulang ketersediaan slot waktu untuk mencegah bentrok akibat aksi bersamaan.
- **FR-05.4:** Administrator dapat menolak (*Reject*) pengajuan dengan wajib mengisi alasan penolakan.
- **FR-05.5:** Sistem wajib mencatat setiap perubahan status ke tabel audit log (`reservation_logs`) beserta nama admin dan timestamp.

---

## 6. Modul Status, Riwayat, dan Notifikasi (FR-06)
- **FR-06.1:** Pengguna dapat melihat daftar seluruh pengajuan miliknya beserta status terkini (`PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`, `COMPLETED`).
- **FR-06.2:** Pengguna dapat melihat alasan penolakan jika pengajuannya ditolak oleh administrator.
- **FR-06.3:** Pengguna dapat membatalkan pengajuan miliknya yang belum selesai/berlangsung.
- **FR-06.4:** Sistem mengirimkan notifikasi dalam aplikasi ke pemesan setiap kali terjadi perubahan status reservasi.
- **FR-06.5:** Pengguna dapat menandai notifikasi sebagai telah dibaca (*mark as read*).

---

## 7. Modul Manajemen Ruangan oleh Admin (FR-07)
- **FR-07.1:** Administrator dapat menambahkan ruangan baru dengan atribut nama, gedung, lantai, kapasitas, fasilitas, jam buka/tutup, deskripsi, dan URL foto.
- **FR-07.2:** Administrator dapat menyunting informasi ruangan yang sudah ada.
- **FR-07.3:** Administrator dapat mengubah status operasional ruangan (`ACTIVE`, `INACTIVE`, `MAINTENANCE`).
- **FR-07.4:** Menonaktifkan ruangan tidak boleh menghapus data riwayat reservasi yang telah tercatat sebelumnya.
