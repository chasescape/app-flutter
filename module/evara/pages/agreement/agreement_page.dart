import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/evara_scaffold.dart';
import '../../env/app_env.dart';

/// Agreement page for terms and privacy policy.
class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage>
    with TickerProviderStateMixin {
  InAppWebViewController? _webViewController;
  String _title = '';
  String _url = '';
  bool _isLoading = true;
  String? _errorMessage;
  bool _isError = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _parseArguments();
    _initAnimation();
  }

  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _title = args['title']?.toString() ?? 'Agreement';
      final urlParam = args['url']?.toString();
      if (urlParam != null && urlParam.isNotEmpty) {
        _url = urlParam;
      } else {
        _determineUrlByTitle();
      }
    } else {
      _title = 'Agreement';
      _determineUrlByTitle();
    }
  }

  void _determineUrlByTitle() {
    final lowerTitle = _title.toLowerCase();
    if (lowerTitle.contains('privacy')) {
      _url = AppEnv().h5Privacy;
    } else {
      _url = AppEnv().h5User;
    }
  }

  void _initAnimation() {
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
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
    return EvaraScaffold(
      safeTop: false,
      appBar: AppBar(title: Text(_title)),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              110,
              AppTheme.spacingLg,
              AppTheme.spacingLg,
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: InAppWebView(
                      initialUrlRequest: URLRequest(url: WebUri(_url)),
                      initialSettings: InAppWebViewSettings(
                        useShouldOverrideUrlLoading: false,
                        javaScriptEnabled: true,
                      ),
                      onWebViewCreated: (controller) {
                        _webViewController = controller;
                      },
                      onLoadStart: (_, __) {
                        setState(() {
                          _isLoading = true;
                          _isError = false;
                          _errorMessage = null;
                        });
                      },
                      onLoadStop: (_, __) {
                        setState(() {
                          _isLoading = false;
                        });
                      },
                      onReceivedError: (_, __, ___) {
                        setState(() {
                          _isLoading = false;
                          _isError = true;
                          _errorMessage = 'Unable to load page';
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: AppTheme.bgOverlay,
              child: Center(
                child: EvaraGlassCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildPulseLoadingIndicator(),
                      const SizedBox(height: AppTheme.spacingMd),
                      const Text(
                        'Loading document...',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.caption,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          if (_isError)
            Container(
              color: AppTheme.bgOverlay,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: EvaraGlassCard(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 52,
                          color: AppTheme.error,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          _errorMessage ?? 'Unable to load page',
                          style: const TextStyle(
                            fontSize: AppTheme.body,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingLg),
                        ElevatedButton(
                          onPressed: () => _webViewController?.reload(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPulseLoadingIndicator() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildPulseCircle(1.0 - _pulseAnimation.value * 0.3, 0.3),
            _buildPulseCircle(1.0 - _pulseAnimation.value * 0.5, 0.5),
            _buildPulseCircle(1.0 - _pulseAnimation.value * 0.7, 0.7),
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: AppTheme.primaryMain,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPulseCircle(double scale, double opacity) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.primaryLight.withValues(alpha: opacity),
            width: 2,
          ),
        ),
      ),
    );
  }
}
