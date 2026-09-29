# Panduan Implementasi Flutter + Supabase + Edge Functions

Dokumentasi ini menjelaskan arsitektur dan langkah deployment untuk aplikasi Room Booking (**RoomBook**) menggunakan stack:
- **Frontend**: Flutter (Android, iOS, Web)
- **Backend / Database**: Supabase (PostgreSQL, Supabase Auth, Realtime, RLS)
- **Serverless Business Logic**: Supabase Edge Functions (Deno / TypeScript)

---

## 1. Arsitektur Sistem

```
┌────────────────────────────────────────────────────────┐
│             Flutter Mobile App (Dart)                  │
│   (UI, Local State, Supabase SDK, Realtime Stream)     │
└──────────────┬──────────────────────────▲──────────────┘
               │ (1) Invoke Function      │ (4) Realtime Stream
               │     create-reservation   │     (Rooms & Status)
               ▼                          │
┌───────────────────────────────┐         │
│    Supabase Edge Functions    │         │
│        (Deno / TS)            │         │
│  - Conflict Collision Check   │         │
│  - Business Validation        │         │
│  - Generate Unique ID         │         │
└──────────────┬────────────────┘         │
               │ (2) Atomic Insert        │
               ▼                          │
┌─────────────────────────────────────────┴──────────────┐
│                  Supabase (PostgreSQL)                 │
│  - RLS (Row Level Security)                            │
│  - Realtime Publication (rooms, reservations)          │
│  - Auth (users & profiles)                             │
└────────────────────────────────────────────────────────┘
```

---

## 2. Struktur Direktori Baru

```
APKFleshBooking/
├── supabase/
│   ├── schema.sql                           # Skema PostgreSQL lengkap + RLS + Triggers
│   └── functions/
│       ├── create-reservation/index.ts      # Edge function validasi bentrok jadwal
│       └── approve-reservation/index.ts     # Edge function persetujuan admin & audit trail
│
└── mobile_flutter/
    ├── pubspec.yaml                         # Dependensi (supabase_flutter, intl, dll.)
    └── lib/
        ├── main.dart                        # Inisialisasi Supabase
        ├── models/
        │   ├── room_model.dart              # Model Ruangan
        │   └── reservation_model.dart       # Model Reservasi
        ├── services/
        │   └── supabase_service.dart        # Service Auth, Realtime & Edge Functions
        └── screens/
            ├── login_screen.dart            # Layar Login Supabase Auth
            ├── room_list_screen.dart        # Daftar Ruangan (Stream Realtime)
            └── booking_form_screen.dart     # Form Booking memanggil Edge Function
```

---

## 3. Langkah Instalasi & Menjalankan

### A. Setup Supabase
1. Buat project baru di [supabase.com](https://supabase.com).
2. Buka **SQL Editor** di Dashboard Supabase, lalu jalankan script yang ada di `supabase/schema.sql`.
3. Pasang Supabase CLI di komputer Anda (opsional untuk deploy functions):
   ```bash
   npm install -g supabase
   supabase login
   supabase link --project-ref <your-project-ref>
   ```
4. Deploy Edge Functions:
   ```bash
   supabase functions deploy create-reservation --no-verify-jwt
   supabase functions deploy approve-reservation --no-verify-jwt
   ```

### B. Konfigurasi Flutter
1. Buka file `mobile_flutter/lib/main.dart`.
2. Ubah `url` dan `anonKey` dengan kredensial dari Dashboard Supabase (*Project Settings -> API*).
3. Jalankan aplikasi Flutter:
   ```bash
   cd mobile_flutter
   flutter pub get
   flutter run
   ```
