import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:crushi/crushi/core/router/global_router.dart';
import 'package:crushi/crushi/core/router/router_provider.dart';
import 'package:crushi/crushi/core/router/router_state_manager.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';
import 'package:crushi/crushi/interface.dart';

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
    _routerManager = RouterStateManager(_getDefaultPage());
    GlobalRouter.I.setRouterStateManager(_routerManager);
  }

  Page _getDefaultPage() {
    final isLoggedIn = Interface().authToken != null;
    return isLoggedIn
        ? GlobalRouter.I.getHomePage()
        : GlobalRouter.I.getLoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return RouterProvider(
      routerManager: _routerManager,
      child: MaterialApp(
        title: 'StoicMind',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        navigatorObservers: [FlutterSmartDialog.observer],
        builder: FlutterSmartDialog.init(),
        home: ListenableBuilder(
          listenable: _routerManager,
          builder: (context, child) {
            return Navigator(
              pages: _routerManager.pages,
              onPopPage: (route, result) {
                if (!route.didPop(result)) return false;
                _routerManager.goBack();
                return true;
              },
            );
          },
        ),
      ),
    );
  }
}
