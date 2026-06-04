import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'app_router.dart';

/// Extension on BuildContext for convenient navigation
extension AppRouterExtension on BuildContext {
  /// Navigate to coin store page
  void toCoinStore() {
    push(AppRoutes.coinStore);
  }

  /// Navigate to login page
  void toLogin() {
    go(AppRoutes.login);
  }

  /// Navigate to home page
  void toHome() {
    go(AppRoutes.home);
  }

  /// Navigate to library page
  void toLibrary() {
    go(AppRoutes.library);
  }

  /// Navigate to stats page
  void toStats() {
    go(AppRoutes.stats);
  }

  /// Navigate to profile page
  void toProfile() {
    go(AppRoutes.profile);
  }

  /// Navigate to editor page
  void toEditor({String? novelId}) {
    if (novelId != null) {
      push(AppRoutes.editorDetail(novelId));
    } else {
      push(AppRoutes.editor);
    }
  }

  /// Navigate to agreement page
  void toAgreement(String title, [String? url]) {
    final route = Uri(
      path: AppRoutes.agreement,
      queryParameters: {
        'title': title,
        if (url != null && url.isNotEmpty) 'url': url,
      },
    ).toString();
    push(route);
  }
}
