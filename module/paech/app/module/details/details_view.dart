import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

import 'details_logic.dart';

/// 下方卡片使用的图标列表，每张卡片按索引取不同图标（无星星图标）
const _careCardIcons = <IconData>[
  Icons.checkroom_outlined,
  Icons.spa_outlined,
  Icons.water_drop_outlined,
  Icons.local_laundry_service_outlined,
  Icons.ac_unit_outlined,
];

class DetailsPage extends StatefulWidget {
  const DetailsPage({super.key});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> with SingleTickerProviderStateMixin {
  late final DetailsLogic logic;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    logic = Get.put(DetailsLogic());
    
    // 创建动画控制器
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 淡入动画
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // 向上滑动动画
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
    ));

    // 延迟启动动画，等待 Hero 动画完成
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: AppBar(
            title: const Text('Details'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: const Color(0xFF2D2A26),
            actions: [
              IconButton(
                icon: const Icon(Icons.share_outlined),
                onPressed: () {
                  final title = logic.title ?? 'Details';
                  final desc = logic.description ?? '';
                  final text = desc.isEmpty ? title : '$title\n\n$desc';
                  Share.share(text);
                },
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Hero(
              tag: 'image_${logic.imagePath}',
              flightShuttleBuilder: (
                BuildContext flightContext,
                Animation<double> animation,
                HeroFlightDirection flightDirection,
                BuildContext fromHeroContext,
                BuildContext toHeroContext,
              ) {
                // 自定义 Hero 动画速度
                return AnimatedBuilder(
                  animation: animation,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: const Color(0xFFE4E0DA),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: logic.imagePath != null
                          ? Image.asset(
                              logic.imagePath!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            )
                          : const SizedBox.shrink(),
                    );
                  },
                );
              },
              child: Container(
                height: 520,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  color: const Color(0xFFE4E0DA),
                ),
                clipBehavior: Clip.antiAlias,
                child: logic.imagePath != null
                    ? Image.asset(
                        logic.imagePath!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
                      )
                    : const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: Color(0xFFB8B0A6),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 14),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Text(
                  logic.title ?? 'Accessory Styling',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF2D2A26),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Text(
                  logic.description ?? 'The right accessories can transform any outfit. Learn how to choose and care for accessories that complement your personal style.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: const Color(0xFF595550),
                    height: 1.4,
                  ),
                ),
              ),
            ),
            if (logic.tips != null && logic.tips!.isNotEmpty) ...[
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: const Divider(
                    color: Color(0xFF8D857C),
                    thickness: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ...logic.tips!.asMap().entries.map((entry) {
                final index = entry.key;
                final tip = entry.value;
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _CareInstructionsCard(
                        tips: tip,
                        icon: _careCardIcons[index % _careCardIcons.length],
                      ),
                    ),
                  ),
                );
              }),
            ] else ...[
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 50),
                  child: const Divider(
                    color: Color(0xFF8D857C),
                    thickness: 0.2,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _CareInstructionsCard(
                    icon: _careCardIcons[0],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: _CareInstructionsCard(
                    icon: _careCardIcons[1],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CareInstructionsCard extends StatelessWidget {
  const _CareInstructionsCard({this.tips, this.icon});

  final Map<String, String>? tips;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // 使用传入的 tips 或默认值
    final cardTitle = tips?['title'] ?? 'Care Instructions';
    final cardSubtitle = tips?['subtitle'] ?? 'Keep your clothing fresh & lasting';
    
    // 获取指令列表
    final instructions = <String>[];
    if (tips != null) {
      for (int i = 1; i <= 10; i++) {
        final instruction = tips!['instruction$i'];
        if (instruction != null && instruction.isNotEmpty) {
          instructions.add(instruction);
        }
      }
    }
    
    // 如果没有传入指令，使用默认值
    if (instructions.isEmpty) {
      instructions.addAll([
        'Store leather items in dust bags',
        'Polish metal accessories regularly',
        'Keep jewelry in separate compartments',
        'Polish metal accessories regularly',
      ]);
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF6F1EA),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? _careCardIcons[0],
                  color: const Color(0xFFD0B08E),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cardTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2D2A26),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      cardSubtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF8D857C),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...instructions.asMap().entries.map((entry) {
            final index = entry.key;
            final instruction = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < instructions.length - 1 ? 12 : 0),
              child: _InstructionRow(
                number: '${index + 1}',
                text: instruction,
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  const _InstructionRow({
    required this.number,
    required this.text,
  });

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F1EA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text(
            number,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFD0B08E),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF595550),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
