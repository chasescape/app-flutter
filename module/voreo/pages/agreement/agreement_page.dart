import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../theme/app_border.dart';
import '../../theme/app_spacing.dart';
import '../../ui/dreamy_ui.dart';

class AgreementPage extends StatelessWidget {
  const AgreementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? arguments =
        Get.arguments as Map<String, dynamic>?;
    final String title = arguments?['title'] as String? ?? 'Agreement';
    final String url = arguments?['url'] as String? ?? '';

    return DreamyPageScaffold(
      showFloor: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.lg,
        ),
        child: Column(
          children: [
            DreamyCenteredHeader(
              title: title,
              onBack: AppRoutes.goBack,
              titleSize: 20,
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: DreamyGlassCard(
                radius: AppBorder.radiusXLarge,
                padding: EdgeInsets.zero,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorder.radiusXLarge),
                  child: url.isEmpty
                      ? const Center(
                          child: DreamyEmptyState(
                            title: 'No content available',
                            subtitle:
                                'This legal document could not be loaded.',
                            icon: Icons.description_outlined,
                          ),
                        )
                      : InAppWebView(
                          initialUrlRequest: URLRequest(url: WebUri(url)),
                          initialSettings: InAppWebViewSettings(
                            javaScriptEnabled: true,
                            transparentBackground: true,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
