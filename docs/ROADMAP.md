# Development Roadmap — RoomBook

**Dokumen:** Project Timeline, Milestones, and Future Enhancements  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Timeline Pengembangan MVP (6 Minggu)

```text
Minggu 1: Requirement & UI/UX Design
  ├── Finalisasi PRD, ERD, dan arsitektur sistem
  ├── Desain wireframe & panduan UI/UX (Tailwind + shadcn)
  └── Persetujuan spesifikasi modul

Minggu 2: Setup Lingkungan & Database
  ├── Inisialisasi Next.js 14, TypeScript, Tailwind CSS
  ├── Konfigurasi basis data, migrasi skema tabel, dan seeder data ruangan
  └── Pembuatan lapisan model & autentikasi role pengguna

Minggu 3: Fitur Utama (Core Features)
  ├── Katalog ruangan dengan pencarian & multi-filter
  ├── Kalender ketersediaan interaktif per ruangan
  └── Dashboard pengguna dan dashboard admin

Minggu 4: Reservasi & Alur Persetujuan (Reservation & Approval)
  ├── Formulir reservasi dengan validasi bentrok jadwal real-time
  ├── Panel admin untuk persetujuan (Approve) & penolakan dengan alasan
  └── Sistem notifikasi in-app dan pencatatan audit log

Minggu 5: Integrasi & Pengujian Menyeluruh (Integration & Testing)
  ├── Pengujian end-to-end skenario bentrok jadwal
  ├── Optimasi performa dan audit responsivitas mobile/tablet
  └── Perbaikan bug & penghalusan animasi micro-interactions

Minggu 6: Deployment & Evaluasi (Deployment & Evaluation)
  ├── Setup environment variables & deployment build di Vercel / server
  ├── User Acceptance Testing (UAT) bersama perwakilan mahasiswa & admin
  └── Dokumentasi final dan serah terima prototipe
```

---

## 2. Rencana Pengembangan Masa Depan (Post-MVP)

1. **Integrasi Kalender Eksternal:**
   - Ekspor otomatis ke Google Calendar dan Microsoft Outlook via file `.ics` atau OAuth sync.
2. **Notifikasi WhatsApp & Email:**
   - Pengiriman otomatis tiket booking dan notifikasi persetujuan via WhatsApp Gateway dan SMTP email.
3. **Check-in Berbasis QR Code:**
   - Pemesan memindai QR Code di depan pintu ruangan saat mulai menggunakan, dan check-out saat selesai. Ruangan otomatis dibatalkan jika pemesan tidak check-in dalam 15 menit.
4. **Persetujuan Bertingkat (Multi-tier Approval):**
   - Mendukung alur persetujuan bertingkat untuk ruangan khusus (misal: Ketua Jurusan ➔ Dekan ➔ Bagian Sarana Prasarana).
5. **Analitik Lanjutan:**
   - Heatmap jam-jam sibuk, prediksi kebutuhan ruangan, dan laporan utilisasi ruang per semester.
