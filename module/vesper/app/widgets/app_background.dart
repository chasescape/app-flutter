import 'package:flutter/material.dart';

import '../../../gen_a/A.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    this.child,
    this.padding,
    this.safeArea = true,
    this.useImageBackground = false,
  });

  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final bool safeArea;
  final bool useImageBackground;

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: double.infinity,
      height: double.infinity,
      decoration: useImageBackground 
          ? BoxDecoration(
              image: DecorationImage(
                image: AssetImage(A.assets_vesper_bg),
                fit: BoxFit.cover,
              ),
            )
          : const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white,
                ],
              ),
            ),
      child: Padding(
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 20),
        child: child,
      ),
    );

    if (safeArea) {
      content = SafeArea(child: content);
    }

    return content;
  }
}
