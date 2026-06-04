import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../gen_a/A.dart';
import '../../interface.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreedToTerms = false;

  void _handleGetStarted() async {
    if (!_agreedToTerms) {
      _showAgreementDialog();
      return;
    }
    await _enterHome();
  }

  Future<void> _enterHome() async {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: GlidoSurface(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor:
                      AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 1));
    Interface().authToken = 'mock_token';

    if (mounted) {
      Navigator.of(context).pop();
      context.go(AppRoutes.home);
    }
  }

  void _showAgreementDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Agree to continue'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Please agree to the Terms of Service and Privacy Policy before entering Glido.',
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(dialogContext),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      Navigator.pop(dialogContext);
                      if (!mounted) return;
                      setState(() => _agreedToTerms = true);
                      await _enterHome();
                    },
                    child: const Text('Agree'),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              A.assets_glido_open,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.02),
                    AppTheme.bgPrimary.withValues(alpha: 0.82),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingLg,
                AppTheme.spacingXl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  GlidoSurface(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _handleGetStarted,
                            child: const Text('Enter Glido'),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () => setState(
                                () => _agreedToTerms = !_agreedToTerms,
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 2, right: 8),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 180),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: _agreedToTerms
                                        ? AppTheme.primaryMain
                                        : Colors.white.withValues(alpha: 0.92),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: _agreedToTerms
                                          ? AppTheme.primaryDark
                                          : AppTheme.ink.withValues(
                                              alpha: 0.18,
                                            ),
                                    ),
                                  ),
                                  child: _agreedToTerms
                                      ? const Icon(
                                          Icons.check_rounded,
                                          size: 14,
                                          color: AppTheme.textPrimary,
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Wrap(
                                spacing: 0,
                                runSpacing: 0,
                                children: [
                                  Text(
                                    'By continuing, you agree to our ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: () => AppRoutes.toAgreement(
                                      context,
                                      'Terms of Service',
                                      Interface().h5User,
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Terms'),
                                  ),
                                  Text(
                                    ' and ',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                  ),
                                  TextButton(
                                    onPressed: () => AppRoutes.toAgreement(
                                      context,
                                      'Privacy Policy',
                                      Interface().h5Privacy,
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize:
                                          MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text('Privacy'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
