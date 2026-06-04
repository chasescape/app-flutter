import 'package:flutter/material.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  const AppScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.extendBody = true,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    return CandyBackground(
      child: Scaffold(
        extendBody: extendBody,
        resizeToAvoidBottomInset: resizeToAvoidBottomInset,
        backgroundColor: Colors.transparent,
        appBar: appBar,
        bottomNavigationBar: bottomNavigationBar,
        body: body,
      ),
    );
  }
}

class CandyBackground extends StatelessWidget {
  final Widget child;

  const CandyBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: AppTheme.candyGradient,
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: CustomPaint(
              painter: _CandyLinePainter(),
            ),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _CandyLinePainter extends CustomPainter {
  const _CandyLinePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.24)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final path = Path()
      ..moveTo(size.width * 0.05, size.height * 0.16)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.02,
        size.width * 0.36,
        size.height * 0.26,
        size.width * 0.18,
        size.height * 0.34,
      );
    canvas.drawPath(path, paint);

    final lowerPath = Path()
      ..moveTo(size.width * 0.54, size.height * 0.92)
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.74,
        size.width * 0.32,
        size.height * 0.66,
        size.width * 0.44,
        size.height * 0.5,
      );
    canvas.drawPath(
        lowerPath, paint..color = Colors.white.withValues(alpha: 0.18));

    final topWash = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x52FFFFFF),
          Color(0x00FFFFFF),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height * 0.42));
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height * 0.42), topWash);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
