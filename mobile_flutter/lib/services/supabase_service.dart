import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';
import '../models/reservation_model.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // ==========================================
  // AUTHENTICATION
  // ==========================================

  static User? get currentUser => client.auth.currentUser;
  static bool get isAuthenticated => currentUser != null;

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  // ==========================================
  // ROOMS (FETCH & REALTIME STREAM)
  // ==========================================

  // Mendapatkan daftar ruangan (Query Statis)
  static Future<List<RoomModel>> getRooms() async {
    final response = await client
        .from('rooms')
        .select()
        .order('name', ascending: true);

    return (response as List).map((e) => RoomModel.fromJson(e)).toList();
  }

  // Mendapatkan stream realtime ruangan (otomatis terupdate jika ada perubahan)
  static Stream<List<RoomModel>> getRoomsRealtimeStream() {
    return client
        .from('rooms')
        .stream(primaryKey: ['id'])
        .order('name', ascending: true)
        .map((list) => list.map((e) => RoomModel.fromJson(e)).toList());
  }

  // ==========================================
  // RESERVATIONS (EDGE FUNCTIONS & QUERIES)
  // ==========================================

  /// Memanggil Supabase Edge Function `create-reservation`
  /// Edge Function ini melakukan verifikasi bentrok jadwal secara atomic di server.
  static Future<Map<String, dynamic>> createReservationViaEdgeFunction({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
    required String organization,
    required int participantCount,
    String? additionalFacilities,
    String? notes,
  }) async {
    final payload = {
      'roomId': roomId,
      'startTime': startTime.toUtc().toIso8601String(),
      'endTime': endTime.toUtc().toIso8601String(),
      'purpose': purpose,
      'organization': organization,
      'participantCount': participantCount,
      if (additionalFacilities != null) 'additionalFacilities': additionalFacilities,
      if (notes != null) 'notes': notes,
    };

    // Memanggil Supabase Edge Function
    final FunctionResponse res = await client.functions.invoke(
      'create-reservation',
      body: payload,
    );

    if (res.status >= 200 && res.status < 300) {
      return Map<String, dynamic>.from(res.data);
    } else {
      final errorMsg = res.data?['error'] ?? 'Gagal membuat reservasi (Kode: ${res.status})';
      throw Exception(errorMsg);
    }
  }

  /// Ambil reservasi milik user yang sedang login
  static Future<List<ReservationModel>> getUserReservations() async {
    final userId = currentUser?.id;
    if (userId == null) return [];

    final response = await client
        .from('reservations')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((e) => ReservationModel.fromJson(e)).toList();
  }

  /// Memanggil Edge Function `approve-reservation` (khusus role Admin)
  static Future<void> approveReservationViaEdgeFunction({
    required String reservationId,
    required String action, // 'APPROVED' atau 'REJECTED'
    String? reason,
  }) async {
    final res = await client.functions.invoke(
      'approve-reservation',
      body: {
        'reservationId': reservationId,
        'action': action,
        'reason': reason,
      },
    );

    if (res.status < 200 || res.status >= 300) {
      throw Exception(res.data?['error'] ?? 'Gagal memperbarui status');
    }
  }
}
