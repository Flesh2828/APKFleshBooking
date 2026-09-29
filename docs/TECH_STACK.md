# Tech Stack Documentation — RoomBook

**Dokumen:** Technology & Architecture Selection  
**Aplikasi:** RoomBook — Sistem Booking Ruangan Terpadu  
**Versi:** 1.0  

---

## 1. Ringkasan Teknologi

RoomBook dibangun menggunakan arsitektur monorepo terpadu berbasis **TypeScript** di sisi frontend dan backend, memberikan konsistensi tipe (*type-safety*) dari database hingga komponen UI.

| Komponen | Pilihan Teknologi | Alasan Pemilihan |
|---|---|---|
| **Bahasa Utama** | **TypeScript** | Memastikan kejelasan tipe data, mengurangi bug runtime, mempermudah refactoring dan kolaborasi tim. |
| **Framework Web** | **Next.js 14 (App Router)** | Full-stack framework dengan Server Components, Route Handlers (API), SSR/SSG, dan optimalisasi aset otomatis. |
| **UI Library** | **React 18** | Ekosistem komponen deklaratif yang matang, modular, dan reaktif. |
| **Styling** | **Tailwind CSS** | Utility-first CSS framework untuk pembuatan antarmuka responsif modern, cepat, dan konsisten. |
| **Desain & Komponen** | **shadcn/ui & Radix UI primitives** | Komponen UI aksesibel, modular, dan mudah dikustomisasi sesuai tema institusi. |
| **Ikon Antarmuka** | **Lucide React** | Ikon vektor modern, ringan, dan memiliki cakupan lengkap untuk navigasi dan status. |
| **Format Tanggal** | **date-fns** | Library manipulasi tanggal fungsional, ringan, dan mendukung lokalisasi tanggal Indonesia. |
| **Database** | **PostgreSQL / SQLite** | Relational database ACID-compliant untuk integritas transaksi pemesanan dan pencegahan bentrok. |
| **ORM** | **Prisma ORM** | Object-Relational Mapping dengan skema deklaratif, migrasi otomatis, dan auto-generated client bertipe kuat. |
| **Autentikasi & RBAC** | **Auth.js / NextAuth / Custom Session** | Autentikasi sesi berbasis cookie/JWT dan verifikasi role di middleware dan server route handler. |
| **Deployment** | **Vercel / Docker Container** | Standar industri untuk hosting Next.js dengan CI/CD otomatis dan performa CDN edge global. |

---

## 2. Rincian Lapisan Arsitektur

### 2.1 Lapisan Presentasi (Frontend)
- **Framework:** Next.js App Router (`src/app`)
- **Fitur Frontend:**
  - Layout dinamis dengan Sidebar, Header, Breadcrumbs, dan Quick Role Switcher.
  - Komponen Kalender Ketersediaan (Monthly, Weekly, Day views) dengan indikator warna status.
  - Formulir Reservasi dengan validasi instan (jam operasional, kapasitas, jam bentrok).
  - Modal Interaktif untuk Persetujuan (*Approval*) dan Penolakan (*Rejection with Reason*).
  - Toast Notification dan Live Counter untuk pengajuan pending.

### 2.2 Lapisan Bisnis & API (Backend)
- **Route Handlers:** Next.js Route Handlers (`src/app/api/...`)
- **Tanggung Jawab:**
  - Validasi schema request (input sanitization, time comparison).
  - Business rules engine: verifikasi operasional, batas kapasitas, deteksi tumpang-tindih waktu (*interval overlap query*).
  - State machine status: `PENDING` ➔ `APPROVED` / `REJECTED` / `CANCELLED` ➔ `COMPLETED`.
  - Log audit otomatis setiap kali terjadi perubahan status.
  - Pembuatan notifikasi in-app untuk pengguna terkait.

### 2.3 Lapisan Data (Database & ORM)
- **Database Engine:** PostgreSQL (Production) / SQLite (Development & Local Zero-Config).
- **ORM:** Prisma Client untuk query bertipe.
- **Transaksi:** Dukungan atomic transaction (`prisma.$transaction`) untuk memastikan tidak ada dua pemesanan yang disetujui pada slot waktu yang sama (*concurrency lock*).

---

## 3. Library & Dependensi Tambahan
- `lucide-react`: Ikon visual responsif
- `date-fns`: Parsing, perbandingan rentang waktu (`isWithinInterval`, `areIntervalsOverlapping`)
- `clsx` & `tailwind-merge`: Utility penggabungan kelas styling dinamis (`cn()`)
