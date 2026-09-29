# Database Documentation — RoomBook

**Dokumen:** Database Schema, Tables, Relations, and ERD  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  

---

## 1. Entity Relationship Diagram (ERD)

```text
+-------------------+              +----------------------+
|       users       | 1          * |     reservations     |
+-------------------+--------------+----------------------+
| id (PK)           |              | id (PK)              |
| name              |              | user_id (FK -> users)|
| email (Unique)    |              | room_id (FK -> rooms)|
| password_hash     |              | user_name            |
| role              |              | organization         |
| department        |              | start_time           |
| phone             |              | end_time             |
| created_at        |              | purpose              |
+-------------------+              | participant_count    |
        | 1                        | additional_facilities|
        |                          | notes                |
        | *                        | status               |
+-------------------+              | created_at           |
|   notifications   |              | updated_at           |
+-------------------+              +----------------------+
| id (PK)           |                         | 1
| user_id (FK)      |                         |
| reservation_id(FK)|                         | *
| message           |              +----------------------+
| is_read           |              |   reservation_logs   |
| created_at        |              +----------------------+
+-------------------+              | id (PK)              |
                                   | reservation_id (FK)  |
+-------------------+              | admin_id (FK -> users|
|       rooms       | 1          * | previous_status      |
+-------------------+--------------+ new_status           |
| id (PK)           |              | reason               |
| name              |              | created_at           |
| building          |              +----------------------+
| floor             |
| capacity          |
| facilities (JSON) |
| status            |
| opening_hour      |
| closing_hour      |
| image_url         |
| description       |
+-------------------+
        | 1
        |
        | *
+-----------------------+
|  room_unavailability  |
+-----------------------+
| id (PK)               |
| room_id (FK -> rooms) |
| start_time            |
| end_time              |
| reason                |
| created_at            |
+-----------------------+
```

---

## 2. Struktur Tabel & Atribut

### 2.1 Tabel `users`
Menyimpan akun pengguna dan administrator.
| Kolom | Tipe Data | Constraint | Keterangan |
|---|---|---|---|
| `id` | VARCHAR(36) | PRIMARY KEY | UUID v4 |
| `name` | VARCHAR(100) | NOT NULL | Nama lengkap pengguna |
| `email` | VARCHAR(100) | UNIQUE, NOT NULL | Alamat email (format institusi) |
| `password_hash` | VARCHAR(255) | NOT NULL | Hash kata sandi |
| `role` | VARCHAR(20) | NOT NULL | `ADMIN`, `MAHASISWA`, `DOSEN`, `STAF` |
| `department` | VARCHAR(100) | NULL | Fakultas / Departemen / Unit kerja |
| `phone` | VARCHAR(20) | NULL | Nomor kontak WhatsApp/telepon |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu pendaftaran |

### 2.2 Tabel `rooms`
Menyimpan data master ruangan dan fasilitasnya.
| Kolom | Tipe Data | Constraint | Keterangan |
|---|---|---|---|
| `id` | VARCHAR(36) | PRIMARY KEY | UUID v4 |
| `name` | VARCHAR(100) | NOT NULL | Nama ruangan (contoh: Lab Multimedia 1) |
| `building` | VARCHAR(100) | NOT NULL | Nama gedung (contoh: Gedung Rektorat Lt. 2) |
| `floor` | INTEGER | NOT NULL | Nomor lantai |
| `capacity` | INTEGER | NOT NULL | Kapasitas orang maksimal |
| `facilities` | TEXT / JSON | NOT NULL | Daftar fasilitas (Array string JSON) |
| `status` | VARCHAR(20) | DEFAULT 'ACTIVE' | `ACTIVE`, `INACTIVE`, `MAINTENANCE` |
| `opening_hour` | VARCHAR(5) | DEFAULT '08:00' | Jam buka operasional (HH:mm) |
| `closing_hour` | VARCHAR(5) | DEFAULT '17:00' | Jam tutup operasional (HH:mm) |
| `image_url` | TEXT | NULL | Tautan foto ruangan |
| `description` | TEXT | NULL | Keterangan tambahan |

