import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../core/constants/app_colors.dart';
import '../../core/widgets/app_shell.dart';
import '../../env/app_env.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage>
    with SingleTickerProviderStateMixin {
  late final String _title;
  late final String _url;
  bool _isLoading = true;
  String? _errorMessage;
  late AnimationController _loadingController;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _title = args['title'] as String? ?? 'Agreement';
    _url = args['url'] as String? ?? _getDefaultUrl();
    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  String _getDefaultUrl() {
    final titleLower = _title.toLowerCase();
    if (titleLower.contains('privacy')) {
      return AppEnv().h5Privacy;
    }
    return AppEnv().h5User;
  }

  @override
  void dispose() {
    _loadingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                AppTopBar(
                  title: _title,
                  subtitle: 'DOCUMENT',
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        InAppWebView(
                          initialUrlRequest: URLRequest(url: WebUri(_url)),
                          initialSettings: InAppWebViewSettings(
                            transparentBackground: true,
                            javaScriptEnabled: true,
                          ),
                          onLoadStart: (controller, url) {
                            if (mounted) {
                              setState(() => _isLoading = true);
                            }
                          },
                          onLoadStop: (controller, url) {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          },
                          onReceivedError: (controller, request, error) {
                            if (mounted) {
                              setState(() {
                                _isLoading = false;
                                _errorMessage = 'Unable to load page';
                              });
                            }
                          },
                        ),
                        if (_isLoading) _buildLoadingOverlay(),
                        if (_errorMessage != null) _buildErrorOverlay(),
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

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.92),
      child: Center(
        child: AnimatedBuilder(
          animation: _loadingController,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.9 + (_loadingController.value * 0.18),
              child: Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  gradient: AppGradients.accent,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: AppColors.textOnDark,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.white.withValues(alpha: 0.95),
      child: Center(
        child: AppEmptyStateCard(
          icon: Icons.error_outline_rounded,
          title: 'Unable to load',
          description: _errorMessage ?? 'Please try again.',
          action: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppGradients.whitePill,
              borderRadius: BorderRadius.circular(999),
            ),
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _errorMessage = null;
                  _isLoading = true;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Text('Retry'),
            ),
          ),
        ),
      ),
    );
  }
}
