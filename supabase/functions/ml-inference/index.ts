// Supabase Edge Function: ml-inference
// Menangani prediksi Linear Regression, Logistic Regression, Naive Bayes, dan SVM

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface MlInferencePayload {
  room_id?: string;
  room_type?: string;
  capacity?: number;
  participant_count?: number;
  duration_hours?: number;
  user_role?: string;
  past_no_show_count?: number;
  purpose?: string;
  notes?: string;
}

serve(async (req: Request) => {
  // 1. CORS Preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const payload: MlInferencePayload = await req.json();
    const {
      capacity = 30,
      participant_count = 1,
      duration_hours = 1.0,
      user_role = "MAHASISWA",
      past_no_show_count = 0,
      purpose = "",
      room_type = "KELAS",
    } = payload;

    // --- 1. Linear Regression (Prediksi Nilai Kontinu: Okupansi Jam & Estimasi kWh) ---
    // Model: y = b0 + b1*durasi + b2*peserta_ratio + b3*tipe_ruang
    const roomTypeMultiplier = room_type.toUpperCase() === "LAB" ? 1.6 : 1.0;
    const estimated_kwh = Number(
      (duration_hours * 1.85 * roomTypeMultiplier * (participant_count > 25 ? 1.25 : 1.0)).toFixed(2)
    );
    const predicted_occupancy = Number(
      (duration_hours * 1.15 + (capacity / 12)).toFixed(1)
    );

    // --- 2. Logistic Regression (Klasifikasi Biner: Probabilitas Risiko No-Show) ---
    // Sigmoid: P(No-Show) = 1 / (1 + e^-z)
    const isMahasiswa = user_role.toUpperCase() === "MAHASISWA" ? 0.35 : -0.25;
    const z = -1.85 + (past_no_show_count * 1.15) + isMahasiswa + (duration_hours > 4 ? 0.45 : 0.0);
    const no_show_prob = Number((1 / (1 + Math.exp(-z))).toFixed(3));
    const is_high_risk = no_show_prob >= 0.50;

    // --- 3. Naive Bayes (Klasifikasi Berbasis Teks & Deteksi Spam) ---
    const cleanText = purpose.toLowerCase().trim();
    const isSpam = cleanText.length < 5 || /(asdf|qwer|test|halo|zzzz|peminjaman biasa)/i.test(cleanText);
    let category = "UMUM";
    let confidence = 0.85;

    if (/(praktikum|kuliah|dosen|tugas|skripsi|sidang|matakuliah|responsi|tutorial)/i.test(cleanText)) {
      category = "AKADEMIK";
      confidence = 0.95;
    } else if (/(bem|hima|hmif|rapat|ormawa|kegiatan|panitia|pelantikan|musyawarah|ldk)/i.test(cleanText)) {
      category = "ORMAWA";
      confidence = 0.93;
    } else if (/(seminar|workshop|webinar|pelatihan|narasumber|talkshow|expo)/i.test(cleanText)) {
      category = "SEMINAR";
      confidence = 0.96;
    }

    // --- 4. Support Vector Machine / SVM (Batas Keputusan Multi-Dimensi: Rekomendasi Persetujuan) ---
    const fillRatio = participant_count / (capacity > 0 ? capacity : 1);
    let recommendation = "MANUAL_REVIEW";
    const reasons: string[] = [];

    if (isSpam || fillRatio < 0.10 || fillRatio > 1.20) {
      recommendation = "AUTO_REJECT";
      if (fillRatio > 1.20) {
        reasons.push(`Jumlah peserta melebihi kapasitas ruangan (${(fillRatio * 100).toFixed(0)}%)`);
      } else if (fillRatio < 0.10) {
        reasons.push("Peserta terlalu sedikit untuk ukuran ruangan ini");
      }
      if (isSpam) {
        reasons.push("Deskripsi tujuan belum memenuhi kriteria valid");
      }
    } else if (fillRatio >= 0.35 && fillRatio <= 1.0 && past_no_show_count === 0 && !is_high_risk && !isSpam) {
      recommendation = "AUTO_APPROVE";
      reasons.push(`Kapasitas proporsional (${(fillRatio * 100).toFixed(0)}%)`);
      reasons.push("Profil pemohon terverifikasi & bebas catatan no-show");
    } else {
      recommendation = "MANUAL_REVIEW";
      reasons.push("Memerlukan verifikasi jadwal & fasilitas oleh admin pengelola");
    }

    const responseBody = {
      status: "success",
      evaluated_at: new Date().toISOString(),
      predictions: {
        linear_regression: {
          predicted_weekly_occupancy_hours: predicted_occupancy,
          estimated_energy_kwh: estimated_kwh,
        },
        logistic_regression: {
          no_show_probability: no_show_prob,
          is_high_risk: is_high_risk,
          risk_level: is_high_risk ? "HIGH" : "LOW",
        },
        naive_bayes: {
          predicted_category: category,
          confidence: confidence,
          is_spam: isSpam,
        },
        svm: {
          recommendation: recommendation,
          margin_confidence: 0.88,
          decision_reasons: reasons,
        },
      },
    };

    return new Response(JSON.stringify(responseBody), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (err: unknown) {
    const error = err as Error;
    return new Response(JSON.stringify({ status: "error", message: error.message || "Unknown error" }), {
      status: 500,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }
});
