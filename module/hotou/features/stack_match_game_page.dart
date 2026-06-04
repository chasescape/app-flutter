import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'coin_wallet.dart';
import 'game_progress.dart';

class StackMatchGamePage extends StatefulWidget {
  const StackMatchGamePage({super.key});

  @override
  State<StackMatchGamePage> createState() => _StackMatchGamePageState();
}

class _StackMatchGamePageState extends State<StackMatchGamePage> {
  static const int _trayLimit = 7;
  static const int _actionCoinCost = 10;
  static const double _boardUnitWidth = 6.7;
  static const double _boardUnitHeight = 4.9;

  final math.Random _random = math.Random();
  final List<_GameSnapshot> _history = <_GameSnapshot>[];

  late List<_BoardTile> _boardTiles;
  final List<_BoardTile> _trayTiles = <_BoardTile>[];

  int _level = 1;
  int _score = 0;
  int _moves = 0;
  int _shuffleCount = 3;
  _GamePhase _phase = _GamePhase.playing;

  @override
  void initState() {
    super.initState();
    _startLevel(resetScore: true);
  }

  void _startLevel({required bool resetScore}) {
    final positions = _tilePositions();
    final deck = _buildDeck(positions.length)..shuffle(_random);

    _boardTiles = <_BoardTile>[
      for (int index = 0; index < positions.length; index++)
        _BoardTile(
          id: index,
          type: deck[index],
          layer: positions[index].layer,
          gridX: positions[index].x,
          gridY: positions[index].y,
        ),
    ];

    _trayTiles.clear();
    _history.clear();
    _moves = 0;
    _shuffleCount = 3;
    _phase = _GamePhase.playing;
    if (resetScore) {
      _level = 1;
      _score = 0;
    }
    GameProgress.syncLevel(_level);
  }

  List<int> _buildDeck(int tileCount) {
    final pairCount = tileCount ~/ 3;
    return <int>[
      for (int type = 0; type < pairCount; type++)
        for (int repeat = 0; repeat < 3; repeat++) type % _tileThemes.length,
    ];
  }

  List<_TilePosition> _tilePositions() {
    final positions = <_TilePosition>[];
    void addGrid({
      required int layer,
      required int rows,
      required int columns,
      required double startX,
      required double startY,
    }) {
      for (int row = 0; row < rows; row++) {
        for (int column = 0; column < columns; column++) {
          positions.add(
            _TilePosition(
              layer: layer,
              x: startX + column * 1.04,
              y: startY + row * 1.02,
            ),
          );
        }
      }
    }

    addGrid(layer: 0, rows: 4, columns: 6, startX: 0.2, startY: 0.25);
    addGrid(layer: 1, rows: 3, columns: 5, startX: 0.72, startY: 0.75);
    addGrid(layer: 2, rows: 3, columns: 4, startX: 1.24, startY: 1.25);
    addGrid(layer: 3, rows: 1, columns: 3, startX: 1.76, startY: 1.75);
    return positions;
  }

  void _saveSnapshot() {
    _history.add(
      _GameSnapshot(
        boardTiles: List<_BoardTile>.of(_boardTiles),
        trayTiles: List<_BoardTile>.of(_trayTiles),
        score: _score,
        moves: _moves,
        shuffleCount: _shuffleCount,
        phase: _phase,
      ),
    );
    if (_history.length > 40) {
      _history.removeAt(0);
    }
  }

  void _selectTile(_BoardTile tile) {
    if (_phase != _GamePhase.playing || _isBlocked(tile)) {
      return;
    }

    _saveSnapshot();
    setState(() {
      _boardTiles.removeWhere((item) => item.id == tile.id);
      _trayTiles.add(tile);
      _moves++;
      HapticFeedback.selectionClick();
      _resolveTray(tile.type);
      _syncPhase();
    });
  }

  void _resolveTray(int type) {
    final matches = _trayTiles.where((tile) => tile.type == type).length;
    if (matches < 3) {
      return;
    }

    _trayTiles.removeWhere((tile) => tile.type == type);
    _score += 30 + _level * 5;
    HapticFeedback.mediumImpact();
  }

  void _syncPhase() {
    if (_boardTiles.isEmpty && _trayTiles.isEmpty) {
      _phase = _GamePhase.won;
      return;
    }
    if (_trayTiles.length >= _trayLimit) {
      _phase = _GamePhase.lost;
    }
  }

