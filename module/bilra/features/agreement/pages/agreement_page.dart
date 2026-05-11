import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:bilra/bilra/routes/app_router.dart';
import 'package:bilra/bilra/theme/app_theme.dart';
import 'package:bilra/bilra/widgets/bilra_ui.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({
    super.key,
    required this.title,
    required this.url,
    this.returnTab,
  });

  final String title;
  final String url;
  final int? returnTab;

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: BilraBackdrop(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              BilraTopBar(
                title: widget.title,
                subtitle: 'Secure in-app view',
                leading: BilraIconChipButton(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => AppRoutes.pop(context),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.md,
                  ),
                  child: BilraGlassCard(
                    padding: EdgeInsets.zero,
                    radius: 30,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(30),
                          child: InAppWebView(
                            initialUrlRequest:
                                URLRequest(url: WebUri(widget.url)),
                            initialSettings: InAppWebViewSettings(
                              javaScriptEnabled: true,
                            ),
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
                        ),
                        if (_isLoading)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundOverlay,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            child: const Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryMain),
                                ),
                                SizedBox(height: AppSpacing.md),
                                Text('Loading content',
                                    style: AppTextStyles.body),
                              ],
                            ),
                          ),
                        if (_error != null)
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundOverlay,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.wifi_off_rounded,
                                  size: 42,
                                  color: AppColors.semanticError,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                const Text('Unable to load',
                                    style: AppTextStyles.h3),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  _error!,
                                  style: AppTextStyles.caption,
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
    );
  }
}
