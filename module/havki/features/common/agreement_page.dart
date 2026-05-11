import 'package:flutter/material.dart';
import 'package:havki/havki/app/theme/app_theme.dart';
import 'package:webview_flutter/webview_flutter.dart';

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
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _errorMessage = null;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (_) => setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to load content. Please try again.';
          }),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.sm,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AppCircleIconButton(
                  icon: Icons.arrow_back_ios_new_rounded,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: AppSectionTitle(
                    eyebrow: '',
                    title: widget.title,
                    subtitle: '',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: AppGlassCard(
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  child: Stack(
                    children: [
                      if (_errorMessage != null)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.lg),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.error_outline, size: 48, color: AppColors.textSecondary),
                                const SizedBox(height: AppSpacing.md),
                                Text(_errorMessage!, textAlign: TextAlign.center),
                                const SizedBox(height: AppSpacing.md),
                                ElevatedButton(onPressed: _initializeWebView, child: const Text('Retry')),
                              ],
                            ),
                          ),
                        )
                      else
                        WebViewWidget(controller: _controller),
                      if (_isLoading) const Center(child: CircularProgressIndicator()),
                    ],
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
