import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/models/reservation_model.dart';

void main() {
  group('ReservationModel Unit Tests', () {
    test('fromJson parses reservation with ML fields properly', () {
      final json = {
        'id': 'GS-101',
        'user_id': 'user-01',
        'room_id': 'room-01',
        'user_name': 'Xiao Xiu',
        'organization': 'Divisi Dewan Perwakilan Mahasiswa / Guild Hub',
        'start_time': '2026-10-10T09:00:00Z',
        'end_time': '2026-10-10T11:00:00Z',
        'purpose': 'Sidang Pleno Himpunan & Koordinasi Ormawa',
        'participant_count': 35,
        'status': 'APPROVED',
        'created_at': '2026-10-01T10:00:00Z',
        'auto_category': 'ACADEMIC',
        'is_spam': false,
        'no_show_risk_score': 0.15,
        'is_high_risk_no_show': false,
        'approval_recommendation': 'AUTO_APPROVE',
        'estimated_occupancy_hours': 12.5,
        'estimated_energy_kwh': 6.8,
      };

      final res = ReservationModel.fromJson(json);

      expect(res.id, equals('GS-101'));
      expect(res.userName, equals('Xiao Xiu'));
      expect(res.participantCount, equals(35));
      expect(res.status, equals('APPROVED'));
      expect(res.autoCategory, equals('ACADEMIC'));
      expect(res.isSpam, isFalse);
      expect(res.noShowRiskScore, equals(0.15));
      expect(res.approvalRecommendation, equals('AUTO_APPROVE'));
      expect(res.estimatedOccupancyHours, equals(12.5));
      expect(res.estimatedEnergyKwh, equals(6.8));
    });

    test('fromJson handles optional fields correctly with minimal required json', () {
      final json = {
        'id': 'res-102',
        'room_id': 'room-default',
        'start_time': '2026-11-01T08:00:00Z',
        'end_time': '2026-11-01T10:00:00Z',
      };

      final res = ReservationModel.fromJson(json);

      expect(res.id, equals('res-102'));
      expect(res.roomId, equals('room-default'));
      expect(res.userName, isEmpty);
      expect(res.organization, isEmpty);
      expect(res.purpose, isEmpty);
      expect(res.participantCount, equals(1));
      expect(res.status, equals('PENDING'));
      expect(res.isSpam, isNull);
    });
  });
}
