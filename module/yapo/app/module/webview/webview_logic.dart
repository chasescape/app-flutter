import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class WebViewLogic extends GetxController {
  final isLoading = true.obs;
  final progress = 0.0.obs;
  final canGoBack = false.obs;
  final canGoForward = false.obs;
  final title = ''.obs;
  final url = ''.obs;

  InAppWebViewController? webViewController;

  late final String initialUrl;
  late final String pageTitle;
  late final int textZoom;

  @override
  void onInit() {
    super.onInit();

    // 从路由参数获取 URL、标题和文字缩放比例
    final args = Get.arguments as Map<String, dynamic>?;
    initialUrl = args?['url'] ?? '';
    pageTitle = args?['title'] ?? 'Loading...';
    textZoom = args?['textZoom'] ?? 400; // 默认 200%
    title.value = pageTitle;
    url.value = initialUrl;
  }

  /// 页面加载开始
  void onLoadStart(String? url) {
    isLoading.value = true;
    if (url != null) {
      this.url.value = url;
    }
  }

  /// 页面加载进度
  void onProgressChanged(int progress) {
    this.progress.value = progress / 100;
  }

  /// 页面加载完成
  void onLoadStop(String? url) {
    isLoading.value = false;
    if (url != null) {
      this.url.value = url;
    }
    _updateNavigationState();
  }

  /// 页面加载错误
  void onLoadError(String? url, int code, String message) {
    isLoading.value = false;
    print('WebView 加载错误: $code - $message');
  }

  /// 更新导航状态
  Future<void> _updateNavigationState() async {
    if (webViewController != null) {
      canGoBack.value = await webViewController!.canGoBack();
      canGoForward.value = await webViewController!.canGoForward();
    }
  }

  /// 返回上一页
  Future<void> goBack() async {
    if (await webViewController?.canGoBack() ?? false) {
      await webViewController?.goBack();
    }
  }

  /// 前进下一页
  Future<void> goForward() async {
    if (await webViewController?.canGoForward() ?? false) {
      await webViewController?.goForward();
    }
  }

  /// 刷新页面
  Future<void> reload() async {
    await webViewController?.reload();
  }

  /// 停止加载
  Future<void> stopLoading() async {
    await webViewController?.stopLoading();
  }
}
