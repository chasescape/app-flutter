import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../core/theme/app_theme.dart';

class ScentLoadingDialog extends StatefulWidget {
  final VoidCallback? onCancel;
  final String? message;
  final bool showMessage;

  const ScentLoadingDialog({
    super.key,
    this.onCancel,
    this.message,
    this.showMessage = true,
  });

  static void show({
    VoidCallback? onCancel,
    String? message,
    bool showMessage = true,
  }) {
    SmartDialog.show(
      clickMaskDismiss: false,
      maskColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => ScentLoadingDialog(
        onCancel: onCancel,
        message: message,
        showMessage: showMessage,
      ),
    );
  }

  static void dismiss() {
    SmartDialog.dismiss();
  }

  @override
  State<ScentLoadingDialog> createState() => _ScentLoadingDialogState();
}

class _ScentLoadingDialogState extends State<ScentLoadingDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _statusText = 'Preparing...';

  static const _statusTexts = ['Preparing...', 'Analyzing...', 'Finalizing...'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    if (widget.message != null) {
      _statusText = widget.message!;
    } else {
      _cycleStatus();
    }
  }

  void _cycleStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() => _statusText = _statusTexts[1]);
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() => _statusText = _statusTexts[2]);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 196,
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: const [
            BoxShadow(
                color: Color(0x20000000), blurRadius: 24, offset: Offset(0, 8)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 76,
              height: 76,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) => CustomPaint(
                      size: const Size(76, 76),
                      painter: _ScentBubblePainter(_controller.value),
                    ),
                  ),
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (_, __) {
                      final scale = 0.88 +
                          0.12 * math.sin(_controller.value * 2 * math.pi);
                      return Transform.scale(
                        scale: scale,
                        child: const Icon(
                          Icons.local_florist_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            if (widget.showMessage) ...[
              const SizedBox(height: 20),
              Text(
                _statusText,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
            ] else ...[
              const SizedBox(height: 8),
            ],
            if (widget.onCancel != null)
              GestureDetector(
                onTap: () => widget.onCancel?.call(),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
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

class _BubbleDef {
  final double phase;
  final Color color;
  final double radius;
  final double orbitRadius;
  final double speed;

  const _BubbleDef({
    required this.phase,
    required this.color,
    required this.radius,
    required this.orbitRadius,
    required this.speed,
  });
}

class _ScentBubblePainter extends CustomPainter {
  final double progress;

  static const _bubbles = [
    _BubbleDef(
        phase: 0.0,
        color: AppColors.primary,
        radius: 6.0,
        orbitRadius: 23,
        speed: 1.0),
    _BubbleDef(
        phase: 1.25,
        color: AppColors.secondary,
        radius: 5.0,
        orbitRadius: 18,
        speed: 0.8),
    _BubbleDef(
        phase: 2.5,
        color: Color(0xFFFFB088),
        radius: 4.0,
        orbitRadius: 27,
        speed: 1.15),
    _BubbleDef(
        phase: 3.75,
        color: AppColors.secondary,
        radius: 3.5,
        orbitRadius: 14,
        speed: 0.9),
    _BubbleDef(
        phase: 5.0,
        color: AppColors.primary,
        radius: 3.0,
        orbitRadius: 21,
        speed: 1.1),
  ];

  _ScentBubblePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final t = progress * 2 * math.pi;

    for (final b in _bubbles) {
      final angle = t * b.speed + b.phase;
      final x = cx + b.orbitRadius * math.cos(angle);
      final y = cy + b.orbitRadius * 0.65 * math.sin(angle + 0.3 * math.sin(t));

      final opacity = 0.55 + 0.4 * math.sin(t * 1.5 + b.phase);
      final r = b.radius * (0.85 + 0.15 * math.sin(t * 2 + b.phase));

      final paint = Paint()
        ..color = b.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), r, paint);
    }

    // Outer glow ring
    final glowRadius = 30.0 + 3.0 * math.sin(t);
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(Offset(cx, cy), glowRadius, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _ScentBubblePainter old) => true;
}
