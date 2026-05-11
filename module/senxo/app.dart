import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:senxo/senxo/app/bindings/initial_binding.dart';
import 'package:senxo/senxo/app/core/services/auth_service.dart';
import 'package:senxo/senxo/app/routes/app_pages.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isInitialized = false;
  String _initialRoute = Routes.login;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // 初始化全局服务
      final binding = InitialBinding();
      await binding.dependencies();
      
      // 根据登录状态决定初始路由
      final authService = Get.find<AuthService>();
      
      print('=== App 初始化完成 ===');
      print('登录状态: ${authService.isLoggedIn}');
      print('Token: ${authService.token != null && authService.token!.isNotEmpty ? "${authService.token!.substring(0, 10)}..." : "无"}');
      
      setState(() {
        _initialRoute = authService.isLoggedIn ? Routes.home : Routes.login;
        _isInitialized = true;
      });
      
      print('初始路由: $_initialRoute');
    } catch (e) {
      print('初始化失败: $e');
      setState(() {
        _initialRoute = Routes.login;
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      // 显示启动画面
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFF9FB),
                  Color(0xFFFFDAE0),
                  Color(0xFFFFF4DC),
                ],
              ),
            ),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF9575CD),
              ),
            ),
          ),
        ),
      );
    }

    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return GetMaterialApp(
          themeMode: ThemeMode.system,
          
          // GetX 路由配置
          initialRoute: _initialRoute,
          getPages: AppPages.routes,

          // 调试配置
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
