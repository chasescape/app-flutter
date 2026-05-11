import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class DreamScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final EdgeInsetsGeometry? bodyPadding;

  const DreamScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.bodyPadding,
  });

  @override
  Widget build(BuildContext context) {
    final content = Padding(
      padding: bodyPadding ?? EdgeInsets.zero,
      child: body,
    );
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      backgroundColor: Colors.transparent,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DreamBackground(),
          SafeArea(
            top: !extendBodyBehindAppBar,
            bottom: false,
            child: content,
          ),
        ],
      ),
    );
  }
}

class DreamBackground extends StatelessWidget {
  const DreamBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(decoration: const BoxDecoration(gradient: AppTheme.dreamyBackground)),
        Positioned(
          top: -80,
          left: -40,
          child: _blurBubble(
            size: 220,
            colors: const [Color(0x55FFFFFF), Color(0x33FFC0EF)],
          ),
        ),
        Positioned(
          top: 140,
          right: -20,
          child: _blurBubble(
            size: 170,
            colors: const [Color(0x55F78FD4), Color(0x22FFFFFF)],
          ),
        ),
        Positioned(
          bottom: -30,
          left: 40,
          child: _blurBubble(
            size: 200,
            colors: const [Color(0x44BFE7FF), Color(0x18FFFFFF)],
          ),
        ),
        const IgnorePointer(child: StarryOverlay()),
      ],
    );
  }

  Widget _blurBubble({required double size, required List<Color> colors}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: colors),
      ),
    );
  }
}

class StarryOverlay extends StatelessWidget {
  const StarryOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _StarPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.8);
    final glow = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5)
      ..color = Colors.white.withValues(alpha: 0.32);
    final stars = <Offset>[
      Offset(size.width * 0.14, size.height * 0.08),
      Offset(size.width * 0.24, size.height * 0.18),
      Offset(size.width * 0.67, size.height * 0.12),
      Offset(size.width * 0.8, size.height * 0.2),
      Offset(size.width * 0.16, size.height * 0.36),
      Offset(size.width * 0.52, size.height * 0.31),
      Offset(size.width * 0.73, size.height * 0.42),
      Offset(size.width * 0.31, size.height * 0.56),
      Offset(size.width * 0.63, size.height * 0.61),
      Offset(size.width * 0.85, size.height * 0.74),
      Offset(size.width * 0.11, size.height * 0.82),
    ];
    for (var i = 0; i < stars.length; i++) {
      final center = stars[i];
      final radius = i.isEven ? 1.8 : 1.2;
      canvas.drawCircle(center, radius * 2.4, glow);
      canvas.drawCircle(center, radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? borderColor;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding ?? const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: borderColor ?? AppColors.borderSoft,
          width: 1,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14A35BD8),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: child,
    );
    if (onTap == null) return content;
    return GestureDetector(onTap: onTap, child: content);
  }
}

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final IconData? icon;
  final double? width;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.icon,
    this.width,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final child = SizedBox(
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              child: _buildChild(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              child: _buildChild(),
            ),
    );
    if (width != null) {
      return SizedBox(width: width, child: child);
    }
    return child;
  }

  Widget _buildChild() {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.4,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnDark),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
        ],
      );
    }
    return Text(text);
  }
}

class CoinBadge extends StatelessWidget {
  final int coins;
  final VoidCallback? onTap;

