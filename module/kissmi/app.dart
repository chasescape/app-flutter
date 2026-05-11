import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/network/core_services.dart';
import 'app/network/core/app_env_config_adapter.dart';

// *** [do change classname] ***
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _resolveInitialRoute(),
      builder: (context, snapshot) {
        final String initialRoute = snapshot.data ?? AppRoutes.login;
        return GetMaterialApp(
          title: 'Kissmi',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF9B5CFF),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0B0B0F),
            useMaterial3: true,
          ),
          initialRoute: initialRoute,
          getPages: AppPages.pages,
        );
      },
    );
  }

  Future<String> _resolveInitialRoute() async {
    final AppEnvConfigAdapter config = CoreServices.instance.config as AppEnvConfigAdapter;
    await config.loadAuthToken();
    final String? token = config.authToken;
    return (token != null && token.isNotEmpty) ? AppRoutes.home : AppRoutes.login;
  }
}
