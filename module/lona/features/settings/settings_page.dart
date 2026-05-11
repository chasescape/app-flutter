import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/settings_controller.dart';
import '../../core/constants/app_border_radius.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/app_shell.dart';
import '../../routes/app_routes.dart';

class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            children: [
              const AppTopBar(
                title: 'Settings',
                subtitle: 'YOUR SPACE',
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildBalanceCard(),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                title: 'Explore',
                items: [
                  _SettingsItem(
                    title: 'Coin store',
                    icon: Icons.shopping_bag_outlined,
                    onTap: controller.openCoinStore,
                  ),
                  _SettingsItem(
                    title: 'History',
                    icon: Icons.photo_library_outlined,
                    onTap: () => Get.toNamed(AppRoutes.history),
                  ),
                  _SettingsItem(
                    title: 'Feedback',
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: controller.openFeedback,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                title: 'Policies',
                items: [
                  _SettingsItem(
                    title: 'Terms of service',
                    icon: Icons.description_outlined,
                    onTap: controller.openAgreement,
                  ),
                  _SettingsItem(
                    title: 'Privacy policy',
                    icon: Icons.lock_outline_rounded,
                    onTap: controller.openPrivacy,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildSection(
                title: 'Account',
                items: [
                  _SettingsItem(
                    title: 'Logout',
                    icon: Icons.logout_rounded,
                    onTap: controller.logout,
                  ),
                  _SettingsItem(
                    title: 'Delete account',
                    icon: Icons.delete_outline_rounded,
                    onTap: controller.clearAllData,
                    destructive: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return ValueListenableBuilder<int>(
      valueListenable: controller.coinsNotifier,
      builder: (context, coins, _) => AppSurface(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppTag(label: 'CURRENT BALANCE'),
                  const SizedBox(height: AppSpacing.md),
                  Text('$coins', style: AppTextStyles.h1),
                  const Text(
                    'coins ready for your next review',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: 118,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppGradients.whitePill,
                  borderRadius: BorderRadius.circular(AppBorderRadius.full),
                ),
                child: ElevatedButton(
                  onPressed: controller.openCoinStore,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text('Top up'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.h3),
        const SizedBox(height: AppSpacing.md),
        AppSurface(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _buildMenuItem(items[i]),
                if (i != items.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Divider(
                      height: 1,
                      color: AppColors.textPrimary.withValues(alpha: 0.08),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(_SettingsItem item) {
    final color = item.destructive ? AppColors.semanticError : AppColors.textPrimary;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  item.title,
                  style: AppTextStyles.body.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool destructive;

  _SettingsItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.destructive = false,
  });
}
