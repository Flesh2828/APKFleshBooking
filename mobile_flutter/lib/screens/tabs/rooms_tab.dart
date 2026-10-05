import 'package:flutter/material.dart';
import '../../models/room_model.dart';
import '../../services/supabase_service.dart';
import '../booking_form_screen.dart';

class RoomsTab extends StatefulWidget {
  const RoomsTab({super.key});

  @override
  State<RoomsTab> createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'ALL'; // 'ALL', 'ACTIVE', 'MAINTENANCE'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search & Filter Header
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search Input
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'Cari nama ruangan atau gedung...',
                  hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, size: 20),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('Semua', 'ALL'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Siap Pakai (Aktif)', 'ACTIVE'),
                    const SizedBox(width: 8),
                    _buildFilterChip('Perbaikan / Maintenance', 'MAINTENANCE'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // List Ruangan (Stream Realtime)
        Expanded(
          child: StreamBuilder<List<RoomModel>>(
            stream: SupabaseService.getRoomsRealtimeStream(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 12),
                        Text(
                          'Gagal memuat data ruangan:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final allRooms = snapshot.data ?? [];
              final searchQuery = _searchController.text.trim().toLowerCase();

              // Filtering
              final filteredRooms = allRooms.where((room) {
                final matchQuery = room.name.toLowerCase().contains(searchQuery) ||
                    room.building.toLowerCase().contains(searchQuery);

                if (_selectedStatusFilter == 'ALL') {
                  return matchQuery;
                } else {
                  return matchQuery && (room.status.toUpperCase() == _selectedStatusFilter);
                }
              }).toList();

              if (filteredRooms.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.meeting_room_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text(
                          'Tidak ada ruangan yang cocok',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          searchQuery.isNotEmpty
                              ? 'Coba gunakan kata kunci pencarian yang berbeda.'
                              : 'Belum ada ruangan dengan status ini.',
                          style: const TextStyle(color: Colors.grey, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        if (searchQuery.isNotEmpty || _selectedStatusFilter != 'ALL') ...[
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _selectedStatusFilter = 'ALL');
                            },
                            icon: const Icon(Icons.refresh, size: 16),
                            label: const Text('Reset Filter'),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredRooms.length,
                itemBuilder: (context, index) {
                  final room = filteredRooms[index];
                  final isAvailable = room.status.toUpperCase() == 'ACTIVE';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isAvailable ? Colors.blue.shade100 : Colors.red.shade100,
                      ),
                    ),
                    elevation: 1.5,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isAvailable ? Colors.blue.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.meeting_room_rounded,
                                  color: isAvailable ? Colors.blue.shade700 : Colors.red.shade700,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      room.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${room.building} • Lantai ${room.floor}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isAvailable ? Colors.green.shade50 : Colors.red.shade50,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isAvailable ? Colors.green.shade300 : Colors.red.shade300,
                                  ),
                                ),
                                child: Text(
                                  isAvailable ? 'Tersedia' : 'Maintenance',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: isAvailable ? Colors.green.shade800 : Colors.red.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Metadata row (Kapasitas & Jam Operasional)
                          Row(
                            children: [
                              Icon(Icons.people_outline, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                'Kapasitas: ${room.capacity} Orang',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                              const SizedBox(width: 16),
                              Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                              const SizedBox(width: 4),
                              Text(
                                '${room.openingHour} - ${room.closingHour}',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                              ),
                            ],
                          ),

                          if (room.facilities.isNotEmpty) ...[
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              children: room.facilities.map((fac) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    fac,
                                    style: TextStyle(
                                      color: Colors.blue.shade900,
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: isAvailable
                                  ? () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BookingFormScreen(room: room),
                                        ),
                                      );
                                    }
                                  : null,
                              icon: const Icon(Icons.calendar_month, size: 16),
                              label: Text(isAvailable ? 'Ajukan Peminjaman' : 'Sedang Tidak Tersedia'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
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
          setState(() => _selectedStatusFilter = value);
        }
      },
    );
  }
}
