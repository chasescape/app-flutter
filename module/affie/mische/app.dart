import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/network/app_bootstrap_service.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'interface.dart';

// *** [do change classname] ***
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> _checkLoginStatus() async {
    await AppBootstrapService.loadFromStorage();
    final token = Interface().authToken;
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginStatus(),
      builder: (context, snapshot) {
        final isLoggedIn = snapshot.data == true;
        return GetMaterialApp(
          title: 'Mische',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          getPages: AppPages.routes,
          initialRoute: isLoggedIn ? AppRoutes.nav : AppRoutes.login,
        );
      },
    );
  }
}
