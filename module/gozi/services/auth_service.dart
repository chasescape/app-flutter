import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../interface.dart';

/// Auth Service - Manages authentication state globally
class AuthService extends GetxService {
  static AuthService get to => Get.find();

  final RxBool _isLoggedIn = false.obs;

  /// Get login status
  bool get isLoggedIn => _isLoggedIn.value;

  /// Login status stream
  RxBool get isLoggedInStream => _isLoggedIn;

  @override
  void onInit() {
    super.onInit();
    _loadAuthState();
  }

  /// Load auth state from local storage and restore to Interface
  Future<void> _loadAuthState() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token != null && token.isNotEmpty) {
      // Restore to Interface.authToken
      Interface().authToken = token;
      _isLoggedIn.value = true;
    }
  }

  /// Login via Interface
  Future<void> login() async {
    await Interface().doSignInAction();
    _isLoggedIn.value = true;
  }

  /// Logout via Interface
  Future<void> logout() async {
    await Interface().onAuthTokenRemoved();
    _isLoggedIn.value = false;
  }

  /// Check if should navigate to login
  bool shouldShowLogin() {
    return !_isLoggedIn.value;
  }
}
