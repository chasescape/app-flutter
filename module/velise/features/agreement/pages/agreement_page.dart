import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/velise_ui.dart';
import '../../../env/app_env.dart';
import '../../../routes/app_pages.dart';

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
  late final AgreementType _agreementType;
  bool _isLoading = true;
  String? _error;

  String get _url {
    final passedUrl = AppRoutes.getAgreementUrl();
    if (passedUrl != null && passedUrl.isNotEmpty) {
      return passedUrl;
    }

    final appEnv = AppEnv();
    switch (_agreementType) {
      case AgreementType.user:
        return appEnv.h5User;
      case AgreementType.privacy:
        return appEnv.h5Privacy;
    }
  }

  @override
  void initState() {
    super.initState();
    _agreementType = _parseAgreementType();
  }

  AgreementType _parseAgreementType() {
    final title = AppRoutes.getAgreementTitle() ?? '';
    if (title.toLowerCase().contains('privacy')) {
      return AgreementType.privacy;
    }
    return AgreementType.user;
  }

  @override
  Widget build(BuildContext context) {
    return VeliseScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              Expanded(
                child: VeliseSurfaceCard(
                  light: true,
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: InAppWebView(
                            initialUrlRequest: URLRequest(url: WebUri(_url)),
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                            ),
                            onLoadStart: (controller, url) {
                              setState(() {
                                _isLoading = true;
                                _error = null;
                              });
                            },
                            onLoadStop: (controller, url) {
                              setState(() {
                                _isLoading = false;
                              });
                            },
                            onLoadError: (controller, url, code, message) {
                              setState(() {
                                _isLoading = false;
                                _error = message;
                              });
                            },
                          ),
                        ),
                        if (_isLoading)
                          Positioned.fill(
                            child: Container(
                              color: AppColors.surfacePrimary,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppColors.primaryMain,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        if (_error != null)
                          Positioned.fill(
                            child: Container(
                              color: AppColors.surfacePrimary,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: AppColors.textOnSurfaceSoft,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Unable to load this page',
                                    style: AppTextStyles.surfaceTitleStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _error!,
                                    style: AppTextStyles.surfaceBodyStyle,
                                    textAlign: TextAlign.center,
                                  ),
                                ],
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
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final headerTitle =
        _agreementType == AgreementType.privacy ? 'privacy' : 'terms';

    return SizedBox(
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: VeliseActionButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: Get.back,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 96),
              child: Text(
                headerTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h3Style.copyWith(
                  fontWeight: AppTextStyles.semibold,
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: VelisePill(
              label: _agreementType == AgreementType.privacy
                  ? 'Privacy'
                  : 'Terms',
              icon: Icons.lock_outline_rounded,
            ),
          ),
        ],
      ),
    );
  }
}
