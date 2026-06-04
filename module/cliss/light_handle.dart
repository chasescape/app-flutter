import 'package:flutter/material.dart';
import 'package:cliss/cliss/interface.dart';
import 'package:cliss/cliss/app/routes/app_routes.dart';
import 'package:cliss/cliss/app/services/user_service.dart';
import 'package:cliss/cliss/app/services/meal_storage_service.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';

void _showGlobalLoading(BuildContext context, String message) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.backgroundOverlay,
    builder: (context) => Center(
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppBorderRadius.allLarge,
          boxShadow: AppShadows.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primaryMain,
                ),
                backgroundColor: AppColors.borderSoft,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTextStyles.label.copyWith(
                color: AppColors.textPrimary,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class LightHandle {
  static Future<void> readyToInit() async {
    _initDataFromStorage();
  }

  static Future<void> _initDataFromStorage() async {
    final i = Interface();
    await i.loadAuthToken();
    i.encryptKey = 'getAppConfig and set';
  }

  static Future<void> logout(BuildContext context) async {
    _showGlobalLoading(context, 'Logging out...');
    await Future.delayed(const Duration(seconds: 1));

    final i = Interface();
    await i.setAuthToken(null);
    await UserService.instance.clear();

    if (context.mounted) {
      Navigator.of(context).pop();
      AppRoutes.toLogin();
    }
  }

  static Future<void> login() async {
    final context = AppRoutes.navigatorKey.currentContext;
    if (context == null) return;

    _showGlobalLoading(context, 'Signing in...');
    await Future.delayed(const Duration(seconds: 2));

    final i = Interface();
    final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';
    await i.setAuthToken(token);

    if (context.mounted) {
      Navigator.of(context).pop();
      AppRoutes.toMain();
    }
  }

  static Future<void> deleteAccount(BuildContext context) async {
    _showGlobalLoading(context, 'Deleting account...');
    await Future.delayed(const Duration(seconds: 2));

    final i = Interface();
    await i.setAuthToken(null);
    await UserService.instance.clear();
    await MealStorageService.instance.clearMealHistory();

    if (context.mounted) {
      Navigator.of(context).pop();
      AppRoutes.toLogin();
    }
  }

  static Future<void> onAuthTokenRemoved() async {
    final i = Interface();
    i.authToken = null;
    i.onAuthTokenRemoved();
  }

  static void clearAllData() {
    final i = Interface();
    i.authToken = null;
    i.onAuthTokenRemoved();
  }

  static void _doShuffleActions() {}
}
