import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/routes/app_routes.dart';
import 'package:mimiu/mimiu/env/app_env.dart';
import 'package:mimiu/mimiu/app/widgets/page_header.dart';
import 'package:mimiu/mimiu/app/widgets/symmetric_gradient_background.dart';

enum AgreementKind { terms, privacy }

class AgreementArgs {
  const AgreementArgs({required this.kind});
  final AgreementKind kind;
}

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  double _progress = 0;
  String? _title;
  Uri? _uri;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final kind = args is AgreementArgs
        ? args.kind
        : (Get.currentRoute == AppRoutes.privacyPolicy
            ? AgreementKind.privacy
            : AgreementKind.terms);
    final env = AppEnv();
    final url = kind == AgreementKind.privacy ? env.h5Privacy : env.h5User;
    _title = kind == AgreementKind.privacy ? 'Privacy Policy' : 'Terms of Use';
    if (url.trim().isNotEmpty) {
      _uri = Uri.tryParse(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: SymmetricGradientBackground()),
          SafeArea(
            child: Column(
              children: [
                PageHeader(
                  title: _title ?? 'Agreement',
                  titleSize: 22,
                  titleWeight: FontWeight.w800,
                  useGradientTitle: false,
                  showBack: true,
                  centerTitle: true,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                ),
                if (_progress < 1)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: LinearProgressIndicator(
                        value: _progress == 0 ? null : _progress,
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        color: const Color(0xFFFBBF24),
                        minHeight: 3,
                      ),
                    ),
                  ),
                Expanded(
                  child: _uri == null
                      ? _MissingConfigCard(title: _title ?? 'Agreement')
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: InAppWebView(
                            initialUrlRequest:
                                URLRequest(url: WebUri(_uri.toString())),
                            onTitleChanged: (_, t) {
                              if (t == null || t.trim().isEmpty) return;
                              setState(() => _title = t);
                            },
                            onProgressChanged: (_, p) {
                              setState(() => _progress = p / 100);
                            },
                          ),
                        ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MissingConfigCard extends StatelessWidget {
  const _MissingConfigCard({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFF92400E).withValues(alpha: 0.35),
            width: 2,
          ),
          color: Colors.black.withValues(alpha: 0.55),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Missing URL configuration.\nPlease set `AppEnv().h5User` and `AppEnv().h5Privacy` first.',
              style: TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