### 2.3 Tabel `reservations`
Menyimpan pengajuan reservasi penggunaan ruangan.
| Kolom | Tipe Data | Constraint | Keterangan |
|---|---|---|---|
| `id` | VARCHAR(36) | PRIMARY KEY | UUID v4 / ID booking (contoh: RB-202609-001) |
| `user_id` | VARCHAR(36) | FOREIGN KEY -> users(id) | ID pengguna pemesan |
| `room_id` | VARCHAR(36) | FOREIGN KEY -> rooms(id) | ID ruangan yang dipesan |
| `user_name` | VARCHAR(100) | NOT NULL | Nama pemesan saat formulir disubmit |
| `organization`| VARCHAR(100) | NOT NULL | Himpunan/Unit/Organisasi/Prodi |
| `start_time` | TIMESTAMP | NOT NULL | Waktu mulai pemakaian |
| `end_time` | TIMESTAMP | NOT NULL | Waktu selesai pemakaian |
| `purpose` | TEXT | NOT NULL | Tujuan kegiatan pemakaian ruangan |
| `participant_count` | INTEGER | NOT NULL | Estimasi jumlah orang yang hadir |
| `additional_facilities` | TEXT | NULL | Kebutuhan tambahan (kabel rol, mic ekstra) |
| `notes` | TEXT | NULL | Catatan khusus |
| `status` | VARCHAR(20) | DEFAULT 'PENDING' | `PENDING`, `APPROVED`, `REJECTED`, `CANCELLED`, `COMPLETED` |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu pengajuan dibuat |
| `updated_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu pembaruan status terakhir |

### 2.4 Tabel `reservation_logs`
Mencatat seluruh rekam jejak riwayat audit persetujuan dan pembatalan.
| Kolom | Tipe Data | Constraint | Keterangan |
|---|---|---|---|
| `id` | VARCHAR(36) | PRIMARY KEY | UUID v4 |
| `reservation_id` | VARCHAR(36) | FOREIGN KEY -> reservations(id) | ID reservasi terkait |
| `admin_id` | VARCHAR(36) | FOREIGN KEY -> users(id) | Admin yang memutuskan (atau User jika dibatalkan sendiri) |
| `previous_status`| VARCHAR(20) | NOT NULL | Status sebelum perubahan |
| `new_status` | VARCHAR(20) | NOT NULL | Status sesudah perubahan |
| `reason` | TEXT | NULL | Alasan penolakan / catatan persetujuan |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu perubahan dicatat |

### 2.5 Tabel `room_unavailability`
Menyimpan jadwal pemeliharaan (*maintenance*) atau ruangan tidak dapat dipakai.
| Kolom | Tipe Data | Constraint | Keterangan |
|---|---|---|---|
| `id` | VARCHAR(36) | PRIMARY KEY | UUID v4 |
| `room_id` | VARCHAR(36) | FOREIGN KEY -> rooms(id) | ID ruangan |
| `start_time` | TIMESTAMP | NOT NULL | Waktu mulai penonaktifan |
| `end_time` | TIMESTAMP | NOT NULL | Waktu selesai penonaktifan |
| `reason` | TEXT | NOT NULL | Alasan (Renovasi AC, Perawatan Proyektor, dll) |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu penjadwalan dibuat |

### 2.6 Tabel `notifications`
Menyimpan pemberitahuan in-app ke pengguna.
| Kolom | Tipe Data | Constraint | Keterangan |
|---|---|---|---|
| `id` | VARCHAR(36) | PRIMARY KEY | UUID v4 |
| `user_id` | VARCHAR(36) | FOREIGN KEY -> users(id) | Pengguna penerima notifikasi |
| `reservation_id` | VARCHAR(36) | FOREIGN KEY -> reservations(id) | ID reservasi rujukan |
| `message` | TEXT | NOT NULL | Isi pesan notifikasi |
| `is_read` | BOOLEAN | DEFAULT FALSE | Status sudah dibaca |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu dikirimkan |

---

## 3. Query Deteksi Bentrok Jadwal (Conflict Detection)
Untuk memverifikasi apakah ada reservasi yang bentrok pada ruangan `X` untuk rentang waktu `[req_start, req_end]`:
```sql
SELECT * FROM reservations
WHERE room_id = :room_id
  AND status = 'APPROVED'
  AND (
    (start_time < :req_end) AND (end_time > :req_start)
  );
```
Jika hasil query mengembalikan ≥ 1 baris, maka jadwal bentrok dan pengajuan tidak dapat disetujui / dipesan.
