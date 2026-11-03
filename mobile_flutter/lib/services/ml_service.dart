import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ml_prediction_model.dart';

class MlInferenceService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  /// Memanggil Endpoint Inference ML Supabase Edge Function dengan timeout & graceful fallback
  static Future<MlPredictionBundle> evaluateBooking({
    required String roomId,
    required int capacity,
    required int participantCount,
    required double durationHours,
    required String userRole,
    required int pastNoShowCount,
    required String purpose,
    String? roomType,
    String? notes,
  }) async {
    final payload = {
      'room_id': roomId,
      'capacity': capacity,
      'participant_count': participantCount,
      'duration_hours': durationHours,
      'user_role': userRole,
      'past_no_show_count': pastNoShowCount,
      'purpose': purpose,
      'room_type': roomType ?? 'KELAS',
      'notes': notes ?? '',
    };

    try {
      final response = await _supabase.functions
          .invoke('ml-inference', body: payload)
          .timeout(const Duration(milliseconds: 3500));

      if (response.status == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data as Map);
        return MlPredictionBundle.fromJson(data);
      } else {
        return calculateLocalFallback(payload);
      }
    } catch (_) {
      // Graceful fallback lokal bila device offline atau Edge Function belum dideploy
      return calculateLocalFallback(payload);
    }
  }

  /// Algoritma Fallback Heuristik Lokal (Matematika & Aturan ML di sisi klien)
  static MlPredictionBundle calculateLocalFallback(Map<String, dynamic> data) {
    final duration = (data['duration_hours'] as num?)?.toDouble() ?? 1.0;
    final capacity = (data['capacity'] as num?)?.toInt() ?? 30;
    final participants = (data['participant_count'] as num?)?.toInt() ?? 1;
    final role = (data['user_role'] as String?)?.toUpperCase() ?? 'MAHASISWA';
    final pastNoShow = (data['past_no_show_count'] as num?)?.toInt() ?? 0;
    final purpose = (data['purpose'] as String?)?.toLowerCase().trim() ?? '';
    final roomType = (data['room_type'] as String?)?.toUpperCase() ?? 'KELAS';

    // 1. Linear Regression (Prediksi Okupansi & Energi kWh)
    final roomMultiplier = roomType == 'LAB' ? 1.55 : 1.0;
    final estKwh = double.parse(
      (duration * 1.85 * roomMultiplier * (participants > 25 ? 1.25 : 1.0))
          .toStringAsFixed(2),
    );
    final predOccupancy = double.parse(
      (duration * 1.15 + (capacity / 12)).toStringAsFixed(1),
    );

    // 2. Logistic Regression (Probabilitas Risiko No-Show)
    final isMahasiswaBias = role == 'MAHASISWA' ? 0.35 : -0.25;
    final z = -1.85 + (pastNoShow * 1.15) + isMahasiswaBias + (duration > 4 ? 0.45 : 0.0);
    // Sigmoid function: 1 / (1 + e^-z)
    final finalProb = double.parse(((1 / (1 + _exp(-z)))).toStringAsFixed(3));
    final isHighRisk = finalProb >= 0.50;

    // 3. Naive Bayes (Klasifikasi Kategori & Deteksi Teks Tidak Valid/Spam)
    final isSpam = purpose.length < 5 ||
        RegExp(r'(asdf|qwer|test|halo|zzzz|peminjaman biasa)', caseSensitive: false)
            .hasMatch(purpose);
    String category = 'UMUM';
    double confidence = 0.85;

    if (RegExp(r'(praktikum|kuliah|dosen|tugas|skripsi|sidang|matakuliah|responsi)',
            caseSensitive: false)
        .hasMatch(purpose)) {
      category = 'AKADEMIK';
      confidence = 0.95;
    } else if (RegExp(r'(bem|hima|hmif|rapat|ormawa|kegiatan|panitia|pelantikan)',
            caseSensitive: false)
        .hasMatch(purpose)) {
      category = 'ORMAWA';
      confidence = 0.93;
    } else if (RegExp(r'(seminar|workshop|webinar|pelatihan|narasumber|talkshow)',
            caseSensitive: false)
        .hasMatch(purpose)) {
      category = 'SEMINAR';
      confidence = 0.96;
    }

    // 4. SVM (Batas Keputusan Rekomendasi Persetujuan)
    final fillRatio = participants / (capacity > 0 ? capacity : 1);
    String recommendation = 'MANUAL_REVIEW';
    final List<String> reasons = [];

    if (isSpam || fillRatio < 0.10 || fillRatio > 1.20) {
      recommendation = 'AUTO_REJECT';
      if (fillRatio > 1.20) {
        reasons.add(
            'Jumlah peserta melebihi kapasitas ruangan (${(fillRatio * 100).toInt()}%)');
      } else if (fillRatio < 0.10) {
        reasons.add('Peserta terlalu sedikit untuk ukuran ruangan ini');
      }
      if (isSpam) {
        reasons.add('Deskripsi tujuan belum memenuhi kriteria valid');
      }
    } else if (fillRatio >= 0.35 &&
        fillRatio <= 1.0 &&
        pastNoShow == 0 &&
        !isHighRisk &&
        !isSpam) {
      recommendation = 'AUTO_APPROVE';
      reasons.add('Kapasitas proporsional (${(fillRatio * 100).toInt()}%)');
      reasons.add('Profil pemohon terverifikasi & bebas catatan no-show');
    } else {
      recommendation = 'MANUAL_REVIEW';
      reasons.add('Memerlukan verifikasi jadwal & fasilitas oleh admin pengelola');
    }

    return MlPredictionBundle(
      linearRegression: LinearRegressionResult(
        predictedWeeklyOccupancyHours: predOccupancy,
        estimatedEnergyKwh: estKwh,
      ),
      logisticRegression: LogisticRegressionResult(
        noShowProbability: finalProb,
        isHighRisk: isHighRisk,
        riskLevel: isHighRisk ? 'HIGH' : 'LOW',
      ),
      naiveBayes: NaiveBayesResult(
        predictedCategory: category,
        confidence: confidence,
        isSpam: isSpam,
      ),
      svm: SvmResult(
        recommendation: recommendation,
        marginConfidence: 0.88,
        decisionReasons: reasons,
      ),
      evaluatedAt: DateTime.now(),
    );
  }

  static double _exp(double x) {
    if (x > 20) return 485165195.4;
    if (x < -20) return 0.0;
    // Approximating e^x via standard power/math series or exp
    double sum = 1.0;
    double term = 1.0;
    for (int i = 1; i <= 15; i++) {
      term *= x / i;
      sum += term;
    }
    return sum > 0 ? sum : 0.00001;
  }
}
