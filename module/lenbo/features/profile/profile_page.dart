import 'package:flutter/material.dart';
import 'package:lenbo/gen_a/A.dart';
import 'package:lenbo/lenbo/app/routes/app_routes.dart';
import 'package:lenbo/lenbo/app/widgets/confirm_dialog.dart';
import 'package:lenbo/lenbo/core/theme/app_colors.dart';
import 'package:lenbo/lenbo/core/theme/app_spacing.dart';
import 'package:lenbo/lenbo/core/services/coins_manager.dart';
import 'package:lenbo/lenbo/env/app_env.dart';
import 'package:lenbo/lenbo/light_handle.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgPrimary,
                  AppColors.accentMain.withAlpha(26),
                  AppColors.bgPrimary,
                ],
              ),
            ),
          ),
          ListView(
            children: [
              // Profile header
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.xl,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 24),
                    _buildProfileAvatar(),
                    const SizedBox(height: 16),
                    const Text(
                      'Lenbo',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Settings list
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Column(
                  children: [
                    _buildActionCard(
                      children: [
                        ValueListenableBuilder<int>(
                          valueListenable: CoinsManager.coinsNotifier,
                          builder: (context, coinBalance, _) {
                            return _buildCardButton(
                              icon: Icons.monetization_on_outlined,
                              title: 'My Coins',
                              trailingText: '$coinBalance',
                              onTap: () => AppRoutes.toCoinStore(),
                            );
                          },
                        ),
                        _buildCardButton(
                          icon: Icons.history,
                          title: 'History',
                          onTap: () => AppRoutes.toHistory(),
                        ),
                        _buildCardButton(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          onTap: () => AppRoutes.toFeedback(),
                        ),
                        _buildCardButton(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          onTap: () => AppRoutes.toAgreement(
                            'Terms of Service',
                            AppEnv().h5User,
                          ),
                        ),
                        _buildCardButton(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          onTap: () => AppRoutes.toAgreement(
                            'Privacy Policy',
                            AppEnv().h5Privacy,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _buildActionCard(
                      isDangerous: true,
                      children: [
                        _buildCardButton(
                          icon: Icons.logout,
                          title: 'Log Out',
                          titleColor: AppColors.error,
                          iconColor: AppColors.error,
                          onTap: _handleLogout,
                        ),
                        _buildCardButton(
                          icon: Icons.delete_outline,
                          title: 'Delete Account',
                          titleColor: AppColors.error,
                          iconColor: AppColors.error,
                          onTap: _handleDeleteAccount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
          // Loading overlay for delete
          if (_isDeleting)
            Container(
              color: AppColors.bgOverlay,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryMain),
                ),
              ),
            ),
        ],
      ),
    );
  }

	  Widget _buildProfileAvatar() {
	    return Container(
	      width: 104,
	      height: 104,
	      decoration: BoxDecoration(
	        shape: BoxShape.circle,
	        gradient: LinearGradient(
	          begin: Alignment.topLeft,
	          end: Alignment.bottomRight,
	          colors: [
	            AppColors.accentMain.withAlpha(90),
	            AppColors.bgPrimary,
	          ],
	        ),
	        border: Border.all(
	          color: AppColors.secondaryMain.withAlpha(82),
	          width: 1.2,
	        ),
	        boxShadow: [
	          BoxShadow(
	            color: AppColors.neonPinkGlow.withAlpha(120),
	            blurRadius: 26,
	            offset: const Offset(0, 12),
	          ),
	        ],
	      ),
	      child: ClipOval(
	        child: Image.asset(
	          A.assets_lenbo_logo,
	          width: 104,
	          height: 104,
	          fit: BoxFit.cover,
	        ),
	      ),
	    );
	  }

  Widget _buildActionCard({
    required List<Widget> children,
    bool isDangerous = false,
  }) {
    final dividerColor =
        isDangerous ? AppColors.error.withAlpha(30) : AppColors.cardBorderLight.withAlpha(90);
    final borderColor =
        isDangerous ? AppColors.error.withAlpha(48) : AppColors.secondaryMain.withAlpha(38);
    final shadowColor =
        isDangerous ? AppColors.error.withAlpha(16) : AppColors.secondaryMain.withAlpha(18);
    final gradientTopColor =
        isDangerous ? AppColors.error.withAlpha(18) : AppColors.accentMain.withAlpha(55);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gradientTopColor,
            AppColors.cardBg,
          ],
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: borderColor, width: 0.9),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                Container(
                  height: 1,
                  margin: const EdgeInsets.only(left: 60),
                  color: dividerColor,
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? titleColor,
    Color? iconColor,
    VoidCallback? onTap,
  }) {
    final effectiveTitleColor = titleColor ?? AppColors.textPrimary;
    final effectiveIconColor = iconColor ?? AppColors.secondaryMain;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.accentMain.withAlpha(70),
                      AppColors.cardBg,
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: effectiveIconColor.withAlpha(70), width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: (iconColor ?? AppColors.neonPinkGlow).withAlpha(70),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(icon, size: 18, color: effectiveIconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: effectiveTitleColor,
                  ),
                ),
              ),
              if (trailingText != null) ...[
                Text(
                  trailingText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              const Icon(Icons.chevron_right, color: AppColors.textDisabled, size: 20),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Log Out',
      content: 'Are you sure you want to log out?',
    );
    if (confirmed == true) {
      await LightHandle.logout();
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete Account',
      content: 'This will permanently delete your account and all data. This action cannot be undone.',
      confirmText: 'Delete',
      isDangerous: true,
    );
    if (confirmed == true) {
      setState(() => _isDeleting = true);
      await Future.delayed(const Duration(seconds: 2));
      await LightHandle.deleteAccount();
    }
  }
}
