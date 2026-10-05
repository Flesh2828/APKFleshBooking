import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import 'tabs/home_tab.dart';
import 'tabs/rooms_tab.dart';
import 'tabs/my_reservations_tab.dart';
import 'tabs/approvals_tab.dart';
import 'tabs/profile_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  UserModel? _userProfile;
  bool _isLoadingProfile = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await SupabaseService.getCurrentUserProfile();
    if (mounted) {
      setState(() {
        _userProfile = profile;
        _isLoadingProfile = false;
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
    if (_isLoadingProfile) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('Menyiapkan aplikasi...'),
            ],
          ),
        ),
      );
    }

    final isAdmin = _userProfile?.isAdmin ?? false;

    // List of screens depending on whether user is Admin
    final List<Widget> screens = [
      HomeTab(
        userProfile: _userProfile,
        onNavigateToTab: _onTabSelected,
      ),
      const RoomsTab(),
      const MyReservationsTab(),
      if (isAdmin) const ApprovalsTab(),
      ProfileTab(userProfile: _userProfile),
    ];

    // Titles for AppBar
    final List<String> titles = [
      'RoomBook',
      'Katalog Ruangan',
      'Reservasi Saya',
      if (isAdmin) 'Persetujuan Admin',
      'Profil Akun',
    ];

    // Ensure _currentIndex does not exceed screens length if role changes
    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          titles[safeIndex],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue.shade900,
        actions: [
          if (safeIndex == 0) // On home tab, show notification / refresh action
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Segarkan',
              onPressed: () {
                setState(() {});
              },
            ),
        ],
      ),
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: _onTabSelected,
        elevation: 3,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Beranda',
          ),
          const NavigationDestination(
            icon: Icon(Icons.meeting_room_outlined),
            selectedIcon: Icon(Icons.meeting_room_rounded),
            label: 'Ruangan',
          ),
          const NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note_rounded),
            label: 'Reservasi',
          ),
          if (isAdmin)
            const NavigationDestination(
              icon: Icon(Icons.assignment_turned_in_outlined),
              selectedIcon: Icon(Icons.assignment_turned_in_rounded),
              label: 'Persetujuan',
            ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
