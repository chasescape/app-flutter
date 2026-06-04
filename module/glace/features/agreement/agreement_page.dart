import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../core/theme/app_theme.dart';
import '../../widgets/glace_ui.dart';

class AgreementPage extends StatefulWidget {
  final String title;
  final String url;

  const AgreementPage({super.key, required this.title, required this.url});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _error;
  String _content = '';
  HeadlessInAppWebView? _headlessWebView;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _loadContent();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _headlessWebView?.dispose();
    super.dispose();
  }

  Future<void> _loadContent() async {
    if (widget.url.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Content not available';
      });
      return;
    }

    _headlessWebView = HeadlessInAppWebView(
      initialSettings: InAppWebViewSettings(
        useHybridComposition: false,
        javaScriptEnabled: true,
      ),
      initialUrlRequest: URLRequest(url: WebUri(widget.url)),
      onLoadStop: (controller, _) async {
        await Future.delayed(const Duration(milliseconds: 800));
        try {
          final result = await controller.evaluateJavascript(source: '''
            (function() {
              var selectors = ['article', 'main', '.content', '.article', '#content', 'body'];
              for (var i = 0; i < selectors.length; i++) {
                var el = document.querySelector(selectors[i]);
                if (el && el.innerText.length > 100) {
                  return el.innerText;
                }
              }
              return document.body.innerText;
            })();
          ''');
          if (mounted) {
            final text = result?.toString() ?? '';
            if (text.isNotEmpty && text.length > 50) {
              setState(() {
                _content = text;
                _isLoading = false;
              });
            } else {
              setState(() {
                _error = 'Unable to parse content';
                _isLoading = false;
              });
            }
          }
        } catch (_) {
          if (mounted) {
            setState(() {
              _error = 'Failed to load content';
              _isLoading = false;
            });
          }
        }
      },
      onReceivedError: (controller, _, error) {
        if (mounted) {
          setState(() {
            _error = 'Unable to load';
            _isLoading = false;
          });
        }
      },
    );

    _headlessWebView?.run();
  }

  @override
  Widget build(BuildContext context) {
    return GlaceScaffold(
      appBar: AppBar(title: Text(widget.title)),
      safeArea: false,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: _content.isNotEmpty
              ? _buildContentView()
              : _isLoading
                  ? _buildLoadingView()
                  : _buildErrorView(),
        ),
      ),
    );
  }

  Widget _buildContentView() {
    return GlaceSurfaceCard(
      color: Colors.white.withValues(alpha: 0.82),
      child: SingleChildScrollView(
        child: SelectableText(
          _content,
          style: const TextStyle(
            fontSize: 15,
            height: 1.8,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: GlaceGlassCard(
        width: 190,
        height: 190,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _pulseController,
              builder: (_, __) {
                final value = _pulseController.value;
                return Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.92),
                        AppColors.secondary
                            .withValues(alpha: 0.24 + 0.10 * value),
                        const Color(0x00FFFFFF),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            const Text(
              'Loading content...',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: GlaceSurfaceCard(
        color: Colors.white.withValues(alpha: 0.80),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                color: AppColors.surfaceHighlight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unable to load',
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 140,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                    _content = '';
                  });
                  _headlessWebView?.dispose();
                  _loadContent();
                },
                child: const Text('Retry'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
