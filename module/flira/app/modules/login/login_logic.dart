import 'package:flira/flira/app/network/core/app_env_config_adapter.dart';
import 'package:flira/flira/app/network/core_services.dart';
import 'package:get/get.dart';

class LoginLogic extends GetxController {
  final RxBool loading = false.obs;

  /// 登录流程：
  /// 1) 拉取 appConfig，拿 encryptKey
  /// 2) 获取稳定 deviceId
  /// 3) 调用登录接口并保存 authToken
  Future<void> signIn() async {
    if (loading.value) return;

    loading.value = true;
    try {
      final core = CoreServices.instance;

      await core.appConfigApi.getAppConfig();

      String deviceId = core.config.deviceId ?? '';
      if (core.config is AppEnvConfigAdapter) {
        deviceId = await (core.config as AppEnvConfigAdapter).ensureDeviceId();
      }

      if (deviceId.isEmpty) {
        throw Exception('deviceId is empty');
      }

      final loginData = await core.authApi.signIn(deviceId);

      final token = (loginData['authToken'] ??
              loginData['token'] ??
              loginData['access_token'])
          ?.toString();
      if (token != null && token.isNotEmpty) {
        core.config.authToken = token;
      }
    } finally {
      loading.value = false;
    }
  }
}
