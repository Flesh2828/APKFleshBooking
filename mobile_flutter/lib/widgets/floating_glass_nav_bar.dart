import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'glass_surface.dart';

/// Floating Frosted Glass Bottom Navigation Bar dengan Center FAB dan Dynamic Role Tab.
/// Mengacu ke DESIGN.md Section 5.1 dan referensi Google Stitch.
class FloatingGlassNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback? onFabPressed;
  final bool isAdmin;
  final int pendingCount;

  const FloatingGlassNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    this.onFabPressed,
    required this.isAdmin,
    this.pendingCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: GlassSurface(
        tier: GlassTier.dock,
        borderRadius: BorderRadius.circular(28),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Tab 0: Beranda
            Expanded(
              child: _buildNavItem(
                index: 0,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard_rounded,
                label: 'Beranda',
              ),
            ),

            // Tab 1: Ruangan
            Expanded(
              child: _buildNavItem(
                index: 1,
                icon: Icons.meeting_room_outlined,
                activeIcon: Icons.meeting_room_rounded,
                label: 'Ruangan',
              ),
            ),

            // Tab 2: Kalender
            Expanded(
              child: _buildNavItem(
                index: 2,
                icon: Icons.calendar_month_outlined,
                activeIcon: Icons.calendar_month_rounded,
                label: 'Kalender',
              ),
            ),

            // Tab 3: Dinamis (Admin: Persetujuan, Non-Admin: Reservasi)
            Expanded(
              child: _buildNavItem(
                index: 3,
                icon: isAdmin
                    ? Icons.fact_check_outlined
                    : Icons.bookmark_border_rounded,
                activeIcon: isAdmin
                    ? Icons.fact_check_rounded
                    : Icons.bookmark_rounded,
                label: isAdmin ? 'Persetujuan' : 'Reservasi',
                badgeCount: pendingCount,
              ),
            ),

            // Tab 4: Profil
            Expanded(
              child: _buildNavItem(
                index: 4,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'Profil',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    int badgeCount = 0,
  }) {
    final isSelected = currentIndex == index;

    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandIndigo.withValues(alpha: 0.10)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? AppColors.brandIndigo : AppColors.textMuted,
                ),
                if (badgeCount > 0)
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppColors.statusPending,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        badgeCount > 9 ? '9+' : '$badgeCount',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? AppColors.brandIndigo : AppColors.textMuted,
                letterSpacing: -0.1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

