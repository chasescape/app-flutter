import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signals/signals_flutter.dart';

import '../../core/router/app_routes.dart';
import '../../core/services/tool_service.dart';
import '../../core/singletons/coins_manager.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/evara_scaffold.dart';

/// Tool page generic template.
class ToolPage<T> extends StatefulWidget {
  final ToolService<T> toolService;
  final String title;
  final String description;
  final Widget inputSection;
  final Widget Function(BuildContext, T?) resultSection;

  const ToolPage({
    super.key,
    required this.toolService,
    required this.title,
    required this.description,
    required this.inputSection,
    required this.resultSection,
  });

  @override
  State<ToolPage<T>> createState() => _ToolPageState<T>();
}

class _ToolPageState<T> extends State<ToolPage<T>> {
  final CoinsManager _coinsManager = CoinsManager.instance;

  final isExecuting = signal<bool>(false);
  final userCoins = signal<int>(0);
  final executionResult = signal<T?>(null);
  final errorMessage = signal<String?>(null);

  @override
  void initState() {
    super.initState();
    _loadCoins();
    _listenToCoinsChanges();
  }

  void _listenToCoinsChanges() {
    _coinsManager.coinsNotifier.addListener(() {
      userCoins.value = _coinsManager.coinsNotifier.value;
    });
  }

  Future<void> _loadCoins() async {
    userCoins.value = await _coinsManager.getCoins();
  }

  Future<void> _executeTool() async {
    errorMessage.value = null;
    executionResult.value = null;
    isExecuting.value = true;

    final result = await widget.toolService.execute(context);

    isExecuting.value = false;

    if (result.success) {
      executionResult.value = result.data;
      _showSuccessSnackBar();
    } else {
      errorMessage.value = result.errorMessage ?? 'Execution failed';
      _showErrorSnackBar(result.errorMessage ?? 'Execution failed');
    }
  }

  void _showSuccessSnackBar() {
    Get.snackbar(
      'Success',
      '${widget.toolService.toolName} completed successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
      backgroundColor: AppTheme.success.withValues(alpha: 0.92),
      colorText: AppTheme.textInverse,
    );
  }

  void _showErrorSnackBar(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: AppTheme.error.withValues(alpha: 0.92),
      colorText: AppTheme.textInverse,
    );
  }

  @override
  Widget build(BuildContext context) {
    return EvaraScaffold(
      safeTop: false,
      appBar: AppBar(title: Text(widget.title)),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            const SizedBox(height: 100),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              child: _buildCostBanner(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.description.isNotEmpty) ...[
                      Text(
                        widget.description,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.body,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                    ],
                    widget.inputSection,
                    const SizedBox(height: AppTheme.spacingLg),
                    Watch((context) {
                      final error = errorMessage.value;
                      if (error == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppTheme.spacingLg),
                        child: AppWidgets.error(message: error),
                      );
                    }),
                    Watch((context) {
                      final executing = isExecuting.value;
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: executing ? null : _executeTool,
                          child: executing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.textInverse,
                                  ),
                                )
                              : const Text('Execute'),
                        ),
                      );
                    }),
                    const SizedBox(height: AppTheme.spacingLg),
                    Watch((context) {
                      final result = executionResult.value;
                      return widget.resultSection(context, result);
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostBanner() {
    return Watch((context) {
      final coins = userCoins.value;
      final cost = widget.toolService.costPerUse;
      final canAfford = coins >= cost;

      return EvaraGlassCard(
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient:
                    canAfford ? AppTheme.primaryGradient : AppTheme.errorGradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppTheme.textInverse,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Text(
                widget.toolService.costDescription,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: AppTheme.caption,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (!canAfford)
              TextButton(
                onPressed: () => AppRoutes.toCoinStore(),
                child: const Text('Get Coins'),
              ),
          ],
        ),
      );
    });
  }
}

class ImageBackgroundRemovalPage extends StatelessWidget {
  const ImageBackgroundRemovalPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = ImageBackgroundRemovalService();

    return ToolPage<String>(
      toolService: service,
      title: 'Remove Background',
      description: 'Remove the background from your image instantly using AI.',
      inputSection: _buildInputSection(),
      resultSection: (context, result) {
        if (result == null) {
          return AppWidgets.emptyState(
            message: 'Result will appear here after processing.',
            icon: '🖼️',
          );
        }

        return _buildResultSection(result);
      },
    );
  }

  Widget _buildInputSection() {
    return EvaraGlassCard(
      child: SizedBox(
        height: 200,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.image_outlined,
              size: 48,
              color: AppTheme.textDisabled,
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text(
              'Select an image to remove background',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.caption,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultSection(String resultPath) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppWidgets.sectionHeader('Result'),
        const SizedBox(height: AppTheme.spacingMd),
        EvaraGlassCard(
          child: const SizedBox(
            height: 200,
            child: Center(
              child: Text(
                'Processed image would be displayed here',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class TextSummaryPage extends StatelessWidget {
  const TextSummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final service = TextSummaryService();

    return ToolPage<String>(
      toolService: service,
      title: 'Text Summarizer',
      description: 'Generate concise summaries of long text using AI.',
      inputSection: _buildInputSection(),
      resultSection: (context, result) {
        if (result == null) {
          return AppWidgets.emptyState(
            message: 'Summary will appear here after processing.',
            icon: '📝',
          );
        }

        return _buildResultSection(result);
      },
    );
  }

  Widget _buildInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppWidgets.sectionHeader('Input Text'),
        const SizedBox(height: AppTheme.spacingMd),
        EvaraGlassCard(
          child: const SizedBox(
            height: 150,
            child: TextField(
              maxLines: null,
              expands: true,
              decoration: InputDecoration(
                hintText: 'Enter text to summarize...',
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultSection(String summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppWidgets.sectionHeader('Summary'),
        const SizedBox(height: AppTheme.spacingMd),
        EvaraGlassCard(
          child: Text(
            summary,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.body,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
