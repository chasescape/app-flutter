import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';
import '../../app/theme/theme.dart';
import '../../env/app_env.dart';
import '../../widgets/visuals/sunny_visuals.dart';

/// Agreement Page - Display Terms of Service and Privacy Policy
/// Uses WebView to load agreement content from remote URL
class AgreementPage extends StatefulWidget {
  /// Agreement title
  final String title;

  /// Agreement URL (optional, will use AppEnv default if not provided)
  final String? url;

  const AgreementPage({
    super.key,
    required this.title,
    this.url,
  });

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _isLoading = true;
  String? _errorMessage;
  InAppWebViewController? _webViewController;
  late String _url;

  @override
  void initState() {
    super.initState();
    _url = widget.url ?? _getDefaultUrl();
  }

  String _getDefaultUrl() {
    // Determine agreement type from title
    final titleLower = widget.title.toLowerCase();
    if (titleLower.contains('privacy')) {
      return AppEnv().h5Privacy;
    }
    return AppEnv().h5User;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          // WebView
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_url)),
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: false,
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
            },
            onLoadStart: (controller, url) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
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
                _errorMessage = error.description;
              });
            },
          ),

          // Loading Overlay
          if (_isLoading)
            SunnyPage(
              child: Center(
                child: _LoadingAnimation(),
              ),
            ),

          // Error Overlay
          if (_errorMessage != null)
            SunnyPage(
              child: Center(
                child: SunnyCard(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(AppColors.error),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Unable to load',
                        style: AppTypography.getH3TextStyle(
                          const Color(AppColors.textPrimary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        style: AppTypography.getBodyTextStyle(
                          const Color(AppColors.textSecondary),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
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
        ],
      ),
    );
  }
}

/// Custom pulse loading animation
class _LoadingAnimation extends StatefulWidget {
  @override
  State<_LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<_LoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            _PulseCircle(
              animation: _controller,
              begin: 0.0,
              end: 1.0,
              size: 80,
            ),
            // Middle ring
            _PulseCircle(
              animation: _controller,
              begin: 0.2,
              end: 0.8,
              size: 56,
            ),
            // Center dot
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: const Color(AppColors.primaryMain),
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PulseCircle extends StatelessWidget {
  final Animation<double> animation;
  final double begin;
  final double end;
  final double size;

  const _PulseCircle({
    required this.animation,
    required this.begin,
    required this.end,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final interval = CurvedAnimation(
      parent: animation,
      curve: Interval(begin, end, curve: Curves.easeInOut),
    );
    final opacity = Tween<double>(begin: 0.3, end: 0.8).animate(interval);
    final scale = Tween<double>(begin: 0.8, end: 1.2).animate(interval);

    return ScaleTransition(
      scale: scale,
      child: Opacity(
        opacity: opacity.value,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(AppColors.primaryMain),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}
