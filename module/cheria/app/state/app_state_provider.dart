import 'package:flutter/widgets.dart';
import 'app_state.dart';

/// App State InheritedNotifier
/// Provides AppState to all descendant widgets
class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    super.key,
    required AppState state,
    required Widget child,
  }) : super(notifier: state, child: child);

  static AppState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppStateProvider>()!
        .notifier!;
  }

  @override
  bool updateShouldNotify(AppStateProvider oldWidget) {
    return notifier != oldWidget.notifier;
  }
}
