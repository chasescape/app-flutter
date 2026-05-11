import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lenbo/lenbo/core/theme/app_colors.dart';
import 'package:lenbo/lenbo/core/theme/app_spacing.dart';
import 'package:lenbo/lenbo/data/models/plant_analysis.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plant = Get.arguments as PlantAnalysis;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with gradient overlay
            Stack(
              children: [
                SizedBox(
                  height: 480,
                  width: double.infinity,
                  child: plant.assetImg.startsWith('assets/')
                      ? Image.asset(
                          plant.assetImg,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        )
                      : Image.file(
                          File(plant.assetImg),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (_, __, ___) => Container(
                            color: AppColors.bgTertiary,
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 48, color: AppColors.textDisabled),
                            ),
                          ),
                        ),
                ),
                // Gradient overlay
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withAlpha(13),
                          Colors.black.withAlpha(179),
                        ],
                        stops: const [0.4, 1.0],
                      ),
                    ),
                  ),
                ),
                // Back button
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(77),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.white),
                    ),
                  ),
                ),
                // Core text overlay at bottom
                Positioned(
                  left: AppSpacing.lg,
                  right: AppSpacing.lg,
                  bottom: AppSpacing.lg,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plant.plantId.commonName,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 8, color: Colors.black45)],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        plant.plantId.scientificName,
                        style: TextStyle(
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                          color: Colors.white.withAlpha(217),
                          shadows: const [Shadow(blurRadius: 6, color: Colors.black45)],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Key attribute chips
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _InfoChip(
                    icon: Icons.eco,
                    label: plant.plantId.family,
                    color: AppColors.success,
                  ),
                  _InfoChip(
                    icon: Icons.favorite,
                    label: plant.healthCheck.status,
                    color: _statusColor(plant.healthCheck.status),
                  ),
                  _InfoChip(
                    icon: Icons.straighten,
                    label: plant.growthInfo.maxHeight,
                    color: AppColors.info,
                  ),
                  _InfoChip(
                    icon: Icons.speed,
                    label: plant.growthInfo.difficultyLevel,
                    color: AppColors.warning,
                  ),
                  _InfoChip(
                    icon: Icons.light_mode,
                    label: plant.environmentReading.lightEnv,
                    color: const Color(0xFFFFA726),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Overall impression card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: AppColors.secondaryMain, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Overview',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plant.healthCheck.overallImpression,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plant.careGuide.summary,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Health check card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monitor_heart, color: _statusColor(plant.healthCheck.status), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Health Check',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor(plant.healthCheck.status).withAlpha(31),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            '${(plant.healthCheck.confidence * 100).toInt()}% Confident',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _statusColor(plant.healthCheck.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      plant.healthCheck.visualEvidence,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    if (plant.healthCheck.symptoms.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      ...plant.healthCheck.symptoms.map(
                        (s) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.circle, size: 4, color: AppColors.textDisabled),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(s, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Care guide cards
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.spa, color: AppColors.success, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'Care Guide',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _CareRow(
                      icon: Icons.water_drop,
                      title: 'Watering',
                      value: plant.careGuide.watering.frequency,
                      detail: plant.careGuide.watering.method,
                    ),
                    const SizedBox(height: 12),
                    _CareRow(
                      icon: Icons.wb_sunny,
                      title: 'Light',
                      value: plant.careGuide.light.idealCondition,
                      detail: plant.careGuide.light.adjustmentTip,
                    ),
                    const SizedBox(height: 12),
                    _CareRow(
                      icon: Icons.thermostat,
                      title: 'Temperature',
                      value: plant.careGuide.temperature.idealRange,
                      detail: plant.careGuide.temperature.tolerance,
                    ),
                    const SizedBox(height: 12),
                    _CareRow(
                      icon: Icons.grain,
                      title: 'Fertilizer',
                      value: plant.careGuide.fertilizing.recommendedType,
                      detail: plant.careGuide.fertilizing.schedule,
                    ),
                    const SizedBox(height: 12),
                    _CareRow(
                      icon: Icons.air,
                      title: 'Humidity',
                      value: plant.careGuide.humidity.idealLevel,
                      detail: plant.careGuide.humidity.boostMethods.isNotEmpty
                          ? plant.careGuide.humidity.boostMethods.join(', ')
                          : null,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Common issues
            if (plant.commonIssues.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: _SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bug_report, color: AppColors.warning, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Common Issues',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ...plant.commonIssues.map(
                        (issue) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                issue.problem,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                issue.fix,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: AppSpacing.md),

            // Fun fact - collapsible
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _CollapsibleCard(
                title: 'Fun Fact',
                icon: Icons.lightbulb_outline,
                iconColor: const Color(0xFFFFC107),
                child: Text(
                  plant.plantId.funFact,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Pro tip - collapsible
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _CollapsibleCard(
                title: 'Pro Tip',
                icon: Icons.tips_and_updates,
                iconColor: AppColors.secondaryMain,
                child: Text(
                  plant.proTip,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Safety info - collapsible
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: _CollapsibleCard(
                title: 'Safety Info',
                icon: plant.safety.petSafe ? Icons.pets : Icons.warning_amber,
                iconColor: plant.safety.petSafe ? AppColors.success : AppColors.error,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          plant.safety.petSafe ? Icons.check_circle : Icons.cancel,
                          size: 16,
                          color: plant.safety.petSafe ? AppColors.success : AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          plant.safety.petSafe ? 'Pet Safe' : 'Not Pet Safe',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: plant.safety.petSafe ? AppColors.success : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      plant.safety.toxicityNote,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    if (plant.safety.notes.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        plant.safety.notes,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textDisabled,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return AppColors.success;
      case 'needs attention':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: color.withAlpha(64), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;

  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorderLight, width: 0.5),
      ),
      child: child,
    );
  }
}

class _CareRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String? detail;

  const _CareRow({
    required this.icon,
    required this.title,
    required this.value,
    this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.secondaryMain),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDisabled,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
              if (detail != null)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    detail!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CollapsibleCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Widget child;

  const _CollapsibleCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.child,
  });

  @override
  State<_CollapsibleCard> createState() => _CollapsibleCardState();
}

class _CollapsibleCardState extends State<_CollapsibleCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.cardBorderLight, width: 0.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(widget.icon, size: 18, color: widget.iconColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    Icon(
                      _expanded ? Icons.expand_less : Icons.expand_more,
                      size: 20,
                      color: AppColors.textDisabled,
                    ),
                  ],
                ),
                if (_expanded) ...[
                  const SizedBox(height: 12),
                  widget.child,
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.secondaryMain, width: 1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.secondaryMain, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.secondaryMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
