import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/router/router_state_manager.dart';
import 'core/router/router_provider.dart';
import 'routes/global_router.dart';
import 'services/auth_service.dart';
import 'services/coins_manager.dart';
import 'services/theme_service.dart';
import 'services/achievement_storage_service.dart';
import 'theme/app_theme.dart';
import 'interface.dart';

/// App Binding - Initialize global services
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Register global services
    Get.put(ThemeService(), permanent: true);
    Get.put(AuthService(), permanent: true);
    Get.put(AchievementStorageService(), permanent: true);
  }
}

/// Main App Widget
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final RouterStateManager _routerManager;

  @override
  void initState() {
    super.initState();
    // Initialize route manager
    _routerManager = RouterStateManager(const MaterialPage(
      key: ValueKey('splash'),
      child: _SplashPlaceholder(),
    ));

    // Set global router
    GlobalRouter.I.setRouterStateManager(_routerManager);

    // Initialize app and determine initial page
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize CoinsManager globally
    await CoinsManager.instance.initialize();

    // Wait for AuthService to load auth state from local storage
    // This will restore the token to Interface().authToken
    await Future.delayed(const Duration(milliseconds: 100));

    // Get the initial page based on login status
    final initialPage = _getDefaultPage();

    // Replace the splash placeholder with the actual page
    _routerManager.to(initialPage);
  }

  Page _getDefaultPage() {
    // Check login status from Interface.authToken
    // AuthService.onInit already loaded the token into Interface.authToken
    final isLoggedIn = Interface().authToken != null;

    if (isLoggedIn) {
      return GlobalRouter.I.getHomePage();
    } else {
      return GlobalRouter.I.getLoginPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'AchieveNote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      initialBinding: AppBinding(),

      // Builder with route provider
      builder: (context, child) {
        return RouterProvider(
          routerManager: _routerManager,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () {
              FocusManager.instance.primaryFocus?.unfocus();
            },
            child: child!,
          ),
        );
      },

      // Home widget with Navigator 2.0
      home: ListenableBuilder(
        listenable: _routerManager,
        builder: (context, child) {
          return Navigator(
            pages: _routerManager.pages,
            onDidRemovePage: (page) {
              _routerManager.goBack();
            },
          );
        },
      ),
    );
  }
}

/// Splash placeholder - shown briefly while initializing
class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
