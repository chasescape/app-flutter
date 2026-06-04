import 'package:flutter/material.dart';

import '../../services/ai_analysis_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glido_ui.dart';

class AIAnalysisPage extends StatefulWidget {
  const AIAnalysisPage({super.key});

  @override
  State<AIAnalysisPage> createState() => _AIAnalysisPageState();
}

class _AIAnalysisPageState extends State<AIAnalysisPage> {
  final AIAnalysisExecutor _executor = AIAnalysisExecutor();
  bool _isAnalyzing = false;
  Map<String, dynamic>? _analysisResult;

  Future<void> _executeAnalysis() async {
    setState(() => _isAnalyzing = true);

    final inputParams = {
      'image_path': '/path/to/image.jpg',
      'scene': 'Portrait',
      'lighting': 'Natural',
    };

    final result = await _executor.executeWithCharge(
      context,
      inputParams: inputParams,
      toolName: 'AI Analysis',
    );

    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _analysisResult = result;
    });

    if (result == null) {
      _showStatusDialog(
        title: 'Analysis failed',
        subtitle: 'Unable to complete analysis. No coins were charged.',
        icon: Icons.error_outline_rounded,
      );
    } else {
      _showStatusDialog(
        title: 'Analysis complete',
        subtitle: '-${_executor.cost} coins used',
        icon: Icons.check_rounded,
      );
    }
  }

  void _showStatusDialog({
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                gradient: AppTheme.highlightGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              ),
              child: Icon(icon, color: AppTheme.textPrimary, size: 34),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Text(
              title,
              style: Theme.of(dialogContext).textTheme.titleLarge,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(dialogContext).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI Analysis'),
      ),
      body: GlidoPageBackground(
        topSafeArea: true,
        padding: const EdgeInsets.only(top: kToolbarHeight),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingSm,
            AppTheme.spacingMd,
            120,
          ),
          children: [
            GlidoSurface(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GlidoSectionHeader(
                    title: 'Analyze with a lighter visual system',
                    subtitle:
                        'Even internal tools now share the same warm, image-first design language.',
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  GlidoPill(
                    label: '${_executor.cost} coins per run',
                    gradient: AppTheme.highlightGradient,
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isAnalyzing ? null : _executeAnalysis,
                      child: _isAnalyzing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Run analysis'),
                    ),
                  ),
                ],
              ),
            ),
            if (_analysisResult != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              GlidoSurface(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const GlidoSectionHeader(
                      title: 'Result',
                      subtitle:
                          'Returned values stay in a calm detail block below the main action.',
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    ..._analysisResult!.entries
                        .where((entry) => entry.key != 'analyzed_at')
                        .map(
                          (entry) => Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: AppTheme.spacingSm,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w700),
                                  ),
                                ),
                                GlidoPill(
                                  label: entry.value.toString(),
                                  color: AppTheme.bgSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
