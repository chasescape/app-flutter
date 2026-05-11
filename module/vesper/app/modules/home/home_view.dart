import 'package:flutter/material.dart';
import 'dart:io';

import 'package:get/get.dart';
import 'package:vesper/gen_a/A.dart';
import 'package:vesper/vesper/app/data/cheer_history_store.dart';
import 'package:vesper/vesper/app/routes/app_routes.dart';

import 'home_logic.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final HomeLogic logic = Get.put(HomeLogic());
  static const Color ink = Color(0xFF2B1A2B);
  static const Color inkMuted = Color(0xFF6E5B6F);
  static const Color blush = Color(0xFFFFE8EE);
  static const Color blushDeep = Color(0xFFF6D1DE);
  static const Color berry = Color(0xFFFF2F8B);
  static const Color berryDark = Color(0xFFB60B63);
  static const Color mint = Color(0xFFBFEFE6);
  static const Color softPink = Color(0xFFFF8AC4);
  static const Color mistPink = Color(0xFFFFB6D8);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(A.assets_vesper_bg),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.10),
                      Colors.white.withValues(alpha: 0.02),
                      Colors.white.withValues(alpha: 0.18),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              left: -50,
              child: _blurBlob(
                color: blushDeep.withValues(alpha: 0.35),
                size: 200,
              ),
            ),
            Positioned(
              bottom: 220,
              right: -40,
              child: _blurBlob(
                color: berry.withValues(alpha: 0.22),
                size: 220,
              ),
            ),
            Positioned(
              top: 360,
              right: 24,
              child: _blurBlob(
                color: Colors.white.withValues(alpha: 0.18),
                size: 140,
              ),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 顶部标题
                      const Text(
                        'Welcome to Vesper',
                        style: TextStyle(
                          fontSize: 16,
                          color: inkMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Start Your Journey',
                        style: TextStyle(
                          fontSize: 32,
                          color: ink,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // 主卡片
                      _buildMainCard(),

                      const SizedBox(height: 32),

                      // Explore 区域
                      _buildExploreSection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: blush.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.7),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: berryDark.withValues(alpha: 0.2),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // 图标区域
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.9),
              boxShadow: [
                BoxShadow(
                  color: berryDark.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.upload_rounded,
              size: 48,
              color: berry,
            ),
          ),

          const SizedBox(height: 24),

          // 标题
          const Text(
            'Ready to Start Your\nCheer Journey?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: ink,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 16),

          // 描述
          const Text(
            'Upload your first practice photo and get instant\nAI-powered feedback to improve your moves!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: inkMuted,
              height: 1.5,
            ),
          ),

          const SizedBox(height: 12),

          // 金币提示
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.stars_rounded,
                size: 18,
                color: Color(0xFFFFC857),
              ),
              SizedBox(width: 6),
              Text(
                'Start with 100 free coins',
                style: TextStyle(
                  fontSize: 13,
                  color: inkMuted,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 按钮
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFF5AA9), Color(0xFFFF3A92)],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFFF3A92).withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  logic.onStartTraining();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Start Training Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExploreSection() {
    return GetBuilder<CheerHistoryStore>(
      init: Get.isRegistered<CheerHistoryStore>()
          ? Get.find<CheerHistoryStore>()
          : Get.put(CheerHistoryStore(), permanent: true),
      builder: (store) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Training History',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    logic.onViewAll();
                  },
                  child: const Text(
                    'View All >',
                    style: TextStyle(
                      fontSize: 14,
                      color: berryDark,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            (() {
              final visible = store.items
                  .where((e) => File(e.imagePath).existsSync())
                  .toList();
              return visible.isEmpty
                  ? _emptyHistoryCard()
                  : SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: visible.length,
                        itemBuilder: (context, index) {
                          return _buildHistoryCard(visible[index]);
                        },
                      ),
                    );
            })(),
          ],
        );
      },
    );
  }

  Widget _buildMoveCard(int index) {
    final moves = [
      {'title': 'Toe Touch Jump', 'category': 'Jump', 'level': 'Intermediate'},
      {'title': 'Pike Jump', 'category': 'Jump', 'level': 'Intermediate'},
      {'title': 'High V', 'category': 'Arm Motion', 'level': 'Beginner'},
    ];

    final move = moves[index];

    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: berryDark.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: blushDeep,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.image,
                      size: 48,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: mint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        move['level']!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: ink,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 文字信息
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  move['title']!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: ink,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  move['category']!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: inkMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _blurBlob({required Color color, required double size}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _emptyHistoryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            softPink.withOpacity(0.35),
            mistPink.withOpacity(0.28),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.35), width: 1),
      ),
      child: Column(
        children: const [
          Icon(Icons.photo_library_rounded, color: ink, size: 28),
          SizedBox(height: 8),
          Text(
            'No training history yet',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: ink,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Complete your first analysis to see it here.',
            style: TextStyle(
              fontSize: 12,
              color: inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(CheerHistoryItem item) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.details, arguments: item);
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.92),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.white.withOpacity(0.8),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: berryDark.withOpacity(0.12),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.file(
                  File(item.imagePath),
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analysis Result',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Score: ${item.result.score}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: inkMuted,
                    ),
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
