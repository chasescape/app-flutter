import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'env/app_env.dart';
import 'light_handle.dart';
import 'app/routes/app_routes.dart';
import 'app/theme/app_theme.dart';
import 'app/services/user_service.dart';
import 'app/services/meal_analysis_service.dart';

class Interface {
  Interface._();

  static Interface? _instance;

  factory Interface() {
    _instance ??= Interface._();
    return _instance!;
  }

  static const String _keyAuthToken = 'auth_token';

  String lightHome = 'AppRoutes.main';
  String loginPage = 'AppRoutes.login';

  String? env;
  String? authToken;
  String? encryptKey;
  String? userId;
  String? deviceId;

  Future<void> setAuthToken(String? token) async {
    authToken = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null) {
      await prefs.remove(_keyAuthToken);
    } else {
      await prefs.setString(_keyAuthToken, token);
    }
  }

  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    authToken = prefs.getString(_keyAuthToken);
  }

  void setRunEnv({
    required String runEnv,
    required String apiUrl,
    required String h5Url,
    required String imUrl,
    required String logUrl,
    required String h5User,
    required String h5Privacy,
    String? geApiKey,
  }) {
    env = runEnv;

    final config = AppEnv();
    config.env = runEnv == 'prod' ? AppEnvType.product : AppEnvType.test;
    config.hostApi = apiUrl;
    config.hostH5 = h5Url;
    config.hostIM = imUrl;
    config.hostLog = logUrl;
    config.h5User = '$h5Url/$h5User';
    config.h5Privacy = '$h5Url/$h5Privacy';
    config.geApiKey = geApiKey ?? '';
  }

  Future<void> prevInitialize() async {
    await LightHandle.readyToInit();
    await loadAuthToken();
    await UserService.instance.init();
    MealAnalysisService.instance.init();
  }

  Future<void> doSignInAction() async {
    await LightHandle.login();
  }

  Future<void> setHomeEntranceForSideA() async {}

  Future<void> onAuthTokenRemoved() async {
    _doShuffleActions();
  }

  _doShuffleActions() {}
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diet Manager',
      theme: AppTheme.lightTheme,
      navigatorKey: AppRoutes.navigatorKey,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      initialRoute: AppRoutes.login,
    );
  }
}
