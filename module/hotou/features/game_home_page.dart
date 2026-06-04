import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hotou/hotou/features/profile_page.dart';
import 'package:hotou/hotou/features/stack_match_game_page.dart';

class GameHomePage extends StatelessWidget {
  const GameHomePage({super.key});

  void _startGame(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const StackMatchGamePage(),
      ),
    );
  }

  void _showHowToPlay(BuildContext context) {
    HapticFeedback.selectionClick();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HowToPlaySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Positioned.fill(child: _HomeBackground()),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight - 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _buildTopBar(context),
                        const SizedBox(height: 20),
                        const _HeroGameCard(),
                        const SizedBox(height: 18),
                        const _RuleGrid(),
                        const SizedBox(height: 18),
                        _buildPrimaryAction(context),
                        const SizedBox(height: 12),
                        _buildSecondaryAction(context),
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

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: const Color(0xFF263D32),
            borderRadius: BorderRadius.circular(16),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: const Color(0xFF263D32).withOpacity(0.18),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.layers_rounded,
            color: Color(0xFFFFE7A3),
            size: 25,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'HotoU',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF22382E),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 2),
              Text(
                'A calm little tile-clearing puzzle.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Color(0xFF5F7467),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        _SettingsButton(onPressed: () => _openSettings(context)),
      ],
    );
  }

  void _openSettings(BuildContext context) {
    HapticFeedback.selectionClick();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const ProfilePage(),
      ),
    );
  }

  Widget _buildPrimaryAction(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Start game',
      child: SizedBox(
        height: 58,
        child: FilledButton(
          onPressed: () => _startGame(context),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF263D32),
            foregroundColor: const Color(0xFFFFF7DF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            textStyle: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.2,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.play_arrow_rounded, size: 26),
              SizedBox(width: 8),
              Text('Start Game'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction(BuildContext context) {
    return SizedBox(
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _showHowToPlay(context),
        icon: const Icon(Icons.menu_book_rounded, size: 20),
        label: const Text('How to Play'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF263D32),
          side: BorderSide(
            color: const Color(0xFF263D32).withOpacity(0.28),
            width: 1.5,
          ),
          backgroundColor: Colors.white.withOpacity(0.36),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _HomeBackground extends StatelessWidget {
  const _HomeBackground();

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
      child: CustomPaint(painter: _HomePatternPainter()),
    );
  }
}

class _HeroGameCard extends StatelessWidget {
  const _HeroGameCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E8).withOpacity(0.9),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  'Clear the stack before your tray fills up.',
                  style: TextStyle(
                    color: Color(0xFF24382F),
                    fontSize: 28,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          AspectRatio(
            aspectRatio: 1.28,
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF4D7),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.8)),
                    ),
                  ),
                ),
                const Positioned(
                  left: 18,
                  top: 18,
                  child: _PreviewTile(
                    icon: Icons.eco_rounded,
                    color: Color(0xFF4F9A55),
                    lightColor: Color(0xFFC9EFC2),
                    rotation: -0.12,
                  ),
                ),
                const Positioned(
                  right: 30,
                  top: 30,
                  child: _PreviewTile(
                    icon: Icons.cloud_rounded,
                    color: Color(0xFF6FA0B8),
                    lightColor: Color(0xFFD4EEF8),
                    rotation: 0.1,
                  ),
                ),
                const Positioned(
                  left: 82,
                  top: 58,
                  child: _PreviewTile(
                    icon: Icons.star_rounded,
                    color: Color(0xFFE7A530),
                    lightColor: Color(0xFFFFE4A3),
                    rotation: 0.06,
                  ),
                ),
                const Positioned(
                  right: 78,
                  bottom: 42,
                  child: _PreviewTile(
                    icon: Icons.favorite_rounded,
                    color: Color(0xFFD95F59),
                    lightColor: Color(0xFFFFC5BE),
                    rotation: -0.08,
                  ),
                ),
                const Positioned(
                  left: 34,
                  bottom: 30,
                  child: _PreviewTile(
                    icon: Icons.music_note_rounded,
                    color: Color(0xFF6B7DD8),
                    lightColor: Color(0xFFC8D0FF),
                    rotation: 0.14,
                  ),
                ),
                Positioned(
                  right: 18,
                  bottom: 18,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFF263D32),
                      borderRadius: BorderRadius.circular(99),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                          color: const Color(0xFF263D32).withOpacity(0.18),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.bolt_rounded,
                          color: Color(0xFFFFE7A3),
                          size: 17,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Match 3',
                          style: TextStyle(
                            color: Color(0xFFFFF7DF),
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
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

class _PreviewTile extends StatelessWidget {
  const _PreviewTile({
    required this.icon,
    required this.color,
    required this.lightColor,
    required this.rotation,
  });

  final IconData icon;
  final Color color;
  final Color lightColor;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: 72,
        height: 64,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[lightColor, Colors.white],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withOpacity(0.8), width: 2),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF1B2D24).withOpacity(0.12),
              blurRadius: 14,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: Icon(icon, color: color, size: 30),
      ),
    );
  }
}

