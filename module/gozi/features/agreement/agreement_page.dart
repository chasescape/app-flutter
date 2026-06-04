import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';

/// Agreement Page - WebView for legal documents
class AgreementPage extends StatefulWidget {
  final String url;
  final String title;

  const AgreementPage({
    super.key,
    required this.url,
    required this.title,
  });

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  int _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _loadingProgress = 0;
            });
          },
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(
        Uri.parse(widget.url),
      );
  }

  Future<void> _refresh() async {
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Bar
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress / 100,
              backgroundColor: AppTheme.primaryWhite.withValues(alpha: 0.64),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppTheme.accentRed,
              ),
            ),

          // WebView Content
          Expanded(
            child: Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.accentRed,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
