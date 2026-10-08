import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'mahasiswa@roombook.ac.id');
  final _passwordController = TextEditingController(text: 'mhs123');
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _fillAccount(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan email dan password'),
          backgroundColor: AppColors.statusPending,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await SupabaseService.signIn(email: email, password: password);

      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/main');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login Gagal: ${e.toString()}'),
          backgroundColor: AppColors.statusRejected,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo & Header Brand
                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      gradient: AppColors.welcomeGradient,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.meeting_room_rounded,
                      size: 38,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'RoomBook',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sistem Manajemen & Booking Ruangan Terpadu',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 28),

                // Dark Aesthetic Card Form
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.borderSubtle, width: 1),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Masuk ke Akun Anda',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Email Field
                      TextField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: const InputDecoration(
                          labelText: 'Email Kampus',
                          hintText: 'nama@roombook.ac.id',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        style: const TextStyle(color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Kata Sandi',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),

                      // Submit Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Masuk Sekarang',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Quick Switcher Demo Accounts
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.flash_on_rounded, size: 16, color: AppColors.statusPending),
                          SizedBox(width: 6),
                          Text(
                            'Quick Switcher Akun Demo (Pilih & Klik):',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDemoChip(
                              role: 'Mahasiswa',
                              email: 'mahasiswa@roombook.ac.id',
                              pass: 'mhs123',
                              icon: Icons.school_outlined,
                              accentColor: const Color(0xFF3B82F6),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDemoChip(
                              role: 'Dosen',
                              email: 'dosen@roombook.ac.id',
                              pass: 'dosen123',
                              icon: Icons.person_outline_rounded,
                              accentColor: const Color(0xFF10B981),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _buildDemoChip(
                              role: 'Admin',
                              email: 'admin@roombook.ac.id',
                              pass: 'admin123',
                              icon: Icons.admin_panel_settings_outlined,
                              accentColor: const Color(0xFF8B5CF6),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDemoChip({
    required String role,
    required String email,
    required String pass,
    required IconData icon,
    required Color accentColor,
  }) {
    final isSelected = _emailController.text == email;

    return InkWell(
      onTap: () => _fillAccount(email, pass),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withValues(alpha: 0.2) : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? accentColor : AppColors.borderSubtle,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: accentColor),
            const SizedBox(height: 4),
            Text(
              role,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textSecondary,
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
