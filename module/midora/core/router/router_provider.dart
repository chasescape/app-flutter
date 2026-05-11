import 'package:flutter/material.dart';
import 'router_state_manager.dart';

/// Router State Provider - Pass RouterStateManager in Widget tree
class RouterProvider extends InheritedWidget {
  final RouterStateManager routerManager;

  const RouterProvider({
    super.key,
    required this.routerManager,
    required Widget child,
  }) : super(child: child);

  /// Safely get router manager (can be null)
  static RouterStateManager? maybeOf(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RouterProvider>();
    return provider?.routerManager;
  }

  /// Get router manager (throw exception if not found)
  static RouterStateManager of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RouterProvider>();
    return provider!.routerManager;
  }

  @override
  bool updateShouldNotify(RouterProvider oldWidget) => true;
}
