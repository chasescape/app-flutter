import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/tavia_ui.dart';
import '../../shared/constants/app_constants.dart';

/// Agreement page wrapped in the shared visual frame.
class AgreementPage extends StatefulWidget {
  final String title;
  final String url;

  const AgreementPage({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _progress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _progress = 0;
          }),
          onProgress: (value) => setState(() => _progress = value),
          onPageFinished: (_) => setState(() {
            _isLoading = false;
            _progress = 100;
          }),
          onWebResourceError: (_) => setState(() => _isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: TaviaBackground(
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingLg,
              AppConstants.spacingMd,
              AppConstants.spacingLg,
              AppConstants.spacingXxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    TaviaIconButton(
                      icon: Icons.arrow_back_ios_new,
                      onTap: () => Navigator.of(context).pop(),
                    ),
                    const SizedBox(width: AppConstants.spacingMd),
                    Expanded(
                      child: TaviaSectionTitle(
                        title: widget.title,
                        subtitle:
                            'Presented inside the same soft visual shell.',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.spacingLg),
                Expanded(
                  child: TaviaPanel(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: WebViewWidget(controller: _controller),
                          ),
                          if (_isLoading)
                            Positioned(
                              left: 0,
                              right: 0,
                              top: 0,
                              child: LinearProgressIndicator(
                                value: _progress / 100,
                                minHeight: 4,
                                backgroundColor: AppColors.surfaceTint,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_isLoading) ...[
                  const SizedBox(height: AppConstants.spacingMd),
                  Text(
                    'Loading $_progress%',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.white,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
