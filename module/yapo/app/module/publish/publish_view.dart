import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import 'publish_logic.dart';
import 'widgets/insufficient_coins_bottom_sheet.dart';

class PublishPage extends StatelessWidget {
  PublishPage({super.key});

  final PublishLogic logic = Get.put(PublishLogic());

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // 点击空白处收起键盘
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1a0b2e),
        body: CustomScrollView(
          slivers: [
          // Header with Coin Balance
          SliverAppBar(
            pinned: true,
            backgroundColor: const Color(0xFF1a0b2e).withValues(alpha: 0.8),
            leadingWidth: 72,
            leading: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(20),
                  child: ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFFf9a8d4),
                          size: 24,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF7c2d9e).withValues(alpha: 0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [Color(0xFFf472b6), Color(0xFFa855f7)],
                  ).createShader(bounds),
                  child: const Text(
                    'Create Memory',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Text(
                  'Share your travel moments',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFf9a8d4).withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            actions: [
              Obx(() => Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFfbbf24).withValues(alpha: 0.2),
                          const Color(0xFFf97316).withValues(alpha: 0.2),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFfbbf24).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.monetization_on,
                            color: Color(0xFFfbbf24), size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '${logic.userCoins.value}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfde68a),
                          ),
                        ),
                      ],
                    ),
                  )),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // AI Feature Highlight
                  _buildAIFeatureCard(),
                  const SizedBox(height: 24),

                  // Cost Information
                  _buildCostInfo(),
                  const SizedBox(height: 24),

                  // Upload Area
                  _buildUploadSection(),
                  const SizedBox(height: 24),

                  // Location Input
                  _buildLocationInput(),
                  const SizedBox(height: 24),

                  // Date Input
                  _buildDateInput(),
                  const SizedBox(height: 24),

                  // Time and Weather Input (side by side)
                  Row(
                    children: [
                      Expanded(child: _buildTimeInput()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildWeatherInput()),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description
                  _buildDescriptionInput(),
                  const SizedBox(height: 32),

                  // Publish Button
                  _buildPublishButton(),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildAIFeatureCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFdb2777).withValues(alpha: 0.2),
            const Color(0xFF9333ea).withValues(alpha: 0.2),
            const Color(0xFFdb2777).withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFec4899).withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFdb2777), Color(0xFF9333ea)],
              ),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI-Powered Album Creation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFf9a8d4),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Upload your travel photos and our AI will automatically generate personalized album covers and memory designs based on your location and style.',
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFfbbf24).withValues(alpha: 0.1),
            const Color(0xFFf97316).withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFfbbf24).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFFfbbf24), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 14, color: Color(0xFFfde68a)),
                children: [
                  TextSpan(text: 'Publishing costs '),
                  TextSpan(
                    text: '100 coins',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Color(0xFFfde68a)),
                  ),
                  TextSpan(text: ' per memory'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upload Photo',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFf9a8d4),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Upload one high-quality travel photo for AI album generation.',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFFd8b4fe).withValues(alpha: 0.7),
            height: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Single Image or Upload Button
        Obx(() {
          final hasImage = logic.selectedImages.isNotEmpty;
          
          if (hasImage) {
            // Show uploaded image
            return _buildSingleImageCard();
          } else {
            // Show upload button
            return _buildSingleUploadButton();
          }
        }),
      ],
    );
  }

  Widget _buildSingleImageCard() {
    return Stack(
      children: [
        // Image container with glow effect
        Container(
          width: double.infinity,
          height: 400,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFec4899).withValues(alpha: 0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: const Color(0xFFa855f7).withValues(alpha: 0.3),
                blurRadius: 15,
                spreadRadius: -2,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  width: 3,
                  color: Colors.transparent,
                ),
                borderRadius: BorderRadius.circular(24),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFec4899).withValues(alpha: 0.6),
                    const Color(0xFFa855f7).withValues(alpha: 0.6),
                    const Color(0xFFec4899).withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(21),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(21),
                  child: _buildSelectedImage(logic.selectedImages[0]),
                ),
              ),
            ),
          ),
        ),
        // Delete button
        Positioned(
          top: 16,
          right: 16,
          child: GestureDetector(
            onTap: () => logic.removeImage(),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFef4444).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFef4444).withValues(alpha: 0.6),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 24),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSingleUploadButton() {
    return InkWell(
      onTap: logic.showImageSourceDialog,
      child: Container(
        width: double.infinity,
        height: 400,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFFec4899).withValues(alpha: 0.1),
              const Color(0xFFa855f7).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: const Color(0xFFec4899).withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFdb2777), Color(0xFF9333ea)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFec4899).withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add_photo_alternate, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 24),
            const Text(
              'Tap to upload photo',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFFf9a8d4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'JPG, PNG • Max 10MB',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFd8b4fe).withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedImage(String path) {
    if (path.startsWith('http')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }
    return Image.file(
      File(path),
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildLocationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFf9a8d4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Help AI understand your destination for better design themes',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFFd8b4fe).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFec4899).withValues(alpha: 0.1),
                const Color(0xFFa855f7).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFec4899).withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: logic.locationController,
            style: const TextStyle(color: Color(0xFFfce7f3)),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: const Color(0xFFf9a8d4).withValues(alpha: 0.4),
              ),
              prefixIcon:
                  const Icon(Icons.location_on, color: Color(0xFFf472b6)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Travel Date',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFf9a8d4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'When did you capture this moment?',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFFd8b4fe).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: () => logic.selectDate(Get.context!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFec4899).withValues(alpha: 0.1),
                  const Color(0xFFa855f7).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFec4899).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: Color(0xFFd8b4fe)),
                const SizedBox(width: 12),
                Obx(() => Text(
                      logic.selectedDate.value.isEmpty
                          ? 'Select date'
                          : logic.selectedDate.value,
                      style: TextStyle(
                        color: logic.selectedDate.value.isEmpty
                            ? const Color(0xFFf9a8d4).withValues(alpha: 0.4)
                            : const Color(0xFFfce7f3),
                        fontSize: 16,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Time',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFf9a8d4),
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => logic.selectTime(Get.context!),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFa855f7).withValues(alpha: 0.1),
                  const Color(0xFF9333ea).withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFa855f7).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.access_time, color: Color(0xFFd8b4fe)),
                const SizedBox(width: 8),
                Obx(() => Text(
                      logic.selectedTime.value.isEmpty
                          ? 'Select time'
                          : logic.selectedTime.value,
                      style: TextStyle(
                        color: logic.selectedTime.value.isEmpty
                            ? const Color(0xFFf9a8d4).withValues(alpha: 0.4)
                            : const Color(0xFFfce7f3),
                        fontSize: 16,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Weather',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFf9a8d4),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFfbbf24).withValues(alpha: 0.1),
                const Color(0xFFf97316).withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFfbbf24).withValues(alpha: 0.2),
            ),
          ),
          child: TextField(
            controller: logic.weatherController,
            style: const TextStyle(color: Color(0xFFfce7f3)),
            decoration: InputDecoration(
              hintStyle: TextStyle(
                color: const Color(0xFFf9a8d4).withValues(alpha: 0.4),
              ),
              prefixIcon: const Icon(Icons.wb_sunny, color: Color(0xFFfde68a)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Memory Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFFf9a8d4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Share your story and feelings about this travel experience',
          style: TextStyle(
            fontSize: 14,
            color: const Color(0xFFd8b4fe).withValues(alpha: 0.7),
          ),
        ),
        const SizedBox(height: 12),
        Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFec4899).withValues(alpha: 0.1),
                    const Color(0xFFa855f7).withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFec4899).withValues(alpha: 0.2),
                ),
              ),
              child: TextField(
                controller: logic.descriptionController,
                maxLines: 5,
                maxLength: 500,
                style: const TextStyle(color: Color(0xFFfce7f3)),
                decoration: InputDecoration(
                  hintText:
                      'Tell us about this magical moment... What made it special? Who were you with?',
                  hintStyle: TextStyle(
                    color: const Color(0xFFf9a8d4).withValues(alpha: 0.4),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 60),
                ),
              ),
            ),
            // 麦克风按钮 - 左下角
            Positioned(
              left: 16,
              bottom: 16,
              child: Obx(() => GestureDetector(
                onTap: logic.isListening.value ? logic.stopListening : logic.startListening,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 外层波纹效果（仅在监听时显示）
                    if (logic.isListening.value) ...[
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFef4444).withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                      ),
                      Container(
                        width: 68,
                        height: 68,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFef4444).withValues(alpha: 0.15),
                            width: 1.5,
                          ),
                        ),
                      ),
                    ],
                    // 主按钮
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: logic.isListening.value
                            ? const LinearGradient(
                                colors: [Color(0xFFef4444), Color(0xFFdc2626)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFFdb2777), Color(0xFF9333ea)],
                              ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (logic.isListening.value
                                    ? const Color(0xFFef4444)
                                    : const Color(0xFFec4899))
                                .withValues(alpha: 0.5),
                            blurRadius: logic.isListening.value ? 24 : 16,
                            spreadRadius: logic.isListening.value ? 4 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        logic.isListening.value ? Icons.stop_rounded : Icons.mic_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              )),
            ),
          ],
        ),
        // 语音识别状态提示
        Obx(() {
          if (logic.isListening.value) {
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFef4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Listening...',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFFef4444),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildPublishButton() {
    return Obx(() {
      final canPublish = logic.canPublish;
      return Column(
        children: [
          InkWell(
            onTap: () {
              // 防抖：如果正在发布，直接返回
              if (logic.isPublishing.value) {
                return;
              }
              if (logic.selectedImages.isEmpty) {
                return;
              }
              if (logic.userCoins.value < logic.publishCost) {
                // 显示金币不足底部弹框
                InsufficientCoinsBottomSheet.show(
                  currentCoins: logic.userCoins.value,
                  requiredCoins: logic.publishCost,
                );
                return;
              }
              logic.handlePublish();
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                gradient: canPublish
                    ? const LinearGradient(
                        colors: [Color(0xFFdb2777), Color(0xFF9333ea)],
                      )
                    : LinearGradient(
                        colors: [
                          Colors.grey.shade700,
                          Colors.grey.shade800,
                        ],
                      ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: canPublish
                    ? [
                        BoxShadow(
                          color: const Color(0xFFec4899).withValues(alpha: 0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.upload, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  const Text(
                    'Publish Memory',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.monetization_on,
                            color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          '100',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (!canPublish && logic.selectedImages.isEmpty)
            Text(
              'Please upload at least one photo to publish',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFFf9a8d4).withValues(alpha: 0.6),
              ),
            ),
        ],
      );
    });
  }
}
