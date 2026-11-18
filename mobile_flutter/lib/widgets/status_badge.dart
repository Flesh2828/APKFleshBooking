import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable Status Badge untuk status semantik:
/// - AVAILABLE / ACTIVE (Emerald)
/// - BOOKED / APPROVED (Rose/Emerald)
/// - PENDING / MENUNGGU (Amber)
/// - MAINTENANCE / PERBAIKAN / CANCELLED (Cool Slate)
/// - REJECTED (Rose)
class StatusBadge extends StatelessWidget {
  final String status;
  final String? customLabel;
  final bool showDot;
  final bool isCompact;

  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.showDot = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final normalized = status.toUpperCase().trim();

    Color solidColor;
    Color bgColor;
    Color borderColor;
    Color textColor;
    IconData? icon;
    String displayLabel;

    switch (normalized) {
      case 'AVAILABLE':
      case 'ACTIVE':
        solidColor = AppColors.statusAvailable;
        bgColor = AppColors.statusAvailableBg;
        borderColor = AppColors.statusAvailableBorder;
        textColor = AppColors.statusAvailableText;
        icon = Icons.check_circle_rounded;
        displayLabel = customLabel ?? (normalized == 'ACTIVE' ? 'SIAP DIPESAN' : 'AVAILABLE');
        break;

      case 'BOOKED':
        solidColor = AppColors.statusBooked;
        bgColor = AppColors.statusBookedBg;
        borderColor = AppColors.statusBookedBorder;
        textColor = AppColors.statusBookedText;
        icon = Icons.lock_rounded;
        displayLabel = customLabel ?? 'BOOKED';
        break;

      case 'APPROVED':
        solidColor = AppColors.statusAvailable;
        bgColor = AppColors.statusAvailableBg;
        borderColor = AppColors.statusAvailableBorder;
        textColor = AppColors.statusAvailableText;
        icon = Icons.verified_rounded;
        displayLabel = customLabel ?? 'APPROVED';
        break;

      case 'PENDING':
        solidColor = AppColors.statusPending;
        bgColor = AppColors.statusPendingBg;
        borderColor = AppColors.statusPendingBorder;
        textColor = AppColors.statusPendingText;
        icon = Icons.hourglass_top_rounded;
        displayLabel = customLabel ?? 'PENDING';
        break;

      case 'MAINTENANCE':
        solidColor = AppColors.statusMaintenance;
        bgColor = AppColors.statusMaintenanceBg;
        borderColor = AppColors.statusMaintenanceBorder;
        textColor = AppColors.statusMaintenanceText;
        icon = Icons.build_rounded;
        displayLabel = customLabel ?? 'MAINTENANCE';
        break;

      case 'REJECTED':
        solidColor = AppColors.statusRejected;
        bgColor = AppColors.statusRejectedBg;
        borderColor = AppColors.statusRejectedBorder;
        textColor = AppColors.statusRejectedText;
        icon = Icons.cancel_rounded;
        displayLabel = customLabel ?? 'DITOLAK';
        break;

      case 'CANCELLED':
      default:
        solidColor = AppColors.statusCancelled;
        bgColor = AppColors.statusCancelledBg;
        borderColor = AppColors.statusMaintenanceBorder;
        textColor = AppColors.statusMaintenanceText;
        icon = Icons.block_rounded;
        displayLabel = customLabel ?? normalized;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 7 : 10,
        vertical: isCompact ? 3 : 4.5,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: solidColor.withValues(alpha: 0.10),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: isCompact ? 5 : 6,
              height: isCompact ? 5 : 6,
              decoration: BoxDecoration(
                color: solidColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
          ] else ...[
            Icon(icon, size: isCompact ? 10 : 12, color: solidColor),
            const SizedBox(width: 4),
          ],
          Text(
            displayLabel,
            style: TextStyle(
              fontSize: isCompact ? 9 : 10.5,
              fontWeight: FontWeight.w800,
              color: textColor,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
