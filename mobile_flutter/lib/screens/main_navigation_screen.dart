import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../models/reservation_model.dart';
import '../services/supabase_service.dart';
import '../widgets/glass_surface.dart';
import '../widgets/floating_glass_nav_bar.dart';
import 'tabs/home_tab.dart';
import 'tabs/rooms_tab.dart';
import 'tabs/my_reservations_tab.dart';
import 'tabs/approvals_tab.dart';
import 'tabs/profile_tab.dart';
import 'availability_calendar_screen.dart';
import 'booking_form_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  UserModel _currentUser = SupabaseService.currentUser;
  StreamSubscription<UserModel>? _userSubscription;
  StreamSubscription<List<ReservationModel>>? _reservationsSubscription;
  int _pendingCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _userSubscription = SupabaseService.userStream.listen((updatedUser) {
      if (mounted) {
        setState(() {
          _currentUser = updatedUser;
        });
      }
    });

    // Realtime listener untuk badge counter antrean pending
    _reservationsSubscription = SupabaseService.getReservationsStream().listen((all) {
      if (mounted) {
        final pending = _currentUser.isAdmin
            ? all.where((r) => r.status.toUpperCase() == 'PENDING').length
            : all.where((r) => r.userId == _currentUser.id && r.status.toUpperCase() == 'PENDING').length;
        setState(() {
          _pendingCount = pending;
        });
      }
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    _reservationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final profile = await SupabaseService.getCurrentUserProfile();
    if (mounted && profile != null) {
      setState(() {
        _currentUser = profile;
      });
    }
  }

  void _onTabSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _openBookingForm() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BookingFormScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = _currentUser.isAdmin;

    // 5 Primary Navigation Tabs strictly segmented by Role:
    // Admin: [Beranda, Ruangan, Kalender, Persetujuan, Profil]
    // Mahasiswa / Dosen / Staf: [Beranda, Ruangan, Kalender, Reservasi Saya, Profil]
    final List<Widget> screens = [
      HomeTab(
        userProfile: _currentUser,
        onNavigateToTab: _onTabSelected,
      ),
      const RoomsTab(),
      const AvailabilityCalendarScreen(),
      isAdmin ? const ApprovalsTab() : const MyReservationsTab(),
      ProfileTab(
        userProfile: _currentUser,
        onProfileUpdated: () {
          setState(() => _currentUser = SupabaseService.currentUser);
        },
      ),
    ];

    final List<String> titles = [
      'GuildSpace',
      'Katalog Ruangan',
      'Kalender Ketersediaan',
      isAdmin ? 'Persetujuan Pengajuan' : 'Reservasi Saya',
      isAdmin ? 'Profil Pengelola' : 'Profil Civitas',
    ];

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      extendBody: true, // Memungkinkan frosted glass dock membias konten di belakangnya
      backgroundColor: AppColors.canvasMeshStart,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                // Brand Logo & Title (Wrapped in Expanded to prevent any overflow)
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.brandIndigo.withValues(alpha: 0.25),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'GS',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 12.5,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              titles[safeIndex],
                              style: GoogleFonts.plusJakartaSans(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                                color: AppColors.textPrimary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (safeIndex == 0)
                              Text(
                                'Smart Hub & Space Management',
                                style: GoogleFonts.plusJakartaSans(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 10,
                                  color: AppColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),

                // Right Actions: + Ajukan Button & Profile Chip
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // + Ajukan Booking Quick Action Button
                    Container(
                      height: 28,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandIndigo.withValues(alpha: 0.25),
                            blurRadius: 4,
                            offset: const Offset(0, 1.5),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: _openBookingForm,
                          borderRadius: BorderRadius.circular(14),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_rounded, size: 14, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'Ajukan',
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),

                    // Profile & Role Chip (Taps to Tab 4 Profile)
                    InkWell(
                      onTap: () => _onTabSelected(4),
                      borderRadius: BorderRadius.circular(18),
                      child: GlassSurface(
                        tier: GlassTier.pill,
                        borderRadius: BorderRadius.circular(18),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 9.5,
                              backgroundColor: AppColors.brandIndigo,
                              child: Text(
                                _currentUser.name.isNotEmpty
                                    ? _currentUser.name[0].toUpperCase()
                                    : 'U',
                                style: const TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isAdmin ? 'Admin' : _currentUser.roleLabel,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.brandIndigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: MeshCanvasBackground(
        child: IndexedStack(
          index: safeIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: FloatingGlassNavBar(
        currentIndex: safeIndex,
        onTabSelected: _onTabSelected,
        onFabPressed: _openBookingForm,
        isAdmin: isAdmin,
        pendingCount: _pendingCount,
      ),
    );
  }
}
