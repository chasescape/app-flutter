import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

/// Primary Button Widget with enhanced feedback
class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? width;
  final double? height;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.backgroundColor,
    this.foregroundColor,
    this.width,
    this.height,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled =
        widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: enabled
            ? (_) {
                setState(() => _isPressed = true);
                _scaleController.forward();
                HapticFeedback.lightImpact();
              }
            : null,
        onTapUp: enabled
            ? (_) {
                setState(() => _isPressed = false);
                _scaleController.reverse();
              }
            : null,
        onTapCancel: enabled
            ? () {
                setState(() => _isPressed = false);
                _scaleController.reverse();
              }
            : null,
        child: SizedBox(
          width: widget.width,
          height: widget.height ?? 56,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: enabled && widget.backgroundColor == null
                  ? AppTheme.primaryButtonGradient
                  : null,
              color: widget.backgroundColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              boxShadow: enabled && !_isPressed ? AppTheme.buttonShadow : [],
            ),
            child: ElevatedButton(
              onPressed: enabled ? widget.onPressed : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.backgroundColor ??
                    (enabled
                        ? Colors.transparent
                        : AppTheme.textDisabled.withValues(alpha: 0.28)),
                foregroundColor:
                    widget.foregroundColor ?? AppTheme.primaryWhite,
                disabledBackgroundColor:
                    AppTheme.textDisabled.withValues(alpha: 0.28),
                disabledForegroundColor: AppTheme.textSecondary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: widget.isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primaryWhite),
                      ),
                    )
                  : Text(
                      widget.text,
                      style: AppTheme.body.copyWith(
                        fontWeight: FontWeight.w700,
                        color: enabled
                            ? (widget.foregroundColor ?? AppTheme.primaryWhite)
                            : AppTheme.textDisabled,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Secondary Button Widget with enhanced feedback
class AppSecondaryButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final Color? borderColor;
  final double? width;
  final double? height;

  const AppSecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderColor,
    this.width,
    this.height,
  });

  @override
  State<AppSecondaryButton> createState() => _AppSecondaryButtonState();
}

class _AppSecondaryButtonState extends State<AppSecondaryButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enabled =
        widget.onPressed != null && !widget.isDisabled && !widget.isLoading;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTapDown: enabled
            ? (_) {
                _scaleController.forward();
                HapticFeedback.lightImpact();
              }
            : null,
        onTapUp: enabled ? (_) => _scaleController.reverse() : null,
        onTapCancel: enabled ? () => _scaleController.reverse() : null,
        child: SizedBox(
          width: widget.width,
          height: widget.height ?? 56,
          child: OutlinedButton(
            onPressed: enabled ? widget.onPressed : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.textPrimary,
              backgroundColor: AppTheme.primaryWhite.withValues(alpha: 0.5),
              side: BorderSide(
                color: widget.isDisabled
                    ? AppTheme.textDisabled.withValues(alpha: 0.3)
                    : (widget.borderColor ??
                        AppTheme.primaryWhite.withValues(alpha: 0.82)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
            ),
            child: widget.isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    widget.text,
                    style: AppTheme.body.copyWith(
                      fontWeight: FontWeight.w700,
                      color: enabled
                          ? AppTheme.textInverse
                          : AppTheme.textDisabled,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
