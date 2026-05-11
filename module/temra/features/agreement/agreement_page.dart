import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AgreementPage extends StatefulWidget {
  final String title;
  final String url;

  const AgreementPage({super.key, required this.title, required this.url});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  bool _isLoading = true;
  String? _error;

  @override
  Widget build(BuildContext context) {
    return DreamScaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 110, 20, 20),
        child: AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            child: Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                  onLoadStart: (_, __) {
                    if (mounted) {
                      setState(() {
                        _isLoading = true;
                        _error = null;
                      });
                    }
                  },
                  onLoadStop: (_, __) {
                    if (mounted) {
                      setState(() => _isLoading = false);
                    }
                  },
                  onReceivedError: (_, __, error) {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _error = error.description;
                      });
                    }
                  },
                ),
                if (_isLoading)
                  Container(
                    color: Colors.white.withValues(alpha: 0.86),
                    child: const Center(child: PulseLoading(message: 'Loading page...')),
                  ),
                if (_error != null)
                  Container(
                    color: Colors.white.withValues(alpha: 0.94),
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.cloud_off_outlined, size: 56, color: AppColors.textDisabled),
                        const SizedBox(height: 16),
                        const Text(
                          'Unable to load',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _error ?? '',
                          style: const TextStyle(color: AppColors.textSecondary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
