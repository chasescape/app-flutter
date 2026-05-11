import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:affie/gen_a/A.dart';
import 'profile_logic.dart';
import '../../theme/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../../env/app_env.dart';
import '../webview/simple_webview_page.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic logic = Get.put(ProfileLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildProfileHeader(context),
              const SizedBox(height: 32),
              _buildSectionTitle('Account', context),
              const SizedBox(height: 12),
              _buildMenuCard(context, [
                _buildMenuItem(
                  context,
                  icon: Icons.monetization_on_outlined,
                  title: 'Coin Balance',
                  onTap: () => Get.toNamed(AppRoutes.coins),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.feedback_outlined,
                  title: 'Feedback',
                  onTap: () => Get.toNamed(AppRoutes.feedback),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.history,
                  title: 'History',
                  onTap: () => Get.toNamed(AppRoutes.history),
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionTitle('Preferences', context),
              const SizedBox(height: 12),
              _buildMenuCard(context, [
                GetBuilder<ProfileLogic>(
                  builder: (logic) => _buildMenuItemWithSwitch(
                    context,
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark Mode',
                    value: logic.isDarkMode,
                    onChanged: (value) => logic.toggleDarkMode(value),
                  ),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy Policy',
                  onTap: () => _openPrivacy(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Terms of service',
                  onTap: () => _openTerms(context),
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  onTap: () => logic.deleteAccount(),
                  isDestructive: true,
                ),
                _buildMenuItem(
                  context,
                  icon: Icons.logout,
                  title: 'Logout',
                  onTap: () => logic.logout(),
                  isDestructive: true,
                ),
              ]),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  void _openTerms(BuildContext context) {
    final url = AppEnv().h5User;
    if (url.isEmpty) return;
    Get.to(() => SimpleWebviewPage(
          title: 'Terms of Service',
          url: url,
        ));
  }

  void _openPrivacy(BuildContext context) {
    final url = AppEnv().h5Privacy;
    if (url.isEmpty) return;
    Get.to(() => SimpleWebviewPage(
          title: 'Privacy Policy',
          url: url,
        ));
  }

  Widget _buildProfileHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.3),
                AppColors.secondary.withValues(alpha: 0.3),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset(A.assets_affie_logo, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Affie',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color:
                isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? badge,
    VoidCallback? onTap,
    bool isDestructive = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: (isDark ? Colors.white : AppColors.textLight)
                    .withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDestructive
                    ? AppColors.error
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDestructive
                        ? AppColors.error
                        : (isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary),
                  ),
                ),
              ),
              if (badge != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: const BoxDecoration(
                    color: AppColors.success,
                    shape: BoxShape.circle,
                  ),
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  child: Center(
                    child: Text(
                      badge,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              if (badge == null && !isDestructive)
                Icon(
                  Icons.arrow_forward_ios,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textLight,
                  size: 16,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItemWithSwitch(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onChanged(!value),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: (isDark ? Colors.white : AppColors.textLight)
                    .withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: value,
                  onChanged: onChanged,
                  activeColor: const Color(0xFFE8B4D9),
                  // 低饱和度粉色
                  activeTrackColor:
                      const Color(0xFFE8B4D9).withValues(alpha: 0.4),
                  inactiveThumbColor: Colors.grey[400],
                  inactiveTrackColor: Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
