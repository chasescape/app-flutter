import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paech/gen_a/A.dart';

import '../nav/nav_logic.dart';
import 'generate_logic.dart';

class GeneratePage extends StatefulWidget {
  GeneratePage({super.key});

  @override
  State<GeneratePage> createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> with SingleTickerProviderStateMixin {
  late final GenerateLogic logic;
  late final AnimationController _animationController;
  late final Animation<double> _introFade;
  late final Animation<Offset> _introSlide;
  late final Animation<double> _takePhotoFade;
  late final Animation<Offset> _takePhotoSlide;
  late final Animation<double> _galleryFade;
  late final Animation<Offset> _gallerySlide;
  late final Animation<double> _tipFade;
  late final Animation<double> _feature1Fade;
  late final Animation<double> _feature2Fade;
  late final Animation<double> _feature3Fade;

  static const int _kGenerateTabIndex = 1;
  bool _hasPlayedEntrance = false;

  @override
  void initState() {
    super.initState();
    logic = Get.put(GenerateLogic());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    );
    _introFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _introSlide = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _takePhotoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );
    _takePhotoSlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.1, 0.5, curve: Curves.easeOut),
      ),
    );
    _galleryFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _gallerySlide = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );
    _tipFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.75, curve: Curves.easeOut),
      ),
    );
    _feature1Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.55, 0.8, curve: Curves.easeOut),
      ),
    );
    _feature2Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.85, curve: Curves.easeOut),
      ),
    );
    _feature3Fade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.65, 0.9, curve: Curves.easeOut),
      ),
    );
    // 仅首次切到本 Tab 时播放入场渐入动画
    final navLogic = Get.find<NavLogic>();
    ever(navLogic.tabIndex, (int index) {
      if (!mounted || index != _kGenerateTabIndex || _hasPlayedEntrance) return;
      _hasPlayedEntrance = true;
      _animationController.reset();
      _animationController.forward();
    });
    if (navLogic.tabIndex.value == _kGenerateTabIndex) {
      _hasPlayedEntrance = true;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Generate',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2D2A26),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Get AI-powered care & styling tips',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF8D857C),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3EDE6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_outlined,
                        size: 16,
                        color: Color(0xFFB89B79),
                      ),
                      const SizedBox(width: 8),
                      Obx(() {
                        String displayText;
                        if (logic.isFreeGenerationMode) {
                          displayText = '${logic.creditsDisplayText} Free';
                        } else {
                          displayText = '${logic.creditsDisplayText} Coins';
                        }
                        return Text(
                          displayText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2D2A26),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8E0D7)),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Obx(() {
                    final hasImage = logic.selectedImage.value != null;
                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: Tween<double>(begin: 0.96, end: 1.0).animate(
                              CurvedAnimation(parent: animation, curve: Curves.easeOut),
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: hasImage
                          ? _BuildPreviewSection(key: const ValueKey(true), logic: logic)
                          : _BuildIntroSection(
                              key: const ValueKey(false),
                              introFade: _introFade,
                              introSlide: _introSlide,
                              takePhotoFade: _takePhotoFade,
                              takePhotoSlide: _takePhotoSlide,
                              galleryFade: _galleryFade,
                              gallerySlide: _gallerySlide,
                              logic: logic,
                            ),
                    );
                  }),
                  const SizedBox(height: 40),
                  FadeTransition(
                    opacity: _tipFade,
                    child: const _TipCard(),
                  ),
                  const SizedBox(height: 30),
                  FadeTransition(
                    opacity: _feature1Fade,
                    child: const _FeatureCard(
                      icon: Icons.auto_awesome_outlined,
                      title: 'AI-Powered Analysis',
                      subtitle:
                          'Advanced computer vision identifies fabric types, colors, and patterns to provide tailored care recommendations',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _feature2Fade,
                    child: const _FeatureCard(
                      icon: Icons.checkroom_outlined,
                      title: 'Personalized Styling',
                      subtitle:
                          'Get creative outfit combinations and styling ideas to maximize your wardrobe potential',
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeTransition(
                    opacity: _feature3Fade,
                    child: const _FeatureCard(
                      icon: Icons.shield_outlined,
                      title: 'Extend Garment Life',
                      subtitle:
                          'Professional care tips help protect your investment and keep clothes looking brand new longer',
                    ),
                  ),
                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 未选图时：介绍区 + Take Photo / Gallery 按钮（带错峰淡入上移）
class _BuildIntroSection extends StatelessWidget {
  const _BuildIntroSection({
    super.key,
    required this.introFade,
    required this.introSlide,
    required this.takePhotoFade,
    required this.takePhotoSlide,
    required this.galleryFade,
    required this.gallerySlide,
    required this.logic,
  });

  final Animation<double> introFade;
  final Animation<Offset> introSlide;
  final Animation<double> takePhotoFade;
  final Animation<Offset> takePhotoSlide;
  final Animation<double> galleryFade;
  final Animation<Offset> gallerySlide;
  final GenerateLogic logic;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FadeTransition(
          opacity: introFade,
          child: SlideTransition(
            position: introSlide,
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFE0C3A2),
                        Color(0xFFC8A57E),
                      ],
                    ),
                  ),
                  child: Center(
                    child: ColorFiltered(
                      colorFilter: const ColorFilter.mode(
                        Colors.white,
                        BlendMode.srcIn,
                      ),
                      child: Image.asset(
                        A.assets_paech_ic_create,
                        width: 60,
                        height: 60,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Smart Clothing Care',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2D2A26),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Upload a photo to receive personalized care instructions and styling suggestions powered by AI',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF8D857C),
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.speed,
                      size: 16,
                      color: Color(0xFFB89B79),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Instant AI Analysis',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFB89B79),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 35),
              ],
            ),
          ),
        ),
        FadeTransition(
          opacity: takePhotoFade,
          child: SlideTransition(
            position: takePhotoSlide,
            child: _PrimaryActionButton(
              icon: Icons.camera_alt_outlined,
              title: 'Take Photo',
              subtitle: 'Use camera to capture',
              onTap: logic.takePhoto,
              isSelected: false,
            ),
          ),
        ),
        const SizedBox(height: 15),
        FadeTransition(
          opacity: galleryFade,
          child: SlideTransition(
            position: gallerySlide,
            child: _SecondaryActionButton(
              icon: Icons.image_outlined,
              title: 'Choose from Gallery',
              subtitle: 'Select existing photo',
              onTap: logic.pickImageFromGallery,
              isSelected: false,
            ),
          ),
        ),
      ],
    );
  }
}

