import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:enkou/gen_a/A.dart';

class LoadingOverlay {
  LoadingOverlay._();

  static bool _showing = false;
  static bool _pendingHide = false;
  static BuildContext? _dialogContext;

  static void show() {
    if (_showing) return;
    _showing = true;
    _pendingHide = false;
    _dialogContext = null;
    Get.dialog(
      Builder(
        builder: (context) {
          _dialogContext = context;
          return const _LoadingDialog();
        },
      ),
      barrierDismissible: false,
      barrierColor: const Color(0x66000000),
    );
    // 如果在 dialog 真正弹出前就调用了 hide()，下一帧补一次关闭。
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_pendingHide) {
        hide();
      }
    });
  }

  static void hide() {
    if (!_showing) {
      _pendingHide = true;
      return;
    }

    final ctx = _dialogContext;
    if (ctx != null) {
      final nav = Navigator.of(ctx, rootNavigator: true);
      if (nav.canPop()) {
        nav.pop();
        _showing = false;
        _pendingHide = false;
        _dialogContext = null;
        return;
      }
    }

    // dialog 尚未打开（或刚好在路由切换），延迟到下一帧再尝试关闭。
    _pendingHide = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_pendingHide) return;
      final ctx2 = _dialogContext;
      if (ctx2 != null) {
        final nav = Navigator.of(ctx2, rootNavigator: true);
        if (nav.canPop()) {
          nav.pop();
        }
      } else if (Get.isDialogOpen == true) {
        // fallback：尽量关闭顶层 dialog，避免卡死
        Get.back<void>();
      }
      _showing = false;
      _pendingHide = false;
      _dialogContext = null;
    });
  }
}

class _LoadingDialog extends StatelessWidget {
  const _LoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Lottie.asset(
          A.assets_loading_loading,
          width: 180,
          height: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
