import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find<StorageService>();

  Future<SharedPreferences> get prefs async => await SharedPreferences.getInstance();

  Future<void> setString(String key, String value) async {
    final pref = await prefs;
    await pref.setString(key, value);
  }

  Future<String?> getString(String key) async {
    final pref = await prefs;
    return pref.getString(key);
  }

  Future<void> setInt(String key, int value) async {
    final pref = await prefs;
    await pref.setInt(key, value);
  }

  Future<int?> getInt(String key) async {
    final pref = await prefs;
    return pref.getInt(key);
  }

  Future<void> setBool(String key, bool value) async {
    final pref = await prefs;
    await pref.setBool(key, value);
  }

  Future<bool?> getBool(String key) async {
    final pref = await prefs;
    return pref.getBool(key);
  }

  Future<void> remove(String key) async {
    final pref = await prefs;
    await pref.remove(key);
  }

  Future<void> clear() async {
    final pref = await prefs;
    await pref.clear();
  }
}
