import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../models/room_model.dart';
import '../../models/reservation_model.dart';
import '../../models/user_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../booking_form_screen.dart';
import '../availability_calendar_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);
    final rooms = await SupabaseService.getRooms();
    final resvs = await SupabaseService.getAllReservations();

    if (mounted) {
      setState(() {
        _rooms = rooms;
        _reservations = resvs;
        _isLoading = false;
      });
    }
  }

  void _showApprovalDialog(ReservationModel res, bool isApprove) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          isApprove ? 'Setujui Reservasi' : 'Tolak Reservasi',
          style: TextStyle(
            color: isApprove
                ? AppColors.statusAvailable
                : AppColors.statusRejected,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${res.purpose} (${res.organization})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isApprove
                  ? 'Konfirmasi persetujuan penggunaan ruangan untuk kegiatan ini?'
                  : 'Berikan alasan penolakan agar pemohon dapat mengetahuinya:',
              style:
                  const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: AppColors.textPrimary),
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
            child: const Text('Batal'),
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
            child: Text(isApprove ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.userProfile ?? SupabaseService.currentUser;
    final isAdminOrDosen = user.isAdmin || user.role == 'DOSEN';

    // Metrics computation
    final activeRoomsCount = _rooms.where((r) => r.status == 'ACTIVE').length;
    final pendingReservations =
        _reservations.where((r) => r.status == 'PENDING').toList();
    final approvedReservations =
        _reservations.where((r) => r.status == 'APPROVED').toList();

    // Today's bookings
    final now = DateTime.now();
    final todayBookings = _reservations.where((r) {
      return r.status == 'APPROVED' &&
          r.startTime.year == now.year &&
          r.startTime.month == now.month &&
          r.startTime.day == now.day;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. HERO BANNER GRADIENT
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.welcomeGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome,
                              size: 13, color: Colors.amberAccent),
                          SizedBox(width: 6),
                          Text(
                            'Sistem Manajemen & Booking Ruangan Terpusat',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Greeting
                    Text(
                      'Selamat Datang, ${user.name}!',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isAdminOrDosen
                          ? 'Kelola ketersediaan fasilitas kampus, pantau penggunaan ruangan, dan tindak lanjuti pengajuan pemesanan yang masuk secara real-time.'
                          : 'Temukan ruangan ideal untuk kegiatan akademik, perkuliahan hibrida, maupun agenda organisasi Anda dengan validasi bebas bentrok.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.9),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Quick CTA Buttons
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const BookingFormScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_circle_outline_rounded,
                              size: 16),
                          label: const Text('Ajukan Booking Sekarang'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF4338CA),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const AvailabilityCalendarScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.calendar_month_outlined,
                              size: 16, color: Colors.white),
                          label: const Text('Cek Kalender Jadwal',
                              style: TextStyle(color: Colors.white)),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.4)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 2. METRIC CARDS GRID
              if (_isLoading)
                const Column(
                  children: [
                    Row(
                      children: [
                        Expanded(child: ShimmerMetricCard()),
                        SizedBox(width: 12),
                        Expanded(child: ShimmerMetricCard()),
                      ],
                    ),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: ShimmerMetricCard()),
                        SizedBox(width: 12),
                        Expanded(child: ShimmerMetricCard()),
                      ],
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Total Ruangan Aktif',
                            value: '$activeRoomsCount',
                            subtitle: 'Siap Digunakan',
                            icon: Icons.meeting_room_outlined,
                            iconColor: AppColors.primaryLight,
                            iconBg: AppColors.primary.withValues(alpha: 0.15),
                            onTap: () => widget.onNavigateToTab(1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Pengajuan Pending',
                            value: '${pendingReservations.length}',
                            subtitle: 'Menunggu review',
                            icon: Icons.schedule_rounded,
                            iconColor: AppColors.statusPending,
                            iconBg: AppColors.statusPendingBg.withValues(alpha: 0.3),
                            onTap: () => widget.onNavigateToTab(
                                isAdminOrDosen ? 4 : 3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Reservasi Disetujui',
                            value: '${approvedReservations.length}',
                            subtitle: 'Terverifikasi',
                            icon: Icons.check_circle_outline_rounded,
                            iconColor: AppColors.statusAvailable,
                            iconBg: AppColors.statusAvailableBg.withValues(alpha: 0.3),
                            onTap: () => widget.onNavigateToTab(3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMetricCard(
                            title: 'Jadwal Hari Ini',
                            value: '${todayBookings.length}',
                            subtitle: 'Sesi berlangsung',
                            icon: Icons.event_available_rounded,
                            iconColor: AppColors.statusCompleted,
                            iconBg: AppColors.statusCompletedBg.withValues(alpha: 0.3),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const AvailabilityCalendarScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

              const SizedBox(height: 24),

              // 3. SECTION "PERLU PERSETUJUAN SEGERA" (Khusus Admin / Dosen)
              if (isAdminOrDosen && pendingReservations.isNotEmpty) ...[
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
                          'Perlu Persetujuan Segera (${pendingReservations.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () => widget.onNavigateToTab(4),
                      child: const Text('Lihat Semua'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                ...pendingReservations.take(3).map((res) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              res.id,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                            Text(
                              DateFormatterIndo.formatDayTime(res.startTime),
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          res.purpose,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${res.organization} • ${res.roomDisplayName}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => _showApprovalDialog(res, false),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.statusRejected,
                                side: const BorderSide(
                                    color: AppColors.statusRejected),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text('Tolak'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              onPressed: () => _showApprovalDialog(res, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.statusAvailable,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                              child: const Text('Setujui'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 20),
              ],

              // 4. SPOTLIGHT RUANGAN UNGGULAN
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Katalog Fasilitas Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.onNavigateToTab(1),
                    child: const Text('Lihat Semua &rarr;'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              ..._rooms.take(2).map((room) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.domain_rounded,
                            color: AppColors.primaryLight),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              room.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${room.building} • Kapasitas ${room.capacity}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => BookingFormScreen(
                                preselectedRoom: room,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 11),
                        ),
                        child: const Text('Booking'),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
