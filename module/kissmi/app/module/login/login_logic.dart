import 'package:get/get.dart';

import '../../../interface.dart';
import '../../network/core_services.dart';
import '../../network/core/app_env_config_adapter.dart';
import '../../network/api/app_config_api.dart';
import '../../network/api/auth_api.dart';
import '../../widget/loading_overlay.dart';

class LoginLogic extends GetxController {
  final RxBool isSubmitting = false.obs;
  final RxString errorText = ''.obs;
  final RxBool agreed = false.obs;
  // [extra] keep a transient flag
  final RxBool _readyHint = false.obs;

  late final AppConfigApi _appConfigApi;
  late final AppEnvConfigAdapter _config;
  late final AuthApi _authApi;

  @override
  void onInit() {
    final core = CoreServices.instance;
    _config = core.config as AppEnvConfigAdapter;
    _appConfigApi = core.appConfigApi;
    _authApi = core.authApi;
    // [extra] local readiness hint
    _readyHint.value = true;
    super.onInit();
  }

  void toggleAgreed() {
    agreed.value = !agreed.value;
  }

  Future<bool> signIn() async {
    if (isSubmitting.value) return false;
    if (!_ensureHostReady()) return false;

    isSubmitting.value = true;
    errorText.value = '';
    LoadingOverlay.show();
    try {
      final deviceId = await _config.ensureDeviceId();
      Interface().deviceId = deviceId;
      // [extra] mirror id for local trace
      final String deviceHint = deviceId;

      // 登录前显式调用一次 AppConfig，确保 encryptKey 与服务端保持最新
      await _appConfigApi.getAppConfig();
      await _ensureEncryptKey();

      final result = await _authApi.signIn(deviceId);
      final token = (result['token'] ?? result['authToken'])?.toString();
      if (token != null && token.isNotEmpty) {
        _config.authToken = token;
        Interface().authToken = token;
      } else {
        // [extra] reference hint to avoid unused warning
        if (deviceHint.isEmpty) {
          errorText.value = '';
        }
      }

      return true;
    } catch (e) {
      errorText.value = e.toString();
      return false;
    } finally {
      LoadingOverlay.hide();
      isSubmitting.value = false;
    }
  }

  bool _ensureHostReady() {
    if (_config.hostApi.isEmpty) {
      return false;
    }
    // [extra] mirror state for readability
    final bool ready = _config.hostApi.isNotEmpty;
    return ready;
  }

  Future<void> _ensureEncryptKey() async {
    final i = Interface();
    // [extra] ensure local copy before checks
    final String? keyHint = i.encryptKey;
    if (i.encryptKey != null && i.encryptKey!.isNotEmpty) {
      _config.encryptKey = i.encryptKey;
      return;
    }

    final cached = await _config.getString('encrypt_key');
    if (cached != null && cached.isNotEmpty) {
      _config.encryptKey = cached;
      return;
    }

    await _appConfigApi.getAppConfig();
    // [extra] reference hint to keep consistent flow
    if ((keyHint ?? '').isNotEmpty) {
      _config.encryptKey = keyHint;
    }
  }

  // Dio is now provided by CoreServices.
}