  void _undo() {
    if (_history.isEmpty) {
      return;
    }
    if (!_spendActionCoins('Undo')) {
      return;
    }

    final snapshot = _history.removeLast();
    setState(() {
      _boardTiles = List<_BoardTile>.of(snapshot.boardTiles);
      _trayTiles
        ..clear()
        ..addAll(snapshot.trayTiles);
      _score = snapshot.score;
      _moves = snapshot.moves;
      _shuffleCount = snapshot.shuffleCount;
      _phase = snapshot.phase;
      GameProgress.syncLevel(_level);
    });
  }

  void _shuffleBoard() {
    if (_phase != _GamePhase.playing || _shuffleCount <= 0) {
      return;
    }
    if (!_spendActionCoins('Shuffle')) {
      return;
    }

    _saveSnapshot();
    setState(() {
      final types = _boardTiles.map((tile) => tile.type).toList()
        ..shuffle(_random);
      _boardTiles = <_BoardTile>[
        for (int index = 0; index < _boardTiles.length; index++)
          _boardTiles[index].copyWith(type: types[index]),
      ];
      _shuffleCount--;
      HapticFeedback.lightImpact();
    });
  }

  void _restart() {
    setState(() {
      _startLevel(resetScore: true);
    });
  }

  bool _spendActionCoins(String actionName) {
    final spent = CoinWallet.spend(_actionCoinCost);
    if (!spent) {
      _showMessage(
          'Not enough coins. $actionName costs $_actionCoinCost coins.');
      return false;
    }
    _showMessage('-$_actionCoinCost coins');
    return true;
  }

