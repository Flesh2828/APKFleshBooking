-- ==============================================================================
-- Schema Supabase PostgreSQL untuk APKFleshBooking (RoomBook)
-- Mendukung: RLS (Row Level Security), Supabase Auth, Realtime, & Edge Functions
-- ==============================================================================

-- 1. ENUM DEFINITIONS
CREATE TYPE user_role AS ENUM ('ADMIN', 'MAHASISWA', 'DOSEN', 'STAF');
CREATE TYPE reservation_status AS ENUM ('PENDING', 'APPROVED', 'REJECTED', 'CANCELLED', 'COMPLETED');
CREATE TYPE room_status AS ENUM ('ACTIVE', 'INACTIVE', 'MAINTENANCE');
CREATE TYPE notification_type AS ENUM ('INFO', 'SUCCESS', 'WARNING', 'DANGER');

-- 2. USER PROFILES TABLE (Terkoneksi dengan Supabase Auth)
CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    role user_role NOT NULL DEFAULT 'MAHASISWA',
    department TEXT,
    phone TEXT,
    avatar_url TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- Trigger untuk sinkronisasi otomatis dari auth.users ke public.profiles saat sign up
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, name, email, role, department, avatar_url)
    VALUES (
        new.id,
        COALESCE(new.raw_user_meta_data->>'name', 'Pengguna Baru'),
        new.email,
        COALESCE((new.raw_user_meta_data->>'role')::user_role, 'MAHASISWA'),
        new.raw_user_meta_data->>'department',
        new.raw_user_meta_data->>'avatar_url'
    );
    RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- 3. ROOMS TABLE
CREATE TABLE public.rooms (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    building TEXT NOT NULL,
    floor INT NOT NULL DEFAULT 1,
    capacity INT NOT NULL,
    facilities JSONB NOT NULL DEFAULT '[]'::jsonb,
    status room_status NOT NULL DEFAULT 'ACTIVE',
    opening_hour TIME NOT NULL DEFAULT '08:00',
    closing_hour TIME NOT NULL DEFAULT '17:00',
    image_url TEXT,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 4. RESERVATIONS TABLE
CREATE TABLE public.reservations (
    id TEXT PRIMARY KEY, -- Kode unik misal: RB-202609-001
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    room_id UUID NOT NULL REFERENCES public.rooms(id) ON DELETE CASCADE,
    user_name TEXT NOT NULL,
    organization TEXT NOT NULL,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    purpose TEXT NOT NULL,
    participant_count INT NOT NULL,
    additional_facilities TEXT,
    notes TEXT,
    status reservation_status NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

CREATE INDEX idx_reservations_room_time ON public.reservations (room_id, start_time, end_time);
CREATE INDEX idx_reservations_user ON public.reservations (user_id);
CREATE INDEX idx_reservations_status ON public.reservations (status);

-- 5. RESERVATION LOGS TABLE (Audit Trail)
CREATE TABLE public.reservation_logs (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reservation_id TEXT NOT NULL REFERENCES public.reservations(id) ON DELETE CASCADE,
    admin_id UUID NOT NULL REFERENCES public.profiles(id),
    previous_status reservation_status NOT NULL,
    new_status reservation_status NOT NULL,
    reason TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- 6. IN-APP NOTIFICATIONS TABLE
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
    reservation_id TEXT REFERENCES public.reservations(id) ON DELETE SET NULL,
    title TEXT NOT NULL,
    message TEXT NOT NULL,
    type notification_type NOT NULL DEFAULT 'INFO',
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc', now())
);

-- ==============================================================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reservation_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;

-- Helper function: Cek apakah user adalah ADMIN
CREATE OR REPLACE FUNCTION public.is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'ADMIN'
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Profiles: Siapapun yg login bisa baca, hanya pemilik yg bisa update
CREATE POLICY "Public read profiles" ON public.profiles FOR SELECT TO authenticated USING (true);
CREATE POLICY "User update own profile" ON public.profiles FOR UPDATE TO authenticated USING (id = auth.uid());

-- Rooms: Semua user terotentikasi bisa melihat ruangan, hanya Admin yang bisa kelola
CREATE POLICY "All users can view active rooms" ON public.rooms FOR SELECT TO authenticated USING (true);
CREATE POLICY "Only admin manage rooms" ON public.rooms FOR ALL TO authenticated USING (public.is_admin());

-- Reservations:
-- 1. Mahasiswa/Dosen/Staf bisa melihat reservasinya sendiri
-- 2. Admin bisa melihat semua reservasi
CREATE POLICY "Users view own or admin view all" ON public.reservations
FOR SELECT TO authenticated
USING (user_id = auth.uid() OR public.is_admin());

-- User bisa membuat reservasi via Edge Function / RLS
CREATE POLICY "Users can insert reservation" ON public.reservations
FOR INSERT TO authenticated
WITH CHECK (user_id = auth.uid());

-- User bisa membatalkan reservasinya sendiri selama status PENDING, Admin bisa ubah status apapun
CREATE POLICY "Update reservation policy" ON public.reservations
FOR UPDATE TO authenticated
USING (
    public.is_admin() OR 
    (user_id = auth.uid() AND status = 'PENDING')
);

-- Notifications: User hanya melihat notifikasinya sendiri
CREATE POLICY "User view own notifications" ON public.notifications
FOR SELECT TO authenticated
USING (user_id = auth.uid());

CREATE POLICY "User update own notifications read state" ON public.notifications
FOR UPDATE TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- ==============================================================================
-- 8. AKTIFKAN SUPABASE REALTIME
-- ==============================================================================
ALTER PUBLICATION supabase_realtime ADD TABLE public.rooms;
ALTER PUBLICATION supabase_realtime ADD TABLE public.reservations;
ALTER PUBLICATION supabase_realtime ADD TABLE public.notifications;
