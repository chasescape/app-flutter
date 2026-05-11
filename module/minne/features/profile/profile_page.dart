import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:minne/gen_a/A.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/utils/app_overlay.dart';
import '../../core/widgets/app_card.dart';
import '../../core/models/user_model.dart';
import '../../interface.dart';
import '../../env/app_env.dart';
import '../../data/datasources/local_storage.dart';
import '../../routes/app_pages.dart';
import '../../services/coins_manager.dart';

/// Profile Page - User Personal Center
/// Shows user info, settings, and account management options
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _berryPrimary = Color(0xFF8F355B);
  static const Color _berrySecondary = Color(0xFFB06A84);
  static const Color _pageTop = Color(0xFFFFEAF4);
  static const Color _pageMid = Color(0xFFFFD7E7);
  static const Color _pageBottom = Color(0xFFFFF5DF);
  static const Color _cardBg = Color(0xFFFFFCFE);

  final UserState _userState = UserState();
  final CoinsManager _coinsManager = CoinsManager();

  @override
  void initState() {
    super.initState();
    _coinsManager.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final user = _userState.user;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_pageTop, _pageMid, _pageBottom],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200,
              pinned: true,
              backgroundColor: _pageTop,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  final topPadding = MediaQuery.of(context).padding.top;
                  final collapsedHeight = kToolbarHeight + topPadding;
                  final isCollapsed =
                      constraints.maxHeight <= collapsedHeight + 12;

                  return FlexibleSpaceBar(
                    centerTitle: true,
                    titlePadding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    title: isCollapsed
                        ? Text(
                            user?.nickname ?? 'Minne',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: _berryPrimary,
                            ),
                          )
                        : null,
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [_pageTop, _pageMid, _pageBottom],
                        ),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: user?.avatar != null
                                    ? Image.network(
                                        user!.avatar!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Image.asset(
                                            A.assets_minne_logo6,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: AppColors.bgSecondary,
                                                child: const Icon(
                                                  Icons.person,
                                                  size: 40,
                                                  color: AppColors.textSecondary,
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      )
                                    : Image.asset(
                                        A.assets_minne_logo6,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: AppColors.bgSecondary,
                                            child: const Icon(
                                              Icons.person,
                                              size: 40,
                                              color: AppColors.textSecondary,
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            AppSpacing.gapMD,
                            if (!isCollapsed)
                              Text(
                                user?.nickname ?? 'Minne',
                                style: AppTextStyles.h2Style.copyWith(
                                  color: _berryPrimary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  AppSpacing.gapLG,
                  _buildWalletCard(),
                  AppSpacing.gapLG,
                  _buildSupportSection(),
                  AppSpacing.gapLG,
                  _buildDangerZone(),
                  const SizedBox(height: 180),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingHorizontalMD,
          child: Text(
            'Support',
            style: AppTextStyles.h3Style.copyWith(color: _berryPrimary),
          ),
        ),
        AppSpacing.gapSM,
        AppCard(
          margin: AppSpacing.paddingHorizontalMD,
          backgroundColor: _cardBg.withValues(alpha: 0.8),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.feedback_outlined,
                title: 'Feedback',
                onTap: () => AppRoutes.toFeedback(),
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () {
                  final appEnv = AppEnv();
                  AppRoutes.toAgreement(
                    'Terms of Service',
                    appEnv.h5User,
                  );
                },
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () {
                  final appEnv = AppEnv();
                  AppRoutes.toAgreement(
                    'Privacy Policy',
                    appEnv.h5Privacy,
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return GestureDetector(
      onTap: () async {
        await Get.toNamed(AppRoutes.shop);
        if (!mounted) return;
        await _coinsManager.refresh();
      },
      child: Container(
        margin: AppSpacing.paddingHorizontalMD,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFD25A),
              Color(0xFFFFC13D),
              Color(0xFFFFB01B),
            ],
          ),
          borderRadius: AppBorderRadius.borderRadiusLG,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFFB93A).withValues(alpha: 0.34),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Coins Wallet',
                style: AppTextStyles.bodyMediumStyle.copyWith(
                  color: const Color(0xFF5E3A00),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: Color(0xFF5E3A00),
                ),
              ),
            ],
          ),
          AppSpacing.gapMD,
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars_rounded,
                      size: 15,
                      color: Color(0xFFFFB11F),
                    ),
                  ),
                ),
              ),
              AppSpacing.gapMD,
              Expanded(
                child: ValueListenableBuilder<int>(
                  valueListenable: _coinsManager.coinsNotifier,
                  builder: (context, coins, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$coins',
                          style: AppTextStyles.h1Style.copyWith(
                            color: const Color(0xFF4E2D00),
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        AppSpacing.gapXS,
                        Text(
                          'Available coins',
                          style: AppTextStyles.captionStyle.copyWith(
                            color: const Color(0xFF7F560E),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
          AppSpacing.gapMD,
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () async {
                await Get.toNamed(AppRoutes.shop);
                if (!mounted) return;
                await _coinsManager.refresh();
              },
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF2CC),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Tap to recharge',
                  style: AppTextStyles.bodyMediumStyle.copyWith(
                    color: const Color(0xFF7B4F05),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildDangerZone() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppSpacing.paddingHorizontalMD,
          child: Text(
            'Account',
            style: AppTextStyles.h3Style.copyWith(color: _berryPrimary),
          ),
        ),
        AppSpacing.gapSM,
        AppCard(
          margin: AppSpacing.paddingHorizontalMD,
          backgroundColor: _cardBg.withValues(alpha: 0.8),
          child: Column(
            children: [
              _buildSettingItem(
                icon: Icons.logout,
                title: 'Log Out',
                iconColor: AppColors.warning,
                onTap: _handleLogout,
              ),
              _buildDivider(),
              _buildSettingItem(
                icon: Icons.delete_forever,
                title: 'Delete Account',
                iconColor: AppColors.error,
                onTap: _handleDeleteAccount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    Widget? trailing,
    Color? iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppBorderRadius.borderRadiusMD,
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Row(
          children: [
            Icon(
              icon,
              color: iconColor ?? _berryPrimary,
            ),
            AppSpacing.gapMD,
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyStyle.copyWith(color: _berryPrimary),
              ),
            ),
            if (trailing != null) trailing,
            AppSpacing.gapSM,
            Icon(
              Icons.chevron_right,
              size: 20,
              color: _berrySecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Divider(
        height: 1,
        color: AppColors.divider,
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await AppOverlay.showFrostedConfirmSheet(
      context: context,
      title: 'Log Out',
      content: 'Are you sure you want to log out?',
      confirmText: 'Log Out',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true) {
      _userState.clearUser();
      await LocalStorage.removeToken();
      await LocalStorage.removeUserData();
      Interface().authToken = null;
      AppRoutes.toLogin();
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await AppOverlay.showFrostedConfirmSheet(
      context: context,
      title: 'Delete Account',
      content: 'This action cannot be undone. All your data will be permanently deleted.',
      confirmText: 'Delete',
      cancelText: 'Cancel',
      isDestructive: true,
    );

    if (confirmed == true) {
      _userState.clearUser();
      await CoinsManager().clear();
      await LocalStorage.clearAll();
      Interface().authToken = null;
      AppRoutes.toLogin();

      await AppOverlay.showFrostedNoticeSheet(
        context,
        message: 'Account deleted successfully',
        type: ToastType.success,
      );
    }
  }
}
