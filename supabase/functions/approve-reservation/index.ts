// Supabase Edge Function: approve-reservation
// Khusus Admin untuk approve / reject reservasi dengan audit log & notifikasi otomatis.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.8";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseAnonKey = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";

    const authHeader = req.headers.get("Authorization");
    if (!authHeader) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseClient = createClient(supabaseUrl, supabaseAnonKey, {
      global: { headers: { Authorization: authHeader } },
    });

    const { data: { user } } = await supabaseClient.auth.getUser();
    if (!user) {
      return new Response(JSON.stringify({ error: "Unauthorized" }), {
        status: 401,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey);

    // Cek Role Admin
    const { data: profile } = await supabaseAdmin
      .from("profiles")
      .select("role")
      .eq("id", user.id)
      .single();

    if (profile?.role !== "ADMIN") {
      return new Response(JSON.stringify({ error: "Hanya Admin yang memiliki hak akses ini" }), {
        status: 403,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const { reservationId, action, reason } = await req.json(); // action: 'APPROVED' | 'REJECTED'
    if (!reservationId || !["APPROVED", "REJECTED"].includes(action)) {
      return new Response(JSON.stringify({ error: "Parameter reservationId atau action tidak valid" }), {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Ambil data reservasi lama
    const { data: resv, error: fetchErr } = await supabaseAdmin
      .from("reservations")
      .select("*, rooms(name)")
      .eq("id", reservationId)
      .single();

    if (fetchErr || !resv) {
      return new Response(JSON.stringify({ error: "Reservasi tidak ditemukan" }), {
        status: 404,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    const prevStatus = resv.status;

    // Update Status
    const { error: updateErr } = await supabaseAdmin
      .from("reservations")
      .update({ status: action, updated_at: new Date().toISOString() })
      .eq("id", reservationId);

    if (updateErr) {
      return new Response(JSON.stringify({ error: updateErr.message }), {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      });
    }

    // Catat Audit Trail di reservation_logs
    await supabaseAdmin.from("reservation_logs").insert({
      reservation_id: reservationId,
      admin_id: user.id,
      previous_status: prevStatus,
      new_status: action,
      reason: reason || (action === "APPROVED" ? "Disetujui oleh Administrator" : "Ditolak oleh Administrator"),
    });

    // Kirim notifikasi ke user pemesan
    await supabaseAdmin.from("notifications").insert({
      user_id: resv.user_id,
      reservation_id: reservationId,
      title: action === "APPROVED" ? "Reservasi Disetujui! 🎉" : "Reservasi Ditolak",
      message: action === "APPROVED"
        ? `Reservasi Anda untuk ${resv.rooms?.name || 'ruangan'} (${reservationId}) telah disetujui.`
        : `Reservasi Anda (${reservationId}) ditolak. Alasan: ${reason || 'Tidak ada alasan spesifik'}.`,
      type: action === "APPROVED" ? "SUCCESS" : "DANGER",
    });

    return new Response(
      JSON.stringify({ success: true, message: `Status berhasil diubah menjadi ${action}` }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
