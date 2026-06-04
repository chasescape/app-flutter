import 'package:flutter/material.dart';
import 'package:cliss/cliss/app/routes/app_routes.dart';
import 'package:cliss/cliss/app/services/meal_storage_service.dart';
import 'package:cliss/cliss/app/theme/app_theme.dart';
import 'package:cliss/cliss/app/widgets/app_card.dart';
import 'package:cliss/cliss/app/widgets/app_image_frame.dart';
import 'package:cliss/cliss/app/widgets/app_scaffold.dart';
import 'package:cliss/cliss/data/models/meal_analysis.dart';
import 'package:cliss/cliss/features/data/data_page.dart';
import 'package:cliss/cliss/features/history/history_page.dart';
import 'package:cliss/cliss/features/profile/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  List<MealAnalysis> _mealData = [];
  bool _isLoading = true;
  int _refreshVersion = 0;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final history = await MealStorageService.instance.getMealHistory();
    if (!mounted) return;
    setState(() {
      _mealData = history;
      _isLoading = false;
      _refreshVersion++;
    });
  }

  void _handleTabChange(int index) {
    setState(() {
      _currentIndex = index;
    });
    if (index == 0 || index == 1 || index == 2) {
      _loadMeals();
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _HomeTab(
        mealData: _mealData,
        isLoading: _isLoading,
        onRefresh: _loadMeals,
      ),
      HistoryPage(refreshVersion: _refreshVersion),
      DataPage(mealData: _mealData),
      const ProfilePage(),
    ];

    return AppScaffold(
      safeBottom: false,
      bottomNavigationBar: _BottomNav(
        currentIndex: _currentIndex,
        onTap: _handleTabChange,
      ),
      child: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
    );
  }
}

class _HomeTab extends StatelessWidget {
  final List<MealAnalysis> mealData;
  final bool isLoading;
  final Future<void> Function() onRefresh;

