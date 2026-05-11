import 'package:flutter/material.dart';

import '../../../gen_a/A.dart';


class KissmiBackground extends StatelessWidget {
  const KissmiBackground({
    super.key,
    required this.child,
    this.overlayColor,
    this.overlayOpacity = 0.88,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
  });

  final Widget child;
  final Color? overlayColor;
  final double overlayOpacity;
  final BoxFit fit;
  final Alignment alignment;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: Image.asset(
              A.assets_kissmi_background,
              fit: fit,
              alignment: alignment,
            ),
          ),
          if (overlayColor != null)
            Positioned.fill(
              child: ColoredBox(
                color: overlayColor!.withValues(alpha: overlayOpacity),
              ),
            ),
          child,
        ],
      ),
    );
  }
}
