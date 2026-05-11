import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:affie/gen_a/A.dart';
import 'dart:ui';
import 'dart:io';
import '../../theme/app_colors.dart';
import '../../data/home_data.dart';
import 'detail_logic.dart';

class DetailPage extends StatelessWidget {
  DetailPage({super.key});

  final DetailLogic logic = Get.put(DetailLogic());

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final dynamic argId = args?['id'];
    final Map<String, dynamic>? aiResult =
    args != null ? args['aiResult'] as Map<String, dynamic>? : null;

    final bool isAi = aiResult != null;

    final heroImagePath = aiResult?['imagePath'] as String?;
    final heroAsset = args?['image'] as String?;
    final String? caveId = !isAi && argId is String ? argId as String : null;
    final HomeCave? cave =
        !isAi && caveId != null ? _findCaveById(caveId) : null;
    final HomeShare? share =
        !isAi && cave == null && argId is String ? _findShareById(argId as String) : null;
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final titleColor =
    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;

    String difficultyLabel = 'Intermediate';
    final routesForDifficulty = aiResult?['routes'];
    if (routesForDifficulty is List &&
        routesForDifficulty.isNotEmpty &&
        routesForDifficulty.first is Map &&
        (routesForDifficulty.first as Map)['difficulty'] is String) {
      difficultyLabel =
      (routesForDifficulty.first as Map)['difficulty'] as String;
    }

    final String pageTitle;
    if (isAi) {
      pageTitle = 'AI Gear Check';
    } else if (cave != null) {
      pageTitle = cave.title;
    } else if (share != null) {
      pageTitle = share.title;
    } else {
      pageTitle = 'Cave detail';
    }

