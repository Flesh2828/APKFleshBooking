import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reservation_model.dart';
import '../../services/supabase_service.dart';

class MyReservationsTab extends StatefulWidget {
  const MyReservationsTab({super.key});

  @override
  State<MyReservationsTab> createState() => _MyReservationsTabState();
}

class _MyReservationsTabState extends State<MyReservationsTab> {
  List<ReservationModel> _reservations = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedStatus = 'ALL'; // 'ALL', 'PENDING', 'APPROVED', 'HISTORY'

  @override
  void initState() {
    super.initState();
    _fetchReservations();
  }

  Future<void> _fetchReservations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await SupabaseService.getUserReservations();
      if (mounted) {
        setState(() {
          _reservations = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelBooking(ReservationModel resv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Batalkan Reservasi?'),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pengajuan peminjaman ruangan ${resv.roomDisplayName} (${resv.id})?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Ya, Batalkan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService.cancelReservation(resv.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Reservasi berhasil dibatalkan'),
              backgroundColor: Colors.orange,
            ),
          );
          _fetchReservations();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal membatalkan: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showDetailDialog(ReservationModel resv) {
    final dateFormat = DateFormat('EEEE, d MMMM yyyy', 'id_ID');
    final timeFormat = DateFormat('HH:mm');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Kode: ${resv.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                _buildStatusBadge(resv.status),
              ],
            ),
            const Divider(height: 24),
            _buildDetailRow('Ruangan', resv.roomDisplayName),
            _buildDetailRow(
              'Tanggal',
              dateFormat.format(resv.startTime),
            ),
            _buildDetailRow(
              'Waktu',
              '${timeFormat.format(resv.startTime)} - ${timeFormat.format(resv.endTime)} WIB',
            ),
            _buildDetailRow('Organisasi / Instansi', resv.organization),
            _buildDetailRow('Keperluan', resv.purpose),
            _buildDetailRow('Jumlah Peserta', '${resv.participantCount} Orang'),
            if (resv.notes != null && resv.notes!.isNotEmpty)
              _buildDetailRow('Catatan', resv.notes!),
            const SizedBox(height: 16),
            if (resv.status.toUpperCase() == 'PENDING') ...[
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _cancelBooking(resv);
                  },
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text(
                    'Batalkan Pengajuan Ini',
                    style: TextStyle(color: Colors.red),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'CANCELLED':
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status.toUpperCase()) {
      case 'APPROVED':
        return 'Disetujui';
      case 'PENDING':
        return 'Menunggu';
      case 'REJECTED':
        return 'Ditolak';
      case 'CANCELLED':
        return 'Dibatalkan';
      default:
        return status;
    }
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        _getStatusLabel(status),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _reservations.where((r) {
      final st = r.status.toUpperCase();
      if (_selectedStatus == 'ALL') return true;
      if (_selectedStatus == 'PENDING') return st == 'PENDING';
      if (_selectedStatus == 'APPROVED') return st == 'APPROVED';
      if (_selectedStatus == 'HISTORY') return st == 'REJECTED' || st == 'CANCELLED' || st == 'COMPLETED';
      return true;
    }).toList();

    return Column(
      children: [
        // Filter bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: Colors.white,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterTab('Semua', 'ALL'),
                const SizedBox(width: 8),
                _buildFilterTab('Menunggu', 'PENDING'),
                const SizedBox(width: 8),
                _buildFilterTab('Disetujui', 'APPROVED'),
                const SizedBox(width: 8),
                _buildFilterTab('Riwayat / Batal', 'HISTORY'),
              ],
            ),
          ),
        ),

        // List
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchReservations,
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _errorMessage != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline, size: 48, color: Colors.red),
                              const SizedBox(height: 12),
                              Text(
                                'Gagal memuat reservasi:\n$_errorMessage',
                                textAlign: TextAlign.center,
                                style: const TextStyle(color: Colors.red),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _fetchReservations,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        ),
                      )
                    : filteredList.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.event_busy_outlined, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tidak Ada Reservasi',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _selectedStatus == 'ALL'
                                        ? 'Anda belum pernah mengajukan peminjaman ruangan.'
                                        : 'Tidak ada data reservasi dengan status ini.',
                                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final resv = filteredList[index];
                              final isPending = resv.status.toUpperCase() == 'PENDING';
                              final dateFormat = DateFormat('dd MMM yyyy', 'id_ID');
                              final timeFormat = DateFormat('HH:mm');

                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: BorderSide(color: Colors.grey.shade200),
                                ),
                                elevation: 1,
                                child: InkWell(
                                  onTap: () => _showDetailDialog(resv),
                                  borderRadius: BorderRadius.circular(14),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              resv.id,
                                              style: TextStyle(
                                                color: Colors.blue.shade800,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            _buildStatusBadge(resv.status),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          resv.roomDisplayName,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Row(
                                          children: [
                                            Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(
                                              dateFormat.format(resv.startTime),
                                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                            ),
                                            const SizedBox(width: 14),
                                            Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${timeFormat.format(resv.startTime)} - ${timeFormat.format(resv.endTime)} WIB',
                                              style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Keperluan: ${resv.purpose}',
                                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        if (isPending) ...[
                                          const SizedBox(height: 12),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: TextButton.icon(
                                              onPressed: () => _cancelBooking(resv),
                                              icon: const Icon(Icons.close, size: 16, color: Colors.red),
                                              label: const Text('Batalkan', style: TextStyle(color: Colors.red, fontSize: 12)),
                                              style: TextButton.styleFrom(
                                                visualDensity: VisualDensity.compact,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String label, String value) {
    final isSelected = _selectedStatus == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: Colors.blue.shade100,
      labelStyle: TextStyle(
        fontSize: 12,
        color: isSelected ? Colors.blue.shade900 : Colors.grey.shade800,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedStatus = value);
        }
      },
    );
  }
}
