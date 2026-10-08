import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/room_model.dart';
import '../models/reservation_model.dart';
import '../models/user_model.dart';
import 'mock_data.dart';

class SupabaseService {
  static final SupabaseClient client = Supabase.instance.client;

  // Active user session state (supports Supabase Auth + Demo Accounts)
  static UserModel _currentUser = SeedData.demoUsers[0]; // Default: Mahasiswa
  static final StreamController<UserModel> _userStreamController =
      StreamController<UserModel>.broadcast();

  // In-memory cache synced with Web parity
  static List<RoomModel> _cachedRooms = List.from(SeedData.initialRooms);
  static List<ReservationModel> _cachedReservations = SeedData.getInitialReservations();

  static final StreamController<List<RoomModel>> _roomsStreamController =
      StreamController<List<RoomModel>>.broadcast();
  static final StreamController<List<ReservationModel>> _reservationsStreamController =
      StreamController<List<ReservationModel>>.broadcast();

  // ==========================================
  // AUTHENTICATION & PROFILES
  // ==========================================

  static UserModel get currentUser => _currentUser;
  static bool get isAuthenticated => true;
  static Stream<UserModel> get userStream => _userStreamController.stream;

  static void setCurrentUser(UserModel user) {
    _currentUser = user;
    _userStreamController.add(_currentUser);
    _notifyReservationsChanged();
  }

  static Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Cek Demo Accounts matching Web
    final demoMatch = SeedData.demoUsers.firstWhere(
      (u) => u.email.toLowerCase() == cleanEmail,
      orElse: () => UserModel(
        id: 'usr-${DateTime.now().millisecondsSinceEpoch}',
        name: cleanEmail.split('@').first,
        email: cleanEmail,
        role: 'MAHASISWA',
        department: 'Civitas Akademika Kampus',
      ),
    );

    // 2. Coba autentikasi Supabase nyata di background (non-blocking jika error RLS/credential)
    try {
      await client.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final profile = await getCurrentUserProfile();
      if (profile != null) {
        _currentUser = profile;
        _userStreamController.add(_currentUser);
        return _currentUser;
      }
    } catch (_) {
      // Jika Supabase auth belum memiliki user tersebut, gunakan demo profile
    }

