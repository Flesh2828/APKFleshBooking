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
      'RoomBook',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Brand Logo & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        gradient: AppColors.tealGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brandTeal.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.meeting_room_rounded,
                        size: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          titles[safeIndex],
                          style: GoogleFonts.plusJakartaSans(
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        if (safeIndex == 0)
                          Text(
                            'Campus Facilities Portal',
                            style: GoogleFonts.plusJakartaSans(
                              fontWeight: FontWeight.w500,
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),

                // Right Profile & Role Chip (Taps to Tab 4 Profile)
                InkWell(
                  onTap: () => _onTabSelected(4),
                  borderRadius: BorderRadius.circular(20),
                  child: GlassSurface(
                    tier: GlassTier.pill,
                    borderRadius: BorderRadius.circular(20),
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircleAvatar(
                          radius: 11,
                          backgroundColor: AppColors.brandTeal,
                          child: Text(
                            _currentUser.name.isNotEmpty
                                ? _currentUser.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAdmin ? 'Admin' : _currentUser.roleLabel,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandTealDark,
                          ),
                        ),
                      ],
                    ),
                  ),
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
