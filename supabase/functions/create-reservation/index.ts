// Supabase Edge Function: create-reservation
// Menangani validasi atomic, bentrok jadwal (collision), jam operasional, dan pembuatan kode unik reservasi.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface CreateReservationPayload {
  roomId: string;
  startTime: string; // ISO 8601
  endTime: string;   // ISO 8601
  purpose: string;
  organization: string;
  participantCount: number;
  additionalFacilities?: string;
  notes?: string;
}

serve(async (req: Request) => {
  // 1. Handle CORS Preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Missing Authorization header" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Client dengan session user untuk validasi Auth
    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const {
      data: { user },
      error: userError,
    } = await supabaseClient.auth.getUser();

    if (userError || !user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const payload: CreateReservationPayload = await req.json();
    const {
      roomId,
      startTime,
      endTime,
      purpose,
      organization,
      participantCount,
      additionalFacilities,
      notes,
    } = payload;

    if (!roomId || !startTime || !endTime || !purpose || !organization) {
      return new Response(JSON.stringify({ error: "Data wajib (roomId, waktu, keperluan, organisasi) belum lengkap" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const start = new Date(startTime);
    const end = new Date(endTime);
    const now = new Date();

    if (start <= now) {
      return new Response(JSON.stringify({ error: "Waktu mulai harus di masa depan" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (end <= start) {
      return new Response(JSON.stringify({ error: "Waktu selesai harus lebih besar dari waktu mulai" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Client Admin/Service Role untuk query dan insert atomic
    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // 2. Ambil data Ruangan dan Profile User
    const [roomRes, profileRes] = await Promise.all([
      supabaseAdmin.from("rooms").select("*").eq("id", roomId).single(),
      supabaseAdmin.from("profiles").select("*").eq("id", user.id).single(),
    ]);

    if (roomRes.error || !roomRes.data) {
      return new Response(JSON.stringify({ error: "Ruangan tidak ditemukan" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const room = roomRes.data;
    if (room.status !== "ACTIVE") {
      return new Response(JSON.stringify({ error: `Ruangan sedang dalam status ${room.status}` }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (participantCount > room.capacity) {
      return new Response(JSON.stringify({ error: `Jumlah peserta (${participantCount}) melebihi kapasitas ruangan (${room.capacity})` }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 3. Validasi Bentrok Jadwal (Overlap Collision Check)
    // Bentrok terjadi jika: existing.start_time < new.end_time AND existing.end_time > new.start_time
    const { data: conflicts, error: conflictError } = await supabaseAdmin
      .from("reservations")
      .select("id, start_time, end_time, status")
      .eq("room_id", roomId)
      .in("status", ["PENDING", "APPROVED"])
      .lt("start_time", end.toISOString())
      .gt("end_time", start.toISOString());

    if (conflictError) {
      return new Response(JSON.stringify({ error: "Gagal memverifikasi ketersediaan jadwal" }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    if (conflicts && conflicts.length > 0) {
      return new Response(
        JSON.stringify({
          error: "Jadwal yang dipilih bentrok dengan pemesanan lain yang sudah terdaftar atau menunggu persetujuan.",
          conflicts,
        }),
        {
          status: 409, // Conflict
          headers: { ...corsHeaders, "Content-Type": "application/json" },
        }
      );
    }

    // 4. Generate Reservation ID Unik (contoh: RB-202609-001)
    const yearMonth = `${start.getFullYear()}${String(start.getMonth() + 1).padStart(2, "0")}`;
    const randomSuffix = Math.floor(100 + Math.random() * 900);
    const reservationCode = `RB-${yearMonth}-${randomSuffix}`;

    const userName = profileRes.data?.name || user.email?.split("@")[0] || "User";

    // 5. Simpan Reservasi
    const { data: newReservation, error: insertError } = await supabaseAdmin
      .from("reservations")
      .insert({
        id: reservationCode,
        user_id: user.id,
        room_id: roomId,
        user_name: userName,
        organization,
        start_time: start.toISOString(),
        end_time: end.toISOString(),
        purpose,
        participant_count: participantCount,
        additional_facilities: additionalFacilities,
        notes,
        status: "PENDING",
      })
      .select()
      .single();

    if (insertError) {
      return new Response(JSON.stringify({ error: insertError.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // 6. Buat In-App Notification untuk User
    await supabaseAdmin.from("notifications").insert({
      user_id: user.id,
      reservation_id: reservationCode,
      title: "Pengajuan Reservasi Berhasil",
      message: `Pengajuan reservasi ruangan ${room.name} (${reservationCode}) berhasil diajukan dan sedang menunggu verifikasi admin.`,
      type: "SUCCESS",
    });

    return new Response(
      JSON.stringify({
        success: true,
        message: "Reservasi berhasil diajukan!",
        data: newReservation,
      }),
      {
        status: 201,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message || "Internal server error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
