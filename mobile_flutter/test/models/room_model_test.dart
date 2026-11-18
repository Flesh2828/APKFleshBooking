import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/models/room_model.dart';

void main() {
  group('RoomModel Unit Tests', () {
    test('fromJson parses full JSON map correctly', () {
      final json = {
        'id': 'room-01',
        'name': 'Lab AI & Robotics',
        'building': 'Gedung Rektorat Baru',
        'floor': 3,
        'capacity': 40,
        'facilities': ['Projector', 'AC', 'Whiteboard', 'Sound System'],
        'status': 'ACTIVE',
        'opening_hour': '08:00',
        'closing_hour': '17:00',
        'description': 'Laboratorium riset kecerdasan buatan',
      };

      final room = RoomModel.fromJson(json);

      expect(room.id, equals('room-01'));
      expect(room.name, equals('Lab AI & Robotics'));
      expect(room.floor, equals(3));
      expect(room.capacity, equals(40));
      expect(room.facilities.length, equals(4));
      expect(room.facilities, contains('Projector'));
      expect(room.status, equals('ACTIVE'));
    });

    test('fromJson handles facilities JSON string format and null defaults', () {
      final json = {
        'id': 'room-02',
        'name': 'Ruang Seminar',
        'building': 'Gedung A',
        'facilities': '["Proyektor", "WiFi"]',
      };

      final room = RoomModel.fromJson(json);

      expect(room.facilities.length, equals(2));
      expect(room.floor, equals(1));
      expect(room.capacity, equals(0));
      expect(room.status, equals('ACTIVE'));
      expect(room.openingHour, equals('08:00'));
      expect(room.closingHour, equals('17:00'));
    });
  });
}
