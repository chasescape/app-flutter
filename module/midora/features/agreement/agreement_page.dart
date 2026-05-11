import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/midora_design.dart';
import '../../core/widgets/midora_open_background.dart';
import '../../env/app_env.dart';

enum AgreementType {
  user,
  privacy;

  String get displayName {
    switch (this) {
      case AgreementType.user:
        return 'Terms of Service';
      case AgreementType.privacy:
        return 'Privacy Policy';
    }
  }
}

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _isLoading = true;
  String? _error;

  AgreementType _agreementType(BuildContext context) {
    final title = AppRoutes.getAgreementTitle(context) ?? '';
    return title.toLowerCase().contains('privacy')
        ? AgreementType.privacy
        : AgreementType.user;
  }

  String _url(BuildContext context) {
    final passedUrl = AppRoutes.getAgreementUrl(context);
    if (passedUrl != null && passedUrl.isNotEmpty) {
      return passedUrl;
    }

    final env = AppEnv();
    return _agreementType(context) == AgreementType.privacy
        ? env.h5Privacy
        : env.h5User;
  }

  @override
  Widget build(BuildContext context) {
    final agreementType = _agreementType(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const MidoraOpenBackground(overlayOpacity: 0.26),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.xl,
              ),
              child: Column(
                children: [
                  MidoraTopBar(
                    title: agreementType.displayName,
                    subtitle:
                        'Displayed in a calmer reading shell for better consistency.',
                    leading: MidoraCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Expanded(
                    child: MidoraGlassCard(
                      padding: EdgeInsets.zero,
                      borderRadius: AppBorderRadius.borderRadiusXl,
                      blur: 0,
                      // Opaque "reading shell" for legibility.
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFFDFBFF),
                          Color(0xFFF6F2FF),
                        ],
                      ),
                      borderColor: const Color(0x26FFFFFF),
                      child: ClipRRect(
                        borderRadius: AppBorderRadius.borderRadiusXl,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            InAppWebView(
                              initialUrlRequest:
                                  URLRequest(url: WebUri(_url(context))),
                              initialSettings: InAppWebViewSettings(
                                javaScriptEnabled: true,
                                transparentBackground: false,
                              ),
                              onLoadStart: (_, __) {
                                setState(() {
                                  _isLoading = true;
                                  _error = null;
                                });
                              },
                              onLoadStop: (_, __) {
                                setState(() => _isLoading = false);
                              },
                              onReceivedError: (_, __, error) {
                                setState(() {
                                  _isLoading = false;
                                  _error = error.description;
                                });
                              },
                            ),
                            if (_isLoading)
                              Container(
                                color: Colors.white.withValues(alpha: 0.92),
                                alignment: Alignment.center,
                                child: const CircularProgressIndicator(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                            if (_error != null)
                              Container(
                                color: Colors.white.withValues(alpha: 0.96),
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Unable to load this page',
                                      style: AppTextStyles.h3.copyWith(
                                        color: AppColors.backgroundPrimary,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: AppSpacing.sm),
                                    Text(
                                      _error!,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.backgroundPrimary
                                            .withValues(alpha: 0.70),
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
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
