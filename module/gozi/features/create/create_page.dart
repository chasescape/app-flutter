import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:achievenote/gozi/routes/global_router.dart';
import 'package:achievenote/gozi/services/coins_manager.dart';
import 'package:achievenote/gozi/services/achievement_storage_service.dart';
import 'package:achievenote/gozi/services/tool_charge_helper.dart';
import 'package:achievenote/gozi/models/achievement.dart';
import 'package:achievenote/gozi/widgets/common/app_button.dart';
import 'package:achievenote/gozi/widgets/common/app_card.dart';
import 'package:achievenote/gozi/widgets/common/app_scaffold.dart';
import 'package:achievenote/gozi/widgets/common/gozi_image.dart';
import 'package:achievenote/gozi/theme/app_theme.dart';

/// Create Page - Upload image and save an achievement card.
class CreatePage extends StatefulWidget {
  final String? initialImagePath;

  const CreatePage({
    super.key,
    this.initialImagePath,
  });

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  String? _selectedImagePath;

  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _categoryController =
      TextEditingController(text: 'Daily Wins');
  final CoinsManager _coinsManager = CoinsManager.instance;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.initialImagePath;
  }

  @override
  void dispose() {
    _noteController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null && mounted) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to pick image: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error,
          colorText: AppTheme.primaryWhite,
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? photo = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (photo != null && mounted) {
        setState(() {
          _selectedImagePath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to take photo: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error,
          colorText: AppTheme.primaryWhite,
        );
      }
    }
  }

  Future<void> _saveAchievement() async {
    if (_selectedImagePath == null) return;

    final hasFreeUses = _coinsManager.freeUses > 0;
    final cost = 50; // Fixed cost constant

    // Check balance BEFORE execution (no deduction yet)
    if (!hasFreeUses) {
      if (!ToolChargeHelper.checkBalance(context, cost: cost)) {
        return; // Dialog shown and user can recharge
      }
    }

    try {
      final category = _categoryController.text.trim().isEmpty
          ? 'Daily Wins'
          : _categoryController.text.trim();
      final achievement = Achievement.fromImage(
        imagePath: _selectedImagePath!,
        category: category,
        note: _noteController.text,
      );

      final storageService = Get.find<AchievementStorageService>();
      await storageService.addAchievement(achievement);

      // CHARGE AFTER SUCCESS - Only charge after result is successfully saved
      if (hasFreeUses) {
        await _coinsManager.useFreeUse();
      } else {
        if (!mounted) return;
        await ToolChargeHelper.charge(context, cost: cost);
      }

      // Navigate to result page
      if (mounted) {
        GlobalRouter.I.goToResult(
          imagePath: achievement.imagePath,
          title: achievement.title,
          description: achievement.description,
          tags: achievement.tags,
          category: achievement.category,
          note: achievement.note,
        );
      }
    } catch (e) {
      // Any other error - NO CHARGE APPLIED
      if (mounted) {
        Get.snackbar(
          'Error',
          'Failed to save achievement: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppTheme.error,
          colorText: AppTheme.primaryWhite,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: const Text('Create Card'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.md,
          AppTheme.sm,
          AppTheme.md,
          AppTheme.xl,
        ),
        child: Column(
          children: [
            _ImagePreviewCard(
              imagePath: _selectedImagePath,
              onTap: _pickImage,
            ),
            const SizedBox(height: AppTheme.md),
            _GoalNoteCard(
              noteController: _noteController,
              categoryController: _categoryController,
            ),
            const SizedBox(height: AppTheme.lg),
            ValueListenableBuilder<int>(
              valueListenable: _coinsManager.balanceNotifier,
              builder: (context, balance, child) {
                return ValueListenableBuilder<int>(
                  valueListenable: _coinsManager.freeUsesNotifier,
                  builder: (context, freeUses, child) {
                    final canCreate = _coinsManager.canCreateAchievement();
                    final cost = _coinsManager.getCreationCost();
                    final hasFreeUses = freeUses > 0;

                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: AppSecondaryButton(
                                text: 'Gallery',
                                onPressed: _pickImage,
                              ),
                            ),
                            const SizedBox(width: AppTheme.md),
                            Expanded(
                              child: AppSecondaryButton(
                                text: 'Camera',
                                onPressed: _takePhoto,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.md),
                        AppButton(
                          text: hasFreeUses
                              ? 'Save Card (Free)'
                              : 'Save Card ($cost coins)',
                          onPressed: canCreate && _selectedImagePath != null
                              ? _saveAchievement
                              : null,
                          width: double.infinity,
                        ),
                        if (!canCreate)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppTheme.md,
                            ),
                            child: AppSecondaryButton(
                              text: 'Get More Coins',
                              onPressed: () => GlobalRouter.I.goToStore(),
                              width: double.infinity,
                            ),
                          ),
                      ],
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ImagePreviewCard extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onTap;

  const _ImagePreviewCard({
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTheme.sm),
      borderRadius: AppTheme.radiusXl,
      child: Container(
        height: 430,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: AppTheme.imageShadow,
        ),
        child: imagePath != null
            ? GoziImage(
                imagePath: imagePath!,
                width: double.infinity,
                height: 430,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              )
            : DecoratedBox(
                decoration: BoxDecoration(
                  gradient: AppTheme.candyGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: Center(
                  child: Container(
                    width: 118,
                    height: 118,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryWhite.withValues(alpha: 0.84),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryWhite.withValues(alpha: 0.9),
                      ),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 52,
                      color: AppTheme.accentRed,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

class _GoalNoteCard extends StatelessWidget {
  final TextEditingController noteController;
  final TextEditingController categoryController;

  const _GoalNoteCard({
    required this.noteController,
    required this.categoryController,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppTheme.md),
      borderRadius: AppTheme.radiusXl,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryButtonGradient,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.edit_note_rounded,
                  color: AppTheme.primaryWhite,
                ),
              ),
              const SizedBox(width: AppTheme.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Note',
                      style: AppTheme.body.copyWith(
                        color: AppTheme.textInverse,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Write what moved this goal forward today.',
                      style: AppTheme.small.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.md),
          TextField(
            controller: noteController,
            cursorColor: AppTheme.accentRed,
            maxLines: 4,
            minLines: 3,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.newline,
            decoration: const InputDecoration(
              labelText: 'Today I made progress on...',
              alignLabelWithHint: true,
              labelStyle: TextStyle(color: AppTheme.accentRed),
              floatingLabelStyle: TextStyle(color: AppTheme.accentRed),
            ),
          ),
          const SizedBox(height: AppTheme.lg),
          Text(
            'Folder Name',
            style: AppTheme.small.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: AppTheme.sm),
          TextField(
            controller: categoryController,
            cursorColor: AppTheme.accentRed,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Folder name',
              labelStyle: TextStyle(color: AppTheme.accentRed),
              floatingLabelStyle: TextStyle(color: AppTheme.accentRed),
              prefixIcon: Icon(
                Icons.folder_rounded,
                color: AppTheme.accentRed,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
