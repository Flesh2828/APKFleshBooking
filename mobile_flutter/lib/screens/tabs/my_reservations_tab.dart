import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../models/reservation_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/reservation_detail_modal.dart';
import '../booking_form_screen.dart';

class MyReservationsTab extends StatefulWidget {
  const MyReservationsTab({super.key});

  @override
  State<MyReservationsTab> createState() => _MyReservationsTabState();
}

class _MyReservationsTabState extends State<MyReservationsTab> {
  List<ReservationModel> _reservations = [];
  bool _isLoading = true;
  String _selectedFilter = 'SEMUA'; // 'SEMUA', 'PENDING', 'APPROVED', 'REJECTED', 'CANCELLED'

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    if (_reservations.isEmpty) {
      _reservations = SupabaseService.cachedReservations;
      if (_reservations.isNotEmpty && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
    final data = await SupabaseService.getUserReservations();
    if (mounted) {
      setState(() {
        _reservations = data;
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.statusAvailable;
      case 'IN_USE':
        return AppColors.statusInUse;
      case 'PENDING':
        return AppColors.statusPending;
      case 'REJECTED':
        return AppColors.statusRejected;
      case 'CANCELLED_GHOST':
        return AppColors.statusGhostBooking;
      case 'CANCELLED':
      default:
        return AppColors.statusCancelled;
    }
  }

  Color _getStatusBg(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.statusAvailableBg;
      case 'IN_USE':
        return AppColors.statusInUseBg;
      case 'PENDING':
        return AppColors.statusPendingBg;
      case 'REJECTED':
        return AppColors.statusRejectedBg;
      case 'CANCELLED_GHOST':
        return AppColors.statusGhostBookingBg;
      case 'CANCELLED':
      default:
        return AppColors.statusCancelledBg;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Disetujui';
      case 'IN_USE':
        return 'Aktif Digunakan';
      case 'PENDING':
        return 'Menunggu';
      case 'REJECTED':
        return 'Ditolak';
      case 'CANCELLED_GHOST':
        return 'Dibatalkan (Ghost-Booking)';
      case 'CANCELLED':
        return 'Dibatalkan';
      case 'COMPLETED':
        return 'Selesai';
      default:
        return status;
    }
  }

  void _showQrPassModal(ReservationModel res) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final startFormatted =
            DateFormatterIndo.formatDateTime(res.startTime);
        final endFormatted =
            DateFormatterIndo.formatTime(res.endTime);
        final statusUpper = res.status.toUpperCase();
        final statusColor = _getStatusColor(statusUpper);
        final isApproved = statusUpper == 'APPROVED';
        final isInUse = statusUpper == 'IN_USE';
        final isGhost = statusUpper == 'CANCELLED_GHOST';

        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderHighlight,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          gradient: AppColors.brandGradient,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'GS SMART PASS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Tiket Presensi Digital',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Sistem Presensi Fisik Anti Ghost-Booking • GuildSpace Hub',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // QR Box with Dynamic Payload
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.brandIndigo.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: QrImageView(
                      data: 'GUILDSPACE:PASS:${res.id}:${res.roomId}:${res.status}',
                      version: QrVersions.auto,
                      size: 180.0,
                      backgroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Dynamic Anti Ghost-Booking Countdown Box
                  if (isApproved)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.statusPendingBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.statusPendingBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.statusPending, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Countdown Check-In: 15 Menit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.statusPendingText,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sisa toleransi: 14m 32s sebelum pembatalan otomatis',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.statusPendingText.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isInUse)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.statusInUseBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.statusInUseBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle_rounded, color: AppColors.statusInUse, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Presensi Fisik Terverifikasi',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.statusInUseText,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Ruangan sedang aktif digunakan oleh pemohon.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.statusInUseText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (isGhost)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.statusGhostBookingBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.statusGhostBookingBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error_outline_rounded, color: AppColors.statusGhostBooking, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dibatalkan (Ghost-Booking Terdeteksi)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.statusGhostBookingText,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Tidak ada pemindaian fisik setelah batas toleransi 15 menit habis.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.statusGhostBookingText,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 14),

                  // Ticket Details Strip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'ID Booking',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            Text(
                              res.id,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 14),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Ruangan',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            Expanded(
                              child: Text(
                                res.roomDisplayName,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Jadwal Acara',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '$startFormatted - $endFormatted WIB',
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Status Validasi',
                              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                _getStatusLabel(res.status),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Smart Check-in Simulation Buttons (Only when APPROVED)
                  if (isApproved) ...[
                    const SizedBox(height: 14),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await SupabaseService.checkInReservation(res.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadReservations();
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Check-In Sukses! Ruangan ${res.roomDisplayName} kini Aktif Digunakan.',
                            ),
                            backgroundColor: AppColors.statusInUse,
                          ),
                        );
                      },
                      icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                      label: const Text('Simulasikan Scan Presensi Fisik (Check-In)'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusAvailable,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        await SupabaseService.expireGhostBooking(res.id);
                        if (ctx.mounted) Navigator.pop(ctx);
                        _loadReservations();
                        if (!mounted) return;
                        messenger.showSnackBar(
                          SnackBar(
                            content: Text(
                              'Waktu toleransi habis! Reservasi ${res.id} dibatalkan (Ghost-Booking Terdeteksi).',
                            ),
                            backgroundColor: AppColors.statusGhostBooking,
                          ),
                        );
                      },
                      icon: const Icon(Icons.timer_off_outlined, size: 16),
                      label: const Text('Simulasi Waktu Habis 15 Mnt (Ghost-Booking)'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.statusGhostBooking,
                        side: const BorderSide(color: AppColors.statusGhostBookingBorder),
                        minimumSize: const Size(double.infinity, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: AppColors.textPrimary,
                      minimumSize: const Size(double.infinity, 42),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(color: AppColors.borderSubtle),
                      ),
                    ),
                    child: const Text('Tutup Pass'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleCancel(ReservationModel res) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: const Text(
          'Batalkan Reservasi?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pengajuan "${res.purpose}" (${res.id})?',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.statusRejected),
            child: const Text('Ya, Batalkan'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await SupabaseService.cancelReservation(res.id);
      _loadReservations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reservasi berhasil dibatalkan'),
            backgroundColor: AppColors.statusCancelled,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: StreamBuilder<List<ReservationModel>>(
        stream: SupabaseService.getReservationsStream(),
        builder: (context, snapshot) {
          final allData = snapshot.data ?? _reservations;

          // Apply Filter: Hanya tampilkan reservasi milik akun yang sedang login
          final filtered = allData.where((r) {
            final user = SupabaseService.currentUser;
            final isOwner = (r.userId.isNotEmpty && r.userId == user.id) ||
                (user.email.isNotEmpty &&
                    r.userId.toLowerCase().trim() == user.email.toLowerCase().trim()) ||
                (r.userName.isNotEmpty &&
                    r.userName.toLowerCase().trim() == user.name.toLowerCase().trim());
            if (!isOwner) return false;

            if (_selectedFilter == 'SEMUA') return true;
            if (_selectedFilter == 'CANCELLED') {
              return r.status.toUpperCase() == 'CANCELLED' ||
                  r.status.toUpperCase() == 'CANCELLED_GHOST';
            }
            return r.status.toUpperCase() == _selectedFilter;
          }).toList();

          return Column(
            children: [
              // Segmented Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    _buildFilterChip('SEMUA', 'Semua'),
                    const SizedBox(width: 8),
                    _buildFilterChip('PENDING', 'Menunggu'),
                    const SizedBox(width: 8),
                    _buildFilterChip('APPROVED', 'Disetujui'),
                    const SizedBox(width: 8),
                    _buildFilterChip('IN_USE', 'Aktif Digunakan'),
                    const SizedBox(width: 8),
                    _buildFilterChip('REJECTED', 'Ditolak'),
                    const SizedBox(width: 8),
                    _buildFilterChip('CANCELLED', 'Dibatalkan'),
                  ],
                ),
              ),

              // Reservation List
              Expanded(
                child: _isLoading && allData.isEmpty
                    ? ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: 4,
                        itemBuilder: (_, __) =>
                            const ShimmerReservationCard(),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.bookmark_border_rounded,
                                    size: 56, color: AppColors.textMuted),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum Ada Reservasi',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Pengajuan ruangan yang Anda buat akan muncul di sini.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const BookingFormScreen(),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.add_rounded, size: 18),
                                  label: const Text('Buat Pengajuan Baru'),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: _loadReservations,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 110),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                return _buildReservationCard(filtered[index]);
                              },
                            ),
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedFilter == key;

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: AppColors.primary,
      backgroundColor: AppColors.surface,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected ? Colors.white : AppColors.textSecondary,
      ),
      side: BorderSide(
        color: isSelected ? AppColors.primary : AppColors.borderSubtle,
      ),
      onSelected: (_) {
        setState(() => _selectedFilter = key);
      },
    );
  }

  Widget _buildReservationCard(ReservationModel res) {
    final statusColor = _getStatusColor(res.status);
    final statusBg = _getStatusBg(res.status);
    final isPending = res.status.toUpperCase() == 'PENDING';

    final startFormatted =
        DateFormatterIndo.formatDateTime(res.startTime);
    final endFormatted =
        DateFormatterIndo.formatTime(res.endTime);

    final attachment = res.attachmentInfo;
    final cleanNotes = res.cleanNotes;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => ReservationDetailModal.show(
          context,
          reservation: res,
          isAdmin: false,
          onActionCompleted: _loadReservations,
        ),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Code & Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      res.id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBg.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _getStatusLabel(res.status),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Purpose & Organization
              Text(
                res.purpose,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.group_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${res.organization} (${res.participantCount} Orang)',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // ML Tags Strip (Naive Bayes Category, SVM Recommendation, No-Show Flag, Energy kWh)
              if (res.autoCategory != null ||
                  res.approvalRecommendation != null ||
                  res.isHighRiskNoShow == true) ...[
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (res.autoCategory != null)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.primaryLight.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          '🏷️ ${res.autoCategory}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryLight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (res.approvalRecommendation == 'AUTO_APPROVE')
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.statusAvailableBg.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.statusAvailable.withValues(alpha: 0.5)),
                        ),
                        child: const Text(
                          '⚡ Siap Auto-Approve',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.statusAvailable,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (res.isHighRiskNoShow == true)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.statusPendingBg.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: AppColors.statusPending.withValues(alpha: 0.5)),
                        ),
                        child: const Text(
                          '⚠️ Pantau Kehadiran',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.statusPending,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    if (res.estimatedEnergyKwh != null)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(
                          '⚡ ${res.estimatedEnergyKwh} kWh',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Room & Time Strip
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.meeting_room_outlined,
                            size: 15, color: AppColors.primaryLight),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            res.roomDisplayName,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 15, color: AppColors.textMuted),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$startFormatted - $endFormatted WIB',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
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

              // Attachment Highlight Bar
              if (attachment != null && attachment.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attach_file_rounded, size: 15, color: AppColors.primaryLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Lampiran: $attachment',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Lihat Berkas →',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.amberAccent,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (cleanNotes != null && cleanNotes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Catatan: $cleanNotes',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 14),

              // Action Buttons: Tampilkan QR Pass & Batalkan & Detail
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showQrPassModal(res),
                      icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                      label: const Text('QR Pass'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => ReservationDetailModal.show(
                        context,
                        reservation: res,
                        isAdmin: false,
                        onActionCompleted: _loadReservations,
                      ),
                      icon: const Icon(Icons.info_outline_rounded, size: 15),
                      label: const Text('Detail'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryLight,
                        side: const BorderSide(color: AppColors.borderSubtle),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        textStyle: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  if (isPending) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _handleCancel(res),
                        icon: const Icon(Icons.cancel_outlined, size: 15),
                        label: const Text('Batal'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceElevated,
                          foregroundColor: AppColors.statusRejected,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
