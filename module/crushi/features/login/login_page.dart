import 'package:flutter/material.dart';
import 'package:crushi/crushi/core/theme/app_theme.dart';
import 'package:crushi/crushi/core/widgets/pulse_animation.dart';
import 'package:crushi/crushi/core/router/global_router.dart';
import 'package:crushi/crushi/env/app_env.dart';
import 'package:crushi/crushi/interface.dart';
import 'dart:io';
import 'dart:ui';

import 'package:permission_handler/permission_handler.dart';
import 'package:crushi/gen_a/A.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  bool _agreed = false;

  Future<void> _handleEnter() async {
    if (!_agreed) {
      _showAgreementDialog();
      return;
    }

    await _startLoginFlow();
  }

  void _showAgreementDialog() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.65),
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(AppRadius.xl),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryMain.withOpacity(0.10),
                    blurRadius: 26,
                    spreadRadius: -10,
                  ),
                  BoxShadow(
                    color: Colors.white.withOpacity(0.04),
                    blurRadius: 18,
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.16),
                      ),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      color: AppColors.primaryMain,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Before you continue',
                      style: AppTypography.h3.copyWith(
                        color: AppColors.textInverse,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Please review and agree to our Terms of Service and Privacy Policy.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textInverse.withOpacity(0.75),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          foregroundColor:
                              AppColors.textInverse.withOpacity(0.85),
                          backgroundColor: Colors.white.withOpacity(0.08),
                          side: BorderSide(color: Colors.white.withOpacity(0.16)),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          if (mounted) {
                            setState(() => _agreed = true);
                            await _requestPrivacyPromptIfNeeded();
                            await _startLoginFlow();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryMain,
                          foregroundColor: AppColors.textPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                        ),
                        child: const Text('Agree'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _requestPrivacyPromptIfNeeded() async {
    if (!Platform.isIOS) return;

    final status = await Permission.appTrackingTransparency.status;
    if (status.isGranted || status.isLimited || status.isRestricted) return;

    await Permission.appTrackingTransparency.request();
  }

  Future<void> _startLoginFlow() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    Interface().authToken = 'mock_token';

    if (mounted) {
      setState(() => _isLoading = false);
      GlobalRouter.I.goToHome();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            A.assets_crushi_open,
            fit: BoxFit.cover,
          ),
          SafeArea(
            child: Column(
              children: [
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
                child: PulseAnimation(
                  minScale: 0.96,
                  maxScale: 1.02,
                  duration: const Duration(milliseconds: 1800),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleEnter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryMain,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.textPrimary,
                              ),
                            )
                          : const Text(
                              "Let's Go",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                                fontFamily: AppTypography.fontFamily,
                              ),
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Agreement checkbox
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Center(
                  child: Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    alignment: WrapAlignment.center,
                    runAlignment: WrapAlignment.center,
                    spacing: 0,
                    runSpacing: 4,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: Checkbox(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                          activeColor: AppColors.primaryMain,
                          side: const BorderSide(color: AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'I agree to the ',
                        style: AppTypography.small.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                      InkWell(
                        onTap: () => _openAgreement('Terms of Service'),
                        child: Text(
                          'Terms of Service',
                        style: AppTypography.small.copyWith(
                          color: AppColors.primaryMain,
                        ),
                      ),
                    ),
                      Text(
                        ' and ',
                        style: AppTypography.small.copyWith(
                          color: AppColors.textPrimary.withOpacity(0.6),
                        ),
                      ),
                      InkWell(
                        onTap: () => _openAgreement('Privacy Policy'),
                        child: Text(
                          'Privacy Policy',
                        style: AppTypography.small.copyWith(
                          color: AppColors.primaryMain,
                        ),
                      ),
                    ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAgreement(String title) {
    final env = AppEnv();
    final url =
        title == 'Terms of Service' ? env.h5User : env.h5Privacy;
    GlobalRouter.I.goToAgreement(url: url, title: title);
  }
}