  void _showMessage(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _nextLevel() {
    setState(() {
      _level++;
      final currentScore = _score + 120;
      _startLevel(resetScore: false);
      _score = currentScore;
      GameProgress.syncLevel(_level);
    });
  }

  bool _isBlocked(_BoardTile tile) {
    final rect = tile.gridRect;
    return _boardTiles.any((other) {
      if (other.id == tile.id || other.layer <= tile.layer) {
        return false;
      }
      return _overlapArea(rect, other.gridRect) > 0.08;
    });
  }

  double _overlapArea(Rect a, Rect b) {
    final width = math.min(a.right, b.right) - math.max(a.left, b.left);
    final height = math.min(a.bottom, b.bottom) - math.max(a.top, b.top);
    if (width <= 0 || height <= 0) {
      return 0;
    }
    return width * height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _GameBackground()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                children: <Widget>[
                  _buildHeader(),
                  const SizedBox(height: 14),
                  _buildBoard(),
                  const SizedBox(height: 12),
                  _buildTray(),
                  const SizedBox(height: 12),
                  _buildActions(),
                ],
              ),
            ),
          ),
          if (_phase != _GamePhase.playing) _buildResultOverlay(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _BackButton(onPressed: _goBack),
              ),
            ),
            _Pill(
              label: 'Level $_level',
              icon: Icons.flag_rounded,
              foreground: const Color(0xFF355D4B),
              background: const Color(0xFFEAF3D8),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: <Widget>[
            Expanded(
              child: _StatCard(
                label: 'Score',
                value: '$_score',
                icon: Icons.auto_graph_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Moves',
                value: '$_moves',
                icon: Icons.touch_app_rounded,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatCard(
                label: 'Left',
                value: '${_boardTiles.length}',
                icon: Icons.layers_rounded,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _goBack() {
    HapticFeedback.selectionClick();
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
    }
  }

  Widget _buildBoard() {
    final sortedTiles = List<_BoardTile>.of(_boardTiles)
      ..sort((a, b) {
        final layerResult = a.layer.compareTo(b.layer);
        if (layerResult != 0) {
          return layerResult;
        }
        return a.id.compareTo(b.id);
      });

    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9EA).withOpacity(0.86),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.white.withOpacity(0.72), width: 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF5B6F44).withOpacity(0.16),
              blurRadius: 28,
              offset: const Offset(0, 18),
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final tileSize = math.min(
              constraints.maxWidth / _boardUnitWidth,
              constraints.maxHeight / _boardUnitHeight,
            );
            final boardWidth = tileSize * _boardUnitWidth;
            final boardHeight = tileSize * _boardUnitHeight;
            final originX = (constraints.maxWidth - boardWidth) / 2;
            final originY = (constraints.maxHeight - boardHeight) / 2;

            return ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: CustomPaint(painter: _BoardPatternPainter()),
                  ),
                  for (final tile in sortedTiles)
                    _buildBoardTile(tile, tileSize, originX, originY),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBoardTile(
    _BoardTile tile,
    double tileSize,
    double originX,
    double originY,
  ) {
    final blocked = _isBlocked(tile);
    final layerLift = tile.layer * 2.5;
    return AnimatedPositioned(
      key: ValueKey<int>(tile.id),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      left: originX + tile.gridX * tileSize,
      top: originY + tile.gridY * tileSize - layerLift,
      width: tileSize * 0.92,
      height: tileSize * 0.82,
      child: _MatchTileCard(
        theme: _tileThemes[tile.type],
        blocked: blocked,
        depth: tile.layer,
        onTap: blocked ? null : () => _selectTile(tile),
      ),
    );
  }

  Widget _buildTray() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF24382F).withOpacity(0.92),
        borderRadius: BorderRadius.circular(24),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: const Color(0xFF18251F).withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.inventory_2_rounded,
                color: Color(0xFFF8E9A4),
                size: 18,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  'Tray full at 7 ends the run',
                  style: TextStyle(
                    color: Color(0xFFF6F1D5),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${_trayTiles.length}/$_trayLimit',
                style: const TextStyle(
                  color: Color(0xFFF8E9A4),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: <Widget>[
              for (int index = 0; index < _trayLimit; index++) ...<Widget>[
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 0.9,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOutBack,
                      switchOutCurve: Curves.easeIn,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.center,
                          fit: StackFit.expand,
                          children: <Widget>[
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      child: index < _trayTiles.length
                          ? _TrayTileCard(
                              key: ValueKey<int>(_trayTiles[index].id),
                              theme: _tileThemes[_trayTiles[index].type],
                            )
                          : const _EmptyTraySlot(),
                    ),
                  ),
                ),
                if (index != _trayLimit - 1) const SizedBox(width: 6),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _GameButton(
            label: 'Undo',
            icon: Icons.undo_rounded,
            onPressed: _history.isEmpty ? null : _undo,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GameButton(
            label: 'Shuffle $_shuffleCount',
            icon: Icons.shuffle_rounded,
            onPressed: _shuffleCount <= 0 ? null : _shuffleBoard,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _GameButton(
            label: 'Restart',
            icon: Icons.refresh_rounded,
            onPressed: _restart,
          ),
        ),
      ],
    );
  }

  Widget _buildResultOverlay() {
    final won = _phase == _GamePhase.won;
    return Positioned.fill(
      child: Container(
        color: const Color(0xFF17231E).withOpacity(0.58),
        child: Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.92, end: 1),
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: Container(
              width: 310,
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 22),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E3),
                borderRadius: BorderRadius.circular(32),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(0.24),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    won
                        ? Icons.workspace_premium_rounded
                        : Icons.sentiment_dissatisfied_rounded,
                    color:
                        won ? const Color(0xFFD59A24) : const Color(0xFFBC5E4C),
                    size: 58,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    won ? 'Nice clear!' : 'Tray is full',
                    style: const TextStyle(
                      color: Color(0xFF24382F),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    won
                        ? 'You cleared this level in $_moves moves. Score: $_score.'
                        : 'Try a different order and you can rescue the board.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF5E7164),
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: _DialogButton(
                          label: 'Restart',
                          outlined: true,
                          onPressed: _restart,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _DialogButton(
                          label: won ? 'Next Level' : 'Try Again',
                          outlined: false,
                          onPressed: won ? _nextLevel : _restart,
                        ),
                      ),
                    ],
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

class _BoardTile {
  const _BoardTile({
    required this.id,
    required this.type,
    required this.layer,
    required this.gridX,
    required this.gridY,
  });

  final int id;
  final int type;
  final int layer;
  final double gridX;
  final double gridY;

  Rect get gridRect => Rect.fromLTWH(gridX, gridY, 0.92, 0.82);

  _BoardTile copyWith({int? type}) {
    return _BoardTile(
      id: id,
      type: type ?? this.type,
      layer: layer,
      gridX: gridX,
      gridY: gridY,
    );
  }
}

class _TilePosition {
  const _TilePosition({
    required this.layer,
    required this.x,
    required this.y,
  });

  final int layer;
  final double x;
  final double y;
}

class _GameSnapshot {
  const _GameSnapshot({
    required this.boardTiles,
    required this.trayTiles,
    required this.score,
    required this.moves,
    required this.shuffleCount,
    required this.phase,
  });

  final List<_BoardTile> boardTiles;
  final List<_BoardTile> trayTiles;
  final int score;
  final int moves;
  final int shuffleCount;
  final _GamePhase phase;
}

enum _GamePhase { playing, won, lost }

class _TileTheme {
  const _TileTheme({
    required this.icon,
    required this.label,
    required this.color,
    required this.lightColor,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color lightColor;
}

const List<_TileTheme> _tileThemes = <_TileTheme>[
  _TileTheme(
    icon: Icons.star_rounded,
    label: 'Star',
    color: Color(0xFFE7A530),
    lightColor: Color(0xFFFFE4A3),
  ),
  _TileTheme(
    icon: Icons.favorite_rounded,
    label: 'Heart',
    color: Color(0xFFD95F59),
    lightColor: Color(0xFFFFC5BE),
  ),
  _TileTheme(
    icon: Icons.local_florist_rounded,
    label: 'Bloom',
    color: Color(0xFFAF6AA8),
    lightColor: Color(0xFFF0C7EA),
  ),
  _TileTheme(
    icon: Icons.wb_sunny_rounded,
    label: 'Sun',
    color: Color(0xFFE2A01D),
    lightColor: Color(0xFFFFD87A),
  ),
  _TileTheme(
    icon: Icons.opacity_rounded,
    label: 'Drop',
    color: Color(0xFF459AC7),
    lightColor: Color(0xFFBFE8FA),
  ),
  _TileTheme(
    icon: Icons.local_cafe_rounded,
    label: 'Cup',
    color: Color(0xFF9B6B43),
    lightColor: Color(0xFFE7C39C),
  ),
  _TileTheme(
    icon: Icons.cake_rounded,
    label: 'Cake',
    color: Color(0xFFDA7B92),
    lightColor: Color(0xFFFFCAD7),
  ),
  _TileTheme(
    icon: Icons.spa_rounded,
    label: 'Sprout',
    color: Color(0xFF60A36E),
    lightColor: Color(0xFFC8EDC8),
  ),
  _TileTheme(
    icon: Icons.pets_rounded,
    label: 'Paw',
    color: Color(0xFF8D725B),
    lightColor: Color(0xFFE4D2BD),
  ),
  _TileTheme(
    icon: Icons.music_note_rounded,
    label: 'Note',
    color: Color(0xFF6B7DD8),
    lightColor: Color(0xFFC8D0FF),
  ),
  _TileTheme(
    icon: Icons.flash_on_rounded,
    label: 'Bolt',
    color: Color(0xFFE2B433),
    lightColor: Color(0xFFFFE79D),
  ),
  _TileTheme(
    icon: Icons.cloud_rounded,
    label: 'Cloud',
    color: Color(0xFF6FA0B8),
    lightColor: Color(0xFFD4EEF8),
  ),
  _TileTheme(
    icon: Icons.ac_unit_rounded,
    label: 'Snow',
    color: Color(0xFF69AFC3),
    lightColor: Color(0xFFC9F2F3),
  ),
  _TileTheme(
    icon: Icons.local_fire_department_rounded,
    label: 'Flame',
    color: Color(0xFFE26D3B),
    lightColor: Color(0xFFFFC19B),
  ),
  _TileTheme(
    icon: Icons.flight_takeoff_rounded,
    label: 'Flight',
    color: Color(0xFF5477C8),
    lightColor: Color(0xFFC6D6FF),
  ),
  _TileTheme(
    icon: Icons.beach_access_rounded,
    label: 'Shade',
    color: Color(0xFF3AA189),
    lightColor: Color(0xFFB9ECE0),
  ),
  _TileTheme(
    icon: Icons.local_pizza_rounded,
    label: 'Slice',
    color: Color(0xFFC7772E),
    lightColor: Color(0xFFF7D0A4),
  ),
  _TileTheme(
    icon: Icons.eco_rounded,
    label: 'Leaf',
    color: Color(0xFF4F9A55),
    lightColor: Color(0xFFC9EFC2),
  ),
];

class _GameBackground extends StatelessWidget {
  const _GameBackground();

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
            Color(0xFFB7D7BD),
          ],
        ),
      ),
      child: Stack(
        children: <Widget>[
          Positioned(
            top: -68,
            right: -42,
            child: _SoftCircle(
              size: 180,
              color: Color(0xFFFFD170),
              opacity: 0.34,
            ),
          ),
          Positioned(
            left: -70,
            bottom: 160,
            child: _SoftCircle(
              size: 170,
              color: Color(0xFF6FBF9F),
              opacity: 0.24,
            ),
          ),
          Positioned(
            right: 26,
            bottom: 72,
            child: Transform.rotate(
              angle: -0.18,
              child: const _FloatingBadge(),
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftCircle extends StatelessWidget {
  const _SoftCircle({
    required this.size,
    required this.color,
    required this.opacity,
  });

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(opacity),
      ),
    );
  }
}

class _FloatingBadge extends StatelessWidget {
  const _FloatingBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.white.withOpacity(0.55)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.grass_rounded, size: 18, color: Color(0xFF4F7C55)),
          SizedBox(width: 5),
          Text(
            'Original Stack Match',
            style: TextStyle(
              color: Color(0xFF47634F),
              fontWeight: FontWeight.w900,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.58),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.72)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF355D4B),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFF8E9A4), size: 17),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF68806F),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF24382F),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
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

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.icon,
    required this.foreground,
    required this.background,
  });

  final String label;
  final IconData icon;
  final Color foreground;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: foreground.withOpacity(0.14),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 17, color: foreground),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Back to home',
      child: Material(
        color: Colors.white.withOpacity(0.62),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(99),
          side: BorderSide(
            color: Colors.white.withOpacity(0.74),
            width: 1.4,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          child: const SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              Icons.arrow_back_rounded,
              color: Color(0xFF355D4B),
              size: 21,
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchTileCard extends StatelessWidget {
  const _MatchTileCard({
    required this.theme,
    required this.blocked,
    required this.depth,
    required this.onTap,
  });

  final _TileTheme theme;
  final bool blocked;
  final int depth;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = blocked ? const Color(0xFF9AAA9D) : theme.color;
    return Semantics(
      button: true,
      enabled: onTap != null,
      label: blocked
          ? '${theme.label} tile, covered'
          : '${theme.label} tile, open',
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 180),
          opacity: blocked ? 0.58 : 1,
          child: AnimatedScale(
            duration: const Duration(milliseconds: 140),
            scale: blocked ? 0.97 : 1,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    blocked ? const Color(0xFFE4E7DA) : theme.lightColor,
                    blocked ? const Color(0xFFD2D8CC) : Colors.white,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: borderColor.withOpacity(0.86), width: 2),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFF1B2D24).withOpacity(
                      blocked ? 0.08 : 0.14 + depth * 0.025,
                    ),
                    blurRadius: blocked ? 7 : 12 + depth * 2,
                    offset: Offset(0, blocked ? 4 : 7 + depth.toDouble()),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    theme.icon,
                    color: blocked ? const Color(0xFF849283) : theme.color,
                    size: 27,
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

class _TrayTileCard extends StatelessWidget {
  const _TrayTileCard({
    super.key,
    required this.theme,
  });

  final _TileTheme theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[theme.lightColor, Colors.white],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.color.withOpacity(0.82), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(theme.icon, color: theme.color, size: 23),
        ],
      ),
    );
  }
}

