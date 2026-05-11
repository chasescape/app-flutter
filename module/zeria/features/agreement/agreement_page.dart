import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:zeria/zeria/constants/app_colors.dart';
import 'package:zeria/zeria/constants/app_text_styles.dart';
import 'package:zeria/zeria/widgets/zeria_ui.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return ZeriaScreen(
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: ZeriaHeader(
                title: widget.title,
                subtitle: 'IN-APP READING',
                leading: ZeriaIconButton(
                  icon: Icons.arrow_back_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                child: ZeriaSurfaceCard(
                  padding: EdgeInsets.zero,
                  radius: 34,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(33),
                    child: Stack(
                      children: [
                        InAppWebView(
                          initialUrlRequest:
                              URLRequest(url: WebUri(widget.url)),
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
                          onReceivedError: (controller, request, error) {
                            setState(() {
                              _isLoading = false;
                              _error = error.description;
                            });
                          },
                        ),
                        if (_isLoading)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: AppColors.surfaceStrong,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),
                        if (_error != null)
                          Positioned.fill(
                            child: ColoredBox(
                              color: AppColors.surfaceStrong,
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.error_outline_rounded,
                                        size: 48,
                                        color: AppColors.error,
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        'Unable to load',
                                        style: AppTextStyles.h3,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        _error!,
                                        textAlign: TextAlign.center,
                                        style: AppTextStyles.body.copyWith(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
