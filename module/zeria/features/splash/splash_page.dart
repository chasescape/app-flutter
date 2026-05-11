import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:zeria/gen_a/A.dart';
import 'package:zeria/zeria/interface.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_routes.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Keep splash fast; we only use it as a routing bridge.
    await Future.delayed(const Duration(milliseconds: 150));
    if (!mounted) return;

    if (Interface().authToken != null) {
      context.go(AppRoutes.main);
    } else {
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Image.asset(
        A.assets_zeria_open,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: AppColors.brandBlush,
            alignment: Alignment.center,
            child: Text(
              'open.png failed to load',
              style: AppTextStyles.bodyBold.copyWith(
                color: AppColors.brandInk,
              ),
            ),
          );
        },
      ),
    );
  }
}
