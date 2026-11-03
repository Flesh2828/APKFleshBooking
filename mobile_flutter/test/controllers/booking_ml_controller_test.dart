import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/controllers/booking_ml_controller.dart';

void main() {
  group('BookingMlController Unit Tests', () {
    late BookingMlController controller;

    setUp(() {
      controller = BookingMlController();
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state has null prediction and isLoading false', () {
      expect(controller.prediction, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('onFormParametersChanged with empty purpose resets state immediately', () async {
      controller.onFormParametersChanged(
        roomId: 'room-1',
        capacity: 30,
        participantCount: 15,
        durationHours: 2.0,
        userRole: 'MAHASISWA',
        pastNoShowCount: 0,
        purpose: '   ',
      );

      // Wait for debounce period (450ms)
      await Future<void>.delayed(const Duration(milliseconds: 500));

      expect(controller.prediction, isNull);
      expect(controller.isLoading, isFalse);
    });

    test('onFormParametersChanged evaluates prediction after debounce delay', () async {
      int notifyCount = 0;
      controller.addListener(() {
        notifyCount++;
      });

      controller.onFormParametersChanged(
        roomId: 'room-101',
        capacity: 40,
        participantCount: 20,
        durationHours: 2.0,
        userRole: 'DOSEN',
        pastNoShowCount: 0,
        purpose: 'Kuliah Pemrograman Mobile',
      );

      // Before 450ms, prediction should not be resolved yet
      expect(controller.prediction, isNull);

      // Wait for debounce to complete
      await Future<void>.delayed(const Duration(milliseconds: 600));

      expect(controller.isLoading, isFalse);
      expect(controller.prediction, isNotNull);
      expect(controller.prediction!.naiveBayes.predictedCategory, equals('AKADEMIK'));
      expect(notifyCount, greaterThan(0));
    });

    test('reset clears prediction and cancels active debounce', () async {
      controller.onFormParametersChanged(
        roomId: 'room-1',
        capacity: 30,
        participantCount: 15,
        durationHours: 1.0,
        userRole: 'DOSEN',
        pastNoShowCount: 0,
        purpose: 'Seminar Nasional AI',
      );

      await Future<void>.delayed(const Duration(milliseconds: 600));
      expect(controller.prediction, isNotNull);

      controller.reset();

      expect(controller.prediction, isNull);
      expect(controller.isLoading, isFalse);
    });
  });
}

