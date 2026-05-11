import 'package:get/get.dart';
import '../interface.dart';
import 'storage_service.dart';

class AuthService extends GetxService {
  static AuthService get to => Get.find<AuthService>();

  final RxnString authToken = RxnString(null);

  bool get isLoggedIn => authToken.value != null && authToken.value!.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _loadToken();
  }

  Future<void> _loadToken() async {
    final token = await StorageService.to.getString('auth_token');
    if (token != null && token.isNotEmpty) {
      authToken.value = token;
      Interface().authToken = token;
    }
  }

  Future<void> login(String token) async {
    authToken.value = token;
    Interface().authToken = token;
    await StorageService.to.setString('auth_token', token);
  }

  Future<void> logout() async {
    authToken.value = null;
    Interface().authToken = null;
    await StorageService.to.remove('auth_token');
  }

  Future<void> clear() async {
    authToken.value = null;
    Interface().authToken = null;
    await StorageService.to.clear();
  }
}
