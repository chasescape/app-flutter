import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'interface.dart';

// *** [do change classname] ***
class Leprechaun213MyApp extends StatelessWidget {
  /// 可选：由 main 根据登录态传入，有 token 进首页、无 token 进登录页；不传则用 [AppPages.INITIAL]（登录页）
  const Leprechaun213MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // 有 token 保持登录进首页，无 token 进登录页（仅首次安装或已退出登录时）
    final hasToken = Unshaved408Interface().authToken != null && Unshaved408Interface().authToken!.isNotEmpty;
    final initialRoute = hasToken ? Routes.home : Routes.login;

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        // 自定义页面过渡动画时长
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: initialRoute ?? AppPages.INITIAL,
      getPages: AppPages.routes,
      // 自定义默认过渡动画
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 600), // Hero 动画速度
    );
  }
}