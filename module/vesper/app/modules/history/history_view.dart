import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/data/cheer_history_store.dart';
import 'package:vesper/vesper/app/routes/app_routes.dart';
import 'package:vesper/vesper/app/widgets/app_background.dart';

import 'history_logic.dart';

class HistoryPage extends StatelessWidget {
  HistoryPage({Key? key}) : super(key: key);

  final HistoryLogic logic = Get.put(HistoryLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        useImageBackground: true,
        safeArea: false,
        padding: EdgeInsets.zero,
        child: GetBuilder<CheerHistoryStore>(
          init: Get.isRegistered<CheerHistoryStore>()
              ? Get.find<CheerHistoryStore>()
              : Get.put(CheerHistoryStore(), permanent: true),
          builder: (store) {
            return SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Move Library',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2B1A2B),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            if (store.items.isEmpty) return;
                            final confirmed = await Get.dialog<bool>(
                                  AlertDialog(
                                    title: const Text('Clear History'),
                                    content: const Text(
                                      'Delete all analysis records and photos?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Get.back(result: true),
                                        child: const Text(
                                          'Delete',
                                          style: TextStyle(
                                            color: Color(0xFFFF4FA5),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  barrierDismissible: false,
                                ) ??
                                false;
                            if (!confirmed) return;
                            await store.clearAll();
                          },
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: Color(0xFF2B1A2B),
                          ),
                          tooltip: 'Clear history',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    (() {
                      final visible = store.items
                          .where((e) => File(e.imagePath).existsSync())
                          .toList();
                      return visible.isEmpty
                          ? _emptyState()
                          : Column(
                              children: visible
                                  .map((item) => _historyCard(item, store))
                                  .toList(),
                            );
                    })(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _historyCard(CheerHistoryItem item, CheerHistoryStore store) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.details, arguments: item);
      },
      onLongPress: () async {
        final confirmed = await Get.dialog<bool>(
              AlertDialog(
                title: const Text('Delete This Record'),
                content: const Text(
                  'This will remove the analysis and the uploaded photo.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Get.back(result: false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Get.back(result: true),
                    child: const Text(
                      'Delete',
                      style: TextStyle(color: Color(0xFFFF4FA5)),
                    ),
                  ),
                ],
              ),
              barrierDismissible: false,
            ) ??
            false;
        if (!confirmed) return;
        await store.removeItem(item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFF8AC4), Color(0xFFFF5BAA)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(22),
              ),
              child: Image.file(
                File(item.imagePath),
                height: 320,
                width: double.infinity,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Analysis Result',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Score: ${item.result.score}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'Tap to view details',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
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

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE8EE),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFB60B63).withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.7),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 98,
            height: 98,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [
                  Color(0xFFFF9BD0),
                  Color(0xFFFF62AF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 66,
                height: 66,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.15),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 34,
                  color: Color(0xFFFF2F8B),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Build Your Training\nHistory First',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF2B1A2B),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Complete your first training session to\nunlock personalized move\nrecommendations and track your progress!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Color(0xFF6E5B6F),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: Colors.white.withOpacity(0.35),
                width: 1,
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 14,
                  color: Color(0xFFFF2F8B),
                ),
                SizedBox(width: 6),
                Text(
                  'Get AI-powered insights after training',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2B1A2B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFFFF5AA9),
                    Color(0xFFFF3A92),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF3A92).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: TextButton(
                onPressed: () {
                  logic.onStartTraining();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text(
                  'Start Training Now  →',
                  style: TextStyle(
                    fontSize: 15,
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
}
