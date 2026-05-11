import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/pink_ui.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late final WebViewController _controller;
  late final String _title;
  late final String _url;
  bool _isLoading = true;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _title = args['title'] as String;
    _url = args['url'] as String;

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0;
            });
          },
          onProgress: (progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageFinished: (_) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_url));
  }

  @override
  Widget build(BuildContext context) {
    return PinkPageScaffold(
      leading: PinkBackButton(onTap: AppRoutes.back),
      title: _title,
      centerTitle: true,
      child: Column(
        children: [
          if (_isLoading)
            Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: _loadingProgress,
                  minHeight: 6,
                  backgroundColor: AppTheme.secondaryLight,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppTheme.primaryMain),
                ),
              ),
            ),
          Expanded(
            child: PinkGlassCard(
              padding: EdgeInsets.zero,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                child: WebViewWidget(controller: _controller),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
