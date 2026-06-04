import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_button.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';

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
  String? _error;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() {
            _isLoading = true;
            _error = null;
          }),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) => setState(() {
            _isLoading = false;
            _error = error.description;
          }),
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  Future<void> _reload() async {
    setState(() {
      _error = null;
      _isLoading = true;
    });
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(title: Text(widget.title)),
      safeBottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: AppBorderRadius.allLarge,
            child: Stack(
              children: [
                Positioned.fill(
                  child: WebViewWidget(controller: _controller),
                ),
                if (_isLoading && _error == null)
                  const Center(child: CircularProgressIndicator()),
                if (_error != null)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 52,
                            color: AppColors.semanticWarning,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text('Unable to load', style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _error!,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          AppButton(
                            text: 'Retry',
                            onPressed: _reload,
                            width: 180,
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
