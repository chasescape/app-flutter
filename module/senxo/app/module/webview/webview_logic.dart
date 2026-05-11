import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebviewLogic extends GetxController {
  InAppWebViewController? webViewController;
  
  var progress = 0.0.obs;
  var url = ''.obs;
  var title = 'Loading...'.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    // Get URL and title from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    url.value = args?['url'] ?? '';
    title.value = args?['title'] ?? 'Loading...';
    
    // Debug print
    print('=== WebView Debug ===');
    print('Arguments: $args');
    print('URL: ${url.value}');
    print('Title: ${title.value}');
    print('URL isEmpty: ${url.value.isEmpty}');
    print('URL length: ${url.value.length}');
    print('====================');
    
    // Validate URL
    if (url.value.isEmpty) {
      hasError.value = true;
      errorMessage.value = 'URL is empty. Please check AppEnv configuration.';
      print('Error: URL is empty');
    } else if (!url.value.startsWith('http')) {
      hasError.value = true;
      errorMessage.value = 'Invalid URL format. URL must start with http:// or https://';
      print('Error: Invalid URL format');
    }
  }

  void onWebViewCreated(InAppWebViewController controller) {
    webViewController = controller;
    print('WebView created');
  }

  void onLoadStart(Uri? uri) {
    if (uri != null) {
      url.value = uri.toString();
      print('Load start: ${uri.toString()}');
    }
    hasError.value = false;
  }

  Future<void> onLoadStop(Uri? uri) async {
    if (uri != null) {
      url.value = uri.toString();
      print('Load stop: ${uri.toString()}');
    }
    // Get page title
    if (webViewController != null) {
      final pageTitle = await webViewController!.getTitle();
      if (pageTitle != null && pageTitle.isNotEmpty) {
        title.value = pageTitle;
        print('Page title: $pageTitle');
      }
      
      // Get page content height to verify it loaded
      final contentHeight = await webViewController!.getContentHeight();
      print('Content height: $contentHeight');
      
      // Try to get HTML to verify content
      final html = await webViewController!.evaluateJavascript(
        source: 'document.body.innerHTML.substring(0, 100)'
      );
      print('HTML preview: $html');
    }
  }

  void onProgressChanged(int progressValue) {
    progress.value = progressValue / 100;
    print('Progress: $progressValue%');
  }

  void onReceivedError(WebResourceRequest request, WebResourceError error) {
    hasError.value = true;
    errorMessage.value = 'Error: ${error.description}';
    print('WebView Error: ${error.description}');
    print('Error URL: ${request.url}');
  }
}
