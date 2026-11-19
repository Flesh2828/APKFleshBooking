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
    final percentage = (logisticResult.noShowProbability * 100).toInt();
    final isHigh = logisticResult.isHighRisk;

    final bannerBg = isHigh
        ? AppColors.statusPendingBg.withValues(alpha: 0.35)
        : AppColors.statusAvailableBg.withValues(alpha: 0.35);
    final bannerBorder = isHigh
        ? AppColors.statusPending.withValues(alpha: 0.5)
        : AppColors.statusAvailable.withValues(alpha: 0.5);
    final iconColor = isHigh ? AppColors.statusPending : AppColors.statusAvailable;
    final iconData = isHigh ? Icons.warning_amber_rounded : Icons.verified_user_rounded;
    final titleText = isHigh
        ? 'Perhatian: Indikator Risiko No-Show Tinggi ($percentage%)'
        : 'Indikator Risiko No-Show Terkendali ($percentage% - Rendah)';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bannerBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bannerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                iconData,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  titleText,
                  style: TextStyle(
                    color: iconColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            isHigh
                ? 'Berdasarkan model Logistic Regression, profil pemohon memiliki probabilitas no-show tinggi ($percentage%). Verifikasi komitmen kehadiran diperlukan.'
                : 'Berdasarkan model Logistic Regression, rekam jejak pemohon sangat baik dengan probabilitas mangkir hanya $percentage%.',
            style: const TextStyle(
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
