import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'dodge_blocks_coin_page.dart';
import 'favio_palette.dart';
import 'game_progress_store.dart';

enum _BlockType {
  normal,
  fast,
  hunter,
  wall,
}

const Color _gameGoldAccent = Color(0xFFFFC857);
const Color _gameCyanAccent = Color(0xFF7DD3FC);
const Color _gameLabelColor = Color(0xFFC7B8E7);
const Color _gameSurfaceTop = Color(0xFF20172F);
const Color _gameSurfaceBottom = Color(0xFF0B1020);
const Color _gameArenaTop = Color(0xFF241339);
const Color _gameArenaMid = Color(0xFF120A1D);
const Color _gameArenaBottom = Color(0xFF060910);
const Color _gamePanelTop = Color(0xFF27173B);
const Color _gamePanelBottom = Color(0xFF100A1B);
const Color _gameBadgeSurface = Color(0xCC181027);

class DodgeBlocksGamePage extends StatefulWidget {
  const DodgeBlocksGamePage({super.key});

  @override
  State<DodgeBlocksGamePage> createState() => _DodgeBlocksGamePageState();
}

class _DodgeBlocksGamePageState extends State<DodgeBlocksGamePage> {
  static const double _playerSize = 34;
  static const double _playerBottomGap = 24;
  static const Duration _frameDuration = Duration(milliseconds: 16);
  static const int _maxRevivesPerRun = 3;
  static const List<Color> _blockColors = <Color>[
    FavioPalette.brandGlow,
    Color(0xFFFFD166),
    Color(0xFF4ECDC4),
    Color(0xFF5C7CFA),
    Color(0xFFFF922B),
  ];

  final List<_FallingBlock> _blocks = <_FallingBlock>[];
  final math.Random _random = math.Random();

  Timer? _timer;
  final GameProgressStore _progressStore = GameProgressStore.instance;
  Size _playAreaSize = Size.zero;
  double _playerX = 0;
  double _elapsedSeconds = 0;
  double _spawnCooldown = 0.8;
  double _patternCooldown = 3.6;
  int _score = 0;
  int _dangerLevel = 1;
  int _revivesUsed = 0;
  double _shieldTimeLeft = 0;
  bool _isRunning = false;
  bool _isGameOver = false;
  bool _hasFinalizedRun = false;

  int get _reviveCost => 80 + (_revivesUsed * 40);

  int get _bestScore => _progressStore.bestScore;

  int get _coins => _progressStore.coins;

  int get _revivesLeft => _maxRevivesPerRun - _revivesUsed;

  bool get _canRevive =>
      _isGameOver && _coins >= _reviveCost && _revivesUsed < _maxRevivesPerRun;

  @override
  void dispose() {
    _finalizeRunIfNeeded();
    _timer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _finalizeRunIfNeeded();
    _timer?.cancel();

    setState(() {
      _blocks.clear();
      _elapsedSeconds = 0;
      _spawnCooldown = 0.48;
      _patternCooldown = 3.6;
      _score = 0;
      _dangerLevel = 1;
      _revivesUsed = 0;
      _shieldTimeLeft = 0;
      _isRunning = true;
      _isGameOver = false;
      _hasFinalizedRun = false;
      _playerX = _centerPlayerX(_playAreaSize.width);
    });

    _timer = Timer.periodic(_frameDuration, (_) => _tick());
  }

  bool get _hasMeaningfulRun =>
      _isGameOver || _elapsedSeconds > 0 || _score > 0 || _revivesUsed > 0;

  void _recordRunCheckpoint() {
    if (!_hasMeaningfulRun) {
      return;
    }

    _progressStore.recordRun(
      score: _score,
      coins: _coins,
      dangerLevel: _dangerLevel,
      countRun: false,
    );
  }

  void _finalizeRunIfNeeded() {
    if (_hasFinalizedRun || !_hasMeaningfulRun) {
      return;
    }

    _hasFinalizedRun = true;
    _progressStore.recordRun(
      score: _score,
      coins: _coins,
      dangerLevel: _dangerLevel,
    );
  }

