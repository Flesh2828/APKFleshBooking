import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUser();
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

  @override
  Widget build(BuildContext context) {
    final isAdminOrDosen = _currentUser.isAdmin || _currentUser.role == 'DOSEN';

    // 5 Primary Navigation Tabs
    final List<Widget> screens = [
      HomeTab(
        userProfile: _currentUser,
        onNavigateToTab: _onTabSelected,
      ),
      const RoomsTab(),
      const AvailabilityCalendarScreen(),
      const MyReservationsTab(),
      isAdminOrDosen
          ? const ApprovalsTab()
          : ProfileTab(
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
      'Reservasi Saya',
      isAdminOrDosen ? 'Persetujuan Pengajuan' : 'Profil Civitas',
    ];

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.welcomeGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.meeting_room_rounded,
                  size: 18, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              titles[safeIndex],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        actions: [
          // Profile & Role Chip Button in AppBar
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('Profil & Akun')),
                      body: ProfileTab(
                        userProfile: _currentUser,
                        onProfileUpdated: () {
                          setState(() => _currentUser = SupabaseService.currentUser);
                        },
                      ),
                    ),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 11,
                      backgroundColor: AppColors.primary,
                      child: Text(
                        _currentUser.name.isNotEmpty
                            ? _currentUser.name[0].toUpperCase()
                            : 'U',
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _currentUser.roleLabel,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const BookingFormScreen(),
            ),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Booking',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 6,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: safeIndex,
          onDestinationSelected: _onTabSelected,
          backgroundColor: AppColors.surface,
          indicatorColor: AppColors.primary.withValues(alpha: 0.2),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: AppColors.textMuted),
              selectedIcon:
                  Icon(Icons.dashboard_rounded, color: AppColors.primaryLight),
              label: 'Beranda',
            ),
            const NavigationDestination(
              icon: Icon(Icons.domain_outlined, color: AppColors.textMuted),
              selectedIcon:
                  Icon(Icons.domain_rounded, color: AppColors.primaryLight),
              label: 'Ruangan',
            ),
            const NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined,
                  color: AppColors.textMuted),
              selectedIcon: Icon(Icons.calendar_month_rounded,
                  color: AppColors.primaryLight),
              label: 'Kalender',
            ),
            const NavigationDestination(
              icon: Icon(Icons.bookmark_border_rounded,
                  color: AppColors.textMuted),
              selectedIcon: Icon(Icons.bookmark_rounded,
                  color: AppColors.primaryLight),
              label: 'Reservasi',
            ),
            NavigationDestination(
              icon: Icon(
                isAdminOrDosen
                    ? Icons.fact_check_outlined
                    : Icons.person_outline_rounded,
                color: AppColors.textMuted,
              ),
              selectedIcon: Icon(
                isAdminOrDosen
                    ? Icons.fact_check_rounded
                    : Icons.person_rounded,
                color: AppColors.primaryLight,
              ),
              label: isAdminOrDosen ? 'Persetujuan' : 'Profil',
            ),
          ],
        ),
      ),
    );
  }
}
