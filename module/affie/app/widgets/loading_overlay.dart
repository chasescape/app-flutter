import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:affie/gen_a/A.dart';

class LoadingOverlay {
  static OverlayEntry? _entry;

  static void show({String? message}) {
    if (_entry != null) return;
    final overlayContext = Get.overlayContext;
    if (overlayContext == null) return;
    final overlay = Overlay.of(overlayContext, rootOverlay: true);

    _entry = OverlayEntry(
      builder: (context) => const _LoadingOverlayLayer(),
    );
    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}

class _LoadingOverlayLayer extends StatelessWidget {
  const _LoadingOverlayLayer();

  @override
  Widget build(BuildContext context) {
    return const Positioned.fill(
      child: ColoredBox(
        color: Color(0x66000000),
        child: Center(child: _LoadingContent()),
      ),
    );
  }
}

class _LoadingContent extends StatelessWidget {
  const _LoadingContent();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 140,
      child: Lottie.asset(
        A.assets_loading_loading,
        fit: BoxFit.contain,
      ),
    );
  }
}
