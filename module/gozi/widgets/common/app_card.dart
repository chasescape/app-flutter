import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'package:achievenote/gozi/widgets/common/gozi_image.dart';

/// App Card Widget with enhanced shadows and feedback
class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final double? borderRadius;
  final double? elevation;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.backgroundColor,
    this.borderRadius,
    this.elevation,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  AnimationController? _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    if (widget.onTap != null) {
      final scaleController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100),
      );
      _scaleController = scaleController;
      _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
        CurvedAnimation(parent: scaleController, curve: Curves.easeInOut),
      );
    }
  }

  @override
  void dispose() {
    _scaleController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveElevation = widget.elevation ?? 1.0;
    final effectiveRadius = widget.borderRadius ?? AppTheme.radiusLg;

    final card = Container(
      margin: widget.margin ?? const EdgeInsets.all(AppTheme.sm),
      padding: widget.padding ?? const EdgeInsets.all(AppTheme.lg),
      decoration: BoxDecoration(
        color: widget.backgroundColor ?? AppTheme.backgroundSecondary,
        gradient: widget.backgroundColor == null
            ? AppTheme.softSurfaceGradient
            : null,
        borderRadius: BorderRadius.circular(effectiveRadius),
        border: Border.all(
          color: AppTheme.primaryWhite.withValues(alpha: 0.72),
        ),
        boxShadow: _buildCardShadows(effectiveElevation, _isPressed),
      ),
      child: widget.child,
    );

    if (widget.onTap != null) {
      return ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTapDown: (_) {
            setState(() => _isPressed = true);
            _scaleController?.forward();
            HapticFeedback.lightImpact();
          },
          onTapUp: (_) {
            setState(() => _isPressed = false);
            _scaleController?.reverse();
          },
          onTapCancel: () {
            setState(() => _isPressed = false);
            _scaleController?.reverse();
          },
          onTap: widget.onTap,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(effectiveRadius),
              splashColor: AppTheme.accentRed.withValues(alpha: 0.08),
              highlightColor: AppTheme.primaryWhite.withValues(alpha: 0.14),
              child: card,
            ),
          ),
        ),
      );
    }

    return card;
  }

  List<BoxShadow> _buildCardShadows(double elevation, bool isPressed) {
    if (elevation <= 0) return [];

    final pressFactor = isPressed ? 0.5 : 1.0;

    return [
      // Primary shadow
      BoxShadow(
        color: AppTheme.accentRed.withValues(alpha: 0.12 * pressFactor),
        blurRadius: 30 * pressFactor,
        offset: Offset(0, 14 * pressFactor),
      ),
      // Secondary shadow
      BoxShadow(
        color: Colors.white.withValues(alpha: 0.72 * pressFactor),
        blurRadius: 10 * pressFactor,
        offset: const Offset(-4, -4),
      ),
    ];
  }
}

/// Achievement Card Widget
class AchievementCard extends StatelessWidget {
  final String title;
  final String description;
  final List<String> tags;
  final String imagePath;
  final String? category;
  final String? note;
  final DateTime createdAt;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.tags,
    required this.imagePath,
    this.category,
    this.note,
    required this.createdAt,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.sm),
      borderRadius: AppTheme.radiusXl,
      child: Stack(
        children: [
          GoziImage(
            imagePath: imagePath,
            width: double.infinity,
            height: 260,
            fit: BoxFit.cover,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          if (onDelete != null)
            Positioned(
              top: AppTheme.sm,
              right: AppTheme.sm,
              child: Material(
                color: AppTheme.primaryWhite.withValues(alpha: 0.84),
                shape: const CircleBorder(),
                child: IconButton(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline,
                    color: AppTheme.error,
                  ),
                  tooltip: 'Delete',
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CompactAchievementCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final String? category;
  final DateTime createdAt;
  final VoidCallback? onTap;

  const CompactAchievementCard({
    super.key,
    required this.title,
    required this.imagePath,
    this.category,
    required this.createdAt,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.sm),
      margin: EdgeInsets.zero,
      borderRadius: AppTheme.radiusXl,
      child: GoziImage(
        imagePath: imagePath,
        width: double.infinity,
        height: 180,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
    );
  }
}

class AchievementImageStrip extends StatelessWidget {
  final String imagePath;
  final VoidCallback? onTap;

  const AchievementImageStrip({
    super.key,
    required this.imagePath,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 132,
        margin: const EdgeInsets.only(right: AppTheme.md),
        padding: const EdgeInsets.all(AppTheme.xs),
        decoration: BoxDecoration(
          gradient: AppTheme.softSurfaceGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border:
              Border.all(color: AppTheme.primaryWhite.withValues(alpha: 0.7)),
          boxShadow: AppTheme.cardShadow,
        ),
        child: GoziImage(
          imagePath: imagePath,
          width: 124,
          height: 160,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }
}
