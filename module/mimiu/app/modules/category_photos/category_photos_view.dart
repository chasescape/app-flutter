import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mimiu/mimiu/app/modules/home/home_logic.dart';
import 'package:mimiu/mimiu/app/widgets/page_header.dart';
import 'package:mimiu/mimiu/app/widgets/symmetric_gradient_background.dart';
import 'package:share_plus/share_plus.dart';

import 'category_photos_logic.dart';

class CategoryPhotosPage extends StatelessWidget {
  const CategoryPhotosPage({super.key});

  CategoryPhotosLogic get logic => Get.put(CategoryPhotosLogic());

  @override
  Widget build(BuildContext context) {
    logic;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          const Positioned.fill(child: SymmetricGradientBackground()),
          SafeArea(
            child: Column(
              children: [
                Obx(() {
                  return PageHeader(
                    title: logic.title.value.isEmpty
                        ? 'Album'
                        : logic.title.value,
                    titleSize: 22,
                    titleWeight: FontWeight.w800,
                    useGradientTitle: false,
                    showBack: true,
                    centerTitle: true,
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (logic.selectionMode.value)
                          IconButton(
                            onPressed: () async {
                              final ok = await Get.dialog<bool>(
                                    AlertDialog(
                                      title: const Text('Delete selected?'),
                                      content: const Text(
                                        'This removes the selected photos from this album on this device.',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Get.back(result: false),
                                          child: const Text('Cancel'),
                                        ),
                                        ElevatedButton(
                                          onPressed: () =>
                                              Get.back(result: true),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF7F1D1D),
                                            foregroundColor:
                                                const Color(0xFFFEE2E2),
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ) ??
                                  false;
                              if (!ok) return;
                              await logic.deleteSelected();
                              if (Get.isRegistered<HomeLogic>()) {
                                await Get.find<HomeLogic>().refreshFromStorage();
                              }
                            },
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: const Color(0xFFFBBF24),
                            tooltip: 'Delete',
                          ),
                        if (logic.selectionMode.value)
                          IconButton(
                            onPressed: logic.clearSelection,
                            icon: const Icon(Icons.close_rounded),
                            color: const Color(0xFFFDE68A),
                            tooltip: 'Cancel',
                          ),
                      ],
                    ),
                  );
                }),
                Expanded(
                  child: Obx(() {
                    final items = logic.photos.toList();
                    final selectionMode = logic.selectionMode.value;
                    // Force reactive tracking for selection changes.
                    final selectedSet = logic.selected.toSet();
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'No photos in this category yet.',
                          style: TextStyle(
                            color: Color(0xFF9CA3AF),
                            fontSize: 13,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: [
                        if (logic.showMultiSelectTip.value)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.black.withValues(alpha: 0.45),
                                border: Border.all(
                                  color: const Color(0xFF92400E)
                                      .withValues(alpha: 0.25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    color: Color(0xFFFBBF24),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Text(
                                      'Tip: Long-press a photo to select multiple and delete.',
                                      style: TextStyle(
                                        color: Color(0xFFFDE68A),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        height: 1.2,
                                        decoration: TextDecoration.none,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: logic.dismissTip,
                                    icon: const Icon(Icons.close_rounded),
                                    color: const Color(0xFFFDE68A),
                                    iconSize: 18,
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 36,
                                      minHeight: 36,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 6,
                              mainAxisSpacing: 6,
                            ),
                            itemCount: items.length,
                            itemBuilder: (context, index) {
                              final p = items[index];
                              return _Thumb(
                                path: p.path,
                                heroTag: 'photo_${p.path}',
                                selected: selectedSet.contains(p.path),
                                selectionMode: selectionMode,
                                onTap: () {
                                  if (selectionMode) {
                                    logic.toggleSelect(p.path);
                                    return;
                                  }
                                  Get.to(
                                    () => _PhotoViewer(
                                      paths: items.map((e) => e.path).toList(),
                                      initialIndex: index,
                                      title: logic.title.value,
                                    ),
                                  );
                                },
                                onLongPress: () {
                                  if (!selectionMode) {
                                    logic.enterSelection(p.path);
                                  } else {
                                    logic.toggleSelect(p.path);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({
    required this.path,
    required this.heroTag,
    required this.onTap,
    required this.onLongPress,
    required this.selectionMode,
    required this.selected,
  });

  final String path;
  final String heroTag;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final bool selectionMode;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(10);
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOut,
        scale: selectionMode && selected ? 0.98 : 1.0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: radius,
            boxShadow: selectionMode && selected
                ? [
                    BoxShadow(
                      color: const Color(0xFFFBBF24).withValues(alpha: 0.28),
                      blurRadius: 26,
                      spreadRadius: 1,
                    ),
                  ]
                : const [],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: Hero(
              tag: heroTag,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.black.withValues(alpha: 0.35),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.broken_image_outlined,
                        color: Color(0xFFFBBF24),
                        size: 18,
                      ),
                    ),
                  ),
                  if (selectionMode)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 140),
                      decoration: BoxDecoration(
                        borderRadius: radius,
                        color: Colors.black.withValues(
                          alpha: selected ? 0.08 : 0.42,
                        ),
                        border: Border.all(
                          color: selected
                              ? const Color(0xFFFBBF24).withValues(alpha: 0.95)
                              : Colors.white.withValues(alpha: 0.06),
                          width: selected ? 2.5 : 1.2,
                        ),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: const Color(0xFFFBBF24)
                                      .withValues(alpha: 0.22),
                                  blurRadius: 18,
                                  spreadRadius: 1,
                                ),
                              ]
                            : const [],
                      ),
                    ),
                  if (selectionMode)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 140),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFFFBBF24).withValues(alpha: 0.98)
                              : Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selected
                                ? const Color(0xFFFFF7ED)
                                    .withValues(alpha: 0.70)
                                : const Color(0xFF92400E)
                                    .withValues(alpha: 0.28),
                            width: selected ? 1.5 : 1,
                          ),
                          boxShadow: selected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFFFBBF24)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 14,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : const [],
                        ),
                        child: Icon(
                          selected ? Icons.check_rounded : Icons.circle_outlined,
                          color:
                              selected ? Colors.black : const Color(0xFFFDE68A),
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer({
    required this.paths,
    required this.initialIndex,
    required this.title,
  });

  final List<String> paths;
  final int initialIndex;
  final String title;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  late final PageController _page = PageController(initialPage: widget.initialIndex);
  late int _index = widget.initialIndex;

  String get _currentPath => widget.paths[_index];

  Future<void> _share({required bool saveMode}) async {
    final p = _currentPath;
    final file = XFile(p);
    final name = widget.title.isEmpty ? 'Photo' : widget.title;
    await Share.shareXFiles(
      [file],
      subject: name,
      text: 'Shared from Mimiu.',
    );
  }

  Future<void> _openActions() async {
    await _share(saveMode: false);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            PageView.builder(
              controller: _page,
              itemCount: widget.paths.length,
              onPageChanged: (i) => setState(() => _index = i),
              itemBuilder: (context, i) {
                final path = widget.paths[i];
                return Center(
                  child: Hero(
                    tag: 'photo_$path',
                    child: InteractiveViewer(
                      minScale: 1,
                      maxScale: 4,
                      child: Image.file(
                        File(path),
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ),
                );
              },
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.80),
                      Colors.black.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios_new_rounded),
                      color: const Color(0xFFFBBF24),
                      iconSize: 18,
                    ),
                    Expanded(
                      child: Text(
                        widget.title.isEmpty ? 'Photo' : widget.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: _openActions,
                      icon: const Icon(Icons.more_horiz_rounded),
                      color: const Color(0xFFFDE68A),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 18,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF92400E).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Text(
                    '${_index + 1} / ${widget.paths.length}',
                    style: const TextStyle(
                      color: Color(0xFFFDE68A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
