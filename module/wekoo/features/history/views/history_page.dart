import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../controllers/main_controller.dart';
import '../../../models/drink_record.dart';
import '../../../theme/app_theme.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find<MainController>();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackgroundGradient,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Wekoo History'),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: 'Clear all records',
                onPressed: () => _confirmClearRecords(controller),
              ),
            ],
          ),
          body: Obx(() {
            final records = controller.records;

            if (records.isEmpty) {
              return Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: AppTheme.cardGlowGradient,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: AppTheme.secondaryLight),
                    boxShadow: AppTheme.shadows,
                  ),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.water_drop_outlined,
                        size: 66,
                        color: AppTheme.textDisabled,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No water logs yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your daily records will collect here once you start logging.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.45,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final groupedRecords = _groupRecordsByDate(records);

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
              physics: const BouncingScrollPhysics(),
              itemCount: groupedRecords.length,
              itemBuilder: (context, index) {
                final date = groupedRecords.keys.elementAt(index);
                final dayRecords = groupedRecords[date]!;
                final totalAmount = dayRecords.fold<int>(
                  0,
                  (sum, record) => sum + record.amount,
                );

                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: 1),
                  duration: Duration(milliseconds: 320 + (index * 80)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.translate(
                      offset: Offset(0, (1 - value) * 20),
                      child: Opacity(opacity: value, child: child),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 18),
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      gradient: AppTheme.cardGlowGradient,
                      borderRadius: BorderRadius.circular(26),
                      border: Border.all(color: AppTheme.secondaryLight),
                      boxShadow: AppTheme.shadows,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDateHeader(date, totalAmount, dayRecords.length),
                        const SizedBox(height: 14),
                        ...dayRecords.map(
                          (record) => _buildRecordCard(record, controller),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }

  Map<String, List<DrinkRecord>> _groupRecordsByDate(List<DrinkRecord> records) {
    final grouped = <String, List<DrinkRecord>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final record in records) {
      final recordDate = DateTime(
        record.dateTime.year,
        record.dateTime.month,
        record.dateTime.day,
      );
      String key;

      if (recordDate == today) {
        key = 'Today';
      } else if (recordDate == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat('MMM dd, yyyy').format(record.dateTime);
      }

      grouped.putIfAbsent(key, () => []).add(record);
    }

    return grouped;
  }

  Widget _buildDateHeader(String date, int totalAmount, int count) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$count ${count == 1 ? 'record' : 'records'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.secondaryLight,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Text(
            '$totalAmount ml',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.accentMain,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordCard(DrinkRecord record, MainController controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.waveMint, AppTheme.waveBlue],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.water_drop_rounded,
              color: Colors.white,
              size: 23,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.amount} ml',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('HH:mm').format(record.dateTime),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
                if (record.note != null && record.note!.trim().isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    record.note!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: AppTheme.textDisabled,
              size: 20,
            ),
            onPressed: () => _confirmDeleteRecord(controller, record),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  void _confirmClearRecords(MainController controller) {
    if (controller.records.isEmpty) {
      Get.snackbar(
        'No records',
        'There is nothing to clear yet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppTheme.deepOcean.withValues(alpha: 0.92),
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        borderRadius: 18,
      );
      return;
    }

    Get.dialog(
      _HistoryActionDialog(
        title: 'Clear all records',
        message: 'Remove all water logs from your history? This cannot be undone.',
        confirmLabel: 'Clear all',
        onConfirm: () async {
          await controller.clearRecords();
          Get.back();
          Get.snackbar(
            'Cleared',
            'All water records have been removed.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppTheme.deepOcean.withValues(alpha: 0.92),
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
            borderRadius: 18,
          );
        },
      ),
      barrierDismissible: true,
    );
  }

  void _confirmDeleteRecord(MainController controller, DrinkRecord record) {
    Get.dialog(
      _HistoryActionDialog(
        title: 'Delete record',
        message: 'Remove this water log from history?',
        confirmLabel: 'Delete',
        onConfirm: () {
          controller.deleteRecord(record.id);
          Get.back();
        },
      ),
      barrierDismissible: true,
    );
  }
}

class _HistoryActionDialog extends StatelessWidget {
  const _HistoryActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onConfirm,
  });

  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: Get.back,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.waveMint,
                      side: const BorderSide(color: AppTheme.waveMint, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.waveMint,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    child: Text(
                      confirmLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
