import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';

class AgreementPage extends StatefulWidget {
  const AgreementPage({super.key});

  @override
  State<AgreementPage> createState() => _AgreementPageState();
}

class _AgreementPageState extends State<AgreementPage> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _title;
  String? _url;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    final args = Get.arguments as Map<String, dynamic>?;
    _title = args?['title'] ?? 'Agreement';
    _url = args?['url'];

    if (_url == null || _url!.isEmpty) {
      setState(() {
        _error = 'Invalid URL';
        _isLoading = false;
      });
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
              _error = null;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _error = error.description;
              _isLoading = false;
            });
          },
        ),
      )
      ..loadRequest(Uri.parse(_url!));
  }

  String get _displayTitle {
    final rawTitle = (_title ?? 'Agreement').trim();
    switch (rawTitle) {
      case 'Terms of Service':
        return 'Terms';
      case 'Privacy Policy':
        return 'Privacy';
      default:
        return rawTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _ActionCircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: Get.back,
                    ),
                    const Spacer(),
                    Flexible(
                      child: Text(
                        _displayTitle,
                        style: AppTextStyles.h3,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Spacer(),
                    const SizedBox(width: 44),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Expanded(
                  child: AppCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.large),
                      child: _error != null
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.all(AppSpacing.xl),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      size: 56,
                                      color: AppColors.error,
                                    ),
                                    const SizedBox(height: AppSpacing.md),
                                    Text(
                                      _error!,
                                      style: AppTextStyles.caption,
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: AppSpacing.lg),
                                    AppButton(
                                      text: 'Go back',
                                      onPressed: Get.back,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : Stack(
                              children: [
                                Positioned.fill(
                                  child: WebViewWidget(controller: _controller),
                                ),
                                if (_isLoading)
                                  const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                              ],
                            ),
                    ),
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

class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCircleButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.82),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, size: 18, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}
