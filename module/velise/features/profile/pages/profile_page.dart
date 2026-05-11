import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:velise/gen_a/A.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/velise_ui.dart';
import '../../../services/coins/coins_manager.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return VeliseScaffold(
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: VeliseActionButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: Get.back,
                      ),
                    ),
                    Text(
                      'Profile',
                      style: AppTextStyles.h3Style.copyWith(
                        fontWeight: AppTextStyles.semibold,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ValueListenableBuilder<int>(
                        valueListenable: CoinsManager.instance,
                        builder: (context, balance, child) {
                          return VelisePill(
                            label: '$balance coins',
                            icon: Icons.auto_awesome_rounded,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _buildIdentityCard(),
              const SizedBox(height: 18),
              _buildQuickActions(),
              const SizedBox(height: 18),
              _buildMenuSection(),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityCard() {
    return VeliseSurfaceCard(
      light: true,
      child: Row(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
              gradient: AppColors.lavenderGradient,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(4),
            child: ClipOval(
              child: Image.asset(
                A.assets_velise_velise,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Velise',
                  style: AppTextStyles.surfaceTitleStyle,
                ),
                const SizedBox(height: 12),
                ValueListenableBuilder<int>(
                  valueListenable: CoinsManager.instance,
                  builder: (context, balance, child) {
                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        VelisePill(
                          label: '$balance balance',
                          icon: Icons.wallet_giftcard_rounded,
                          light: true,
                          compact: true,
                        ),
                        const VelisePill(
                          label: 'Editorial mode',
                          icon: Icons.auto_stories_outlined,
                          light: true,
                          compact: true,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: VeliseSurfaceCard(
              light: true,
              onTap: controller.onTopUp,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.add_card_rounded,
                    color: AppColors.textOnSurface,
                    size: 26,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Top Up',
                    style:
                        AppTextStyles.surfaceTitleStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Keep enough coins for new AI reads.',
                    style: AppTextStyles.surfaceBodyStyle,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: VeliseSurfaceCard(
              light: true,
              onTap: controller.onHistory,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.collections_bookmark_outlined,
                    color: AppColors.textOnSurface,
                    size: 26,
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'History',
                    style:
                        AppTextStyles.surfaceTitleStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Revisit the full image archive.',
                    style: AppTextStyles.surfaceBodyStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return VeliseSurfaceCard(
      light: true,
      child: Column(
        children: [
          _buildMenuItem(
            title: 'Feedback',
            subtitle: 'Send notes with typing or voice.',
            icon: Icons.mic_none_rounded,
            onTap: controller.onFeedback,
          ),
          _buildDivider(),
          _buildMenuItem(
            title: 'Privacy Policy',
            subtitle: 'Read how image and account data are handled.',
            icon: Icons.privacy_tip_outlined,
            onTap: controller.onPrivacyPolicy,
          ),
          _buildDivider(),
          _buildMenuItem(
            title: 'Terms of Service',
            subtitle: 'Review usage rules and purchase terms.',
            icon: Icons.description_outlined,
            onTap: controller.onTermsOfService,
          ),
          _buildDivider(),
          _buildMenuItem(
            title: 'Log Out',
            subtitle: 'End the current session on this device.',
            icon: Icons.logout_rounded,
            onTap: controller.onLogout,
            dangerous: true,
          ),
          _buildDivider(),
          _buildMenuItem(
            title: 'Delete Account',
            subtitle:
                'This action removes local identity, coins, and saved history.',
            icon: Icons.delete_forever_outlined,
            onTap: controller.onDeleteAccount,
            dangerous: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
    bool dangerous = false,
  }) {
    final iconColor = dangerous ? AppColors.error : AppColors.textOnSurface;
    final textColor = dangerous ? AppColors.error : AppColors.textOnSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: dangerous
                    ? AppColors.error.withValues(alpha: 0.12)
                    : AppColors.primaryMain.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.surfaceMetaStyle.copyWith(
                      color: textColor,
                      fontWeight: AppTextStyles.semibold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style:
                        AppTextStyles.surfaceBodyStyle.copyWith(fontSize: 15),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textOnSurfaceSoft,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      color: AppColors.secondaryDark.withValues(alpha: 0.28),
      height: 1,
    );
  }
}
