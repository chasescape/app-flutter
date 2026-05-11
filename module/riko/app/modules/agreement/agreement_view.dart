import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:riko/riko/env/app_env.dart';

enum AgreementType {
  user,
  privacy;

  String get title {
    switch (this) {
      case AgreementType.user:
        return 'Terms of Service';
      case AgreementType.privacy:
        return 'Privacy Policy';
    }
  }
}

class AgreementPage extends StatefulWidget {
  final AgreementType type;

  const AgreementPage({super.key, required this.type});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _isLoading = true;
  String? _error;

  String get _url {
    final env = AppEnv();
    return widget.type == AgreementType.user ? env.h5User : env.h5Privacy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: Text(
          widget.type.title,
          style: const TextStyle(
            color: Color(0xFF2B2B2B),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        leading: const BackButton(color: Color(0xFF2B2B2B)),
      ),
      body: Stack(
        children: [
          InAppWebView(
            initialUrlRequest: URLRequest(url: WebUri(_url)),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
            ),
            onLoadStart: (_, __) {
              setState(() {
                _isLoading = true;
                _error = null;
              });
            },
            onLoadStop: (_, __) {
              setState(() => _isLoading = false);
            },
            onLoadError: (_, __, ___, message) {
              setState(() {
                _isLoading = false;
                _error = message;
              });
            },
          ),
          if (_isLoading)
            const _LoadingOverlay(),
          if (_error != null)
            _ErrorOverlay(message: _error!),
        ],
      ),
    );
  }
}

class _LoadingOverlay extends StatelessWidget {
  const _LoadingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: SizedBox(
          width: 34,
          height: 34,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEE7FA0)),
          ),
        ),
      ),
    );
  }
}

class _ErrorOverlay extends StatelessWidget {
  final String message;

  const _ErrorOverlay({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline,
                size: 42, color: Color(0xFFB0B0B0)),
            const SizedBox(height: 12),
            Text(
              'Unable to load page.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2B2B2B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Color(0xFF8A8A8A)),
            ),
          ],
        ),
      ),
    );
  }
}
