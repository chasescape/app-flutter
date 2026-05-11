import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import 'protocol_logic.dart';

class ProtocolPage extends StatelessWidget {
  const ProtocolPage({
    super.key,
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return _ProtocolPageContent(url: url, title: title);
  }
}

class _ProtocolPageContent extends StatefulWidget {
  const _ProtocolPageContent({
    required this.url,
    this.title,
  });

  final String url;
  final String? title;

  @override
  State<_ProtocolPageContent> createState() => _ProtocolPageContentState();
}

class _ProtocolPageContentState extends State<_ProtocolPageContent> {
  final ProtocolLogic logic = Get.put(ProtocolLogic());

  double _progress = 0;
  double _previousProgress = 0;
  String? _pageTitle;
  bool _loadError = false;

  String get _displayTitle => widget.title ?? _pageTitle ?? '';

  void _loadUrl(InAppWebViewController controller) {
    final url = widget.url;
    if (url.isEmpty) {
      setState(() => _loadError = true);
      return;
    }
    setState(() => _loadError = false);
    controller.loadUrl(urlRequest: URLRequest(url: WebUri(url)));
  }

  @override
  Widget build(BuildContext context) {
    final url = widget.url;
    if (url.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_displayTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D2A26))),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF2D2A26)), onPressed: () => Get.back()),
        ),
        body: const Center(child: Text('链接地址为空', style: TextStyle(color: Color(0xFF2D2A26)))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          _displayTitle,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF2D2A26)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20, color: Color(0xFF2D2A26)),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 22, color: Color(0xFF2D2A26)),
            onPressed: () {
              setState(() => _loadError = false);
              logic.webViewController?.reload();
            },
          ),
        ],
      ),
      body: _loadError
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('加载失败，请检查网络或链接', style: TextStyle(color: Color(0xFF2D2A26))),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() => _loadError = false);
                      logic.webViewController?.reload();
                    },
                    child: const Text('重试'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _progress < 1 ? 1.0 : 0.0,
                  child: TweenAnimationBuilder<double>(
                    key: ValueKey(_progress),
                    tween: Tween(begin: _previousProgress, end: _progress),
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOut,
                    builder: (context, value, _) => SizedBox(
                      height: value < 1 ? 4 : 0,
                      child: value < 1
                          ? LinearProgressIndicator(
                              value: value,
                              backgroundColor: const Color(0xFFE8E0D7),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFB89B79)),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                ),
                Expanded(
                  child: InAppWebView(
                    initialUrlRequest: null,
                    initialSettings: InAppWebViewSettings(
                      javaScriptEnabled: true,
                      useOnLoadResource: true,
                      suppressesIncrementalRendering: false,
                      textZoom: 200,
                      pageZoom: 2.0,
                    ),
                    onWebViewCreated: (controller) {
                      logic.webViewController = controller;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) _loadUrl(controller);
                      });
                    },
                    onLoadStart: (controller, uri) {
                      if (mounted) setState(() {
                        _previousProgress = _progress;
                        _progress = 0;
                      });
                    },
                    onProgressChanged: (controller, progress) {
                      if (mounted) setState(() {
                        _previousProgress = _progress;
                        _progress = progress / 100;
                      });
                    },
                    onLoadStop: (controller, uri) {
                      if (mounted) {
                        setState(() {
                          _previousProgress = _progress;
                          _progress = 1;
                        });
                        controller.getTitle().then((t) {
                          if (t != null && mounted) setState(() => _pageTitle = t);
                        });
                      }
                    },
                    onReceivedError: (controller, request, error) {
                      if (mounted) {
                        setState(() {
                          _previousProgress = _progress;
                          _progress = 1;
                          _loadError = true;
                        });
                      }
                    },
                    shouldOverrideUrlLoading: (controller, navigationAction) async {
                      final targetUri = navigationAction.request.url;
                      if (targetUri == null) return NavigationActionPolicy.ALLOW;
                      final scheme = targetUri.scheme.toLowerCase();
                      if (scheme == 'http' || scheme == 'https') {
                        return NavigationActionPolicy.ALLOW;
                      }
                      return NavigationActionPolicy.CANCEL;
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
