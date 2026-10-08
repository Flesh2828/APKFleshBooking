import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';
import '../../services/mock_data.dart';

class ProfileTab extends StatelessWidget {
  final UserModel? userProfile;
  final VoidCallback? onProfileUpdated;

  const ProfileTab({
    super.key,
    required this.userProfile,
    this.onProfileUpdated,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusRejected,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupabaseService.signOut();
      if (context.mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    }
  }

  void _switchUser(BuildContext context, UserModel user) {
    SupabaseService.setCurrentUser(user);
    onProfileUpdated?.call();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Beralih akun ke: ${user.name} (${user.roleLabel})'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = userProfile ?? SupabaseService.currentUser;
    final name = user.name;
    final email = user.email;
    final role = user.roleLabel;
    final dept = user.department ?? 'Fakultas / Unit Kampus';
    final phone = user.phone ?? '0812-3456-7890';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            // Avatar & Name Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: AppColors.welcomeGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        name.isNotEmpty ? name[0].toUpperCase() : 'U',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    email,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: AppColors.primaryLight.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Text(
                      role,
                      style: const TextStyle(
                        color: AppColors.primaryLight,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Detail User Strip
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Civitas Akademika',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildInfoRow(Icons.business_rounded, 'Unit / Fakultas', dept),
                  const Divider(height: 20),
                  _buildInfoRow(Icons.phone_rounded, 'Nomor Kontak', phone),
                  const Divider(height: 20),
                  _buildInfoRow(
                    Icons.security_rounded,
                    'Tipe Otentikasi',
                    'SSO Terintegrasi (Supabase & Google Cloud)',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick Switcher Demo Accounts
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.swap_horiz_rounded,
                          size: 18, color: AppColors.statusPending),
                      SizedBox(width: 8),
                      Text(
                        'Ganti Peran Akun Demo',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Pilih akun untuk menguji hak akses (Mahasiswa, Dosen, Admin):',
                    style:
                        TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),
                  ...SeedData.demoUsers.map((u) {
                    final isCurrent = u.id == user.id;
                    return InkWell(
                      onTap: () => _switchUser(context, u),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCurrent
                                ? AppColors.primary
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.name,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isCurrent
                                        ? FontWeight.bold
                                        : FontWeight.w600,
                                    color: isCurrent
                                        ? AppColors.primaryLight
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  u.roleLabel,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            if (isCurrent)
                              const Icon(Icons.check_circle_rounded,
                                  color: AppColors.primaryLight, size: 18)
                            else
                              const Text(
                                'Pilih',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            OutlinedButton.icon(
              onPressed: () => _handleLogout(context),
              icon: const Icon(Icons.logout_rounded,
                  size: 18, color: AppColors.statusRejected),
              label: const Text(
                'Keluar dari Aplikasi',
                style: TextStyle(
                  color: AppColors.statusRejected,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.statusRejected),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
