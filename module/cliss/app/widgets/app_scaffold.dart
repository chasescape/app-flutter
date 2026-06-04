import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final bool safeTop;
  final bool safeBottom;
  final EdgeInsetsGeometry? padding;

  const AppScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.safeTop = true,
    this.safeBottom = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget body = Container(
      decoration: const BoxDecoration(
        gradient: AppGradients.appBackground,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppGradients.mintGlow,
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: AppGradients.pinkGlow,
              ),
            ),
          ),
          Positioned(
            right: -80,
            top: MediaQuery.of(context).size.height * 0.22,
            child: Container(
              width: 280,
              height: 280,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x48F7C1F1),
              ),
            ),
          ),
          Positioned(
            left: -90,
            top: -30,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x45B8FFF1),
              ),
            ),
          ),
          SafeArea(
            top: safeTop,
            bottom: safeBottom,
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      appBar: appBar,
      backgroundColor: Colors.transparent,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
