import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class DarkShimmer extends StatelessWidget {
  final Widget child;

  const DarkShimmer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      child: child,
    );
  }
}

class ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

class ShimmerMetricCard extends StatelessWidget {
  const ShimmerMetricCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DarkShimmer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const ShimmerBox(width: 44, height: 10),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ShimmerBox(width: 26, height: 22, borderRadius: 6),
                ShimmerBox(width: 34, height: 14, borderRadius: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerRoomCard extends StatelessWidget {
  const ShimmerRoomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DarkShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 180,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 140, height: 12),
                  SizedBox(height: 8),
                  ShimmerBox(width: 220, height: 18),
                  SizedBox(height: 12),
                  Row(
                    children: [
                      ShimmerBox(width: 80, height: 24, borderRadius: 20),
                      SizedBox(width: 8),
                      ShimmerBox(width: 90, height: 24, borderRadius: 20),
                      SizedBox(width: 8),
                      ShimmerBox(width: 70, height: 24, borderRadius: 20),
                    ],
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: ShimmerBox(width: double.infinity, height: 42, borderRadius: 12)),
                      SizedBox(width: 10),
                      Expanded(child: ShimmerBox(width: double.infinity, height: 42, borderRadius: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ShimmerReservationCard extends StatelessWidget {
  const ShimmerReservationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return DarkShimmer(
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 110, height: 14),
                ShimmerBox(width: 70, height: 22, borderRadius: 12),
              ],
            ),
            SizedBox(height: 14),
            ShimmerBox(width: 200, height: 16),
            SizedBox(height: 8),
            ShimmerBox(width: 160, height: 12),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: ShimmerBox(width: double.infinity, height: 38, borderRadius: 10)),
                SizedBox(width: 10),
                Expanded(child: ShimmerBox(width: double.infinity, height: 38, borderRadius: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
