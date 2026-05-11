import 'package:flutter/material.dart';
import 'package:tavia/tavia/core/state/state_provider.dart';

import 'core/router/app_router.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';

/// Main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = AppState();

    return StateProvider(
      state: appState,
      child: MaterialApp.router(
        title: 'Tavia',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: AppRouter.router,
      ),
    );
  }
}