    _currentUser = demoMatch;
    _userStreamController.add(_currentUser);
    return _currentUser;
  }

  static Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (_) {}
    _currentUser = SeedData.demoUsers[0];
    _userStreamController.add(_currentUser);
  }

  static Future<UserModel?> getCurrentUserProfile() async {
    final sbUser = client.auth.currentUser;
    if (sbUser == null) return _currentUser;

    // Jika email terdaftar sebagai akun demo, gunakan profil demo dengan role yang tepat
    final cleanEmail = sbUser.email?.toLowerCase().trim();
    if (cleanEmail != null) {
      final demoMatches = SeedData.demoUsers.where(
        (u) => u.email.toLowerCase() == cleanEmail,
      );
      if (demoMatches.isNotEmpty) {
        _currentUser = demoMatches.first;
        return _currentUser;
      }
    }

    try {
      final res = await client
          .from('profiles')
          .select()
          .eq('id', sbUser.id)
          .maybeSingle();

      if (res != null) {
        final profile = UserModel.fromJson(res);
        _currentUser = profile;
        return profile;
      }
    } catch (_) {}

    final metaName = sbUser.userMetadata?['name'] as String?;
    final metaRole = sbUser.userMetadata?['role'] as String?;

    final fallback = UserModel(
      id: sbUser.id,
      name: metaName ?? sbUser.email?.split('@').first ?? 'Pengguna',
      email: sbUser.email ?? '',
      role: (metaRole ?? 'MAHASISWA').toUpperCase(),
    );
    _currentUser = fallback;
    return fallback;
  }

  // ==========================================
  // ROOMS (FETCH & REALTIME STREAM)
  // ==========================================

  static Future<List<RoomModel>> getRooms() async {
    try {
      final response = await client
          .from('rooms')
          .select()
          .order('name', ascending: true);

      final list = (response as List).map((e) => RoomModel.fromJson(e)).toList();
      if (list.isNotEmpty) {
        _cachedRooms = list;
        _roomsStreamController.add(_cachedRooms);
        return list;
      }
    } catch (_) {}

    // Fallback data identik dengan web jika data Supabase kosong / anon RLS
    _roomsStreamController.add(_cachedRooms);
    return _cachedRooms;
  }

  static Stream<List<RoomModel>> getRoomsRealtimeStream() {
    getRooms(); // Trigger initial fetch
    return _roomsStreamController.stream;
  }

  // ==========================================
  // RESERVATIONS (FETCH, FILTER & ACTIONS)
  // ==========================================

  static Future<List<ReservationModel>> getAllReservations() async {
    try {
      final response = await client
          .from('reservations')
          .select('*, rooms(*)')
          .order('start_time', ascending: false);

      final list = (response as List).map((e) => ReservationModel.fromJson(e)).toList();
      if (list.isNotEmpty) {
        _cachedReservations = list;
        _reservationsStreamController.add(_cachedReservations);
        return list;
      }
    } catch (_) {}

    _reservationsStreamController.add(_cachedReservations);
    return _cachedReservations;
  }

  static Future<List<ReservationModel>> getUserReservations() async {
    final all = await getAllReservations();
    if (_currentUser.isAdmin) {
      return all;
    }
    return all.where((r) {
      return r.userId == _currentUser.id ||
          (_currentUser.role == 'MAHASISWA' &&
              (r.userId == 'usr-mhs1' || r.userId.startsWith('usr-mhs'))) ||
          (_currentUser.role == 'DOSEN' &&
              (r.userId == 'usr-dosen' || r.userId.startsWith('usr-dosen'))) ||
          r.userName.toLowerCase().trim() == _currentUser.name.toLowerCase().trim();
    }).toList();
  }

  static Stream<List<ReservationModel>> getReservationsStream() {
    getAllReservations();
    return _reservationsStreamController.stream;
  }

  static void _notifyReservationsChanged() {
    _reservationsStreamController.add(List.from(_cachedReservations));
  }

  /// Membuat reservasi baru dengan validasi anti bentrok jadwal
  static Future<ReservationModel> createReservation({
    required String roomId,
    required DateTime startTime,
    required DateTime endTime,
    required String purpose,
    required String organization,
    required int participantCount,
    String? additionalFacilities,
    String? notes,
    String? attachmentFileName,
  }) async {
    // 1. Cek bentrok jadwal lokal/server
    final conflict = _cachedReservations.any((r) {
      if (r.roomId != roomId || r.status != 'APPROVED') return false;
      return startTime.isBefore(r.endTime) && endTime.isAfter(r.startTime);
    });

    if (conflict) {
      throw Exception('Jadwal bentrok dengan kegiatan lain yang telah disetujui pada ruangan ini.');
    }

    final targetRoom = _cachedRooms.firstWhere(
      (r) => r.id == roomId,
      orElse: () => _cachedRooms.first,
    );

    final newId = 'RB-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}-${(_cachedReservations.length + 1).toString().padLeft(3, '0')}';

    final newReservation = ReservationModel(
      id: newId,
      userId: _currentUser.id,
      roomId: roomId,
      userName: _currentUser.name,
      organization: organization,
      startTime: startTime,
      endTime: endTime,
      purpose: purpose,
      participantCount: participantCount,
      additionalFacilities: additionalFacilities,
      notes: notes != null && attachmentFileName != null
          ? '$notes [Lampiran: $attachmentFileName]'
          : notes ?? (attachmentFileName != null ? '[Lampiran: $attachmentFileName]' : null),
      status: 'PENDING',
      createdAt: DateTime.now(),
      room: targetRoom,
    );

    // 2. Simpan ke local cache
    _cachedReservations.insert(0, newReservation);
    _notifyReservationsChanged();

    // 3. Sync ke Supabase Database secara aman
    try {
      await client.from('reservations').insert({
        'id': newId,
        'user_id': _currentUser.id.startsWith('usr-')
            ? '00000000-0000-0000-0000-000000000001'
            : _currentUser.id,
        'room_id': roomId.startsWith('room-')
            ? '00000000-0000-0000-0000-000000000002'
            : roomId,
        'user_name': _currentUser.name,
        'organization': organization,
        'start_time': startTime.toUtc().toIso8601String(),
        'end_time': endTime.toUtc().toIso8601String(),
        'purpose': purpose,
        'participant_count': participantCount,
        'additional_facilities': additionalFacilities,
        'notes': newReservation.notes,
        'status': 'PENDING',
      });
    } catch (_) {
      // Berjalan mulus di mode hybrid
    }

    return newReservation;
  }

  /// Persetujuan Reservasi (Admin / Dosen)
  static Future<void> approveReservation(String id, {String? reason}) async {
    final index = _cachedReservations.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = _cachedReservations[index];
      _cachedReservations[index] = ReservationModel(
        id: old.id,
        userId: old.userId,
        roomId: old.roomId,
        userName: old.userName,
        organization: old.organization,
        startTime: old.startTime,
        endTime: old.endTime,
        purpose: old.purpose,
        participantCount: old.participantCount,
        additionalFacilities: old.additionalFacilities,
        notes: reason != null ? '${old.notes ?? ''} [Disetujui: $reason]' : old.notes,
        status: 'APPROVED',
        createdAt: old.createdAt,
        room: old.room,
      );
      _notifyReservationsChanged();
    }

    try {
      await client
          .from('reservations')
          .update({'status': 'APPROVED'})
          .eq('id', id);
    } catch (_) {}
  }

  /// Penolakan Reservasi (Admin / Dosen)
  static Future<void> rejectReservation(String id, {required String reason}) async {
    final index = _cachedReservations.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = _cachedReservations[index];
      _cachedReservations[index] = ReservationModel(
        id: old.id,
        userId: old.userId,
        roomId: old.roomId,
        userName: old.userName,
        organization: old.organization,
        startTime: old.startTime,
        endTime: old.endTime,
        purpose: old.purpose,
        participantCount: old.participantCount,
        additionalFacilities: old.additionalFacilities,
        notes: '[Alasan Ditolak: $reason]',
        status: 'REJECTED',
        createdAt: old.createdAt,
        room: old.room,
      );
      _notifyReservationsChanged();
    }

    try {
      await client
          .from('reservations')
          .update({'status': 'REJECTED', 'notes': reason})
          .eq('id', id);
    } catch (_) {}
  }

  /// Pembatalan Reservasi
  static Future<void> cancelReservation(String id) async {
    final index = _cachedReservations.indexWhere((r) => r.id == id);
    if (index != -1) {
      final old = _cachedReservations[index];
      _cachedReservations[index] = ReservationModel(
        id: old.id,
        userId: old.userId,
        roomId: old.roomId,
        userName: old.userName,
        organization: old.organization,
        startTime: old.startTime,
        endTime: old.endTime,
        purpose: old.purpose,
        participantCount: old.participantCount,
        additionalFacilities: old.additionalFacilities,
        notes: old.notes,
        status: 'CANCELLED',
        createdAt: old.createdAt,
        room: old.room,
      );
      _notifyReservationsChanged();
    }

    try {
      await client
          .from('reservations')
          .update({'status': 'CANCELLED'})
          .eq('id', id);
    } catch (_) {}
  }

  // ==========================================
  // STORAGE (FILE PICKER & UPLOAD SURAT IZIN)
  // ==========================================

  static Future<String?> uploadBookingDocument({
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      final cleanName = '${DateTime.now().millisecondsSinceEpoch}_$fileName';
      await client.storage.from('booking-documents').uploadBinary(
            cleanName,
            fileBytes as dynamic,
          );
      final publicUrl = client.storage.from('booking-documents').getPublicUrl(cleanName);
      return publicUrl;
    } catch (_) {
      // Fallback filename reference
      return fileName;
    }
  }
}
