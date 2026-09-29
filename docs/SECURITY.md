# Security Documentation — RoomBook

**Dokumen:** Authentication, Authorization, and Data Protection Standards  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Prinsip Keamanan Utama

RoomBook menerapkan prinsip **Defense in Depth** dengan pengamanan di beberapa lapisan:
1. **Server-Side Authorization:** Hak akses tidak hanya dibatasi di UI (menyembunyikan tombol), namun divalidasi ketat di setiap Route Handler API.
2. **Input Sanitization & Validation:** Semua payload JSON dibersihkan dari karakter berbahaya dan divalidasi tipe serta batasannya.
3. **Data Isolation:** Pengguna reguler hanya dapat mengakses dan mengelola reservasi dengan `user_id` miliknya sendiri.
4. **Audit Trail Immutability:** Riwayat persetujuan, penolakan, dan pembatalan disimpan di tabel log audit yang tidak dapat dihapus melalui antarmuka reguler.

---

## 2. Autentikasi dan Manajemen Sesi

- **Metode 1 — Kredensial Email & Kata Sandi Institusi:**
  - Pengguna memasukkan alamat email institusi dan kata sandi.
  - Kata sandi diverifikasi dengan enkripsi satu arah yang aman (*bcrypt/argon2*) dan proteksi brute-force.
- **Metode 2 — Single Sign-On (SSO) Google Cloud Platform (GCP) / Google Workspace:**
  - Terintegrasi dengan Google Cloud Identity / Google Workspace Domain `@campus.ac.id`.
  - Menggunakan protokol OAuth 2.0 / OpenID Connect dengan client ID dan secret aman dari Google Cloud Console.
  - Sesi diautentikasi secara terpusat dengan token yang ditandatangani oleh Google.
- **Manajemen Sesi:**
  - Sesi disimpan secara terproteksi di storage/cookie dengan verifikasi identitas di setiap interaksi API.
  - Fitur Logout mengakhiri sesi aktif dan membersihkan seluruh token autentikasi.

---

## 3. Role-Based Access Control (RBAC) Matrix

| Endpoint / Operasi | Mahasiswa | Dosen / Staf | Administrator |
|---|---|---|---|
| Lihat Katalog Ruangan & Ketersediaan | Ya | Ya | Ya |
| Ajukan Reservasi Ruangan | Ya | Ya | Ya |
| Batalkan Reservasi Milik Sendiri | Ya | Ya | Ya |
| Lihat Reservasi Pengguna Lain | Tidak | Tidak | Ya |
| Setujui / Tolak Pengajuan Reservasi | Tidak | Tidak | Ya |
| Tambah / Edit / Nonaktifkan Ruangan | Tidak | Tidak | Ya |
| Jadwalkan Pemeliharaan Ruangan | Tidak | Tidak | Ya |
| Unduh Laporan Seluruh Reservasi | Tidak | Tidak | Ya |

---

## 4. Pencegahan Kerentanan Web (OWASP Top 10)

### 4.1 SQL Injection
- Seluruh interaksi basis data dilakukan melalui parameterized query via Prisma ORM / prepared statements. Tidak ada perangkaian string mentah (*raw string concatenation*).

### 4.2 Cross-Site Scripting (XSS)
- React secara bawaan melakukan *auto-escaping* pada semua konten yang dirender ke DOM.
- Teks tujuan kegiatan, catatan, dan alasan penolakan disanitasi sebelum ditampilkan.

### 4.3 Cross-Site Request Forgery (CSRF)
- Endpoint mutasi (POST, PUT, PATCH, DELETE) dilindungi dengan SameSite cookie policy dan verifikasi header Origin/Referer.

### 4.4 Race Condition & Concurrency Overbooking
- Pengecekan bentrok jadwal dilakukan di dalam blok transaksi database. Jika ada dua pengguna mengajukan waktu yang sama atau admin menyetujui dua pemesanan bertabrakan, transaksi kedua akan ditolak secara atomik.

---

## 5. Perlindungan Privasi Data Pengguna
- Nomor telepon dan email pengguna hanya dapat diakses oleh Administrator untuk keperluan konfirmasi darurat kegiatan.
- Data reservasi lama tetap diarsipkan dengan status `COMPLETED` untuk transparansi audit tanpa mengekspos data pribadi ke publik.
