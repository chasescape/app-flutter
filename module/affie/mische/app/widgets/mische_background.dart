import 'package:flutter/material.dart';

import '../../../gen_a/A.dart';

class MischeBackground extends StatelessWidget {
  const MischeBackground({super.key, required this.child});

  final Widget child;

  static String assetPath = A.assets_mische_bg;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(assetPath),
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
          ),
        ),
        child: child,
      ),
    );
  }
}
