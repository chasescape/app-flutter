import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import '../../routes/app_routes.dart';
import '../../widgets/mische_background.dart';
import 'emotion_models.dart';

class EmotionDetailPage extends StatelessWidget {
  const EmotionDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as EmotionDetailArgs;
    final entry = args.entry;
    final colors = EmotionPalette.gradients[entry.emotion]!;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: MischeBackground(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(entry, colors),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (entry.note.isNotEmpty) _buildNote(entry.note),
                      const SizedBox(height: 16),
                      _buildAnalysis(entry),
                      const SizedBox(height: 16),
                      _buildRecommendedTools(entry),
                      const SizedBox(height: 16),
                      _buildPatternCard(args.totalEntries),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(EmotionEntry entry, List<Color> colors) {
    final topInset = MediaQuery.of(Get.context!).padding.top;
    final shareText = _buildShareText(entry);
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: 3 / 4,
          child: entry.imagePath != null
              ? Image.file(
                  File(entry.imagePath!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.network(
                      _imageForEmotion(entry.emotion),
                      fit: BoxFit.cover,
                    );
                  },
                )
              : Image.network(
                  _imageForEmotion(entry.emotion),
                  fit: BoxFit.cover,
                ),
        ),
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.transparent, Colors.black87],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ),
        Positioned(
          top: topInset + 12,
          left: 16,
          child: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
        ),
        Positioned(
          top: topInset + 12,
          right: 16,
          child: GestureDetector(
            onTap: () {
              Share.share(shareText);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share, color: Colors.white, size: 20),
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      EmotionPalette.label(entry.emotion),
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${entry.timestamp.month}/${entry.timestamp.day}/${entry.timestamp.year}  ${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Color(0xFFE7E7F0), fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Intensity:', style: TextStyle(color: Color(0xFFB9BAC6), fontSize: 12)),
                  const SizedBox(width: 8),
                  ...List.generate(
                    10,
                    (index) => Container(
                      width: 9,
                      height: 9,
                      margin: const EdgeInsets.only(right: 3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index < entry.intensity ? colors.first : const Color(0xFF2A2A33),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text('${entry.intensity}/10', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNote(String note) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1B1B25), Color(0xFF14141C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2E2E3A)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.edit_note, color: Color(0xFFB7B7C6), size: 16),
              SizedBox(width: 6),
              Text('What Happened', style: TextStyle(color: Color(0xFFB7B7C6), fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
          const SizedBox(height: 10),
          Text(note, style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildAnalysis(EmotionEntry entry) {
    final colors = EmotionPalette.gradients[entry.emotion]!;
    
    // 优先使用 AI 生成的内容，否则使用默认建议
    final title = entry.aiStoryTitle ?? _advice[entry.emotion]!.title;
    final content = entry.aiStoryContent ?? _advice[entry.emotion]!.suggestion;
    
    return SizedBox(
      width: double.infinity,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: colors),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('AI Analysis', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text(content, style: const TextStyle(color: Colors.black87, fontSize: 12, height: 1.4)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendedTools(EmotionEntry entry) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Recommended Tools for You',
            style: TextStyle(color: Color(0xFFB0B0B6), fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        if (['sad', 'anxious', 'angry'].contains(entry.emotion.name))
          _toolCard(
            title: 'Deep Breathing',
            subtitle: '4-7-8 technique for instant calm',
            color: const Color(0xFFE94AA8),
            icon: Icons.air,
          ),
        if (['sad', 'anxious', 'angry', 'calm'].contains(entry.emotion.name))
          _toolCard(
            title: 'Guided Meditation',
            subtitle: 'Mindfulness sessions for inner peace',
            color: const Color(0xFF8F3CF0),
            icon: Icons.self_improvement,
          ),
        if (['sad', 'angry'].contains(entry.emotion.name))
          _toolCard(
            title: 'Expression Techniques',
            subtitle: 'Healthy ways to express your feelings',
            color: const Color(0xFFFF7A4B),
            icon: Icons.mic,
          ),
      ],
    );
  }

  Widget _toolCard({required String title, required String subtitle, required Color color, required IconData icon}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A33)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color.withOpacity(0.8), color]),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF9C9CA8), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(int totalEntries) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF111116),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF2A2A33)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Emotion Pattern', style: TextStyle(color: Color(0xFFB0B0B6), fontSize: 12)),
          const SizedBox(height: 6),
          const Text(
            'Tracking your emotions consistently helps identify patterns and triggers. Keep recording to unlock deeper insights.',
            style: TextStyle(color: Color(0xFF9C9CA8), fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metricBox('$totalEntries', 'Total Entries'),
              const SizedBox(width: 12),
              _metricBox('Day ${totalEntries.clamp(1, 7)}', 'Journey Progress'),
            ],
          ),
        ],
      ),
    );
  }

  String _buildShareText(EmotionEntry entry) {
    final date = '${entry.timestamp.month}/${entry.timestamp.day}/${entry.timestamp.year} '
        '${entry.timestamp.hour.toString().padLeft(2, '0')}:${entry.timestamp.minute.toString().padLeft(2, '0')}';
    final buffer = StringBuffer()
      ..writeln('Emotion: ${EmotionPalette.label(entry.emotion)}')
      ..writeln('Date: $date')
      ..writeln('Intensity: ${entry.intensity}/10');

    if (entry.note.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln('Note:')
        ..writeln(entry.note);
    }

    if (entry.aiStoryTitle != null && entry.aiStoryTitle!.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(entry.aiStoryTitle!);
    }

    if (entry.aiStoryContent != null && entry.aiStoryContent!.isNotEmpty) {
      buffer
        ..writeln(entry.aiStoryContent!);
    }

    return buffer.toString();
  }

  Widget _metricBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F0F14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A33)),
        ),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(color: Color(0xFF8D8D98), fontSize: 10)),
          ],
        ),
      ),
    );
  }

  String _imageForEmotion(EmotionType emotion) {
    switch (emotion) {
      case EmotionType.happy:
        return 'https://images.unsplash.com/photo-1591021802639-72a355b39886?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';
      case EmotionType.sad:
        return 'https://images.unsplash.com/photo-1764677224091-d300d12df5f6?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';
      case EmotionType.calm:
        return 'https://images.unsplash.com/photo-1766524791322-8753e582e652?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';
      case EmotionType.anxious:
        return 'https://images.unsplash.com/photo-1625662171040-8d196a082232?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';
      case EmotionType.angry:
        return 'https://images.unsplash.com/photo-1758521540924-a061adde98ed?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';
      case EmotionType.excited:
        return 'https://images.unsplash.com/photo-1758274526671-ad18176acb01?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080';
    }
  }
}

