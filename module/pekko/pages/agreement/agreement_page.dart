import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../env/app_env.dart';

/// Agreement page for Terms of Service and Privacy Policy
/// Uses InAppWebView to display content within the app
class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage>
    with SingleTickerProviderStateMixin {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  String? _error;

  // Get URL and title from route parameters
  String get _url =>
      Get.parameters['url'] ?? _getDefaultUrl();
  String get _title => Get.parameters['title'] ?? 'Agreement';

  String _getDefaultUrl() {
    // Determine URL based on title
    final title = Get.parameters['title'] ?? '';
    if (title.toLowerCase().contains('privacy')) {
      return AppEnv().h5Privacy.isNotEmpty ? AppEnv().h5Privacy : 'about:blank';
    }
    return AppEnv().h5User.isNotEmpty ? AppEnv().h5User : 'about:blank';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // WebView
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(_url),
            ),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: false,
              javaScriptEnabled: true,
              supportZoom: true,
              displayZoomControls: false,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
                _error = null;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                _isLoading = false;
              });
            },
            onReceivedError: (controller, request, error) {
              setState(() {
                _isLoading = false;
                _error = error.description;
              });
            },
            onReceivedHttpError: (controller, request, errorResponse) {
              setState(() {
                _isLoading = false;
                _error = 'HTTP ${errorResponse.statusCode}: ${errorResponse.reasonPhrase}';
              });
            },
          ),

          // Loading overlay
          if (_isLoading)
            Container(
              color: AppColors.backgroundPrimary,
              child: Center(
                child: _PulseLoadingAnimation(),
              ),
            ),

          // Error overlay
          if (_error != null)
            Container(
              color: AppColors.backgroundPrimary,
              child: Center(
                child: Padding(
                  padding: AppSpacing.paddingXL,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Unable to Load',
                        style: AppTextStyles.h3,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        _error!,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      ElevatedButton.icon(
                        onPressed: () {
                          _webViewController.reload();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Custom pulse loading animation
class _PulseLoadingAnimation extends StatefulWidget {
  @override
  State<_PulseLoadingAnimation> createState() =>
      _PulseLoadingAnimationState();
}

class _PulseLoadingAnimationState extends State<_PulseLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _outerScale;
  late Animation<double> _middleScale;
  late Animation<double> _innerScale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _outerScale = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _middleScale = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _innerScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        children: [
          // Outer ring
          Center(
            child: ScaleTransition(
              scale: _outerScale,
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
          // Middle ring
          Center(
            child: ScaleTransition(
              scale: _middleScale,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 3,
                  ),
                ),
              ),
            ),
          ),
          // Center dot
          Center(
            child: ScaleTransition(
              scale: _innerScale,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
