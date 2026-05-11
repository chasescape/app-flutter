import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tanie/tanie/bloc/auth/auth_bloc.dart';
import 'package:tanie/tanie/bloc/auth/auth_event.dart';
import 'package:tanie/tanie/bloc/auth/auth_state.dart';
import 'package:tanie/tanie/bloc/content/content_bloc.dart';
import 'package:tanie/tanie/bloc/content/content_event.dart';
import 'package:tanie/tanie/bloc/content/content_state.dart';
import 'package:tanie/tanie/routes/app_routes.dart';
import 'package:tanie/tanie/services/ai_image_analysis_service.dart';
import 'package:tanie/tanie/services/reflection_storage_service.dart';
import 'package:tanie/tanie/theme/app_colors.dart';
import 'package:tanie/tanie/theme/app_text_styles.dart';
import 'package:tanie/tanie/widgets/app_button.dart';
import 'package:tanie/tanie/widgets/app_loading.dart';
import 'package:tanie/tanie/widgets/app_ui.dart';

class CreationPage extends StatefulWidget {
  final bool showBackButton;

  const CreationPage({
    super.key,
    this.showBackButton = true,
  });

  @override
  State<CreationPage> createState() => _CreationPageState();
}

class _CreationPageState extends State<CreationPage> {
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _promptController = TextEditingController();
  final int _creationCost = 50;
  String? _selectedImagePath;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  Future<bool> _requestPhotoPermission() async {
    final status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      return true;
    }

    if (!mounted) return false;

    if (status.isPermanentlyDenied || status.isRestricted) {
      await showDialog<void>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Photo Access Needed'),
            content: const Text(
              'Please allow photo library access in Settings so you can upload an image.',
              style: AppTextStyles.bodyMedium,
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  context.pop();
                  openAppSettings();
                },
                child: const Text('Open Settings'),
              ),
            ],
          );
        },
      );
      return false;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Photo access is required to upload an image.'),
      ),
    );
    return false;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final hasPermission = source == ImageSource.gallery
          ? await _requestPhotoPermission()
          : true;
      if (!hasPermission) return;

      final image = await _picker.pickImage(source: source);
      if (image == null || !mounted) return;
      setState(() => _selectedImagePath = image.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to pick image: $e')),
      );
    }
  }

  Future<void> _createReflection() async {
    if (_selectedImagePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image first')),
      );
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState.coins < _creationCost) {
      _showInsufficientCoinsSheet(authState.coins);
      return;
    }

    final authBloc = context.read<AuthBloc>();
    final contentBloc = context.read<ContentBloc>();
    final router = GoRouter.of(context);

    contentBloc.add(const StartLoadingEvent());

    try {
      aiImageAnalysisService.init();
      await reflectionStorageService.init();
      final reflectionEntry = await aiImageAnalysisService.analyzeImage(
        imagePath: _selectedImagePath!,
        customPrompt: _promptController.text.trim().isEmpty
            ? null
            : _promptController.text.trim(),
      );
      await reflectionStorageService.saveEntry(reflectionEntry);
      authBloc.add(UpdateCoinsEvent(authState.coins - _creationCost));
      contentBloc.add(const StopLoadingEvent());
      if (!mounted) return;
      router.push(AppRoutes.detail, extra: reflectionEntry);
    } catch (e) {
      contentBloc.add(const StopLoadingEvent());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Analysis failed: $e'),
          action: SnackBarAction(
            label: 'Retry',
            textColor: AppColors.white,
            onPressed: _createReflection,
          ),
        ),
      );
    }
  }

  void _openCoinStore(BuildContext currentContext) {
    Navigator.of(currentContext).pop();
    context.push(AppRoutes.coinStore);
  }

  void _showInsufficientCoinsSheet(int currentCoins) {
    final shortfall = _creationCost - currentCoins;

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text('Not enough coins', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'This generation needs $_creationCost coins. You currently have $currentCoins, so you need $shortfall more to continue.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 18),
                AppSectionCard(
                  onTap: () => _openCoinStore(sheetContext),
                  gradient: AppColors.accentGradient,
                  child: Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(
                          Icons.monetization_on_rounded,
                          color: AppColors.secondaryMain,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Open coin store',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap here to purchase coins and unlock this reflection.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  text: 'Go to Payment',
                  onPressed: () => _openCoinStore(sheetContext),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(sheetContext).pop(),
                    child: const Text('Maybe later'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, authState) {
          return BlocBuilder<ContentBloc, ContentState>(
            builder: (context, contentState) {
              return AppLoadingOverlay(
                isLoading: contentState.isLoading,
                message: 'Analyzing your photo...',
                child: AppBackdrop(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.showBackButton) ...[
                              AppIconCircle(
                                icon: Icons.arrow_back_rounded,
                                onTap: () => context.pop(),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: AppSectionTitle(
                                title: widget.showBackButton
                                    ? 'New Reflection'
                                    : 'Create',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        AppSectionCard(
                          padding: const EdgeInsets.all(14),
                          child: GestureDetector(
                            onTap: () => _pickImage(ImageSource.gallery),
                            child: Container(
                              width: double.infinity,
                              height: 460,
                              decoration: BoxDecoration(
                                color: AppColors.cardMuted,
                                borderRadius: BorderRadius.circular(28),
                              ),
                              child: _selectedImagePath == null
                                  ? Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 74,
                                          height: 74,
                                          decoration: BoxDecoration(
                                            gradient: AppColors.primaryGradient,
                                            borderRadius:
                                                BorderRadius.circular(26),
                                          ),
                                          child: const Icon(
                                            Icons.add_photo_alternate_outlined,
                                            color: AppColors.textPrimary,
                                            size: 34,
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Tap to upload image',
                                          style: AppTextStyles.h3,
                                        ),
                                        const SizedBox(height: 6),
                                        const Text(
                                          'Tap to choose an image from your gallery.',
                                          style: AppTextStyles.bodyMedium,
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    )
                                  : Stack(
                                      children: [
                                        Positioned.fill(
                                          child: AppAdaptiveImage(
                                            imagePath: _selectedImagePath!,
                                            borderRadius:
                                                BorderRadius.circular(28),
                                          ),
                                        ),
                                        const Positioned(
                                          right: 12,
                                          top: 12,
                                          child: AppStickerChip(
                                            label: 'Change',
                                            icon: Icons.edit_rounded,
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppSectionCard(
                          gradient: AppColors.accentGradient,
                          child: Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Icon(
                                  Icons.monetization_on_rounded,
                                  color: AppColors.secondaryMain,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  'Generation Cost  $_creationCost coins',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppPrimaryButton(
                          text: 'Generate Reflection',
                          onPressed: _createReflection,
                          isEnabled: _selectedImagePath != null,
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
