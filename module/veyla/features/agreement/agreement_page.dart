import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/pastel_ui.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late final WebViewController _controller;

  String _title = 'Agreement';
  String _url = '';
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    final args = Get.arguments as Map<String, dynamic>?;
    _title = args?['title'] as String? ?? 'Agreement';
    _url = args?['url'] as String? ?? '';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = true;
              _hasError = false;
            });
          },
          onPageFinished: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (_) {
            if (!mounted) return;
            setState(() {
              _isLoading = false;
              _hasError = true;
            });
          },
        ),
      );

    if (_url.isEmpty) {
      _hasError = true;
      _isLoading = false;
      return;
    }

    _controller.loadRequest(Uri.parse(_url));
  }

  Future<void> _reloadPage() async {
    if (_url.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    await _controller.loadRequest(Uri.parse(_url));
  }

  @override
  Widget build(BuildContext context) {
    return PastelScaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
        title: Text(_title),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: GlassCard(
          padding: const EdgeInsets.all(10),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                Positioned.fill(
                  child: ColoredBox(
                    color: AppColors.surface,
                    child: _url.isEmpty
                        ? const SizedBox.shrink()
                        : WebViewWidget(controller: _controller),
                  ),
                ),
                if (_isLoading)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.surface.withValues(alpha: 0.92),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accentLight,
                            ),
                            child: const Icon(
                              Icons.language_rounded,
                              size: 34,
                              color: AppColors.accentDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.accentDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text('Loading page...', style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            _url,
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                if (_hasError)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.surface,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 84,
                            height: 84,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              gradient: AppGradients.hero,
                              border: Border.all(color: AppColors.stroke),
                            ),
                            child: const Icon(
                              Icons.language_outlined,
                              size: 42,
                              color: AppColors.accentDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const Text('Unable to load page', style: AppTextStyles.h3),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            _url.isEmpty ? 'Missing agreement URL.' : _url,
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          ElevatedButton.icon(
                            onPressed: _url.isEmpty ? null : _reloadPage,
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Try again'),
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
