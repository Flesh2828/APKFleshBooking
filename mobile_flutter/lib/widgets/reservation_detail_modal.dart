import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/reservation_model.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../services/supabase_service.dart';

class ReservationDetailModal extends StatelessWidget {
  final ReservationModel reservation;
  final bool isAdmin;
  final VoidCallback? onActionCompleted;

  const ReservationDetailModal({
    super.key,
    required this.reservation,
    this.isAdmin = false,
    this.onActionCompleted,
  });

  static void show(
    BuildContext context, {
    required ReservationModel reservation,
    bool isAdmin = false,
    VoidCallback? onActionCompleted,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReservationDetailModal(
        reservation: reservation,
        isAdmin: isAdmin,
        onActionCompleted: onActionCompleted,
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return AppColors.statusAvailable;
      case 'PENDING':
        return AppColors.statusPending;
      case 'REJECTED':
        return AppColors.statusRejected;
      case 'CANCELLED':
      default:
        return AppColors.statusCancelled;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Disetujui';
      case 'PENDING':
        return 'Menunggu Review';
      case 'REJECTED':
        return 'Ditolak';
      case 'CANCELLED':
        return 'Dibatalkan';
      case 'COMPLETED':
        return 'Selesai';
      default:
        return status;
    }
  }

  void _previewAttachment(BuildContext context, String attachment) {
    final cleanAttachment = attachment.trim();
    final lower = cleanAttachment.toLowerCase();
    final isImage = lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');

    // Cek bytes di cache in-memory SupabaseService
    final bytes = SupabaseService.getAttachmentBytes(cleanAttachment) ??
        SupabaseService.getAttachmentBytes(reservation.id);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.borderSubtle),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isImage ? Icons.image_rounded : Icons.description_rounded,
                        color: AppColors.primaryLight,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cleanAttachment,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Dokumen Lampiran Pengajuan Surat Izin',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),

              // Content Body (Interactive Viewer)
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      if (bytes != null) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: Image.memory(
                              Uint8List.fromList(bytes),
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _buildFallbackDocumentCard(cleanAttachment),
                            ),
                          ),
                        ),
                      ] else if (cleanAttachment.startsWith('http')) ...[
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.borderSubtle),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: Image.network(
                              cleanAttachment,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => _buildFallbackDocumentCard(cleanAttachment),
                            ),
                          ),
                        ),
                      ] else ...[
                        _buildFallbackDocumentCard(cleanAttachment),
                      ],
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.verified_user_rounded,
                                size: 16, color: AppColors.statusAvailable),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Berkas valid diajukan oleh: ${reservation.userName} (${reservation.organization})',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.surfaceElevated,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Tutup Pratinjau'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackDocumentCard(String filename) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.file_present_rounded,
              size: 48,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            filename,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'Format Dokumen Resmi Disertifikasi Sistem',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline_rounded,
                    size: 15, color: AppColors.statusAvailable),
                SizedBox(width: 6),
                Flexible(
                  child: Text(
                    'Lampiran siap diverifikasi untuk persetujuan ruangan',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.statusAvailable,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDecision(BuildContext context, bool isApprove) async {
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
            color: isApprove ? AppColors.statusAvailable : AppColors.statusRejected,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${reservation.roomDisplayName}\nOleh: ${reservation.userName} (${reservation.organization})',
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
              backgroundColor:
                  isApprove ? AppColors.statusAvailable : AppColors.statusRejected,
            ),
            child: Text(isApprove ? 'Setujui' : 'Tolak'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      if (isApprove) {
        await SupabaseService.approveReservation(
          reservation.id,
          reason: reasonController.text.trim().isNotEmpty
              ? reasonController.text.trim()
              : null,
        );
      } else {
        await SupabaseService.rejectReservation(
          reservation.id,
          reason: reasonController.text.trim(),
        );
      }

      if (context.mounted) {
        Navigator.pop(context); // Close bottom sheet
        onActionCompleted?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isApprove
                  ? 'Pengajuan ${reservation.id} berhasil disetujui!'
                  : 'Pengajuan ${reservation.id} telah ditolak.',
            ),
            backgroundColor:
                isApprove ? AppColors.statusAvailable : AppColors.statusRejected,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(reservation.status);
    final isPending = reservation.status.toUpperCase() == 'PENDING';
    final attachment = reservation.attachmentInfo;
    final cleanNotes = reservation.cleanNotes;

    final startFormatted = DateFormatterIndo.formatDateTime(reservation.startTime);
    final endFormatted = DateFormatterIndo.formatTime(reservation.endTime);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 14,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderHighlight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Modal Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      reservation.id,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: AppColors.primaryLight,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor),
                    ),
                    child: Text(
                      _getStatusLabel(reservation.status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 18),

            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Purpose
                    Text(
                      reservation.purpose,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Diajukan oleh: ${reservation.userName} (${reservation.organization})',
                      style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 16),

                    // ML Recommendation Banner if available
                    if (reservation.autoCategory != null ||
                        reservation.approvalRecommendation != null ||
                        reservation.isHighRiskNoShow == true) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.auto_awesome, size: 14, color: Colors.amberAccent),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Analisis Cerdas Machine Learning (AI Assist)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.amberAccent,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: [
                                if (reservation.autoCategory != null)
                                  _buildTag('🏷️ Kategori: ${reservation.autoCategory}'),
                                if (reservation.approvalRecommendation == 'AUTO_APPROVE')
                                  _buildTag('⚡ Rekomendasi: Siap Disetujui',
                                      color: AppColors.statusAvailable),
                                if (reservation.isHighRiskNoShow == true)
                                  _buildTag('⚠️ Risiko No-Show Tinggi',
                                      color: AppColors.statusPending),
                                if (reservation.estimatedEnergyKwh != null)
                                  _buildTag('💡 Estimasi: ${reservation.estimatedEnergyKwh} kWh'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Info Section Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        children: [
                          _buildDetailRow(
                            Icons.meeting_room_outlined,
                            'Ruangan',
                            reservation.roomDisplayName,
                          ),
                          const Divider(height: 18),
                          _buildDetailRow(
                            Icons.schedule_rounded,
                            'Jadwal Acara',
                            '$startFormatted - $endFormatted WIB',
                          ),
                          const Divider(height: 18),
                          _buildDetailRow(
                            Icons.group_outlined,
                            'Kapasitas & Peserta',
                            '${reservation.participantCount} Orang Terdaftar',
                          ),
                          if (reservation.additionalFacilities != null &&
                              reservation.additionalFacilities!.isNotEmpty) ...[
                            const Divider(height: 18),
                            _buildDetailRow(
                              Icons.devices_other_rounded,
                              'Fasilitas Ekstra',
                              reservation.additionalFacilities!,
                            ),
                          ],
                          if (cleanNotes != null && cleanNotes.isNotEmpty) ...[
                            const Divider(height: 18),
                            _buildDetailRow(
                              Icons.notes_rounded,
                              'Catatan Khusus',
                              cleanNotes,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // SECTION BERKAS / LAMPIRAN (Focus on User Request!)
                    const Text(
                      'Lampiran Dokumen & Surat Izin',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),

                    if (attachment != null && attachment.isNotEmpty) ...[
                      InkWell(
                        onTap: () => _previewAttachment(context, attachment),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceVariant,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.attach_file_rounded,
                                  color: AppColors.primaryLight,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      attachment,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    const Text(
                                      'Ketuk untuk membuka dan meninjau berkas',
                                      style: TextStyle(fontSize: 11, color: AppColors.primaryLight),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: () => _previewAttachment(context, attachment),
                                icon: const Icon(Icons.visibility_rounded, size: 14),
                                label: const Text('Buka'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline_rounded, size: 18, color: AppColors.textMuted),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Tidak ada dokumen lampiran tambahan yang disertakan.',
                                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),

            // Action Buttons for Admin or Requester
            if (isAdmin && isPending) ...[
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.border, width: 1)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleDecision(context, false),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.statusRejected,
                          side: const BorderSide(color: AppColors.statusRejected),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Tolak Pengajuan'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _handleDecision(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.statusAvailable,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Setujui Pengajuan'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.textMuted),
        const SizedBox(width: 10),
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text, {Color? color}) {
    final effectiveColor = color ?? AppColors.primaryLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: effectiveColor.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: effectiveColor,
        ),
      ),
    );
  }
}
