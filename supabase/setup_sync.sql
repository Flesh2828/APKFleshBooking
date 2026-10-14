-- ==============================================================================
-- SQL SETUP SINKRONISASI FLUTTER MOBILE & WEBSITE ADMIN (SUPABASE)
-- Jalankan query ini di Supabase Dashboard -> SQL Editor
-- Link: https://supabase.com/dashboard/project/wmtdckxqsgjmuwvikleb/sql
-- ==============================================================================

-- 1. Hapus tabel lama yang masih bertipe UUID (kosongkan struktur lama)
DROP TABLE IF EXISTS public.reservations CASCADE;
DROP TABLE IF EXISTS public.rooms CASCADE;

-- 2. Buat tabel rooms dengan TEXT ID (room-auditorium, room-lab-ai, dll)
CREATE TABLE public.rooms (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    building TEXT NOT NULL,
    floor INT NOT NULL DEFAULT 1,
    capacity INT NOT NULL,
    facilities JSONB NOT NULL DEFAULT '[]'::jsonb,
    status TEXT NOT NULL DEFAULT 'ACTIVE',
    opening_hour TEXT NOT NULL DEFAULT '08:00',
    closing_hour TEXT NOT NULL DEFAULT '17:00',
    image_url TEXT,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 3. Buat tabel reservations dengan TEXT ID (RB-YYYYMM-XXX) dan room_id TEXT
CREATE TABLE public.reservations (
    id TEXT PRIMARY KEY,
    user_id TEXT NOT NULL,
    room_id TEXT NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    organization TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    purpose TEXT NOT NULL,
    participant_count INT NOT NULL,
    additional_facilities TEXT,
    notes TEXT,
    status TEXT NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 4. Buka akses RLS (Nonaktifkan RLS agar Flutter di HP & Web Admin dapat baca-tulis realtime langsung)
ALTER TABLE public.rooms DISABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations DISABLE ROW LEVEL SECURITY;

-- 5. Aktifkan Supabase Realtime Replication secara aman
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'rooms'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.rooms;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND schemaname = 'public' AND tablename = 'reservations'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.reservations;
    END IF;
END $$;

-- 5. Masukkan Data Awal Ruangan (Rooms Seed Data)
INSERT INTO public.rooms (id, name, building, floor, capacity, facilities, status, opening_hour, closing_hour, image_url, description)
VALUES
(
    'room-auditorium',
    'Auditorium Utama Graha Wiyata',
    'Gedung Rektorat Lt. 3',
    3,
    250,
    '["Proyektor 4K Laser", "Sound System 5000W", "AC Central", "Podium & 4 Mic Wireless", "Lighting Panggung"]'::jsonb,
    'ACTIVE',
    '08:00',
    '18:00',
    'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=800&q=80',
    'Ruangan serbaguna skala besar untuk seminar nasional, simposium ilmiah, kuliah tamu, dan pelantikan ormawa.'
),
(
    'room-lab-ai',
    'Laboratorium Riset AI & Komputer Terpadu',
    'Gedung Sains & Teknologi Lt. 2',
    2,
    45,
    '["45 PC Workstation i7 RTX 4070", "Dual Proyektor HD", "AC Split 3 Unit", "Gigabit LAN", "Whiteboard Kaca"]'::jsonb,
    'ACTIVE',
    '08:00',
    '17:00',
    'https://images.unsplash.com/photo-1562774053-701939374585?auto=format&fit=crop&w=800&q=80',
    'Ruang komputasi berkecepatan tinggi cocok untuk workshop pemrograman, pelatihan data science, dan sertifikasi IT.'
),
(
    'room-smart-class',
    'Smart Classroom & Hybrid Studio 101',
    'Gedung Perkuliahan Bersama Lt. 1',
    1,
    60,
    '["Interactive Smart Board 85 Inch", "Kamera Hybrid Auto-Tracking", "Sound Ceiling", "AC Central", "Meja Kursi Fleksibel"]'::jsonb,
    'ACTIVE',
    '08:00',
    '17:00',
    'https://images.unsplash.com/photo-1580582932707-520aed937b7b?auto=format&fit=crop&w=800&q=80',
    'Ruang kelas modern dengan fasilitas pembelajaran interaktif dan siaran langsung kuliah hibrida.'
),
(
    'room-rapat-senat',
    'Ruang Rapat Senat & Eksekutif',
    'Gedung Rektorat Lt. 2',
    2,
    30,
    '["Smart TV 75 Inch 4K", "Sistem Video Conference Polycom", "Mic Meja Delegate 20 Unit", "AC Central", "Dispenser & Minibar"]'::jsonb,
    'ACTIVE',
    '08:00',
    '18:00',
    'https://images.unsplash.com/photo-1497366216548-37526070297c?auto=format&fit=crop&w=800&q=80',
    'Ruang rapat representatif khusus pimpinan, dewan pertimbangan, dan koordinasi antar fakultas.'
),
(
    'room-aula-student',
    'Aula Kemahasiswaan & Seni',
    'Gedung Student Center Lt. 1',
    1,
    120,
    '["Panggung Portable", "Sound System 2000W", "Proyektor HD", "Kipas Angin Turbin & AC", "Lantai Parquet Karpet"]'::jsonb,
    'ACTIVE',
    '08:00',
    '20:00',
    'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=800&q=80',
    'Pusat aktivitas ormawa untuk latihan seni, musyawarah besar, bazar dalam ruangan, dan expo UKM.'
),
(
    'room-diskusi-library',
    'Ruang Diskusi & Workshop Perpustakaan 2B',
    'Gedung Perpustakaan Pusat Lt. 2',
    2,
    20,
    '["Smart TV 55 Inch", "Whiteboard Lebar", "AC Split", "Colokan Listrik Tiap Meja", "Wi-Fi Dedicated"]'::jsonb,
    'ACTIVE',
    '08:00',
    '17:00',
    'https://images.unsplash.com/photo-1522202176988-66273c2fd55f?auto=format&fit=crop&w=800&q=80',
    'Ruang kolaborasi hening dengan fasilitas multimedia untuk bimbingan skripsi dan diskusi kelompok kecil.'
)
ON CONFLICT (id) DO UPDATE SET
    name = EXCLUDED.name,
    capacity = EXCLUDED.capacity,
    facilities = EXCLUDED.facilities,
    status = EXCLUDED.status;
