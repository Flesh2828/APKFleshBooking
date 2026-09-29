# RoomBook - Sistem Booking Ruangan Terpadu

> **Pengembangan Prototipe Aplikasi Booking Ruangan untuk Cek Ketersediaan, Reservasi, dan Persetujuan Penggunaan**  
> Versi: 1.0 (Prototype / MVP) | Platform: Web Application (Responsive: Desktop, Tablet, Mobile)

---

## 📌 Ringkasan Proyek

**RoomBook** adalah aplikasi web modern untuk mempermudah pengecekan ketersediaan ruangan, pengajuan reservasi, dan alur persetujuan penggunaan ruangan di lingkungan institusi (kampus, perkantoran, dan organisasi).

Masalah utama yang diselesaikan:
1. **Ketidakpastian Ketersediaan:** Pengguna tidak lagi kesulitan mencari ruangan kosong karena tersedia kalender ketersediaan real-time.
2. **Bentrok Jadwal:** Sistem secara otomatis memvalidasi jadwal agar tidak terjadi double-booking.
3. **Alur Persetujuan Lambat & Tersebar:** Administrator memiliki dashboard terpusat untuk meninjau dan menyetujui/menolak pengajuan dengan alasan yang transparan.
4. **Riwayat & Status Terpantau:** Pemesan mendapatkan ID pengajuan unik, notifikasi dalam aplikasi, dan pemantauan status langsung (*Pending*, *Approved*, *Rejected*, *Cancelled*, *Completed*).

---

## 🚀 Fitur Utama (MVP)

- 🔐 **Autentikasi & Role-Based Access Control (RBAC):**
  - **Pengguna (Mahasiswa / Dosen / Staf):** Mencari ruangan, cek ketersediaan, mengajukan pemesanan, melihat status & riwayat, membatalkan reservasi.
  - **Administrator:** Dashboard statistik, kelola data ruangan & fasilitas, kalender seluruh reservasi, verifikasi & persetujuan/penolakan dengan catatan/alasan penolakan.
- 🏢 **Katalog Ruangan:** Filter berdasarkan gedung/lokasi, kapasitas peserta, dan fasilitas (Proyektor, AC, Sound System, Smart TV, Whiteboard, dll).
- 📅 **Cek Ketersediaan Interaktif:** Kalender interaktif dan time-slot visual dengan indikator status (*Available*, *Pending*, *Booked*, *Unavailable/Maintenance*).
- 📝 **Formulir Reservasi Cerdas:** Validasi otomatis jam operasional gedung, kapasitas maksimum, dan bentrok dengan reservasi yang telah disetujui.
- ⚡ **Sistem Persetujuan & Log Audit:** Setiap aksi persetujuan divalidasi ulang untuk mencegah race condition, serta dicatat riwayat perubahannya ke log audit.
- 🔔 **Notifikasi Dalam Aplikasi:** Notifikasi real-time ketika reservasi disetujui, ditolak, atau dibatalkan.
- 📊 **Laporan & Statistik Penggunaan:** Grafik dan tabel frekuensi penggunaan ruangan, status pengajuan, serta ringkasan utilisasi.

---

## 🛠️ Tech Stack

- **Frontend & Backend:** [Next.js 14](https://nextjs.org/) (App Router, Server & Client Components, Route Handlers)
- **Bahasa:** [TypeScript](https://www.typescriptlang.org/)
- **Styling:** [Tailwind CSS](https://tailwindcss.com/)
- **Ikon:** [Lucide React](https://lucide.dev/)
- **Manajemen State & Database:** Prisma ORM / Relational Database (PostgreSQL / SQLite ready)
- **Deployment:** Vercel / Node.js Container

---

## 📂 Struktur Dokumen (`docs/`)

Dokumentasi lengkap proyek dapat ditemukan pada folder `docs/`:

1. [PRD.md](./PRD.md) — Product Requirements Document lengkap
2. [TECH_STACK.md](./TECH_STACK.md) — Detail teknologi dan alasan pemilihan
3. [ARCHITECTURE.md](./ARCHITECTURE.md) — Arsitektur sistem dan komunikasi data
4. [DATABASE.md](./DATABASE.md) — Skema database, tabel, relasi, dan ERD
5. [UI_UX_GUIDELINES.md](./UI_UX_GUIDELINES.md) — Panduan desain, warna, dan tipografi
6. [USER_FLOW.md](./USER_FLOW.md) — Alur pengguna dan administrator
7. [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) — Dokumentasi endpoint API
8. [FUNCTIONAL_REQUIREMENTS.md](./FUNCTIONAL_REQUIREMENTS.md) — Rincian kebutuhan fungsional
9. [SECURITY.md](./SECURITY.md) — Autentikasi, otorisasi, dan mitigasi keamanan
10. [TESTING.md](./TESTING.md) — Strategi pengujian & skenario acceptance criteria
11. [ROADMAP.md](./ROADMAP.md) — Roadmap pengembangan 6 minggu & masa depan
12. [CHANGELOG.md](./CHANGELOG.md) — Catatan rilis dan versi aplikasi
13. [CONTRIBUTING.md](./CONTRIBUTING.md) — Panduan kontribusi dan standar kode
14. [DEPLOYMENT.md](./DEPLOYMENT.md) — Panduan build dan deployment

---

## 💻 Panduan Menjalankan Aplikasi

### 1. Prasyarat
- Node.js versi 18.x atau lebih baru (disarankan Node.js 20+)
- npm / yarn / pnpm

### 2. Instalasi Dependensi
```bash
cd roombook
npm install
```

### 3. Konfigurasi Environment
Salin file `.env.example` menjadi `.env.local`:
```bash
cp .env.example .env.local
```

### 4. Menjalankan Server Development
```bash
npm run dev
```
Akses aplikasi melalui browser di: `http://localhost:3000`

### 5. Akun Demo untuk Pengujian Cepat
Aplikasi menyediakan akun demo bawaan dan tombol beralih akun (*Quick Role Switcher*):
- **Admin:** `admin@roombook.ac.id` (Password: `admin123`)
- **Dosen / Staf:** `dosen@roombook.ac.id` (Password: `dosen123`)
- **Mahasiswa:** `mahasiswa@roombook.ac.id` (Password: `mhs123`)