  const CoinBadge({super.key, required this.coins, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.bgCardStrong,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: AppColors.borderSoft),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.diamond_outlined, size: 16, color: AppColors.secondary),
            const SizedBox(width: 6),
            Text(
              '$coins',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StyleTagChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const StyleTagChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.heroGradient : null,
          color: isSelected ? null : AppColors.bgCardLight,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isSelected ? Colors.transparent : AppColors.borderSoft,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppColors.textOnDark : AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class AppImageStage extends StatelessWidget {
  final String? imagePath;
  final double height;
  final BorderRadius? borderRadius;
  final Widget? footer;
  final Widget? overlay;
  final String? emptyTitle;
  final String? emptySubtitle;
  final VoidCallback? onTap;

  const AppImageStage({
    super.key,
    this.imagePath,
    this.height = 320,
    this.borderRadius,
    this.footer,
    this.overlay,
    this.emptyTitle,
    this.emptySubtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppRadius.xl);
    final card = ClipRRect(
      borderRadius: radius,
      child: Container(
        height: height,
        decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildImage(),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.14),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.1),
                  ],
                ),
              ),
            ),
            if (overlay != null) overlay!,
            if (footer != null)
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.primary.withValues(alpha: 0.6),
                      ],
                    ),
                  ),
                  child: footer,
                ),
              ),
          ],
        ),
      ),
    );
    if (onTap == null) return card;
    return GestureDetector(onTap: onTap, child: card);
  }

  Widget _buildImage() {
    if (imagePath == null || imagePath!.isEmpty) {
      return _emptyState();
    }
    final file = File(imagePath!);
    if (file.existsSync()) {
      return Image.file(file, fit: BoxFit.cover);
    }
    return _emptyState();
  }

  Widget _emptyState() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppTheme.heroGradient),
        ),
        Positioned(
          top: 24,
          right: 24,
          child: Transform.rotate(
            angle: -math.pi / 12,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
        ),
        Positioned(
          top: 38,
          left: 28,
          child: Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.11),
            ),
          ),
        ),
        Positioned(
          top: 132,
          left: 26,
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
            ),
          ),
        ),
        Positioned(
          right: 52,
          bottom: 118,
          child: Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
        Positioned(
          left: 58,
          bottom: 82,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.18),
            ),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_camera_back_outlined,
                  color: AppColors.textOnDark,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                emptyTitle ?? 'Add your photo',
                style: const TextStyle(
                  color: AppColors.textOnDark,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (emptySubtitle != null) ...[
                const SizedBox(height: 6),
                Text(
                  emptySubtitle!,
                  style: const TextStyle(
                    color: Color(0xE6FFFFFF),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String eyebrow;
  final String title;
  final String? subtitle;
  final Widget? trailing;

  const SectionTitle({
    super.key,
    required this.eyebrow,
    required this.title,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 4),
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.3,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class PulseLoading extends StatelessWidget {
  final String message;

  const PulseLoading({super.key, this.message = 'Analyzing...'});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            width: 30,
            height: 30,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

void copyToClipboard(BuildContext context, String text) {
  Clipboard.setData(ClipboardData(text: text));
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: const Text('Copied to clipboard'),
      backgroundColor: AppColors.textPrimary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
    ),
  );
}

class AnalysisLoadingOverlay extends StatefulWidget {
  final VoidCallback? onCancel;

  const AnalysisLoadingOverlay({super.key, this.onCancel});

  @override
  State<AnalysisLoadingOverlay> createState() => _AnalysisLoadingOverlayState();
}

class _AnalysisLoadingOverlayState extends State<AnalysisLoadingOverlay>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  int _statusIndex = 0;
  Timer? _statusTimer;

  static const _statusMessages = [
    'Preparing your photo...',
    'Matching dreamy styles...',
    'Curating your final moodboard...',
    'Polishing the best details...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _statusTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (mounted) {
        setState(() => _statusIndex = (_statusIndex + 1) % _statusMessages.length);
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _statusTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.6),
      child: Center(
        child: AppCard(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, _) {
                  final scale = 0.92 + (_pulseController.value * 0.12);
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AppTheme.heroGradient,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.auto_awesome, color: AppColors.textOnDark, size: 40),
                    ),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 240),
                child: Text(
                  _statusMessages[_statusIndex],
                  key: ValueKey(_statusIndex),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 140,
                child: AppButton(
                  text: 'Cancel',
                  isOutlined: true,
                  onPressed: widget.onCancel,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String content,
  String confirmText = 'Confirm',
  String cancelText = 'Cancel',
}) async {
  final result = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: AppColors.bgCardStrong,
      title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
      content: Text(content, style: const TextStyle(color: AppColors.textSecondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(cancelText, style: const TextStyle(color: AppColors.textSecondary)),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText, style: const TextStyle(color: AppColors.secondary)),
        ),
      ],
    ),
  );
  return result ?? false;
}
