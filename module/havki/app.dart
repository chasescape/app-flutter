import 'package:flutter/material.dart';
import './app/routes/app_routes.dart';
import './app/theme/app_theme.dart';
import './features/auth/login_page.dart';

/// Main app widget
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QuoteVibe',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: AppNavigator.I.navigatorKey,
      onGenerateRoute: (settings) {
        final routes = buildRoutes();
        final builder = routes[settings.name];
        if (builder != null) {
          return MaterialPageRoute(
            builder: builder,
            settings: settings,
          );
        }
        return null;
      },
      home: const LoginPage(),
    );
  }
}
