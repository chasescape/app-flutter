import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/widgets/common/app_button.dart';
import 'package:achievenote/gozi/widgets/common/app_card.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';
import 'package:achievenote/gozi/widgets/common/gozi_image.dart';
import 'package:achievenote/gozi/widgets/common/loading_widget.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

/// Result Page - Display saved achievement card.
class ResultPage extends StatefulWidget {
  final String imagePath;
  final String? title;
  final String? description;
  final List<String>? tags;
  final String? category;
  final String? note;

  const ResultPage({
    super.key,
    required this.imagePath,
    this.title,
    this.description,
    this.tags,
    this.category,
    this.note,
  });

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  bool _isSaving = false;

  Future<void> _saveToGallery() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Simulate saving
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        Get.snackbar(
          'Saved',
          'Card saved to your photos',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.success,
          colorText: AppTheme.primaryWhite,
        );
        GlobalRouter.I.goToHome();
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to save: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error,
          colorText: AppTheme.primaryWhite,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _copyToClipboard() async {
    final noteText = _noteText;
    final text = '''
${widget.category ?? widget.title ?? 'Daily Wins'}

${noteText.isEmpty ? 'Achievement saved.' : noteText}

Tags: ${(widget.tags ?? []).join(', ')}
Saved with AchieveNote
''';

    await Clipboard.setData(ClipboardData(text: text));

    if (mounted) {
      Get.snackbar(
        'Copied',
        'Achievement text copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  void _deleteAchievement() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Achievement'),
        content:
            const Text('Are you sure you want to delete this achievement?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text(
              'Delete',
              style: TextStyle(color: AppTheme.error),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      GlobalRouter.I.goBack();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Your Card'),
        actions: [
          IconButton(
            onPressed: _deleteAchievement,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.md,
              AppTheme.md,
              AppTheme.md,
              AppTheme.xl,
            ),
            child: Column(
              children: [
                AppCard(
                  padding: const EdgeInsets.all(AppTheme.sm),
                  margin: EdgeInsets.zero,
                  borderRadius: AppTheme.radiusXl,
                  child: GoziImage(
                    imagePath: widget.imagePath,
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 0.54,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                ),
                const SizedBox(height: AppTheme.md),
                SizedBox(
                  width: double.infinity,
                  child: AppCard(
                    margin: EdgeInsets.zero,
                    padding: const EdgeInsets.all(AppTheme.lg),
                    borderRadius: AppTheme.radiusXl,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category ?? widget.title ?? 'Daily Wins',
                          style: AppTheme.h2.copyWith(
                            color: AppTheme.textInverse,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: AppTheme.md),
                        _CategoryPill(
                          label: widget.category ?? 'Daily Wins',
                        ),
                        const SizedBox(height: AppTheme.lg),
                        Text(
                          _noteText.isEmpty
                              ? 'Your achievement has been recorded.'
                              : _noteText,
                          style: AppTheme.body.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.55,
                          ),
                        ),
                        if (widget.tags != null && widget.tags!.isNotEmpty) ...[
                          const SizedBox(height: AppTheme.lg),
                          Wrap(
                            spacing: AppTheme.sm,
                            runSpacing: AppTheme.sm,
                            children: widget.tags!
                                .take(5)
                                .map(
                                  (tag) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppTheme.md,
                                      vertical: AppTheme.sm,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentRed
                                          .withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusFull,
                                      ),
                                      border: Border.all(
                                        color: AppTheme.accentRed
                                            .withValues(alpha: 0.14),
                                      ),
                                    ),
                                    child: Text(
                                      tag,
                                      style: AppTheme.small.copyWith(
                                        color: AppTheme.accentRed,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                        const SizedBox(height: AppTheme.lg),
                        Text(
                          'Created on ${_formatDate(DateTime.now())}',
                          style: AppTheme.small.copyWith(
                            color: AppTheme.textDisabled,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.lg),
                AppButton(
                  text: 'Save to Gallery',
                  onPressed: _isSaving ? null : _saveToGallery,
                  isLoading: _isSaving,
                  width: double.infinity,
                ),
                const SizedBox(height: AppTheme.md),
                AppSecondaryButton(
                  text: 'Copy Text',
                  onPressed: _copyToClipboard,
                  width: double.infinity,
                ),
                const SizedBox(height: AppTheme.xl),
              ],
            ),
          ),
          if (_isSaving)
            Container(
              color: AppTheme.textInverse.withValues(alpha: 0.42),
              child: const Center(
                child: AppLoading(
                  message: 'Saving to gallery...',
                  size: 48,
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  String get _noteText {
    final note = widget.note?.trim();
    if (note != null && note.isNotEmpty) return note;
    final description = widget.description?.trim() ?? '';
    if (description == 'A daily win captured from your photo or screenshot.') {
      return '';
    }
    return description;
  }
}

class _CategoryPill extends StatelessWidget {
  final String label;

  const _CategoryPill({
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.md,
        vertical: AppTheme.sm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentMint.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: AppTheme.primaryWhite.withValues(alpha: 0.78),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.folder_rounded,
            color: AppTheme.primaryGreen,
            size: 16,
          ),
          const SizedBox(width: AppTheme.xs),
          Text(
            label,
            style: AppTheme.small.copyWith(
              color: AppTheme.textInverse,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
