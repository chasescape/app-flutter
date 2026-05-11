import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:mische/gen_a/A.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/mische_background.dart';
import '../emotion/emotion_logic.dart';
import '../emotion/emotion_models.dart';
import '../../routes/app_routes.dart';
import '../../../interface.dart';
import 'home_logic.dart';

const String _privacyConsentKey = 'privacy_photo_consent_v1';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeLogic logic = Get.find<HomeLogic>();
  final EmotionLogic emotionLogic = Get.find<EmotionLogic>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: Stack(
          children: [
            MischeBackground(
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildEmotionGrid(),
                      Obx(() {
                        if (logic.selectedEmotion.value == null) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            const SizedBox(height: 20),
                            _buildEmotionDetailCard(),
                          ],
                        );
                      }),
                      const SizedBox(height: 24),
                      _buildRecentEntries(context),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
            Obx(
              () => logic.isGeneratingAi.value
                  ? Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.45),
                        child: Center(
                          child: Lottie.asset(
                            A.assets_loading_AILoading,
                            width: 220,
                            height: 220,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How are you feeling?',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Track your emotions and find your balance',
          style: TextStyle(
            color: Color(0xFFB0B0B6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEmotionGrid() {
    return Obx(
      () => GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
        physics: const NeverScrollableScrollPhysics(),
        children: EmotionType.values.map((emotion) {
          final isSelected = logic.selectedEmotion.value == emotion;
          final colors = EmotionPalette.gradients[emotion]!;
          return GestureDetector(
            onTap: () => logic.selectEmotion(emotion),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : null,
                color: isSelected ? null : const Color(0xFF1B1B22),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFF2A2A33),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    EmotionPalette.icon(emotion),
                    color: isSelected ? Colors.black : Colors.white,
                    size: 28,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    EmotionPalette.label(emotion),
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Future<void> _handleImagePick() async {
    final status = await Permission.photos.request();
    if (!status.isGranted) {
      return;
    }

    await logic.pickImage();
  }

  Widget _buildEmotionDetailCard() {
    return Obx(
      () {
        final emotion = logic.selectedEmotion.value!;
        final colors = EmotionPalette.gradients[emotion]!;
        final advice = logic.getAdvice(emotion);
        return GlassCard(
          padding: const EdgeInsets.all(18),
          borderRadius: 28,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advice.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      advice.suggestion,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Obx(
                () => Text(
                  'Intensity: ${logic.intensity.value}/10',
                  style: const TextStyle(
                    color: Color(0xFFE4E0E9),
                    fontSize: 12,
                  ),
                ),
              ),
              Obx(
                () => Slider(
                  value: logic.intensity.value.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  activeColor: colors.first,
                  inactiveColor: const Color(0xFFE4E0E9),
                  onChanged: (value) => logic.intensity.value = value.round(),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () {
                  final image = logic.pickedImage.value;
                  if (image == null) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      Container(
                        height: 420,
                        decoration: BoxDecoration(
                          color: const Color(0xFFEDEAF1),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: const Color(0xFFDCD6E5)),
                          image: DecorationImage(
                            image: FileImage(File(image.path)),
                            fit: BoxFit.cover,
                          ),
                        ),
                        alignment: Alignment.topRight,
                        padding: const EdgeInsets.all(8),
                        child: GestureDetector(
                          onTap: () => logic.pickedImage.value = null,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  );
                },
              ),
              const Text(
                'What happened?',
                style: TextStyle(
                  color: Color(0xFFE4E0E9),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: logic.noteController,
                maxLines: 3,
                style: const TextStyle(color: Color(0xFF1F1D24)),
                decoration: InputDecoration(
                  hintText: 'Optional: Add a note...',
                  hintStyle: const TextStyle(color: Color(0xFF8D8898), fontSize: 12),
                  filled: true,
                  fillColor: const Color(0xFFEDEAF1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDCD6E5)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Color(0xFFDCD6E5)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: () => _handleImagePick(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEAF1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDCD6E5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                logic.pickedImage.value == null ? Icons.photo_outlined : Icons.check_circle,
                                color: const Color(0xFF5B5666),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                logic.pickedImage.value == null ? 'Upload photo' : 'Photo selected',
                                style: const TextStyle(color: Color(0xFF5B5666), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Obx(
                      () => GestureDetector(
                        onTap: logic.toggleListening,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: logic.isListening.value ? const Color(0xFFFFE4E8) : const Color(0xFFEDEAF1),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFDCD6E5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                logic.isListening.value ? Icons.stop_circle_outlined : Icons.mic_none,
                                color: const Color(0xFF5B5666),
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                logic.isListening.value ? 'Listening...' : 'Voice',
                                style: const TextStyle(color: Color(0xFF5B5666), fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await logic.saveEntry(emotionLogic);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.first,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Save Emotion',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentEntries(BuildContext context) {
    return Obx(() {
      if (emotionLogic.entries.isEmpty) {
        return _buildEmptyState();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Entries',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFE1E1E6)),
          ),
          const SizedBox(height: 12),
          ...emotionLogic.entries
              .map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildEntryCard(context, entry),
                  ))
              .toList(),
        ],
      );
    });
  }

  Widget _buildEmptyState() {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 28,
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF8F3CF0), Color(0xFFE94AA8)]),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 16),
          const Text(
            'Start Your Journey',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Welcome! Track your first emotion above to begin understanding your emotional patterns and finding balance.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 18),
          _buildStepCard('1', 'Select how you feel', 'Choose from 6 emotions above', const Color(0xFFFF7A4B)),
          const SizedBox(height: 12),
          _buildStepCard('2', 'Rate the intensity', 'Scale from 1 to 10', const Color(0xFFE94AA8)),
          const SizedBox(height: 12),
          _buildStepCard('3', 'Add context (optional)', 'What triggered this feeling?', const Color(0xFF8F3CF0)),
        ],
      ),
    );
  }

  Widget _buildStepCard(String step, String title, String subtitle, Color color) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      borderRadius: 20,
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.9), color]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                step,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, EmotionEntry entry) {
    final colors = EmotionPalette.gradients[entry.emotion]!;
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.detail, arguments: EmotionDetailArgs(entry: entry, totalEntries: emotionLogic.entries.length));
      },
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        borderRadius: 28,
        child: Row(
          children: [
            Container(
              width: 72,
              height: 96,
              decoration: BoxDecoration(
                color: const Color(0xFFE9E6F0),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: entry.imagePath != null
                    ? Image.file(
                        File(entry.imagePath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.network(
                            logic.imageForEmotion(entry.emotion),
                            fit: BoxFit.cover,
                          );
                        },
                      )
                    : Image.network(
                        logic.imageForEmotion(entry.emotion),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          EmotionPalette.label(entry.emotion),
                          style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        logic.formatTime(entry.timestamp),
                        style: const TextStyle(color: Color(0xFF6D6677), fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.note.isEmpty ? 'No note added' : entry.note,
                    style: const TextStyle(color: Color(0xFF4E4A58), fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Intensity:',
                        style: TextStyle(color: Color(0xFF7C7686), fontSize: 11),
                      ),
                      const SizedBox(width: 6),
                      ...List.generate(10, (index) {
                        final active = index < entry.intensity;
                        return Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(right: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: active ? colors.first : const Color(0xFFE1DDEA),
                          ),
                        );
                      }),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => emotionLogic.deleteEntry(entry.id),
              icon: const Icon(Icons.delete_outline, color: Color(0xFFE05C74), size: 20),
            ),
          ],
        ),
      ),
    );
  }
}
