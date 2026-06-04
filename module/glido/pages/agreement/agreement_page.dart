import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

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
  late final InAppWebViewController _webViewController;
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: GlidoPageBackground(
        topSafeArea: true,
        padding: const EdgeInsets.only(
          top: kToolbarHeight - AppTheme.spacingMd,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            0,
            AppTheme.spacingMd,
            AppTheme.spacingMd,
          ),
          child: GlidoSurface(
            padding: EdgeInsets.zero,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: InAppWebView(
                    initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                    initialSettings: InAppWebViewSettings(
                      useShouldOverrideUrlLoading: false,
                    ),
                    onWebViewCreated: (controller) {
                      _webViewController = controller;
                    },
                    onLoadStart: (_, __) {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                    },
                    onLoadStop: (_, __) {
                      setState(() {
                        _isLoading = false;
                        _error = null;
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
                    color: Colors.white.withValues(alpha: 0.9),
                    child: const Center(
                      child: _LoadingState(),
                    ),
                  ),
                if (_error != null)
                  Container(
                    color: Colors.white.withValues(alpha: 0.94),
                    padding: const EdgeInsets.all(AppTheme.spacingLg),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            size: 54,
                            color: AppTheme.error,
                          ),
                          const SizedBox(height: AppTheme.spacingMd),
                          Text(
                            'Unable to load this page',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                          ),
                          const SizedBox(height: AppTheme.spacingLg),
                          ElevatedButton.icon(
                            onPressed: () => _webViewController.reload(),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Retry'),
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
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: AppTheme.highlightGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          ),
          child: const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textPrimary),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Text(
          'Loading content...',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    );
  }
}
