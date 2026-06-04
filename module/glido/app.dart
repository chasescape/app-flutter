import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:glido/glido/theme/app_theme.dart';
import 'package:glido/glido/routes/app_routes.dart';
import 'package:glido/glido/providers/app_state.dart';
import 'package:glido/glido/managers/coins_manager.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    CoinsManager().init();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..setFreeCredits(3),
      child: MaterialApp.router(
        title: 'ToneKeep Note',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRoutes.router,
      ),
    );
  }
}