  Future<void> _openCoinStore() async {
    final bool shouldResume = _isRunning;

    if (shouldResume) {
      _timer?.cancel();
      _timer = null;
      setState(() {
        _isRunning = false;
      });
    }

    final int? nextCoins = await Navigator.of(context).push<int>(
      MaterialPageRoute<int>(
        builder: (_) => DodgeBlocksCoinPage(
          currentCoins: _coins,
          reviveCost: _reviveCost,
          bestScore: _bestScore,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (nextCoins != null) {
      _progressStore.setCoins(nextCoins);
      if (mounted) {
        setState(() {});
      }
    }

    if (shouldResume && !_isGameOver) {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(_frameDuration, (_) => _tick());
    }
  }

  void _revivePlayer() {
    if (_revivesUsed >= _maxRevivesPerRun) {
      return;
    }

    final int reviveCost = _reviveCost;

    if (_coins < _reviveCost) {
      _openCoinStore();
      return;
    }

    _timer?.cancel();

    setState(() {
      _revivesUsed += 1;
      _shieldTimeLeft = 1.9;
      _isRunning = true;
      _isGameOver = false;
      _playerX = _centerPlayerX(_playAreaSize.width);
      _blocks.clear();
    });
    _progressStore.recordRevive(
      coins: _coins - reviveCost,
    );

    _timer = Timer.periodic(_frameDuration, (_) => _tick());
  }

  void _tick() {
    if (!_isRunning || _playAreaSize == Size.zero) {
      return;
    }

    const double deltaTime = 0.016;
    final double nextElapsed = _elapsedSeconds + deltaTime;
    final double difficulty = 1 + (nextElapsed / 8.5);
    bool didCollide = false;

    setState(() {
      _elapsedSeconds = nextElapsed;
      _dangerLevel = math.min(99, difficulty.ceil());
      _score = (_elapsedSeconds * 14).floor();
      _shieldTimeLeft = math.max(0, _shieldTimeLeft - deltaTime).toDouble();
      _spawnCooldown -= deltaTime;
      _patternCooldown -= deltaTime;

      if (_spawnCooldown <= 0) {
        _spawnRegularRain(difficulty);
        _spawnCooldown = math.max(0.10, 0.52 - difficulty * 0.04) +
            _random.nextDouble() * 0.10;
      }

      if (_patternCooldown <= 0) {
        _spawnPatternWave(difficulty);
        _patternCooldown = math.max(1.6, 3.9 - difficulty * 0.25) +
            _random.nextDouble() * 0.65;
      }

      final double playerCenter = _playerX + (_playerSize / 2);

      for (final _FallingBlock block in _blocks) {
        if (block.type == _BlockType.hunter) {
          final double blockCenter = block.x + (block.width / 2);
          final double seekDistance = playerCenter - blockCenter;
          final double seekStep = seekDistance == 0
              ? 0
              : seekDistance.sign * block.homingStrength * deltaTime;
          block.x +=
              seekStep.abs() > seekDistance.abs() ? seekDistance : seekStep;
        }

        block.x += block.velocityX * deltaTime;

        if (block.bounces && _playAreaSize.width > block.width) {
          if (block.x <= 0 || block.x >= _playAreaSize.width - block.width) {
            block.x = block.x
                .clamp(
                  0.0,
                  _playAreaSize.width - block.width,
                )
                .toDouble();
            block.velocityX = -block.velocityX;
          }
        }

        block.y += block.speed * deltaTime;
      }

      _blocks.removeWhere(
        (_FallingBlock block) =>
            block.y > _playAreaSize.height + block.height ||
            block.x < -(block.width * 2) ||
            block.x > _playAreaSize.width + (block.width * 2),
      );

      final Rect playerRect = Rect.fromLTWH(
        _playerX,
        _playAreaSize.height - _playerBottomGap - _playerSize,
        _playerSize,
        _playerSize,
      );

      if (_shieldTimeLeft <= 0) {
        for (final _FallingBlock block in _blocks) {
          final Rect blockRect = Rect.fromLTWH(
            block.x,
            block.y,
            block.width,
            block.height,
          );
          if (playerRect.overlaps(blockRect)) {
            didCollide = true;
            break;
          }
        }
      }
    });

    if (didCollide) {
      _finishGame();
    }
  }

  void _finishGame() {
    _timer?.cancel();
    _timer = null;

    setState(() {
      _isRunning = false;
      _isGameOver = true;
    });

    if (_revivesLeft > 0) {
      _recordRunCheckpoint();
      return;
    }

    _finalizeRunIfNeeded();
  }

  void _spawnRegularRain(double difficulty) {
    final double mainSize = 24 + _random.nextDouble() * 22;
    _addBlock(
      width: mainSize,
      height: mainSize,
      speed: 200 + _random.nextDouble() * 110 + difficulty * 18,
      color: _blockColors[_random.nextInt(_blockColors.length)],
    );

    if (_random.nextDouble() < math.min(0.85, 0.25 + difficulty * 0.09)) {
      final double fastSize = 18 + _random.nextDouble() * 12;
      _addBlock(
        width: fastSize,
        height: fastSize,
        y: -36 - _random.nextDouble() * 40,
        speed: 280 + _random.nextDouble() * 160 + difficulty * 22,
        velocityX: (_random.nextDouble() - 0.5) * (70 + difficulty * 18),
        color: _gameGoldAccent,
        type: _BlockType.fast,
      );
    }

    if (_elapsedSeconds > 5.5 &&
        _random.nextDouble() < math.min(0.65, 0.06 + difficulty * 0.045)) {
      _spawnHunterBlock(difficulty);
    }
  }

  void _spawnPatternWave(double difficulty) {
    final double roll = _random.nextDouble();

    if (difficulty > 2.2 && roll < 0.42) {
      _spawnGapWall(difficulty);
      return;
    }

    if (difficulty > 1.8 && roll < 0.76) {
      _spawnHunterBurst(difficulty);
      return;
    }

    _spawnDiagonalBurst(difficulty);
  }

  void _spawnHunterBurst(double difficulty) {
    final int count = difficulty < 3.8 ? 2 : 3;
    for (int i = 0; i < count; i++) {
      _spawnHunterBlock(
        difficulty,
        startY: -48 - (i * 74),
      );
    }
  }

  void _spawnHunterBlock(double difficulty, {double? startY}) {
    final double size = 20 + _random.nextDouble() * 10;
    _addBlock(
      width: size,
      height: size,
      y: startY ?? (-70 - _random.nextDouble() * 50),
      speed: 150 + _random.nextDouble() * 70 + difficulty * 12,
      color: _gameCyanAccent,
      type: _BlockType.hunter,
      homingStrength: 120 + difficulty * 28,
    );
  }

  void _spawnDiagonalBurst(double difficulty) {
    final bool fromLeft = _random.nextBool();
    final int count = difficulty < 4 ? 4 : 5;
    final double drift = (90 + difficulty * 18) * (fromLeft ? 1 : -1);

    for (int i = 0; i < count; i++) {
      final double size = 18 + _random.nextDouble() * 10;
      _addBlock(
        x: fromLeft ? -(size * 0.4) : _playAreaSize.width - (size * 0.6),
        y: -(i * 58) - size,
        width: size,
        height: size,
        speed: 250 + difficulty * 18 + i * 12,
        velocityX: drift,
        color: _gameGoldAccent,
        type: _BlockType.fast,
      );
    }
  }

  void _spawnGapWall(double difficulty) {
    final int columns = _playAreaSize.width < 340 ? 6 : 7;
    final int gapWidth = difficulty < 3.2 ? 2 : 1;
    final int gapStart = _random.nextInt(columns - gapWidth + 1);
    final double segmentWidth = _playAreaSize.width / columns;
    final double wallHeight = 28;
    final double wallSpeed = 230 + difficulty * 18;

    for (int i = 0; i < columns; i++) {
      if (i >= gapStart && i < gapStart + gapWidth) {
        continue;
      }

      _addBlock(
        x: i * segmentWidth + 2,
        y: -wallHeight,
        width: math.max(12.0, segmentWidth - 4).toDouble(),
        height: wallHeight,
        speed: wallSpeed,
        color: FavioPalette.brandGlow,
        type: _BlockType.wall,
      );
    }

    if (difficulty > 5.2 && _random.nextDouble() < 0.45) {
      final int secondGapStart = _random.nextInt(columns);
      for (int i = 0; i < columns; i++) {
        if (i == secondGapStart) {
          continue;
        }

        _addBlock(
          x: i * segmentWidth + 2,
          y: -wallHeight - 150,
          width: math.max(12.0, segmentWidth - 4).toDouble(),
          height: wallHeight,
          speed: wallSpeed + 18,
          color: FavioPalette.brandBright,
          type: _BlockType.wall,
        );
      }
    }
  }

  void _addBlock({
    required double width,
    required double height,
    required double speed,
    required Color color,
    double? x,
    double? y,
    double velocityX = 0,
    double homingStrength = 0,
    bool bounces = false,
    _BlockType type = _BlockType.normal,
  }) {
    _blocks.add(
      _FallingBlock(
        x: x ?? _randomXForWidth(width),
        y: y ?? -height,
        width: width,
        height: height,
        speed: speed,
        color: color,
        velocityX: velocityX,
        homingStrength: homingStrength,
        bounces: bounces,
        type: type,
      ),
    );
  }

  double _randomXForWidth(double blockWidth) {
    final double maxX =
        math.max(0.0, _playAreaSize.width - blockWidth).toDouble();
    return maxX == 0 ? 0 : _random.nextDouble() * maxX;
  }

  void _updatePlayerPosition(double localDx) {
    if (_playAreaSize == Size.zero) {
      return;
    }

    final double maxPlayerX = _maxPlayerX(_playAreaSize.width);
    final double nextX =
        (localDx - (_playerSize / 2)).clamp(0.0, maxPlayerX).toDouble();

    setState(() {
      _playerX = nextX;
    });
  }

  void _syncPlayAreaSize(Size nextSize) {
    if (nextSize == _playAreaSize) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || nextSize == _playAreaSize) {
        return;
      }

      final bool shouldCenterPlayer = _playAreaSize == Size.zero;
      final double maxPlayerX = _maxPlayerX(nextSize.width);

      setState(() {
        _playAreaSize = nextSize;
        _playerX = shouldCenterPlayer
            ? _centerPlayerX(nextSize.width)
            : _playerX.clamp(0.0, maxPlayerX).toDouble();
      });
    });
  }

