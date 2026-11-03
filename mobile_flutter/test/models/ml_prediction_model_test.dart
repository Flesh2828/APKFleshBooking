import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/models/ml_prediction_model.dart';

void main() {
  group('LinearRegressionResult Model Tests', () {
    test('fromJson constructs valid model with correct fields', () {
      final json = {
        'predicted_weekly_occupancy_hours': 14.5,
        'estimated_energy_kwh': 8.25,
      };

      final result = LinearRegressionResult.fromJson(json);

      expect(result.predictedWeeklyOccupancyHours, equals(14.5));
      expect(result.estimatedEnergyKwh, equals(8.25));
    });

    test('fromJson handles null or missing values gracefully', () {
      final json = <String, dynamic>{};

      final result = LinearRegressionResult.fromJson(json);

      expect(result.predictedWeeklyOccupancyHours, equals(0.0));
      expect(result.estimatedEnergyKwh, equals(0.0));
    });

    test('toJson serializes correctly', () {
      const model = LinearRegressionResult(
        predictedWeeklyOccupancyHours: 12.0,
        estimatedEnergyKwh: 5.5,
      );

      final json = model.toJson();

      expect(json['predicted_weekly_occupancy_hours'], equals(12.0));
      expect(json['estimated_energy_kwh'], equals(5.5));
    });
  });

  group('LogisticRegressionResult Model Tests', () {
    test('fromJson constructs valid model with correct fields', () {
      final json = {
        'no_show_probability': 0.72,
        'is_high_risk': true,
        'risk_level': 'HIGH',
      };

      final result = LogisticRegressionResult.fromJson(json);

      expect(result.noShowProbability, equals(0.72));
      expect(result.isHighRisk, isTrue);
      expect(result.riskLevel, equals('HIGH'));
    });

    test('fromJson handles missing values with default values', () {
      final json = <String, dynamic>{};

      final result = LogisticRegressionResult.fromJson(json);

      expect(result.noShowProbability, equals(0.0));
      expect(result.isHighRisk, isFalse);
      expect(result.riskLevel, equals('LOW'));
    });

    test('toJson serializes correctly', () {
      const model = LogisticRegressionResult(
        noShowProbability: 0.15,
        isHighRisk: false,
        riskLevel: 'LOW',
      );

      final json = model.toJson();

      expect(json['no_show_probability'], equals(0.15));
      expect(json['is_high_risk'], isFalse);
      expect(json['risk_level'], equals('LOW'));
    });
  });

  group('NaiveBayesResult Model Tests', () {
    test('fromJson constructs valid model with correct fields', () {
      final json = {
        'predicted_category': 'AKADEMIK',
        'confidence': 0.95,
        'is_spam': false,
      };

      final result = NaiveBayesResult.fromJson(json);

      expect(result.predictedCategory, equals('AKADEMIK'));
      expect(result.confidence, equals(0.95));
      expect(result.isSpam, isFalse);
    });

    test('fromJson handles missing values with fallback', () {
      final json = <String, dynamic>{};

      final result = NaiveBayesResult.fromJson(json);

      expect(result.predictedCategory, equals('UMUM'));
      expect(result.confidence, equals(0.0));
      expect(result.isSpam, isFalse);
    });

    test('toJson serializes correctly', () {
      const model = NaiveBayesResult(
        predictedCategory: 'ORMAWA',
        confidence: 0.93,
        isSpam: false,
      );

      final json = model.toJson();

      expect(json['predicted_category'], equals('ORMAWA'));
      expect(json['confidence'], equals(0.93));
      expect(json['is_spam'], isFalse);
    });
  });

  group('SvmResult Model Tests', () {
    test('fromJson constructs valid model with correct fields', () {
      final json = {
        'recommendation': 'AUTO_APPROVE',
        'margin_confidence': 0.88,
        'decision_reasons': ['Kapasitas proporsional (80%)', 'Bebas catatan no-show'],
      };

      final result = SvmResult.fromJson(json);

      expect(result.recommendation, equals('AUTO_APPROVE'));
      expect(result.marginConfidence, equals(0.88));
      expect(result.decisionReasons.length, equals(2));
      expect(result.decisionReasons.first, contains('Kapasitas proporsional'));
    });

    test('fromJson handles empty/missing values safely', () {
      final json = <String, dynamic>{};

      final result = SvmResult.fromJson(json);

      expect(result.recommendation, equals('MANUAL_REVIEW'));
      expect(result.marginConfidence, equals(0.0));
      expect(result.decisionReasons, isEmpty);
    });

    test('toJson serializes correctly', () {
      const model = SvmResult(
        recommendation: 'AUTO_REJECT',
        marginConfidence: 0.91,
        decisionReasons: ['Spam terdeteksi'],
      );

      final json = model.toJson();

      expect(json['recommendation'], equals('AUTO_REJECT'));
      expect(json['margin_confidence'], equals(0.91));
      expect(json['decision_reasons'], equals(['Spam terdeteksi']));
    });
  });

  group('MlPredictionBundle Model Tests', () {
    test('fromJson parses nested predictions bundle properly', () {
      final testTime = DateTime.now();
      final json = {
        'evaluated_at': testTime.toIso8601String(),
        'predictions': {
          'linear_regression': {
            'predicted_weekly_occupancy_hours': 10.5,
            'estimated_energy_kwh': 4.5,
          },
          'logistic_regression': {
            'no_show_probability': 0.12,
            'is_high_risk': false,
            'risk_level': 'LOW',
          },
          'naive_bayes': {
            'predicted_category': 'SEMINAR',
            'confidence': 0.96,
            'is_spam': false,
          },
          'svm': {
            'recommendation': 'AUTO_APPROVE',
            'margin_confidence': 0.88,
            'decision_reasons': ['Kapasitas proporsional'],
          },
        },
      };

      final bundle = MlPredictionBundle.fromJson(json);

      expect(bundle.linearRegression.predictedWeeklyOccupancyHours, equals(10.5));
      expect(bundle.logisticRegression.isHighRisk, isFalse);
      expect(bundle.naiveBayes.predictedCategory, equals('SEMINAR'));
      expect(bundle.svm.recommendation, equals('AUTO_APPROVE'));
      expect(bundle.evaluatedAt.year, equals(testTime.year));
    });

    test('toJson preserves all sub-models in dictionary format', () {
      final fixedDate = DateTime(2026, 10, 28, 12, 0);
      final bundle = MlPredictionBundle(
        linearRegression: const LinearRegressionResult(
          predictedWeeklyOccupancyHours: 8.0,
          estimatedEnergyKwh: 3.5,
        ),
        logisticRegression: const LogisticRegressionResult(
          noShowProbability: 0.8,
          isHighRisk: true,
          riskLevel: 'HIGH',
        ),
        naiveBayes: const NaiveBayesResult(
          predictedCategory: 'AKADEMIK',
          confidence: 0.95,
          isSpam: false,
        ),
        svm: const SvmResult(
          recommendation: 'MANUAL_REVIEW',
          marginConfidence: 0.75,
          decisionReasons: ['Verifikasi admin'],
        ),
        evaluatedAt: fixedDate,
      );

      final json = bundle.toJson();

      expect(json['evaluated_at'], equals(fixedDate.toIso8601String()));
      expect(json['predictions'], isA<Map<String, dynamic>>());

      final preds = json['predictions'] as Map<String, dynamic>;
      expect(preds['linear_regression']['estimated_energy_kwh'], equals(3.5));
      expect(preds['logistic_regression']['is_high_risk'], isTrue);
      expect(preds['naive_bayes']['predicted_category'], equals('AKADEMIK'));
      expect(preds['svm']['recommendation'], equals('MANUAL_REVIEW'));
    });
  });
}

