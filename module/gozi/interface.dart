import 'package:shared_preferences/shared_preferences.dart';
import 'env/app_env.dart';

// interface acts as a protocol and convention. Do not arbitrarily add methods or modify parameters!!!
/// App environment configuration
class Interface {
  Interface._();

  static Interface? _instance;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  // A-side home page
  String lightHome = '';

  // Login page route
  String loginPage = '';

  // prod | test
  String? env;

  // User login state, saved after login or read from persistence on startup. Interface login state handling reads this value directly
  String? authToken;

  /// Set environment variables
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

    // TODO A-side configuration
    final config = AppEnv();
    config.env = runEnv == 'prod' ? AppEnvType.product : AppEnvType.test;
    config.hostApi = apiUrl;
    config.hostH5 = h5Url;
    config.hostIM = imUrl;
    config.hostLog = logUrl;
    config.h5User = '$h5Url/$h5User';
    config.h5Privacy = '$h5Url/$h5Privacy';

    // TODO B-side configuration
  }

  /// Initialize
  Future<void> prevInitialize() async {
    // A-side initialization
    // Persist initialization, initialize based on project persistence implementation, for example:
    // await SharedPreferences.getInstance()
    // Or:
    // await getStorage();

    // TODO B-side initialization
  }

  /// Login operation
  Future<void> doSignInAction() async {
    // A-side login logic
    // Simulate API call with random delay, then save auth token
    final prefs = await SharedPreferences.getInstance();
    final mockToken = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await prefs.setString('auth_token', mockToken);
    authToken = mockToken;

    // B-stage uses B-side logic
  }

  /// B-side entering A-side preprocessing
  Future<void> setHomeEntranceForSideA() async {
    // A-side period doesn't need processing
    // TODO B-stage processing
  }

  /// Delete login information
  Future<void> onAuthTokenRemoved() async {
    // A-side deletion logic
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    authToken = null;

    // B-stage supplement B-side deletion logic
    _doShuffleActions();
  }

  _doShuffleActions() {}
}
