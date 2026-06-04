import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/managers/coins_manager.dart';
import 'package:pliro/pliro/core/routes/app_routes.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/env/app_env.dart';
import 'package:pliro/pliro/features/profile/presentation/controllers/profile_controller.dart';
import 'package:pliro/pliro/shared/widgets/common_button.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';
import 'package:pliro/gen_a/A.dart';

/// Profile page - user settings and account management.
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final ProfileController _controller = Get.put(ProfileController());
  final CoinsManager _coinsManager = CoinsManager.instance;

  @override
  Widget build(BuildContext context) {
    return DreamScaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: GetBuilder<ProfileController>(
        init: _controller,
        builder: (ctrl) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMD,
              AppTheme.spacingSM,
              AppTheme.spacingMD,
              AppTheme.spacingXXL,
            ),
            child: Column(
              children: [
                _buildProfileCard(ctrl),
                const SizedBox(height: AppTheme.spacingLG),
                _buildCoinCard(),
                const SizedBox(height: AppTheme.spacingLG),
                _buildSettingsSection(),
                const SizedBox(height: AppTheme.spacingXL),
                NeonButton(
                  text: 'Sign Out',
                  icon: Icons.logout,
                  onPressed: ctrl.onSignOut,
                  width: double.infinity,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                TextButton(
                  onPressed: ctrl.onDeleteAccount,
                  child: Text(
                    'Delete Account',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.errorRed,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileCard(ProfileController ctrl) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: AppTheme.glowShadow,
            ),
            child: ClipOval(
              child: Image.asset(
                A.assets_pliro_logo,
                fit: BoxFit.cover,
                width: 88,
                height: 88,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMD),
          Text('Pliro', style: AppTextStyles.h3),
          const SizedBox(height: AppTheme.spacingLG),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatItem('Records', '${ctrl.totalRecords}'),
              _buildDivider(),
              _buildStatItem('Badges', '${ctrl.badgeCount}'),
              _buildDivider(),
              _buildStatItemCoins(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(value, style: AppTextStyles.h3),
          Text(
            label,
            style: AppTextStyles.small,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItemCoins() {
    return Expanded(
      child: ValueListenableBuilder<int>(
        valueListenable: _coinsManager.coinsNotifier,
        builder: (context, coinBalance, child) {
          return Column(
            children: [
              Text('$coinBalance', style: AppTextStyles.h3),
              Text(
                'Coins',
                style: AppTextStyles.small,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 32,
      color: AppColors.textDisabled.withOpacity(0.18),
    );
  }

  Widget _buildCoinCard() {
    return ValueListenableBuilder<int>(
      valueListenable: _coinsManager.coinsNotifier,
      builder: (context, coinBalance, child) {
        return NeonCard(
          onTap: () => Get.toNamed(AppRoutes.coinStore),
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: AppColors.blushMist.withOpacity(0.78),
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                ),
                child: const Icon(
                  Icons.toll_outlined,
                  color: AppColors.roseDeep,
                  size: 28,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Coin balance', style: AppTextStyles.caption),
                    Text('$coinBalance', style: AppTextStyles.h2),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection() {
    return NeonCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingLG,
        vertical: AppTheme.spacingSM,
      ),
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              AppRoutes.toAgreement('Terms of Service', AppEnv().h5User);
            },
          ),
          _settingDivider(),
          _buildSettingItem(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              AppRoutes.toAgreement('Privacy Policy', AppEnv().h5Privacy);
            },
          ),
          _settingDivider(),
          _buildSettingItem(
            icon: Icons.feedback_outlined,
            title: 'Send Feedback',
            onTap: () => Get.toNamed(AppRoutes.feedback),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMD),
          child: Row(
            children: [
              Icon(icon, color: AppColors.roseDeep, size: 23),
              const SizedBox(width: AppTheme.spacingMD),
              Expanded(
                child: Text(title, style: AppTextStyles.body),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _settingDivider() {
    return Divider(
      color: AppColors.textDisabled.withOpacity(0.14),
      height: 1,
    );
  }
}
