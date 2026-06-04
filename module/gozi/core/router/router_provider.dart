import 'package:flutter/material.dart';
import 'router_state_manager.dart';

/// Route State Provider - Passes RouterStateManager in the widget tree
class RouterProvider extends InheritedWidget {
  final RouterStateManager routerManager;

  const RouterProvider({
    required this.routerManager,
    required super.child,
    super.key,
  });

  /// Safely get router manager (may be null)
  static RouterStateManager? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RouterProvider>();
    return provider?.routerManager;
  }

  /// Get router manager (throws exception if not found)
  static RouterStateManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RouterProvider>();
    return provider!.routerManager;
  }

  @override
  bool updateShouldNotify(RouterProvider oldWidget) => true;
}
