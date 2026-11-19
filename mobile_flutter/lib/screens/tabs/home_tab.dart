import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../models/room_model.dart';
import '../../models/reservation_model.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/reservation_detail_modal.dart';
import '../../widgets/glass_surface.dart';
import '../../widgets/status_badge.dart';
import '../booking_form_screen.dart';

class HomeTab extends StatefulWidget {
  final UserModel? userProfile;
  final Function(int) onNavigateToTab;

  const HomeTab({
    super.key,
    required this.userProfile,
    required this.onNavigateToTab,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<RoomModel> _rooms = [];
  List<ReservationModel> _reservations = [];
  bool _isLoading = true;
  StreamSubscription<List<ReservationModel>>? _resvSubscription;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _resvSubscription = SupabaseService.getReservationsStream().listen((updatedList) {
      if (mounted) {
        setState(() {
          _reservations = updatedList;
        });
      }
    });
  }

  @override
  void dispose() {
    _resvSubscription?.cancel();
    super.dispose();
  }

  Future<void> _fetchDashboardData() async {
    // 1. Tampilkan data dari cache instan (0ms First Frame Render!)
    if (_rooms.isEmpty) {
      _rooms = SupabaseService.cachedRooms;
    }
    if (_reservations.isEmpty) {
      _reservations = SupabaseService.cachedReservations;
    }
    if (_rooms.isNotEmpty && _isLoading) {
      setState(() => _isLoading = false);
    }

    // 2. Refresh data Supabase secara paralel di background
    try {
      final results = await Future.wait([
        SupabaseService.getRooms(),
        SupabaseService.getAllReservations(),
      ]);

      if (mounted) {
        setState(() {
          _rooms = results[0] as List<RoomModel>;
          _reservations = results[1] as List<ReservationModel>;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showApprovalDialog(ReservationModel res, bool isApprove) {
    final user = widget.userProfile ?? SupabaseService.currentUser;
    if (!user.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya Admin yang berhak menyetujui pengajuan'),
          backgroundColor: AppColors.statusRejected,
        ),
      );
      return;
    }

    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border),
        ),
        title: Text(
          isApprove ? 'Setujui Reservasi' : 'Tolak Reservasi',
          style: GoogleFonts.plusJakartaSans(
            color: isApprove
                ? AppColors.statusAvailable
                : AppColors.statusRejected,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${res.purpose} (${res.organization})',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isApprove
                  ? 'Konfirmasi persetujuan penggunaan ruangan untuk kegiatan ini?'
                  : 'Berikan alasan penolakan agar pemohon dapat mengetahuinya:',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
              decoration: InputDecoration(
                hintText: isApprove
                    ? 'Catatan persetujuan (opsional)'
                    : 'Alasan penolakan *',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              if (isApprove) {
                await SupabaseService.approveReservation(
                  res.id,
                  reason: reasonController.text.trim().isNotEmpty
                      ? reasonController.text.trim()
                      : null,
                );
              } else {
                await SupabaseService.rejectReservation(
                  res.id,
                  reason: reasonController.text.trim().isNotEmpty
                      ? reasonController.text.trim()
                      : 'Jadwal ruangan dialokasikan untuk agenda internal kampus.',
                );
              }
              _fetchDashboardData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove
                  ? AppColors.statusAvailable
                  : AppColors.statusRejected,
            ),
            child: Text(
              isApprove ? 'Setujui' : 'Tolak',
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userProfile ?? SupabaseService.currentUser;
    final isAdmin = user.isAdmin;

    // Metrics computation
    final activeRoomsCount = _rooms.where((r) => r.status.toUpperCase() == 'ACTIVE').length;
    final pendingReservations =
        _reservations.where((r) => r.status.toUpperCase() == 'PENDING').toList();
    final approvedReservations =
        _reservations.where((r) => r.status.toUpperCase() == 'APPROVED').toList();

    // User-specific reservations
    final myReservations = _reservations.where((r) => r.userId == user.id).toList();
    final myPending = myReservations.where((r) => r.status.toUpperCase() == 'PENDING').toList();
    final myApproved = myReservations.where((r) => r.status.toUpperCase() == 'APPROVED').toList();
    final myRejected = myReservations.where((r) => r.status.toUpperCase() == 'REJECTED').toList();

    // Next upcoming booking for user
    final now = DateTime.now();
    final nextUpcomingBookings = myApproved.where((r) {
      return r.endTime.isAfter(now);
    }).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final nextBooking = nextUpcomingBookings.isNotEmpty ? nextUpcomingBookings.first : null;

    return RefreshIndicator(
      onRefresh: _fetchDashboardData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. TOP HEADER GREETING, ROLE BADGE & NOTIFICATION
            _buildTopHeader(user, isAdmin, pendingReservations.length),
            const SizedBox(height: 16),

            // 2. 3 GLASS KPI MINI-CARDS (Horizontal Row)
            if (_isLoading)
              const Row(
                children: [
                  Expanded(child: ShimmerMetricCard()),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerMetricCard()),
                  SizedBox(width: 8),
                  Expanded(child: ShimmerMetricCard()),
                ],
              )
            else if (isAdmin)
              _buildAdminKpiGrid(
                activeRooms: activeRoomsCount,
                pendingCount: pendingReservations.length,
                approvedCount: approvedReservations.length,
              )
            else
              _buildUserKpiRow(
                pendingCount: myPending.length,
                approvedCount: myApproved.length,
                rejectedCount: myRejected.length,
              ),
            const SizedBox(height: 18),

            // 3. HERO GLASS CARD: JADWAL PEMAKAIAN BERIKUTNYA (User) OR PERLU PERSETUJUAN (Admin)
            if (isAdmin)
              _buildAdminPendingSection(pendingReservations)
            else
              _buildUserUpcomingSection(nextBooking),
            const SizedBox(height: 20),

            // 4. SPOTLIGHT KATALOG RUANGAN CAROUSEL
            _buildSpotlightCarousel(),
            const SizedBox(height: 16),

            // 5. ML AI AUTO-APPROVAL ENGINE TEASER BANNER
            _buildMlTeaserBanner(),
          ],
        ),
      ),
    );
  }

  // --- SUB-COMPONENTS ---

  Widget _buildTopHeader(UserModel user, bool isAdmin, int pendingAdminCount) {
    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.brandIndigo,
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: -1,
              right: -1,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.statusAvailable,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Halo, ${user.name.split(' ').first} 👋',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.brandEmeraldMint,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.brandEmerald.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      isAdmin ? 'ADMINISTRATOR' : user.roleLabel.toUpperCase(),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.brandEmeraldDark,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      user.department ?? (isAdmin ? 'Sarpras Kampus' : 'Civitas'),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // Notification Bell Button with Ping Indicator
        InkWell(
          onTap: () {
            widget.onNavigateToTab(3);
          },
          borderRadius: BorderRadius.circular(16),
          child: GlassSurface(
            tier: GlassTier.card,
            borderRadius: BorderRadius.circular(16),
            padding: const EdgeInsets.all(10),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(
                  Icons.notifications_outlined,
                  size: 20,
                  color: AppColors.textPrimary,
                ),
                if ((isAdmin && pendingAdminCount > 0) || (!isAdmin && myPendingCount > 0))
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.statusBooked,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  int get myPendingCount {
    final user = widget.userProfile ?? SupabaseService.currentUser;
    return _reservations.where((r) => r.userId == user.id && r.status.toUpperCase() == 'PENDING').length;
  }

  Widget _buildUserKpiRow({
    required int pendingCount,
    required int approvedCount,
    required int rejectedCount,
  }) {
    return Row(
      children: [
        // Pending
        Expanded(
          child: _buildKpiCard(
            title: 'PENDING',
            value: '$pendingCount',
            badgeText: 'Review',
            accentColor: AppColors.statusPending,
            badgeBg: AppColors.statusPendingBg,
            badgeTextColor: AppColors.statusPendingText,
            onTap: () => widget.onNavigateToTab(3),
          ),
        ),
        const SizedBox(width: 8),

        // Disetujui
        Expanded(
          child: _buildKpiCard(
            title: 'DISETUJUI',
            value: '$approvedCount',
            badgeText: 'Siap',
            accentColor: AppColors.statusAvailable,
            badgeBg: AppColors.statusAvailableBg,
            badgeTextColor: AppColors.statusAvailableText,
            onTap: () => widget.onNavigateToTab(3),
          ),
        ),
        const SizedBox(width: 8),

        // Ditolak
        Expanded(
          child: _buildKpiCard(
            title: 'DITOLAK',
            value: '$rejectedCount',
            badgeText: 'Nihil',
            accentColor: AppColors.textMuted,
            badgeBg: AppColors.statusMaintenanceBg,
            badgeTextColor: AppColors.statusMaintenanceText,
            onTap: () => widget.onNavigateToTab(3),
          ),
        ),
      ],
    );
  }

  Widget _buildAdminKpiGrid({
    required int activeRooms,
    required int pendingCount,
    required int approvedCount,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildKpiCard(
            title: 'RUANGAN',
            value: '$activeRooms',
            badgeText: 'Aktif',
            accentColor: AppColors.brandTeal,
            badgeBg: AppColors.brandMint,
            badgeTextColor: AppColors.brandTealDark,
            onTap: () => widget.onNavigateToTab(1),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            title: 'PENDING',
            value: '$pendingCount',
            badgeText: 'Antrean',
            accentColor: AppColors.statusPending,
            badgeBg: AppColors.statusPendingBg,
            badgeTextColor: AppColors.statusPendingText,
            onTap: () => widget.onNavigateToTab(3),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildKpiCard(
            title: 'DISETUJUI',
            value: '$approvedCount',
            badgeText: 'Valid',
            accentColor: AppColors.statusAvailable,
            badgeBg: AppColors.statusAvailableBg,
            badgeTextColor: AppColors.statusAvailableText,
            onTap: () => widget.onNavigateToTab(3),
          ),
        ),
      ],
    );
  }

  Widget _buildKpiCard({
    required String title,
    required String value,
    required String badgeText,
    required Color accentColor,
    required Color badgeBg,
    required Color badgeTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: GlassCard(
        borderRadius: BorderRadius.circular(18),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMuted,
                    letterSpacing: 0.4,
                  ),
                ),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: accentColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    badgeText,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w800,
                      color: badgeTextColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- SECTION: USER UPCOMING BOOKING ---

  Widget _buildUserUpcomingSection(ReservationModel? booking) {
    if (booking == null) {
      return GlassCard(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.brandMint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.event_seat_rounded, color: AppColors.brandTeal, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Belum Ada Agenda Aktif',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Temukan ruangan kosong & ajukan peminjaman sekarang.',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const BookingFormScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle_outline_rounded, size: 16),
                label: const Text('Ajukan Booking Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandTeal,
                  padding: const EdgeInsets.symmetric(vertical: 11),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return GlassCard(
      borderRadius: BorderRadius.circular(24),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title & Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.statusAvailable,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'JADWAL PEMAKAIAN BERIKUTNYA',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
              const StatusBadge(status: 'APPROVED', isCompact: true),
            ],
          ),
          const SizedBox(height: 12),

          // Sub-card details
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        booking.purpose,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        booking.id,
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.door_sliding_outlined, size: 14, color: AppColors.brandTeal),
                    const SizedBox(width: 4),
                    Text(
                      booking.roomDisplayName,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.brandTealDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 10),

                // Date & Time Grid
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.brandMint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.calendar_today_rounded, size: 13, color: AppColors.brandTeal),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'TANGGAL',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                DateFormatterIndo.formatShort(booking.startTime),
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.brandMint,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.access_time_rounded, size: 13, color: AppColors.brandTeal),
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'WAKTU',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              Text(
                                '${DateFormatterIndo.formatTime(booking.startTime)} - ${DateFormatterIndo.formatTime(booking.endTime)} WIB',
                                style: GoogleFonts.jetBrainsMono(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action CTA Row
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => ReservationDetailModal.show(
                    context,
                    reservation: booking,
                    isAdmin: false,
                    onActionCompleted: _fetchDashboardData,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.qr_code_rounded, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          'Lihat Bukti Izin (QR)',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => widget.onNavigateToTab(2),
                borderRadius: BorderRadius.circular(12),
                child: GlassSurface(
                  tier: GlassTier.pill,
                  borderRadius: BorderRadius.circular(12),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_month_outlined, size: 16, color: AppColors.brandTeal),
                      const SizedBox(width: 5),
                      Text(
                        'Kalender',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
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
    );
  }

  // --- SECTION: ADMIN PENDING QUEUE ---

  Widget _buildAdminPendingSection(List<ReservationModel> pendingList) {
    if (pendingList.isEmpty) {
      return GlassCard(
        borderRadius: BorderRadius.circular(22),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.statusAvailableBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.statusAvailable, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semua Pengajuan Telah Ditinjau',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w800,
                      fontSize: 13.5,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    'Tidak ada antrean pending saat ini.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.statusPending,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Perlu Persetujuan (${pendingList.length})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            TextButton(
              onPressed: () => widget.onNavigateToTab(3),
              child: Text(
                'Lihat Semua →',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        ...pendingList.take(3).map((res) {
          final hasAttachment = res.attachmentInfo != null;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              borderRadius: BorderRadius.circular(18),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.brandMint,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          res.id,
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.brandTealDark,
                          ),
                        ),
                      ),
                      Text(
                        DateFormatterIndo.formatDayTime(res.startTime),
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 10.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    res.purpose,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    '${res.organization} • ${res.roomDisplayName}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  if (hasAttachment) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.attach_file_rounded, size: 13, color: AppColors.brandTeal),
                        const SizedBox(width: 4),
                        Text(
                          res.attachmentInfo!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.brandTeal,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      TextButton.icon(
                        onPressed: () => ReservationDetailModal.show(
                          context,
                          reservation: res,
                          isAdmin: true,
                          onActionCompleted: _fetchDashboardData,
                        ),
                        icon: const Icon(Icons.visibility_outlined, size: 14),
                        label: const Text('Detail'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.textMuted,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          textStyle: const TextStyle(fontSize: 11.5),
                        ),
                      ),
                      const Spacer(),
                      OutlinedButton(
                        onPressed: () => _showApprovalDialog(res, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.statusRejected,
                          side: const BorderSide(color: AppColors.statusRejected),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Tolak'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showApprovalDialog(res, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandTeal,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          textStyle: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                        ),
                        child: const Text('Setujui'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- SECTION: SPOTLIGHT ROOMS CAROUSEL ---

  Widget _buildSpotlightCarousel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Spotlight Katalog Ruangan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Fasilitas unggulan siap pakai hari ini',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => widget.onNavigateToTab(1),
              child: Text(
                'Semua →',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.brandTeal,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 195,
          child: _rooms.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  clipBehavior: Clip.none,
                  itemCount: _rooms.length,
                  itemBuilder: (context, index) {
                    final room = _rooms[index];
                    final isAvailable = room.status.toUpperCase() == 'ACTIVE';

                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 12),
                      child: GlassCard(
                        borderRadius: BorderRadius.circular(20),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Photo with status and capacity badges
                            Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: Container(
                                    height: 95,
                                    width: double.infinity,
                                    color: AppColors.surfaceVariant,
                                    child: room.imageUrl != null && room.imageUrl!.isNotEmpty
                                        ? Image.network(
                                            room.imageUrl!,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) => const Icon(
                                              Icons.meeting_room_outlined,
                                              size: 32,
                                              color: AppColors.textMuted,
                                            ),
                                          )
                                        : const Icon(
                                            Icons.meeting_room_outlined,
                                            size: 32,
                                            color: AppColors.textMuted,
                                          ),
                                  ),
                                ),
                                // Gradient Scrim
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.black.withValues(alpha: 0.55),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                // Status Pill
                                Positioned(
                                  top: 6,
                                  left: 6,
                                  child: StatusBadge(
                                    status: room.status,
                                    isCompact: true,
                                  ),
                                ),
                                // Capacity Badge
                                Positioned(
                                  bottom: 6,
                                  right: 6,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.65),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.people_outline, size: 10, color: Colors.white),
                                        const SizedBox(width: 3),
                                        Text(
                                          '${room.capacity} Kursi',
                                          style: GoogleFonts.jetBrainsMono(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Room Title
                            Text(
                              room.name,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${room.building} • Lt. ${room.floor}',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                color: AppColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Spacer(),

                            // Footer row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${room.openingHour} - ${room.closingHour}',
                                  style: GoogleFonts.jetBrainsMono(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                SizedBox(
                                  height: 26,
                                  child: ElevatedButton(
                                    onPressed: isAvailable
                                        ? () {
                                            Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) => BookingFormScreen(
                                                  preselectedRoom: room,
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isAvailable ? AppColors.brandTeal : AppColors.border,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      isAvailable ? 'Pesan' : 'Tutup',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // --- SECTION: ML TEASER BANNER ---

  Widget _buildMlTeaserBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.brandEmeraldMint.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.brandEmerald.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GuildSpace AI Engine (4 Model)',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w800,
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Naive Bayes • SVM • Logistic • Linear Reg',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brandEmerald.withValues(alpha: 0.3)),
            ),
            child: Text(
              '4-ML Active',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: AppColors.brandEmeraldDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
