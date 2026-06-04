import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../gen_a/A.dart';
import '../env/app_env.dart';
import '../light_handle.dart';

class GoldPalette {
  static const Color background = Color(0xFFFFE9F1);
  static const Color backgroundDeep = Color(0xFFF6B8D2);
  static const Color backgroundMist = Color(0xFFFFF7E7);
  static const Color backgroundLavender = Color(0xFFF8D8F4);
  static const Color surface = Color(0xFFFFFEFD);
  static const Color surfaceSoft = Color(0xFFFFF4F8);
  static const Color surfaceRose = Color(0xFFFFE3EC);
  static const Color stroke = Color(0x26D88DB0);
  static const Color primary = Color(0xFFFF8BB3);
  static const Color primaryDeep = Color(0xFFFA6D9D);
  static const Color highlight = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF563247);
  static const Color textMuted = Color(0xFF9A7388);
  static const Color textOnGold = Color(0xFF5C2C44);
  static const Color accentTeal = Color(0xFFBFEDE3);
  static const Color accentRose = Color(0xFFFFC1D8);
  static const Color accentPeach = Color(0xFFFFD6AF);
  static const Color accentLilac = Color(0xFFE9C6FF);

  const GoldPalette._();
}

enum DifficultyLevel {
  easy(
    label: 'Easy',
    subtitle: '8 pairs',
    pairCount: 8,
    columns: 4,
    mismatchDelayMillis: 850,
  ),
  normal(
    label: 'Normal',
    subtitle: '10 pairs',
    pairCount: 10,
    columns: 4,
    mismatchDelayMillis: 700,
  ),
  hard(
    label: 'Hard',
    subtitle: '12 pairs',
    pairCount: 12,
    columns: 4,
    mismatchDelayMillis: 560,
  );

  const DifficultyLevel({
    required this.label,
    required this.subtitle,
    required this.pairCount,
    required this.columns,
    required this.mismatchDelayMillis,
  });

  final String label;
  final String subtitle;
  final int pairCount;
  final int columns;
  final int mismatchDelayMillis;
}

class _BestScore {
  const _BestScore({
    required this.moves,
    required this.seconds,
  });

  final int moves;
  final int seconds;
}

class _ScoreStore extends ChangeNotifier {
  _ScoreStore._();

  static final _ScoreStore instance = _ScoreStore._();

  final Map<DifficultyLevel, _BestScore> _bestScores =
      <DifficultyLevel, _BestScore>{};

  _BestScore? scoreFor(DifficultyLevel level) => _bestScores[level];

  List<MapEntry<DifficultyLevel, _BestScore>> get rankedScores {
    final entries = _bestScores.entries.toList();
    entries.sort((a, b) {
      final moveCompare = a.value.moves.compareTo(b.value.moves);
      if (moveCompare != 0) {
        return moveCompare;
      }
      return a.value.seconds.compareTo(b.value.seconds);
    });
    return entries;
  }

  bool recordScore({
    required DifficultyLevel level,
    required int moves,
    required int seconds,
  }) {
    final current = _bestScores[level];
    final isBetter = current == null ||
        moves < current.moves ||
        (moves == current.moves && seconds < current.seconds);

    if (!isBetter) {
      return false;
    }

    _bestScores[level] = _BestScore(
      moves: moves,
      seconds: seconds,
    );
    notifyListeners();
    return true;
  }
}

class _CoinBalanceStore extends ChangeNotifier {
  _CoinBalanceStore._();

  static final _CoinBalanceStore instance = _CoinBalanceStore._();
  static const int roundCost = 10;

  int _balance = 240;
  final Set<String> _deliveredPurchaseKeys = <String>{};

  int get balance => _balance;

  bool deliverCoins({
    required String deliveryKey,
    required int coins,
  }) {
    if (_deliveredPurchaseKeys.contains(deliveryKey)) {
      return false;
    }

    _deliveredPurchaseKeys.add(deliveryKey);
    _balance += coins;
    notifyListeners();
    return true;
  }

  bool canAfford(int coins) => _balance >= coins;

  bool spendCoins(int coins) {
    if (coins <= 0 || _balance < coins) {
      return false;
    }

    _balance -= coins;
    notifyListeners();
    return true;
  }
}

class _MemoryCardData {
  const _MemoryCardData({
    required this.code,
    required this.label,
    required this.imageSeed,
  });

  final String code;
  final String label;
  final String imageSeed;
}

class _SceneBackground extends StatelessWidget {
  const _SceneBackground({
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            GoldPalette.background,
            GoldPalette.backgroundMist,
            GoldPalette.backgroundLavender,
            GoldPalette.backgroundDeep,
          ],
          stops: <double>[0, 0.28, 0.72, 1],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: -70,
            left: -60,
            child: _BackgroundGlow(
              size: 260,
              color: Color(0x99FFFFFF),
            ),
          ),
          const Positioned(
            top: 40,
            right: -48,
            child: _BackgroundGlow(
              size: 240,
              color: Color(0x66FFC2DD),
            ),
          ),
          const Positioned(
            top: 180,
            left: -100,
            child: _BackgroundGlow(
              size: 250,
              color: Color(0x55FFD0EA),
            ),
          ),
          const Positioned(
            bottom: -20,
            right: -36,
            child: _BackgroundGlow(
              size: 220,
              color: Color(0x77FFF8EA),
            ),
          ),
          const Positioned(
            bottom: 60,
            left: -30,
            child: _BackgroundArc(
              size: 180,
              color: Color(0x30FFFFFF),
            ),
          ),
          const Positioned(
            bottom: -24,
            right: 18,
            child: _BackgroundArc(
              size: 132,
              color: Color(0x28FFFFFF),
            ),
          ),
          const Positioned(
            top: 82,
            left: 46,
            child: _BackgroundDot(
              size: 10,
              color: Color(0xAAFFFFFF),
            ),
          ),
          const Positioned(
            top: 198,
            right: 54,
            child: _BackgroundDot(
              size: 18,
              color: Color(0x66FFFFFF),
            ),
          ),
          const Positioned(
            top: 326,
            left: 36,
            child: _BackgroundDot(
              size: 7,
              color: Color(0x66FFD4E8),
            ),
          ),
          const Positioned(
            top: 400,
            right: 32,
            child: _BackgroundDot(
              size: 12,
              color: Color(0x77FFF6D8),
            ),
          ),
          const Positioned(
            bottom: 236,
            left: 56,
            child: _BackgroundDot(
              size: 8,
              color: Color(0x90FFFFFF),
            ),
          ),
          const Positioned(
            bottom: 164,
            right: 74,
            child: _BackgroundDot(
              size: 14,
              color: Color(0x55FFE5F2),
            ),
          ),
          const Positioned(
            top: 246,
            left: 78,
            child: _PrismStreak(
              width: 102,
              color: Color(0x30FFFFFF),
              angle: -0.56,
            ),
          ),
          const Positioned(
            bottom: 226,
            right: 32,
            child: _PrismStreak(
              width: 80,
              color: Color(0x2AFFD1E7),
              angle: 0.38,
            ),
          ),
          const Positioned(
            top: 120,
            right: 18,
            child: _TwinkleStar(
              size: 18,
              color: Color(0xBFFFFFFF),
            ),
          ),
          const Positioned(
            bottom: 140,
            right: 26,
            child: _TwinkleStar(
              size: 22,
              color: Color(0xAAFFFFFF),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _BackgroundGlow extends StatelessWidget {
  const _BackgroundGlow({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[
            color,
            color.withValues(alpha: color.a * 0.35),
            Colors.transparent,
          ],
          stops: const <double>[0, 0.42, 1],
        ),
      ),
    );
  }
}

class _BackgroundArc extends StatelessWidget {
  const _BackgroundArc({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: color,
          width: 1.4,
        ),
      ),
    );
  }
}

class _BackgroundDot extends StatelessWidget {
  const _BackgroundDot({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: color.withValues(alpha: color.a * 0.45),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
}

class _PrismStreak extends StatelessWidget {
  const _PrismStreak({
    required this.width,
    required this.color,
    required this.angle,
  });

  final double width;
  final Color color;
  final double angle;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: width,
        height: 14,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: LinearGradient(
            colors: <Color>[
              color.withValues(alpha: color.a * 0.15),
              color,
              color.withValues(alpha: color.a * 0.05),
            ],
          ),
        ),
      ),
    );
  }
}

class _TwinkleStar extends StatelessWidget {
  const _TwinkleStar({
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.auto_awesome,
      size: size,
      color: color,
    );
  }
}

class _GlassPanel extends StatelessWidget {
  const _GlassPanel({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.radius = 28,
    this.color = const Color(0xBFFFFCFD),
  });

