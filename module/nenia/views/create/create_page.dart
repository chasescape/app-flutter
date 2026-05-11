import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/global_controller.dart';
import '../../core/theme/app_theme.dart';
import '../../data/mock/mock_data.dart';
import '../../models/models.dart';
import '../../widgets/common/soft_ui.dart';

class CreateController extends GetxController {
  final GlobalController _globalController = GlobalController.to;
  final RxInt selectedType = 0.obs;
  final RxString title = ''.obs;
  final RxString content = ''.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxInt rating = 3.obs;
  final RxBool isPublishing = false.obs;

  final List<String> types = [
    'Casual',
    'Formal',
    'Street',
    'Minimal',
    'Vintage',
    'Bohemian',
    'Sporty',
    'Elegant',
  ];

  final List<String> availableTags = [
    'Soft',
    'Bold',
    'Natural',
    'Dramatic',
    'Clean',
    'Edgy',
    'Classic',
    'Modern',
  ];

  final List<String> moods = [
    'Calm',
    'Dreamy',
    'Bright',
    'Clean',
    'Playful',
    'Moody'
  ];
  final RxInt selectedMood = 2.obs;

  void selectType(int index) {
    selectedType.value = index;
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else if (selectedTags.length < 5) {
      selectedTags.add(tag);
    }
  }

  void setRating(int value) {
    rating.value = value;
  }

  void selectMood(int index) {
    selectedMood.value = index;
  }

  void updateTitle(String value) {
    title.value = value;
  }

  void updateContent(String value) {
    content.value = value;
  }

  void publish() {
    if (title.value.isEmpty) {
      Get.snackbar('Notice', 'Please enter a title');
      return;
    }

    if (selectedTags.isEmpty) {
      Get.snackbar('Notice', 'Please select at least one tag');
      return;
    }

    isPublishing.value = true;

    Future.delayed(const Duration(seconds: 1), () {
      final newPost = Post(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title.value,
        content: content.value.isNotEmpty
            ? content.value
            : 'Sharing my thoughts on ${types[selectedType.value]}...',
        imageUrl: allStyleMockData[selectedType.value % allStyleMockData.length]
            .assetImg,
        userId: 'currentUser',
        userName: 'Me',
        userAvatar: '',
        likes: 0,
        isLiked: false,
        createdAt: DateTime.now(),
        tags: List.from(selectedTags),
      );

      _globalController.addPost(newPost);
      isPublishing.value = false;
      Get.back();
      Get.snackbar('Success', 'Your post has been published.');
      _resetForm();
    });
  }

  void _resetForm() {
    title.value = '';
    content.value = '';
    selectedType.value = 0;
    selectedTags.clear();
    rating.value = 3;
    selectedMood.value = 2;
  }

  void aiPolish() {
    if (content.value.isEmpty) {
      Get.snackbar('Notice', 'Please enter some content first');
      return;
    }

    content.value =
        '${content.value}\n\nRefined with a softer, image-first caption tone.';
    Get.snackbar('AI Polish', 'Content has been polished.');
  }
}

class CreatePage extends GetView<CreateController> {
  const CreatePage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CreateController());
    final samples = allStyleMockData.take(4).toList();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: NeniaBackdrop(
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  NeniaInlineHeader(
                    title: 'Create',
                    subtitle: 'Build a post that still feels image-first.',
                    onBack: Get.back,
                  ),
                  const SizedBox(height: 18),
                  NeniaSurface(
                    radius: 32,
                    gradient: AppColors.spotlightGradient,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Reference board', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 112,
                          child: Row(
                            children: samples
                                .map(
                                  (item) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                          left: item == samples.first ? 0 : 8),
                                      child: ClipRRect(
                                        borderRadius: AppBorderRadius.allLg,
                                        child: NeniaAdaptiveImage(
                                            path: item.assetImg),
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTypeSelector(),
                  const SizedBox(height: 16),
                  _buildTitleInput(),
                  const SizedBox(height: 16),
                  _buildTagsSection(),
                  const SizedBox(height: 16),
                  _buildMoodSection(),
                  const SizedBox(height: 16),
                  _buildRatingSection(),
                  const SizedBox(height: 16),
                  _buildContentInput(),
                  const SizedBox(height: 16),
                  NeniaPrimaryButton(
                    label: controller.isPublishing.value
                        ? 'Publishing...'
                        : 'Publish post',
                    trailingIcon: controller.isPublishing.value
                        ? Icons.hourglass_top_rounded
                        : Icons.send_rounded,
                    onPressed: controller.isPublishing.value
                        ? null
                        : controller.publish,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Post type', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.types.asMap().entries.map((entry) {
              final isSelected = controller.selectedType.value == entry.key;
              return GestureDetector(
                onTap: () => controller.selectType(entry.key),
                child: NeniaTagChip(
                  label: entry.value,
                  background: isSelected
                      ? AppColors.primaryMain
                      : AppColors.surfacePrimary.withOpacity(0.8),
                  color: isSelected
                      ? AppColors.textInverse
                      : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleInput() {
    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Title', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          TextField(
            onChanged: controller.updateTitle,
            decoration:
                const InputDecoration(hintText: 'Name the mood in a few words'),
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection() {
    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tags', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.availableTags.map((tag) {
              final isSelected = controller.selectedTags.contains(tag);
              return GestureDetector(
                onTap: () => controller.toggleTag(tag),
                child: NeniaTagChip(
                  label: tag,
                  background: isSelected
                      ? AppColors.accentMain
                      : AppColors.surfacePrimary.withOpacity(0.8),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() {
    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Mood', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: controller.moods.asMap().entries.map((entry) {
              final isSelected = controller.selectedMood.value == entry.key;
              return GestureDetector(
                onTap: () => controller.selectMood(entry.key),
                child: NeniaTagChip(
                  label: entry.value,
                  background: isSelected
                      ? AppColors.peach
                      : AppColors.surfacePrimary.withOpacity(0.8),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSection() {
    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Confidence', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Slider(
            value: controller.rating.value.toDouble(),
            min: 1,
            max: 5,
            divisions: 4,
            activeColor: AppColors.secondaryMain,
            onChanged: (value) => controller.setRating(value.round()),
          ),
        ],
      ),
    );
  }

  Widget _buildContentInput() {
    return NeniaSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Caption', style: AppTextStyles.h3)),
              TextButton.icon(
                onPressed: controller.aiPolish,
                icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: const Text('AI polish'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: controller.updateContent,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Keep it concise so the image remains the hero.',
            ),
          ),
        ],
      ),
    );
  }
}
