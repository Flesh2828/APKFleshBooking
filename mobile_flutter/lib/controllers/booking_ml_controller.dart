import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/ml_prediction_model.dart';
import '../services/ml_service.dart';

class BookingMlController extends ChangeNotifier {
  MlPredictionBundle? _prediction;
  bool _isLoading = false;
  Timer? _debounceTimer;

  MlPredictionBundle? get prediction => _prediction;
  bool get isLoading => _isLoading;

  /// Memanggil evaluasi prediksi saat form berubah dengan debounce 450ms
  void onFormParametersChanged({
    required String roomId,
    required int capacity,
    required int participantCount,
    required double durationHours,
    required String userRole,
    required int pastNoShowCount,
    required String purpose,
    String? roomType,
    String? notes,
  }) {
    _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 450), () async {
      if (purpose.trim().isEmpty) {
        _prediction = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      _isLoading = true;
      notifyListeners();

      try {
        final result = await MlInferenceService.evaluateBooking(
          roomId: roomId,
          capacity: capacity,
          participantCount: participantCount,
          durationHours: durationHours,
          userRole: userRole,
          pastNoShowCount: pastNoShowCount,
          purpose: purpose,
          roomType: roomType,
          notes: notes,
        );
        _prediction = result;
      } catch (_) {
        // Abaikan error jaringan agar tidak mengganggu UI form utama
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    });
  }

  /// Reset state jika form di-clear
  void reset() {
    _debounceTimer?.cancel();
    _prediction = null;
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
