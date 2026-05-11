import 'package:flira/flira/app/modules/common/in_app_web_page.dart';
import 'package:flira/flira/app/modules/profile/profile_logic.dart';
import 'package:flira/flira/app/routes/app_routes.dart';
import 'package:flira/flira/env/app_env.dart';
import 'package:flira/gen_a/A.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final logic = Get.put(ProfileLogic());

  Future<void> _showConfirmDialog({
    required IconData icon,
    required String title,
    required String content,
    required String confirmText,
    required Color accentColor,
    required VoidCallback onConfirm,
  }) async {
    final bool? confirmed = await Get.dialog<bool>(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 32),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x1F1F1020),
                blurRadius: 28,
                offset: Offset(0, 14),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3D2C34),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                content,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Color(0xFF8D707A),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF8D707A),
                        side: const BorderSide(color: Color(0xFFF3D7E1)),
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Get.back(result: false),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: accentColor,
                        minimumSize: const Size.fromHeight(44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Get.back(result: true),
                      child: Text(
                        confirmText,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );

    if (confirmed == true) {
      onConfirm();
    }
  }

  String _composeH5Url({
    required String direct,
    required String fallbackPath,
  }) {
    if (direct.isNotEmpty) return direct;

    final hostH5 = AppEnv().hostH5;
    if (hostH5.isEmpty) return '';

    if (hostH5.endsWith('/')) {
      return '$hostH5${fallbackPath.replaceFirst('/', '')}';
    }
    return '$hostH5$fallbackPath';
  }

  void _openTerms() {
    final String url = _composeH5Url(
      direct: AppEnv().h5User,
      fallbackPath: '/terms-of-service',
    );
    if (url.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Terms link is not configured yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.to(() => InAppWebPage(title: 'Terms of Service', url: url));
  }

  void _openPrivacy() {
    final String url = _composeH5Url(
      direct: AppEnv().h5Privacy,
      fallbackPath: '/privacy-policy',
    );
    if (url.isEmpty) {
      Get.snackbar(
        'Unavailable',
        'Privacy link is not configured yet.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    Get.to(() => InAppWebPage(title: 'Privacy Policy', url: url));
  }

  void _onLogoutTap() {
    _showConfirmDialog(
      icon: Icons.logout_rounded,
      title: 'Log out?',
      content: 'You will be returned to the login screen and need to sign in again.',
      confirmText: 'Log out',
      accentColor: const Color(0xFFFF7E9D),
      onConfirm: () async {
        await logic.logout();
        Get.offAllNamed(AppRoutes.login);
      },
    );
  }

  void _onDeleteAccountTap() {
    _showConfirmDialog(
      icon: Icons.warning_amber_rounded,
      title: 'Delete account?',
      content: 'This action is permanent and cannot be undone. Do you want to continue?',
      confirmText: 'Delete',
      accentColor: const Color(0xFFE85A82),
      onConfirm: () async {
        try {
          await logic.deleteAccount();
          Get.offAllNamed(AppRoutes.login);
          Get.snackbar(
            'Account deleted',
            'Your local coins and generated data have been removed.',
            snackPosition: SnackPosition.BOTTOM,
          );
        } catch (e) {
          Get.snackbar(
            'Delete failed',
            e.toString(),
            snackPosition: SnackPosition.BOTTOM,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: const Color(0xFFFFF6F9),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: <Widget>[
              const _Header(),
              const SizedBox(height: 12),
              const _LogoSection(),
              const SizedBox(height: 14),
              _BigCoinsCard(
                coins: logic.coins,
                onTap: () => Get.toNamed(AppRoutes.coins),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                children: <Widget>[
                  _ActionTile(
                    icon: Icons.history_rounded,
                    title: 'My Timeline',
                    subtitle: 'Review your memories',
                    iconBg: const Color(0xFFFFE6EE),
                    iconColor: const Color(0xFFFF6F91),
                    onTap: () => Get.toNamed(AppRoutes.history),
                  ),
                  const Divider(height: 1, color: Color(0xFFFBE2EA)),
                  _ActionTile(
                    icon: Icons.feedback_outlined,
                    title: 'Feedback',
                    subtitle: 'Help us improve Flira',
                    iconBg: const Color(0xFFFFEAF0),
                    iconColor: const Color(0xFFFF8FA3),
                    onTap: () => Get.toNamed(AppRoutes.feedback),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                children: <Widget>[
                  _ActionTile(
                    icon: Icons.privacy_tip_outlined,
                    title: 'Privacy Policy',
                    subtitle: 'How we handle your data',
                    iconBg: const Color(0xFFFFEEF3),
                    iconColor: const Color(0xFFFF8FA3),
                    onTap: _openPrivacy,
                  ),
                  const Divider(height: 1, color: Color(0xFFFBE2EA)),
                  _ActionTile(
                    icon: Icons.article_outlined,
                    title: 'Terms of Service',
                    subtitle: 'Our terms and conditions',
                    iconBg: const Color(0xFFFFEEF3),
                    iconColor: const Color(0xFFFF8FA3),
                    onTap: _openTerms,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SectionCard(
                children: <Widget>[
                  _ActionTile(
                    icon: Icons.logout_rounded,
                    title: 'Log out',
                    subtitle: 'Sign out and return to login',
                    iconBg: const Color(0xFFFFEEF3),
                    iconColor: const Color(0xFFFF7E9D),
                    onTap: _onLogoutTap,
                  ),
                  const Divider(height: 1, color: Color(0xFFFBE2EA)),
                  _ActionTile(
                    icon: Icons.person_remove_alt_1_rounded,
                    title: 'Delete account',
                    subtitle: 'Permanently remove this account',
                    iconBg: const Color(0xFFFFE7ED),
                    iconColor: const Color(0xFFE85A82),
                    onTap: _onDeleteAccountTap,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        'My Profile',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: Color(0xFFFF6F91),
        ),
      ),
    );
  }
}

class _LogoSection extends StatelessWidget {
  const _LogoSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF2E7EC)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        children: <Widget>[
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF8F2F5),
              border: Border.all(color: const Color(0xFFF6C6D4), width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              A.assets_flira_logo,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Flira',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    );
  }
}

class _BigCoinsCard extends StatefulWidget {
  const _BigCoinsCard({required this.coins, this.onTap});

  final int coins;
  final VoidCallback? onTap;

  @override
  State<_BigCoinsCard> createState() => _BigCoinsCardState();
}

class _BigCoinsCardState extends State<_BigCoinsCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.985 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(24),
          splashColor: const Color(0x24FFFFFF),
          highlightColor: const Color(0x18FFFFFF),
          onHighlightChanged: (bool value) {
            if (mounted) {
              setState(() => _isPressed = value);
            }
          },
          child: Ink(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(
                colors: <Color>[Color(0xFFFFA0B9), Color(0xFFF37EA0)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Color(0x3DF07E9D),
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Stack(
              children: <Widget>[
                Positioned(
                  top: -24,
                  right: -28,
                  child: Container(
                    width: 132,
                    height: 132,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[Color(0x66FFE49A), Color(0x00FFE49A)],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -14,
                  left: -10,
                  child: Container(
                    width: 86,
                    height: 86,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: <Color>[Color(0x45FFD56A), Color(0x00FFD56A)],
                      ),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: <Color>[Color(0xFFFFD978), Color(0xFFF4B94E)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            border: Border.all(color: const Color(0x80FFFFFF)),
                            boxShadow: const <BoxShadow>[
                              BoxShadow(
                                color: Color(0x44E7A93B),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.monetization_on_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Flira Coins',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFFFE9F0),
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Current Balance',
                      style: TextStyle(
                        color: Color(0xFFFFEEF3),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        Text(
                          '${widget.coins}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            height: 1,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'coins',
                            style: TextStyle(
                              color: Color(0xFFFFEEF3),
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE1EA)),
      ),
      child: Column(children: children),
    );
  }
}

class _ActionTile extends StatefulWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconBg,
    required this.iconColor,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconBg;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  State<_ActionTile> createState() => _ActionTileState();
}

class _ActionTileState extends State<_ActionTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: const Color(0x22FF9DB0),
          highlightColor: const Color(0x1AFF9DB0),
          onHighlightChanged: (bool value) {
            if (mounted) {
              setState(() => _isPressed = value);
            }
          },
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            leading: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: widget.iconBg,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(widget.icon, color: widget.iconColor, size: 20),
            ),
            title: Text(
              widget.title,
              style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF4A3A40)),
            ),
            subtitle: Text(
              widget.subtitle,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9D7D87)),
            ),
            trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFFF9DB0)),
          ),
        ),
      ),
    );
  }
}
