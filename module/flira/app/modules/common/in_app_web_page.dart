import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class InAppWebPage extends StatefulWidget {
  const InAppWebPage({
    super.key,
    required this.title,
    required this.url,
  });

  final String title;
  final String url;

  @override
  State<InAppWebPage> createState() => _InAppWebPageState();
}

class _InAppWebPageState extends State<InAppWebPage> {
  bool _hasErrorPage = false;

  Future<void> _showErrorPage({
    required InAppWebViewController controller,
    required String title,
    required String message,
    String? extra,
  }) async {
    _hasErrorPage = true;

    final String html = '''
<!doctype html>
<html>
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Error</title>
    <style>
      body {
        margin: 0;
        font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Text', Arial, sans-serif;
        background: #ffffff;
        color: #222222;
      }
      .wrap {
        min-height: 100vh;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 24px;
      }
      .card {
        width: 100%;
        max-width: 560px;
        border: 1px solid #efefef;
        border-radius: 14px;
        padding: 20px;
        box-shadow: 0 10px 24px rgba(0, 0, 0, 0.06);
      }
      .code {
        font-size: 28px;
        font-weight: 800;
        margin-bottom: 8px;
      }
      .msg {
        font-size: 16px;
        line-height: 1.5;
        color: #555;
      }
      .extra {
        margin-top: 12px;
        font-size: 13px;
        color: #888;
        word-break: break-all;
      }
    </style>
  </head>
  <body>
    <div class="wrap">
      <div class="card">
        <div class="code">$title</div>
        <div class="msg">$message</div>
        ${extra == null ? '' : '<div class="extra">$extra</div>'}
      </div>
    </div>
  </body>
</html>
''';

    await controller.loadData(
      data: html,
      mimeType: 'text/html',
      encoding: 'utf-8',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Stack(
        children: <Widget>[
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(widget.url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
            ),
            onLoadStart: (_, __) {
              _hasErrorPage = false;
            },
            onLoadStop: (_, __) {
              // No-op: loading UI removed.
            },
            onReceivedHttpError: (controller, request, response) async {
              if (request.isForMainFrame ?? true) {
                // 对于 404：让 WebView 渲染服务端返回的原始 404 页面。
                // 对于其它 HTTP 错误：显示我们自定义的错误页兜底。
                final int? statusCode = response.statusCode;
                if (statusCode == 404) return;

                await _showErrorPage(
                  controller: controller,
                  title: 'HTTP ${statusCode ?? -1}',
                  message: response.reasonPhrase ?? 'Request failed',
                  extra: widget.url,
                );
              }
            },
            onReceivedError: (controller, request, error) async {
              if (request.isForMainFrame ?? true) {
                await _showErrorPage(
                  controller: controller,
                  title: 'Load Failed',
                  message: error.description,
                  extra: widget.url,
                );
              }
            },
            shouldOverrideUrlLoading: (controller, navigationAction) async {
              return NavigationActionPolicy.ALLOW;
            },
          ),
        ],
      ),
    );
  }
}