class _EmptyTraySlot extends StatelessWidget {
  const _EmptyTraySlot();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('empty'),
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.22)),
      ),
    );
  }
}

class _GameButton extends StatelessWidget {
  const _GameButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 19),
        label: Text(label),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          backgroundColor: const Color(0xFF355D4B),
          foregroundColor: const Color(0xFFFDF7DF),
          disabledBackgroundColor: const Color(0xFF9EB1A2),
          disabledForegroundColor: const Color(0xFFE8EFE6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.outlined,
    required this.onPressed,
  });

  final String label;
  final bool outlined;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (outlined) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF355D4B),
          side: const BorderSide(color: Color(0xFF8DAA7B), width: 1.5),
          minimumSize: const Size.fromHeight(48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(label),
      );
    }

    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF355D4B),
        foregroundColor: const Color(0xFFFDF7DF),
        minimumSize: const Size.fromHeight(48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: Text(label),
    );
  }
}

class _BoardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF8FB47D).withOpacity(0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    for (double x = -size.height; x < size.width; x += 28) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }

    final dotPaint = Paint()
      ..color = const Color(0xFFE3B84A).withOpacity(0.16)
      ..style = PaintingStyle.fill;
    for (double y = 22; y < size.height; y += 54) {
      for (double x = 28; x < size.width; x += 64) {
        canvas.drawCircle(Offset(x, y), 2.2, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
