# UI/UX Guidelines — RoomBook

**Dokumen:** Design System, Typography, Colors, and Interaction Guidelines  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Filosofi Desain
RoomBook didesain dengan prinsip **Modern Minimalist, High Contrast, and Task-Oriented Efficiency**.  
Tujuan utama pengalaman pengguna adalah:
- **Zero Confusion:** Pengguna dapat mengetahui ketersediaan ruangan hanya dalam hitungan detik.
- **Micro-friction Booking:** Formulir reservasi ringkas, jelas, dengan feedback validasi langsung (*real-time inline validation*).
- **Executive Clarity:** Administrator dapat memutuskan persetujuan dengan informasi lengkap di satu layar tanpa perlu berpindah-pindah tab.

---

## 2. Palet Warna (Color Palette)

Aplikasi menggunakan palet warna kurasi modern berbasis nuansa Slate, Emerald, Amber, Rose, dan Indigo:

| Peran Warna | Hex / Tailwind Token | Penerapan dalam UI |
|---|---|---|
| **Primary Brand** | `#4F46E5` (`indigo-600`) | Header navigasi aktif, tombol submit utama, link aksen |
| **Primary Hover** | `#4338CA` (`indigo-700`) | Hover state tombol utama |
| **Available (Tersedia)** | `#10B981` (`emerald-500`) | Badge status ruangan aktif, slot waktu kosong |
| **Pending (Menunggu)** | `#F59E0B` (`amber-500`) | Badge pengajuan yang sedang menunggu persetujuan admin |
| **Booked / Approved** | `#3B82F6` (`blue-500`) | Slot waktu yang sudah terisi dan terkonfirmasi |
| **Rejected / Danger** | `#EF4444` (`red-500`) | Badge ditolak, aksi pembatalan, tombol hapus |
| **Maintenance / Inactive**| `#64748B` (`slate-500`) | Badge pemeliharaan, slot waktu tidak dapat dipesan |
| **Background Light** | `#F8FAFC` (`slate-50`) | Latar belakang kanvas aplikasi |
| **Card Surface** | `#FFFFFF` (`white`) | Panel kartu, modal dialog, formulir input |
| **Border & Divider** | `#E2E8F0` (`slate-200`) | Garis tepi kartu, pemisah tabel, field input |
| **Text Primary** | `#0F172A` (`slate-900`) | Judul halaman, teks penekanan utama |
| **Text Secondary** | `#64748B` (`slate-500`) | Keterangan pembantu, placeholder, label waktu |

---

## 3. Tipografi (Typography)
- **Font Utama:** `Inter`, `system-ui`, `-apple-system`, `sans-serif`
- **Hierarki Font:**
  - `H1` (Judul Halaman): `24px / 1.5rem`, `font-bold`, `tracking-tight`
  - `H2` (Subjudul / Nama Ruangan): `18px / 1.125rem`, `font-semibold`
  - `Body Regular`: `14px / 0.875rem`, `font-normal`
  - `Caption / Badges`: `12px / 0.75rem`, `font-medium`

---

## 4. Komponen Desain Kunci

### 4.1 Status Badge
Setiap status reservasi memiliki visual badge yang khas:
- `PENDING`: Background kuning muda (`bg-amber-50 text-amber-700 border-amber-200`) dengan ikon Jam (*Clock*).
- `APPROVED`: Background hijau muda (`bg-emerald-50 text-emerald-700 border-emerald-200`) dengan ikon Centang (*CheckCircle2*).
- `REJECTED`: Background merah muda (`bg-rose-50 text-rose-700 border-rose-200`) dengan ikon Silang (*XCircle*).
- `CANCELLED`: Background abu-abu (`bg-slate-100 text-slate-600 border-slate-200`) dengan ikon Batalkan (*Ban*).

### 4.2 Kalender & Slot Waktu Ketersediaan
- Kalender menampilkan penanda tanggal yang memiliki reservasi.
- Tampilan detail hari menyajikan pembagian per jam (08:00 - 17:00).
- Setiap blok jam diwarnai sesuai status: Hijau (Bebas/Available), Biru (Terisi/Booked), Abu-abu Gelap (Maintenance).

### 4.3 Formulir Reservasi & Deteksi Bentrok
- Pemilihan waktu mulai dan waktu selesai secara interaktif.
- Peringatan instan jika:
  - Waktu selesai ≤ waktu mulai.
  - Jumlah peserta > kapasitas ruangan.
  - Waktu berada di luar jam operasional ruangan.
  - Waktu bertabrakan dengan reservasi `APPROVED` lainnya.

### 4.4 Responsivitas (Mobile, Tablet, Desktop)
- **Desktop (≥ 1024px):** Sidebar permanen di sebelah kiri, layout multi-kolom untuk katalog dan detail.
- **Tablet (768px - 1023px):** Sidebar collapsible atau top navigation bar dengan tap targets yang lega.
- **Mobile (< 768px):** Hamburger drawer menu, kartu ruangan full-width bertumpuk vertikal, sticky bottom action bar untuk tombol "Pesan Sekarang".
