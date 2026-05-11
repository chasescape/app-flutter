import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tavia/tavia/env/app_env.dart';

import '../../core/router/app_routes.dart';
import '../../core/state/state_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/dialog_widget.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../interface.dart';
import '../../shared/constants/app_constants.dart';
import '../../shared/models/user_model.dart';

/// Login page rebuilt to closely match the supplied splash reference.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _agreedToTerms = false;
  bool _attRequested = false;
  late final TapGestureRecognizer _termsRecognizer;
  late final TapGestureRecognizer _privacyRecognizer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _termsRecognizer = TapGestureRecognizer()
      ..onTap = () => _showAgreement('Terms of Service');
    _privacyRecognizer = TapGestureRecognizer()
      ..onTap = () => _showAgreement('Privacy Policy');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestTrackingIfNeeded(delayMs: 500);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestTrackingIfNeeded();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spacingLg,
              vertical: AppConstants.spacingLg,
            ),
            child: Column(
              children: [
                const SizedBox(height: 24),
                const Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TaviaLogoLockup(),
                      ],
                    ),
                  ),
                ),
                _buildActionButton(),
                const SizedBox(height: AppConstants.spacingLg),
                _buildAgreementSection(),
                const SizedBox(height: AppConstants.spacingSm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAgreementSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Transform.scale(
          scale: 0.92,
          child: Checkbox(
            value: _agreedToTerms,
            side: BorderSide(
              color: AppColors.white.withValues(alpha: 0.7),
            ),
            onChanged: (value) {
              setState(() {
                _agreedToTerms = value ?? false;
              });
            },
            fillColor: WidgetStateProperty.resolveWith((states) {
              return states.contains(WidgetState.selected)
                  ? AppColors.white
                  : AppColors.white.withValues(alpha: 0.22);
            }),
            checkColor: AppColors.primaryMain,
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 9),
            child: Text.rich(
              TextSpan(
                style: AppTextStyles.small.copyWith(
                  color: AppColors.white.withValues(alpha: 0.74),
                ),
                children: [
                  const TextSpan(
                    text: 'By tapping Sign in and using Tavia, you agree to our ',
                  ),
                  TextSpan(
                    text: 'Terms',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: _termsRecognizer,
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: AppTextStyles.small.copyWith(
                      color: AppColors.white,
                      decoration: TextDecoration.underline,
                      fontWeight: FontWeight.w700,
                    ),
                    recognizer: _privacyRecognizer,
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: TaviaPrimaryButton(
        label: _isLoading ? 'Signing in...' : "Let's go",
        onPressed: !_isLoading ? _handleLogin : null,
      ),
    );
  }

  Future<void> _handleLogin() async {
    await _requestTrackingIfNeeded();

    if (!_agreedToTerms) {
      final agreed = await _showAgreementWarning();
      if (!agreed) {
        return;
      }
      if (mounted) {
        setState(() {
          _agreedToTerms = true;
        });
      }
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) {
      return;
    }

    Interface().authToken = 'mock_token';
    final state = StateProvider.of(context);
    final user = UserModel.mock();
    state.setUser(user);
    if (!Interface.prefs.containsKey('coin_balance')) {
      state.setCoinBalance(user.coinBalance ?? 100);
    }
    context.go(AppRoutes.home);
  }

  Future<void> _requestTrackingIfNeeded({int delayMs = 0}) async {
    if (!mounted || _attRequested || !Platform.isIOS) {
      return;
    }

    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
      if (!mounted) {
        return;
      }
    }

    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('[ATT] current status: $status');

      if (status == TrackingStatus.notDetermined) {
        status =
            await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('[ATT] status after request: $status');
      }

      _attRequested = status != TrackingStatus.notDetermined;
    } catch (error) {
      debugPrint('[ATT] request failed: $error');
      _attRequested = false;
    }
  }

  void _showAgreement(String title) {
    final url =
        title == 'Terms of Service' ? AppEnv().h5User : AppEnv().h5Privacy;

    context.push(
      '${AppRoutes.agreement}?${AppRoutes.paramTitle}=$title&${AppRoutes.paramUrl}=$url',
    );
  }

  Future<bool> _showAgreementWarning() async {
    final result = await AppDialog.showGlassDialog<bool>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primaryMain.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.verified_user_outlined,
                  color: AppColors.primaryMain,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Agree to continue',
                  style: AppTextStyles.h3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Please review and accept the Terms of Service and Privacy Policy to enter Tavia.',
            style: AppTextStyles.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Not now'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TaviaPrimaryButton(
                  label: 'I Agree',
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
