import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'webview_logic.dart';

class WebviewPage extends StatelessWidget {
  WebviewPage({super.key});

  final WebviewLogic logic = Get.put(WebviewLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevron_left, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title: Obx(() => Text(
          logic.title.value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF212121),
          ),
        )),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(logic.url.value),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              domStorageEnabled: true,
              transparentBackground: false,
            ),
            onWebViewCreated: logic.onWebViewCreated,
            onLoadStart: (controller, url) => logic.onLoadStart(url),
            onLoadStop: (controller, url) => logic.onLoadStop(url),
            onProgressChanged: (controller, progress) => logic.onProgressChanged(progress),
            onReceivedError: (controller, request, error) => logic.onReceivedError(request, error),
            onConsoleMessage: (controller, consoleMessage) {
              print('WebView Console: ${consoleMessage.message}');
            },
          ),
          // Progress bar
          Obx(() => logic.progress.value < 1.0
              ? Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: LinearProgressIndicator(
                    value: logic.progress.value,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF9575CD),
                    ),
                  ),
                )
              : const SizedBox.shrink()),
        ],
      ),
    );
  }
}
