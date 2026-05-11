import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_loading.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';
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
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _errorMessage = null;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) => setState(() {
            _isLoading = false;
            _errorMessage = error.description;
          }),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackdrop(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AppIconCircle(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => context.pop(),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(widget.title, style: AppTextStyles.h2),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: AppSectionCard(
                  padding: const EdgeInsets.all(10),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: WebViewWidget(controller: _controller),
                        ),
                        if (_isLoading)
                          const Positioned.fill(
                            child: ColoredBox(
                              color: Colors.white,
                              child: Center(
                                child: AppLoading(message: 'Loading...'),
                              ),
                            ),
                          ),
                        if (_errorMessage != null)
                          Positioned.fill(
                            child: Center(
                              child: AppEmptyState(
                                message: _errorMessage!,
                                icon: Icons.error_outline,
                                actionLabel: 'Retry',
                                onAction: _initWebView,
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
}
