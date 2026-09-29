# API Documentation — RoomBook

**Dokumen:** RESTful API Endpoints Specification  
**Aplikasi:** RoomBook — Sistem Booking Ruangan  
**Versi:** 1.0  
**Format Data:** JSON (`application/json`)  
**Base URL:** `/api`  

---

## 1. Authentication & Session

### 1.1 POST `/api/auth/login`
Melakukan otentikasi pengguna atau admin.

#### Opsi A: Login dengan Email & Password
**Request Body:**
```json
{
  "email": "admin@roombook.ac.id",
  "password": "admin123"
}
```

#### Opsi B: Login dengan Google Cloud Platform (GCP) SSO
**Request Body:**
```json
{
  "authMethod": "GCP_GOOGLE",
  "gcpProfile": {
    "name": "Sarah Wijaya, S.Kom",
    "email": "sarah.wijaya@campus.ac.id",
    "avatarUrl": "https://..."
  }
}
```

**Response Success (200 OK):**
```json
{
  "success": true,
  "message": "Login berhasil.",
  "authProvider": "EMAIL",
  "user": {
    "id": "usr-admin",
    "name": "Dr. Ir. Budi Santoso, M.Kom",
    "email": "admin@roombook.ac.id",
    "role": "ADMIN",
    "department": "Bagian Sarana & Prasarana Kampus"
  }
}
```

### 1.2 GET `/api/auth/me`
Mengambil data profil pengguna yang sedang login.

---

## 2. Ruangan (Rooms)

### 2.1 GET `/api/rooms`
Mengambil daftar ruangan dengan filter opsional.

**Query Parameters:**
- `search` (string, opsional): Nama ruangan atau gedung
- `building` (string, opsional): Filter gedung tertentu
- `minCapacity` (number, opsional): Kapasitas minimal
- `status` (string, opsional): `ACTIVE`, `INACTIVE`, `MAINTENANCE`

**Response (200 OK):**
```json
{
  "data": [
    {
      "id": "room-1",
      "name": "Auditorium Utama",
      "building": "Gedung Rektorat Lt. 3",
      "floor": 3,
      "capacity": 250,
      "facilities": ["Proyektor 4K", "Sound System 5000W", "AC Central", "Podium", "Mikrofon Wireless"],
      "status": "ACTIVE",
      "openingHour": "08:00",
      "closingHour": "18:00",
      "imageUrl": "https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80",
      "description": "Ruangan serbaguna untuk seminar nasional, simposium, dan wisuda."
    }
  ]
}
```

### 2.2 GET `/api/rooms/:id`
Mengambil detail spesifik satu ruangan.

### 2.3 POST `/api/rooms` *(Admin Only)*
Menambahkan data ruangan baru.

**Request Body:**
```json
{
  "name": "Ruang Rapat Senat",
  "building": "Gedung A Lt. 2",
  "floor": 2,
  "capacity": 30,
  "facilities": ["Smart TV 65 Inch", "AC Central", "Whiteboard", "Mic Meja"],
  "openingHour": "08:00",
  "closingHour": "17:00",
  "imageUrl": "/images/rooms/senat.jpg",
  "description": "Ruang rapat khusus pimpinan dan rapat komite."
}
```

### 2.4 PUT `/api/rooms/:id` *(Admin Only)*
Memperbarui data ruangan atau mengubah status aktif/nonaktif.

---

## 3. Cek Ketersediaan (Availability)

### 3.1 GET `/api/availability`
Mengecek slot waktu yang telah terisi atau ketersediaan ruangan pada tanggal tertentu.

**Query Parameters:**
- `roomId` (string, wajib): ID ruangan
- `date` (string, wajib, format `YYYY-MM-DD`): Tanggal yang ingin diperiksa

**Response (200 OK):**
```json
{
  "roomId": "room-1",
  "date": "2026-09-30",
  "openingHour": "08:00",
  "closingHour": "18:00",
  "bookedSlots": [
    {
      "reservationId": "RB-202609-001",
      "startTime": "2026-09-30T09:00:00.000Z",
      "endTime": "2026-09-30T11:30:00.000Z",
      "status": "APPROVED",
      "purpose": "Seminar Nasional AI"
    }
  ],
  "pendingSlots": [
    {
      "reservationId": "RB-202609-002",
      "startTime": "2026-09-30T13:00:00.000Z",
      "endTime": "2026-09-30T15:00:00.000Z",
      "status": "PENDING",
      "purpose": "Rapat BEM"
    }
  ],
  "maintenanceSlots": []
}
```

---

## 4. Reservasi (Reservations)

### 4.1 POST `/api/reservations`
Mengajukan reservasi penggunaan ruangan.

**Request Body:**
```json
{
  "roomId": "room-1",
  "userName": "Farhan Kurniawan",
  "organization": "BEM Fakultas Ilmu Komputer",
  "startTime": "2026-09-30T13:00:00.000Z",
  "endTime": "2026-09-30T15:00:00.000Z",
  "participantCount": 45,
  "purpose": "Rapat Kerja Tahunan Organisasi Mahasiswa",
  "additionalFacilities": "2 Pointer Presentasi, 1 Mic Wireless Tambahan",
  "notes": "Peserta hadir 15 menit sebelum acara dimulai."
}
```

**Response (201 Created):**
```json
{
  "success": true,
  "message": "Pengajuan reservasi berhasil dikirim dan menunggu persetujuan.",
  "data": {
    "id": "RB-202609-002",
    "status": "PENDING",
    "createdAt": "2026-09-29T09:00:00.000Z"
  }
}
```

**Response Conflict Error (409 Conflict):**
```json
{
  "success": false,
  "error": "Jadwal yang dipilih bentrok dengan reservasi yang telah disetujui sebelumnya."
}
```

### 4.2 GET `/api/reservations`
Mengambil daftar reservasi.
- Jika pengguna biasa: hanya mengembalikan reservasi milik pengguna tersebut.
- Jika administrator: mengembalikan seluruh reservasi dengan filter status (`PENDING`, `APPROVED`, `REJECTED`, dll).

### 4.3 PATCH `/api/reservations/:id/status` *(Admin / Owner)*
Memproses persetujuan, penolakan, atau pembatalan.

**Request Body (Approve by Admin):**
```json
{
  "status": "APPROVED",
  "reason": "Pengajuan disetujui sesuai permohonan."
}
```

**Request Body (Reject by Admin):**
```json
{
  "status": "REJECTED",
  "reason": "Ruangan sedang dipersiapkan untuk kegiatan akreditasi institusi."
}
```

**Request Body (Cancel by User):**
```json
{
  "status": "CANCELLED",
  "reason": "Kegiatan diundur oleh panitia pelaksana."
}
```

---

## 5. Notifikasi (Notifications)

### 5.1 GET `/api/notifications`
Mengambil daftar notifikasi pengguna yang sedang login.

### 5.2 PATCH `/api/notifications/:id/read`
Menandai notifikasi sebagai telah dibaca.
