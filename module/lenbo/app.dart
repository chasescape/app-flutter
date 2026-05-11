import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:lenbo/lenbo/app/routes/app_routes.dart';
import 'package:lenbo/lenbo/core/network/api_client.dart';
import 'package:lenbo/lenbo/core/theme/app_theme.dart';
import 'package:lenbo/lenbo/interface.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  static const MethodChannel _attChannel = MethodChannel('lenbo/att');
  bool _attRequestedThisRun = false;
  bool _attRequestInFlight = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestAttIfNeeded();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestAttIfNeeded();
    }
  }

  Future<void> _requestAttIfNeeded() async {
    if (_attRequestedThisRun || _attRequestInFlight) return;

    if (!Platform.isIOS) return;

    _attRequestInFlight = true;
    try {
      final status = await _attChannel.invokeMethod<int>('getTrackingStatus') ?? 0;
      // 0: notDetermined, 1: restricted, 2: denied, 3: authorized
      if (status == 0) {
        await _attChannel.invokeMethod<int>('requestTrackingAuthorization');
      }
      _attRequestedThisRun = true;
    } catch (_) {
      // Ignore: channel may not be available yet; retry when app resumes.
    } finally {
      _attRequestInFlight = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'PlantCare',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: Interface().authToken != null ? AppRoutes.main : AppRoutes.login,
      getPages: AppPages.pages,
      defaultTransition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 300),
      initialBinding: _AppBinding(),
    );
  }
}

class _AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ApiClient());
  }
}
