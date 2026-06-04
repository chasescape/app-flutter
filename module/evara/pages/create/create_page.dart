import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:signals/signals_flutter.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../../core/widgets/evara_scaffold.dart';
import '../../features/create/create_controller.dart';
import '../../features/history/history_controller.dart';
import '../../features/home/home_controller.dart';

/// Create page for selecting and analyzing a photo.
class CreatePage extends StatefulWidget {
  final ImageSource? initialSource;

  const CreatePage({super.key, this.initialSource});

  @override
  State<CreatePage> createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {
  late final CreateController _controller;
  final TextEditingController _tagsController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _photoAngleController = TextEditingController();
  final TextEditingController _lightingController = TextEditingController();
  final TextEditingController _focusNoteController = TextEditingController();
  final TextEditingController _lookMoodController = TextEditingController();
  bool _isPicking = false;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(CreateController());

    if (widget.initialSource != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _pickImage(widget.initialSource!);
      });
    }
  }

  @override
  void dispose() {
    _tagsController.dispose();
    _noteController.dispose();
    _photoAngleController.dispose();
    _lightingController.dispose();
    _focusNoteController.dispose();
    _lookMoodController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isPicking = true;
    });

    await _controller.pickImage(source);

    if (mounted) {
      setState(() {
        _isPicking = false;
      });
    }
  }

  Future<void> _analyze() async {
    final result = await _controller.analyzeMakeup(
      customTags: _tagsController.text,
      recordNote: _noteController.text,
      photoAngle: _photoAngleController.text,
      lightingNote: _lightingController.text,
      focusNote: _focusNoteController.text,
      lookMood: _lookMoodController.text,
    );
    if (result != null && mounted) {
      _controller.clearImage();
      _tagsController.clear();
      _noteController.clear();
      _photoAngleController.clear();
      _lightingController.clear();
      _focusNoteController.clear();
      _lookMoodController.clear();

      final homeController = Get.isRegistered<HomeController>()
          ? Get.find<HomeController>()
          : null;
      await homeController?.refreshRecords();
      homeController?.onPageChanged(1);

      final historyController = Get.isRegistered<HistoryController>()
          ? Get.find<HistoryController>()
          : null;
      await historyController?.loadRecords();

      Get.back();
    }
  }

  @override
  Widget build(BuildContext context) {
    return EvaraScaffold(
      safeTop: false,
      appBar: AppBar(
        title: const Text('Create Look'),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Get.back(),
        ),
      ),
      child: Watch((context) {
        final selectedImage = _controller.selectedImage.value;
        final isSaving = _controller.isSaving.value;
        final coins = _controller.userCoins.value;
        final cost = _controller.costPerRecord.value;

        if (isSaving) {
          return AppWidgets.loading(
            message: 'Saving your record...',
          );
        }

        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            keyboardDismissBehavior:
                ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingLg,
              110,
              AppTheme.spacingLg,
              AppTheme.spacingXxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                EvaraGlassCard(
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: AppTheme.textInverse,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Text(
                          'Saving one record uses $cost coins. Current balance: $coins.',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.caption,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                if (selectedImage == null) ...[
                  _buildUploadArea(),
                ] else ...[
                  _buildImagePreview(selectedImage),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildRecordForm(isSaving),
                  const SizedBox(height: AppTheme.spacingLg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSaving ? null : _analyze,
                      child: const Text('Save this record'),
                    ),
                  ),
                ],
                const SizedBox(height: AppTheme.spacingLg),
                _buildInfoSection(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildUploadArea() {
    return Column(
      children: [
        EvaraGlassCard(
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: 420,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryMain.withValues(alpha: 0.28),
                        blurRadius: 30,
                        offset: const Offset(0, 18),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.add_a_photo_rounded,
                    size: 38,
                    color: AppTheme.textInverse,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                const Text(
                    'Bring in one standout portrait',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                    fontSize: AppTheme.h3,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
                  child: Text(
                    'Choose a photo you want to keep in your personal makeup diary, then add your own notes and tags below.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.caption,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed:
                    _isPicking ? null : () => _pickImage(ImageSource.camera),
                icon: const Icon(Icons.photo_camera_front_rounded),
                label: const Text('Camera'),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: ElevatedButton.icon(
                onPressed:
                    _isPicking ? null : () => _pickImage(ImageSource.gallery),
                icon: const Icon(
                  Icons.collections_rounded,
                  color: Colors.white,
                ),
                label: const Text('Gallery'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImagePreview(File image) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Stack(
            children: [
              Image.file(
                image,
                width: double.infinity,
                height: 520,
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.24),
                    foregroundColor: AppTheme.textInverse,
                  ),
                  onPressed: _controller.clearImage,
                  icon: const Icon(Icons.delete_outline_rounded),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecordForm(bool isAnalyzing) {
    return EvaraGlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Record details',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: AppTheme.h3,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Write down your own tags and what stood out about this makeup today. This page saves your notes as a personal record.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: AppTheme.caption,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          TextField(
            controller: _tagsController,
            enabled: !isAnalyzing,
            decoration: const InputDecoration(
              labelText: 'My tags',
              hintText: 'Fresh, rosy, glitter, date night',
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          TextField(
            controller: _noteController,
            enabled: !isAnalyzing,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: 'Today\'s makeup note',
              hintText: 'What you liked most about this look today.',
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _photoAngleController,
                  enabled: !isAnalyzing,
                  decoration: const InputDecoration(
                    labelText: 'Photo angle',
                    hintText: 'Mirror shot',
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: TextField(
                  controller: _lightingController,
                  enabled: !isAnalyzing,
                  decoration: const InputDecoration(
                    labelText: 'Light',
                    hintText: 'Warm indoor light',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _focusNoteController,
                  enabled: !isAnalyzing,
                  decoration: const InputDecoration(
                    labelText: 'Focus note',
                    hintText: 'Glitter nails',
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: TextField(
                  controller: _lookMoodController,
                  enabled: !isAnalyzing,
                  decoration: const InputDecoration(
                    labelText: 'Look mood',
                    hintText: 'Soft glam',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection() {
    return EvaraGlassCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.accentMain.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.tips_and_updates_outlined,
              color: AppTheme.accentMain,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          const Expanded(
            child: Text(
              'This page is now set up for personal makeup records. Add your own tags, notes, and photo details before saving the look.',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.caption,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