  double _centerPlayerX(double width) {
    return _maxPlayerX(width) / 2;
  }

  double _maxPlayerX(double width) {
    return math.max(0.0, width - _playerSize).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (bool didPop, Object? result) {
        _finalizeRunIfNeeded();
      },
      child: Scaffold(
        backgroundColor: FavioPalette.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.white,
          elevation: 0,
          titleSpacing: 18,
          title: const Text(
            'Favio',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
            ),
          ),
        ),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: <Color>[
                FavioPalette.backgroundTop,
                Color(0xFF0A0913),
                FavioPalette.backgroundBottom,
              ],
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: <Widget>[
                  _GameHud(
                    score: _score,
                    bestScore: _bestScore,
                    coins: _coins,
                    onStoreTap: _openCoinStore,
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: <Color>[
                                _gameArenaTop,
                                _gameArenaMid,
                                _gameArenaBottom,
                              ],
                            ),
                            border: Border.all(
                              color: FavioPalette.brandGlow
                                  .withValues(alpha: 0.16),
                            ),
                            boxShadow: <BoxShadow>[
                              const BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 28,
                                offset: Offset(0, 18),
                              ),
                              BoxShadow(
                                color: FavioPalette.brandGlow
                                    .withValues(alpha: 0.14),
                                blurRadius: 44,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(28),
                            child: LayoutBuilder(
                              builder: (BuildContext context,
                                  BoxConstraints constraints) {
                                final Size size = Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                );
                                _syncPlayAreaSize(size);

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapDown: (TapDownDetails details) {
                                    _updatePlayerPosition(
                                        details.localPosition.dx);
                                  },
                                  onHorizontalDragUpdate:
                                      (DragUpdateDetails details) {
                                    _updatePlayerPosition(
                                        details.localPosition.dx);
                                  },
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: <Widget>[
                                      const _GameBackground(),
                                      Positioned(
                                        top: 16,
                                        left: 16,
                                        child: _TopBadge(
                                          label:
                                              _isRunning ? 'LIVE' : 'STANDBY',
                                          icon: _isRunning
                                              ? Icons
                                                  .radio_button_checked_rounded
                                              : Icons.tune_rounded,
                                          accentColor: _isRunning
                                              ? FavioPalette.brandBright
                                              : FavioPalette.brand,
                                        ),
                                      ),
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: _CoinPill(
                                          coins: _coins,
                                          onTap: _openCoinStore,
                                        ),
                                      ),
                                      for (final _FallingBlock block in _blocks)
                                        Positioned(
                                          left: block.x,
                                          top: block.y,
                                          child: _BlockTile(block: block),
                                        ),
                                      if (_shieldTimeLeft > 0)
                                        Positioned(
                                          left: _playerX - 10,
                                          bottom: _playerBottomGap - 10,
                                          child: IgnorePointer(
                                            child: _ShieldRing(
                                              secondsLeft: _shieldTimeLeft,
                                            ),
                                          ),
                                        ),
                                      Positioned(
                                        left: _playerX,
                                        bottom: _playerBottomGap,
                                        child: const _PlayerTile(),
                                      ),
                                      if (!_isRunning)
                                        _GameOverlay(
                                          isGameOver: _isGameOver,
                                          score: _score,
                                          onStart: _startGame,
                                          coins: _coins,
                                          reviveCost: _reviveCost,
                                          revivesLeft: _revivesLeft,
                                          canRevive: _canRevive,
                                          onRevive: _revivePlayer,
                                          onOpenStore: _openCoinStore,
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
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
    );
  }
}

class _GameHud extends StatelessWidget {
  const _GameHud({
    required this.score,
    required this.bestScore,
    required this.coins,
    required this.onStoreTap,
  });

  final int score;
  final int bestScore;
  final int coins;
  final VoidCallback onStoreTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: _HudCard(
            label: 'SCORE',
            value: '$score',
            accentColor: _gameGoldAccent,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _HudCard(
            label: 'BEST',
            value: '$bestScore',
            accentColor: _gameCyanAccent,
          ),
        ),
        const SizedBox(width: 8),
        _HudActionCard(
          coins: coins,
          onTap: onStoreTap,
        ),
      ],
    );
  }
}

