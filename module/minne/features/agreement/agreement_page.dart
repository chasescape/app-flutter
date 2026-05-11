import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';

/// Color Scheme for Agreement Page
/// Uses project theme colors for consistent design
class _AgreementColorScheme {
  final Color primary;
  final Color secondary;
  final Color backgroundTop;
  final Color backgroundBottom;
  final Color surface;
  final Color text;
  final Color textSecondary;
  final Color ornament1;
  final Color ornament2;
  final Color ornament3;

  const _AgreementColorScheme({
    required this.primary,
    required this.secondary,
    required this.backgroundTop,
    required this.backgroundBottom,
    required this.surface,
    required this.text,
    required this.textSecondary,
    required this.ornament1,
    required this.ornament2,
    required this.ornament3,
  });
}

/// Agreement Page - Artistic Custom UI Style (Template B)
/// Uses HeadlessInAppWebView to crawl content and display with custom UI
class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  String _title = 'Agreement';
  String _content = "Loading terms and conditions...";
  bool _isLoading = true;
  HeadlessInAppWebView? _headlessWebView;
  late final _AgreementColorScheme _colors;

  @override
  void initState() {
    super.initState();
    _colors = _getColorScheme();
    _parseArguments();
    _startCrawling();
  }

  @override
  void dispose() {
    _headlessWebView?.dispose();
    super.dispose();
  }

  void _parseArguments() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      _title = args['title'] as String? ?? 'Agreement';
    }
  }

  /// Get color scheme based on project theme
  _AgreementColorScheme _getColorScheme() {
    return const _AgreementColorScheme(
      primary: Color(0xFFAF3D6B),
      secondary: Color(0xFFF7B24D),
      backgroundTop: Color(0xFFFFD3E1),
      backgroundBottom: Color(0xFFFFF2A8),
      surface: Color(0xFFFFFCF8),
      text: Color(0xFF8E375B),
      textSecondary: Color(0xFFB45E72),
      ornament1: Color(0xFFFF8BB3),
      ornament2: Color(0xFFFFD36E),
      ornament3: Color(0xFFFFB5C8),
    );
  }

  /// Start crawling web content using HeadlessInAppWebView
  Future<void> _startCrawling() async {
    // Get URL from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    final url = args?['url'] as String? ?? '';

    if (url.isEmpty) {
      if (mounted) {
        setState(() {
          _content = "No URL provided.";
          _isLoading = false;
        });
      }
      return;
    }

    _headlessWebView = HeadlessInAppWebView(
      initialUrlRequest: URLRequest(url: WebUri(url)),
      onLoadStop: (controller, url) async {
        // Wait for JS rendering
        await Future.delayed(const Duration(milliseconds: 800));

        // Crawl web content
        final String? result = await controller.evaluateJavascript(source: """
          (function() {
            try {
              var selectors = ['article', 'main', '.content', '.article', '#content', 'body'];
              for (var i = 0; i < selectors.length; i++) {
                var el = document.querySelector(selectors[i]);
                if (el && el.innerText.trim().length > 100) {
                  return el.innerText;
                }
              }
              return document.body.innerText;
            } catch (e) {
              return document.body.innerText;
            }
          })()
        """);

        if (mounted) {
          setState(() {
            _content = (result != null && result.isNotEmpty)
                ? result.trim()
                : "No content available.";
            _isLoading = false;
          });
        }
      },
      onReceivedError: (controller, request, error) {
        if (mounted) {
          setState(() {
            _content = "Connection error. Please check your internet.\n(${error.description})";
            _isLoading = false;
          });
        }
      },
    );

    await _headlessWebView?.run();
  }

  Widget _buildHeader() {
    return Padding(
      padding: AppSpacing.paddingHorizontalMD,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              _title,
              style: AppTextStyles.h1Style.copyWith(
                color: _colors.primary,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _colors.primary.withValues(alpha: 0.14),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Icon(Icons.close, color: _colors.textSecondary, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentCard() {
    return Padding(
      padding: AppSpacing.paddingHorizontalMD,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _colors.surface,
          borderRadius: BorderRadius.circular(38),
          boxShadow: [
            BoxShadow(
              color: _colors.primary.withValues(alpha: 0.16),
              blurRadius: 34,
              offset: const Offset(0, 18),
            ),
          ],
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.75),
            width: 1.8,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(38),
          child: _isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: _colors.primary,
                        strokeWidth: 3,
                      ),
                      AppSpacing.gapMD,
                      Text(
                        'Loading...',
                        style: AppTextStyles.bodyStyle.copyWith(
                          color: _colors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 30),
                  child: Text(
                    _content,
                    style: AppTextStyles.bodyStyle.copyWith(
                      height: 1.82,
                      color: _colors.text,
                      fontSize: 15.5,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildBackgroundOrnament(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: 0.18),
          ],
        ),
        shape: BoxShape.circle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _colors.backgroundBottom,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    _colors.backgroundTop,
                    const Color(0xFFFFE7B8),
                    _colors.backgroundBottom,
                  ],
                ),
              ),
            ),
          ),
          // Decorative background ornaments
          Positioned(
            top: -50,
            right: -50,
            child: _buildBackgroundOrnament(200, _colors.ornament1.withValues(alpha: 0.15)),
          ),
          Positioned(
            bottom: 100,
            left: -80,
            child: _buildBackgroundOrnament(250, _colors.ornament2.withValues(alpha: 0.1)),
          ),
          Positioned(
            top: 110,
            right: 24,
            child: _buildBackgroundOrnament(92, _colors.ornament3.withValues(alpha: 0.2)),
          ),
          // Small decorative dots
          Positioned(
            top: 150,
            left: 30,
            child: _buildBackgroundOrnament(15, _colors.primary.withValues(alpha: 0.2)),
          ),
          Positioned(
            top: 200,
            left: 60,
            child: _buildBackgroundOrnament(8, _colors.secondary.withValues(alpha: 0.3)),
          ),
          Positioned(
            bottom: 250,
            right: 40,
            child: _buildBackgroundOrnament(20, _colors.ornament2.withValues(alpha: 0.15)),
          ),
          Positioned(
            bottom: 180,
            left: 36,
            child: _buildBackgroundOrnament(16, _colors.ornament3.withValues(alpha: 0.18)),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                AppSpacing.gapLG,
                _buildHeader(),
                Padding(
                  padding: AppSpacing.paddingHorizontalMD,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'A sweet little read before we continue.',
                      style: AppTextStyles.bodyStyle.copyWith(
                        color: _colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                AppSpacing.gapXL,
                Expanded(child: _buildContentCard()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
