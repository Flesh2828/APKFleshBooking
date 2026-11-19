import 'dart:async';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../models/reservation_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/reservation_detail_modal.dart';

class ApprovalsTab extends StatefulWidget {
  const ApprovalsTab({super.key});

  @override
  State<ApprovalsTab> createState() => _ApprovalsTabState();
}

class _ApprovalsTabState extends State<ApprovalsTab> {
  List<ReservationModel> _pendingReservations = [];
  bool _isLoading = true;
  StreamSubscription<List<ReservationModel>>? _reservationsSub;

  @override
  void initState() {
    super.initState();
    _fetchPendingReservations();
    _reservationsSub = SupabaseService.getReservationsStream().listen((all) {
      if (mounted) {
        setState(() {
          _pendingReservations =
              all.where((r) => r.status.toUpperCase() == 'PENDING').toList();
          _isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _reservationsSub?.cancel();
    super.dispose();
  }

  Future<void> _fetchPendingReservations() async {
    if (_pendingReservations.isEmpty) {
      _pendingReservations = SupabaseService.cachedReservations
          .where((r) => r.status.toUpperCase() == 'PENDING')
          .toList();
      if (_pendingReservations.isNotEmpty && _isLoading) {
        setState(() => _isLoading = false);
      }
    }
    final all = await SupabaseService.getAllReservations();
    if (mounted) {
      setState(() {
        _pendingReservations =
            all.where((r) => r.status.toUpperCase() == 'PENDING').toList();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleDecision(ReservationModel resv, bool isApprove) async {
    if (!SupabaseService.currentUser.isAdmin) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akses ditolak: Hanya Admin yang berhak menyetujui pengajuan'),
          backgroundColor: AppColors.statusRejected,
        ),
      );
      return;
    }

    final reasonController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        title: Text(
          isApprove ? 'Setujui Pengajuan?' : 'Tolak Pengajuan?',
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
              '${resv.roomDisplayName}\nOleh: ${resv.userName} (${resv.organization})',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: isApprove
                    ? 'Catatan Persetujuan (Opsional)'
                    : 'Alasan Penolakan (Wajib) *',
                hintText: isApprove
                    ? 'cth: Kunci diambil di pos keamanan'
                    : 'cth: Ruangan dipakai agenda rektorat',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (!isApprove && reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alasan penolakan harus diisi'),
                    backgroundColor: AppColors.statusPending,
                  ),
                );
                return;
              }
              Navigator.pop(ctx, true);
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

    if (confirmed == true) {
      if (isApprove) {
        await SupabaseService.approveReservation(
          resv.id,
          reason: reasonController.text.trim().isNotEmpty
              ? reasonController.text.trim()
              : null,
        );
      } else {
        await SupabaseService.rejectReservation(
          resv.id,
          reason: reasonController.text.trim(),
        );
      }
      _fetchPendingReservations();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApprove
                  ? 'Reservasi ${resv.id} berhasil disetujui!'
                  : 'Reservasi ${resv.id} telah ditolak.',
            ),
            backgroundColor: isApprove
                ? AppColors.statusAvailable
                : AppColors.statusRejected,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!SupabaseService.currentUser.isAdmin) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.gpp_bad_rounded,
                    size: 56, color: AppColors.statusRejected),
                SizedBox(height: 16),
                Text(
                  'Akses Khusus Administrator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Halaman persetujuan reservasi hanya dapat diakses oleh akun Admin Pengelola Sarpras.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 3,
              itemBuilder: (_, __) => const ShimmerReservationCard(),
            )
          : _pendingReservations.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline_rounded,
                          size: 56, color: AppColors.statusAvailable),
                      SizedBox(height: 12),
                      Text(
                        'Semua Pengajuan Telah Ditinjau',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Tidak ada antrean pending saat ini.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchPendingReservations,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    itemCount: _pendingReservations.length,
                    itemBuilder: (context, index) {
                      final resv = _pendingReservations[index];
                      final startFormatted =
                          DateFormatterIndo.formatDateTime(resv.startTime);
                      final endFormatted =
                          DateFormatterIndo.formatTime(resv.endTime);

                      final attachment = resv.attachmentInfo;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.statusPending.withValues(alpha: 0.4),
                          ),
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
                            reservation: resv,
                            isAdmin: true,
                            onActionCompleted: _fetchPendingReservations,
                          ),
                          borderRadius: BorderRadius.circular(18),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.15),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                                      ),
                                      child: Text(
                                        resv.id,
                                        style: const TextStyle(
                                          fontFamily: 'monospace',
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryLight,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.statusPendingBg
                                            .withValues(alpha: 0.3),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                            color: AppColors.statusPending),
                                      ),
                                      child: const Text(
                                        'Menunggu Review',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.statusPending,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  resv.purpose,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Pemohon: ${resv.userName} (${resv.organization}) • ${resv.participantCount} Orang',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceVariant,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.meeting_room_outlined,
                                          size: 15, color: AppColors.primaryLight),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${resv.roomDisplayName} ($startFormatted - $endFormatted WIB)',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Highlight Lampiran Berkas if attached
                                if (attachment != null && attachment.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.35)),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.attach_file_rounded, size: 16, color: AppColors.primaryLight),
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
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.amberAccent.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'Buka Berkas',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.amberAccent,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 14),
                                Row(
                                  children: [
                                    OutlinedButton.icon(
                                      onPressed: () => ReservationDetailModal.show(
                                        context,
                                        reservation: resv,
                                        isAdmin: true,
                                        onActionCompleted: _fetchPendingReservations,
                                      ),
                                      icon: const Icon(Icons.visibility_outlined, size: 14),
                                      label: const Text('Detail'),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.primaryLight,
                                        side: const BorderSide(color: AppColors.borderSubtle),
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const Spacer(),
                                    OutlinedButton(
                                      onPressed: () =>
                                          _handleDecision(resv, false),
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppColors.statusRejected,
                                        side: const BorderSide(
                                            color: AppColors.statusRejected),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 14, vertical: 8),
                                      ),
                                      child: const Text('Tolak'),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () =>
                                          _handleDecision(resv, true),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.statusAvailable,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                      ),
                                      child: const Text('Setujui'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