class _HudCard extends StatelessWidget {
  const _HudCard({
    required this.label,
    required this.value,
    required this.accentColor,
  });

  final String label;
  final String value;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            _gameSurfaceTop.withValues(alpha: 0.94),
            _gameSurfaceBottom.withValues(alpha: 0.94),
          ],
        ),
        border: Border.all(
          color: FavioPalette.brandGlow.withValues(alpha: 0.10),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: accentColor.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: const TextStyle(
                    color: _gameLabelColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    shadows: <Shadow>[
                      Shadow(
                        color: accentColor.withValues(alpha: 0.30),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GameBackground extends StatelessWidget {
  const _GameBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _GridPainter(),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint glowPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 48);

    glowPaint.color = _gameCyanAccent.withValues(alpha: 0.08);
    canvas.drawCircle(
      Offset(size.width * 0.18, size.height * 0.14),
      size.width * 0.22,
      glowPaint,
    );

    glowPaint.color = FavioPalette.brandGlow.withValues(alpha: 0.13);
    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.76),
      size.width * 0.28,
      glowPaint,
    );

    final Paint linePaint = Paint()
      ..color = _gameLabelColor.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const double gap = 28;

    for (double x = 0; x <= size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }

    for (double y = 0; y <= size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }

    final Paint sweepPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          Color(0x00D85CFF),
          Color(0x1FD85CFF),
          Color(0x00D85CFF),
        ],
      ).createShader(
        Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.18),
      );

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.62, size.width, size.height * 0.18),
      sweepPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _BlockTile extends StatelessWidget {
  const _BlockTile({required this.block});

  final _FallingBlock block;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: block.width,
      height: block.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            block.color,
            Color.lerp(block.color, Colors.white, 0.18) ?? block.color,
          ],
        ),
        borderRadius: BorderRadius.circular(
          block.type == _BlockType.wall ? 6 : 8,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: block.type == _BlockType.hunter ? 0.50 : 0.18,
          ),
          width: block.type == _BlockType.hunter ? 1.6 : 1,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: block.color.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: block.type == _BlockType.hunter
          ? Center(
              child: Icon(
                Icons.gps_fixed_rounded,
                color: Colors.white,
                size: math.min(block.width, block.height) * 0.56,
              ),
            )
          : null,
    );
  }
}

