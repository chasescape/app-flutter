import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../routes/app_routes.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/rova_background.dart';
import '../home/home_logic.dart';
import '../nav/nav_logic.dart';
import 'history_logic.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final HistoryLogic logic = Get.find<HistoryLogic>();
    final HomeLogic homeLogic = Get.find<HomeLogic>();
    const Color pink = Color(0xFFE84B7B);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RovaBackground(
        blurSigma: 4,
        overlayColor: const Color(0x22FFFFFF),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x33FFE7EF),
            Color(0x22FFFFFF),
          ],
        ),
        child: SafeArea(
          child: Obx(() {
            final items = homeLogic.generatedImages;
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 40),
              children: [
                SizedBox(
                  height: 44,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          tooltip: 'Back',
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.arrow_back_ios_new_rounded),
                        ),
                      ),
                      const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'History',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: items.isEmpty
                              ? null
                              : () async {
                                  await homeLogic.clearGeneratedImages();
                                  Get.snackbar(
                                    'Cleared',
                                    'History removed.',
                                    snackPosition: SnackPosition.BOTTOM,
                                  );
                                },
                          child: const Text('Clear'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                if (items.isEmpty)
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(26),
                          child: Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: const Color(0x66FFFFFF),
                              borderRadius: BorderRadius.circular(26),
                              border:
                                  Border.all(color: const Color(0x66FFFFFF)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.10),
                                  blurRadius: 22,
                                  offset: const Offset(0, 14),
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'No history yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Generate a manicure on the Generate tab, then save it to see it here.',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        height: 1.2,
                                        color: Colors.black
                                            .withValues(alpha: 0.65),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(999),
                                          gradient: const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Color(0xFFFF4FA1),
                                              Color(0xFFE84B7B),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: pink.withValues(
                                                  alpha: 0.28),
                                              blurRadius: 18,
                                              offset: const Offset(0, 10),
                                            ),
                                          ],
                                        ),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            foregroundColor: Colors.white,
                                            shape: const StadiumBorder(),
                                            elevation: 0,
                                          ),
                                          onPressed: () {
                                            try {
                                              final navLogic =
                                                  Get.find<NavLogic>();
                                              navLogic.setTab(1);
                                              Get.back();
                                            } catch (_) {
                                              Get.offAllNamed(AppRoutes.nav);
                                            }
                                          },
                                          child: const Text(
                                            'Go to Generate',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                else ...[
                  const SizedBox(height: 10),
                  ...items.asMap().entries.map((entry) {
                    final item = entry.value;
                    final value = item.pathOrUrl;
                    final isFile = logic.isFilePath(value);
                    final dateLabel =
                        '${item.createdAt.year.toString().padLeft(4, '0')}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: ValueKey('${item.pathOrUrl}-${item.createdAtMs}'),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                Color(0xFFFF7A9A),
                                Color(0xFFE84B7B),
                              ],
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                        onDismissed: (_) async {
                          await homeLogic.removeGeneratedImage(item.pathOrUrl);
                          Get.snackbar(
                            'Deleted',
                            'History item removed.',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () {
                              Get.toNamed(
                                AppRoutes.details,
                                arguments: {
                                  'generatedImagePath': item.pathOrUrl,
                                  'outfitImagePath': null,
                                  'aiCopy': item.aiCopy,
                                  'outfitNotes': '',
                                  'preferredColors': '',
                                  'preferredStyle': '',
                                  'preferredElements': '',
                                  'customPrompt': '',
                                },
                              );
                            },
                            child: GlassCard(
                              borderRadius: 18,
                              blurSigma: 14,
                              backgroundColor: const Color(0xD9FFFFFF),
                              borderColor: const Color(0x44FFFFFF),
                              highlight: false,
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Container(
                                      width: 92,
                                      height: 92,
                                      color: const Color(0xFFFFE7EF),
                                      child: isFile
                                          ? Image.file(
                                              File(value),
                                              fit: BoxFit.cover,
                                            )
                                          : (value.startsWith('http://') ||
                                                  value.startsWith('https://'))
                                              ? Image.network(
                                                  value,
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (_, __, ___) => Icon(
                                                    Icons
                                                        .auto_awesome_rounded,
                                                    color: pink.withValues(
                                                        alpha: 0.9),
                                                    size: 30,
                                                  ),
                                                )
                                              : Icon(
                                                  Icons.auto_awesome_rounded,
                                                  color: pink.withValues(
                                                      alpha: 0.9),
                                                  size: 30,
                                                ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          dateLabel,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w900,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          item.aiCopy.trim().isEmpty
                                              ? 'No description yet.'
                                              : item.aiCopy.trim(),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            height: 1.2,
                                            color: Colors.black
                                                .withValues(alpha: 0.65),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            );
          }),
        ),
      ),
    );
  }
}
