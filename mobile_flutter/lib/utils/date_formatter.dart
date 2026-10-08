import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class DateFormatterIndo {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (!_initialized) {
      try {
        await initializeDateFormatting('id_ID', null);
        _initialized = true;
      } catch (_) {}
    }
  }

  static const List<String> days = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> months = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Format: 'Senin, 08 Oktober 2026'
  static String formatFull(DateTime dt) {
    try {
      return DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      final dayName = days[(dt.weekday - 1) % 7];
      final monthName = months[(dt.month - 1) % 12];
      final day = dt.day.toString().padLeft(2, '0');
      return '$dayName, $day $monthName ${dt.year}';
    }
  }

  /// Format: '08 Okt 2026'
  static String formatShort(DateTime dt) {
    try {
      return DateFormat('dd MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      final monthName = monthsShort[(dt.month - 1) % 12];
      final day = dt.day.toString().padLeft(2, '0');
      return '$day $monthName ${dt.year}';
    }
  }

  /// Format: '08 Okt 2026 • 09:00'
  static String formatDateTime(DateTime dt) {
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '${formatShort(dt)} • $timeStr';
  }

  /// Format: '08 Okt, 09:00'
  static String formatDayTime(DateTime dt) {
    final monthName = monthsShort[(dt.month - 1) % 12];
    final day = dt.day.toString().padLeft(2, '0');
    final timeStr =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$day $monthName, $timeStr';
  }

  /// Format: '09:00'
  static String formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
