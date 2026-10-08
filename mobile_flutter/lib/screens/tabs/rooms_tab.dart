import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../models/room_model.dart';
import '../../services/supabase_service.dart';
import '../../widgets/shimmer_loading.dart';
import '../booking_form_screen.dart';
import '../availability_calendar_screen.dart';

class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  List<RoomModel> _rooms = [];
  bool _isLoading = true;
  String _searchQuery = '';

  // Filter state
  String _selectedBuilding = 'Semua';
  String _selectedCapacityRange = 'Semua';
  String _selectedStatus = 'Semua';

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    setState(() => _isLoading = true);
    final data = await SupabaseService.getRooms();
    if (mounted) {
      setState(() {
        _rooms = data;
        _isLoading = false;
      });
    }
  }

  List<RoomModel> get _filteredRooms {
    return _rooms.where((room) {
      // Search
      final matchesSearch = room.name
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          room.building.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          room.facilities
              .any((f) => f.toLowerCase().contains(_searchQuery.toLowerCase()));
      if (!matchesSearch) return false;

      // Building filter
      if (_selectedBuilding != 'Semua' &&
          !room.building.toLowerCase().contains(_selectedBuilding.toLowerCase())) {
        return false;
      }

      // Capacity filter
      if (_selectedCapacityRange == '< 50' && room.capacity >= 50) return false;
      if (_selectedCapacityRange == '50 - 100' &&
          (room.capacity < 50 || room.capacity > 100)) {
        return false;
      }
      if (_selectedCapacityRange == '> 100' && room.capacity <= 100) return false;

      // Status filter
      if (_selectedStatus != 'Semua' && room.status != _selectedStatus) {
        return false;
      }

      return true;
    }).toList();
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final buildings = [
              'Semua',
              'Gedung Rektorat',
              'Gedung Sains & Teknologi',
              'Gedung Perkuliahan Bersama',
              'Gedung Student Center',
              'Gedung Perpustakaan Pusat',
            ];

            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Katalog Ruangan',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Building Filter
                  const Text(
                    'Lokasi Gedung Kampus',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: buildings.map((b) {
                      final isSelected = _selectedBuilding == b;
                      return ChoiceChip(
                        label: Text(b),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceVariant,
                        labelStyle: TextStyle(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        onSelected: (val) {
                          setModalState(() => _selectedBuilding = b);
                          setState(() => _selectedBuilding = b);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Capacity Range
                  const Text(
                    'Kapasitas Peserta',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: ['Semua', '< 50', '50 - 100', '> 100'].map((cap) {
                      final isSelected = _selectedCapacityRange == cap;
                      return ChoiceChip(
                        label: Text(cap),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surfaceVariant,
                        labelStyle: TextStyle(
                          fontSize: 12,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                        onSelected: (val) {
                          setModalState(() => _selectedCapacityRange = cap);
                          setState(() => _selectedCapacityRange = cap);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Reset & Apply Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedBuilding = 'Semua';
                              _selectedCapacityRange = 'Semua';
                              _selectedStatus = 'Semua';
                            });
                            setState(() {
                              _selectedBuilding = 'Semua';
                              _selectedCapacityRange = 'Semua';
                              _selectedStatus = 'Semua';
                            });
                          },
                          child: const Text('Reset Filter'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Terapkan Filter'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari nama ruang, fasilitas, gedung...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () =>
                                  setState(() => _searchQuery = ''),
                            )
                          : null,
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: _openFilterBottomSheet,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: (_selectedBuilding != 'Semua' ||
                              _selectedCapacityRange != 'Semua')
                          ? AppColors.primary
                          : AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Active filter chip indicators
          if (_selectedBuilding != 'Semua' || _selectedCapacityRange != 'Semua')
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Text(
                    'Filter aktif: ',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  if (_selectedBuilding != 'Semua')
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: Chip(
                        label: Text(_selectedBuilding,
                            style: const TextStyle(fontSize: 10)),
                        backgroundColor: AppColors.surfaceVariant,
                        padding: EdgeInsets.zero,
                        onDeleted: () =>
                            setState(() => _selectedBuilding = 'Semua'),
                      ),
                    ),
                  if (_selectedCapacityRange != 'Semua')
                    Chip(
                      label: Text('Kap: $_selectedCapacityRange',
                          style: const TextStyle(fontSize: 10)),
                      backgroundColor: AppColors.surfaceVariant,
                      padding: EdgeInsets.zero,
                      onDeleted: () =>
                          setState(() => _selectedCapacityRange = 'Semua'),
                    ),
                ],
              ),
            ),

          // Catalog List View
          Expanded(
            child: _isLoading
                ? ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: 4,
                    itemBuilder: (_, __) => const ShimmerRoomCard(),
                  )
                : _filteredRooms.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off_rounded,
                                size: 54, color: AppColors.textMuted),
                            SizedBox(height: 12),
                            Text(
                              'Tidak ada ruangan yang cocok',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Coba sesuaikan kata kunci pencarian atau reset filter.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadRooms,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _filteredRooms.length,
                          itemBuilder: (context, index) {
                            return _buildRoomCard(_filteredRooms[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomCard(RoomModel room) {
    final isReady = room.status == 'ACTIVE';

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Room Image with Overlays
          Stack(
            children: [
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 170,
                  width: double.infinity,
                  child: room.imageUrl != null && room.imageUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: room.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: AppColors.surfaceVariant,
                            child: const Icon(Icons.broken_image_rounded,
                                size: 40, color: AppColors.textMuted),
                          ),
                        )
                      : Container(
                          color: AppColors.surfaceVariant,
                          child: const Icon(Icons.meeting_room_rounded,
                              size: 40, color: AppColors.textMuted),
                        ),
                ),
              ),

              // Gradient Scrim
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Capacity Badge (Top Left)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.65),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt_rounded,
                          size: 13, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        '${room.capacity} Peserta',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Status Badge (Top Right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isReady
                        ? AppColors.statusAvailableBg.withValues(alpha: 0.85)
                        : AppColors.statusPendingBg.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isReady
                          ? AppColors.statusAvailable
                          : AppColors.statusPending,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isReady
                              ? AppColors.statusAvailable
                              : AppColors.statusPending,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isReady ? 'Siap Dipesan' : 'Perawatan',
                        style: TextStyle(
                          color: isReady
                              ? AppColors.statusAvailable
                              : AppColors.statusPending,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Floor & Building (Bottom Left on Image)
              Positioned(
                bottom: 12,
                left: 12,
                right: 12,
                child: Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 14, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        room.building,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black87),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content Details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (room.description != null && room.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    room.description!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 10),

                // Operational Hours Strip
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Text(
                      'Operasional: ${room.openingHour} - ${room.closingHour} WIB',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Facility Chips
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: room.facilities.take(4).map((f) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        f,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 16),

                // Action Buttons: Cek Jadwal & Booking
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AvailabilityCalendarScreen(
                                initialRoomId: room.id,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.calendar_today_outlined,
                            size: 15),
                        label: const Text('Cek Jadwal'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isReady
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
                        icon: const Icon(Icons.bookmark_add_rounded, size: 15),
                        label: const Text('Booking'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(vertical: 11),
                          textStyle: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
