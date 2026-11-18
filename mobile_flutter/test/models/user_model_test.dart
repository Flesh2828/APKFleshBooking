import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/models/user_model.dart';

void main() {
  group('UserModel Unit Tests', () {
    test('fromJson creates valid UserModel', () {
      final json = {
        'id': 'usr-123',
        'name': 'Ahmad Fauzi',
        'email': 'ahmad@kampus.ac.id',
        'role': 'ADMIN',
        'department': 'Teknik Informatika',
        'phone': '08123456789',
        'avatar_url': 'https://example.com/avatar.png',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, equals('usr-123'));
      expect(user.name, equals('Ahmad Fauzi'));
      expect(user.isAdmin, isTrue);
      expect(user.roleLabel, equals('Administrator'));
    });

    test('roleLabel handles various roles appropriately', () {
      final mhs = UserModel.fromJson({'id': '1', 'role': 'MAHASISWA'});
      expect(mhs.isAdmin, isFalse);
      expect(mhs.roleLabel, equals('Mahasiswa'));

      final dsn = UserModel.fromJson({'id': '2', 'role': 'DOSEN'});
      expect(dsn.roleLabel, equals('Dosen'));

      final stf = UserModel.fromJson({'id': '3', 'role': 'STAF'});
      expect(stf.roleLabel, equals('Staf Kampus'));
    });

    test('handles fallback defaults when fields are null', () {
      final minimal = UserModel.fromJson({'id': 'usr-999'});
      expect(minimal.name, equals('Pengguna'));
      expect(minimal.email, isEmpty);
      expect(minimal.role, equals('MAHASISWA'));
    });
  });
}
