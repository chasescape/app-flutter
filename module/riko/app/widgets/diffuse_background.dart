import 'package:flutter/widgets.dart';

class DiffuseBackground extends StatelessWidget {
  final Widget? child;

  const DiffuseBackground({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const _BaseGradient(),
        const _Blob(
          alignment: Alignment(-0.9, -0.8),
          size: 560,
          colorStart: Color(0x99FCAEC1),
          colorEnd: Color(0x00FCAEC1),
        ),
        const _Blob(
          alignment: Alignment(0.9, -0.6),
          size: 520,
          colorStart: Color(0x99FCD1DB),
          colorEnd: Color(0x00FCD1DB),
        ),
        const _Blob(
          alignment: Alignment(0.7, 0.8),
          size: 560,
          colorStart: Color(0x88B7A8D6),
          colorEnd: Color(0x00B7A8D6),
        ),
        const _Blob(
          alignment: Alignment(-0.6, 0.7),
          size: 480,
          colorStart: Color(0x88ADD9F3),
          colorEnd: Color(0x00ADD9F3),
        ),
        if (child != null) child!,
      ],
    );
  }
}

class _BaseGradient extends StatelessWidget {
  const _BaseGradient();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF7EFF5),
            Color(0xFFF2E8F2),
            Color(0xFFF6EEF7),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Alignment alignment;
  final double size;
  final Color colorStart;
  final Color colorEnd;

  const _Blob({
    required this.alignment,
    required this.size,
    required this.colorStart,
    required this.colorEnd,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [colorStart, colorEnd],
              stops: [0.0, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}
