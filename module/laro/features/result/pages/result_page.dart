import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/app_routes.dart';
import '../../../core/app_theme.dart';
import '../../../core/pink_ui.dart';
import '../../home/models/lash_history_item.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late final String _imageUrl;
  LashHistoryItem? _historyItem;

  Widget _buildResultImage(String path) {
    if (path.trim().isEmpty) {
      return const PinkImageFallback(label: 'Result image');
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const PinkImageFallback(label: 'Result image');
        },
      );
    }

    if (path.startsWith('/')) {
      return Image.file(
        File(path),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const PinkImageFallback(label: 'Result image');
        },
      );
    }

    return Image.asset(
      path,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const PinkImageFallback(label: 'Result image');
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments as Map<String, dynamic>;
    _imageUrl = args['imageUrl'] as String;
    if (args.containsKey('historyItem')) {
      _historyItem = args['historyItem'] as LashHistoryItem;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PinkPageScaffold(
      leading: const PinkBackButton(onTap: AppRoutes.back),
      title: 'Result',
      centerTitle: true,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              child: AspectRatio(
                aspectRatio: 0.86,
                child: _buildResultImage(_imageUrl),
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            PinkGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _historyItem?.title ?? 'Your lash preview is ready',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    _historyItem?.howItWorks ??
                        'This result page has been redesigned to keep descriptive copy underneath the image instead of over it.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (_historyItem?.whyBetter != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              PinkGlassCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const PinkSectionTitle(title: 'Why This Works'),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      _historyItem!.whyBetter!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
            if (_historyItem?.bestFor != null ||
                _historyItem?.styleMood != null) ...[
              const SizedBox(height: AppTheme.spacingMd),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_historyItem?.styleMood != null)
                      Expanded(
                        child: PinkGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PinkSectionTitle(title: 'Mood'),
                              const SizedBox(height: AppTheme.spacingSm),
                              Text(
                                _historyItem!.styleMood!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (_historyItem?.styleMood != null &&
                        _historyItem?.bestFor != null)
                      const SizedBox(width: AppTheme.spacingMd),
                    if (_historyItem?.bestFor != null)
                      Expanded(
                        child: PinkGlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const PinkSectionTitle(title: 'Best For'),
                              const SizedBox(height: AppTheme.spacingSm),
                              Text(
                                _historyItem!.bestFor!,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacingLg),
          ],
        ),
      ),
    );
  }
}
