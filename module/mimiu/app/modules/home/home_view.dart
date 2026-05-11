import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/models/photo_models.dart';
import 'package:mimiu/mimiu/app/modules/nav/nav_logic.dart';
import 'package:mimiu/mimiu/app/modules/category_photos/category_photos_logic.dart';
import 'package:mimiu/mimiu/app/routes/app_routes.dart';
import 'package:mimiu/mimiu/app/widgets/page_header.dart';
import 'package:mimiu/mimiu/app/widgets/symmetric_gradient_background.dart';

import 'home_logic.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeLogic logic = Get.put(HomeLogic());

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(child: SymmetricGradientBackground()),
        Column(
          children: [
            _Header(categories: logic.categories),
            Expanded(
              child: Obx(() {
                final categories = logic.categories.toList();
                if (categories.isEmpty) {
                  return const _EmptyState();
                }
                return _Content(categories: categories);
              }),
            ),
          ],
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.categories});

  final RxList<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PageHeader(
          title: 'Photos',
          titleSize: 40,
        ),
      ],
    );
  }
}

class _StripCard extends StatefulWidget {
  const _StripCard({required this.category});

  final CategoryModel category;

  @override
  State<_StripCard> createState() => _StripCardState();
}

class _StripCardState extends State<_StripCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final cover = widget.category.coverPhoto;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      onTap: () => Get.toNamed(
        AppRoutes.categoryPhotos,
        arguments: CategoryPhotosArgs(
          categoryId: widget.category.id,
          title: widget.category.name,
        ),
      ),
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1,
        duration: const Duration(milliseconds: 140),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF78350F).withValues(alpha: 0.30),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.24),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1F2937), Color(0xFF111827)],
            ),
          ),
          child: Stack(
            children: [
              if (cover != null)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.file(
                      File(cover),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.60),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFF422006).withValues(alpha: 0.90),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: const Color(0xFFF59E0B).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    widget.category.photoCount.toString(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFBBF24),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 10,
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.60),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Content extends StatelessWidget {
  const _Content({required this.categories});

  final List<CategoryModel> categories;

  @override
  Widget build(BuildContext context) {
    final recent = categories.take(3).toList();
    final all = categories.skip(3).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 24),
      children: [
        const _SectionTitle(
          title: 'Recent Days',
          trailing: null,
        ),
        const SizedBox(height: 14),
        _RecentGrid(items: recent),
        if (all.isNotEmpty) ...[
          const SizedBox(height: 26),
          _SectionTitle(
            title: 'All Collections',
            trailing: _CountBadge(count: categories.length),
          ),
          const SizedBox(height: 14),
          _AllCollectionsGrid(items: all),
        ],
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF422006).withValues(alpha: 0.40),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF92400E).withValues(alpha: 0.40),
        ),
      ),
      child: Text(
        '$count',
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Color(0xFFF59E0B),
        ),
      ),
    );
  }
}

class _RecentGrid extends StatelessWidget {
  const _RecentGrid({required this.items});

  final List<CategoryModel> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (c) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _BigCard(category: c),
            ),
          )
          .toList(),
    );
  }
}

class _AllCollectionsGrid extends StatelessWidget {
  const _AllCollectionsGrid({required this.items});

  final List<CategoryModel> items;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: items.length,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 3 / 4,
      ),
      itemBuilder: (context, index) => _TallCard(category: items[index]),
    );
  }
}

class _BigCard extends StatelessWidget {
  const _BigCard({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final cover = category.coverPhoto;
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.categoryPhotos,
        arguments: CategoryPhotosArgs(
          categoryId: category.id,
          title: category.name,
        ),
      ),
      child: _GlowCard(
        borderColor: const Color(0xFF78350F).withValues(alpha: 0.30),
        height: 170,
        breathing: true,
        child: Stack(
          children: [
            Positioned(
              left: 16,
              top: 18,
              child: _sparkle(
                size: 12,
                color: const Color(0xFFFDE68A).withValues(alpha: 0.85),
              ),
            ),
            Positioned(
              left: 34,
              top: 44,
              child: _sparkle(
                size: 7,
                color: const Color(0xFFFBBF24).withValues(alpha: 0.70),
              ),
            ),
            Positioned(
              right: 74,
              top: 18,
              child: _sparkle(
                size: 8,
                color: const Color(0xFFF59E0B).withValues(alpha: 0.60),
              ),
            ),
            Positioned(
              right: 24,
              top: 60,
              child: _sparkle(
                size: 6,
                color: const Color(0xFFFDE68A).withValues(alpha: 0.55),
              ),
            ),
            if (cover != null)
              Positioned.fill(
                child: Image.file(
                  File(cover),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
          if (cover == null)
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF111827),
                      const Color(0xFF1F2937),
                      Colors.black.withValues(alpha: 0.92),
                    ],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.80),
                    Colors.black.withValues(alpha: 0.40),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: 14,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF422006).withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.40),
                ),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                size: 18,
                color: Color(0xFFFBBF24),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.30),
                        ),
                      ),
                      child: Text(
                        '${category.photoCount} ${category.photoCount == 1 ? 'photo' : 'photos'}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFFDE68A),
                        ),
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: const Color(0xFFFBBF24).withValues(alpha: 0.85),
                  size: 26,
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }
}

