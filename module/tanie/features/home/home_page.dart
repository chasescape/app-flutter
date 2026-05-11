import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tanie/tanie/routes/app_routes.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_button.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackdrop(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppSectionTitle(
                title: 'Photo Journaling',
              ),
              const SizedBox(height: 14),
              Text(
                'Turn one photo into a clear reflection and one next step.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
              AppSectionCard(
                gradient: AppColors.heroGradient,
                padding: const EdgeInsets.fromLTRB(22, 24, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'A simpler way to reflect.',
                      style: AppTextStyles.h2,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Upload a photo, let AI read the moment, and get a short reflection you can use right away.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textPrimary.withValues(alpha: 0.78),
                      ),
                    ),
                    const SizedBox(height: 18),
                    AppPrimaryButton(
                      text: 'Start',
                      onPressed: () => context.go(AppRoutes.create),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Text('How It Works', style: AppTextStyles.h3),
              const SizedBox(height: 12),
              _StepCard(
                step: '01',
                title: 'Pick a photo',
                description: 'Use your camera or gallery.',
                onTap: () => context.go(AppRoutes.create),
              ),
              const SizedBox(height: 10),
              _StepCard(
                step: '02',
                title: 'Get AI reflection',
                description: 'See the mood, meaning, and insight.',
                onTap: () => context.go(AppRoutes.create),
              ),
              const SizedBox(height: 10),
              _StepCard(
                step: '03',
                title: 'Save and act',
                description: 'Keep it in history and take one next step.',
                onTap: () => context.go(AppRoutes.create),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String step;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _StepCard({
    required this.step,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppSectionCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryMain,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              step,
              style: AppTextStyles.small.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
