import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../gen_a/A.dart';
import '../../controllers/global_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../env/app_env.dart';
import '../../models/models.dart';
import '../../routes/app_pages.dart';
import '../../services/coins_manager.dart';
import '../../widgets/common/soft_ui.dart';

class ProfileController extends GetxController {
  final GlobalController _globalController = GlobalController.to;

  User? get user => _globalController.user;
  CoinsManager get coinsManager => CoinsManager.to;
  int get coins => coinsManager.currentCoins;

  void goToHistory() {
    Routes.toAnalysisHistory();
  }

  void goToCoinStore() {
    Routes.toCoinStore();
  }

  void goToFeedback() {
    Routes.toFeedback();
  }

  void goToTermsOfService() {
    Routes.toAgreement('Terms of Service', AppEnv().h5User);
  }

  void goToPrivacyPolicy() {
    Routes.toAgreement('Privacy Policy', AppEnv().h5Privacy);
  }

  void goToSettings() {
    Get.snackbar('Settings', 'Settings page can be connected here later.');
  }

  void goToAbout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: const Text('About', style: AppTextStyles.h3),
        content: const Text(
          'Nenia now uses a lighter, image-first reading flow across the app.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        title: const Text('Log out', style: AppTextStyles.h3),
        content: const Text('Are you sure you want to log out?',
            style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              Get.back();
              _globalController.logout();
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        backgroundColor: AppColors.surfacePrimary,
        shape: const RoundedRectangleBorder(
          borderRadius: AppBorderRadius.allLg,
        ),
        title: const Text('Delete account', style: AppTextStyles.h3),
        content: const Text(
          'This action is permanent. In the current build it will clear local account data and sign you out.',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Get.back();
              _globalController.logout(clearLocalData: true, clearCoins: true);
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
            child: Column(
              children: [
                _buildTopHeader(),
                const SizedBox(height: 18),
                _buildHero(),
                const SizedBox(height: 16),
                _buildCoinsCard(),
                const SizedBox(height: 16),
                _buildMenu(),
                const SizedBox(height: 16),
                NeniaPrimaryButton(
                  label: 'Log out',
                  trailingIcon: Icons.logout_rounded,
                  onPressed: controller.logout,
                ),
                const SizedBox(height: 14),
                _buildDangerZone(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader() {
    return NeniaInlineHeader(
      title: 'Profile',
      subtitle: 'Manage coins, saved looks and privacy settings.',
      onBack: Get.back,
    );
  }

  Widget _buildHero() {
    return NeniaSurface(
      radius: 32,
      gradient: AppColors.spotlightGradient,
      child: Column(
        children: [
          Container(
            width: 94,
            height: 94,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: AppShadows.sm,
            ),
            child: ClipOval(
              child: Image.asset(
                A.assets_nenia_NeniaLogo,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenia',
            style: AppTextStyles.h2,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NeniaSecondaryButton(
                  label: 'History',
                  icon: Icons.collections_bookmark_outlined,
                  onPressed: controller.goToHistory,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NeniaPrimaryButton(
                  label: 'Coins',
                  trailingIcon: Icons.monetization_on_rounded,
                  onPressed: controller.goToCoinStore,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsCard() {
    return NeniaSurface(
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              gradient: AppColors.candyGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.monetization_on_rounded,
                color: AppColors.textInverse),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Current balance', style: AppTextStyles.small),
                const SizedBox(height: 4),
                ValueListenableBuilder(
                  valueListenable: controller.coinsManager.coinsNotifier,
                  builder: (context, value, child) {
                    return Text('$value coins', style: AppTextStyles.h2);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenu() {
    final items = [
      (
        Icons.feedback_outlined,
        'Feedback',
        'Send notes or dictate them by voice',
        controller.goToFeedback,
      ),
      (
        Icons.description_outlined,
        'Terms of Service',
        'Read the usage agreement',
        controller.goToTermsOfService,
      ),
      (
        Icons.privacy_tip_outlined,
        'Privacy Policy',
        'See how account data is handled',
        controller.goToPrivacyPolicy,
      ),
    ];

    return NeniaSurface(
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            NeniaInfoTile(
              icon: items[i].$1,
              title: items[i].$2,
              subtitle: items[i].$3,
              onTap: items[i].$4,
            ),
            if (i != items.length - 1)
              const Divider(
                height: 14,
                indent: 56,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      children: [
        TextButton(
          onPressed: controller.deleteAccount,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          ),
          child: const Text(
            'Delete account',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
