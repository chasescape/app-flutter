import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tanie/gen_a/A.dart';
import 'package:tanie/tanie/bloc/auth/auth_bloc.dart';
import 'package:tanie/tanie/bloc/auth/auth_event.dart';
import 'package:tanie/tanie/bloc/auth/auth_state.dart';
import 'package:tanie/tanie/env/app_env.dart';
import 'package:tanie/tanie/routes/app_routes.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _hasAgreed = false;

  void _toggleAgreement() {
    setState(() => _hasAgreed = !_hasAgreed);
  }

  void _handleEnter() {
    if (_hasAgreed) {
      context.read<AuthBloc>().add(const LoginEvent());
      return;
    }

    _showAgreementDialog();
  }

  void _showAgreementDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Agreement Required'),
          content: const Text(
            'Please agree to the Terms & Conditions and Privacy Policy before entering.',
            style: AppTextStyles.bodyMedium,
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            SizedBox(
              width: double.infinity,
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => dialogContext.pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        dialogContext.pop();
                        setState(() => _hasAgreed = true);
                        context.read<AuthBloc>().add(const LoginEvent());
                      },
                      child: const Text('Agree'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _openTerms() {
    AppRoutes.toAgreement(
      context,
      'Terms & Conditions',
      AppEnv().h5User.isNotEmpty
          ? AppEnv().h5User
          : 'https://example.com/terms',
    );
  }

  void _openPrivacy() {
    AppRoutes.toAgreement(
      context,
      'Privacy Policy',
      AppEnv().h5Privacy.isNotEmpty
          ? AppEnv().h5Privacy
          : 'https://example.com/privacy',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated && !state.isLoading) {
          context.go(AppRoutes.home);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                A.assets_tanie_TanieoOpen,
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(28, 20, 28, 18),
                child: BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return Column(
                      children: [
                        const Spacer(flex: 6),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryDark.withValues(
                                    alpha: 0.18,
                                  ),
                                  blurRadius: 18,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: state.isLoading ? null : _handleEnter,
                                child: Center(
                                  child: state.isLoading
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              AppColors.white,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          'Explore now',
                                          style: AppTextStyles.buttonPrimary
                                              .copyWith(
                                            fontSize: 17,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: _toggleAgreement,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: _hasAgreed
                                          ? AppColors.primaryDark
                                          : Colors.transparent,
                                      border: Border.all(
                                        color: AppColors.primaryDark,
                                        width: 1.4,
                                      ),
                                    ),
                                    child: _hasAgreed
                                        ? const Icon(
                                            Icons.check,
                                            size: 10,
                                            color: AppColors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'By using App you agree with our ',
                                      style: AppTextStyles.small.copyWith(
                                        color: AppColors.primaryDark.withValues(
                                          alpha: 0.82,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        height: 1.45,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _openTerms,
                                      child: Text(
                                        'Terms & Conditions',
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      ' and ',
                                      style: AppTextStyles.small.copyWith(
                                        color: AppColors.primaryDark.withValues(
                                          alpha: 0.82,
                                        ),
                                        fontWeight: FontWeight.w500,
                                        height: 1.45,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: _openPrivacy,
                                      child: Text(
                                        'Privacy Policy.',
                                        style: AppTextStyles.small.copyWith(
                                          color: AppColors.primaryDark,
                                          fontWeight: FontWeight.w700,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
