import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'webview_logic.dart';

class WebViewPage extends StatelessWidget {
  WebViewPage({super.key});

  final WebViewLogic logic = Get.find<WebViewLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0a0412),
      body: Stack(
        children: [
          // 背景渐变
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1a0b2e),
                  Color(0xFF0a0412),
                ],
              ),
            ),
          ),

          // 主内容
          Column(
            children: [
              // 自定义 AppBar
              _buildAppBar(context),

              // WebView 内容
              Expanded(
                child: _buildWebView(),
              ),
            ],
          ),

          // 加载进度条
          Obx(() {
            if (logic.isLoading.value && logic.progress.value < 1.0) {
              return Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(
                  value: logic.progress.value,
                  backgroundColor: Colors.transparent,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFec4899),
                  ),
                  minHeight: 3,
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  /// 构建自定义 AppBar
  Widget _buildAppBar(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 16,
        right: 16,
        bottom: 12,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF7c2d9e).withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // 返回按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Get.back(),
              borderRadius: BorderRadius.circular(20),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFFf9a8d4),
                      size: 24,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 标题
          Expanded(
            child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFf472b6), Color(0xFFa855f7)],
                  ).createShader(bounds),
                  child: Text(
                    logic.title.value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  logic.url.value.isNotEmpty
                      ? Uri.parse(logic.url.value).host
                      : '',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFFf9a8d4).withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            )),
          ),

          // 刷新按钮
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: logic.reload,
              borderRadius: BorderRadius.circular(20),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                        width: 1,
                      ),
                    ),
                    child: Obx(() => logic.isLoading.value
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFFf9a8d4),
                        ),
                      ),
                    )
                        : const Icon(
                      Icons.refresh,
                      color: Color(0xFFf9a8d4),
                      size: 22,
                    ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建 WebView
  Widget _buildWebView() {
    return ClipRRect(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFec4899).withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri(logic.initialUrl),
          ),
          initialSettings: InAppWebViewSettings(
            useShouldOverrideUrlLoading: true,
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
            iframeAllow: "camera; microphone",
            iframeAllowFullscreen: true,
            javaScriptEnabled: true,
            javaScriptCanOpenWindowsAutomatically: true,
            useHybridComposition: true,
            supportZoom: true,
            builtInZoomControls: true,
            displayZoomControls: false,
          ),
          onWebViewCreated: (controller) {
            logic.webViewController = controller;
          },
          onLoadStart: (controller, url) {
            logic.onLoadStart(url?.toString());
          },
          onLoadStop: (controller, url) async {
            logic.onLoadStop(url?.toString());

            // 获取页面标题
            final pageTitle = await controller.getTitle();
            if (pageTitle != null && pageTitle.isNotEmpty) {
              logic.title.value = pageTitle;
            }
          },
          onProgressChanged: (controller, progress) {
            logic.onProgressChanged(progress);
          },
          onReceivedError: (controller, request, error) {
            logic.onLoadError(
              request.url.toString(),
              error.type.toNativeValue() ?? 0,
              error.description,
            );
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            // 允许所有导航
            return NavigationActionPolicy.ALLOW;
          },
        ),
      ),
    );
  }
}
