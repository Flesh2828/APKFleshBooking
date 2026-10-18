import 'package:flutter/material.dart';
import '../models/ml_prediction_model.dart';
import '../theme/app_theme.dart';

class MlSmartApprovalBadge extends StatelessWidget {
  final SvmResult svmResult;
  final NaiveBayesResult naiveBayesResult;

  const MlSmartApprovalBadge({
    super.key,
    required this.svmResult,
    required this.naiveBayesResult,
  });

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    Color badgeBg;
    IconData badgeIcon;
    String badgeTitle;

    switch (svmResult.recommendation) {
      case 'AUTO_APPROVE':
        badgeColor = AppColors.statusAvailable;
        badgeBg = AppColors.statusAvailableBg.withValues(alpha: 0.35);
        badgeIcon = Icons.auto_awesome_rounded;
        badgeTitle = 'Layak Disetujui Otomatis (Instant Booking)';
        break;
      case 'AUTO_REJECT':
        badgeColor = AppColors.statusRejected;
        badgeBg = AppColors.statusRejectedBg.withValues(alpha: 0.35);
        badgeIcon = Icons.gpp_bad_rounded;
        badgeTitle = 'Tidak Disarankan / Di luar Ketentuan';
        break;
      default:
        badgeColor = AppColors.statusPending;
        badgeBg = AppColors.statusPendingBg.withValues(alpha: 0.35);
        badgeIcon = Icons.shield_outlined;
        badgeTitle = 'Memerlukan Tinjauan Manual Admin';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: badgeColor.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(badgeIcon, color: badgeColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  badgeTitle,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              // Chip Kategori dari Naive Bayes
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryLight.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.label_outline_rounded,
                      size: 12,
                      color: AppColors.primaryLight,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      naiveBayesResult.predictedCategory,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (naiveBayesResult.isSpam)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.statusRejected, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Deskripsi kegiatan terindikasi kurang spesifik atau tidak valid.',
                      style: TextStyle(
                        color: Colors.red[300],
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (svmResult.decisionReasons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                svmResult.decisionReasons.join(' • '),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
