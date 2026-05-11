import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../routes/app_routes.dart';

class TermsWebViewPage extends StatelessWidget {
  const TermsWebViewPage({super.key});

  String _resolveUrl() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final url = args['url'];
      if (url is String && url.isNotEmpty) {
        return url;
      }
    }
    return 'about:blank';
  }

  String _resolveTitle() {
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      final title = args['title'];
      if (title is String && title.isNotEmpty) {
        return title;
      }
    }
    return 'Web';
  }

  @override
  Widget build(BuildContext context) {
    final url = _resolveUrl();
    final title = _resolveTitle();
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(url)),
          onLoadError: (controller, url, code, message) {
            if (url == null || url.toString().isEmpty) {
              Get.snackbar('Load failed', 'Unable to open page', snackPosition: SnackPosition.BOTTOM);
            }
          },
        ),
      ),
    );
  }
}
