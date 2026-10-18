import 'package:flutter/material.dart';
import '../models/ml_prediction_model.dart';
import '../theme/app_theme.dart';

class MlEnergyOccupancyCard extends StatelessWidget {
  final LinearRegressionResult linearResult;

  const MlEnergyOccupancyCard({super.key, required this.linearResult});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics_outlined, size: 14, color: AppColors.primaryLight),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Estimasi Sumber Daya (Linear Regression)',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.electric_bolt_rounded,
                  iconColor: const Color(0xFFFBBF24),
                  value: '${linearResult.estimatedEnergyKwh} kWh',
                  label: 'Estimasi Daya Listrik',
                ),
              ),
              Container(
                height: 28,
                width: 1,
                color: AppColors.borderSubtle,
              ),
              Expanded(
                child: _buildMetricTile(
                  icon: Icons.hourglass_top_rounded,
                  iconColor: const Color(0xFF818CF8),
                  value: '${linearResult.predictedWeeklyOccupancyHours} Jam',
                  label: 'Prediksi Okupansi/Minggu',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
