import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:tanie/tanie/data/models/reflection_entry.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_button.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  ReflectionEntry? entry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = GoRouterState.of(context).extra;
    if (args is ReflectionEntry) {
      entry = args;
    }
  }

  Future<void> _shareEntry() async {
    final data = entry;
    if (data == null) return;

    final shareText = [
      data.sceneUnderstanding.mainSubject,
      '',
      'Observation: ${data.reflection.observation}',
      '',
      'Insight: ${data.reflection.insight}',
      '',
      'Action Prompt: ${data.reflection.actionPrompt}',
    ].join('\n');

    final box = context.findRenderObject() as RenderBox?;

    await Share.share(
      shareText,
      subject: data.sceneUnderstanding.mainSubject,
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (entry == null) {
      return Scaffold(
        body: AppBackdrop(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const AppIconCircle(icon: Icons.error_outline),
                const SizedBox(height: 16),
                Text('Content not found', style: AppTextStyles.h3),
              ],
            ),
          ),
        ),
      );
    }

    final data = entry!;
    final imageHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      body: AppBackdrop(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  AppAdaptiveImage(
                    imagePath: data.assetImg,
                    height: imageHeight,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(34),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: AppIconCircle(
                      icon: Icons.arrow_back_rounded,
                      onTap: () => context.pop(),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Row(
                      children: [
                        AppIconCircle(
                          icon: Icons.ios_share_rounded,
                          onTap: _shareEntry,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AppSectionCard(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.sceneUnderstanding.mainSubject,
                        style: AppTextStyles.h1),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        AppMetaChip(
                          icon: Icons.place_rounded,
                          label: data.sceneUnderstanding.location,
                        ),
                        AppMetaChip(
                          icon: Icons.wb_sunny_outlined,
                          label: data.sceneUnderstanding.timeOfDay,
                        ),
                        AppMetaChip(
                          icon: Icons.auto_awesome_rounded,
                          label: data.sceneUnderstanding.atmosphere,
                        ),
                        AppMetaChip(
                          icon: Icons.favorite_outline_rounded,
                          label: data.sceneUnderstanding.emotionalCue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _DetailBlock(
                      title: 'Observation',
                      body: data.reflection.observation,
                    ),
                    const SizedBox(height: 16),
                    _DetailBlock(
                      title: 'Insight',
                      body: data.reflection.insight,
                      highlighted: true,
                    ),
                    const SizedBox(height: 16),
                    _DetailBlock(
                      title: 'Deeper Thought',
                      body: data.reflection.deeperThought,
                    ),
                    const SizedBox(height: 16),
                    _DetailBlock(
                      title: 'Action Prompt',
                      body: data.reflection.actionPrompt,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailBlock extends StatelessWidget {
  final String title;
  final String body;
  final bool highlighted;

  const _DetailBlock({
    required this.title,
    required this.body,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: highlighted ? AppColors.accentGradient : null,
        color: highlighted ? null : AppColors.cardMuted,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: AppTextStyles.small.copyWith(
              color: AppColors.secondaryMain,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(body, style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }
}
