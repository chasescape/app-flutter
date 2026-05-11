import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../widgets/glass_card.dart';
import '../../widgets/mische_background.dart';
import 'tools_logic.dart';

class ToolsPage extends StatelessWidget {
  ToolsPage({super.key});

  final ToolsLogic logic = Get.find<ToolsLogic>();

  void _dismissActive() {
    logic.activeTool.value = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E12),
      body: MischeBackground(
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildRecommended(),
                    const SizedBox(height: 18),
                    _buildCategory(
                      title: 'Quick Relief',
                      accent: const Color(0xFFE94AA8),
                      tools: _tools
                          .where((tool) => tool.category == 'Quick Relief')
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    _buildCategory(
                      title: 'Deep Practice',
                      accent: const Color(0xFF8F3CF0),
                      tools: _tools
                          .where((tool) => tool.category == 'Deep Practice')
                          .toList(),
                    ),
                    const SizedBox(height: 18),
                    _buildCategory(
                      title: 'Creative Expression',
                      accent: const Color(0xFFFF7A4B),
                      tools: _tools
                          .where((tool) => tool.category == 'Creative')
                          .toList(),
                    ),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
              Obx(() => _buildActiveTool(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Self-Regulation Tools',
          style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Color(0xFFffffff)),
        ),
        SizedBox(height: 6),
        Text(
          'Find calm and balance with these practices',
          style: TextStyle(color: Color(0xFFB0B0B6), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildRecommended() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 28,
      backgroundColor: const Color(0xB31C1F2A),
      borderColor: const Color(0x66FFFFFF),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.auto_awesome, color: Color(0xFFFFC857), size: 18),
              SizedBox(width: 8),
              Text(
                'Recommended for You',
                style: TextStyle(
                    color: Color(0xFFFFC857),
                    fontWeight: FontWeight.w600,
                    fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Deep Breathing Exercise',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16)),
          const SizedBox(height: 6),
          const Text(
              'Perfect for quick stress relief. Based on your recent mood patterns.',
              style: TextStyle(
                  color: Color(0xFFE1DFE6), fontSize: 12, height: 1.4)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => logic.activeTool.value = 'breathing',
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE94AA8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Start Now',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategory({
    required String title,
    required Color accent,
    required List<_ToolCard> tools,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                    color: accent, borderRadius: BorderRadius.circular(12))),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Column(
          children: tools.map(_buildToolCard).toList(),
        ),
      ],
    );
  }

  Widget _buildToolCard(_ToolCard tool) {
    return GestureDetector(
      onTap: () => logic.activeTool.value = tool.id,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A22),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFF2A2A33)),
        ),
        child: Row(
          children: [
            Container(
              width: 70,
              height: 94,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: tool.gradient),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(tool.icon, color: Colors.white, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        tool.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(Icons.circle,
                              color: Color(0xFF60D394), size: 8),
                          const SizedBox(width: 4),
                          Text('${tool.popularity}%',
                              style: const TextStyle(
                                  color: Color(0xFF60D394), fontSize: 11)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(tool.description,
                      style: const TextStyle(
                          color: Color(0xFF9C9CA8), fontSize: 11)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2A2A33),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(tool.duration,
                        style: const TextStyle(
                            color: Color(0xFFB0B0B6), fontSize: 10)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveTool(BuildContext context) {
    final active = logic.activeTool.value;
    if (active == null) return const SizedBox.shrink();

    switch (active) {
      case 'breathing':
        return _buildBreathingModal();
      case 'meditation':
        return _buildMeditationModal();
      case 'expression':
        return _buildExpressionModal();
      default:
        return _buildComingSoon();
    }
  }

  Widget _buildBreathingModal() {
    return GestureDetector(
      onTap: _dismissActive,
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF2A2A33)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                    child: SizedBox(
                      height: 360,
                      child: Obx(
                        () => Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                'https://images.unsplash.com/photo-1758274526671-ad18176acb01?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.7),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.5),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              right: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '4-7-8 Breathing',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _dismissActive,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: logic.isBreathing.value
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '${logic.breathCount.value}',
                                            style: const TextStyle(
                                              fontSize: 56,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFFE94AA8),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          child: const Text(
                                            'breaths completed',
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.air,
                                            color: Color(0xFFE94AA8),
                                            size: 52,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          child: const Text(
                                            'Ready to begin',
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _buildTipCard(const [
                          'Breathe in through your nose for 4 seconds',
                          'Hold your breath for 7 seconds',
                          'Exhale slowly through your mouth for 8 seconds',
                        ], accent: const Color(0xFFE94AA8)),
                        const SizedBox(height: 12),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: logic.isBreathing.value
                                  ? null
                                  : logic.startBreathing,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE94AA8),
                                disabledBackgroundColor: const Color(0xFF5E2A44),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                logic.isBreathing.value
                                    ? 'In Progress...'
                                    : 'Start Practice',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeditationModal() {
    return GestureDetector(
      onTap: _dismissActive,
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF2A2A33)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                    child: SizedBox(
                      height: 360,
                      child: Obx(
                        () => Stack(
                          children: [
                            Positioned.fill(
                              child: Image.network(
                                'https://images.unsplash.com/photo-1545389336-cf090694435e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.black.withValues(alpha: 0.7),
                                      Colors.transparent,
                                      Colors.black.withValues(alpha: 0.5),
                                    ],
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 20,
                              left: 20,
                              right: 20,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Meditation Timer',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: _dismissActive,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.5),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Center(
                              child: logic.isMeditating.value
                                  ? Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(28),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            logic.formatTime(logic.meditationTime.value),
                                            style: const TextStyle(
                                              fontSize: 50,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF8F3CF0),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          child: const Text(
                                            'remaining',
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(24),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.self_improvement,
                                            color: Color(0xFF8F3CF0),
                                            size: 52,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withValues(alpha: 0.6),
                                            borderRadius: BorderRadius.circular(24),
                                          ),
                                          child: const Text(
                                            'Select duration below',
                                            style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            _buildTimeButton(5),
                            const SizedBox(width: 8),
                            _buildTimeButton(10),
                            const SizedBox(width: 8),
                            _buildTimeButton(15),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: logic.isMeditating.value
                                  ? () => logic.isMeditating.value = false
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8F3CF0),
                                disabledBackgroundColor: const Color(0xFF3A2B55),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(
                                  logic.isMeditating.value
                                      ? 'Stop Session'
                                      : 'Select Duration',
                                  style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpressionModal() {
    return GestureDetector(
      onTap: _dismissActive,
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF2A2A33)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
                    child: SizedBox(
                      height: 280,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                              'https://images.unsplash.com/photo-1612907527100-f02bb2b26b1d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&q=80&w=1080',
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withValues(alpha: 0.7),
                                    Colors.transparent,
                                  ],
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            right: 20,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Expression Techniques',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: _dismissActive,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(alpha: 0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 20),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: _buildTipCard(const [
                      'Journaling: write down your thoughts and feelings without judgment.',
                      'Talk It Out: share with someone you trust.',
                      'Creative Expression: express yourself through art, music, or movement.',
                    ], accent: const Color(0xFFFF7A4B)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComingSoon() {
    return GestureDetector(
      onTap: _dismissActive,
      child: Container(
        color: Colors.black.withValues(alpha: 0.85),
        child: Center(
          child: GestureDetector(
            onTap: () {},
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A22),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: const Color(0xFF2A2A33)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildModalHeader('Coming Soon'),
                  const SizedBox(height: 12),
                  const Icon(Icons.auto_awesome,
                      color: Color(0xFF8F3CF0), size: 40),
                  const SizedBox(height: 12),
                  const Text('This tool is being prepared for you.',
                      style: TextStyle(color: Color(0xFFB0B0B6), fontSize: 12)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => logic.activeTool.value = null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8F3CF0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Explore Other Tools',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModalHeader(String title) {
    return Row(
      children: [
        Expanded(
          child: Text(title,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600)),
        ),
        IconButton(
          onPressed: _dismissActive,
          icon: const Icon(Icons.close, color: Color(0xFFB0B0B6)),
        ),
      ],
    );
  }

  Widget _buildTipCard(List<String> tips, {required Color accent}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF15151C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2A2A33)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tips
            .map(
              (tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text(
                  '• $tip',
                  style: const TextStyle(
                      color: Color(0xFFB0B0B6), fontSize: 12, height: 1.4),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildTimeButton(int minutes) {
    return Expanded(
      child: Obx(
        () => OutlinedButton(
          onPressed: logic.isMeditating.value
              ? null
              : () => logic.startMeditation(minutes),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(color: Color(0xFF5E4F87)),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
          child:
              Text('$minutes min', style: const TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

class _ToolCard {
  _ToolCard({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.gradient,
    required this.duration,
    required this.popularity,
    required this.category,
  });

  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<Color> gradient;
  final String duration;
  final int popularity;
  final String category;
}

final List<_ToolCard> _tools = [
  _ToolCard(
    id: 'breathing',
    title: 'Deep Breathing',
    description: '4-7-8 breathing technique for instant calm',
    icon: Icons.air,
    gradient: [const Color(0xFFE94AA8), const Color(0xFF8F3CF0)],
    duration: '5 min',
    popularity: 95,
    category: 'Quick Relief',
  ),
  _ToolCard(
    id: 'meditation',
    title: 'Guided Meditation',
    description: 'Mindfulness sessions for inner peace',
    icon: Icons.self_improvement,
    gradient: [const Color(0xFF8F3CF0), const Color(0xFF5E7BFF)],
    duration: '10-15 min',
    popularity: 88,
    category: 'Deep Practice',
  ),
  _ToolCard(
    id: 'expression',
    title: 'Expression Techniques',
    description: 'Healthy ways to express your feelings',
    icon: Icons.mic,
    gradient: [const Color(0xFFFF7A4B), const Color(0xFFE94AA8)],
    duration: 'Flexible',
    popularity: 78,
    category: 'Creative',
  ),
];
