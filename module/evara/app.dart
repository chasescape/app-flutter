import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import '../gen_a/A.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_routes.dart';
import 'core/singletons/storage_service.dart';
import 'core/singletons/user_service.dart';
import 'core/widgets/evara_scaffold.dart';
import 'interface.dart';

/// Main App Widget
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'MakeupLog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      navigatorObservers: [FlutterSmartDialog.observer],
      builder: FlutterSmartDialog.init(),
      initialRoute: AppRoutes.splash,
      getPages: AppRoutes.routes,
      home: const _SplashScreen(),
    );
  }
}

/// Splash Screen - Handle initialization and auth check
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 初始化 Interface
      final interface = Interface();

      // 恢复登录态 - 从持久化存储读取 authToken
      await interface.restoreAuthToken();

      // Check first launch
      final isFirstLaunch = await (StorageService.instance
          .loadString(StorageKeys.isFirstLaunch));
      final hasCoins = await StorageService.instance.containsKey(
        StorageKeys.userCoins,
      );

      if (isFirstLaunch == null) {
        await UserService.instance.setFreeUsageCount(0);
        await StorageService.instance.saveString(StorageKeys.isFirstLaunch, 'false');
      }

      if (!hasCoins) {
        await UserService.instance.setCoins(100);
      }

      // 根据登录态判断跳转
      if (interface.authToken != null && interface.authToken!.isNotEmpty) {
        // 已登录 - 跳转首页
        AppRoutes.toHome();
      } else {
        // 未登录 - 跳转登录页
        AppRoutes.toLogin();
      }
    } catch (e) {
      // On error, go to login
      AppRoutes.toLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EvaraScaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(28)),
              child: Image(
                image: AssetImage(A.assets_evara_logo),
                width: 96,
                height: 96,
                fit: BoxFit.cover,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Evara',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w800,
                color: AppTheme.textInverse,
                letterSpacing: 0.4,
              ),
            ),
            SizedBox(height: 18),
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppTheme.accentMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
