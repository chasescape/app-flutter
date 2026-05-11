import '../../interface.dart';
import 'app_bootstrap_service.dart';
import 'net_client.dart';

class AuthGateway {
  static final AuthGateway ins = AuthGateway._internal();
  AuthGateway._internal();

  Future<Map<String, dynamic>> signInWithDevice() async {
    await AppBootstrapService.getOrCreateDeviceId();
    await AppBootstrapService.ensureEncryptKey();

    final deviceToken = Interface().deviceId ?? '';
    final res = await NetClient.ins.post(
      '/api/v0/page_top_price/del',
      body: {
        'oauthType': '4',
        'token': deviceToken,
        'token_hint': deviceToken,
      },
    );

    final token = _extractToken(res);
    if (token != null && token.isNotEmpty) {
      await AppBootstrapService.saveToken(token);
    }

    return res;
  }

  Future<Map<String, dynamic>> logout() async {
    final res = await NetClient.ins.post('/api/v3/harddisk_max_price/erase');
    await AppBootstrapService.clearAuth();
    return res;
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final res = await NetClient.ins.post('/api/v2/dateinfo_last_list/del');
    return res;
  }

  String? _extractToken(Map<String, dynamic> res) {
    final direct = res['token'] ?? res['auth_token'] ?? res['authToken'];
    if (direct is String && direct.isNotEmpty) {
      return direct;
    }

    final data = res['data'];
    if (data is Map) {
      final nested = data['token'] ?? data['auth_token'] ?? data['authToken'];
      if (nested is String && nested.isNotEmpty) {
        return nested;
      }
    }

    return null;
  }
}
