import 'package:flutter/material.dart';

class GlassEffect extends StatelessWidget {
  const GlassEffect({
    super.key,
    required this.child,
    this.settings = const GlassEffectSettings(),
    this.useOwnLayer = true,
  });

  final Widget child;
  final GlassEffectSettings settings;
  final bool useOwnLayer;

  @override
  Widget build(BuildContext context) {
    final GlassEffectSettings cfg = settings;

    return ClipRRect(
      borderRadius: BorderRadius.circular(cfg.radius),
      child: Stack(
        children: <Widget>[
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: cfg.backgroundOpacity),
              borderRadius: BorderRadius.circular(cfg.radius),
              border: Border.all(
                color: Colors.white.withValues(alpha: cfg.borderOpacity),
              ),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: Colors.black.withValues(alpha: cfg.shadowOpacity),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(cfg.radius),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[
                    Colors.white.withValues(alpha: cfg.highlightOpacity),
                    Colors.white.withValues(alpha: 0.02),
                  ],
                ),
              ),
            ),
          ),
          if (useOwnLayer)
            Positioned.fill(
              child: Container(
                color: Colors.white.withValues(alpha: 0.02),
              ),
            ),
          child,
        ],
      ),
    );
  }
}

class GlassEffectSettings {
  const GlassEffectSettings({
    this.radius = 20,
    this.backgroundOpacity = 0.08,
    this.borderOpacity = 0.18,
    this.shadowOpacity = 0.2,
    this.highlightOpacity = 0.25,
  });

  final double radius;
  final double backgroundOpacity;
  final double borderOpacity;
  final double shadowOpacity;
  final double highlightOpacity;
}
