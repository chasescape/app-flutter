// *** [do change classname] ***
import 'env/app_env.dart';
import 'light_handle.dart';

// Interface contract. Avoid changing method signatures casually.
class Interface {
  Interface._();

  static Interface? _instance;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  // Side A login entry page. Keep this aligned with the Side A home page.
  String lightHome = 'AppRoutes.main';
  String loginPage = 'AppRoutes.login';

  // prod | test
  String? env;
  // User auth token loaded after login or from persisted storage.
  String? authToken;
  // Encryption key from app config for request encryption and decryption.
  String? encryptKey;
  // Used by Side A flows.
  String? userId;
  String? deviceId;

  /// Set environment values.
  void setRunEnv({
    required String runEnv,
    required String apiUrl,
    required String h5Url,
    required String imUrl,
    required String logUrl,
    required String h5User,
    required String h5Privacy,
  }) {
    env = runEnv;

    // TODO: Side A configuration.
    final config = AppEnv();
    config.env = runEnv == 'prod' ? AppEnvType.product : AppEnvType.test;
    config.hostApi = apiUrl;
    config.hostH5 = h5Url;
    config.hostIM = imUrl;
    config.hostLog = logUrl;
    config.h5User = '$h5Url/$h5User';
    config.h5Privacy = '$h5Url/$h5Privacy';

    // TODO: Side B configuration.
  }

  /// Initialize.
  Future<void> prevInitialize() async {
    // TODO: Side A initialization, usually persisted state for login.
    // Side A business initialization.
    await LightHandle.readyToInit();

    // TODO: Side B initialization.
  }

  /// Sign in.
  Future<void> doSignInAction() async {
    // TODO: Call into Side A or Side B logic only. Keep implementations out of interface.
    // Side A login flow.
    await LightHandle.login();

    // Use Side B logic after the merge.
  }

  /// Handle Side B before entering Side A.
  Future<void> setHomeEntranceForSideA() async {
    // No action needed during the Side A stage.
    // TODO: Handle this after the merge.
  }

  /// Set auth token.
  void setAuthToken(String token) {
    authToken = token;
  }

  /// Clear auth token.
  void clearAuthToken() {
    authToken = null;
  }

  /// Remove login information.
  Future<void> onAuthTokenRemoved() async {
    // No action needed during the Side A stage.
    // TODO: Add Side B removal logic after the merge.

    _doShuffleActions();
  }

  _doShuffleActions() {}
}