/// 已选图时：预览区 + Generate 按钮（AnimatedSwitcher 内淡入+缩放）
class _BuildPreviewSection extends StatelessWidget {
  const _BuildPreviewSection({super.key, required this.logic});

  final GenerateLogic logic;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15),
          child: Container(
            height: 360,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE8E0D7)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Image.file(
                  logic.selectedImage.value!,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: InkWell(
                    onTap: () => logic.selectedImage.value = null,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        _GenerateButtonWithScale(
          logic: logic,
          onTap: logic.startGeneration,
        ),
      ],
    );
  }
}

/// Generate 按钮：按下时缩放至 0.98
class _GenerateButtonWithScale extends StatefulWidget {
  const _GenerateButtonWithScale({
    required this.logic,
    required this.onTap,
  });

  final GenerateLogic logic;
  final VoidCallback onTap;

  @override
  State<_GenerateButtonWithScale> createState() => _GenerateButtonWithScaleState();
}

class _GenerateButtonWithScaleState extends State<_GenerateButtonWithScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.logic.canGenerate() && !widget.logic.isGenerating.value) {
          setState(() => _pressed = true);
        }
      },
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.logic.canGenerate() && !widget.logic.isGenerating.value
          ? widget.onTap
          : null,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOut,
        child: Obx(() => _GenerateButton(
          onTap: widget.onTap,
          isGenerating: widget.logic.isGenerating.value,
          canGenerate: widget.logic.canGenerate(),
          hasEnoughCredits: widget.logic.hasEnoughCredits(),
        )),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFD8B792),
              Color(0xFFC8A57E),
            ],
          ),
        ),
        child: Align(
          alignment: Alignment.center,
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.92),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SecondaryActionButton extends StatelessWidget {
  const _SecondaryActionButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isSelected = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFF1EBE3)),
        ),
        child: Align(
          alignment: Alignment.center,
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: const Color(0xFFB89B79)),
                const SizedBox(width: 12),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF2D2A26),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF8D857C),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF7F5),
            Color(0xFFF3EDE6),
          ],
        ),
        border: Border.all(color: const Color(0xFFEFE7DE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF2EBE3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              size: 18,
              color: Color(0xFFC9A882),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Quick Tips',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF4A3C2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'For best results, take clear photos in good lighting with the full garment visible\n',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF8B7968),
                    height: 1.35,
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

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF2EBE3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 18,
              color: const Color(0xFFC9A882),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF4A3C2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF8B7968),
                    height: 1.35,
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

class _GenerateButton extends StatelessWidget {
  const _GenerateButton({
    required this.onTap,
    required this.isGenerating,
    required this.canGenerate,
    required this.hasEnoughCredits,
  });

  final VoidCallback onTap;
  final bool isGenerating;
  final bool canGenerate;
  final bool hasEnoughCredits;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEnabled = canGenerate && !isGenerating;

    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: isEnabled
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD8B792),
                  Color(0xFFC8A57E),
                ],
              )
            : null,
        color: isEnabled ? null : const Color(0xFFE8E0D7),
      ),
      alignment: Alignment.center,
      child: isGenerating
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: isEnabled ? Colors.white : const Color(0xFFB8B0A6),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'Generate',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isEnabled
                        ? Colors.white
                        : const Color(0xFFB8B0A6),
                  ),
                ),
              ],
            ),
    );
  }
}