class _RuleGrid extends StatelessWidget {
  const _RuleGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const <Widget>[
        Expanded(
          child: _RuleCard(
            icon: Icons.touch_app_rounded,
            title: 'Pick',
            body: 'Tap open tiles',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _RuleCard(
            icon: Icons.auto_awesome_rounded,
            title: 'Match',
            body: 'Clear triples',
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _RuleCard(
            icon: Icons.inventory_2_rounded,
            title: 'Tray',
            body: 'Keep space',
          ),
        ),
      ],
    );
  }
}

class _RuleCard extends StatelessWidget {
  const _RuleCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 106),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withOpacity(0.72)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFF355D4B),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: const Color(0xFFFFE7A3)),
          ),
          const SizedBox(height: 8),
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
            body,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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

class _SettingsButton extends StatelessWidget {
  const _SettingsButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Settings',
      child: Material(
        color: const Color(0xFFEAF3D8),
        clipBehavior: Clip.antiAlias,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          child: const SizedBox(
            width: 46,
            height: 46,
            child: Icon(
              Icons.settings_rounded,
              size: 21,
              color: Color(0xFF355D4B),
            ),
          ),
        ),
      ),
    );
  }
}

class _HowToPlaySheet extends StatelessWidget {
  const _HowToPlaySheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E8),
          borderRadius: BorderRadius.circular(28),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'How to Play',
              style: TextStyle(
                color: Color(0xFF24382F),
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 12),
            const _HowToPlayRow(
              icon: Icons.layers_rounded,
              title: 'Look for open tiles',
              body: 'A tile is open when nothing sits on top of it.',
            ),
            const _HowToPlayRow(
              icon: Icons.auto_awesome_rounded,
              title: 'Match three icons',
              body: 'Three matching tiles disappear from the tray.',
            ),
            const _HowToPlayRow(
              icon: Icons.inventory_2_rounded,
              title: 'Protect your tray',
              body: 'The run ends when all seven tray slots are filled.',
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF263D32),
                  foregroundColor: const Color(0xFFFFF7DF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: const Text(
                  'Got It',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HowToPlayRow extends StatelessWidget {
  const _HowToPlayRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEAF3D8),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF355D4B), size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF24382F),
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  body,
                  style: const TextStyle(
                    color: Color(0xFF66796D),
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
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

class _HomePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final ringPaint = Paint()
      ..color = const Color(0xFFFFFFFF).withOpacity(0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final fillPaint = Paint()
      ..color = const Color(0xFFFFD170).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    for (double y = 30; y < size.height; y += 92) {
      for (double x = 22; x < size.width; x += 88) {
        canvas.drawCircle(Offset(x, y), 10, ringPaint);
      }
    }

    canvas.drawCircle(Offset(size.width - 18, 90), 92, fillPaint);
    canvas.drawCircle(Offset(12, size.height * 0.72), 120, fillPaint);

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
