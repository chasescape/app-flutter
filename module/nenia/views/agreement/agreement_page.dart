import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../env/app_env.dart';
import '../../routes/app_pages.dart';
import '../../widgets/common/soft_ui.dart';

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

  String get _title => _agreementType.displayName;

  String get _url {
    final args = Get.arguments as Map<String, dynamic>?;
    final passedUrl = args?['url'] as String?;
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
    final args = Get.arguments as Map<String, dynamic>?;
    final title = args?['title'] as String? ?? '';
    if (title.toLowerCase().contains('privacy')) {
      return AgreementType.privacy;
    }
    return AgreementType.user;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              children: [
                NeniaInlineHeader(
                  title: _title,
                  subtitle:
                      'Presented inside the same softened card container for visual consistency.',
                  onBack: Routes.back,
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: NeniaSurface(
                    padding: const EdgeInsets.all(10),
                    radius: 32,
                    child: ClipRRect(
                      borderRadius: AppBorderRadius.allXl,
                      child: Stack(
                        children: [
                          InAppWebView(
                            initialUrlRequest: URLRequest(url: WebUri(_url)),
                            initialSettings:
                                InAppWebViewSettings(javaScriptEnabled: true),
                            onLoadStart: (_, __) {
                              setState(() {
                                _isLoading = true;
                                _error = null;
                              });
                            },
                            onLoadStop: (_, __) {
                              setState(() {
                                _isLoading = false;
                              });
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
                              color: AppColors.surfacePrimary,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.secondaryMain),
                                ),
                              ),
                            ),
                          if (_error != null)
                            Container(
                              color: AppColors.surfacePrimary,
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.error_outline_rounded,
                                        size: 48, color: AppColors.error),
                                    const SizedBox(height: 14),
                                    const Text('Unable to load page',
                                        style: AppTextStyles.h3),
                                    const SizedBox(height: 8),
                                    Text(_error!,
                                        style: AppTextStyles.caption,
                                        textAlign: TextAlign.center),
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
      ),
    );
  }
}
