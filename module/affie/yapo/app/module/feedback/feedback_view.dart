import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'feedback_logic.dart';

class FeedbackPage extends StatelessWidget {
  const FeedbackPage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.find<FeedbackLogic>();
    
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: const Color(0xFF1a0b2e),
        body: CustomScrollView(
          slivers: [
            // Header
            SliverAppBar(
              pinned: true,
              backgroundColor: const Color(0xCC1a0b2e), // 0.8 alpha
              leadingWidth: 72,
              leading: Padding(
                padding: const EdgeInsets.only(left: 24),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => Get.back(),
                    borderRadius: BorderRadius.circular(20),
                    // ✅ 移除 BackdropFilter，使用简单背景
                    child: Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0x1FFFFFFF), // 0.12 alpha
                        border: Border.all(
                          color: const Color(0x33FFFFFF), // 0.2 alpha
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
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xCC7c2d9e), // 0.8 alpha
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              // ✅ 移除 ShaderMask，使用简单颜色
              title: const Text(
                'Feedback',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFf472b6),
                ),
              ),
              centerTitle: true,
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    const Text(
                      'We\'d love to hear from you!',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xCCd8b4fe), // 0.8 alpha
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Share your thoughts, suggestions, or report any issues.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0x99d8b4fe), // 0.6 alpha
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Feedback Type Selection
                    _buildSectionTitle('Feedback Type'),
                    const SizedBox(height: 16),
                    // ✅ 移除外层 Obx，每个 chip 内部自己监听
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildTypeChip('Suggestion', Icons.lightbulb_outline),
                        _buildTypeChip('Bug Report', Icons.bug_report_outlined),
                        _buildTypeChip('Feature Request', Icons.star_outline),
                        _buildTypeChip('Other', Icons.chat_bubble_outline),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Feedback Input with voice button
                    _buildSectionTitle('Your Feedback'),
                    const SizedBox(height: 16),
                    Stack(
                      children: [
                        _buildFeedbackInput(),
                        // 麦克风按钮（输入框左下角）
                        Positioned(
                          left: 16,
                          bottom: 16,
                          child: Obx(() {
                            final logic = Get.find<FeedbackLogic>();
                            return GestureDetector(
                              onTap: logic.isInitialized.value
                                  ? (logic.isListening.value
                                      ? logic.stopListening
                                      : logic.startListening)
                                  : null,
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
                                          color: const Color(0x4Def4444), // 0.3 alpha
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
                                          color: const Color(0x26ef4444), // 0.15 alpha
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
                                              colors: [
                                                Color(0xFFef4444),
                                                Color(0xFFdc2626)
                                              ],
                                            )
                                          : const LinearGradient(
                                              colors: [
                                                Color(0xFFdb2777),
                                                Color(0xFF9333ea)
                                              ],
                                            ),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: logic.isListening.value
                                              ? const Color(0x80ef4444) // 0.5 alpha
                                              : const Color(0x80ec4899), // 0.5 alpha
                                          blurRadius: logic.isListening.value ? 24 : 16,
                                          spreadRadius: logic.isListening.value ? 4 : 2,
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      logic.isListening.value
                                          ? Icons.stop_rounded
                                          : Icons.mic_rounded,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Submit Button
                    _buildSubmitButton(),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    // ✅ 移除 ShaderMask，使用简单颜色
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFFf472b6),
      ),
    );
  }

  Widget _buildTypeChip(String label, IconData icon) {
    final logic = Get.find<FeedbackLogic>();
    // ✅ 每个 chip 内部使用 Obx，只监听自己需要的状态
    return Obx(() {
      final isSelected = logic.selectedType.value == label;
      return InkWell(
        onTap: () => logic.selectedType.value = label,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFFec4899), Color(0xFFa855f7)],
                  )
                : null,
            color: isSelected ? null : const Color(0x1Aec4899), // 0.1 alpha
            border: Border.all(
              color: isSelected
                  ? Colors.transparent
                  : const Color(0x4Dec4899), // 0.3 alpha
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : const Color(0xCCd8b4fe), // 0.8 alpha
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isSelected ? Colors.white : const Color(0xCCd8b4fe), // 0.8 alpha
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildFeedbackInput() {
    final logic = Get.find<FeedbackLogic>();
    // ✅ 移除 BackdropFilter 和 ClipRRect，使用简单背景
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0x1Aec4899), // 0.1 alpha
            Color(0x14a855f7), // 0.08 alpha
          ],
        ),
        border: Border.all(
          color: const Color(0x4Dec4899), // 0.3 alpha
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: logic.feedbackController,
        maxLines: 8,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
        ),
        decoration: const InputDecoration(
          hintText: 'Tell us what\'s on your mind...',
          hintStyle: TextStyle(
            color: Color(0x66d8b4fe), // 0.4 alpha
            fontSize: 15,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final logic = Get.find<FeedbackLogic>();
    return Obx(() {
      final isLoading = logic.isSubmitting.value;
      return InkWell(
        onTap: isLoading ? null : () => logic.submitFeedback(),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isLoading
                  ? [Colors.grey.shade600, Colors.grey.shade700]
                  : const [Color(0xFFdb2777), Color(0xFF9333ea)],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x66ec4899), // 0.4 alpha
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              else ...[
                const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Submit Feedback',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    });
  }
}
