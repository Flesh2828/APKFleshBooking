import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_flutter/utils/date_formatter.dart';

void main() {
  setUpAll(() async {
    await DateFormatterIndo.ensureInitialized();
  });

  group('DateFormatterIndo Tests', () {
    final testDate = DateTime(2026, 10, 8, 9, 30);

    test('formatFull formats date correctly in Indonesian', () {
      final formatted = DateFormatterIndo.formatFull(testDate);
      expect(formatted, contains('2026'));
      expect(formatted, anyOf(contains('Oktober'), contains('10')));
    });

    test('formatShort formats date in concise format', () {
      final formatted = DateFormatterIndo.formatShort(testDate);
      expect(formatted, contains('2026'));
      expect(formatted, anyOf(contains('Okt'), contains('Oct')));
    });

    test('formatDateTime combines date and time', () {
      final formatted = DateFormatterIndo.formatDateTime(testDate);
      expect(formatted, contains('09:30'));
      expect(formatted, contains('•'));
    });

    test('formatDayTime formats month day and time', () {
      final formatted = DateFormatterIndo.formatDayTime(testDate);
      expect(formatted, contains('09:30'));
      expect(formatted, contains('08'));
    });

    test('formatTime extracts HH:mm correctly', () {
      final formatted = DateFormatterIndo.formatTime(testDate);
      expect(formatted, equals('09:30'));
    });
  });
}
