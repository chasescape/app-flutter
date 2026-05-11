import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/models/ingredient_analysis.dart';
import '../../core/models/user_data.dart';
import '../../core/providers/app_providers.dart';
import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/common_widgets.dart';
import '../main/main_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    final userData = ref.watch(userDataProvider);
    final history = ref.watch(analysisHistoryProvider);
    final featuredItems = history.take(4).toList();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHero(userData),
                const SizedBox(height: AppSpacing.lg),
                _buildCaptureActions(),
                const SizedBox(height: AppSpacing.xl),
                AppSectionHeader(
                  title: 'Recent scans',
                  subtitle: 'Image-first cards with quick visual recall.',
                  actionLabel: history.isEmpty ? null : 'See all',
                  onAction: history.isEmpty
                      ? null
                      : () => _navigateToHistory(context),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
        if (featuredItems.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
              child: EmptyState(
                message:
                    'No scans yet.\nStart with a gallery shot or camera capture.',
                icon: Icons.photo_library_outlined,
                actionLabel: 'Choose from gallery',
                onAction: () => _pickImage(ImageSource.gallery),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildScanCard(featuredItems[index]);
                },
                childCount: featuredItems.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.70,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHero(UserData userData) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(20),
      borderRadius: BorderRadius.circular(AppBorderRadius.xlarge),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Decode beauty labels',
                      style: AppTextStyles.h2.copyWith(
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    const Text(
                      'A soft, visual-first feed for ingredients and product scans.',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppStatPill(
                icon: Icons.auto_awesome_rounded,
                label: '${userData.freeUses} free scans',
              ),
              AppStatPill(
                icon: Icons.stars_rounded,
                label: '${userData.coins} coins',
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: AppGradients.hero,
              borderRadius: BorderRadius.circular(AppBorderRadius.large),
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan, save, compare',
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Keep the imagery big and the reading light.',
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureActions() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final tileWidth = (constraints.maxWidth - AppSpacing.md) / 2;

        return Row(
          children: [
            SizedBox(
              width: tileWidth,
              child: _CaptureTile(
                title: 'Camera',
                subtitle: 'Fresh capture',
                icon: Icons.photo_camera_back_rounded,
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            SizedBox(
              width: tileWidth,
              child: _CaptureTile(
                title: 'Gallery',
                subtitle: 'Use existing shot',
                icon: Icons.collections_rounded,
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScanCard(IngredientAnalysis analysis) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      onTap: () => AppRoutes.toResult({'analysis': analysis}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppBorderRadius.large),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AppRemoteImage(imageUrl: analysis.imageUrl),
                  ),
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.84),
                        borderRadius:
                            BorderRadius.circular(AppBorderRadius.full),
                      ),
                      child: Text(
                        _primaryCategory(analysis),
                        style: AppTextStyles.small.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.productName,
                  style: AppTextStyles.body.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  _formatDate(analysis.createdAt),
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToHistory(BuildContext context) {
    try {
      final mainPageState = context.findAncestorStateOfType<State<MainPage>>();
      if (mainPageState is MainPageState) {
        mainPageState.navigateToTab(1);
      }
    } catch (_) {
      AppRoutes.toMain();
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final hasPermission = await _ensureMediaPermission(source);
      if (!hasPermission || !mounted) {
        return;
      }

      final XFile? image = await _imagePicker.pickImage(
        source: source,
        requestFullMetadata: false,
      );
      if (image != null && mounted) {
        AppRoutes.toResult({'imagePath': image.path});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              source == ImageSource.gallery
                  ? 'Unable to open photos. Check photo access or try a simulator with media.'
                  : 'Failed to open camera: $e',
            ),
          ),
        );
      }
    }
  }

  Future<bool> _ensureMediaPermission(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        return true;
      }

      if (mounted) {
        await _showPermissionDialog(
          title: 'Camera access needed',
          message:
              'Please allow camera access so you can capture product photos.',
        );
      }
      return false;
    }

    var status = await Permission.photos.status;
    if (status.isGranted || status.isLimited) {
      return true;
    }

    status = await Permission.photos.request();
    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (mounted) {
      await _showPermissionDialog(
        title: 'Photo access needed',
        message:
            'Please allow photo library access so you can choose an existing image.',
      );
    }
    return false;
  }

  Future<void> _showPermissionDialog({
    required String title,
    required String message,
  }) async {
    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Not now'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open settings'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes} min ago';
      }
      return '${diff.inHours} hours ago';
    }
    if (diff.inDays == 1) {
      return 'Yesterday';
    }
    if (diff.inDays < 7) {
      return '${diff.inDays} days ago';
    }
    return '${date.month}/${date.day}/${date.year}';
  }

  String _primaryCategory(IngredientAnalysis analysis) {
    if (analysis.categories.isEmpty) {
      return 'Scan';
    }
    return analysis.categories.first.split(' ').first;
  }
}

class _CaptureTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _CaptureTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                gradient: AppGradients.hero,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.textPrimary),
            ),
            const Spacer(),
            Text(
              title,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              style: AppTextStyles.small,
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const HomePage();
  }
}
