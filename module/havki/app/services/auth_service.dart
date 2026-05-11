import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Authentication Service - Global singleton using GetX
/// Handles user login state, token management, and user data
class AuthService extends GetxService {
  static const int _defaultCoins = 100;

  static AuthService get to => Get.find();

  // Reactive variables
  final RxBool isLoggedIn = false.obs;
  final RxString authToken = ''.obs;
  final RxString userName = 'Guest'.obs;
  final RxInt userCoins = _defaultCoins.obs; // Default coins for new users

  // SharedPreferences key constants
  static const String _keyAuthToken = 'auth_token';
  static const String _keyUserName = 'user_name';
  static const String _keyUserCoins = 'user_coins';
  static const String _keyIsLoggedIn = 'is_logged_in';

  SharedPreferences? _prefs;

  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
    await _loadUserData();
  }

  /// Load user data from local storage
  Future<void> _loadUserData() async {
    if (_prefs == null) return;

    isLoggedIn.value = _prefs!.getBool(_keyIsLoggedIn) ?? false;
    authToken.value = _prefs!.getString(_keyAuthToken) ?? '';
    userName.value = _prefs!.getString(_keyUserName) ?? 'Guest';
    userCoins.value = _prefs!.getInt(_keyUserCoins) ?? _defaultCoins;
  }

  /// Login action - sets auth state and saves to storage
  Future<void> login({String token = 'mock_token'}) async {
    if (_prefs == null) return;

    authToken.value = token;
    isLoggedIn.value = true;
    userName.value = 'User'; // Default user name

    await _prefs!.setBool(_keyIsLoggedIn, true);
    await _prefs!.setString(_keyAuthToken, token);
    await _prefs!.setString(_keyUserName, 'User');
  }

  /// Logout action - clears all user data
  Future<void> logout() async {
    if (_prefs == null) return;

    authToken.value = '';
    isLoggedIn.value = false;
    userName.value = 'Guest';
    userCoins.value = _defaultCoins;

    await _prefs!.remove(_keyIsLoggedIn);
    await _prefs!.remove(_keyAuthToken);
    await _prefs!.remove(_keyUserName);
    await _prefs!.remove(_keyUserCoins);
  }

  /// Update user name
  Future<void> updateUserName(String name) async {
    if (_prefs == null) return;

    userName.value = name;
    await _prefs!.setString(_keyUserName, name);
  }

  /// Add coins (for purchases or rewards)
  Future<void> addCoins(int amount) async {
    if (_prefs == null) return;

    userCoins.value += amount;
    await _prefs!.setInt(_keyUserCoins, userCoins.value);
  }

  /// Deduct coins (for purchases or AI analysis)
  Future<bool> deductCoins(int amount) async {
    if (_prefs == null) return false;

    if (userCoins.value < amount) return false;

    userCoins.value -= amount;
    await _prefs!.setInt(_keyUserCoins, userCoins.value);
    return true;
  }

  /// Check if user has enough coins
  bool hasEnoughCoins(int amount) {
    return userCoins.value >= amount;
  }

  /// Clear all data (for account deletion)
  Future<void> clearAllData() async {
    if (_prefs == null) return;

    await _prefs!.clear();
    authToken.value = '';
    isLoggedIn.value = false;
    userName.value = 'Guest';
    userCoins.value = _defaultCoins;
  }
}
