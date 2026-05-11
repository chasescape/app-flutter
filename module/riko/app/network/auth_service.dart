import '../../interface.dart';
import 'app_config_service.dart';
import 'network_service.dart';

class AuthService {
  static final AuthService ins = AuthService._internal();
  AuthService._internal();

  Future<Map<String, dynamic>> signInWithDevice() async {
    await AppConfigService.getOrCreateDeviceId();
    await AppConfigService.ensureEncryptKey();

    final deviceToken = Interface().deviceId ?? '';
    final res = await NetworkService.ins.post(
      '/api_prod/v0/page_hash/download',
      body: {
        'oauthType': '4',
        'token': deviceToken,
      },
    );

    if (res['code'] == 0 && res['data'] is Map) {
      final token = (res['data'] as Map)['token']?.toString();
      if (token != null && token.isNotEmpty) {
        await AppConfigService.saveToken(token);
      }
    }

    return res;
  }

  Future<Map<String, dynamic>> logout() async {
    final res = await NetworkService.ins.post('/api_prod/v3/disk_average_value/upload');
    await AppConfigService.clearAuth();
    return res;
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final res = await NetworkService.ins.post('/api_prod/v1/report_first_hash/apply');
    return res;
  }
}
