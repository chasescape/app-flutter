import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import '../../app/theme/theme.dart';
import '../../router/app_router.dart';
import '../../router/app_router_extension.dart';
import '../../widgets/visuals/sunny_visuals.dart';
import '../../interface.dart';
import '../../env/app_env.dart';
import '../../../gen_a/A.dart';

/// Login Page - Fixed Pattern
/// Full-screen background with single "Let us go" button
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Global key to access agreement checkbox state
  final GlobalKey<_AgreementSectionState> _agreementKey =
      GlobalKey<_AgreementSectionState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              A.assets_cheria_open,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                // Fallback gradient if image not found
                return Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(AppColors.secondaryDark),
                        Color(AppColors.backgroundSecondary),
                        Color(AppColors.backgroundPrimary),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(AppColors.textInverse).withOpacity(0.08),
                    const Color(AppColors.backgroundPrimary).withOpacity(0.04),
                    const Color(AppColors.backgroundPrimary).withOpacity(0.2),
                  ],
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xl,
                vertical: AppSpacing.lg,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Spacer(),
                  const SizedBox(height: AppSpacing.lg),

                  // Login Button
                  _LoginButton(
                    onPressed: () => _handleLogin(context),
                  ),

                  // Agreement Checkbox and Links
                  const SizedBox(height: 24),
                  _AgreementSection(key: _agreementKey),

                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin(BuildContext context) async {
    // 1. 检查协议是否已勾选
    final agreed = _agreementKey.currentState?._agreed ?? false;
    if (!agreed) {
      // 显示协议确认弹窗
      final confirmed = await _showAgreementDialog(context);
      if (!confirmed) return;
    }

    // 2. 显示全局 loading
    SmartDialog.showLoading(
      msg: 'Loading...',
      backType: SmartBackType.normal,
    );

    try {
      // 3. 调用 Interface().doSignInAction() 进行登录
      await Interface().doSignInAction();

      // 4. 登录成功，跳转首页
      if (context.mounted) {
        SmartDialog.dismiss();
        context.go(AppRoutes.home);
      }
    } catch (e) {
      // 登录失败，关闭 loading 并显示错误
      SmartDialog.dismiss();
      SmartDialog.showToast('Login failed, please try again');
    }
  }

  Future<bool> _showAgreementDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Agreement Required'),
            content: const Text(
              'Please agree to the Terms of Service and Privacy Policy to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Agree'),
              ),
            ],
          ),
        ) ??
        false;
  }
}

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppColors.buttonPrimary),
          foregroundColor: const Color(AppColors.textInverse),
          shape: RoundedRectangleBorder(
            borderRadius: AppBorderRadius.allMD,
          ),
          elevation: 0,
        ),
        child: Text(
          'Let us go',
          style: AppTypography.getH3TextStyle(
            const Color(AppColors.textInverse),
          ).copyWith(
            fontWeight: AppTypography.bold,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

class _AgreementSection extends StatefulWidget {
  const _AgreementSection({super.key});

  @override
  State<_AgreementSection> createState() => _AgreementSectionState();
}

class _AgreementSectionState extends State<_AgreementSection> {
  bool _agreed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreed,
            onChanged: (value) {
              setState(() {
                _agreed = value ?? false;
              });
            },
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return const Color(AppColors.primaryMain);
              }
              return Colors.transparent;
            }),
            side: const BorderSide(
              color: Color(AppColors.textSecondary),
              width: 1.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Wrap(
            spacing: 4,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(
                'I agree to the ',
                style: AppTypography.getCaptionTextStyle(
                  const Color(AppColors.textSecondary),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.toAgreement('Terms of Service', AppEnv().h5User);
                },
                child: Text(
                  'Terms of Service',
                  style: AppTypography.getCaptionTextStyle(
                    const Color(AppColors.primaryMain),
                  ).copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' and ',
                style: AppTypography.getCaptionTextStyle(
                  const Color(AppColors.textSecondary),
                ),
              ),
              GestureDetector(
                onTap: () {
                  context.toAgreement('Privacy Policy', AppEnv().h5Privacy);
                },
                child: Text(
                  'Privacy Policy',
                  style: AppTypography.getCaptionTextStyle(
                    const Color(AppColors.primaryMain),
                  ).copyWith(
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
