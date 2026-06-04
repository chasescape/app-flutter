import 'package:flutter/material.dart';
import 'package:cliss/cliss/a.dart';
import 'package:cliss/cliss/app/routes/app_routes.dart';
import 'package:cliss/cliss/app/services/user_service.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_button.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';
import 'package:cliss/cliss/env/app_env.dart';
import 'package:cliss/cliss/light_handle.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _height = 170;
  int _weight = 70;
  int _weeklyExercise = 1;
  String _goal = 'maintain';
  int _dailyCalorieTarget = 2000;

  final List<String> _goals = ['lose', 'maintain', 'gain'];
  final Map<String, String> _goalLabels = {
    'lose': 'Lose Fat',
    'maintain': 'Maintain',
    'gain': 'Build Muscle',
  };

  @override
  void initState() {
    super.initState();
    _calculateDailyTarget();
  }

  void _calculateDailyTarget() {
    final baseBmr =
        88 + (13.4 * _weight).toInt() + (4.8 * _height).toInt() - (5.7 * 30).toInt();
    double activityMultiplier = switch (_weeklyExercise) {
      0 => 1.2,
      1 => 1.375,
      2 => 1.55,
      _ => 1.725,
    };
    final tdee = (baseBmr * activityMultiplier).toInt();
    _dailyCalorieTarget = switch (_goal) {
      'lose' => tdee - 500,
      'gain' => tdee + 300,
      _ => tdee,
    };
    setState(() {});
  }

  Future<void> _handleLogout() async {
    final confirmed = await _showConfirmDialog(
      context: context,
      title: 'Logout',
      message: 'Are you sure you want to logout?',
      confirmText: 'Logout',
    );
    if (confirmed == true && mounted) {
      await LightHandle.logout(context);
    }
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await _showConfirmDialog(
      context: context,
      title: 'Delete Account',
      message: 'This will permanently delete your account and all data.',
      confirmText: 'Delete',
    );
    if (confirmed == true && mounted) {
      await LightHandle.deleteAccount(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      safeBottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          64,
          AppSpacing.md,
          120,
        ),
        children: [
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMint,
                        borderRadius: AppBorderRadius.allLarge,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        child: ClipRRect(
                          borderRadius: AppBorderRadius.allMedium,
                          child: Image.asset(
                            A.assets_cliss_logo_Cliss,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Cliss', style: AppTextStyles.h2),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Track your meals, calorie goals, and daily progress in one place.',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        title: 'Daily target',
                        value: '$_dailyCalorieTarget',
                        unit: 'kcal',
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: ValueListenableBuilder(
                        valueListenable: UserService.instance.coinsV,
                        builder: (context, coins, child) {
                          return _StatTile(
                            title: 'Coin balance',
                            value: '$coins',
                            unit: 'coins',
                            onTap: () => AppRoutes.toCoinStore(),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target setup', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.md),
                _SliderRow(
                  label: 'Height',
                  valueLabel: '$_height cm',
                  child: Slider(
                    value: _height.toDouble(),
                    min: 140,
                    max: 220,
                    divisions: 80,
                    onChanged: (value) => setState(() => _height = value.toInt()),
                  ),
                ),
                _SliderRow(
                  label: 'Weight',
                  valueLabel: '$_weight kg',
                  child: Slider(
                    value: _weight.toDouble(),
                    min: 40,
                    max: 150,
                    divisions: 110,
                    onChanged: (value) => setState(() => _weight = value.toInt()),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text('Weekly exercise', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: List.generate(
                    4,
                    (index) => _SelectPill(
                      text: ['0-1/week', '2-3/week', '4-5/week', '6+/week'][index],
                      selected: _weeklyExercise == index,
                      onTap: () => setState(() => _weeklyExercise = index),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Goal', style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: _goals
                      .map(
                        (goal) => _SelectPill(
                          text: _goalLabels[goal]!,
                          selected: _goal == goal,
                          onTap: () => setState(() => _goal = goal),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: AppSpacing.lg),
                AppButton(
                  text: 'Calculate Daily Target',
                  onPressed: _calculateDailyTarget,
                  width: double.infinity,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                _MenuLine(
                  title: 'Terms of Service',
                  icon: Icons.description_outlined,
                  onTap: () => AppRoutes.toAgreement('Terms of Service', AppEnv().h5User),
                ),
                _MenuLine(
                  title: 'Privacy Policy',
                  icon: Icons.privacy_tip_outlined,
                  onTap: () => AppRoutes.toAgreement('Privacy Policy', AppEnv().h5Privacy),
                ),
                _MenuLine(
                  title: 'Feedback',
                  icon: Icons.chat_bubble_outline_rounded,
                  onTap: () => AppRoutes.toFeedback(),
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          AppButton(
            text: 'Logout',
            onPressed: _handleLogout,
            isSecondary: true,
            width: double.infinity,
          ),
          const SizedBox(height: AppSpacing.sm),
          AppButton(
            text: 'Delete Account',
            onPressed: _handleDeleteAccount,
            isOutlined: true,
            width: double.infinity,
          ),
        ],
      ),
    );
  }
}

Future<bool?> _showConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmText,
}) {
  return showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xl,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
          AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: AppColors.backgroundSecondary,
          borderRadius: AppBorderRadius.allLarge,
          boxShadow: AppShadows.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            Text(
              message,
              style: AppTextStyles.body.copyWith(
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: AppTextButton(
                    text: 'Cancel',
                    onPressed: () => Navigator.pop(context, false),
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: AppButton(
                    text: confirmText,
                    onPressed: () => Navigator.pop(context, true),
                    width: double.infinity,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

class _StatTile extends StatelessWidget {
  final String title;
  final String value;
  final String unit;
  final VoidCallback? onTap;

  const _StatTile({
    required this.title,
    required this.value,
    required this.unit,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.small.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTextStyles.h2),
          Text(
            unit,
            style: AppTextStyles.small.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _SliderRow extends StatelessWidget {
  final String label;
  final String valueLabel;
  final Widget child;

  const _SliderRow({
    required this.label,
    required this.valueLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            Text(valueLabel, style: AppTextStyles.label),
          ],
        ),
        child,
      ],
    );
  }
}

class _SelectPill extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _SelectPill({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryMain : AppColors.surfaceGlass,
          borderRadius: AppBorderRadius.allMedium,
          border: Border.all(
            color: selected ? AppColors.primaryMain : AppColors.borderSoft,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(
            color: selected ? AppColors.textInverse : AppColors.primaryMain,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _MenuLine extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool showDivider;

  const _MenuLine({
    required this.title,
    required this.icon,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          onTap: onTap,
          leading: Icon(icon, color: AppColors.primaryMain),
          title: Text(title, style: AppTextStyles.bodyEmphasis),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
        if (showDivider) const Divider(height: 1),
      ],
    );
  }
}
