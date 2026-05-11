import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../../theme/app_theme.dart';

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

class _AgreementPageState extends State<AgreementPage>
    with SingleTickerProviderStateMixin {
  InAppWebViewController? _webViewController;
  bool _isLoading = true;
  String? _error;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initPulseAnimation();
  }

  void _initPulseAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.bgPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          if (widget.url.isEmpty)
            _buildErrorWidget()
          else
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(widget.url)),
              initialSettings: InAppWebViewSettings(
                useShouldOverrideUrlLoading: false,
                javaScriptEnabled: true,
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
                  _error = errorResponse.reasonPhrase;
                });
              },
            ),
          if (_isLoading && widget.url.isNotEmpty) _buildLoadingWidget(),
          if (_error != null) _buildErrorOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Positioned.fill(
      child: Container(
        color: AppTheme.creamBackground.withValues(alpha: 0.9),
        child: Center(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  _buildPulseCircle(_pulseAnimation.value * 1.0),
                  _buildPulseCircle(_pulseAnimation.value * 0.7),
                  _buildPulseCircle(_pulseAnimation.value * 0.4),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPulseCircle(double scale) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.primaryMain.withValues(alpha: 0.4),
          width: 2,
        ),
      ),
      child: Transform.scale(
        scale: scale,
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.primaryMain.withValues(alpha: 0.1),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppTheme.semanticError.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline,
              size: 40,
              color: AppTheme.semanticError,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Unable to load',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Positioned.fill(
      child: Container(
        color: AppTheme.creamBackground.withValues(alpha: 0.95),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppTheme.semanticError.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 40,
                  color: AppTheme.semanticError,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Unable to load',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please try again later',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _webViewController?.reload();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryMain,
                  foregroundColor: AppTheme.primaryContrastText,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
