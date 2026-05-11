import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';

import '../../../gen_a/A.dart';
import '../../core/managers/coins_manager.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../env/app_env.dart';
import '../../interface.dart';
import '../../light_handle.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              children: [
                AppCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          gradient: AppGradients.hero,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: userData.avatar.isNotEmpty
                            ? ClipOval(
                                child:
                                    AppRemoteImage(imageUrl: userData.avatar),
                              )
                            : ClipOval(
                                child: Image.asset(
                                  A.assets_welgo_welgologo,
                                  fit: BoxFit.cover,
                                ),
                              ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        userData.nickname,
                        style: AppTextStyles.h2.copyWith(fontSize: 26),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      const Text(
                        'A soft visual archive for skincare label checks.',
                        style: AppTextStyles.caption,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        alignment: WrapAlignment.center,
                        children: [
                          AppStatPill(
                            icon: Icons.stars_rounded,
                            label: '${userData.coins} coins',
                          ),
                          AppStatPill(
                            icon: Icons.auto_awesome_rounded,
                            label: '${userData.freeUses} free uses',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppCard(
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Need more scans?',
                              style: AppTextStyles.body.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            const Text(
                              'Top up coins to keep your image-based routine flowing.',
                              style: AppTextStyles.small,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      const SizedBox(
                        width: 124,
                        child: AppButton(
                          text: 'Get coins',
                          onPressed: AppRoutes.toCoinStore,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                _buildGroup(
                  title: 'Support',
                  children: [
                    _buildMenuGroupCard(
                      items: [
                        const _MenuItemData(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          subtitle: 'Share ideas and report friction',
                          onTap: AppRoutes.toFeedback,
                        ),
                        _MenuItemData(
                          icon: Icons.description_outlined,
                          title: 'Terms',
                          subtitle: 'Read the terms of service',
                          onTap: () => AppRoutes.toAgreement(
                            'Terms of Service',
                            AppEnv().h5User,
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy policy',
                          subtitle: 'How your data is handled',
                          onTap: () => AppRoutes.toAgreement(
                            'Privacy Policy',
                            AppEnv().h5Privacy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildGroup(
                  title: 'Account',
                  children: [
                    _buildMenuGroupCard(
                      items: [
                        _MenuItemData(
                          icon: Icons.logout_rounded,
                          title: 'Log out',
                          subtitle: 'Sign out and return to the welcome screen',
                          onTap: () => _showLogoutDialog(ref),
                          iconColor: AppColors.warning,
                        ),
                        _MenuItemData(
                          icon: Icons.delete_forever_rounded,
                          title: 'Delete account',
                          subtitle:
                              'Permanently remove local data and account state',
                          onTap: () => _showDeleteAccountDialog(ref),
                          iconColor: AppColors.error,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            title,
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        ...children,
      ],
    );
  }

  Widget _buildMenuGroupCard({
    required List<_MenuItemData> items,
  }) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            _buildMenuRow(
              item: items[index],
              isFirst: index == 0,
              isLast: index == items.length - 1,
            ),
            if (index != items.length - 1)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.strokeSoft.withValues(alpha: 0.8),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildMenuRow({
    required _MenuItemData item,
    required bool isFirst,
    required bool isLast,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.vertical(
          top: isFirst
              ? const Radius.circular(AppBorderRadius.large)
              : Radius.zero,
          bottom: isLast
              ? const Radius.circular(AppBorderRadius.large)
              : Radius.zero,
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 8,
          ),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color:
                  (item.iconColor ?? AppColors.accent).withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(AppBorderRadius.medium),
            ),
            child: Icon(
              item.icon,
              color: item.iconColor ?? AppColors.accent,
            ),
          ),
          title: Text(
            item.title,
            style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w700),
          ),
          subtitle: Text(
            item.subtitle,
            style: AppTextStyles.small,
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(WidgetRef ref) {
    Get.dialog(
      AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _resetSessionAndGoToLogin(
              ref,
              clearPersistedData: LightHandle.logout,
              clearLocalData: false,
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(WidgetRef ref) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete account'),
        content: const Text(
          'Permanently delete your account and local data? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => _resetSessionAndGoToLogin(
              ref,
              clearPersistedData: LightHandle.deleteAccount,
            ),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
      barrierDismissible: true,
    );
  }

  Future<void> _resetSessionAndGoToLogin(
    WidgetRef ref, {
    required Future<void> Function() clearPersistedData,
    bool clearLocalData = true,
  }) async {
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    try {
      await clearPersistedData();
    } catch (_) {}

    final userNotifier = ref.read(userDataProvider.notifier);
    final historyNotifier = ref.read(analysisHistoryProvider.notifier);

    Interface().authToken = null;

    if (clearLocalData) {
      try {
        await userNotifier.clearAll();
      } catch (_) {
        userNotifier.resetState();
      }

      try {
        await historyNotifier.clearHistory();
      } catch (_) {
        historyNotifier.resetState();
      }

      await CoinsManager.instance.clear();
      userNotifier.resetState();
      historyNotifier.resetState();
    }

    AppRoutes.toLogin();
  }
}

class _MenuItemData {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? iconColor;

  const _MenuItemData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });
}

class ProfileContent extends ConsumerWidget {
  const ProfileContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ProfilePage();
  }
}
