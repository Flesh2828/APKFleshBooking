import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/room_model.dart';
import '../services/supabase_service.dart';
import '../widgets/shimmer_loading.dart';
import 'booking_form_screen.dart';

class RoomListScreen extends StatelessWidget {
  const RoomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Daftar Ruangan'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Keluar',
            onPressed: () async {
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<RoomModel>>(
        stream: SupabaseService.getRoomsRealtimeStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: 4,
              itemBuilder: (_, __) => const ShimmerRoomCard(),
            );
          }

          final rooms = snapshot.data ?? [];
          if (rooms.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada data ruangan',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              final isAvailable = room.status == 'ACTIVE';

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderSubtle),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              room.name,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isAvailable
                                  ? AppColors.statusAvailableBg.withValues(alpha: 0.4)
                                  : AppColors.statusPendingBg.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isAvailable
                                    ? AppColors.statusAvailable
                                    : AppColors.statusPending,
                              ),
                            ),
                            child: Text(
                              isAvailable ? 'Siap Dipesan' : 'Perawatan',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isAvailable
                                    ? AppColors.statusAvailable
                                    : AppColors.statusPending,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${room.building} (Lantai ${room.floor}) • Kapasitas: ${room.capacity} orang',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: room.facilities.map((f) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              f,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
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
                            backgroundColor: AppColors.primary,
                          ),
                          child: const Text('Ajukan Booking'),
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
    );
  }
}
