import 'package:shared_preferences/shared_preferences.dart';

class DailyTipStore {
  DailyTipStore._();

  static const String _prefix = 'daily_tip_';
  static final Map<String, String> _cache = <String, String>{};

  static String _keyForDate(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$_prefix$y-$m-$d';
  }

  static Future<void> loadAll() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(_prefix)) {
        final value = prefs.getString(key);
        if (value != null && value.isNotEmpty) {
          _cache[key] = value;
        }
      }
    }
  }

  static String? getTip(DateTime date) {
    return _cache[_keyForDate(date)];
  }

  static Future<void> setTip(DateTime date, String tip) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final key = _keyForDate(date);
    await prefs.setString(key, tip);
    _cache[key] = tip;
  }

  static String keyForDate(DateTime date) => _keyForDate(date);

  static Map<String, String> get cacheSnapshot =>
      Map<String, String>.from(_cache);

  static Future<void> clear() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
    _cache.clear();
  }
}
