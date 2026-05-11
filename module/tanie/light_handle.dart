// *** [do change classname] ***
import 'interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/coins_manager.dart';
import 'services/reflection_storage_service.dart';

// Concrete Side A business handling.
class LightHandle {
  static const String _authTokenKey = 'auth_token';

  // Side A business initialization.
  static Future<void> readyToInit() async {
    // Initialize persistent services
    await coinsManager.init();
    await reflectionStorageService.init();

    // Initialize from persisted storage and continue the startup flow.
    await _initDataFromStorage();
  }

  // Initialize Side A state from persisted storage.
  static Future<void> _initDataFromStorage() async {
    final i = Interface();
    final prefs = await SharedPreferences.getInstance();
    final storedAuthToken = prefs.getString(_authTokenKey)?.trim();

    i.authToken = (storedAuthToken != null && storedAuthToken.isNotEmpty)
        ? storedAuthToken
        : null;
    i.encryptKey = 'getAppConfig and set';

    // Typical flow:
    // Check whether encryptKey exists; if not, fetch it from AppConfig.

    // If authToken is empty, go to login.
    // Otherwise:
    // 1. Load user information
    // 2. Initialize IAP-related state
    // 3. Navigate to Side A home using Interface().lightHome
  }

  /// Side A logout action.
  static Future<void> logout() async {
    // ...
    onAuthTokenRemoved();
  }

  /// Side A login action.
  static Future<void> login() async {}

  /// Persist the auth token for the next launch.
  static Future<void> persistAuthToken(String token) async {
    final trimmedToken = token.trim();
    final prefs = await SharedPreferences.getInstance();

    if (trimmedToken.isEmpty) {
      await prefs.remove(_authTokenKey);
      Interface().authToken = null;
      return;
    }

    await prefs.setString(_authTokenKey, trimmedToken);
    Interface().authToken = trimmedToken;
  }

  /// Side A delete-account action.
  static Future<void> deleteAccount() async {
    // ...
    clearAllData();
  }

  /// Remove login information.
  static Future<void> onAuthTokenRemoved() async {
    // Clear Side A login state only.
    final i = Interface();
    i.authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);

    // Navigation.

    // During merge phase, comment out the navigation above and let Side B handle it.
    await i.onAuthTokenRemoved();
  }

  /// Clear all data before deleting a Side A account.
  static Future<void> clearAllData() async {
    // In-memory data.
    final i = Interface();
    i.authToken = null;

    // Reset persisted user data for a fresh start.
    await coinsManager.setCoins(CoinsManager.initialCoins);
    await reflectionStorageService.clearAll();

    // Navigation.

    // During merge phase, comment out the navigation above and let Side B handle it.
    await onAuthTokenRemoved();
  }
}
