import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/services/auth_service.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';

/// Splash Page - App launch screen
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Wait for services to initialize
    await Future.delayed(const Duration(seconds: 2));

    // Check login status
    final authService = Get.find<AuthService>();
    if (authService.isLoggedIn) {
      GlobalRouter.I.goToHome();
    } else {
      GlobalRouter.I.goToLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CandyBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: AppTheme.softSurfaceGradient,
                  shape: BoxShape.circle,
                  boxShadow: AppTheme.cardShadow,
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 64,
                  color: AppTheme.accentRed,
                ),
              ),
              const SizedBox(height: AppTheme.xl),

              // App Name
              Text(
                'AchieveNote',
                style: AppTheme.h1.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppTheme.sm),

              // Tagline
              Text(
                'Turn Photos Into Achievement Cards',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppTheme.xxl),

              // Loading Indicator
              const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentRed,
                  ),
                  strokeWidth: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
