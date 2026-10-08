import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/date_formatter.dart';
import '../models/room_model.dart';
import '../models/reservation_model.dart';
import '../services/supabase_service.dart';
import '../widgets/shimmer_loading.dart';
import 'booking_form_screen.dart';

class AvailabilityCalendarScreen extends StatefulWidget {
  final String? initialRoomId;

  const AvailabilityCalendarScreen({super.key, this.initialRoomId});

  @override
  State<AvailabilityCalendarScreen> createState() =>
      _AvailabilityCalendarScreenState();
}

class _AvailabilityCalendarScreenState
    extends State<AvailabilityCalendarScreen> {
  DateTime _selectedDate = DateTime.now();
  String? _selectedRoomId;
  List<RoomModel> _rooms = [];
  List<ReservationModel> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _selectedRoomId = widget.initialRoomId;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final rooms = await SupabaseService.getRooms();
    final resvs = await SupabaseService.getAllReservations();

    if (mounted) {
      setState(() {
        _rooms = rooms;
        if (_selectedRoomId == null && rooms.isNotEmpty) {
          _selectedRoomId = rooms.first.id;
        }
        _reservations = resvs;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 7)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme.copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.surface,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  // Generate hourly slot list (08:00 - 18:00)
  List<Map<String, dynamic>> _generateTimeSlots() {
    final slots = <Map<String, dynamic>>[];
    for (int hour = 8; hour < 18; hour++) {
      final start = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour,
        0,
      );
      final end = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        hour + 1,
        0,
      );

      // Check overlap with approved reservations
      ReservationModel? bookedRes;
      for (final r in _reservations) {
        if (r.roomId == _selectedRoomId &&
            r.status == 'APPROVED' &&
            start.isBefore(r.endTime) &&
            end.isAfter(r.startTime)) {
          bookedRes = r;
          break;
        }
      }

      slots.add({
        'startHour': '${hour.toString().padLeft(2, '0')}:00',
        'endHour': '${(hour + 1).toString().padLeft(2, '0')}:00',
        'start': start,
        'end': end,
        'isBooked': bookedRes != null,
        'reservation': bookedRes,
      });
    }
    return slots;
  }

  @override
  Widget build(BuildContext context) {
    final selectedRoom = _rooms.firstWhere(
      (r) => r.id == _selectedRoomId,
      orElse: () => _rooms.isNotEmpty
          ? _rooms.first
          : RoomModel(
              id: '',
              name: 'Memuat...',
              building: '',
              floor: 1,
              capacity: 0,
              facilities: [],
              status: 'ACTIVE',
              openingHour: '08:00',
              closingHour: '18:00',
            ),
    );

    final dateFormatted = DateFormatterIndo.formatFull(_selectedDate);

    final timeSlots = _generateTimeSlots();
    final availableCount = timeSlots.where((s) => !s['isBooked']).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Cek Ketersediaan & Slot Kalender'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? ListView(
              padding: const EdgeInsets.all(16),
              children: const [
                ShimmerMetricCard(),
                SizedBox(height: 16),
                ShimmerMetricCard(),
                SizedBox(height: 16),
                ShimmerReservationCard(),
              ],
            )
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Room Selector Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pilih Ruangan Fasilitas:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRoomId,
                          dropdownColor: AppColors.surfaceVariant,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 12),
                            prefixIcon: Icon(Icons.meeting_room_outlined),
                          ),
                          items: _rooms.map((r) {
                            return DropdownMenuItem<String>(
                              value: r.id,
                              child: Text(
                                '${r.name} (${r.capacity} Kursi)',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedRoomId = val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Date Picker Strip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                color: AppColors.primaryLight,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tanggal Ditinjau',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textMuted,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  dateFormatted,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickDate,
                          icon: const Icon(Icons.edit_calendar_outlined,
                              size: 16),
                          label: const Text('Ganti'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.surfaceVariant,
                            foregroundColor: AppColors.textPrimary,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summary Strip
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.statusAvailableBg.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.statusAvailable.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  size: 16, color: AppColors.statusAvailable),
                              const SizedBox(width: 6),
                              Text(
                                '$availableCount Slot Bebas Bentrok',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.statusAvailable,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.statusRejectedBg.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.statusRejected.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.cancel_rounded,
                                  size: 16, color: AppColors.statusRejected),
                              const SizedBox(width: 6),
                              Text(
                                '${10 - availableCount} Slot Terpakai',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.statusRejected,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Jadwal Slot Jam (08:00 - 18:00 WIB)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Hourly Slot Cards
                  ...timeSlots.map((slot) {
                    final isBooked = slot['isBooked'] as bool;
                    final res = slot['reservation'] as ReservationModel?;
                    final timeRange =
                        '${slot['startHour']} - ${slot['endHour']} WIB';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isBooked
                            ? AppColors.surface.withValues(alpha: 0.6)
                            : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isBooked
                              ? AppColors.statusRejected.withValues(alpha: 0.3)
                              : AppColors.borderSubtle,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Clock range
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: isBooked
                                  ? AppColors.statusRejectedBg.withValues(alpha: 0.4)
                                  : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              timeRange,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isBooked
                                    ? AppColors.statusRejected
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Slot Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: isBooked
                                            ? AppColors.statusRejected
                                            : AppColors.statusAvailable,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isBooked
                                          ? 'Terpakai / Terisi'
                                          : 'Tersedia / Siap Dipesan',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: isBooked
                                            ? AppColors.statusRejected
                                            : AppColors.statusAvailable,
                                      ),
                                    ),
                                  ],
                                ),
                                if (isBooked && res != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    '${res.purpose} (${res.organization})',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),

                          // Action CTA
                          if (!isBooked)
                            ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => BookingFormScreen(
                                      preselectedRoom: selectedRoom,
                                      initialDate: _selectedDate,
                                      initialStartHour: slot['startHour'],
                                      initialEndHour: slot['endHour'],
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 8),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              child: const Text('Pesan Slot'),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Bentrok',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
    );
  }
}
