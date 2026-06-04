import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotou/gen_a/A.dart';
import 'package:hotou/hotou/features/game_progress.dart';
import 'package:hotou/hotou/features/login_page.dart';
import 'package:hotou/hotou/features/profile_detail_pages.dart';
import 'package:hotou/hotou/light_handle.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _goBack(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.of(context).pop();
  }

  void _openPage(BuildContext context, Widget page) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (context) => page),
    );
  }

  Future<void> _handleLogOut(BuildContext context) async {
    HapticFeedback.selectionClick();
    await LightHandle.logout();
    if (!context.mounted) {
      return;
    }
    _goToLogin(context);
  }

  Future<void> _handleDeleteAccount(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final confirmed = await _confirmDeleteAccount(context);
    if (!confirmed || !context.mounted) {
      return;
    }

    await LightHandle.deleteAccount();
    if (!context.mounted) {
      return;
    }
    _goToLogin(context);
  }

  Future<bool> _confirmDeleteAccount(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Account?'),
              content: const Text(
                'This removes local profile data from this device. This action cannot be undone.',
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF263D32),
                    foregroundColor: const Color(0xFFFFF7DF),
                  ),
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _goToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _ProfileBackground()),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _ProfileTopBar(onBack: () => _goBack(context)),
                  const SizedBox(height: 20),
                  const _ProfileHeroCard(),
                  const SizedBox(height: 16),
                  const _ProfileStatsGrid(),
                  const SizedBox(height: 18),
                  _ProfileSection(
                    title: 'Player',
                    children: <Widget>[
                      _ProfileMenuRow(
                        icon: Icons.feedback_rounded,
                        title: 'Feedback',
                        subtitle: 'Share ideas and report issues',
                        onTap: () => _openPage(context, const FeedbackPage()),
                      ),
                      _ProfileMenuRow(
                        icon: Icons.paid_rounded,
                        title: 'Coins',
                        subtitle: 'View your coin balance',
                        onTap: () => _openPage(context, const CoinsPage()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProfileSection(
                    title: 'Agreements',
                    children: <Widget>[
                      _ProfileMenuRow(
                        icon: Icons.article_rounded,
                        title: 'User Agreement',
                        subtitle: 'Read the app terms',
                        onTap: () => _openPage(
                          context,
                          const AgreementPage(
                            type: AgreementType.userAgreement,
                          ),
                        ),
                      ),
                      _ProfileMenuRow(
                        icon: Icons.privacy_tip_rounded,
                        title: 'Privacy Policy',
                        subtitle: 'Review privacy details',
                        onTap: () => _openPage(
                          context,
                          const AgreementPage(
                            type: AgreementType.privacyPolicy,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ProfileSection(
                    title: 'Account Actions',
                    children: <Widget>[
                      _ProfileMenuRow(
                        icon: Icons.logout_rounded,
                        title: 'Log Out',
                        subtitle: 'Sign out of this profile',
                        onTap: () => _handleLogOut(context),
                      ),
                      _ProfileMenuRow(
                        icon: Icons.delete_forever_rounded,
                        title: 'Delete Account',
                        subtitle: 'Remove this account',
                        onTap: () => _handleDeleteAccount(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          label: 'Back to home',
          onPressed: onBack,
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Text(
            'Profile',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Color(0xFF22382E),
              fontSize: 28,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8).withOpacity(0.92),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withOpacity(0.72), width: 2),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF526840).withOpacity(0.18),
            blurRadius: 28,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF355D4B).withOpacity(0.2),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              A.assets_hotou_logo,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'HotoU',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF24382F),
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                SizedBox(height: 12),
                _ProfileBadge(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileBadge extends StatelessWidget {
  const _ProfileBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF3D8),
        borderRadius: BorderRadius.circular(99),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.eco_rounded, color: Color(0xFF355D4B), size: 15),
          SizedBox(width: 5),
          Text(
            'Local Guest',
            style: TextStyle(
              color: Color(0xFF355D4B),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStatsGrid extends StatelessWidget {
  const _ProfileStatsGrid();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: GameProgress.highestLevel,
      builder: (context, highestLevel, child) {
        return Row(
          children: <Widget>[
            const Expanded(
              child: _ProfileStatCard(
                label: 'Best',
                value: '0',
                icon: Icons.auto_graph_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProfileStatCard(
                label: 'Levels',
                value: '$highestLevel',
                icon: Icons.flag_rounded,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: _ProfileStatCard(
                label: 'Streak',
                value: '0',
                icon: Icons.local_fire_department_rounded,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ProfileStatCard extends StatelessWidget {
  const _ProfileStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 100),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.52),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.74)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: const Color(0xFF355D4B), size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF24382F),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF66796D),
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8).withOpacity(0.82),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.68)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xFF24382F),
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }
}

class _ProfileMenuRow extends StatelessWidget {
  const _ProfileMenuRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: title,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            if (onTap != null) {
              onTap!();
              return;
            }
            HapticFeedback.selectionClick();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 9),
            child: Row(
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF3D8),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: const Color(0xFF355D4B), size: 21),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF24382F),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF66796D),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF7B8E80),
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.label,
    this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      child: Material(
        color: Colors.white.withOpacity(0.58),
        clipBehavior: Clip.antiAlias,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed ??
              () {
                HapticFeedback.selectionClick();
              },
          child: SizedBox(
            width: 46,
            height: 46,
            child: Icon(icon, color: const Color(0xFF355D4B), size: 21),
          ),
        ),
      ),
    );
  }
}

class _ProfileBackground extends StatelessWidget {
  const _ProfileBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFFF2C2),
            Color(0xFFDDEBB6),
            Color(0xFFAED7BF),
          ],
        ),
      ),
      child: CustomPaint(painter: _ProfilePatternPainter()),
    );
  }
}

class _ProfilePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stripePaint = Paint()
      ..color = const Color(0xFF8FB47D).withOpacity(0.13)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (double x = -size.height; x < size.width; x += 36) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        stripePaint,
      );
    }

    final glowPaint = Paint()
      ..color = const Color(0xFFFFD170).withOpacity(0.22)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size.width - 36, 96), 108, glowPaint);
    canvas.drawCircle(Offset(22, size.height - 120), 130, glowPaint);

    final dotPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    for (double y = 40; y < size.height; y += 86) {
      for (double x = 32; x < size.width; x += 90) {
        canvas.drawCircle(Offset(x, y), 3.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
