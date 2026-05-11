import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../interface.dart';

class UserController extends GetxController {
  static UserController get to => Get.find();

  final RxString authToken = ''.obs;
  final RxString userId = ''.obs;
  final RxInt coins = 0.obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    authToken.value = prefs.getString('auth_token') ?? '';
    userId.value = prefs.getString('user_id') ?? '';
    coins.value = prefs.getInt('coins') ?? 0;

    _syncSessionToInterface();
  }

  Future<void> setAuthToken(String token) async {
    authToken.value = token;
    Interface().authToken = token.isEmpty ? null : token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> setUserId(String id) async {
    userId.value = id;
    Interface().userId = id.isEmpty ? null : id;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_id', id);
  }

  Future<void> setCoins(int amount) async {
    coins.value = amount;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('coins', amount);
  }

  Future<void> addCoins(int amount) async {
    await setCoins(coins.value + amount);
  }

  Future<void> deductCoins(int amount) async {
    if (coins.value >= amount) {
      await setCoins(coins.value - amount);
    }
  }

  Future<void> clearUserData() async {
    authToken.value = '';
    userId.value = '';
    coins.value = 0;
    _syncSessionToInterface();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('coins');
  }

  Future<void> signOut() async {
    authToken.value = '';
    userId.value = '';
    _syncSessionToInterface();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
  }

  bool get isLoggedIn => authToken.value.isNotEmpty;

  void _syncSessionToInterface() {
    Interface().authToken = authToken.value.isEmpty ? null : authToken.value;
    Interface().userId = userId.value.isEmpty ? null : userId.value;
  }
}
