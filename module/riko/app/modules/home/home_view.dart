import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math';

import 'package:get/get.dart';
import 'package:riko/gen_a/A.dart';
import 'package:riko/riko/app/routes/app_routes.dart';
import 'package:riko/riko/app/services/advice_store.dart';
import 'package:riko/riko/app/services/coin_store.dart';
import 'package:riko/riko/app/widgets/diffuse_background.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedTab = 'wardrobe';
  late final List<_Outfit> _trendingItems;

  final List<_Outfit> _wardrobeItems = const [
  ];
  final List<String> _trendingImagePool = [
    A.assets_riko_1,
    A.assets_riko_2,
    A.assets_riko_3,
    A.assets_riko_4,
    A.assets_riko_5,
    A.assets_riko_6,
    A.assets_riko_7,
    A.assets_riko_8,
    A.assets_riko_9,
    A.assets_riko_10,
    A.assets_riko_11,
  ];

  @override
  void initState() {
    super.initState();
    final shuffled = List<String>.from(_trendingImagePool)
      ..shuffle(Random());
    final images = shuffled.take(4).toList();
    _trendingItems = [
      _Outfit(
        title: 'Soft Pink Blouse',
        category: 'Tops',
        tags: ['romantic', 'office'],
        imageAsset: images[0],
      ),
      _Outfit(
        title: 'Cream Knit Dress',
        category: 'Dresses',
        tags: ['date', 'soft'],
        imageAsset: images[1],
      ),
      _Outfit(
        title: 'Light Denim Jacket',
        category: 'Outerwear',
        tags: ['casual', 'layer'],
        imageAsset: images[2],
      ),
      _Outfit(
        title: 'Minimal White Set',
        category: 'Sets',
        tags: ['clean', 'modern'],
        imageAsset: images[3],
      ),
    ];
  }

  void _goToChat() {
    Get.toNamed(
      AppRoutes.nav,
      arguments: const {'initialIndex': 1},
      preventDuplicates: false,
    );
  }

  void _onSelectTab(String value) {
    setState(() => _selectedTab = value);
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AdvicePayload>>(
      valueListenable: AdviceStore.history,
      builder: (context, adviceHistory, _) {
        // 只保留图片文件存在的建议
        final validAdviceImages = adviceHistory
            .map((item) => item.imagePath)
            .whereType<String>()
            .where((path) => path.isNotEmpty && File(path).existsSync())
            .toList();
        
        final hasImageAdvice = validAdviceImages.isNotEmpty;
        
        // 过滤出有效的建议（图片存在）
        final validAdviceHistory = adviceHistory
            .where((advice) => 
                advice.imagePath == null || 
                advice.imagePath!.isEmpty || 
                File(advice.imagePath!).existsSync())
            .toList();
        
        final todaysAdvice = _firstAdviceToday(validAdviceHistory);

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: DiffuseBackground(
            child: SafeArea(
              child: !hasImageAdvice
                  ? Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: _Header(
                            onCreditsTap: () => Get.toNamed(AppRoutes.coins),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Expanded(
                          child: _EmptyWardrobeState(
                            onChat: _goToChat,
                          ),
                        ),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      children: [
                        _Header(
                          onCreditsTap: () => Get.toNamed(AppRoutes.coins),
                        ),
                        const SizedBox(height: 20),
                        _AskRikoCard(
                          onChat: _goToChat,
                        ),
                        const SizedBox(height: 18),
                        _TodaysPickCard(
                          advice: todaysAdvice,
                          imagePaths: validAdviceImages,
                        ),
                        const SizedBox(height: 18),
                        _TabSwitcher(
                          selected: _selectedTab,
                          onSelect: _onSelectTab,
                          wardrobeCount: _wardrobeItems.length,
                        ),
                        const SizedBox(height: 12),
                        if (_selectedTab == 'wardrobe')
                          _OutfitGrid(
                            items: _wardrobeItems,
                            adviceHistory: validAdviceHistory,
                            variant: _OutfitGridVariant.defaultStyle,
                          )
                        else
                          _OutfitGrid(
                            items: _trendingItems,
                            adviceHistory: const <AdvicePayload>[],
                            variant: _OutfitGridVariant.trendingStyle,
                          ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onCreditsTap;

  const _Header({required this.onCreditsTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Riko',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2B2B2B),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          'AI Fashion Stylist',
          style: TextStyle(
            fontSize: 13,
            color: Color(0xFF7A7A7A),
          ),
        ),
        const Spacer(),
        InkWell(
          onTap: onCreditsTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3F6),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color(0xFFF3C6D6)),
            ),
            child: ValueListenableBuilder<int>(
              valueListenable: CoinStore.balance,
              builder: (context, balance, _) {
                return Row(
                  children: [
                    const Icon(Icons.monetization_on,
                        size: 16, color: Color(0xFFEE7FA0)),
                    const SizedBox(width: 6),
                    Text(
                      balance.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEE7FA0),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _AskRikoCard extends StatelessWidget {
  final VoidCallback onChat;

  const _AskRikoCard({required this.onChat});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: onChat,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF8A7A), Color(0xFFFF5F8F)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                Icon(Icons.style, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Ask Riko',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'What should I wear today?',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _AskAction(
                      icon: Icons.photo_camera_outlined,
                      label: 'Take photo',
                      onTap: onChat,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _AskAction(
                      icon: Icons.upload_file,
                      label: 'Upload',
                      onTap: onChat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Ask ideas:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  _IdeaChip(text: 'What shoes match this?', onTap: onChat),
                  _IdeaChip(text: 'Date outfit ideas', onTap: onChat),
                  _IdeaChip(text: 'Make me look slimmer', onTap: onChat),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AskAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AskAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdeaChip extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _IdeaChip({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}

class _TodaysPickCard extends StatelessWidget {
  final AdvicePayload? advice;
  final List<String> imagePaths;

  const _TodaysPickCard({this.advice, this.imagePaths = const []});

  @override
  Widget build(BuildContext context) {
    final hasAdvice = advice != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.today, color: Color(0xFFFF5F8F)),
              SizedBox(width: 6),
              Text(
                "Today's Pick from Your Closet",
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              Spacer(),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 480,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFFDE2EA), Color(0xFFEAE3F7)],
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: imagePaths.isEmpty
                  ? (hasAdvice && advice!.imagePath != null
                      ? Image.file(
                          File(advice!.imagePath!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : const Center(
                          child: Text('Outfit Preview'),
                        ))
                  : PageView.builder(
                      controller: PageController(
                        initialPage: imagePaths.length * 1000,
                      ),
                      itemBuilder: (context, index) {
                        final path = imagePaths[index % imagePaths.length];
                        return Image.file(
                          File(path),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            hasAdvice ? 'Style Advice' : 'Professional Style Inspiration',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            hasAdvice
                ? _advicePreview(advice!.content)
                : 'Build your wardrobe to get personalized daily picks.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Color(0xFF7A7A7A)),
          ),
        ],
      ),
    );
  }
}

class _TabSwitcher extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  final int wardrobeCount;

  const _TabSwitcher({
    required this.selected,
    required this.onSelect,
    required this.wardrobeCount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _TabButton(
            label: 'My Closet',
            active: selected == 'wardrobe',
            onTap: () => onSelect('wardrobe'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _TabButton(
            label: 'Trending Looks',
            active: selected == 'trending',
            onTap: () => onSelect('trending'),
          ),
        ),
      ],
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _TabButton(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: active
              ? const LinearGradient(
                  colors: [Color(0xFFFF8A7A), Color(0xFFFF5F8F)],
                )
              : null,
          color: active ? null : Colors.white,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF6E6E6E),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

enum _OutfitGridVariant { defaultStyle, trendingStyle }

class _OutfitGrid extends StatelessWidget {
  final List<_Outfit> items;
  final List<AdvicePayload> adviceHistory;
  final _OutfitGridVariant variant;

  const _OutfitGrid({
    required this.items,
    this.adviceHistory = const <AdvicePayload>[],
    this.variant = _OutfitGridVariant.defaultStyle,
  });

  @override
  Widget build(BuildContext context) {
    final entries = <_OutfitGridEntry>[
      // 只添加有图片且图片文件存在的建议
      ...adviceHistory
          .where((advice) => 
              advice.imagePath != null && 
              advice.imagePath!.isNotEmpty &&
              File(advice.imagePath!).existsSync())
          .map(_OutfitGridEntry.advice),
      ...items.map(_OutfitGridEntry.outfit),
    ];

    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Text('No items yet.', style: TextStyle(fontSize: 14)),
        ),
      );
    }

    return GridView.builder(
      itemCount: entries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemBuilder: (context, index) {
        final entry = entries[index];
        final isTrendingStyle = variant == _OutfitGridVariant.trendingStyle;
        return _OutfitGridCard(
          entry: entry,
          isTrendingStyle: isTrendingStyle,
        );
      },
    );
  }
}

class _OutfitGridEntry {
  final _Outfit? outfit;
  final AdvicePayload? advice;

  const _OutfitGridEntry._({this.outfit, this.advice});

  factory _OutfitGridEntry.outfit(_Outfit outfit) =>
      _OutfitGridEntry._(outfit: outfit);

  factory _OutfitGridEntry.advice(AdvicePayload advice) =>
      _OutfitGridEntry._(advice: advice);
}

class _OutfitGridCard extends StatelessWidget {
  final _OutfitGridEntry entry;
  final bool isTrendingStyle;

  const _OutfitGridCard({
    required this.entry,
    required this.isTrendingStyle,
  });

  @override
  Widget build(BuildContext context) {
    final outfit = entry.outfit;
    final advice = entry.advice;
    final isAdvice = advice != null;
    final preview = isAdvice ? _advicePreview(advice!.content) : null;

    return InkWell(
      onTap: isAdvice
          ? () => Get.toNamed(
                AppRoutes.details,
                arguments: {
                  'id': advice!.createdAt.millisecondsSinceEpoch.toString(),
                  'content': advice.content,
                  'imagePath': advice.imagePath,
                },
              )
          : null,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isTrendingStyle ? 0.03 : 0.04),
              blurRadius: isTrendingStyle ? 10 : 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: isTrendingStyle ? const Color(0xFFF5EDF2) : null,
                  gradient: isTrendingStyle
                      ? null
                      : const LinearGradient(
                          colors: [Color(0xFFF9E9F2), Color(0xFFEDE7F8)],
                        ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: advice?.imagePath != null
                      ? Image.file(
                          File(advice!.imagePath!),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : outfit?.imageAsset != null
                          ? Image.asset(
                              outfit!.imageAsset!,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : const Center(
                              child: Icon(
                                Icons.checkroom_rounded,
                                color: Color(0xFFEE7FA0),
                              ),
                            ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isAdvice ? 'Style Advice' : outfit!.title,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              isAdvice ? (preview ?? '') : outfit!.category,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8A8A8A)),
            ),
          ],
        ),
      ),
    );
  }
}

String _advicePreview(String text) {
  final trimmed = text.replaceAll('\n', ' ').trim();
  return trimmed.length > 48 ? trimmed.substring(0, 48) : trimmed;
}

AdvicePayload? _firstAdviceToday(List<AdvicePayload> adviceHistory) {
  if (adviceHistory.isEmpty) {
    return null;
  }
  final now = DateTime.now();
  final today =
      DateTime(now.year, now.month, now.day);
  final todays = adviceHistory
      .where((advice) {
        final created = advice.createdAt;
        final createdDay =
            DateTime(created.year, created.month, created.day);
        return createdDay == today;
      })
      .toList();
  if (todays.isEmpty) {
    return null;
  }
  return todays.last;
}

class _EmptyWardrobeState extends StatelessWidget {
  final VoidCallback onChat;

  const _EmptyWardrobeState({required this.onChat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _EmptyIllustration(),
            const SizedBox(height: 24),
            const Text(
              'Your Closet is Empty',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2B2B2B),
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Start by chatting with Riko! Upload photos of your clothes or ask for styling advice with images, and I\'ll help build your digital wardrobe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF7A7A7A), height: 1.5),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onChat,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEE7FA0),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 26, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 4,
              ),
              child: const Text('Chat with Riko'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyIllustration extends StatelessWidget {
  const _EmptyIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            child: Container(
              width: 52,
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF7FA0), width: 2),
                color: Colors.transparent,
              ),
            ),
          ),
          Positioned(
            right: 12,
            child: Container(
              width: 52,
              height: 78,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFF7FA0), width: 2),
                color: Colors.transparent,
              ),
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE3EB),
            ),
            child: const Center(
              child: Text(
                '?',
                style: TextStyle(
                  color: Color(0xFFFF5F8F),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const Positioned(
            top: 6,
            left: 24,
            child: Icon(Icons.style, size: 12, color: Color(0xFFFF7FA0)),
          ),
          const Positioned(
            bottom: 10,
            right: 20,
            child: Icon(Icons.style, size: 12, color: Color(0xFFFF7FA0)),
          ),
        ],
      ),
    );
  }
}

class _Outfit {
  final String title;
  final String category;
  final List<String> tags;
  final String? imageAsset;

  const _Outfit(
      {required this.title,
      required this.category,
      required this.tags,
      this.imageAsset});
}

class _LatestAdviceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<AdvicePayload>>(
      valueListenable: AdviceStore.history,
      builder: (context, adviceHistory, _) {
        final advice = _firstAdviceToday(adviceHistory);
        if (advice == null) {
          return const SizedBox.shrink();
        }
        final preview = advice.content.replaceAll('\n', ' ').trim();
        final text = preview.length > 140 ? preview.substring(0, 140) : preview;
        return InkWell(
          onTap: () => Get.toNamed(
            AppRoutes.nav,
            arguments: const {'initialIndex': 1},
          ),
          borderRadius: BorderRadius.circular(22),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (advice.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 4 / 3,
                      child: Image.file(
                        File(advice.imagePath!),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 160,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEEF4),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.style,
                      color: Color(0xFFEE7FA0),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(
                  text,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF7A7A7A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
