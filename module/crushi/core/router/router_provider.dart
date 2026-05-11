import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/router/router_state_manager.dart';

class RouterProvider extends InheritedWidget {
  final RouterStateManager routerManager;

  const RouterProvider({super.key, 
    required this.routerManager,
    required super.child,
  });

  static RouterStateManager? maybeOf(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<RouterProvider>();
    return provider?.routerManager;
  }

  static RouterStateManager of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<RouterProvider>();
    return provider!.routerManager;
  }

  @override
  bool updateShouldNotify(RouterProvider oldWidget) => true;
}
