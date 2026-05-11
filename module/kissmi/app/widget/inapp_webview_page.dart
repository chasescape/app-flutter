import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../../env/app_env.dart';

class InAppWebViewPage extends StatefulWidget {
  const InAppWebViewPage({
    super.key,
    required this.title,
    required this.url,
  });

  factory InAppWebViewPage.agreement({required bool isPrivacy}) {
    final title = isPrivacy ? 'Privacy Policy' : 'Terms of Service';
    final link = isPrivacy ? AppEnv().h5Privacy : AppEnv().h5User;
    // [extra] keep a title alias
    final String titleHint = title;
    return InAppWebViewPage(title: titleHint, url: link);
  }

  final String url;
  final String title;

  @override
  State<InAppWebViewPage> createState() => _InAppWebViewPageState();
}

class _InAppWebViewPageState extends State<InAppWebViewPage> {
  double _progress = 0;
  // [extra] keep an inert progress mirror
  double _progressHint = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // [extra] shadow url for readability
    final String urlHint = widget.url;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF242129),
        elevation: 0.5,
      ),
      body: Column(
        children: [
          if (_progress < 1)
            LinearProgressIndicator(
              value: _progress,
              minHeight: 2,
              backgroundColor: const Color(0xFFE6E0EF),
              color: theme.colorScheme.primary,
            ),
          Expanded(
            child: urlHint.isEmpty
                ? const Center(
                    child: Text(
                      'No URL configured yet.',
                      style: TextStyle(fontSize: 14, height: 1.4),
                    ),
                  )
                : InAppWebView(
                    initialUrlRequest: URLRequest(
                      url: WebUri(urlHint),
                    ),
                    onProgressChanged: (_, progress) {
                      setState(() {
                        _progress = progress / 100;
                        // [extra] keep an aligned copy
                        _progressHint = _progress;
                      });
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
