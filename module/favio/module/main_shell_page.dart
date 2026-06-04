import 'dart:ui';

import 'package:flutter/material.dart';

import '../env/app_env.dart';
import '../light_handle.dart';
import 'agreement_page.dart';
import 'dodge_blocks_coin_page.dart';
import 'dodge_blocks_game_page.dart';
import 'feedback_page.dart';
import 'favio_palette.dart';
import 'game_progress_store.dart';

const double _actionRailGap = 12;
const double _sideActionCardHeight = 92;
const double _mainActionButtonHeight =
    (_sideActionCardHeight * 2) + _actionRailGap;

class MainShellPage extends StatefulWidget {
  const MainShellPage({super.key});

  @override
  State<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends State<MainShellPage> {
  final GlobalKey _pageStackKey = GlobalKey();
  final GlobalKey _profileCardKey = GlobalKey();

  bool _isProfileMenuOpen = false;
  bool _isProfileMenuClosing = false;
  Rect? _profileCardRect;

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
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const FeedbackPage(),
      ),
    );
  }

  Future<void> _showAgreementSheet(
    BuildContext context, {
    required String title,
    required String url,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AgreementPage(
          title: title,
          url: url,
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.30),
      builder: (BuildContext dialogContext) {
        return _GlassConfirmDialog(
          title: 'Log Out',
          body:
              'You will leave the current session and return with cleared auth state.',
          primaryLabel: 'Log Out',
          primaryDestructive: true,
          onPrimaryTap: () async {
            Navigator.of(dialogContext).pop();
            await LightHandle.logout();
          },
        );
      },
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.30),
      builder: (BuildContext dialogContext) {
        return _GlassConfirmDialog(
          title: 'Delete Account',
          body: 'This action is destructive. Please confirm before continuing.',
          primaryLabel: 'Delete',
          primaryDestructive: true,
          onPrimaryTap: () async {
            Navigator.of(dialogContext).pop();
            await LightHandle.deleteAccount();
          },
        );
      },
    );
  }

  void _closeProfileMenu() {
    if (!_isProfileMenuOpen || _isProfileMenuClosing) {
      return;
    }

    setState(() {
      _isProfileMenuClosing = true;
    });

    Future<void>.delayed(const Duration(milliseconds: 360), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isProfileMenuOpen = false;
        _isProfileMenuClosing = false;
      });
    });
  }

  void _toggleProfileMenu() {
    if (_isProfileMenuOpen) {
      _closeProfileMenu();
      return;
    }

    final BuildContext? profileContext = _profileCardKey.currentContext;
    final BuildContext? stackContext = _pageStackKey.currentContext;
    if (profileContext == null || stackContext == null) {
      return;
    }

    final RenderBox profileBox =
        profileContext.findRenderObject()! as RenderBox;
    final RenderBox stackBox = stackContext.findRenderObject()! as RenderBox;
    final Offset localOffset = profileBox.localToGlobal(
      Offset.zero,
      ancestor: stackBox,
    );

    setState(() {
      _profileCardRect = localOffset & profileBox.size;
      _isProfileMenuOpen = true;
      _isProfileMenuClosing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: GameProgressStore.instance,
      builder: (BuildContext context, Widget? child) {
        final GameProgressStore store = GameProgressStore.instance;
        return Scaffold(
          backgroundColor: FavioPalette.background,
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
                key: _pageStackKey,
                children: <Widget>[
                  const Positioned.fill(
                    child: _PersonaBackdrop(),
                  ),
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: <Widget>[
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              _HomeTopBar(
                                store: store,
                                onCoinsTap: () => _openCoinStore(context),
                              ),
                              const SizedBox(height: 18),
                              _HeroPanel(store: store),
                              const SizedBox(height: 18),
                              _ActionRail(
                                store: store,
                                profileCardKey: _profileCardKey,
                                isProfileMenuOpen: _isProfileMenuOpen,
                                onProfileTap: _toggleProfileMenu,
                              ),
                              const SizedBox(height: 22),
                              _RecordStrip(store: store),
                              const SizedBox(height: 20),
                              _LoadingCard(store: store),
                              const SizedBox(height: 18),
                              _BattlePreviewCard(store: store),
                              const SizedBox(height: 24),
                              const _TipsBanner(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_isProfileMenuOpen)
                    Positioned.fill(
                      child: GestureDetector(
                        onTap: _closeProfileMenu,
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            color: Colors.white.withValues(alpha: 0.05),
                          ),
                        ),
                      ),
                    ),
                  if (_isProfileMenuOpen && _profileCardRect != null)
                    Positioned.fill(
                      child: _ProfileFanOverlay(
                        anchorRect: _profileCardRect!,
                        isClosing: _isProfileMenuClosing,
                        onCloseTap: _closeProfileMenu,
                        onCoinsTap: () => _openCoinStore(context),
                        onFeedbackTap: () => _showFeedbackSheet(context),
                        onTermsTap: () => _showAgreementSheet(
                          context,
                          title: 'Terms of Service',
                          url: AppEnv().h5User,
                        ),
                        onPrivacyTap: () => _showAgreementSheet(
                          context,
                          title: 'Privacy Policy',
                          url: AppEnv().h5Privacy,
                        ),
                        onLogoutTap: () => _confirmLogout(context),
                        onDeleteTap: () => _confirmDeleteAccount(context),
                      ),
                    ),
                  if (_isProfileMenuOpen && _profileCardRect != null)
                    Positioned(
                      left: _profileCardRect!.left,
                      top: _profileCardRect!.top,
                      width: _profileCardRect!.width,
                      height: _profileCardRect!.height,
                      child: IgnorePointer(
                        child: _SideActionCard(
                          title: 'CLOSE',
                          subtitle: 'Fold petals',
                          accent: const Color(0xFF101217),
                          onTap: () {},
                        ),
                      ),
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

class _HomeTopBar extends StatelessWidget {
  const _HomeTopBar({
    required this.store,
    required this.onCoinsTap,
  });

  final GameProgressStore store;
  final VoidCallback onCoinsTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Transform.rotate(
          angle: -0.15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(color: FavioPalette.brandGlow),
            child: const Text(
              'MENU',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.3,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const Text(
                'FAVIO',
                style: TextStyle(
                  color: Color(0xFFF4F4F5),
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                store.statusLabel.toUpperCase(),
                style: const TextStyle(
                  color: Color(0xFFCACBD2),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        _TiltTag(
          color: const Color(0xFF10141E),
          borderColor: const Color(0x33FFFFFF),
          label: '${store.coins}',
          icon: Icons.currency_bitcoin_rounded,
          onTap: onCoinsTap,
        ),
      ],
    );
  }
}

class _HeroPanel extends StatelessWidget {
  const _HeroPanel({
    required this.store,
  });

  final GameProgressStore store;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 0.94,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Positioned.fill(
            top: 18,
            child: ClipPath(
              clipper: _SlashClipper(),
              child: DecoratedBox(
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
                child: Stack(
                  children: <Widget>[
                    const Positioned.fill(
                      child: _HeroPattern(),
                    ),
                    Positioned(
                      right: -18,
                      top: 0,
                      bottom: 0,
                      child: IgnorePointer(
                        child: CustomPaint(
                          size: const Size(190, 420),
                          painter: _MaskPainter(),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(22, 54, 22, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Spacer(),
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: <Color>[
                                  Colors.white,
                                  FavioPalette.brandBright,
                                ],
                              ).createShader(bounds);
                            },
                            child: Text(
                              store.totalRuns == 0
                                  ? 'START FAVIO'
                                  : 'PLAY FAVIO',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.w900,
                                height: 0.95,
                                letterSpacing: -1.3,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          ShaderMask(
                            blendMode: BlendMode.srcIn,
                            shaderCallback: (Rect bounds) {
                              return const LinearGradient(
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                                colors: <Color>[
                                  Colors.white,
                                  FavioPalette.brandBright,
                                ],
                              ).createShader(bounds);
                            },
                            child: Text(
                              store.totalRuns == 0
                                  ? 'Drag to move, dodge every falling block, and survive long enough to build your first score.'
                                  : 'Move left and right to dodge fast blocks, hunter blocks, and wall waves. Score rises over time, and 1000 best-score points means 100% clear.',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.45,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: <Widget>[
                              _TiltTag(
                                color: Colors.white,
                                textColor: const Color(0xFF111111),
                                label: store.rankLabel,
                                icon: Icons.bolt_rounded,
                              ),
                              const SizedBox(width: 10),
                              _TiltTag(
                                color: const Color(0xFF111111),
                                borderColor: const Color(0x4DFFFFFF),
                                label: 'BEST ${store.bestScore}',
                                icon: Icons.trending_up_rounded,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionRail extends StatelessWidget {
  const _ActionRail({
    required this.store,
    required this.profileCardKey,
    required this.isProfileMenuOpen,
    required this.onProfileTap,
  });

  final GameProgressStore store;
  final GlobalKey profileCardKey;
  final bool isProfileMenuOpen;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          flex: 7,
          child: _MainActionButton(
            label: 'START GAME',
            sublabel: store.totalRuns == 0
                ? 'First mission'
                : 'Last score ${store.lastScore}',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const DodgeBlocksGamePage(),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: _actionRailGap),
        Expanded(
          flex: 4,
          child: Column(
            children: <Widget>[
              KeyedSubtree(
                key: profileCardKey,
                child: _SideActionCard(
                  title: isProfileMenuOpen ? 'CLOSE' : 'PROFILE',
                  subtitle: isProfileMenuOpen ? 'Fold petals' : 'Open options',
                  accent: const Color(0xFF101217),
                  onTap: onProfileTap,
                ),
              ),
              const SizedBox(height: _actionRailGap),
              _SideActionCard(
                title: 'LOADING',
                subtitle: '${store.clearPercent}% clear',
                accent: FavioPalette.brandGlow,
                textColor: Colors.white,
                onTap: () {},
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordStrip extends StatelessWidget {
  const _RecordStrip({
    required this.store,
  });

  final GameProgressStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _RecordCard(
            label: 'BEST',
            value: '${store.bestScore}',
            angle: -0.08,
            fill: const Color(0xFFFFFFFF),
            textColor: const Color(0xFF111111),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RecordCard(
            label: 'LAST',
            value: '${store.lastScore}',
            angle: 0.06,
            fill: FavioPalette.brandGlow,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _RecordCard(
            label: 'RUNS',
            value: '${store.totalRuns}',
            angle: -0.03,
            fill: const Color(0xFF101217),
          ),
        ),
      ],
    );
  }
}

class _ProfileFanOverlay extends StatelessWidget {
  const _ProfileFanOverlay({
    required this.anchorRect,
    required this.isClosing,
    required this.onCloseTap,
    required this.onCoinsTap,
    required this.onFeedbackTap,
    required this.onTermsTap,
    required this.onPrivacyTap,
    required this.onLogoutTap,
    required this.onDeleteTap,
  });

  final Rect anchorRect;
  final bool isClosing;
  final VoidCallback onCloseTap;
  final VoidCallback onCoinsTap;
  final VoidCallback onFeedbackTap;
  final VoidCallback onTermsTap;
  final VoidCallback onPrivacyTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onDeleteTap;

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double baseLeft = anchorRect.left - 250;
    final double baseTop = anchorRect.top - 178;
    final double privacyRightShift = screenWidth <= 430 ? 42 : 16;

    return IgnorePointer(
      ignoring: false,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          _buildPosterWord(
            left: baseLeft + 58,
            top: baseTop + 30,
            label: 'Coins',
            color: const Color(0xFF6B31F4),
            rotation: 0.34,
            scale: 0.94,
            delay: 0,
            solidWhiteText: true,
            isClosing: isClosing,
            onTap: onCoinsTap,
          ),
          _buildPosterWord(
            left: baseLeft + 42,
            top: baseTop + 82,
            label: 'Feedback',
            color: const Color(0xFF2A51D5),
            rotation: 0.22,
            scale: 1.04,
            delay: 40,
            solidWhiteText: true,
            isClosing: isClosing,
            onTap: onFeedbackTap,
          ),
          _buildPosterWord(
            left: baseLeft + 54,
            top: baseTop + 142,
            label: 'Terms',
            color: const Color(0xFF1C2134),
            rotation: 0.08,
            scale: 1.10,
            delay: 80,
            solidWhiteText: true,
            isClosing: isClosing,
            onTap: onTermsTap,
          ),
          _buildPosterWord(
            left: baseLeft + 18 + privacyRightShift,
            top: baseTop + 232,
            label: 'Privacy',
            color: const Color(0xFF4A2AA2),
            rotation: -0.14,
            scale: 1.18,
            delay: 120,
            gradientMode: _PosterWordGradientMode.purpleToWhite,
            isClosing: isClosing,
            onTap: onPrivacyTap,
          ),
          _buildPosterWord(
            left: baseLeft + 78,
            top: baseTop + 310,
            label: 'Logout',
            color: const Color(0xFF151A26),
            rotation: -0.30,
            scale: 1.00,
            delay: 160,
            gradientMode: _PosterWordGradientMode.blackToWhite,
            isClosing: isClosing,
            onTap: onLogoutTap,
          ),
          _buildPosterWord(
            left: baseLeft + 152,
            top: baseTop + 370,
            label: 'Delete',
            color: const Color(0xFFFF5D73),
            rotation: -0.46,
            scale: 0.92,
            delay: 200,
            gradientMode: _PosterWordGradientMode.redToWhite,
            isClosing: isClosing,
            onTap: onDeleteTap,
          ),
        ],
      ),
    );
  }

  Widget _buildPosterWord({
    required double left,
    required double top,
    required String label,
    required Color color,
    required double rotation,
    required double scale,
    required int delay,
    bool solidWhiteText = false,
    _PosterWordGradientMode gradientMode = _PosterWordGradientMode.defaultFade,
    required bool isClosing,
    required VoidCallback onTap,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: _PosterWordAction(
        label: label,
        color: color,
        rotation: rotation,
        scale: scale,
        visible: true,
        delay: delay,
        solidWhiteText: solidWhiteText,
        gradientMode: gradientMode,
        isClosing: isClosing,
        onTap: onTap,
      ),
    );
  }
}

enum _PosterWordGradientMode {
  defaultFade,
  purpleToWhite,
  blackToWhite,
  redToWhite,
}

class _PosterWordAction extends StatelessWidget {
  const _PosterWordAction({
    required this.label,
    required this.color,
    required this.rotation,
    required this.scale,
    required this.visible,
    required this.delay,
    required this.solidWhiteText,
    required this.gradientMode,
    required this.isClosing,
    required this.onTap,
  });

  final String label;
  final Color color;
  final double rotation;
  final double scale;
  final bool visible;
  final int delay;
  final bool solidWhiteText;
  final _PosterWordGradientMode gradientMode;
  final bool isClosing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    const double width = 220;
    const double height = 86;

    return IgnorePointer(
      ignoring: !visible,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 240 + delay),
        curve: Curves.easeOut,
        opacity: visible && !isClosing ? 1 : 0,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(
            begin: 1,
            end: visible && !isClosing ? 0 : 1,
          ),
          duration: Duration(milliseconds: 320 + delay),
          curve: isClosing ? Curves.easeInCubic : Curves.easeOutBack,
          builder: (BuildContext context, double value, Widget? child) {
            return Transform.translate(
              offset: Offset(0, isClosing ? 58 * value : 34 * value),
              child: Transform.rotate(
                angle: rotation + ((isClosing ? 0.20 : -0.26) * value),
                alignment: Alignment.bottomCenter,
                child: Transform.scale(
                  scale: scale * (1 - ((isClosing ? 0.10 : 0.14) * value)),
                  alignment: Alignment.bottomCenter,
                  child: child,
                ),
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: Ink(
                width: width,
                height: height,
                decoration: const BoxDecoration(
                  color: Colors.transparent,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Positioned(
                      left: 10,
                      right: 12,
                      top: 20,
                      child: Container(
                        height: 22,
                        color: Color.lerp(color, Colors.black, 0.12),
                      ),
                    ),
                    Positioned(
                      left: 0,
                      top: 0,
                      child: ShaderMask(
                        blendMode: BlendMode.srcIn,
                        shaderCallback: (Rect bounds) {
                          return _buildTextGradient().createShader(bounds);
                        },
                        child: Text(
                          label.toUpperCase(),
                          maxLines: 2,
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            height: 0.82,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  LinearGradient _buildTextGradient() {
    if (solidWhiteText) {
      return const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Colors.white,
          Colors.white,
        ],
      );
    }

    switch (gradientMode) {
      case _PosterWordGradientMode.purpleToWhite:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFB67CFF),
            Color(0xFFE8D9FF),
            Colors.white,
          ],
        );
      case _PosterWordGradientMode.blackToWhite:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFF121520),
            Color(0xFF8F94A4),
            Colors.white,
          ],
        );
      case _PosterWordGradientMode.redToWhite:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Color(0xFFFF5D73),
            Color(0xFFFFB7C1),
            Colors.white,
          ],
        );
      case _PosterWordGradientMode.defaultFade:
        return const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.white,
            Color(0xFFE6D8FF),
            Color(0xFFB67CFF),
          ],
        );
    }
  }
}

class _GlassConfirmDialog extends StatelessWidget {
  const _GlassConfirmDialog({
    required this.title,
    required this.body,
    required this.primaryLabel,
    this.primaryDestructive = false,
    this.onPrimaryTap,
  });

  final String title;
  final String body;
  final String primaryLabel;
  final bool primaryDestructive;
  final VoidCallback? onPrimaryTap;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 22),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF171A24).withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
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
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFFD2D6DF),
                    fontSize: 13,
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
                          foregroundColor: Colors.white,
                          side: BorderSide(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.02),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed:
                            onPrimaryTap ?? () => Navigator.of(context).pop(),
                        style: FilledButton.styleFrom(
                          backgroundColor: primaryDestructive
                              ? const Color(0xFFFF5D73)
                              : FavioPalette.brandGlow,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard({
    required this.store,
  });

  final GameProgressStore store;

  @override
  Widget build(BuildContext context) {
    final double progress = store.clearProgress;
    final int loading = store.clearPercent;

    return ClipPath(
      clipper: _SlashClipper(),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
        decoration: const BoxDecoration(
          color: Color(0xFF0E1119),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const Padding(
              padding: EdgeInsets.only(left: 12),
              child: _EyebrowLine(
                primary: 'CLEAR PROGRESS',
                secondary: 'Reach 1000 best-score points for 100% clear',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                Text(
                  '$loading%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(width: 10),
                const Padding(
                  padding: EdgeInsets.only(bottom: 6),
                  child: Text(
                    'CLEAR',
                    style: TextStyle(
                      color: FavioPalette.brandGlow,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Stack(
              children: <Widget>[
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 14,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color(0xFFFFFFFF),
                          FavioPalette.brandGlow,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              store.totalRuns == 0
                  ? 'How to play: drag to move and dodge every block. Fast blocks dive quickly, hunter blocks track your lane, and wall waves leave only narrow gaps.'
                  : store.isCleared
                      ? 'Clear complete. Best score ${store.bestScore}. You reached 100% progress by hitting the 1000-point clear target.'
                      : 'Score increases while you stay alive. Best score ${store.bestScore} / ${GameProgressStore.clearScoreTarget}, highest danger LV ${store.highestDangerLevel}, clear progress ${store.clearPercent}%.',
              style: const TextStyle(
                color: Color(0xFFC7CBD5),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BattlePreviewCard extends StatelessWidget {
  const _BattlePreviewCard({
    required this.store,
  });

  final GameProgressStore store;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: ClipPath(
            clipper: _SlashClipper(),
            child: Container(
              height: 188,
              color: const Color(0xFF11151D),
              child: const Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: _PreviewGrid(),
                  ),
                  Positioned(
                    left: 20,
                    top: 18,
                    child: _TopLabel(
                      text: 'THREAT PREVIEW',
                    ),
                  ),
                  Positioned(
                    right: 28,
                    top: 44,
                    child: _PreviewEnemy(
                      color: Color(0xFFFFC857),
                      size: 24,
                    ),
                  ),
                  Positioned(
                    right: 54,
                    top: 94,
                    child: _PreviewEnemy(
                      color: Color(0xFF7DD3FC),
                      size: 20,
                    ),
                  ),
                  Positioned(
                    left: 26,
                    bottom: 24,
                    child: _PreviewPlayer(),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 4,
          child: SizedBox(
            height: 188,
            child: Column(
              children: <Widget>[
                Expanded(
                  child: _InfoCard(
                    label: 'BEST THREAT',
                    value: 'LV ${store.highestDangerLevel}',
                    accent: FavioPalette.brandGlow,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: _InfoCard(
                    label: 'COIN REVIVES',
                    value: '${store.totalRevives}',
                    accent: const Color(0xFFFFFFFF),
                    darkText: true,
                    fill: const Color(0xFFFFFFFF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TipsBanner extends StatelessWidget {
  const _TipsBanner();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.03,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(color: FavioPalette.brandGlow),
        child: const Text(
          'TIP // DRAG TO MOVE. YELLOW BLOCKS FALL FAST, BLUE HUNTERS TRACK YOU, WALL WAVES FORCE PERFECT GAPS, SCORE RISES OVER TIME, AND 1000 BEST-SCORE POINTS = 100% CLEAR.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _MainActionButton extends StatelessWidget {
  const _MainActionButton({
    required this.label,
    required this.sublabel,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.04,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            height: _mainActionButtonHeight,
            decoration: const BoxDecoration(
              color: Color(0xFFFFFFFF),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 18, 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text(
                          'MISSION',
                          style: TextStyle(
                            color: FavioPalette.brandGlow,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          label,
                          style: const TextStyle(
                            color: Color(0xFF111111),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            height: 0.95,
                            letterSpacing: -1.0,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          sublabel,
                          style: const TextStyle(
                            color: Color(0xFF3B3B40),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.play_arrow_rounded,
                    size: 42,
                    color: FavioPalette.brandGlow,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SideActionCard extends StatelessWidget {
  const _SideActionCard({
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.textColor = Colors.white,
  });

  final String title;
  final String subtitle;
  final Color accent;
  final Color textColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: _sideActionCardHeight,
      ),
      child: Transform.rotate(
        angle: 0.04,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              width: double.infinity,
              decoration: BoxDecoration(
                color: accent,
                border: Border.all(
                  color: accent == const Color(0xFF101217)
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.transparent,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    FittedBox(
                      alignment: Alignment.centerLeft,
                      fit: BoxFit.scaleDown,
                      child: Text(
                        title,
                        maxLines: 1,
                        style: TextStyle(
                          color: textColor,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textColor.withValues(alpha: 0.86),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.label,
    required this.value,
    required this.angle,
    required this.fill,
    this.textColor = Colors.white,
  });

  final String label;
  final String value;
  final double angle;
  final Color fill;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        height: 96,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        color: fill,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: textColor.withValues(alpha: 0.82),
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.accent,
    this.darkText = false,
    this.fill = const Color(0xFF101217),
  });

  final String label;
  final String value;
  final Color accent;
  final bool darkText;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    final Color textColor = darkText ? const Color(0xFF111111) : Colors.white;

    return Transform.rotate(
      angle: darkText ? 0.05 : -0.04,
      child: Container(
        width: double.infinity,
        color: fill,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              label,
              style: TextStyle(
                color: darkText
                    ? const Color(0xFF3D3D3D)
                    : const Color(0xFFC8CBD4),
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
            Container(
              width: 34,
              height: 5,
              color: accent,
            ),
            Text(
              value,
              style: TextStyle(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TiltTag extends StatelessWidget {
  const _TiltTag({
    required this.color,
    required this.label,
    required this.icon,
    this.borderColor = Colors.transparent,
    this.textColor = Colors.white,
    this.onTap,
  });

  final Color color;
  final Color borderColor;
  final Color textColor;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.06,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color,
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  icon,
                  size: 15,
                  color: textColor,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _EyebrowLine extends StatelessWidget {
  const _EyebrowLine({
    required this.primary,
    required this.secondary,
  });

  final String primary;
  final String secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          primary,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          secondary,
          style: const TextStyle(
            color: Color(0xFFD4D6DD),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _TopLabel extends StatelessWidget {
  const _TopLabel({
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      color: FavioPalette.brandGlow,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _PersonaBackdrop extends StatelessWidget {
  const _PersonaBackdrop();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _BackdropPainter(),
    );
  }
}

class _HeroPattern extends StatelessWidget {
  const _HeroPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _HeroPatternPainter(),
    );
  }
}

class _PreviewGrid extends StatelessWidget {
  const _PreviewGrid();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _PreviewGridPainter(),
    );
  }
}

class _PreviewEnemy extends StatelessWidget {
  const _PreviewEnemy({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: 0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
    );
  }
}

class _PreviewPlayer extends StatelessWidget {
  const _PreviewPlayer();

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.24,
      child: Container(
        width: 34,
        height: 34,
        decoration: const BoxDecoration(
          color: FavioPalette.brandGlow,
        ),
        child: const Icon(
          Icons.navigation_rounded,
          color: Colors.white,
          size: 18,
        ),
      ),
    );
  }
}

class _SlashClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..moveTo(size.width * 0.08, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width * 0.92, size.height)
      ..lineTo(0, size.height)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _MaskPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint whitePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.94);
    final Paint blackPaint = Paint()..color = FavioPalette.background;

    final Path face = Path()
      ..moveTo(size.width * 0.22, size.height * 0.12)
      ..quadraticBezierTo(
        size.width * 0.72,
        size.height * 0.05,
        size.width * 0.80,
        size.height * 0.36,
      )
      ..quadraticBezierTo(
        size.width * 0.86,
        size.height * 0.76,
        size.width * 0.48,
        size.height * 0.92,
      )
      ..quadraticBezierTo(
        size.width * 0.12,
        size.height * 0.72,
        size.width * 0.22,
        size.height * 0.12,
      );

    canvas.drawPath(face, whitePaint);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.44, size.height * 0.44),
        width: size.width * 0.12,
        height: size.height * 0.04,
      ),
      blackPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width * 0.63, size.height * 0.41),
        width: size.width * 0.12,
        height: size.height * 0.04,
      ),
      blackPaint,
    );

    final Paint redStroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..color = FavioPalette.brandGlow;

    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.18,
        size.width * 0.56,
        size.height * 0.54,
      ),
      2.9,
      1.6,
      false,
      redStroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint redShape = Paint()..color = FavioPalette.brandShadow;
    final Paint darkShape = Paint()..color = const Color(0xFF101319);
    final Paint whiteLine = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.2;

    final Path leftSlash = Path()
      ..moveTo(0, size.height * 0.12)
      ..lineTo(size.width * 0.27, 0)
      ..lineTo(size.width * 0.14, size.height * 0.42)
      ..lineTo(0, size.height * 0.36)
      ..close();
    canvas.drawPath(leftSlash, redShape);

    final Path rightPanel = Path()
      ..moveTo(size.width * 0.72, size.height * 0.06)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.26)
      ..lineTo(size.width * 0.80, size.height * 0.32)
      ..close();
    canvas.drawPath(rightPanel, darkShape);

    for (double i = -size.height; i < size.width; i += 26) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        whiteLine,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint line = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..strokeWidth = 1.4;
    final Paint blackPanel = Paint()..color = const Color(0xAA06070A);
    final Paint redStripe = Paint()
      ..color = const Color(0xFF111111).withValues(alpha: 0.82);

    for (double y = size.height * 0.08; y < size.height; y += 28) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * 0.72, y - 12),
        line,
      );
    }

    final Path bottomMask = Path()
      ..moveTo(size.width * 0.42, size.height * 0.64)
      ..lineTo(size.width, size.height * 0.48)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width * 0.22, size.height)
      ..close();
    canvas.drawPath(bottomMask, blackPanel);

    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.06, size.height * 0.12, 8, size.height * 0.68),
      redStripe,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PreviewGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    for (double y = 0; y <= size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final Paint glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28)
      ..color = FavioPalette.brandGlow.withValues(alpha: 0.18);

    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.26),
      38,
      glow,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
