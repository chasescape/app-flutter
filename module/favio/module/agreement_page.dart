import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import 'favio_palette.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final bool hasValidUrl = widget.url.isNotEmpty &&
        widget.url != 'N/A' &&
        Uri.tryParse(widget.url)?.hasAbsolutePath == true;

    return Scaffold(
      backgroundColor: FavioPalette.backgroundAlt,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              FavioPalette.backgroundTop,
              FavioPalette.backgroundMid,
              FavioPalette.backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFF121520),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.title.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.06),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: Stack(
                        children: <Widget>[
                          if (hasValidUrl)
                            InAppWebView(
                              initialSettings: InAppWebViewSettings(
                                transparentBackground: true,
                                useShouldOverrideUrlLoading: false,
                              ),
                              initialUrlRequest: URLRequest(
                                url: WebUri(widget.url),
                              ),
                              onLoadStart: (_, __) {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _isLoading = true;
                                  _error = null;
                                });
                              },
                              onLoadStop: (_, __) {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _isLoading = false;
                                });
                              },
                              onReceivedError: (_, __, error) {
                                if (!mounted) {
                                  return;
                                }
                                setState(() {
                                  _isLoading = false;
                                  _error = error.description;
                                });
                              },
                            )
                          else
                            const _AgreementStateView(
                              title: 'Unable to load',
                              body: 'Policy link is not configured yet.',
                            ),
                          if (_isLoading && hasValidUrl)
                            Container(
                              color: const Color(0x88090A10),
                              alignment: Alignment.center,
                              child: const Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.4,
                                      color: FavioPalette.brandGlow,
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'Loading...',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (_error != null)
                            _AgreementStateView(
                              title: 'Unable to load',
                              body: _error!,
                            ),
                        ],
                      ),
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

class _AgreementStateView extends StatelessWidget {
  const _AgreementStateView({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.language_rounded,
              color: Colors.white,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFD2D6DF),
                fontSize: 13,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
