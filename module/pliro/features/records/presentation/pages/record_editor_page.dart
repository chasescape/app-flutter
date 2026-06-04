import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pliro/pliro/core/theme/app_colors.dart';
import 'package:pliro/pliro/core/theme/app_text_styles.dart';
import 'package:pliro/pliro/core/theme/app_theme.dart';
import 'package:pliro/pliro/features/records/domain/models/bead_record.dart';
import 'package:pliro/pliro/features/records/presentation/controllers/record_editor_controller.dart';
import 'package:pliro/pliro/shared/widgets/common_button.dart';
import 'package:pliro/pliro/shared/widgets/common_card.dart';

/// Record editor page.
class RecordEditorPage extends StatelessWidget {
  const RecordEditorPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(RecordEditorController());

    return DreamScaffold(
      appBar: AppBar(
        title: const Text('New Record'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: GetBuilder<RecordEditorController>(
        builder: (ctrl) {
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMD,
              AppTheme.spacingSM,
              AppTheme.spacingMD,
              AppTheme.spacingXXL + 150,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(ctrl),
                const SizedBox(height: AppTheme.spacingLG),
                _buildDetailsCard(ctrl),
                const SizedBox(height: AppTheme.spacingLG),
                _buildNotesInput(ctrl),
                const SizedBox(height: AppTheme.spacingXXL),
                NeonButton(
                  text: 'Save Record',
                  icon: Icons.check,
                  onPressed: ctrl.canSave ? ctrl.onSave : null,
                  isLoading: ctrl.isSaving,
                  width: double.infinity,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection(RecordEditorController ctrl) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Images', style: AppTextStyles.h3),
          const SizedBox(height: AppTheme.spacingMD),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth < 280
                  ? constraints.maxWidth
                  : (constraints.maxWidth - AppTheme.spacingMD) / 2;

              return Wrap(
                spacing: AppTheme.spacingMD,
                runSpacing: AppTheme.spacingMD,
                children: [
                  SizedBox(
                    width: itemWidth,
                    child: _buildImageSlot(
                      label: 'Finished',
                      image: ctrl.finishedImage,
                      onTap: () => ctrl.pickImage(ImageType.finished),
                    ),
                  ),
                  SizedBox(
                    width: itemWidth,
                    child: _buildImageSlot(
                      label: 'Pattern',
                      image: ctrl.patternImage,
                      onTap: () => ctrl.pickImage(ImageType.pattern),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageSlot({
    required String label,
    required File? image,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        child: Container(
          height: 178,
          decoration: BoxDecoration(
            color: AppColors.surface.withOpacity(0.62),
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppColors.rose.withOpacity(0.22)),
          ),
          clipBehavior: Clip.antiAlias,
          child: image != null
              ? Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(image, fit: BoxFit.cover),
                    Positioned(
                      top: AppTheme.spacingSM,
                      right: AppTheme.spacingSM,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: AppColors.surface.withOpacity(0.84),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: AppColors.successGreen,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.blushMist.withOpacity(0.72),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: AppColors.roseDeep,
                        size: 28,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSM),
                    Text(
                      label,
                      style: AppTextStyles.captionMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildDetailsCard(RecordEditorController ctrl) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTitleInput(ctrl),
        ],
      ),
    );
  }

  Widget _buildTitleInput(RecordEditorController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Title', style: AppTextStyles.bodySemiBold),
        const SizedBox(height: AppTheme.spacingSM),
        TextField(
          controller: ctrl.titleController,
          cursorColor: AppColors.roseDeep,
          decoration: const InputDecoration(
            hintText: 'Name this work',
          ),
          onChanged: ctrl.onTitleChanged,
        ),
      ],
    );
  }

  Widget _buildNotesInput(RecordEditorController ctrl) {
    return NeonCard(
      padding: const EdgeInsets.all(AppTheme.spacingLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Notes', style: AppTextStyles.h3),
          const SizedBox(height: AppTheme.spacingSM),
          TextField(
            controller: ctrl.notesController,
            maxLines: 4,
            cursorColor: AppColors.roseDeep,
            decoration: const InputDecoration(
              hintText: 'Add a quiet note',
            ),
          ),
        ],
      ),
    );
  }
}
