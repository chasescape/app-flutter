import 'package:signals/signals_flutter.dart';
import 'package:get/get.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../../core/singletons/user_service.dart';
import '../../core/singletons/coins_manager.dart';
import '../../core/router/app_routes.dart';
import '../../env/app_env.dart';
import '../../light_handle.dart';

/// Settings Page Controller - Signals State Management
class SettingsController extends GetxController {
  final UserService _userService = UserService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  // Signals
  final userCoins = signal<int>(0);
  final appVersion = signal<String>('');

  @override
  void onInit() {
    super.onInit();
    _loadData();
    _listenToCoinsChanges();
  }

  void _listenToCoinsChanges() {
    _coinsManager.coinsNotifier.addListener(() {
      userCoins.value = _coinsManager.coinsNotifier.value;
    });
  }

  Future<void> _loadData() async {
    final coins = await _coinsManager.getCoins();
    userCoins.value = coins;
    appVersion.value = '1.0.0';
  }

  @override
  Future<void> refresh() async {
    await _loadData();
  }

  void goToCoinStore() {
    AppRoutes.toCoinStore();
  }

  void goToFeedback() {
    AppRoutes.toFeedback();
  }

  void goToPrivacyPolicy() {
    AppRoutes.toAgreement('Privacy Policy', AppEnv().h5Privacy);
  }

  void goToTermsOfService() {
    AppRoutes.toAgreement('Terms of Service', AppEnv().h5User);
  }

  void logout() {
    Get.defaultDialog(
      title: 'Log Out',
      middleText: 'Are you sure you want to log out?',
      textConfirm: 'Log Out',
      textCancel: 'Cancel',
      onConfirm: () async {
        Get.back();
        // 通过 LightHandle 统一处理退出登录
        await LightHandle.logout();
      },
    );
  }

  void deleteAccount() {
    Get.defaultDialog(
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account? All your data will be permanently deleted.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () async {
        Get.back();
        // 通过 LightHandle 统一处理删除账号
        await LightHandle.deleteAccount();
      },
    );
  }

  void clearData() {
    Get.defaultDialog(
      title: 'Clear History',
      middleText: 'This removes saved analysis history on this device only. Your login status and coin balance will stay the same.',
      textConfirm: 'Clear History',
      textCancel: 'Cancel',
      confirmTextColor: Get.theme.colorScheme.onError,
      buttonColor: Get.theme.colorScheme.error,
      onConfirm: () async {
        Get.back();
        await _userService.clearData();
        await _loadData();
        SmartDialog.showToast('Local history cleared');
      },
    );
  }
}
