import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/date_formatter.dart';
import '../../models/reservation_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/shimmer_loading.dart';

class ApprovalsTab extends StatefulWidget {
  const ApprovalsTab({super.key});

  @override
  State<ApprovalsTab> createState() => _ApprovalsTabState();
}

class _ApprovalsTabState extends State<ApprovalsTab> {
  List<ReservationModel> _pendingReservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingReservations();
  }

  Future<void> _fetchPendingReservations() async {
    setState(() => _isLoading = true);
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
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingReservations.length,
                    itemBuilder: (context, index) {
                      final resv = _pendingReservations[index];
                      final startFormatted =
                          DateFormatterIndo.formatDateTime(resv.startTime);
                      final endFormatted =
                          DateFormatterIndo.formatTime(resv.endTime);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: AppColors.statusPending.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  resv.id,
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryLight,
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
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                OutlinedButton(
                                  onPressed: () =>
                                      _handleDecision(resv, false),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.statusRejected,
                                    side: const BorderSide(
                                        color: AppColors.statusRejected),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                  ),
                                  child: const Text('Tolak'),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () =>
                                      _handleDecision(resv, true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusAvailable,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 8),
                                  ),
                                  child: const Text('Setujui'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
