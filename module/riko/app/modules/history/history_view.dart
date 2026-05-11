import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:riko/riko/app/routes/app_routes.dart';
import 'package:riko/riko/app/services/advice_store.dart';
import 'package:riko/riko/app/widgets/diffuse_background.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool _selectionMode = false;
  final Set<String> _selected = <String>{};

  void _toggleSelection(String id) {
    setState(() {
      if (_selected.contains(id)) {
        _selected.remove(id);
        if (_selected.isEmpty) {
          _selectionMode = false;
        }
      } else {
        _selected.add(id);
        _selectionMode = true;
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectionMode = false;
      _selected.clear();
    });
  }

  void _deleteSelected() {
    AdviceStore.removeMany(_selected);
    _clearSelection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(_selectionMode
            ? 'Selected ${_selected.length}'
            : 'Chat History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_selectionMode)
            IconButton(
              onPressed: _deleteSelected,
              icon: const Icon(Icons.delete_outline),
            )
          else
            IconButton(
              onPressed: () {
                if (AdviceStore.history.value.isNotEmpty) {
                  AdviceStore.clearAll();
                }
              },
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: 'Clear All',
            ),
        ],
      ),
      body: DiffuseBackground(
        child: SafeArea(
          child: ValueListenableBuilder<List<AdvicePayload>>(
            valueListenable: AdviceStore.history,
            builder: (context, history, _) {
              if (history.isEmpty) {
                return const Center(
                  child: Text(
                    'No chat history yet.',
                    style: TextStyle(color: Color(0xFF8A8A8A)),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];
                  final id =
                      item.createdAt.millisecondsSinceEpoch.toString();
                  final isSelected = _selected.contains(id);
                  return Dismissible(
                    key: ValueKey<String>(id),
                    direction: DismissDirection.endToStart,
                    onDismissed: (_) => AdviceStore.removeById(id),
                    background: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Color(0xFFFF4D4F)),
                    ),
                    secondaryBackground: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE4E4),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Color(0xFFFF4D4F)),
                    ),
                    child: _HistoryItem(
                      title: _titleFromContent(item.content),
                      subtitle: _formatDate(item.createdAt),
                      imagePath: item.imagePath,
                      selected: isSelected,
                      onTap: () {
                        if (_selectionMode) {
                          _toggleSelection(id);
                        } else {
                          Get.toNamed(AppRoutes.details, arguments: item);
                        }
                      },
                      onLongPress: () => _toggleSelection(id),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? imagePath;
  final bool selected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.selected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF1F6) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? const Color(0xFFEE7FA0) : Colors.transparent,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HistoryThumb(imagePath: imagePath),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEEF4),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFFEE7FA0),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.chevron_right_rounded,
                        color: selected
                            ? const Color(0xFFEE7FA0)
                            : Color(0xFFB0B0B0),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
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

class _HistoryThumb extends StatelessWidget {
  final String? imagePath;

  const _HistoryThumb({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 64,
        height: 64,
        color: const Color(0xFFF7EEF2),
        child: imagePath != null && imagePath!.isNotEmpty
            ? Image.file(
                File(imagePath!),
                fit: BoxFit.cover,
              )
            : const Icon(Icons.auto_awesome, color: Color(0xFFEE7FA0)),
      ),
    );
  }
}

String _titleFromContent(String text) {
  final trimmed = text.replaceAll('\n', ' ').trim();
  if (trimmed.isEmpty) return 'Style advice';
  return trimmed.length > 36 ? '${trimmed.substring(0, 36)}...' : trimmed;
}

String _formatDate(DateTime date) {
  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec'
  ];
  final m = months[date.month - 1];
  final day = date.day.toString().padLeft(2, '0');
  return '$m $day, ${date.year}';
}
