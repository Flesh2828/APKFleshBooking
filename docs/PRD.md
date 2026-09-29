# Product Requirements Document (PRD) — RoomBook

**Judul Proyek:** Pengembangan Prototipe Aplikasi Booking Ruangan untuk Cek Ketersediaan, Reservasi, dan Persetujuan Penggunaan  
**Versi:** 1.0 (Prototype / MVP) | Web Application  
**Target Pengguna:** Mahasiswa, Dosen, Staf, dan Administrator  

---

## 1. Informasi Produk
- **Nama Produk:** RoomBook
- **Jenis Produk:** Aplikasi pemesanan dan manajemen ruangan terpusat
- **Platform:** Web responsif: desktop, tablet, dan smartphone
- **Tujuan:** Mempermudah pengecekan ketersediaan, reservasi, dan persetujuan penggunaan ruangan secara transparan, akurat, dan bebas bentrok jadwal.
- **Status:** Versi 1.0 (MVP)

---

## 2. Latar Belakang & Permasalahan
Penggunaan ruangan untuk kegiatan akademik, rapat organisasi, seminar, maupun perkuliahan tambahan memerlukan sistem pemesanan yang terorganisasi. Proses manual melalui pesan instan, formulir kertas, atau komunikasi lisan menimbulkan:
- Informasi ketersediaan yang tidak akurat.
- Risiko bentrok jadwal (*double-booking*).
- Proses persetujuan yang lambat dan birokrasi berbelit.
- Status pengajuan yang tidak terlacak oleh pemesan.
- Data riwayat penggunaan ruangan yang tersebar dan tidak terdokumentasi.

---

## 3. Tujuan Produk
1. Mempermudah pencarian dan filter ruangan berdasarkan tanggal, waktu, kapasitas, lokasi/gedung, dan fasilitas.
2. Menyederhanakan proses reservasi melalui formulir digital terstruktur.
3. Menghilangkan risiko bentrok jadwal melalui validasi otomatis di frontend dan backend.
4. Menyediakan alur persetujuan reservasi yang cepat dan transparan bagi admin.
5. Meningkatkan transparansi status dan notifikasi perubahan status.
6. Memusatkan data ruangan, reservasi, dan laporan pemakaian.

---

## 4. Persona Pengguna
| Persona | Kebutuhan Utama |
|---|---|
| **Mahasiswa** | Memesan ruangan untuk rapat organisasi, diskusi, belajar kelompok, acara kampus; memantau status persetujuan. |
| **Dosen & Staf** | Memesan ruangan untuk perkuliahan pengganti, rapat departemen, seminar, dan kegiatan institusi. |
| **Administrator** | Mengelola master data ruangan, memvalidasi dan memutuskan pengajuan (Setuju/Tolak), memantau kalender jadwal, mencetak laporan. |

---

## 5. Ruang Lingkup MVP

### 5.1 Fitur Must Have
- **Login dan Autentikasi:** Hak akses berbasis role (Pengguna: Mahasiswa/Dosen/Staf vs Admin).
- **Dashboard:** Ringkasan statistik reservasi, pengajuan pending, dan agenda terdekat.
- **Daftar & Detail Ruangan:** Informasi kapasitas, gedung, fasilitas, foto, jam operasional, status ruangan.
- **Cek Ketersediaan:** Tampilan kalender dan time-slot dengan status Available, Pending, Booked, Maintenance.
- **Reservasi Ruangan:** Formulir pengajuan dengan validasi kapasitas, jam operasional, dan bentrok jadwal.
- **Persetujuan Reservasi:** Administrator dapat menyetujui (*Approve*) atau menolak (*Reject*) disertai alasan penolakan.
- **Status Reservasi:** Pelacakan status (*Pending*, *Approved*, *Rejected*, *Cancelled*, *Completed*).
- **Manajemen Ruangan:** Admin dapat menambah, mengubah, menonaktifkan ruangan, dan menjadwalkan maintenance.

### 5.2 Fitur Should Have
- **Riwayat Reservasi:** Daftar riwayat pemesanan terdahulu dengan filter tanggal dan status.
- **Notifikasi Dalam Aplikasi:** Notifikasi otomatis saat status pengajuan disetujui, ditolak, atau dibatalkan.
- **Laporan Penggunaan:** Ringkasan statistik penggunaan ruangan dan frekuensi pemakaian.

### 5.3 Di Luar Ruang Lingkup (Future Scope)
- Integrasi Google Calendar / Outlook
- Notifikasi SMS / WhatsApp Gateway
- QR Code Check-in / Check-out fisik
- Integrasi Payment Gateway sewa ruangan komersial
- Sistem rekomendasi ruangan berbasis AI

---

## 6. Business Rules
1. Pengguna wajib login untuk membuat reservasi.
2. Pengajuan wajib mencantumkan tujuan pemesanan dan jadwal penggunaan.
3. Reservasi hanya dapat diajukan untuk ruangan yang berstatus aktif.
4. Waktu selesai reservasi harus lebih besar dari waktu mulai.
5. Jumlah peserta tidak boleh melebihi kapasitas maksimum ruangan.
6. Jadwal reservasi harus berada di dalam jam operasional ruangan.
7. Sistem menolak pemesanan yang bentrok dengan jadwal yang sudah *Approved* atau masa pemeliharaan (*Maintenance*).
8. Status awal setiap pengajuan baru adalah *Pending*.
9. Administrator wajib mengisi alasan penolakan jika menolak pengajuan.
10. Persetujuan admin divalidasi ulang untuk mencegah pemrosesan bersamaan (*race condition*).
11. Setiap perubahan status dicatat ke dalam log audit (`reservation_logs`).
12. Pengguna dapat membatalkan reservasi miliknya yang berstatus *Pending* atau *Approved* sebelum waktu mulai.

---

## 7. KPI & Metrik Keberhasilan
- Keberhasilan pengajuan reservasi: ≥ 95%
- Pencegahan konflik jadwal: 100% untuk bentrok yang terdeteksi sistem
- Waktu rata-rata membuat reservasi: ≤ 3 menit
- Waktu muat halaman utama: ≤ 3 detik
- Kepuasan pengguna uji: ≥ 4 dari 5
