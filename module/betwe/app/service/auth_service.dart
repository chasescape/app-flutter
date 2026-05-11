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
      '/appApi/v3/game_maximum_session/list',
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
    final res = await NetworkService.ins.post('/appApi/v0/docinfo_top_map/erase');
    await AppConfigService.clearAuth();
    return res;
  }

  Future<Map<String, dynamic>> deleteAccount() async {
    final res = await NetworkService.ins.post('/appApi/v2/tab_entry/apply');
    return res;
  }
}
