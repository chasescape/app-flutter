import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'router/app_router.dart';
import 'app/state/app_state.dart';
import 'app/state/app_state_provider.dart';
import 'app/theme/theme.dart';
import 'interface.dart';
import 'services/api_service.dart';

/// Main App Widget
/// Configures the application with routing, state management, and theme
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize API service
    ApiService.init();

    return AppStateProvider(
      state: AppState(),
      child: MaterialApp.router(
        title: 'Cheria',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        builder: FlutterSmartDialog.init(),
        routerConfig: AppRouter.router,
      ),
    );
  }
}