class _TallCard extends StatelessWidget {
  const _TallCard({required this.category});

  final CategoryModel category;

  @override
  Widget build(BuildContext context) {
    final cover = category.coverPhoto;
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.categoryPhotos,
        arguments: CategoryPhotosArgs(
          categoryId: category.id,
          title: category.name,
        ),
      ),
      child: _GlowCard(
        borderColor: const Color(0xFF78350F).withValues(alpha: 0.30),
        height: null,
        breathing: true,
        child: Stack(
          children: [
            Positioned(
              left: 14,
              top: 16,
              child: _sparkle(
                size: 10,
                color: const Color(0xFFFDE68A).withValues(alpha: 0.80),
              ),
            ),
            Positioned(
              right: 18,
              top: 38,
              child: _sparkle(
                size: 6,
                color: const Color(0xFFFBBF24).withValues(alpha: 0.65),
              ),
            ),
            if (cover != null)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                child: Image.file(
                  File(cover),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
            ),
          if (cover == null)
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF111827),
                      Color(0xFF1F2937),
                      Colors.black,
                    ],
                  ),
                ),
              ),
            ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: _blurOrb(
              size: 120,
              color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
              blur: 70,
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: const Color(0xFFF59E0B)
                              .withValues(alpha: 0.30),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 4,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFBBF24),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${category.photoCount} ${category.photoCount == 1 ? 'photo' : 'photos'}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFFDE68A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.85),
                      size: 26,
                    ),
                  ],
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  Widget _blurOrb({
    required double size,
    required Color color,
    required double blur,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur / 6, sigmaY: blur / 6),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _GlowCard extends StatelessWidget {
  const _GlowCard({
    required this.child,
    required this.borderColor,
    this.height,
    this.breathing = false,
  });

  final Widget child;
  final Color borderColor;
  final double? height;
  final bool breathing;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(26);
    return Stack(
      children: [
        if (breathing)
          Positioned.fill(
            child: _BreathingGlow(
              borderRadius: radius,
              color: const Color(0xFFFBBF24),
            ),
          ),
        Container(
          height: height,
          decoration: BoxDecoration(
            borderRadius: radius,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.20),
                blurRadius: 30,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}

class _BreathingGlow extends StatefulWidget {
  const _BreathingGlow({
    required this.borderRadius,
    required this.color,
  });

  final BorderRadius borderRadius;
  final Color color;

  @override
  State<_BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<_BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1650),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final t = Curves.easeInOut.transform(_c.value);
          final a = 0.22 + 0.20 * t; // opacity breathing
          final spread = 6 + 10 * t;
          final blur = 26 + 18 * t;
          return ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.05,
                  colors: [
                    widget.color.withValues(alpha: a),
                    const Color(0xFFF59E0B).withValues(alpha: a * 0.55),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.color.withValues(alpha: a),
                    blurRadius: 24 + spread,
                    spreadRadius: spread,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget _sparkle({
  required double size,
  required Color color,
}) {
  return IgnorePointer(
    child: Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.90),
            blurRadius: 10,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.50),
            blurRadius: 22,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(28, 20, 28, 96),
      children: const [
        _StartOrganizingCard(),
        SizedBox(height: 18),
        _FeatureCard(
          title: 'Swipe Gestures',
          subtitle: 'Delete or keep with simple,\nintuitive swipes',
          icon: Icons.auto_awesome_rounded,
          accent: Color(0xFFF59E0B),
          dot: true,
        ),
        SizedBox(height: 14),
        _FeatureCard(
          title: 'Lightning Fast',
          subtitle: 'Sort hundreds of photos in\njust minutes',
          icon: Icons.bolt_rounded,
          accent: Color(0xFFFBBF24),
          highlightTitle: true,
        ),
        SizedBox(height: 14),
        _FeatureCard(
          title: 'Auto Collections',
          subtitle: 'Photos organized\nautomatically as you sort',
          icon: Icons.image_outlined,
          accent: Color(0xFFF59E0B),
        ),
      ],
    );
  }
}

class _StartOrganizingCard extends StatefulWidget {
  const _StartOrganizingCard();

  @override
  State<_StartOrganizingCard> createState() => _StartOrganizingCardState();
}

class _StartOrganizingCardState extends State<_StartOrganizingCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _bounce.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Stronger dispersion / glow around the card.
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.0,
                    colors: [
                      const Color(0xFFF59E0B).withValues(alpha: 0.35),
                      const Color(0xFFB45309).withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.45, 1.0],
                  ),
                ),
              ),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF92400E).withValues(alpha: 0.42),
              width: 2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.grey.shade900.withValues(alpha: 0.78),
                Colors.black.withValues(alpha: 0.90),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF78350F).withValues(alpha: 0.55),
                blurRadius: 70,
                spreadRadius: 10,
                offset: const Offset(0, 26),
              ),
            ],
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              SizedBox(
                height: 220,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _orb(
                        size: 320,
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.22),
                        blur: 180,
                      ),
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(36),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              const Color(0xFF422006).withValues(alpha: 0.95),
                              const Color(0xFF78350F).withValues(alpha: 0.75),
                            ],
                          ),
                          border: Border.all(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.36),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF59E0B)
                                  .withValues(alpha: 0.30),
                              blurRadius: 48,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add_photo_alternate_rounded,
                          size: 70,
                          color: Color(0xFFFBBF24),
                        ),
                      ),
                      Container(
                        width: 212,
                        height: 212,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFF59E0B)
                                .withValues(alpha: 0.22),
                            width: 2,
                          ),
                        ),
                      ),
                      _orbitIcon(
                        alignment: const Alignment(-0.62, -0.22),
                        icon: Icons.ios_share_rounded,
                      ),
                      _orbitIcon(
                        alignment: const Alignment(0.68, -0.26),
                        icon: Icons.auto_awesome_rounded,
                      ),
                      _orbitIcon(
                        alignment: const Alignment(-0.68, 0.56),
                        icon: Icons.image_outlined,
                      ),
                      _orbitIcon(
                        alignment: const Alignment(0.60, 0.62),
                        icon: Icons.bolt_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Start',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFFDE68A),
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Organizing',
                style: TextStyle(
                  fontSize: 46,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Color(0xFF9CA3AF),
                  ),
                  children: [
                    const TextSpan(text: 'Upload photos and use\n'),
                    TextSpan(
                      text: 'quick gestures',
                      style: const TextStyle(
                        color: Color(0xFFFBBF24),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(text: ' to keep or\ndelete them'),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AnimatedBuilder(
                animation: _bounce,
                builder: (context, _) {
                  return Transform.translate(
                    offset: Offset(0, -2 * _bounce.value),
                    child: GestureDetector(
                      onTap: () {
                        if (Get.isRegistered<NavLogic>()) {
                          Get.find<NavLogic>().setView(NavViewType.upload);
                          return;
                        }
                        Get.snackbar(
                          'Upload',
                          'Open the Upload tab to begin.',
                          backgroundColor: Colors.black.withValues(alpha: 0.75),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          margin: const EdgeInsets.all(16),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color:
                                const Color(0xFF92400E).withValues(alpha: 0.45),
                          ),
                          color: const Color(0xFF0B0B0B)
                              .withValues(alpha: 0.55),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: Color(0xFFFBBF24),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Tap Upload to begin',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFFBBF24),
                              ),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.arrow_right_alt_rounded,
                              size: 18,
                              color: Color(0xFFFBBF24),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _orb({
    required double size,
    required Color color,
    required double blur,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: blur / 6, sigmaY: blur / 6),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  static Widget _orbitIcon({
    required Alignment alignment,
    required IconData icon,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withValues(alpha: 0.22),
          border: Border.all(
            color: const Color(0xFFF59E0B).withValues(alpha: 0.28),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.18),
              blurRadius: 18,
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFFFBBF24), size: 22),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.dot = false,
    this.highlightTitle = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool dot;
  final bool highlightTitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color(0xFF92400E).withValues(alpha: 0.35),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            const Color(0xFF422006).withValues(alpha: 0.40),
            Colors.black.withValues(alpha: 0.55),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF78350F).withValues(alpha: 0.22),
            blurRadius: 30,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF422006).withValues(alpha: 0.85),
                      const Color(0xFF78350F).withValues(alpha: 0.55),
                    ],
                  ),
                  border: Border.all(
                    color: const Color(0xFF92400E).withValues(alpha: 0.40),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.22),
                      blurRadius: 26,
                    ),
                  ],
                ),
                child: Icon(icon, color: accent, size: 30),
              ),
              if (dot)
                Positioned(
                  top: -4,
                  left: -4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.50),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: highlightTitle ? accent : Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.35,
                    color: Color(0xFF9CA3AF),
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

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF59E0B), Color(0xFFB45309)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF78350F).withValues(alpha: 0.40),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFFDE68A).withValues(alpha: 0.30),
            width: 2,
          ),
        ),
        child: const Icon(Icons.person_rounded, color: Colors.white),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.child,
    required this.borderColor,
    required this.bgColor,
    this.leading,
    this.leftDot = false,
  });

  final Widget child;
  final Color borderColor;
  final Color bgColor;
  final Widget? leading;
  final bool leftDot;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leftDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Color(0xFFF59E0B),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (leading != null) ...[
            leading!,
            const SizedBox(width: 6),
          ],
          child,
        ],
      ),
    );
  }
}

class _PulseIcon extends StatefulWidget {
  const _PulseIcon({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  State<_PulseIcon> createState() => _PulseIconState();
}

class _PulseIconState extends State<_PulseIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        return Opacity(
          opacity: 0.75 + 0.25 * _c.value,
          child: Icon(widget.icon, color: widget.color, size: 20),
        );
      },
    );
  }
}