class _PlayerTile extends StatelessWidget {
  const _PlayerTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _DodgeBlocksGamePageState._playerSize,
      height: _DodgeBlocksGamePageState._playerSize,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            FavioPalette.brandBright,
            FavioPalette.brandGlow,
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.28),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: FavioPalette.brandGlow.withValues(alpha: 0.42),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 6,
            child: Container(
              width: 10,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.70),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          const Icon(
            Icons.navigation_rounded,
            color: Colors.white,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class _GameOverlay extends StatelessWidget {
  const _GameOverlay({
    required this.isGameOver,
    required this.score,
    required this.onStart,
    required this.coins,
    required this.reviveCost,
    required this.revivesLeft,
    required this.canRevive,
    required this.onRevive,
    required this.onOpenStore,
  });

  final bool isGameOver;
  final int score;
  final VoidCallback onStart;
  final int coins;
  final int reviveCost;
  final int revivesLeft;
  final bool canRevive;
  final VoidCallback onRevive;
  final VoidCallback onOpenStore;

  bool get _hasRevivesRemaining => revivesLeft > 0;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xC70A0712),
              Color(0xEE090611),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 312),
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    _gamePanelTop,
                    _gamePanelBottom,
                  ],
                ),
                border: Border.all(
                  color: FavioPalette.brandGlow.withValues(alpha: 0.16),
                ),
                boxShadow: <BoxShadow>[
                  const BoxShadow(
                    color: Color(0x66000000),
                    blurRadius: 26,
                    offset: Offset(0, 18),
                  ),
                  BoxShadow(
                    color: FavioPalette.brandGlow.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  _TopBadge(
                    label: isGameOver ? 'RUN OVER' : 'GET READY',
                    icon: isGameOver
                        ? Icons.close_rounded
                        : Icons.flash_on_rounded,
                    accentColor:
                        isGameOver ? _gameGoldAccent : FavioPalette.brandBright,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isGameOver ? 'Score $score' : 'Ready for Favio',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (isGameOver) ...<Widget>[
                    _RevivePanel(
                      coins: coins,
                      reviveCost: reviveCost,
                      revivesLeft: revivesLeft,
                      canRevive: canRevive,
                    ),
                    if (_hasRevivesRemaining) ...<Widget>[
                      const SizedBox(height: 16),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onOpenStore,
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: FavioPalette.brandBright
                                      .withValues(alpha: 0.20),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text('Get Coins'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton(
                              onPressed: canRevive ? onRevive : onOpenStore,
                              style: FilledButton.styleFrom(
                                minimumSize: const Size.fromHeight(52),
                                backgroundColor: _gameGoldAccent,
                                foregroundColor: const Color(0xFF1C1302),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: Text(canRevive ? 'Revive' : 'Recharge'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ],
                  FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(54),
                      backgroundColor: FavioPalette.brandGlow,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(isGameOver ? 'Restart Run' : 'Start Game'),
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

class _HudActionCard extends StatelessWidget {
  const _HudActionCard({
    required this.coins,
    required this.onTap,
  });

  final int coins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          width: 82,
          height: 82,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color(0xFF2A1B30),
                Color(0xFF141018),
              ],
            ),
            border: Border.all(
              color: _gameGoldAccent.withValues(alpha: 0.42),
            ),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: _gameGoldAccent.withValues(alpha: 0.14),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: FavioPalette.brandGlow.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.currency_bitcoin_rounded,
                  color: _gameGoldAccent,
                  size: 18,
                ),
                const Spacer(),
                Text(
                  '$coins',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'STORE',
                  style: TextStyle(
                    color: Color(0xFFF1D894),
                    fontSize: 10,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w700,
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

class _CoinPill extends StatelessWidget {
  const _CoinPill({
    required this.coins,
    required this.onTap,
  });

  final int coins;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _gameBadgeSurface.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _gameGoldAccent.withValues(alpha: 0.26),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.monetization_on_rounded,
                color: _gameGoldAccent,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                '$coins',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShieldRing extends StatelessWidget {
  const _ShieldRing({
    required this.secondsLeft,
  });

  final double secondsLeft;

  @override
  Widget build(BuildContext context) {
    final double progress = (secondsLeft / 1.9).clamp(0.0, 1.0);

    return Container(
      width: _DodgeBlocksGamePageState._playerSize + 20,
      height: _DodgeBlocksGamePageState._playerSize + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF6AE7FF).withValues(alpha: 0.55 * progress),
          width: 2.4,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF6AE7FF).withValues(alpha: 0.16 * progress),
            blurRadius: 18,
            spreadRadius: 2,
          ),
        ],
      ),
    );
  }
}

class _RevivePanel extends StatelessWidget {
  const _RevivePanel({
    required this.coins,
    required this.reviveCost,
    required this.revivesLeft,
    required this.canRevive,
  });

  final int coins;
  final int reviveCost;
  final int revivesLeft;
  final bool canRevive;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xCC171024),
        border: Border.all(
          color: FavioPalette.brandGlow.withValues(alpha: 0.10),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.favorite_rounded,
                color: _gameGoldAccent,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Revive Cost $reviveCost',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$coins coins',
                style: TextStyle(
                  color: canRevive
                      ? const Color(0xFFFFE6A7)
                      : FavioPalette.brandSoftText,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              Expanded(
                child: _MiniMeta(
                  label: 'Revives left',
                  value: '$revivesLeft',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _MiniMeta(
                  label: 'Status',
                  value: canRevive ? 'Ready' : 'Need coins',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniMeta extends StatelessWidget {
  const _MiniMeta({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.white.withValues(alpha: 0.04),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              color: _gameLabelColor,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBadge extends StatelessWidget {
  const _TopBadge({
    required this.label,
    required this.icon,
    this.accentColor = FavioPalette.brandBright,
  });

  final String label;
  final IconData icon;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _gameBadgeSurface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            icon,
            size: 14,
            color: accentColor,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

class _FallingBlock {
  _FallingBlock({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    required this.speed,
    required this.color,
    required this.velocityX,
    required this.homingStrength,
    required this.bounces,
    required this.type,
  });

  double x;
  double y;
  final double width;
  final double height;
  final double speed;
  final Color color;
  double velocityX;
  final double homingStrength;
  final bool bounces;
  final _BlockType type;
}
