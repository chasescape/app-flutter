import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_border_radius.dart';
import '../../core/widgets/app_card.dart';
import '../../core/widgets/app_button.dart';
import '../../core/utils/app_overlay.dart';
import '../../cherish_ai/cherish_card_storage.dart';
import '../../routes/app_pages.dart';
import '../main/main_shell_page.dart';

/// History Page - User Creations History (Woozi History Layout)
/// Shows list of user's past creations with pull-to-refresh
class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  static const Color _berryPrimary = Color(0xFF8F355B);
  static const Color _berrySecondary = Color(0xFFB06A84);
  static const Color _pageTop = Color(0xFFFFEAF4);
  static const Color _pageMid = Color(0xFFFFD7E7);
  static const Color _pageBottom = Color(0xFFFFF5DF);
  static const Color _cardBg = Color(0xFFFFFCFE);

  List<CherishCardHistoryItem> _historyItems = [];
  Worker? _tabListener;

  @override
  void initState() {
    super.initState();
    _loadHistory();

    if (Get.isRegistered<MainShellController>()) {
      final controller = Get.find<MainShellController>();
      _tabListener = ever<int>(controller.currentIndex, (index) {
        if (index == 2) {
          _loadHistory();
        }
      });
    }
  }

  @override
  void dispose() {
    _tabListener?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: _pageTop,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: _berryPrimary),
        title: const Text(
          'My Creations',
          style: TextStyle(
            color: _berryPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_pageTop, _pageMid, _pageBottom],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadHistory,
          child: _historyItems.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: AppSpacing.paddingMD,
                  itemCount: _historyItems.length,
                  itemBuilder: (context, index) {
                    return _buildCreationCard(_historyItems[index]);
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history,
                size: 64,
                color: _berrySecondary.withOpacity(0.35),
              ),
              AppSpacing.gapMD,
              Text(
                'No creations yet',
                style: AppTextStyles.h3Style.copyWith(color: _berryPrimary),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapSM,
              Text(
                'Start creating your happy moments!',
                style: AppTextStyles.bodySecondaryStyle.copyWith(color: _berrySecondary),
                textAlign: TextAlign.center,
              ),
              AppSpacing.gapLG,
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  text: 'Create Now',
                  gradientColors: const [
                    Color(0xFFFF4D67),
                    Color(0xFFFF8FA3),
                    Color(0xFFFFD36E),
                  ],
                  onPressed: () => AppRoutes.toCreate(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreationCard(CherishCardHistoryItem item) {
    return GestureDetector(
      onTap: () => AppRoutes.toDetail(item.data, imagePath: item.imagePath),
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: AppCard(
          backgroundColor: _cardBg.withOpacity(0.78),
          child: Row(
            children: [
              // Thumbnail
              ClipRRect(
                borderRadius: AppBorderRadius.borderRadiusMD,
                child: Image.asset(
                  item.imagePath,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.file(
                      key: ValueKey(item.id),
                      File(item.imagePath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          color: AppColors.bgSecondary,
                          child: const Icon(Icons.image),
                        );
                      },
                    );
                  },
                ),
              ),

              AppSpacing.gapMD,

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.shortSummary.isEmpty ? 'Untitled Creation' : item.shortSummary,
                      style: AppTextStyles.bodyMediumStyle.copyWith(
                        color: _berryPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    AppSpacing.gapSM,
                    Text(
                      _formatDate(item.createdAt),
                      style: AppTextStyles.smallStyle.copyWith(
                        color: _berrySecondary,
                      ),
                    ),
                    AppSpacing.gapSM,
                    Row(
                      children: [
                        Icon(
                          Icons.monetization_on,
                          size: 14,
                          color: AppColors.warning,
                        ),
                        AppSpacing.gapXS,
                        Text(
                          '-${item.costCoins} coins',
                          style: AppTextStyles.smallStyle.copyWith(
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              AppSpacing.gapSM,

              // Arrow icon
              Icon(
                Icons.chevron_right,
                color: _berrySecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _loadHistory() async {
    try {
      final cards = await CherishCardStorage.getList();
      setState(() {
        _historyItems = cards;
      });
    } catch (e) {
      debugPrint('Failed to load cherish history: $e');
      if (!mounted) {
        return;
      }
      setState(() {
        _historyItems = [];
      });
      AppOverlay.showToast(
        context,
        message: 'Failed to load history',
        type: ToastType.error,
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.month}/${date.day}/${date.year}';
    }
  }
}