    return Scaffold(
      backgroundColor: AppColors.getBackground(context),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
        SliverAppBar(
        pinned: true,
        elevation: 0,
        backgroundColor: AppColors.getBackground(context),
        automaticallyImplyLeading: false,
        toolbarHeight: 60,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              InkWell(
                onTap: () => Get.back(),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_back,
                    color: titleColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  pageTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: titleColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: () {
                  _handleShare(
                    context,
                    title: pageTitle,
                    aiResult: aiResult,
                    cave: cave,
                    share: share,
                    heroImagePath: heroImagePath,
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard.withOpacity(0.9)
                        : Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.ios_share_rounded,
                    color: titleColor,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: GestureDetector(
            onTap: () =>
                _showImagePreview(
                  context,
                  heroImagePath: heroImagePath,
                  heroAsset: heroAsset,
                ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 3 / 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (heroImagePath != null &&
                        heroImagePath.isNotEmpty)
                      Image.file(
                        File(heroImagePath),
                        fit: BoxFit.cover,
                      )
                    else
                      if (heroAsset != null &&
                          heroAsset.isNotEmpty)
                        Image.asset(
                          heroAsset,
                          fit: BoxFit.cover,
                        )
                      else
                        Image.asset(
                          A.assets_affie_open,
                          fit: BoxFit.cover,
                        ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.getBackground(context),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pageTitle,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 12),
                if (isAi || cave != null)
                  Row(
                    children: [
                      _buildTag(
                        context,
                        isAi
                            ? difficultyLabel
                            : (cave?.difficulty ?? 'Intermediate'),
                      ),
                      if (!isAi && cave?.durationAndGroup != null) ...[
                        const SizedBox(width: 8),
                        _buildTag(context, cave!.durationAndGroup!),
                      ] else if (isAi) ...[
                        const SizedBox(width: 8),
                        _buildTag(context, '3 hours'),
                        const SizedBox(width: 8),
                        _buildTag(context, 'Recommended'),
                      ],
                    ],
                  ),
                const SizedBox(height: 24),
                _buildInfoCard(context, aiResult),
                const SizedBox(height: 20),
                _buildDescriptionSection(context, aiResult, cave),
                const SizedBox(height: 20),
                _buildEquipmentSection(context, aiResult, cave),
                const SizedBox(height: 20),
                _buildRouteSection(context, aiResult, cave),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),]
    ,
    )
    ,
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final color =
    isDark ? AppColors.secondaryDark.withOpacity(0.4) : AppColors.secondary;
    final textColor =
    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Future<void> _handleShare(
    BuildContext context, {
    required String title,
    required Map<String, dynamic>? aiResult,
    required HomeCave? cave,
    required HomeShare? share,
    required String? heroImagePath,
  }) async {
    final shareSummary = share == null ? null : '${share.tag} · ${share.location}';
    final description = aiResult?['description'] as String? ??
        cave?.description ??
        shareSummary ??
        '';
    final content = description.trim().isEmpty
        ? title
        : '$title\n\n$description';

    try {
      if (heroImagePath != null && heroImagePath.isNotEmpty) {
        await Share.shareXFiles(
          [XFile(heroImagePath)],
          text: content,
          subject: title,
        );
        return;
      }

      await Share.share(
        content,
        subject: title,
      );
    } catch (_) {
      Get.snackbar(
        'Share failed',
        'Unable to open share panel, please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Widget _buildInfoCard(BuildContext context, Map<String, dynamic>? aiResult) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: isDark
                ? const LinearGradient(
              colors: [AppColors.darkCard, AppColors.darkBackground],
            )
                : LinearGradient(
              colors: [
                Colors.white.withOpacity(0.96),
                Colors.white.withOpacity(0.86),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoItem(
                context,
                Icons.shield,
                (aiResult?['is_setup_safe'] == true) ? 'Safe' : 'Check',
                'Safety',
              ),
              _buildInfoItem(
                context,
                Icons.list_alt,
                (aiResult?['recommended_equipment'] is List)
                    ? (aiResult!['recommended_equipment'] as List).length
                    .toString()
                    : '0',
                'Recommends',
              ),
              _buildInfoItem(
                context,
                Icons.warning_amber_rounded,
                (aiResult?['missing_critical_items'] is List)
                    ? (aiResult!['missing_critical_items'] as List).length
                    .toString()
                    : '0',
                'Critical',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, IconData icon, String value,
      String label) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final titleColor =
    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
    final subtitleColor =
    isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Column(
      children: [
        Icon(icon,
            color: isDark ? AppColors.accent2 : AppColors.accent1, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: subtitleColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionSection(BuildContext context,
      Map<String, dynamic>? aiResult, HomeCave? cave) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final titleColor =
    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
    final bodyColor =
    isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Overview',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                aiResult?['overall_comment'] as String? ??
                    cave?.description ??
                    'AI analysis summary will appear here after you run an equipment check.',
                style: TextStyle(
                  fontSize: 15,
                  color: bodyColor,
                  height: 1.6,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEquipmentSection(BuildContext context,
      Map<String, dynamic>? aiResult, HomeCave? cave) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final titleColor =
    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
    final chipTextColor =
    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
    final borderColor = isDark ? AppColors.secondaryDark : AppColors.secondary;

    final equipment = (aiResult?['recommended_equipment'] is List)
        ? (aiResult!['recommended_equipment'] as List)
        .map<String>((e) =>
    e is Map && e['item'] is String ? e['item'] as String : e.toString())
        .toList()
        : (cave?.requiredEquipment ??
        <String>[
          'Headlamp',
          'Safety rope',
          'Protective gloves',
          'First-aid kit',
          'Radio / intercom',
          'Dry bag',
        ]);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required gear',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: equipment.map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkCard.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle,
                      color: Color(0xFFE8B4D9), size: 18),
                  const SizedBox(width: 6),
                  Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      color: chipTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRouteSection(BuildContext context,
      Map<String, dynamic>? aiResult, HomeCave? cave) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final titleColor =
    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;

    final routes = (aiResult?['routes'] is List)
        ? (aiResult!['routes'] as List)
        : const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          cave != null ? 'Experience highlights' : 'Route plan',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 12),
        if (cave != null)
          for (var i = 0; i < cave.experienceHighlights.length; i++)
            _buildRouteStep(
              context,
              i + 1,
              cave.experienceHighlights[i],
              '',
              i == 0,
            )
        else
          if (routes.isEmpty)
            _buildRouteStep(
              context,
              1,
              'Entrance check',
              'Lay out and confirm all required gear.',
              true,
            )
          else
            for (var i = 0; i < routes.length; i++)
              _buildRouteStep(
                context,
                i + 1,
                routes[i] is Map && routes[i]['name'] is String
                    ? routes[i]['name'] as String
                    : 'Route ${i + 1}',
                routes[i] is Map && routes[i]['explanation'] is String
                    ? routes[i]['explanation'] as String
                    : '',
                i == 0,
              ),
      ],
    );
  }

  Widget _buildRouteStep(BuildContext context, int step, String title,
      String desc, bool isFirst) {
    final isDark = Theme
        .of(context)
        .brightness == Brightness.dark;
    final cardColor = isDark
        ? AppColors.darkCard.withOpacity(0.9)
        : Colors.white.withOpacity(0.9);
    final titleColor =
    isDark ? AppColors.darkTextPrimary : AppColors.primaryDark;
    final subtitleColor =
    isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8B4D9), Color(0xFFF5E6F1)],
                ),
              ),
              child: Center(
                child: Text(
                  '$step',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            if (!isFirst)
              Container(
                width: 2,
                height: 40,
                color: const Color(0xFFE8B4D9).withOpacity(0.3),
              ),
          ],
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

HomeCave? _findCaveById(String id) {
  if (HomeData.featuredAdventure.id == id) {
    return HomeData.featuredAdventure;
  }

  for (final c in HomeData.popularDestinations) {
    if (c.id == id) return c;
  }

  if (HomeData.popularWide.id == id) {
    return HomeData.popularWide;
  }

  return null;
}

HomeShare? _findShareById(String id) {
  if (HomeData.explorersPick.id == id) {
    return HomeData.explorersPick;
  }
  for (final s in HomeData.communityShares) {
    if (s.id == id) return s;
  }
  return null;
}

void _showImagePreview(BuildContext context, {
  String? heroImagePath,
  String? heroAsset,
}) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.9),
    builder: (ctx) {
      Widget image;
      if (heroImagePath != null && heroImagePath.isNotEmpty) {
        image = Image.file(File(heroImagePath), fit: BoxFit.contain);
      } else if (heroAsset != null && heroAsset.isNotEmpty) {
        image = Image.asset(heroAsset, fit: BoxFit.contain);
      } else {
        image = Image.asset(A.assets_affie_open, fit: BoxFit.contain);
      }

      return GestureDetector(
        onTap: () => Navigator.of(ctx).pop(),
        child: Container(
          color: Colors.transparent,
          child: Center(
            child: InteractiveViewer(
              child: image,
            ),
          ),
        ),
      );
    },
  );
}