  final Widget child;
  final EdgeInsets padding;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0x66FFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x24FFB3CD),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
          BoxShadow(
            color: Color(0x16FFFFFF),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _CompactArtworkFill extends StatelessWidget {
  const _CompactArtworkFill({
    this.isBack = false,
    this.letter,
  });

  final bool isBack;
  final String? letter;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            constraints.maxWidth.isFinite ? constraints.maxWidth : 80.0;
        final height =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 110.0;
        final shortest = math.min(width, height);
        final badgeSize = shortest * (isBack ? 0.3 : 0.34);
        final heartSize = shortest * (isBack ? 0.14 : 0.18);
        final labelSize = math.max(20.0, shortest * 0.24);
        final shellRadius = math.max(16.0, shortest * 0.22);
        final panelRadius = math.max(12.0, shortest * 0.18);

        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(shellRadius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isBack
                  ? const <Color>[
                      Color(0xFFFFFDFE),
                      Color(0xFFFFF6FA),
                    ]
                  : const <Color>[
                      Color(0xFFFFFCFD),
                      Color(0xFFFFEEF5),
                      Color(0xFFFFF8EC),
                    ],
            ),
            border: Border.all(
              color: isBack ? const Color(0x88FFFFFF) : const Color(0x66FFFFFF),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(shellRadius),
            child: Stack(
              fit: StackFit.expand,
              children: <Widget>[
                Positioned(
                  top: -shortest * 0.18,
                  left: -shortest * 0.16,
                  child: _BackgroundGlow(
                    size: shortest * 0.68,
                    color: isBack
                        ? const Color(0x30FFD7E8)
                        : const Color(0x48FFD7E8),
                  ),
                ),
                Positioned(
                  right: shortest * 0.14,
                  top: shortest * 0.14,
                  child: Container(
                    width: shortest * 0.12,
                    height: shortest * 0.12,
                    decoration: BoxDecoration(
                      color: const Color(0x52FFFFFF),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(shortest * 0.12),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        width: badgeSize,
                        height: badgeSize,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: isBack
                                ? const <Color>[
                                    Color(0xFFFFD4E4),
                                    Color(0xFFFFE7BB),
                                  ]
                                : const <Color>[
                                    GoldPalette.accentRose,
                                    GoldPalette.accentPeach,
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(panelRadius),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: isBack
                                  ? const Color(0x14FF9FC3)
                                  : const Color(0x24FF9FC3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Icon(
                          isBack
                              ? Icons.favorite_outline_rounded
                              : Icons.favorite_rounded,
                          size: heartSize,
                          color: GoldPalette.textOnGold,
                        ),
                      ),
                      if (!isBack && letter != null) ...<Widget>[
                        SizedBox(height: shortest * 0.11),
                        Container(
                          width: shortest * 0.46,
                          height: shortest * 0.46,
                          decoration: BoxDecoration(
                            color: const Color(0xF8FFFFFF),
                            borderRadius: BorderRadius.circular(panelRadius),
                            border: Border.all(
                              color: const Color(0x16B56688),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              letter!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: labelSize,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: GoldPalette.textOnGold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
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

class MemoryKingHomePage extends StatefulWidget {
  const MemoryKingHomePage({super.key});

  @override
  State<MemoryKingHomePage> createState() => _MemoryKingHomePageState();
}

class _MemoryKingHomePageState extends State<MemoryKingHomePage> {
  Future<void> _startGame() async {
    final selectedDifficulty = await _showDifficultyPicker();
    if (!mounted || selectedDifficulty == null) {
      return;
    }

    final didSpend = _CoinBalanceStore.instance.spendCoins(
      _CoinBalanceStore.roundCost,
    );
    if (!didSpend) {
      await _showNotEnoughCoinsDialog();
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            MemoryKingPage(initialDifficulty: selectedDifficulty),
      ),
    );
  }

  Future<DifficultyLevel?> _showDifficultyPicker() {
    return showModalBottomSheet<DifficultyLevel>(
      context: context,
      backgroundColor: GoldPalette.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Choose difficulty',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: GoldPalette.textOnGold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _CoinBalanceStore.instance,
                  builder: (context, child) {
                    return Text(
                      'Pick a pace and begin. This round costs ${_CoinBalanceStore.roundCost} coins. Balance: ${_CoinBalanceStore.instance.balance}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF856852),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                for (final level in DifficultyLevel.values) ...<Widget>[
                  _DifficultyTile(
                    level: level,
                    onTap: () => Navigator.of(context).pop(level),
                  ),
                  if (level != DifficultyLevel.values.last)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _openSettings() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _SettingsPage(),
      ),
    );
  }

  void _openLeaderboard() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _LeaderboardPage(),
      ),
    );
  }

  Future<void> _showNotEnoughCoinsDialog() async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: GoldPalette.surface,
          title: const Text(
            'Not enough coins',
            style: TextStyle(color: GoldPalette.textOnGold),
          ),
          content: const Text(
            'Starting one round costs 10 coins. Please top up your balance first.',
            style: TextStyle(color: GoldPalette.textOnGold),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Later'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (!mounted) {
                  return;
                }
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (context) => const _CoinsPage(),
                  ),
                );
              },
              child: const Text('Get coins'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SceneBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  'Kindo',
                                  style: TextStyle(
                                    fontSize: 34,
                                    fontWeight: FontWeight.w800,
                                    color: GoldPalette.textPrimary,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'A pastel climb through pairs',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: GoldPalette.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          _IconChip(
                            icon: Icons.tune_rounded,
                            onTap: _openSettings,
                          ),
                        ],
                      ),
                      AnimatedBuilder(
                        animation: _ScoreStore.instance,
                        builder: (context, child) {
                          final entries = _ScoreStore.instance.rankedScores;
                          final bestScore = entries.isEmpty
                              ? '--'
                              : entries.first.value.seconds.toString();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              const SizedBox(height: 20),
                              _HomeHero(
                                onStartGame: _startGame,
                                bestScore: bestScore,
                              ),
                              const SizedBox(height: 24),
                              _HomeQuickPanel(
                                entries: entries,
                                onOpenLeaderboard: _openLeaderboard,
                              ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
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
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreed = false;
  bool _isLoading = false;

  Future<void> _handleStart() async {
    if (!_agreed) {
      final agreed = await _showAgreementDialog();
      if (!agreed || !mounted) {
        return;
      }
      setState(() {
        _agreed = true;
      });
    }

    setState(() {
      _isLoading = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 800));
    await LightHandle.login();

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => const MemoryKingHomePage(),
      ),
    );
  }

  Future<bool> _showAgreementDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: GoldPalette.surface,
              title: const Text(
                'Agreement Required',
                style: TextStyle(color: GoldPalette.textOnGold),
              ),
              content: const Text(
                'Please agree to the Terms of Service and Privacy Policy to continue.',
                style: TextStyle(color: GoldPalette.textOnGold),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Agree'),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  void _openAgreementPage({
    required String title,
    required String url,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AgreementPage(
          title: title,
          url: url,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              A.assets_kindo_open,
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight - 42,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        const SizedBox.shrink(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            FilledButton(
                              onPressed: _isLoading ? null : _handleStart,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(56),
                                backgroundColor: const Color(0xFFF85D9D),
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: const Color(
                                  0xFFF85D9D,
                                ).withValues(alpha: 0.45),
                                disabledForegroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text(
                                      'Start',
                                      style: TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(14, 12, 14, 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.72),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0x66FFFFFF),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _agreed = !_agreed;
                                      });
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 180,
                                      ),
                                      margin: const EdgeInsets.only(top: 2),
                                      width: 18,
                                      height: 18,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: _agreed
                                            ? const Color(0xFFF85D9D)
                                            : Colors.white.withValues(
                                                alpha: 0.95,
                                              ),
                                        border: Border.all(
                                          color: _agreed
                                              ? const Color(0xFFF85D9D)
                                              : const Color(0x66D392AE),
                                          width: 1.4,
                                        ),
                                      ),
                                      child: _agreed
                                          ? const Icon(
                                              Icons.check_rounded,
                                              size: 12,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Wrap(
                                      children: <Widget>[
                                        const Text(
                                          'I agree to the ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.45,
                                            color: GoldPalette.textMuted,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _openAgreementPage(
                                            title: 'Terms of Service',
                                            url: AppEnv().h5User,
                                          ),
                                          child: const Text(
                                            'Terms of Service',
                                            style: TextStyle(
                                              fontSize: 13,
                                              height: 1.45,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  GoldPalette.textPrimary,
                                              color: GoldPalette.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          ' and ',
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.45,
                                            color: GoldPalette.textMuted,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _openAgreementPage(
                                            title: 'Privacy Policy',
                                            url: AppEnv().h5Privacy,
                                          ),
                                          child: const Text(
                                            'Privacy Policy',
                                            style: TextStyle(
                                              fontSize: 13,
                                              height: 1.45,
                                              fontWeight: FontWeight.w700,
                                              decoration:
                                                  TextDecoration.underline,
                                              decorationColor:
                                                  GoldPalette.textPrimary,
                                              color: GoldPalette.textPrimary,
                                            ),
                                          ),
                                        ),
                                        const Text(
                                          '.',
                                          style: TextStyle(
                                            fontSize: 13,
                                            height: 1.45,
                                            color: GoldPalette.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHero extends StatelessWidget {
  const _HomeHero({
    required this.onStartGame,
    required this.bestScore,
  });

  final VoidCallback onStartGame;
  final String bestScore;

  @override
  Widget build(BuildContext context) {
    return _HomeHeroArtwork(
      bestScore: bestScore,
      onStartGame: onStartGame,
    );
  }
}

class _HomeHeroArtwork extends StatelessWidget {
  const _HomeHeroArtwork({
    required this.bestScore,
    required this.onStartGame,
  });

  final String bestScore;
  final VoidCallback onStartGame;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFFF9FD),
            Color(0xFFFFECF4),
            Color(0xFFFFF7E9),
          ],
        ),
        border: Border.all(color: const Color(0x88FFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x22FF9AC0),
            blurRadius: 30,
            offset: Offset(0, 22),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width =
              constraints.maxWidth.isFinite ? constraints.maxWidth : 320.0;
          final titleSize = width < 320 ? 28.0 : 32.0;
          final illustrationWidth = width < 320 ? 122.0 : 138.0;
          final illustrationHeight = width < 320 ? 174.0 : 188.0;

          return Stack(
            children: <Widget>[
              Positioned(
                top: -12,
                right: -10,
                child: _BackgroundGlow(
                  size: width * 0.28,
                  color: const Color(0x42FFF0CF),
                ),
              ),
              Positioned(
                top: 18,
                left: -16,
                child: _BackgroundGlow(
                  size: width * 0.24,
                  color: const Color(0x34FFD5E9),
                ),
              ),
              Positioned(
                top: 26,
                right: 44,
                child: _BackgroundArc(
                  size: width * 0.14,
                  color: const Color(0x28FFFFFF),
                ),
              ),
              Positioned(
                right: 16,
                bottom: 78,
                child: _TwinkleStar(
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: GoldPalette.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'SOFT MATCH',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: GoldPalette.primaryDeep,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.auto_awesome_rounded,
                          size: 12,
                          color: GoldPalette.primaryDeep,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text(
                                  'Find the pairs,\nfeel the calm.',
                                  style: TextStyle(
                                    fontSize: titleSize,
                                    height: 1.02,
                                    fontWeight: FontWeight.w800,
                                    color: GoldPalette.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0x22FFFFFF),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        width: 22,
                                        height: 22,
                                        decoration: BoxDecoration(
                                          color: GoldPalette.surfaceRose,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.favorite_rounded,
                                          size: 12,
                                          color: GoldPalette.primaryDeep,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          const Text(
                                            'Best score',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: GoldPalette.primaryDeep,
                                            ),
                                          ),
                                          Text(
                                            bestScore,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              height: 1,
                                              fontWeight: FontWeight.w800,
                                              color: GoldPalette.textPrimary,
                                            ),
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
                        SizedBox(
                          width: illustrationWidth,
                          height: illustrationHeight,
                          child: Stack(
                            alignment: Alignment.center,
                            children: <Widget>[
                              Positioned(
                                top: 12,
                                child: Container(
                                  width: illustrationWidth * 0.7,
                                  height: illustrationWidth * 0.7,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: <Color>[
                                        Color(0x66FFFFFF),
                                        Color(0x22FFFFFF),
                                        Colors.transparent,
                                      ],
                                      stops: <double>[0, 0.55, 1],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 12,
                                top: 40,
                                child: Transform.rotate(
                                  angle: 0.34,
                                  child: Container(
                                    width: illustrationWidth * 0.54,
                                    height: illustrationHeight * 0.56,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: <Color>[
                                          Color(0xFFFFF6DC),
                                          Color(0xFFFFE6EE),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(28),
                                      boxShadow: const <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0x20FFB2CC),
                                          blurRadius: 16,
                                          offset: Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                top: 32,
                                child: Transform.rotate(
                                  angle: -0.16,
                                  child: Container(
                                    width: illustrationWidth * 0.66,
                                    height: illustrationHeight * 0.66,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: <Color>[
                                          Color(0xFFFFF8FC),
                                          Color(0xFFFFE7F0),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: const <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0x1CFFB7D0),
                                          blurRadius: 22,
                                          offset: Offset(0, 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 24,
                                top: 46,
                                child: Transform.rotate(
                                  angle: -0.12,
                                  child: SizedBox(
                                    width: illustrationWidth * 0.64,
                                    height: illustrationHeight * 0.68,
                                    child: Stack(
                                      alignment: Alignment.center,
                                      children: <Widget>[
                                        Container(
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter,
                                              colors: <Color>[
                                                Color(0xFFFFF9FD),
                                                Color(0xFFFFEAF2),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(30),
                                            border: Border.all(
                                              color: const Color(0x80FFFFFF),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 18,
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: <Color>[
                                                  GoldPalette.accentRose,
                                                  GoldPalette.accentPeach,
                                                ],
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: const Icon(
                                              Icons.favorite_rounded,
                                              size: 20,
                                              color: GoldPalette.textOnGold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 14,
                                top: 74,
                                child: SizedBox(
                                  width: illustrationWidth * 0.85,
                                  height: 58,
                                  child: CustomPaint(
                                    painter: _OrbitPainter(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 8,
                                top: 60,
                                child: _TwinkleStar(
                                  size: 12,
                                  color: GoldPalette.primaryDeep.withValues(
                                    alpha: 0.82,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onStartGame,
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(56),
                          backgroundColor: GoldPalette.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                          elevation: 0,
                        ),
                        icon: const Icon(Icons.play_arrow_rounded, size: 18),
                        label: const Text(
                          'Start a round · 10 coins',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OrbitPainter extends CustomPainter {
  const _OrbitPainter({
    required this.color,
  });

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final path = Path()
      ..moveTo(6, size.height * 0.72)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.08,
        size.width * 0.72,
        size.height * 0.96,
        size.width - 6,
        size.height * 0.3,
      );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _OrbitPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}

class _HomeQuickPanel extends StatelessWidget {
  const _HomeQuickPanel({
    required this.entries,
    required this.onOpenLeaderboard,
  });

  final List<MapEntry<DifficultyLevel, _BestScore>> entries;
  final VoidCallback onOpenLeaderboard;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      radius: 28,
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.leaderboard_rounded,
                size: 18,
                color: GoldPalette.primaryDeep,
              ),
              const SizedBox(width: 8),
              const Text(
                'Leaderboard',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: GoldPalette.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onOpenLeaderboard,
                child: const Text('See all'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (entries.isEmpty)
            const _EmptyRecordCard()
          else
            for (final entry in entries.take(3)) ...<Widget>[
              _LeaderboardMiniRow(entry: entry),
              if (entry != entries.take(3).last) const SizedBox(height: 10),
            ],
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _HomeShortcutButton(
              icon: Icons.leaderboard_rounded,
              label: 'Open leaderboard',
              onTap: onOpenLeaderboard,
            ),
          ),
        ],
      ),
    );
  }
}

class MemoryKingPage extends StatefulWidget {
  const MemoryKingPage({
    super.key,
    this.initialDifficulty = DifficultyLevel.normal,
  });

  final DifficultyLevel initialDifficulty;

  @override
  State<MemoryKingPage> createState() => _MemoryKingPageState();
}

class _MemoryKingPageState extends State<MemoryKingPage> {
  static const Duration _matchPause = Duration(milliseconds: 220);
  static const List<_MemoryCardData> _tokenPool = <_MemoryCardData>[
    _MemoryCardData(code: 'A', label: 'Blush', imageSeed: 'BLUSH'),
    _MemoryCardData(code: 'B', label: 'Bloom', imageSeed: 'BLOOM'),
    _MemoryCardData(code: 'C', label: 'Cloud', imageSeed: 'CLOUD'),
    _MemoryCardData(code: 'D', label: 'Dawn', imageSeed: 'DAWN'),
    _MemoryCardData(code: 'E', label: 'Echo', imageSeed: 'ECHO'),
    _MemoryCardData(code: 'F', label: 'Flare', imageSeed: 'FLARE'),
    _MemoryCardData(code: 'G', label: 'Glow', imageSeed: 'GLOW'),
    _MemoryCardData(code: 'H', label: 'Heart', imageSeed: 'HEART'),
    _MemoryCardData(code: 'I', label: 'Iris', imageSeed: 'IRIS'),
    _MemoryCardData(code: 'J', label: 'Jelly', imageSeed: 'JELLY'),
    _MemoryCardData(code: 'K', label: 'Kiss', imageSeed: 'KISS'),
    _MemoryCardData(code: 'L', label: 'Luma', imageSeed: 'LUMA'),
  ];

  final math.Random _random = math.Random();
  final Set<int> _revealed = <int>{};
  final Set<int> _matched = <int>{};
  final List<int> _selected = <int>[];

  late DifficultyLevel _difficulty;
  late List<_MemoryCardData> _cards;
  Timer? _timer;
  bool _isResolving = false;
  bool _didShowVictory = false;
  bool _started = false;
  int _elapsedSeconds = 0;
  int _moves = 0;

  @override
  void initState() {
    super.initState();
    _difficulty = widget.initialDifficulty;
    _cards = _buildDeck(_difficulty);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  List<_MemoryCardData> _buildDeck(DifficultyLevel difficulty) {
    final selected = List<_MemoryCardData>.of(_tokenPool)..shuffle(_random);
    final cards = <_MemoryCardData>[
      ...selected.take(difficulty.pairCount),
      ...selected.take(difficulty.pairCount),
    ];
    cards.shuffle(_random);
    return cards;
  }

  void _startTimerIfNeeded() {
    if (_started) {
      return;
    }
    _started = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _elapsedSeconds += 1;
      });
    });
  }

  Future<void> _openDifficultyPicker() async {
    final selectedDifficulty = await showModalBottomSheet<DifficultyLevel>(
      context: context,
      backgroundColor: GoldPalette.surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Choose difficulty',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: GoldPalette.textOnGold,
                  ),
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _CoinBalanceStore.instance,
                  builder: (context, child) {
                    return Text(
                      'Restart with a new layout. Starting a round costs ${_CoinBalanceStore.roundCost} coins. Balance: ${_CoinBalanceStore.instance.balance}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF856852),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                for (final level in DifficultyLevel.values) ...<Widget>[
                  _DifficultyTile(
                    level: level,
                    onTap: () => Navigator.of(context).pop(level),
                    isSelected: level == _difficulty,
                  ),
                  if (level != DifficultyLevel.values.last)
                    const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        );
      },
    );

    if (!mounted ||
        selectedDifficulty == null ||
        selectedDifficulty == _difficulty) {
      return;
    }

    _restart(difficulty: selectedDifficulty);
  }

  void _restart({DifficultyLevel? difficulty}) {
    _timer?.cancel();
    final nextDifficulty = difficulty ?? _difficulty;
    setState(() {
      _difficulty = nextDifficulty;
      _cards = _buildDeck(nextDifficulty);
      _revealed.clear();
      _matched.clear();
      _selected.clear();
      _isResolving = false;
      _didShowVictory = false;
      _started = false;
      _elapsedSeconds = 0;
      _moves = 0;
    });
  }

  Future<void> _onCardTap(int index) async {
    if (_isResolving ||
        _revealed.contains(index) ||
        _matched.contains(index) ||
        _selected.length >= 2) {
      return;
    }

    _startTimerIfNeeded();

    setState(() {
      _revealed.add(index);
      _selected.add(index);
    });

    if (_selected.length < 2) {
      return;
    }

    final first = _selected[0];
    final second = _selected[1];
    final isMatch = _cards[first].code == _cards[second].code;

    setState(() {
      _isResolving = true;
      _moves += 1;
    });

    if (isMatch) {
      await Future<void>.delayed(_matchPause);
      if (!mounted) {
        return;
      }
      setState(() {
        _matched.addAll(_selected);
        _selected.clear();
        _isResolving = false;
      });
      _checkForVictory();
      return;
    }

    await Future<void>.delayed(
      Duration(milliseconds: _difficulty.mismatchDelayMillis),
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _revealed.removeAll(_selected);
      _selected.clear();
      _isResolving = false;
    });
  }

  void _checkForVictory() {
    if (_matched.length != _cards.length || _didShowVictory) {
      return;
    }

    _timer?.cancel();
    _didShowVictory = true;

    final isBest = _ScoreStore.instance.recordScore(
      level: _difficulty,
      moves: _moves,
      seconds: _elapsedSeconds,
    );
    final pageContext = context;

    showDialog<void>(
      context: pageContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: GoldPalette.surface,
          title: Text(
            isBest ? 'New best' : 'Maze clear',
            style: const TextStyle(color: GoldPalette.textOnGold),
          ),
          content: Text(
            'Moves: $_moves\nTime: ${_formatDuration(_elapsedSeconds)}',
            style: const TextStyle(color: GoldPalette.textOnGold),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                if (!mounted) {
                  return;
                }
                Navigator.of(pageContext).maybePop();
              },
              child: const Text('Close'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _restart();
              },
              child: const Text('Again'),
            ),
          ],
        );
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remain.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SceneBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              children: <Widget>[
                _GameTopBar(
                  difficultyLabel: _difficulty.label,
                  movesLabel: '$_moves',
                  timeLabel: _formatDuration(_elapsedSeconds),
                  onBack: () => Navigator.of(context).maybePop(),
                  onDifficulty: _openDifficultyPicker,
                  onRestart: _restart,
                ),
                const SizedBox(height: 18),
                const SizedBox(height: 6),
                Expanded(
                  child: _GlassPanel(
                    padding: const EdgeInsets.all(14),
                    radius: 32,
                    color: const Color(0xADFFFFFF),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = _difficulty.columns;
                        final cardWidth =
                            (constraints.maxWidth - ((columns - 1) * 12)) /
                                columns;
                        final desiredHeight = math.max(
                          columns >= 5 ? cardWidth * 1.42 : cardWidth * 1.34,
                          96.0,
                        );

                        return GridView.builder(
                          physics: const BouncingScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: cardWidth / desiredHeight,
                          ),
                          itemCount: _cards.length,
                          itemBuilder: (context, index) {
                            return _MemoryCardView(
                              card: _cards[index],
                              isVisible: _revealed.contains(index) ||
                                  _matched.contains(index),
                              isMatched: _matched.contains(index),
                              onTap: () => _onCardTap(index),
                            );
                          },
                        );
                      },
                    ),
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

class _DifficultyTile extends StatelessWidget {
  const _DifficultyTile({
    required this.level,
    required this.onTap,
    this.isSelected = false,
  });

  final DifficultyLevel level;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color:
                isSelected ? const Color(0x22F4A95D) : const Color(0x12FFFFFF),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isSelected ? GoldPalette.primary : GoldPalette.stroke,
            ),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 60),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0x14FFFFFF),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.grid_view_rounded,
                    color: GoldPalette.primaryDeep,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        level.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: GoldPalette.textOnGold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF856852),
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected) ...<Widget>[
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.check_circle_rounded,
                    color: GoldPalette.primaryDeep,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GameTopBar extends StatelessWidget {
  const _GameTopBar({
    required this.difficultyLabel,
    required this.movesLabel,
    required this.timeLabel,
    required this.onBack,
    required this.onDifficulty,
    required this.onRestart,
  });

  final String difficultyLabel;
  final String movesLabel;
  final String timeLabel;
  final VoidCallback onBack;
  final VoidCallback onDifficulty;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            _IconChip(
              icon: Icons.arrow_back_rounded,
              onTap: onBack,
            ),
            const Spacer(),
            _LabelChip(
              icon: Icons.grid_view_rounded,
              label: difficultyLabel,
              onTap: onDifficulty,
            ),
            const SizedBox(width: 10),
            _IconChip(
              icon: Icons.refresh_rounded,
              onTap: onRestart,
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: _MetricCard(
                label: 'Moves',
                value: movesLabel,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                label: 'Time',
                value: timeLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return _GlassPanel(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      radius: 22,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: GoldPalette.textMuted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: GoldPalette.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconChip extends StatelessWidget {
  const _IconChip({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x18FFAAC4),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: GoldPalette.primaryDeep,
          ),
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  const _LabelChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x66FFFFFF)),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: Color(0x18FFAAC4),
                blurRadius: 16,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 16, color: GoldPalette.primaryDeep),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GoldPalette.textOnGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemoryCardView extends StatelessWidget {
  const _MemoryCardView({
    required this.card,
    required this.isVisible,
    required this.isMatched,
    required this.onTap,
  });

  final _MemoryCardData card;
  final bool isVisible;
  final bool isMatched;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final showFront = isVisible;
    final Color frontColor =
        isMatched ? GoldPalette.surfaceRose : GoldPalette.surface;
    const Color backColor = Color(0xAAFFFFFF);
    final Color frontBorderColor = isMatched
        ? GoldPalette.accentRose.withValues(alpha: 0.9)
        : Colors.white.withValues(alpha: 0.8);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(end: showFront ? 1 : 0),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeInOutCubic,
          builder: (context, value, child) {
            final angle = value * math.pi;
            final isFrontFace = angle >= math.pi / 2;

            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0014)
                ..rotateY(angle),
              child: isFrontFace
                  ? Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(math.pi),
                      child: _MemoryCardFace(
                        color: frontColor,
                        borderColor: frontBorderColor,
                        child: Stack(
                          fit: StackFit.expand,
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: _CompactArtworkFill(
                                letter: card.code,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _MemoryCardFace(
                      color: backColor,
                      borderColor: Colors.white.withValues(alpha: 0.7),
                      child: const Stack(
                        fit: StackFit.expand,
                        children: <Widget>[
                          Positioned.fill(
                            child: Padding(
                              padding: EdgeInsets.all(8),
                              child: _CompactArtworkFill(
                                isBack: true,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }
}

class _MemoryCardFace extends StatelessWidget {
  const _MemoryCardFace({
    required this.color,
    required this.borderColor,
    required this.child,
  });

  final Color color;
  final Color borderColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x18FFAAC4),
            blurRadius: 22,
            offset: Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(21),
        child: Center(child: child),
      ),
    );
  }
}

class _LeaderboardMiniRow extends StatelessWidget {
  const _LeaderboardMiniRow({
    required this.entry,
  });

  final MapEntry<DifficultyLevel, _BestScore> entry;

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remain.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _difficultyTone(entry.key),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.key.label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: GoldPalette.textOnGold,
              ),
            ),
          ),
          Text(
            '${entry.value.moves} taps',
            style: const TextStyle(
              fontSize: 12,
              color: GoldPalette.textMuted,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _formatDuration(entry.value.seconds),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: GoldPalette.highlight,
            ),
          ),
        ],
      ),
    );
  }

  Color _difficultyTone(DifficultyLevel level) {
    switch (level) {
      case DifficultyLevel.easy:
        return GoldPalette.accentTeal;
      case DifficultyLevel.normal:
        return GoldPalette.primary;
      case DifficultyLevel.hard:
        return GoldPalette.accentRose;
    }
  }
}

class _EmptyRecordCard extends StatelessWidget {
  const _EmptyRecordCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: <Widget>[
          Icon(
            Icons.auto_awesome_rounded,
            color: GoldPalette.primaryDeep,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Play one round to create your first pastel record card.',
              style: TextStyle(
                fontSize: 13,
                color: GoldPalette.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeShortcutButton extends StatelessWidget {
  const _HomeShortcutButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0x66FFFFFF)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: GoldPalette.primaryDeep),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: GoldPalette.textOnGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LeaderboardPage extends StatelessWidget {
  const _LeaderboardPage();

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remain = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remain.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SceneBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _IconChip(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Leaderboard',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: GoldPalette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: AnimatedBuilder(
                    animation: _ScoreStore.instance,
                    builder: (context, child) {
                      final entries = _ScoreStore.instance.rankedScores;
                      if (entries.isEmpty) {
                        return const Center(
                          child: Text(
                            'No personal records yet',
                            style: TextStyle(
                              fontSize: 15,
                              color: GoldPalette.textMuted,
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: entries.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _GlassPanel(
                            padding: const EdgeInsets.all(16),
                            radius: 26,
                            child: Row(
                              children: <Widget>[
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: _rankTone(index)
                                        .withValues(alpha: 0.35),
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: GoldPalette.textOnGold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text(
                                        entry.key.label,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                          color: GoldPalette.textOnGold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${entry.value.moves} taps',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: GoldPalette.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  _formatDuration(entry.value.seconds),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: GoldPalette.highlight,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _rankTone(int index) {
    switch (index) {
      case 0:
        return GoldPalette.primary;
      case 1:
        return GoldPalette.accentTeal;
      default:
        return GoldPalette.accentRose;
    }
  }
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  void _openFeedback(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _FeedbackPage(),
      ),
    );
  }

  void _openCoins(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const _CoinsPage(),
      ),
    );
  }

  void _openAgreement(
    BuildContext context, {
    required String title,
    required String url,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => _AgreementPage(title: title, url: url),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GoldPalette.surface,
          title: const Text(
            'Log out',
            style: TextStyle(color: GoldPalette.textOnGold),
          ),
          content: const Text(
            'Do you want to log out of your account now?',
            style: TextStyle(color: GoldPalette.textOnGold),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Log out'),
            ),
          ],
        );
      },
    );

    if (shouldLogout != true) {
      return;
    }

    await LightHandle.logout();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully.')),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: GoldPalette.surface,
          title: const Text(
            'Delete account',
            style: TextStyle(color: GoldPalette.textOnGold),
          ),
          content: const Text(
            'This will clear your local account data. Continue?',
            style: TextStyle(color: GoldPalette.textOnGold),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC85B52),
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    await LightHandle.deleteAccount();
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Account data deleted.')),
    );
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (context) => const LoginPage(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final env = AppEnv();
    final termsUrl = env.h5User;
    final privacyUrl = env.h5Privacy;

    return Scaffold(
      body: _SceneBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    _IconChip(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: GoldPalette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: _GlassPanel(
                    padding: EdgeInsets.zero,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 150),
                      child: Column(
                        children: <Widget>[
                          _SettingsTile(
                            icon: Icons.feedback_outlined,
                            title: 'Feedback',
                            onTap: () => _openFeedback(context),
                          ),
                          const SizedBox(height: 12),
                          _SettingsTile(
                            icon: Icons.monetization_on_outlined,
                            title: 'Coins',
                            subtitle: 'Check your balance and offers',
                            onTap: () => _openCoins(context),
                          ),
                          const SizedBox(height: 12),
                          _SettingsTile(
                            icon: Icons.description_outlined,
                            title: 'Terms of Service',
                            onTap: termsUrl.isEmpty
                                ? null
                                : () => _openAgreement(
                                      context,
                                      title: 'Terms of Service',
                                      url: termsUrl,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          _SettingsTile(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Privacy Policy',
                            onTap: privacyUrl.isEmpty
                                ? null
                                : () => _openAgreement(
                                      context,
                                      title: 'Privacy Policy',
                                      url: privacyUrl,
                                    ),
                          ),
                          const SizedBox(height: 12),
                          _SettingsTile(
                            icon: Icons.logout_rounded,
                            title: 'Log out',
                            onTap: () => _confirmLogout(context),
                          ),
                          const SizedBox(height: 12),
                          _SettingsTile(
                            icon: Icons.person_remove_outlined,
                            title: 'Delete account',
                            isDestructive: true,
                            onTap: () => _confirmDeleteAccount(context),
                          ),
                        ],
                      ),
                    ),
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

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final accentColor =
        isDestructive ? const Color(0xFFC85B52) : GoldPalette.primaryDeep;
    final titleColor =
        isDestructive ? const Color(0xFFB6463E) : GoldPalette.textOnGold;
    final chevronColor =
        isDestructive ? const Color(0xFFC85B52) : GoldPalette.textMuted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.58),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDestructive
                  ? const Color(0x55E48D86)
                  : const Color(0x66FFFFFF),
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDestructive
                      ? const Color(0xFFFFEEE9)
                      : Colors.white.withValues(alpha: 0.68),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          color: isDestructive
                              ? titleColor.withValues(alpha: 0.76)
                              : GoldPalette.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: onTap == null
                    ? chevronColor.withValues(alpha: 0.45)
                    : chevronColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CoinsPage extends StatefulWidget {
  const _CoinsPage();

  @override
  State<_CoinsPage> createState() => _CoinsPageState();
}

class _CoinsPageState extends State<_CoinsPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  static const List<_CoinOffer> _offers = <_CoinOffer>[
    _CoinOffer(
      productId: 'kindo.sa06',
      title: 'Kindo Value Pack6',
      note: 'Hot Sale: 299 coins',
      price: '\$0.99',
      coins: 299,
      type: '促销',
      originalPrice: '\$2.99',
      parentCode: '100009907',
      tint: GoldPalette.accentPeach,
    ),
    _CoinOffer(
      productId: 'kindo.sa07',
      title: 'Kindo Value Pack7',
      note: 'Hot Sale: 749 coins',
      price: '\$2.99',
      coins: 749,
      type: '促销',
      originalPrice: '\$6.99',
      parentCode: '100029901',
      tint: GoldPalette.accentRose,
    ),
    _CoinOffer(
      productId: 'kindo.sa08',
      title: 'Kindo Value Pack8',
      note: 'Hot Sale: 1200 coins',
      price: '\$4.99',
      coins: 1200,
      type: '促销',
      originalPrice: '\$9.99',
      parentCode: '100049905',
      tint: GoldPalette.accentLilac,
    ),
    _CoinOffer(
      productId: 'kindo.sa09',
      title: 'Kindo Value Pack9',
      note: 'Hot Sale: 2498 coins',
      price: '\$11.99',
      coins: 2498,
      type: '促销',
      originalPrice: '\$19.99',
      parentCode: '100119903',
      tint: GoldPalette.accentTeal,
    ),
    _CoinOffer(
      productId: 'kindo.sa10',
      title: 'Kindo Value Pack10',
      note: 'Hot Sale: 7000 coins',
      price: '\$34.99',
      coins: 7000,
      type: '促销',
      originalPrice: '\$49.99',
      parentCode: '100349905',
      tint: GoldPalette.accentPeach,
    ),
    _CoinOffer(
      productId: 'kindo.sa11',
      title: 'Kindo Value Pack11',
      note: 'Hot Sale: 14888 coins',
      price: '\$79.99',
      coins: 14888,
      type: '促销',
      originalPrice: '\$99.99',
      parentCode: '100799906',
      tint: GoldPalette.accentRose,
    ),
    _CoinOffer(
      productId: 'kindo.sa00',
      title: 'Kindo Value Pack0',
      note: 'Regular: 99 coins',
      price: '\$0.99',
      coins: 99,
      type: '常规',
      parentCode: '100009900',
      tint: GoldPalette.accentLilac,
    ),
    _CoinOffer(
      productId: 'kindo.sa01',
      title: 'Kindo Value Pack1',
      note: 'Regular: 500 coins',
      price: '\$4.99',
      coins: 500,
      type: '常规',
      parentCode: '100049902',
      tint: GoldPalette.accentTeal,
    ),
    _CoinOffer(
      productId: 'kindo.sa02',
      title: 'Kindo Value Pack2',
      note: 'Regular: 1000 coins',
      price: '\$9.99',
      coins: 1000,
      type: '常规',
      parentCode: '100099904',
      tint: GoldPalette.accentPeach,
    ),
    _CoinOffer(
      productId: 'kindo.sa03',
      title: 'Kindo Value Pack3',
      note: 'Regular: 2500 coins',
      price: '\$19.99',
      coins: 2500,
      type: '常规',
      parentCode: '100199902',
      tint: GoldPalette.accentRose,
    ),
    _CoinOffer(
      productId: 'kindo.sa04',
      title: 'Kindo Value Pack4',
      note: 'Regular: 7000 coins',
      price: '\$49.99',
      coins: 7000,
      type: '常规',
      parentCode: '100499907',
      tint: GoldPalette.accentLilac,
    ),
    _CoinOffer(
      productId: 'kindo.sa05',
      title: 'Kindo Value Pack5',
      note: 'Regular: 15000 coins',
      price: '\$99.99',
      coins: 15000,
      type: '常规',
      parentCode: '100999910',
      tint: GoldPalette.accentTeal,
    ),
    _CoinOffer(
      productId: 'kindo.sa12',
      title: 'Kindo Value Pack12',
      note: 'Regular',
      price: '\$3.99',
      coins: 400,
      type: '常规',
      parentCode: '280012',
      tint: GoldPalette.accentPeach,
    ),
    _CoinOffer(
      productId: 'kindo.sa13',
      title: 'Kindo Value Pack13',
      note: 'Regular',
      price: '\$6.99',
      coins: 700,
      type: '常规',
      parentCode: '270013',
      tint: GoldPalette.accentRose,
    ),
  ];

  bool _storeAvailable = false;
  bool _isLoadingStore = true;
  bool _purchasePending = false;
  String? _storeError;
  Set<String> _notFoundProductIds = <String>{};
  final Map<String, ProductDetails> _productsById = <String, ProductDetails>{};

  @override
  void initState() {
    super.initState();
    _purchaseSubscription = _inAppPurchase.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) {
        if (!mounted) {
          return;
        }
        setState(() {
          _purchasePending = false;
        });
        _showMessage(context, 'Purchase updates are unavailable right now.');
      },
    );
    _initStore();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }

  Set<String> get _allProductIds =>
      _offers.map((offer) => offer.productId).toSet();

  Map<String, _CoinOffer> get _offerByProductId => <String, _CoinOffer>{
        for (final offer in _offers) offer.productId: offer,
      };

  void _showMessage(BuildContext context, String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _initStore() async {
    if (mounted) {
      setState(() {
        _isLoadingStore = true;
        _storeError = null;
      });
    }

    try {
      final available = await _inAppPurchase.isAvailable();
      if (!mounted) {
        return;
      }

      if (!available) {
        setState(() {
          _storeAvailable = false;
          _isLoadingStore = false;
          _storeError = 'The App Store is unavailable right now.';
          _productsById.clear();
          _notFoundProductIds = <String>{};
        });
        return;
      }

      final response = await _inAppPurchase.queryProductDetails(_allProductIds);
      if (!mounted) {
        return;
      }

      if (response.error != null) {
        setState(() {
          _storeAvailable = true;
          _isLoadingStore = false;
          _storeError = response.error!.message;
          _productsById.clear();
          _notFoundProductIds = response.notFoundIDs.toSet();
        });
        return;
      }

      final nextProducts = <String, ProductDetails>{
        for (final product in response.productDetails) product.id: product,
      };

      setState(() {
        _storeAvailable = true;
        _isLoadingStore = false;
        _storeError = null;
        _productsById
          ..clear()
          ..addAll(nextProducts);
        _notFoundProductIds = response.notFoundIDs.toSet();
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _storeAvailable = false;
        _isLoadingStore = false;
        _storeError = 'Unable to load App Store products right now.';
        _productsById.clear();
        _notFoundProductIds = <String>{};
      });
    }
  }

  Future<void> _buyOffer(_CoinOffer offer) async {
    if (_isLoadingStore) {
      _showMessage(
          context, 'Still loading App Store products. Please try again.');
      return;
    }

    if (!_storeAvailable) {
      _showMessage(context, 'The App Store is unavailable right now.');
      return;
    }

    final product = _productsById[offer.productId];
    if (product == null) {
      _showMessage(
        context,
        'This product is not available in App Store Connect yet.',
      );
      return;
    }

    final didLaunch = await _inAppPurchase.buyConsumable(
      purchaseParam: PurchaseParam(productDetails: product),
      autoConsume: true,
    );

    if (!mounted) {
      return;
    }

    if (!didLaunch) {
      _showMessage(context, 'Unable to start the purchase right now.');
      return;
    }

    setState(() {
      _purchasePending = true;
    });
  }

  Future<void> _handlePurchaseUpdates(
    List<PurchaseDetails> purchaseDetailsList,
  ) async {
    for (final purchaseDetails in purchaseDetailsList) {
      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          if (mounted) {
            setState(() {
              _purchasePending = true;
            });
          }
          break;
        case PurchaseStatus.error:
          if (mounted) {
            setState(() {
              _purchasePending = false;
            });
            _showMessage(
              context,
              purchaseDetails.error?.message ??
                  'Purchase failed. Please try again.',
            );
          }
          break;
        case PurchaseStatus.canceled:
          if (mounted) {
            setState(() {
              _purchasePending = false;
            });
            // _showMessage(context, 'Purchase canceled.');
          }
          break;
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          final isValid = await _verifyPurchase(purchaseDetails);
          if (!isValid) {
            _handleInvalidPurchase(purchaseDetails);
            break;
          }
          await _deliverPurchase(purchaseDetails);
          break;
      }

      if (purchaseDetails.pendingCompletePurchase &&
          purchaseDetails.status != PurchaseStatus.pending) {
        await _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // TODO: Move to server-side receipt verification for production.
    return purchaseDetails.productID.isNotEmpty;
  }

  void _handleInvalidPurchase(PurchaseDetails purchaseDetails) {
    if (!mounted) {
      return;
    }
    setState(() {
      _purchasePending = false;
    });
    _showMessage(
      context,
      'Purchase verification failed for ${purchaseDetails.productID}.',
    );
  }

  Future<void> _deliverPurchase(PurchaseDetails purchaseDetails) async {
    final offer = _offerByProductId[purchaseDetails.productID];
    if (!mounted) {
      return;
    }

    if (offer == null) {
      setState(() {
        _purchasePending = false;
      });
      _showMessage(
        context,
        'Purchased product ${purchaseDetails.productID} is not configured.',
      );
      return;
    }

    final deliveryKey = purchaseDetails.purchaseID ??
        '${purchaseDetails.productID}:${purchaseDetails.transactionDate ?? ''}';
    _CoinBalanceStore.instance.deliverCoins(
      deliveryKey: deliveryKey,
      coins: offer.coins,
    );

    setState(() {
      _purchasePending = false;
    });

    // _showMessage(context, '${offer.coins} coins added to your balance.');
  }

  Widget _buildStoreBanner() {
    if (_isLoadingStore) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.54),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Row(
          children: <Widget>[
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Loading App Store products...',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: GoldPalette.textMuted,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_storeError == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F4),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x33FF9CBF)),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: GoldPalette.primaryDeep,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _storeError!,
              style: const TextStyle(
                fontSize: 13,
                color: GoldPalette.textMuted,
              ),
            ),
          ),
          TextButton(
            onPressed: _initStore,
            child: const Text('Reload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_CoinOffer> saleOffers = _offers
        .where((_CoinOffer offer) => offer.isPromotional)
        .toList(growable: false);
    final List<_CoinOffer> regularOffers = _offers
        .where((_CoinOffer offer) => !offer.isPromotional)
        .toList(growable: false);

    return Scaffold(
      body: _SceneBackground(
        child: Stack(
          children: <Widget>[
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 150),
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      _IconChip(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Navigator.of(context).maybePop(),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Text(
                          'Coins',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: GoldPalette.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: _CoinBalanceStore.instance,
                    builder: (context, child) {
                      final String statusText;
                      if (_isLoadingStore) {
                        statusText = 'Connecting to App Store...';
                      } else if (_purchasePending) {
                        statusText = 'Purchase in progress...';
                      } else if (_storeAvailable) {
                        statusText = 'Available now';
                      } else {
                        statusText = 'App Store unavailable';
                      }

                      return _CoinsBalanceCard(
                        balance: _CoinBalanceStore.instance.balance,
                        statusText: statusText,
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _GlassPanel(
                    padding: const EdgeInsets.all(18),
                    child: LayoutBuilder(
                      builder:
                          (BuildContext context, BoxConstraints constraints) {
                        final bool useTwoColumns = constraints.maxWidth >= 560;
                        final double cardWidth = useTwoColumns
                            ? (constraints.maxWidth - 12) / 2
                            : constraints.maxWidth;

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            const Text(
                              'Coin offers',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: GoldPalette.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildStoreBanner(),
                            const Text(
                              'Regular Packs',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: GoldPalette.textMuted,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: regularOffers
                                  .map(
                                    (_CoinOffer offer) => SizedBox(
                                      width: cardWidth,
                                      child: _CoinOfferCard(
                                        offer: offer,
                                        productDetails:
                                            _productsById[offer.productId],
                                        isPurchaseEnabled: !_purchasePending &&
                                            _storeAvailable &&
                                            _productsById.containsKey(
                                              offer.productId,
                                            ) &&
                                            !_notFoundProductIds.contains(
                                              offer.productId,
                                            ),
                                        onPressed: () => _buyOffer(offer),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 18),
                            const Text(
                              'Hot Sale',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                                color: GoldPalette.primaryDeep,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: saleOffers
                                  .map(
                                    (_CoinOffer offer) => SizedBox(
                                      width: cardWidth,
                                      child: _CoinOfferCard(
                                        offer: offer,
                                        productDetails:
                                            _productsById[offer.productId],
                                        isPurchaseEnabled: !_purchasePending &&
                                            _storeAvailable &&
                                            _productsById.containsKey(
                                              offer.productId,
                                            ) &&
                                            !_notFoundProductIds.contains(
                                              offer.productId,
                                            ),
                                        onPressed: () => _buyOffer(offer),
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            if (_purchasePending)
              const Positioned.fill(
                child: Stack(
                  children: <Widget>[
                    Opacity(
                      opacity: 0.18,
                      child: ModalBarrier(
                        dismissible: false,
                        color: Colors.black,
                      ),
                    ),
                    Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _CoinOffer {
  const _CoinOffer({
    required this.productId,
    required this.title,
    required this.coins,
    required this.price,
    required this.note,
    required this.type,
    this.originalPrice,
    required this.parentCode,
    required this.tint,
  });

  final String productId;
  final String title;
  final int coins;
  final String price;
  final String note;
  final String type;
  final String? originalPrice;
  final String parentCode;
  final Color tint;

  bool get isPromotional => type == '促销';

  String get typeLabel => isPromotional ? 'Hot Sale' : 'Regular';
}

class _CoinsBalanceCard extends StatelessWidget {
  const _CoinsBalanceCard({
    required this.balance,
    required this.statusText,
  });

  final int balance;
  final String statusText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFFFFFEFD),
            Color(0xFFFFF3F8),
            Color(0xFFFFF6E9),
          ],
        ),
        border: Border.all(color: const Color(0x88FFFFFF)),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x20FFAAC6),
            blurRadius: 28,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            top: -10,
            right: -4,
            child: _BackgroundGlow(
              size: 160,
              color: Color(0x55FFF0B8),
            ),
          ),
          const Positioned(
            bottom: -18,
            left: -20,
            child: _BackgroundArc(
              size: 132,
              color: Color(0x22FFFFFF),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      Color(0xFFFFF5B7),
                      Color(0xFFFFD88B),
                    ],
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Color(0x30FFD98D),
                      blurRadius: 22,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: Color(0xFF8F5A17),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Current balance',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: GoldPalette.textMuted,
                ),
              ),
              const SizedBox(height: 8),
              RichText(
                text: TextSpan(
                  children: <InlineSpan>[
                    TextSpan(
                      text: '$balance',
                      style: const TextStyle(
                        fontSize: 42,
                        height: 1,
                        fontWeight: FontWeight.w800,
                        color: GoldPalette.textPrimary,
                      ),
                    ),
                    const TextSpan(
                      text: ' coins',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GoldPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                statusText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: GoldPalette.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CoinOfferCard extends StatelessWidget {
  const _CoinOfferCard({
    required this.offer,
    required this.isPurchaseEnabled,
    required this.onPressed,
    this.productDetails,
  });

  final _CoinOffer offer;
  final ProductDetails? productDetails;
  final bool isPurchaseEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final String displayPrice = offer.price;
    final String buttonLabel =
        productDetails == null ? 'Unavailable' : 'Buy now';

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: offer.isPromotional ? 0.88 : 0.76,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: offer.isPromotional
              ? GoldPalette.primary.withValues(alpha: 0.22)
              : GoldPalette.stroke,
          width: 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x10E8A1BF),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (offer.isPromotional) ...<Widget>[
            Row(
              children: <Widget>[
                Text(
                  offer.typeLabel.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.7,
                    color: GoldPalette.primaryDeep,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          RichText(
            text: TextSpan(
              children: <InlineSpan>[
                TextSpan(
                  text: '${offer.coins}',
                  style: const TextStyle(
                    fontSize: 34,
                    height: 1,
                    fontWeight: FontWeight.w800,
                    color: GoldPalette.textPrimary,
                  ),
                ),
                const TextSpan(
                  text: ' coins',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: GoldPalette.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                displayPrice,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: GoldPalette.textPrimary,
                ),
              ),
              if (offer.originalPrice != null) ...<Widget>[
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    offer.originalPrice!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.lineThrough,
                      decorationColor: GoldPalette.textMuted.withValues(
                        alpha: 0.95,
                      ),
                      color: GoldPalette.textMuted.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: isPurchaseEnabled ? onPressed : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: offer.isPromotional
                    ? GoldPalette.primaryDeep
                    : GoldPalette.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                buttonLabel,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedbackPage extends StatefulWidget {
  const _FeedbackPage();

  @override
  State<_FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<_FeedbackPage> {
  final TextEditingController _controller = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  SpeechToText? _speechToText;
  final List<String> _bugImagePaths = <String>[];
  bool _isListening = false;
  bool _isInitializingSpeech = false;

  @override
  void dispose() {
    _speechToText?.stop();
    _controller.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _toggleSpeechInput() async {
    if (_isListening) {
      await _speechToText?.stop();
      if (!mounted) {
        return;
      }
      setState(() {
        _isListening = false;
      });
      return;
    }

    if (_isInitializingSpeech) {
      return;
    }

    _isInitializingSpeech = true;
    try {
      final speech = _speechToText ?? SpeechToText();
      if (_speechToText == null) {
        final isReady = await speech.initialize(
          onStatus: (status) {
            if (!mounted) {
              return;
            }
            if (status == 'done' ||
                status == 'notListening' ||
                status == 'not listening') {
              setState(() {
                _isListening = false;
              });
            }
          },
          onError: (error) {
            if (!mounted) {
              return;
            }
            setState(() {
              _isListening = false;
            });
            _showMessage(
              error.permanent
                  ? 'Speech permission was denied.'
                  : 'Speech recognition is unavailable right now.',
            );
          },
        );
        if (!isReady) {
          _showMessage('Speech recognition permission was denied.');
          return;
        }
        _speechToText = speech;
      }

      // `speech_to_text` 6.6.x still uses the legacy named params here.
      // ignore: deprecated_member_use
      await speech.listen(
        onResult: (result) {
          if (!mounted) {
            return;
          }
          setState(() {
            _controller.text = result.recognizedWords;
            _controller.selection = TextSelection.collapsed(
              offset: _controller.text.length,
            );
          });
        },
        // ignore: deprecated_member_use
        listenMode: ListenMode.dictation,
        // ignore: deprecated_member_use
        partialResults: true,
      );

      if (!mounted) {
        return;
      }

      final didStart = speech.isListening;
      if (!didStart) {
        _showMessage('Unable to start voice input. Please try again.');
        return;
      }

      setState(() {
        _isListening = true;
      });
    } finally {
      _isInitializingSpeech = false;
    }
  }

  Future<void> _pickBugImages({bool replace = false}) async {
    try {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 88,
      );
      if (images.isEmpty || !mounted) {
        return;
      }

      final nextPaths = images
          .map((image) => image.path)
          .where((path) => path.isNotEmpty)
          .toList();
      if (nextPaths.isEmpty) {
        return;
      }

      setState(() {
        if (replace) {
          _bugImagePaths
            ..clear()
            ..addAll(nextPaths);
          return;
        }

        for (final path in nextPaths) {
          if (!_bugImagePaths.contains(path)) {
            _bugImagePaths.add(path);
          }
        }
      });
    } catch (_) {
      _showMessage('Unable to open photo library right now.');
    }
  }

  void _removeBugImageAt(int index) {
    if (index < 0 || index >= _bugImagePaths.length) {
      return;
    }
    setState(() {
      _bugImagePaths.removeAt(index);
    });
  }

  void _submit() {
    if (_controller.text.trim().isEmpty && _bugImagePaths.isEmpty) {
      _showMessage('Please add feedback text or a bug screenshot first.');
      return;
    }

    _showMessage(
      _bugImagePaths.isEmpty
          ? 'Feedback submitted. Thank you!'
          : 'Bug report submitted with screenshots. Thank you!',
    );
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _SceneBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 150),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: <Widget>[
              Row(
                children: <Widget>[
                  _IconChip(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Feedback',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: GoldPalette.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),
              _BugUploadCard(
                imagePaths: _bugImagePaths,
                onAdd: _pickBugImages,
                onRemoveAt: _removeBugImageAt,
              ),
              const SizedBox(height: 18),
              _GlassPanel(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Text(
                      'Describe the issue and attach a screenshot if needed.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GoldPalette.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: _controller,
                      maxLines: 8,
                      textInputAction: TextInputAction.done,
                      cursorColor: GoldPalette.primary,
                      style: const TextStyle(color: GoldPalette.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Share your ideas or issues here...',
                        hintStyle:
                            const TextStyle(color: GoldPalette.textMuted),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.7),
                        contentPadding: const EdgeInsets.fromLTRB(
                          16,
                          16,
                          72,
                          58,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: GoldPalette.stroke),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide:
                              const BorderSide(color: GoldPalette.stroke),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: GoldPalette.primary,
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: const Offset(-10, -56),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isInitializingSpeech
                                ? null
                                : _toggleSpeechInput,
                            borderRadius: BorderRadius.circular(16),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: _isListening
                                    ? const Color(0xFFFFE8F1)
                                    : Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _isListening
                                      ? const Color(0x66FF8BB3)
                                      : GoldPalette.stroke,
                                  width: _isListening ? 1.4 : 1,
                                ),
                                boxShadow: _isListening
                                    ? const <BoxShadow>[
                                        BoxShadow(
                                          color: Color(0x33FF8BB3),
                                          blurRadius: 14,
                                          offset: Offset(0, 6),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: _isInitializingSpeech
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : AnimatedSwitcher(
                                        duration: const Duration(
                                          milliseconds: 180,
                                        ),
                                        transitionBuilder: (child, animation) {
                                          return ScaleTransition(
                                            scale: animation,
                                            child: FadeTransition(
                                              opacity: animation,
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Icon(
                                          _isListening
                                              ? Icons.stop_rounded
                                              : Icons.mic_none_rounded,
                                          key: ValueKey<bool>(_isListening),
                                          color: _isListening
                                              ? GoldPalette.primaryDeep
                                              : GoldPalette.primaryDeep,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_isListening)
                      Transform.translate(
                        offset: const Offset(0, -34),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: <Widget>[
                            TweenAnimationBuilder<double>(
                              tween: Tween<double>(begin: 0.55, end: 1),
                              duration: const Duration(milliseconds: 900),
                              curve: Curves.easeInOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF5B86),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Recording',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: GoldPalette.primaryDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _submit,
                        child: const Text('Submit feedback'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BugUploadCard extends StatelessWidget {
  const _BugUploadCard({
    required this.imagePaths,
    required this.onAdd,
    required this.onRemoveAt,
  });

  final List<String> imagePaths;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemoveAt;

  @override
  Widget build(BuildContext context) {
    final hasImages = imagePaths.isNotEmpty;

    return _GlassPanel(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.74),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.bug_report_outlined,
                  color: GoldPalette.primaryDeep,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Upload bug screenshot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: GoldPalette.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Add one or more images from your photo library.',
                      style: TextStyle(
                        fontSize: 13,
                        color: GoldPalette.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasImages)
            SizedBox(
              width: double.infinity,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onAdd,
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0x66FFFFFF),
                      ),
                    ),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 34,
                          color: GoldPalette.primaryDeep,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Tap to upload screenshots',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: GoldPalette.textOnGold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.62),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: const Color(0x66FFFFFF),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: <Widget>[
                      for (var index = 0; index < imagePaths.length; index++)
                        _BugPreviewTile(
                          imagePath: imagePaths[index],
                          onRemove: () => onRemoveAt(index),
                        ),
                      _BugAddTile(onTap: onAdd),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _BugPreviewTile extends StatelessWidget {
  const _BugPreviewTile({
    required this.imagePath,
    required this.onRemove,
  });

  final String imagePath;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Image.file(
              File(imagePath),
              fit: BoxFit.cover,
            ),
            Positioned(
              top: 6,
              right: 6,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(999),
                  child: Ink(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: const Color(0xD9FFF9F7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: GoldPalette.primaryDeep,
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
}

class _BugAddTile extends StatelessWidget {
  const _BugAddTile({
    required this.onTap,
  });

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.74),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0x66FFFFFF),
            ),
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 24,
                color: GoldPalette.primaryDeep,
              ),
              SizedBox(height: 6),
              Text(
                'Add',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: GoldPalette.textOnGold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementPage extends StatefulWidget {
  const _AgreementPage({
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<_AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<_AgreementPage> {
  bool _isLoading = true;
  String? _error;

  String get _resolvedUrl => widget.url.trim();

  Future<void> _reload() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isValidUrl = _resolvedUrl.isNotEmpty &&
        Uri.tryParse(_resolvedUrl)?.hasAbsolutePath == true;

    return Scaffold(
      body: _SceneBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Row(
                  children: <Widget>[
                    _IconChip(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: GoldPalette.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: Stack(
                      children: <Widget>[
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  color: Colors.white,
                                  child: isValidUrl
                                      ? InAppWebView(
                                          initialUrlRequest: URLRequest(
                                            url: WebUri(_resolvedUrl),
                                          ),
                                          initialSettings: InAppWebViewSettings(
                                            useShouldOverrideUrlLoading: false,
                                            transparentBackground: true,
                                          ),
                                          onLoadStart: (controller, url) {
                                            if (!mounted) {
                                              return;
                                            }
                                            setState(() {
                                              _isLoading = true;
                                              _error = null;
                                            });
                                          },
                                          onLoadStop: (controller, url) {
                                            if (!mounted) {
                                              return;
                                            }
                                            setState(() {
                                              _isLoading = false;
                                            });
                                          },
                                          onReceivedError:
                                              (controller, request, error) {
                                            if (!mounted) {
                                              return;
                                            }
                                            setState(() {
                                              _isLoading = false;
                                              _error = error.description;
                                            });
                                          },
                                          onReceivedHttpError:
                                              (controller, request, response) {
                                            if (!mounted) {
                                              return;
                                            }
                                            setState(() {
                                              _isLoading = false;
                                              _error =
                                                  'HTTP ${response.statusCode ?? ''}';
                                            });
                                          },
                                        )
                                      : const SizedBox.shrink(),
                                ),
                                if (!isValidUrl)
                                  const _AgreementStateView(
                                    icon: Icons.link_off_rounded,
                                    title: 'Agreement link unavailable',
                                    message:
                                        'The configured URL is empty or invalid. Please update your app environment links.',
                                  ),
                                if (_error != null && isValidUrl)
                                  _AgreementStateView(
                                    icon: Icons.wifi_tethering_error_rounded,
                                    title: 'Unable to load',
                                    message: _error!,
                                    actionLabel: 'Retry',
                                    onAction: _reload,
                                  ),
                                if (_isLoading && _error == null && isValidUrl)
                                  const _AgreementLoadingOverlay(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AgreementLoadingOverlay extends StatelessWidget {
  const _AgreementLoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xC8FFFFFF),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor:
                  AlwaysStoppedAnimation<Color>(GoldPalette.primaryDeep),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Loading ${DateTime.now().millisecond.isEven ? 'agreement' : 'page'}...',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: GoldPalette.textOnGold,
            ),
          ),
        ],
      ),
    );
  }
}

class _AgreementStateView extends StatelessWidget {
  const _AgreementStateView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xD8FFFFFF),
      padding: const EdgeInsets.symmetric(horizontal: 28),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 34,
            color: GoldPalette.primaryDeep,
          ),
          const SizedBox(height: 14),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: GoldPalette.textOnGold,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF856852),
            ),
          ),
          if (onAction != null && actionLabel != null) ...<Widget>[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onAction,
              child: Text(actionLabel!),
            ),
          ],
        ],
      ),
    );
  }
}
