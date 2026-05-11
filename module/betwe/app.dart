import 'package:betwe/betwe/app/routes/app_pages.dart';
import 'package:betwe/betwe/app/routes/app_routes.dart';
import 'package:betwe/betwe/app/widgets/webview_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// *** [do change classname] ***
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Betwe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'SF Pro',
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFFF6B6B)),
      ),
      initialRoute: AppPages.initial,
      getPages: [
        ...AppPages.pages,
        GetPage(
          name: AppRoutes.webview,
          page: () {
            final args = Get.arguments as Map<String, dynamic>;
            return WebviewPage(
              title: args['title'] as String,
              url: args['url'] as String,
            );
          },
        ),
      ],
    );
  }
}
