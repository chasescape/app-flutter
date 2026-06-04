import 'package:flutter/material.dart';

import '../env/app_env.dart';
import '../light_handle.dart';
import 'dodge_blocks_coin_page.dart';
import 'favio_palette.dart';
import 'game_progress_store.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _openCoinStore(BuildContext context) async {
    final GameProgressStore store = GameProgressStore.instance;
    final int? nextCoins = await openDodgeBlocksCoinPage(
      context,
      currentCoins: store.coins,
      bestScore: store.bestScore,
    );

    if (nextCoins != null) {
      store.setCoins(nextCoins);
    }
  }

  Future<void> _showFeedbackSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ActionSheetCard(
          title: 'Feedback',
          body:
              'Feedback entry will connect here next. For now, this is the reserved support channel.',
          primaryLabel: 'Close',
          onPrimaryTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Future<void> _showAgreementSheet(
    BuildContext context, {
    required String title,
    required String url,
  }) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ActionSheetCard(
          title: title,
          body: url.isEmpty || url == 'N/A'
              ? '$title link is not configured yet.'
              : url,
          primaryLabel: 'Close',
          onPrimaryTap: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ActionSheetCard(
          title: 'Log Out',
          body:
              'You will leave the current session and return with cleared auth state.',
          primaryLabel: 'Log Out',
          primaryDestructive: true,
          onPrimaryTap: () async {
            Navigator.of(context).pop();
            await LightHandle.logout();
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return _ActionSheetCard(
          title: 'Delete Account',
          body:
              'This action is destructive. It is wired as a placeholder action right now.',
          primaryLabel: 'Delete',
          primaryDestructive: true,
          onPrimaryTap: () async {
            Navigator.of(context).pop();
            await LightHandle.deleteAccount();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameProgressStore.instance,
      builder: (BuildContext context, Widget? child) {
        final GameProgressStore store = GameProgressStore.instance;
        return Scaffold(
          backgroundColor: FavioPalette.backgroundAlt,
          body: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: <Color>[
                  FavioPalette.backgroundTop,
                  FavioPalette.backgroundMid,
                  FavioPalette.backgroundBottom,
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: <Widget>[
                  const Positioned.fill(child: _ProfileBackdrop()),
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 10, 18, 26),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _ProfileTopBar(
                                store: store,
                                onCoinsTap: () => _openCoinStore(context),
                              ),
                              const SizedBox(height: 18),
                              _IdentityCard(store: store),
                              const SizedBox(height: 22),
                              _ActionGroup(
                                title: 'SHORTCUTS',
                                children: <Widget>[
                                  _ProfileActionTile(
                                    label: 'Coins',
                                    subtitle: '${store.coins} C available',
                                    accent: FavioPalette.brandGlow,
                                    onTap: () => _openCoinStore(context),
                                  ),
                                  _ProfileActionTile(
                                    label: 'Feedback',
                                    subtitle: 'Send support notes',
                                    accent: const Color(0xFF7DD3FC),
                                    onTap: () => _showFeedbackSheet(context),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _ActionGroup(
                                title: 'LEGAL',
                                children: <Widget>[
                                  _ProfileActionTile(
                                    label: 'Terms of Service',
                                    subtitle: 'View user agreement',
                                    accent: const Color(0xFFFFFFFF),
                                    darkText: true,
                                    onTap: () => _showAgreementSheet(
                                      context,
                                      title: 'Terms of Service',
                                      url: AppEnv().h5User,
                                    ),
                                  ),
                                  _ProfileActionTile(
                                    label: 'Privacy Policy',
                                    subtitle: 'View privacy notice',
                                    accent: const Color(0xFFB689FF),
                                    onTap: () => _showAgreementSheet(
                                      context,
                                      title: 'Privacy Policy',
                                      url: AppEnv().h5Privacy,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              _ActionGroup(
                                title: 'ACCOUNT',
                                children: <Widget>[
                                  _ProfileActionTile(
                                    label: 'Log Out',
                                    subtitle: 'End current session',
                                    accent: const Color(0xFF101217),
                                    onTap: () => _confirmLogout(context),
                                  ),
                                  _ProfileActionTile(
                                    label: 'Delete Account',
                                    subtitle: 'Permanent removal',
                                    accent: const Color(0xFFFF5D73),
                                    onTap: () => _confirmDeleteAccount(context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProfileTopBar extends StatelessWidget {
  const _ProfileTopBar({
    required this.store,
    required this.onCoinsTap,
  });

  final GameProgressStore store;
  final VoidCallback onCoinsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xFF101217),
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'FAVIO PROFILE',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                store.rankLabel,
                style: const TextStyle(
                  color: Color(0xFFD4D6DD),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onCoinsTap,
            child: Ink(
              color: FavioPalette.brandGlow,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '${store.coins} C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.store,
  });

  final GameProgressStore store;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: _ProfileClipper(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              FavioPalette.brandBright,
              FavioPalette.brand,
              FavioPalette.brandDark,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Text(
              'GAME',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'FAVIO',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.0,
                height: 0.95,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              store.totalRuns == 0
                  ? 'Start one run to create your first record.'
                  : 'Best score ${store.bestScore}. Reach ${GameProgressStore.clearScoreTarget} best-score points for full clear.',
              style: const TextStyle(
                color: FavioPalette.brandSoftText,
                fontSize: 14,
                height: 1.45,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _IdentityBadge(
                  label: 'BEST ${store.bestScore}',
                ),
                const SizedBox(width: 10),
                _IdentityBadge(
                  label: 'RUNS ${store.totalRuns}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionGroup extends StatelessWidget {
  const _ActionGroup({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          color: FavioPalette.brandGlow,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ..._withSpacing(children, 12),
      ],
    );
  }

  List<Widget> _withSpacing(List<Widget> widgets, double spacing) {
    final List<Widget> result = <Widget>[];
    for (int i = 0; i < widgets.length; i++) {
      result.add(widgets[i]);
      if (i != widgets.length - 1) {
        result.add(SizedBox(height: spacing));
      }
    }
    return result;
  }
}

class _ProfileActionTile extends StatelessWidget {
  const _ProfileActionTile({
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.darkText = false,
  });

  final String label;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final bool darkText;

  @override
  Widget build(BuildContext context) {
    final Color textColor = darkText ? const Color(0xFF111111) : Colors.white;

    return Transform.rotate(
      angle: darkText ? -0.02 : 0.02,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: accent,
              border: Border.all(
                color: darkText
                    ? Colors.transparent
                    : Colors.white.withValues(alpha: 0.10),
              ),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        label,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: textColor.withValues(alpha: 0.82),
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: textColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionSheetCard extends StatelessWidget {
  const _ActionSheetCard({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimaryTap,
    this.primaryDestructive = false,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final VoidCallback onPrimaryTap;
  final bool primaryDestructive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipPath(
        clipper: _ProfileClipper(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                FavioPalette.brandBright,
                FavioPalette.brand,
                FavioPalette.brandDark,
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: const TextStyle(
                  color: FavioPalette.brandSoftText,
                  fontSize: 14,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        foregroundColor: Colors.white,
                        side: BorderSide(
                          color: Colors.white.withValues(alpha: 0.24),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: onPrimaryTap,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        backgroundColor: primaryDestructive
                            ? const Color(0xFFFF5D73)
                            : Colors.white,
                        foregroundColor: primaryDestructive
                            ? Colors.white
                            : const Color(0xFF111111),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: Text(primaryLabel),
                    ),
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

class _IdentityBadge extends StatelessWidget {
  const _IdentityBadge({
    required this.label,
  });

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF111111),
          fontSize: 11,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _ProfileBackdrop extends StatelessWidget {
  const _ProfileBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ProfileBackdropPainter(),
    );
  }
}

class _ProfileClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..moveTo(size.width * 0.06, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.95, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _ProfileBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint red = Paint()
      ..color = FavioPalette.brandShadow.withValues(alpha: 0.80);
    final Paint black = Paint()..color = const Color(0xFF11151D);
    final Paint line = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.1;

    final Path topShape = Path()
      ..moveTo(size.width * 0.58, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.24)
      ..lineTo(size.width * 0.82, size.height * 0.18)
      ..close();
    canvas.drawPath(topShape, red);

    final Path sideShape = Path()
      ..moveTo(0, size.height * 0.44)
      ..lineTo(size.width * 0.18, size.height * 0.30)
      ..lineTo(size.width * 0.28, size.height * 0.72)
      ..lineTo(0, size.height * 0.82)
      ..close();
    canvas.drawPath(sideShape, black);

    for (double i = -size.height; i < size.width; i += 24) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        line,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
