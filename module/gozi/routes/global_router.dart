import 'package:flutter/material.dart';
import '../core/router/router_state_manager.dart';
import '../routes/app_routes.dart';
import '../features/splash/splash_page.dart';
import '../features/auth/login_page.dart';
import '../shells/main_shell.dart';
import '../features/create/create_page.dart';
import '../features/result/result_page.dart';
import '../features/history/history_page.dart';
import '../features/store/store_page.dart';
import '../features/profile/profile_page.dart';
import '../features/settings/settings_page.dart';
import '../features/feedback/feedback_page.dart';
import '../features/agreement/agreement_page.dart';
import '../features/webview/webview_page.dart';

/// Global Router - Provides context-free route navigation capability
class GlobalRouter {
  // Private constructor
  GlobalRouter._();

  // Singleton instance
  static final GlobalRouter _instance = GlobalRouter._();

  // Route state manager reference
  RouterStateManager? _manager;

  /// Get singleton instance
  static GlobalRouter get I => _instance;

  /// Initialize (called at app startup)
  void setRouterStateManager(RouterStateManager manager) {
    _manager = manager;
  }

  // ========== Page Definitions ==========

  MaterialPage getSplashPage() {
    return const MaterialPage(
      key: ValueKey(Routes.splash),
      child: SplashPage(),
    );
  }

  MaterialPage getLoginPage() {
    return const MaterialPage(
      key: ValueKey(Routes.login),
      child: LoginPage(),
    );
  }

  MaterialPage getHomePage() {
    return const MaterialPage(
      key: ValueKey(Routes.home),
      child: MainShell(),
    );
  }

  // ========== Route Navigation Methods ==========

  /// Go to create page
  void goToCreate({String? imagePath}) {
    _manager?.push(
      MaterialPage(
        key: ValueKey(
          '${Routes.create}_${DateTime.now().millisecondsSinceEpoch}',
        ),
        child: CreatePage(initialImagePath: imagePath),
      ),
    );
  }

  /// Go to result page with data
  void goToResult({
    required String imagePath,
    String? title,
    String? description,
    List<String>? tags,
    String? category,
    String? note,
  }) {
    _manager?.push(
      MaterialPage(
        key: ValueKey(
            '${Routes.result}_${DateTime.now().millisecondsSinceEpoch}'),
        child: ResultPage(
          imagePath: imagePath,
          title: title,
          description: description,
          tags: tags,
          category: category,
          note: note,
        ),
      ),
    );
  }

  /// Go to history page
  void goToHistory() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.history),
        child: HistoryPage(),
      ),
    );
  }

  /// Go to store page
  void goToStore() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.store),
        child: StorePage(),
      ),
    );
  }

  /// Go to profile page
  void goToProfile() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.profile),
        child: ProfilePage(),
      ),
    );
  }

  /// Go to settings page
  void goToSettings() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.settings),
        child: SettingsPage(),
      ),
    );
  }

  /// Go to feedback page
  void goToFeedback() {
    _manager?.push(
      const MaterialPage(
        key: ValueKey(Routes.feedback),
        child: FeedbackPage(),
      ),
    );
  }

  /// Go to agreement page
  void goToAgreement({required String url, required String title}) {
    _manager?.push(
      MaterialPage(
        key: ValueKey(
            '${Routes.agreement}_${DateTime.now().millisecondsSinceEpoch}'),
        child: AgreementPage(url: url, title: title),
      ),
    );
  }

  /// Go to webview page
  void goToWebview({required String url, String? title}) {
    _manager?.push(
      MaterialPage(
        key: ValueKey(
            '${Routes.webView}_${DateTime.now().millisecondsSinceEpoch}'),
        child: WebviewPage(url: url, title: title),
      ),
    );
  }

  // ========== Main Navigation Methods ==========

  /// Go to home page (clear route stack)
  void goToHome() {
    _manager?.to(getHomePage());
  }

  /// Go to login page (clear route stack)
  void goToLogin() {
    _manager?.to(getLoginPage());
  }

  /// Go to splash page (clear route stack)
  void goToSplash() {
    _manager?.to(getSplashPage());
  }

  // ========== Back Operations ==========

  /// Go back to previous page
  void goBack() {
    _manager?.goBack();
  }

  /// Go back to home page (clear route stack)
  void popToHome() {
    _manager?.popToHome();
  }
}
