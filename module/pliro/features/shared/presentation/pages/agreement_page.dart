import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/env/app_env.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';

/// Agreement page - WebView for terms and privacy.
class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String? _error;
  String _url = '';
  String _title = '';

  @override
  void initState() {
    super.initState();
    _parseArguments();
  }

  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    _title = args['title'] as String? ?? 'Agreement';
    final urlFromArgs = args['url'] as String?;
    final isPrivacy = _title.toLowerCase().contains('privacy');
    _url = urlFromArgs ?? (isPrivacy ? AppEnv().h5Privacy : AppEnv().h5User);
  }

  @override
  void dispose() {
    _webViewController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DreamScaffold(
      appBar: AppBar(title: Text(_title)),
      body: _url.isEmpty
          ? _buildEmptyState()
          : Stack(
              children: [
                _buildWebView(),
                if (_isLoading) _buildLoadingOverlay(),
                if (_error != null) _buildErrorOverlay(),
              ],
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: NeonCard(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description_outlined,
              size: 56,
              color: AppColors.roseDeep.withOpacity(0.58),
            ),
            const SizedBox(height: AppTheme.spacingMD),
            Text('Content not available', style: AppTextStyles.body),
          ],
        ),
      ),
    );
  }

  Widget _buildWebView() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.spacingMD,
        AppTheme.spacingSM,
        AppTheme.spacingMD,
        AppTheme.spacingMD,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_url)),
          initialOptions: InAppWebViewGroupOptions(
            crossPlatform: InAppWebViewOptions(
              useShouldOverrideUrlLoading: false,
              javaScriptEnabled: true,
            ),
          ),
          onWebViewCreated: (controller) {
            _webViewController = controller;
          },
          onLoadStart: (controller, url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _error = null;
              });
            }
          },
          onLoadStop: (controller, url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = null;
              });
            }
          },
          onLoadError: (controller, url, code, message) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = message;
              });
            }
          },
          onLoadHttpError: (controller, url, statusCode, description) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _error = description;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: AppColors.dreamCream.withOpacity(0.82),
      child: const Center(
        child: NeonCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(strokeWidth: 2.4),
              SizedBox(height: AppTheme.spacingMD),
              Text('Loading...'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: AppColors.dreamCream.withOpacity(0.92),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingLG),
          child: NeonCard(
            padding: const EdgeInsets.all(AppTheme.spacingXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 56,
                  color: AppColors.errorRed,
                ),
                const SizedBox(height: AppTheme.spacingMD),
                Text('Unable to load', style: AppTextStyles.h3),
                const SizedBox(height: AppTheme.spacingSM),
                Text(
                  _error ?? 'Unknown error occurred',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTheme.spacingLG),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _error = null;
                      _isLoading = true;
                    });
                    _webViewController?.reload();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
