# Architecture Documentation — RoomBook

**Dokumen:** System Architecture & Data Communication  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Arsitektur Tingkat Tinggi (High-Level Architecture)

RoomBook mengadopsi pola arsitektur **Clean Modular Client-Server Architecture** berbasis Next.js App Router, di mana frontend dan backend terintegrasi dalam satu runtime terpadu tanpa mengorbankan pemisahan tanggung jawab (*separation of concerns*).

```text
+-------------------------------------------------------------------------+
|                              CLIENT LAYER                               |
|        Browser (Desktop, Tablet, Smartphone) - Next.js React UI         |
+-------------------------------------------------------------------------+
                                    |
                                    | HTTPS / JSON Fetch API
                                    v
+-------------------------------------------------------------------------+
|                           APPLICATION LAYER                             |
|                        Next.js Route Handlers                           |
|  +-------------------+  +-------------------+  +---------------------+  |
|  |  Auth & Session   |  |   RBAC Guards     |  |   Input Validation  |  |
|  |    Middleware     |  | (Admin vs User)   |  |  (Time, Capacity)   |  |
|  +-------------------+  +-------------------+  +---------------------+  |
|                                   |                                     |
|  +-------------------------------------------------------------------+  |
|  |                         BUSINESS LOGIC                            |  |
|  | - Conflict Detector (Slot overlap validation)                     |  |
|  | - Operating Hours & Maintenance Checker                           |  |
|  | - Approval & Rejection Workflow State Machine                     |  |
|  | - Audit Logger & Notification Dispatcher                          |  |
|  +-------------------------------------------------------------------+  |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
|                            DATA ACCESS LAYER                            |
|                 Prisma ORM / Data Repository Client                     |
+-------------------------------------------------------------------------+
                                    |
                                    v
+-------------------------------------------------------------------------+
|                             PERSISTENCE LAYER                           |
|       Relational Database (PostgreSQL / SQLite Storage Engine)          |
|  - Users             - Reservations         - Unavailability            |
|  - Rooms             - Reservation Logs     - Notifications             |
+-------------------------------------------------------------------------+
```

---

## 2. Komponen Sistem & Alur Komunikasi

### 2.1 Lapisan Klien (Frontend Components)
1. **Layout & Shell:** Menyediakan sidebar navigasi, header status user aktif, role switcher, dan drawer notifikasi.
2. **Katalog & Filter Ruangan:** Mengambil data ruangan (`GET /api/rooms`), menerapkan filter lokal/server berdasarkan gedung, kapasitas, dan fasilitas.
3. **Kalender Ketersediaan:** Mengambil data reservasi yang disetujui dan jadwal maintenance (`GET /api/availability?roomId=...&date=...`), merender visual slot waktu.
4. **Formulir Reservasi:** Memvalidasi form di sisi browser (waktu mulai < waktu selesai, jumlah orang <= kapasitas), lalu mengirim payload ke `POST /api/reservations`.
5. **Panel Persetujuan Admin:** Menampilkan daftar reservasi pending, menyediakan dialog detail dan form alasan penolakan, memicu `PATCH /api/reservations/:id/status`.

### 2.2 Lapisan Bisnis & Validasi (Backend Logic)
1. **Autentikasi & Otorisasi:** Membaca sesi aktif. Endpoint admin (`/api/admin/*`, `/api/rooms [POST/PUT/DELETE]`, `/api/reservations/:id/status`) diproteksi khusus role `ADMIN`.
2. **Conflict Prevention Engine (Deteksi Bentrok):**
   - Melakukan query tumpang-tindih rentang waktu:
     $$\text{Start}_{\text{new}} < \text{End}_{\text{existing}} \quad \text{AND} \quad \text{End}_{\text{new}} > \text{Start}_{\text{existing}}$$
   - Mencegah bentrok dengan:
     - Reservasi berstatus `APPROVED` pada ruangan yang sama.
     - Jadwal pemeliharaan (`room_unavailability`) pada ruangan yang sama.
3. **Atomic Concurrency Protection:** Saat administrator menyetujui reservasi, sistem menjalankan transaksi basis data:
   - Mengunci dan memverifikasi kembali apakah slot masih kosong.
   - Mengubah status reservasi menjadi `APPROVED`.
   - Menambahkan catatan ke `reservation_logs`.
   - Mengirim notifikasi ke pemesan.
   - Menolak atau menandai otomatis pengajuan lain yang tumpang-tindih jika diperlukan.

---

## 3. Data Flow Diagram (DFD)

### Alur Reservasi Pengguna:
```text
[Pengguna] 
    ---> 1. Cek Ketersediaan Ruangan
    ---> 2. Isi Formulir Pemesanan
    ---> 3. Kirim Pengajuan (POST /api/reservations)
[Backend API]
    ---> 4. Validasi Kapasitas, Jam Operasional & Bentrok Jadwal
    ---> 5. Simpan Data dengan Status 'PENDING'
    ---> 6. Catat log awal ke reservation_logs
    ---> 7. Kirim Notifikasi Pengajuan Baru ke Admin
    ---> 8. Kembalikan ID Reservasi & Status ke Klien
```

### Alur Persetujuan Administrator:
```text
[Administrator]
    ---> 1. Buka Daftar Pengajuan Pending (GET /api/reservations?status=PENDING)
    ---> 2. Klik "Setujui" atau "Tolak" (disertai alasan)
[Backend API]
    ---> 3. Verifikasi Role Admin
    ---> 4. Validasi Ulang Bentrok Jadwal (Double-check)
    ---> 5. Update Status Reservasi ('APPROVED' / 'REJECTED')
    ---> 6. Insert Log ke reservation_logs (admin_id, prev_status, new_status, reason)
    ---> 7. Insert Notifikasi ke notifications (user_id, message, reservation_id)
    ---> 8. Kembalikan Status Sukses ke Klien
```
