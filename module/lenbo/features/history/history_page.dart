import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lenbo/lenbo/app/routes/app_routes.dart';
import 'package:lenbo/lenbo/app/widgets/confirm_dialog.dart';
import 'package:lenbo/lenbo/core/theme/app_colors.dart';
import 'package:lenbo/lenbo/core/theme/app_spacing.dart';
import 'package:lenbo/lenbo/core/services/analysis_storage.dart';
import 'package:lenbo/lenbo/data/models/plant_analysis.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<PlantAnalysis> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
    AnalysisStorage.historyNotifier.addListener(_onHistoryChanged);
  }

  @override
  void dispose() {
    AnalysisStorage.historyNotifier.removeListener(_onHistoryChanged);
    super.dispose();
  }

  void _onHistoryChanged() {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final data = await AnalysisStorage.loadHistory();
    if (mounted) {
      setState(() {
        _history = data;
        _isLoading = false;
      });
    }
  }

  Widget _buildImage(String assetImg) {
    if (assetImg.isEmpty) {
      return Container(
        color: AppColors.bgTertiary,
        child: const Center(
          child: Icon(Icons.local_florist, size: 32, color: AppColors.textDisabled),
        ),
      );
    }
    if (assetImg.startsWith('assets/')) {
      return Image.asset(assetImg, fit: BoxFit.cover, width: double.infinity);
    }
    return Image.file(
      File(assetImg),
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(
        color: AppColors.bgTertiary,
        child: const Center(
          child: Icon(Icons.broken_image, size: 32, color: AppColors.textDisabled),
        ),
      ),
    );
  }

  Color _healthColor(String status) {
    switch (status.toLowerCase()) {
      case 'healthy':
        return AppColors.success;
      case 'needs attention':
        return AppColors.warning;
      case 'critical':
        return AppColors.error;
      default:
        return AppColors.secondaryMain;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        backgroundColor: AppColors.bgPrimary,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        title: const Text('History', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        actions: [
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, size: 22),
              onPressed: () => _showClearAllDialog(context),
            ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.bgPrimary,
                  AppColors.accentMain.withAlpha(26),
                  AppColors.bgPrimary,
                ],
              ),
            ),
          ),
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondaryMain),
                  ),
                )
              : _history.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.xl),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                border: Border.all(color: AppColors.cardBorderLight, width: 0.6),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondaryMain.withAlpha(36),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Icon(
                Icons.history,
                size: 64,
                color: AppColors.secondaryMain.withAlpha(90),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Analysis History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start analyzing your plants to build your history',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 20, AppSpacing.md, AppSpacing.lg),
      itemCount: _history.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final plant = _history[index];
        return _HistoryCard(plant: plant, buildImage: _buildImage, healthColor: _healthColor);
      },
    );
  }

  Future<void> _showClearAllDialog(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Clear All History',
      content: 'Are you sure you want to clear all analysis history? This action cannot be undone.',
      confirmText: 'Clear All',
      isDangerous: true,
    );
    if (confirmed == true) {
      await AnalysisStorage.clearHistory();
    }
  }
}

class _HistoryCard extends StatelessWidget {
  final PlantAnalysis plant;
  final Widget Function(String) buildImage;
  final Color Function(String) healthColor;

  static const Color _dispersionCyan = Color(0xFF00D5FF);
  static const Color _dispersionMagenta = Color(0xFFFF2EA6);
  static const Color _dispersionYellow = Color(0xFFFFD36A);

  const _HistoryCard({
    required this.plant,
    required this.buildImage,
    required this.healthColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => AppRoutes.toDetail(plant),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.secondaryMain.withAlpha(38), width: 0.8),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryMain.withAlpha(18),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: _dispersionCyan.withAlpha(26),
              blurRadius: 26,
              offset: const Offset(10, 6),
            ),
            BoxShadow(
              color: _dispersionMagenta.withAlpha(28),
              blurRadius: 26,
              offset: const Offset(-10, 6),
            ),
            BoxShadow(
              color: _dispersionYellow.withAlpha(22),
              blurRadius: 30,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Row(
          children: [
            // Plant image thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(AppSpacing.radiusLg),
              ),
              child: SizedBox(
                width: 100,
                height: 100,
                child: buildImage(plant.assetImg),
              ),
            ),
            const SizedBox(width: 12),
            // Plant info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plant.plantId.commonName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      plant.plantId.scientificName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: healthColor(plant.healthCheck.status).withAlpha(22),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                          ),
                          child: Text(
                            plant.healthCheck.status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: healthColor(plant.healthCheck.status),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          plant.environmentReading.lightEnv,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textDisabled,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.secondaryMain.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.chevron_right, color: AppColors.secondaryMain, size: 18),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
