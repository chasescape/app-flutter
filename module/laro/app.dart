import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';

import 'core/app_theme.dart';
import 'core/app_routes.dart';
import 'core/service_locator.dart';
import 'features/home/providers/lash_provider.dart';
import 'features/history/providers/history_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/coin_store/providers/coin_provider.dart';
import 'interface.dart';
import 'services/coins_manager.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await CoinsManager().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => getIt<LashProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<HistoryProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => getIt<CoinProvider>()),
      ],
      child: GetMaterialApp(
        title: 'LashVision Pro',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: Interface().authToken != null ? AppRoutes.home : AppRoutes.login,
        getPages: AppRoutes.routes,
        builder: BotToastInit(),
        navigatorObservers: [BotToastNavigatorObserver()],
        defaultTransition: Transition.cupertino,
      ),
    );
  }
}
