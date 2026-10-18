import 'package:flutter/material.dart';
import '../models/ml_prediction_model.dart';
import '../theme/app_theme.dart';

class MlNoShowBanner extends StatelessWidget {
  final LogisticRegressionResult logisticResult;
  final VoidCallback? onConfirmAttendance;

  const MlNoShowBanner({
    super.key,
    required this.logisticResult,
    this.onConfirmAttendance,
  });

  @override
  Widget build(BuildContext context) {
    if (!logisticResult.isHighRisk) {
      return const SizedBox.shrink();
    }

    final percentage = (logisticResult.noShowProbability * 100).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.statusPendingBg.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.statusPending.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.statusPending,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Perhatian: Indikator Risiko No-Show Tinggi ($percentage%)',
                  style: const TextStyle(
                    color: AppColors.statusPending,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Berdasarkan pola riwayat reservasi, pastikan Anda mengonfirmasi kehadiran tepat waktu untuk menghindari pembatalan otomatis.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
          if (onConfirmAttendance != null) ...[
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: onConfirmAttendance,
                icon: const Icon(Icons.check_circle_outline, size: 14),
                label: const Text(
                  'Siap Konfirmasi Kehadiran',
                  style: TextStyle(fontSize: 11),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusPending,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
