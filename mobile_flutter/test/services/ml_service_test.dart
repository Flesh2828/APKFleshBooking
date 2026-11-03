import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/services/ml_service.dart';

void main() {
  group('MlInferenceService - Linear Regression Tests', () {
    test('calculates correct occupancy hours and baseline energy for KELAS', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 36,
        'participant_count': 20,
        'room_type': 'KELAS',
        'user_role': 'DOSEN',
        'past_no_show_count': 0,
        'purpose': 'Kuliah Pemrograman Mobile',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      // predOccupancy = duration * 1.15 + (capacity / 12) = 2.0 * 1.15 + (36 / 12) = 2.3 + 3.0 = 5.3
      expect(result.linearRegression.predictedWeeklyOccupancyHours, equals(5.3));
      // estKwh = 2.0 * 1.85 * 1.0 * 1.0 = 3.70
      expect(result.linearRegression.estimatedEnergyKwh, equals(3.70));
    });

    test('applies LAB multiplier (1.55) and high participant multiplier (1.25) when participants > 25', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 40,
        'participant_count': 30, // > 25 triggers 1.25 multiplier
        'room_type': 'LAB',     // triggers 1.55 multiplier
        'user_role': 'DOSEN',
        'past_no_show_count': 0,
        'purpose': 'Praktikum Jaringan Komputer',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      // estKwh = 2.0 * 1.85 * 1.55 * 1.25 = 7.16875 -> 7.17
      expect(result.linearRegression.estimatedEnergyKwh, equals(7.17));
    });
  });

  group('MlInferenceService - Logistic Regression (No-Show Risk) Tests', () {
    test('predicts LOW risk for Dosen with 0 past no-show and short duration', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 30,
        'participant_count': 20,
        'user_role': 'DOSEN', // bias = -0.25
        'past_no_show_count': 0,
        'purpose': 'Kuliah Umum',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.logisticRegression.isHighRisk, isFalse);
      expect(result.logisticRegression.riskLevel, equals('LOW'));
      expect(result.logisticRegression.noShowProbability, lessThan(0.50));
    });

    test('predicts HIGH risk for Mahasiswa with past no-shows', () {
      final payload = {
        'duration_hours': 3.0,
        'capacity': 30,
        'participant_count': 15,
        'user_role': 'MAHASISWA', // bias = +0.35
        'past_no_show_count': 2,    // + 2 * 1.15 = 2.30
        'purpose': 'Rapat Panitia',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.logisticRegression.isHighRisk, isTrue);
      expect(result.logisticRegression.riskLevel, equals('HIGH'));
      expect(result.logisticRegression.noShowProbability, greaterThanOrEqualTo(0.50));
    });

    test('long duration (> 4 hours) increases risk score', () {
      final normalPayload = {
        'duration_hours': 3.0,
        'capacity': 30,
        'participant_count': 15,
        'user_role': 'MAHASISWA',
        'past_no_show_count': 1,
        'purpose': 'Belajar Kelompok',
      };
      final longPayload = {
        'duration_hours': 5.0, // > 4 hours adds +0.45 to z
        'capacity': 30,
        'participant_count': 15,
        'user_role': 'MAHASISWA',
        'past_no_show_count': 1,
        'purpose': 'Belajar Kelompok',
      };

      final normalResult = MlInferenceService.calculateLocalFallback(normalPayload);
      final longResult = MlInferenceService.calculateLocalFallback(longPayload);

      expect(longResult.logisticRegression.noShowProbability,
          greaterThan(normalResult.logisticRegression.noShowProbability));
    });
  });

  group('MlInferenceService - Naive Bayes (NLP & Spam Classification) Tests', () {
    test('classifies AKADEMIK keywords correctly', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 30,
        'participant_count': 20,
        'user_role': 'DOSEN',
        'past_no_show_count': 0,
        'purpose': 'Pelaksanaan Sidang Skripsi Mahasiswa',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.naiveBayes.predictedCategory, equals('AKADEMIK'));
      expect(result.naiveBayes.confidence, equals(0.95));
      expect(result.naiveBayes.isSpam, isFalse);
    });

    test('classifies ORMAWA keywords correctly', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 30,
        'participant_count': 20,
        'user_role': 'MAHASISWA',
        'past_no_show_count': 0,
        'purpose': 'Rapat Pleno BEM Fakultas Teknik',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.naiveBayes.predictedCategory, equals('ORMAWA'));
      expect(result.naiveBayes.confidence, equals(0.93));
      expect(result.naiveBayes.isSpam, isFalse);
    });

    test('classifies SEMINAR keywords correctly', () {
      final payload = {
        'duration_hours': 3.0,
        'capacity': 50,
        'participant_count': 40,
        'user_role': 'DOSEN',
        'past_no_show_count': 0,
        'purpose': 'Workshop Artificial Intelligence & Big Data',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.naiveBayes.predictedCategory, equals('SEMINAR'));
      expect(result.naiveBayes.confidence, equals(0.96));
      expect(result.naiveBayes.isSpam, isFalse);
    });

    test('defaults to UMUM category when no specialized keyword matches', () {
      final payload = {
        'duration_hours': 1.0,
        'capacity': 30,
        'participant_count': 15,
        'user_role': 'DOSEN',
        'past_no_show_count': 0,
        'purpose': 'Diskusi Internal Koordinasi Tim Riset',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.naiveBayes.predictedCategory, equals('UMUM'));
      expect(result.naiveBayes.confidence, equals(0.85));
      expect(result.naiveBayes.isSpam, isFalse);
    });

    test('detects spam when purpose length < 5 characters or contains spam words', () {
      final shortPayload = {
        'duration_hours': 1.0,
        'capacity': 30,
        'participant_count': 15,
        'purpose': 'tes', // < 5 chars
      };
      final spamWordPayload = {
        'duration_hours': 1.0,
        'capacity': 30,
        'participant_count': 15,
        'purpose': 'asdf testing ruangan halo',
      };

      final shortResult = MlInferenceService.calculateLocalFallback(shortPayload);
      final spamResult = MlInferenceService.calculateLocalFallback(spamWordPayload);

      expect(shortResult.naiveBayes.isSpam, isTrue);
      expect(spamResult.naiveBayes.isSpam, isTrue);
    });
  });

  group('MlInferenceService - SVM Recommendation Boundary Tests', () {
    test('recommends AUTO_APPROVE when conditions are optimal', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 40,
        'participant_count': 25, // fill ratio = 25/40 = 62.5% (between 35% and 100%)
        'user_role': 'DOSEN',
        'past_no_show_count': 0,
        'purpose': 'Kuliah Pengantar Basis Data',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.svm.recommendation, equals('AUTO_APPROVE'));
      expect(result.svm.decisionReasons, anyElement(contains('Kapasitas proporsional')));
      expect(result.svm.decisionReasons, anyElement(contains('bebas catatan no-show')));
    });

    test('recommends AUTO_REJECT when capacity is exceeded (> 120%)', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 30,
        'participant_count': 45, // fill ratio = 150% > 120%
        'user_role': 'MAHASISWA',
        'past_no_show_count': 0,
        'purpose': 'Seminar Nasional Teknologi',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.svm.recommendation, equals('AUTO_REJECT'));
      expect(result.svm.decisionReasons, anyElement(contains('melebihi kapasitas ruangan')));
    });

    test('recommends AUTO_REJECT when participant count is too small (< 10%)', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 50,
        'participant_count': 2, // fill ratio = 4% < 10%
        'user_role': 'MAHASISWA',
        'past_no_show_count': 0,
        'purpose': 'Rapat Tim Inti',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.svm.recommendation, equals('AUTO_REJECT'));
      expect(result.svm.decisionReasons, anyElement(contains('Peserta terlalu sedikit')));
    });

    test('recommends AUTO_REJECT when text is identified as spam', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 40,
        'participant_count': 25,
        'user_role': 'MAHASISWA',
        'past_no_show_count': 0,
        'purpose': 'asdf',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.svm.recommendation, equals('AUTO_REJECT'));
      expect(result.svm.decisionReasons, anyElement(contains('belum memenuhi kriteria valid')));
    });

    test('recommends MANUAL_REVIEW for intermediate borderline cases', () {
      final payload = {
        'duration_hours': 2.0,
        'capacity': 40,
        'participant_count': 10, // fill ratio = 25% (between 10% and 35%)
        'user_role': 'MAHASISWA',
        'past_no_show_count': 0,
        'purpose': 'Rapat Persiapan Acara Divisi',
      };

      final result = MlInferenceService.calculateLocalFallback(payload);

      expect(result.svm.recommendation, equals('MANUAL_REVIEW'));
      expect(result.svm.decisionReasons, anyElement(contains('Memerlukan verifikasi jadwal')));
    });
  });

  group('MlInferenceService - evaluateBooking Fallback Resilience', () {
    test('gracefully falls back to local algorithm when Supabase is not configured', () async {
      final bundle = await MlInferenceService.evaluateBooking(
        roomId: 'room-123',
        capacity: 30,
        participantCount: 20,
        durationHours: 2.0,
        userRole: 'DOSEN',
        pastNoShowCount: 0,
        purpose: 'Praktikum Pemrograman Web',
      );

      expect(bundle, isNotNull);
      expect(bundle.naiveBayes.predictedCategory, equals('AKADEMIK'));
      expect(bundle.svm.recommendation, equals('AUTO_APPROVE'));
    });
  });
}