const _advice = {
  EmotionType.happy: _EmotionAdvice(
    title: 'Embrace the Joy',
    suggestion: 'Share your happiness with others or capture this moment in a photo or journal entry.',
  ),
  EmotionType.sad: _EmotionAdvice(
    title: 'It\'s Okay to Feel Sad',
    suggestion: 'Try deep breathing exercises or express your feelings through journaling. Consider reaching out to someone you trust.',
  ),
  EmotionType.calm: _EmotionAdvice(
    title: 'Beautiful Balance',
    suggestion: 'Maintain this peaceful state through meditation or a mindful walk. Notice the present moment.',
  ),
  EmotionType.anxious: _EmotionAdvice(
    title: 'Let\'s Ground Together',
    suggestion: 'Practice the 5-4-3-2-1 technique: Notice 5 things you see, 4 you can touch, 3 you hear, 2 you smell, and 1 you taste.',
  ),
  EmotionType.angry: _EmotionAdvice(
    title: 'Channel This Energy',
    suggestion: 'Take deep breaths and count to 10. Physical activity or writing down your thoughts can help process this feeling.',
  ),
  EmotionType.excited: _EmotionAdvice(
    title: 'Ride This Wave',
    suggestion: 'Channel this energy into something creative or productive. Share your excitement with people who uplift you.',
  ),
};

class _EmotionAdvice {
  const _EmotionAdvice({required this.title, required this.suggestion});

  final String title;
  final String suggestion;
}
