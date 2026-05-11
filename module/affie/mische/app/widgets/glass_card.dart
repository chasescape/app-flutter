import 'package:flutter/material.dart';
import 'package:glass_kit/glass_kit.dart';

class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.borderRadius = 28,
    this.padding,
    this.blur = 22,
    this.backgroundColor = const Color(0xB3191B24),
    this.borderColor = const Color(0x4DFFFFFF),
    this.borderWidth = 1,
    this.enablePressEffect = true,
    this.onTap,
  });

  final Widget child;
  final double borderRadius;
  final EdgeInsetsGeometry? padding;
  final double blur;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWidth;
  final bool enablePressEffect;
  final VoidCallback? onTap;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enablePressEffect) return;
    if (_pressed == value) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.backgroundColor;
    final borderColor = widget.borderColor;
    final gradient = LinearGradient(
      colors: [
        baseColor.withOpacity(0.8),
        baseColor.withOpacity(0.55),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final borderGradient = LinearGradient(
      colors: [
        borderColor.withOpacity(0.5),
        borderColor.withOpacity(0.2),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    final content = AnimatedScale(
      duration: const Duration(milliseconds: 140),
      scale: _pressed ? 0.98 : 1,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 140),
        opacity: _pressed ? 0.96 : 1,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    final height = constraints.maxHeight;

                    return GlassContainer(
                      width: width,
                      height: height,
                      blur: widget.blur,
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      isFrostedGlass: true,
                      frostedOpacity: 0.03,
                      gradient: gradient,
                      borderGradient: borderGradient,
                      borderWidth: widget.borderWidth,
                    );
                  },
                ),
              ),
            ),
            if (_pressed)
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(widget.borderRadius),
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: widget.child,
            ),
            if (widget.onTap != null)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                    onTap: widget.onTap,
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    if (!widget.enablePressEffect) {
      return content;
    }

    return Listener(
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: content,
    );
  }
}