  const _HomeTab({
    required this.mealData,
    required this.isLoading,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final averageCalories = mealData.isEmpty
        ? 0
        : mealData
                .map(
                  (meal) =>
                      (meal.nutritionAnalysis.calorieEstimate.min +
                          meal.nutritionAnalysis.calorieEstimate.max) ~/
                      2,
                )
                .reduce((sum, value) => sum + value) ~/
            mealData.length;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.md,
          AppSpacing.md,
          120,
        ),
        children: [
          _HomeHeader(
            mealCount: mealData.length,
            averageCalories: averageCalories,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 80),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (mealData.isEmpty) ...[
            const _EmptyHomeCard(),
            const SizedBox(height: AppSpacing.lg),
            _QuickCaptureCard(),
          ] else ...[
            _QuickCaptureCard(),
            const SizedBox(height: AppSpacing.lg),
            Text('Recent meals', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Your recent meal records with photos and estimated kcal.',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...mealData.take(4).map(
              (meal) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: _MealCard(meal: meal),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyHomeCard extends StatelessWidget {
  const _EmptyHomeCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('No meal records yet', style: AppTextStyles.h2),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Add your first meal and home will show what you ate plus an estimated kcal range.',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final int mealCount;
  final int averageCalories;

  const _HomeHeader({
    required this.mealCount,
    required this.averageCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cliss', style: AppTextStyles.display),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'A simple meal log for tracking what you ate and about how many kcal it was.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _StatPill(
              icon: Icons.restaurant_menu_rounded,
              text: '$mealCount records',
            ),
            const SizedBox(height: AppSpacing.sm),
            _StatPill(
              icon: Icons.local_fire_department_rounded,
              text: averageCalories > 0
                  ? '~$averageCalories kcal'
                  : 'Start logging',
              soft: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final MealAnalysis item;

  const _HeroCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => AppRoutes.toDetail(item),
      padding: EdgeInsets.zero,
      boxShadow: AppShadows.lg,
      child: AppImageFrame(
        imagePath: item.assetImg,
        height: 320,
        borderRadius: AppBorderRadius.allLarge,
        overlay: Positioned(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: AppSpacing.lg,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Tag(text: 'Latest record'),
              const SizedBox(height: AppSpacing.sm),
              Text(
                item.oneLineSummary,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.textInverse,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickCaptureCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => AppRoutes.toCreate(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surfaceMint,
              borderRadius: AppBorderRadius.allMedium,
            ),
            child: const Icon(
              Icons.add_a_photo_rounded,
              size: 28,
              color: AppColors.primaryMain,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add a new meal', style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Save what you ate today and keep a lightweight calorie record.',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  final MealAnalysis meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: () => AppRoutes.toDetail(meal),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppImageFrame(
            imagePath: meal.assetImg,
            height: 238,
            borderRadius: const BorderRadius.vertical(
              top: AppBorderRadius.radiusLarge,
            ),
            overlay: Positioned(
              left: AppSpacing.md,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
              child: Row(
                children: [
                  _Tag(text: meal.sceneCard.mealType),
                  const Spacer(),
                  _Tag(
                    text:
                        '${meal.nutritionAnalysis.calorieEstimate.min}-${meal.nutritionAnalysis.calorieEstimate.max} kcal',
                    soft: true,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    meal.oneLineSummary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyEmphasis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${meal.nutritionAnalysis.calorieEstimate.min}-${meal.nutritionAnalysis.calorieEstimate.max} kcal',
                  style: AppTextStyles.small.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const items = [
      (
        label: 'Home',
        icon: Icons.grid_view_rounded,
        activeIcon: Icons.grid_view_rounded,
      ),
      (
        label: 'History',
        icon: Icons.photo_library_outlined,
        activeIcon: Icons.photo_library_rounded,
      ),
      (
        label: 'Data',
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart_rounded,
      ),
      (
        label: 'Profile',
        icon: Icons.person_outline_rounded,
        activeIcon: Icons.person_rounded,
      ),
    ];

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: const Color(0xE6FFFFFF),
          borderRadius: AppBorderRadius.allXlarge,
          border: Border.all(color: AppColors.borderSoft),
          boxShadow: AppShadows.md,
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _BottomNavItem(
                  label: items[index].label,
                  icon: items[index].icon,
                  activeIcon: items[index].activeIcon,
                  selected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatefulWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_BottomNavItem> createState() => _BottomNavItemState();
}

class _BottomNavItemState extends State<_BottomNavItem> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.selected;
    final iconColor = isSelected
        ? AppColors.primaryMain
        : AppColors.textTertiary;
    final labelColor = isSelected
        ? AppColors.textPrimary
        : AppColors.textTertiary;

    return AnimatedScale(
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      scale: _pressed ? 0.97 : 1,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFF9F2F8),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: AppBorderRadius.allLarge,
          border: isSelected
              ? Border.all(color: const Color(0xFFF0E1EC))
              : Border.all(color: Colors.transparent),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x12000000),
                    offset: Offset(0, 8),
                    blurRadius: 18,
                    spreadRadius: -12,
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) {
              if (_pressed == value) return;
              setState(() {
                _pressed = value;
              });
            },
            borderRadius: AppBorderRadius.allLarge,
            splashColor: const Color(0x1A2A252A),
            highlightColor: const Color(0x102A252A),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.translationValues(
                      0,
                      isSelected ? -1.5 : 0,
                      0,
                    ),
                    child: Icon(
                      isSelected ? widget.activeIcon : widget.icon,
                      size: isSelected ? 19 : 18,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    style: AppTextStyles.small.copyWith(
                      color: labelColor,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w500,
                      letterSpacing: isSelected ? -0.1 : 0,
                    ),
                    child: Text(widget.label),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final bool soft;

  const _Tag({
    required this.text,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: soft ? const Color(0xBBFFFFFF) : AppColors.primaryMain,
        borderRadius: AppBorderRadius.allSmall,
      ),
      child: Text(
        text,
        style: AppTextStyles.small.copyWith(
          color: soft ? AppColors.primaryMain : AppColors.textInverse,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool soft;

  const _StatPill({
    required this.icon,
    required this.text,
    this.soft = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: soft ? AppColors.surfaceGlass : AppColors.primaryMain,
        borderRadius: AppBorderRadius.allMedium,
        border: soft ? Border.all(color: AppColors.borderSoft) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: soft ? AppColors.primaryMain : AppColors.textInverse,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            text,
            style: AppTextStyles.small.copyWith(
              color: soft ? AppColors.primaryMain : AppColors.textInverse,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
