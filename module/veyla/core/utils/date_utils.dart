import 'package:intl/intl.dart';

class AppDateUtils {
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'yyyy-MM-dd HH:mm';

  static String formatDate(DateTime date) {
    return DateFormat(dateFormat).format(date);
  }

  static String formatTime(DateTime time) {
    return DateFormat(timeFormat).format(time);
  }

  static String formatDateTime(DateTime dateTime) {
    return DateFormat(dateTimeFormat).format(dateTime);
  }

  static DateTime parseDate(String dateStr) {
    return DateFormat(dateFormat).parse(dateStr);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static DateTime todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static DateTime todayEnd() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, 23, 59, 59);
  }
}
