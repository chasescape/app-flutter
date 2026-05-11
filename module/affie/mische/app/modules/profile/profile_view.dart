import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mische/gen_a/A.dart';
import 'package:mische/mische/app/routes/app_routes.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/mische_background.dart';
import '../../../interface.dart';
import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic logic = Get.find<ProfileLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1D1017),
      body: MischeBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 20),
                      _buildProfileCard(),
                      const SizedBox(height: 20),
                      _buildCreditCard(),
                      const SizedBox(height: 20),
                      _buildSettingsSection(),
                      const SizedBox(height: 20),
                      _buildAccountSection(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Profile',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.8,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Manage your account settings',
          style: TextStyle(
            color: Color(0xFFE6E3EA),
            fontSize: 15,
            height: 1.5,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      onTap: () {},
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              A.assets_mische_logo,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 18),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'mische',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreditCard() {
    return GlassCard(
      onTap: () => Get.toNamed(AppRoutes.coins),
      child: _buildItemCard(
        icon: Icons.credit_card,
        title: 'Top Up Credits',
        subtitle: 'Add credits to your account',
        iconColor: const Color(0xFFF0A6B8),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        GlassCard(
          child: Column(
            children: [
              _buildItemCard(
                icon: Icons.chat_bubble_outline,
                title: 'Feedback',
                iconColor: const Color(0xFF8DD9FF),
                showBorder: true,
                onTap: () => Get.toNamed(AppRoutes.feedback),
              ),
              _buildItemCard(
                icon: Icons.shield_outlined,
                title: 'Privacy Policy',
                iconColor: const Color(0xFFB88CFF),
                showBorder: true,
                onTap: () => Get.toNamed(
                  AppRoutes.webview,
                  arguments: {
                    'title': 'Privacy Policy',
                    'url': Interface().h5PrivacyUrl ?? '',
                  },
                ),
              ),
              _buildItemCard(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                iconColor: const Color(0xFFFF9CC8),
                onTap: () => Get.toNamed(
                  AppRoutes.webview,
                  arguments: {
                    'title': 'Terms of Service',
                    'url': Interface().h5UserUrl ?? '',
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 10),
        Obx(
          () => GlassCard(
            child: Column(
              children: [
                _buildItemCard(
                  icon: Icons.logout,
                  title: 'Log Out',
                  iconColor: const Color(0xFFFFC48B),
                  showBorder: true,
                  onTap: logic.isLoading.value ? null : () => logic.logout(),
                ),
                _buildItemCard(
                  icon: Icons.delete_outline,
                  title: 'Delete Account',
                  iconColor: const Color(0xFFFF8AA1),
                  showBorder: false,
                  onTap: logic.isLoading.value ? null : () => _showDeleteDialog(context),
                  titleColor: const Color(0xFFFF6B8D),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Obx(
          () => logic.isLoading.value
              ? const Align(
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildItemCard({
    required IconData icon,
    required String title,
    String? subtitle,
    required Color iconColor,
    bool showBorder = false,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    final tile = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iconColor.withValues(alpha: 0.35)),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: titleColor ?? const Color(0xFFffffff),
            fontWeight: FontWeight.w700,
            fontSize: 15,
            letterSpacing: 0.4,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle,
                style: const TextStyle(
                  color: Color(0xFFffffff),
                  fontSize: 12,
                  height: 1.5,
                  letterSpacing: 0.3,
                ),
              ),
        trailing: const Icon(Icons.chevron_right, color: Color(0xFFffffff)),
      ),
    );

    if (!showBorder) {
      return tile;
    }

    return Column(
      children: [
        tile,
        const Divider(color: Color(0x33FFFFFF), height: 1, indent: 20, endIndent: 20),
      ],
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            backgroundColor: const Color(0xCCFFFFFF),
            borderColor: const Color(0x66FFFFFF),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8AA1).withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.delete_outline, color: Color(0xFFFF6B8D), size: 28),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Delete Account?',
                  style: TextStyle(
                    color: Color(0xFF1F1D24),
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'This action cannot be undone. All your data will be permanently deleted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF5A5564),
                    fontSize: 13,
                    height: 1.5,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: logic.isLoading.value
                        ? null
                        : () async {
                            Navigator.of(dialogContext).pop();
                            await logic.deleteAccount();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B8D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      elevation: 0,
                    ),
                    child: logic.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Yes, Delete My Account'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1F1D24),
                      side: const BorderSide(color: Color(0x33000000)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFFF4C1DA), Color(0xFFEAB6E7)]),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF3D1C2B),
          fontWeight: FontWeight.w700,
          fontSize: 12,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
