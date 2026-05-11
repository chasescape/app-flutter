import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/services/auth_manager.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      home: _AppInitializer(),
      getPages: AppPages.routes,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600),
    );
  }
}

/// App 初始化器
/// 
/// 负责在 App 启动时：
/// 1. 初始化 AuthManager
/// 2. 检测 token 登录态
/// 3. 根据登录状态跳转到对应页面
class _AppInitializer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF1a0b2e),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFf472b6)),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Loading...',
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          );
        }

        // 初始化出错
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('初始化失败: ${snapshot.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      // 重新加载
                      (context as Element).markNeedsBuild();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildInitialPage();
      },
    );
  }

  /// 初始化 App
  Future<void> _initializeApp() async {
    if (!Get.isRegistered<AuthManager>()) {
      await AuthManager.init();
    }
  }

  /// 根据登录状态构建初始页面
  Widget _buildInitialPage() {
    final hasToken = AuthManager.to.isLoggedIn.value;

    if (hasToken) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.nav);
      });
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed(Routes.login);
      });
    }

    return const Scaffold(
      backgroundColor: Color(0xFF1a0b2e),
      body: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFf472b6)),
        ),
      ),
    );
  }
}
