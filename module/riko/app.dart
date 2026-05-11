import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riko/riko/app/routes/app_pages.dart';
import 'package:riko/riko/app/routes/app_routes.dart';
import 'package:riko/riko/interface.dart';

// *** [do change classname] ***
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final hasDeviceId =
        (Interface().deviceId != null && Interface().deviceId!.isNotEmpty);
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: hasDeviceId ? AppRoutes.nav : AppRoutes.login,
      getPages: AppPages.pages,
    );
  }
}
