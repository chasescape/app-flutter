import 'package:flutter/material.dart';
import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../interface.dart';
import '../../env/app_env.dart';
import '../../app/theme/app_spacing.dart';
import '../../app/router/app_routes.dart';
import '../../app/router/app_router.dart';
import '../../../gen_a/A.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with WidgetsBindingObserver {
  bool _isLoading = false;
  bool _agreed = false;
  bool _attRequested = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _requestTrackingIfNeeded(delayMs: 500);
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestTrackingIfNeeded();
    }
  }

  Future<void> _requestTrackingIfNeeded({int delayMs = 0}) async {
    if (!mounted || _attRequested || !Platform.isIOS) return;
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
      if (!mounted) return;
    }
    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      debugPrint('[ATT] current status: $status');

      if (status == TrackingStatus.notDetermined) {
        status = await AppTrackingTransparency.requestTrackingAuthorization();
        debugPrint('[ATT] status after request: $status');
      }

      // 只有状态明确后才标记完成；仍未确定则允许后续继续尝试
      _attRequested = status != TrackingStatus.notDetermined;
    } catch (e) {
      debugPrint('[ATT] request failed: $e');
      _attRequested = false;
    }
  }

  Future<void> _handleLogin() async {
    await _requestTrackingIfNeeded();

    if (!_agreed) {
      final shouldAgree = await showDialog<bool>(
        context: context,
        barrierDismissible: true,
        builder: (context) {
          return AlertDialog(
            title: const Text('Agreement required'),
            content: const Text('Please agree to the Terms & Conditions and Privacy Policy to continue.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Agree'),
              ),
            ],
          );
        },
      );

      if (shouldAgree != true) return;
      if (!mounted) return;
      setState(() => _agreed = true);
    }

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    Interface().authToken = 'mock_token';
    setState(() => _isLoading = false);

    context.go(AppRoutes.main);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen background image (no-logo version)
          Positioned.fill(
            child: Image.asset(
              A.assets_halee_HaleeOpen,
              fit: BoxFit.cover,
            ),
          ),
          // Soft color overlay for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withValues(alpha: 0.12),
                    const Color(0xFFB35CFF).withValues(alpha: 0.08),
                    const Color(0xFFFF7A59).withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  // Primary CTA
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF111111),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(0xFF111111).withValues(alpha: 0.5),
                        disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Explore now',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Agreement line
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 22,
                        height: 22,
                        child: Checkbox(
                          value: _agreed,
                          onChanged: (v) => setState(() => _agreed = v ?? false),
                          shape: const CircleBorder(),
                          activeColor: const Color(0xFF111111),
                          checkColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF2B2B2B), width: 1),
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DefaultTextStyle(
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF2B2B2B),
                                    height: 1.2,
                                  ) ??
                              const TextStyle(color: Color(0xFF2B2B2B), fontSize: 12),
                          child: Text.rich(
                            TextSpan(
                              text: 'By using App you agree with our ',
                              children: [
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => AppRouter.toAgreement(
                                      context,
                                      'Terms & Conditions',
                                      AppEnv().h5User,
                                    ),
                                    child: const Text(
                                      'Terms & Conditions',
                                      style: TextStyle(
                                        color: Color(0xFF111111),
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                WidgetSpan(
                                  child: GestureDetector(
                                    onTap: () => AppRouter.toAgreement(
                                      context,
                                      'Privacy Policy',
                                      AppEnv().h5Privacy,
                                    ),
                                    child: const Text(
                                      'Privacy Policy',
                                      style: TextStyle(
                                        color: Color(0xFF111111),
                                        decoration: TextDecoration.underline,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
