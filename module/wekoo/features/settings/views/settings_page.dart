import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/settings_controller.dart';
import '../../../theme/app_theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.appBackgroundGradient,
      ),
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Settings'),
            backgroundColor: Colors.transparent,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            children: [
              _buildGoalSection(controller),
              _buildReminderSection(controller),
              _buildUnitSection(controller),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGoalSection(SettingsController controller) {
    return Obx(() {
      return _buildSection(
        title: 'Daily Goal',
        children: [
          _buildSlider(
            value: controller.settings.value.dailyGoal.toDouble(),
            min: 1000,
            max: 4000,
            divisions: 30,
            label: '${controller.settings.value.dailyGoal} ml',
            onChanged: (value) {
              controller.updateDailyGoal(value.toInt());
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
            child: Text(
              'Current goal: ${controller.settings.value.dailyGoal} ml',
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      );
    });
  }

  Widget _buildReminderSection(SettingsController controller) {
    return Obx(() {
      return _buildSection(
        title: 'Reminders',
        children: [
          SwitchListTile(
            value: controller.settings.value.reminderEnabled,
            onChanged: (value) {
              controller.updateReminder(value);
            },
            title: const Text('Reminders'),
            subtitle: const Text('Stay hydrated with timely notifications'),
            activeColor: AppTheme.primaryMain,
          ),
          if (controller.settings.value.reminderEnabled) ...[
            ListTile(
              title: const Text('Reminder Interval'),
              subtitle: Text(
                'Every ${controller.settings.value.reminderInterval} hours',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showIntervalDialog(controller),
            ),
            ListTile(
              title: const Text('Sleep Hours'),
              subtitle: Text(
                '${controller.settings.value.sleepStartTime} - ${controller.settings.value.sleepEndTime}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showSleepTimeDialog(controller),
            ),
          ],
        ],
      );
    });
  }

  Widget _buildUnitSection(SettingsController controller) {
    return Obx(() {
      return _buildSection(
        title: 'Unit',
        children: [
          RadioListTile<String>(
            value: 'ml',
            groupValue: controller.settings.value.unit,
            activeColor: AppTheme.primaryMain,
            onChanged: (value) {
              if (value != null) controller.updateUnit(value);
            },
            title: const Text('Milliliters (ml)'),
          ),
          RadioListTile<String>(
            value: 'oz',
            groupValue: controller.settings.value.unit,
            activeColor: AppTheme.primaryMain,
            onChanged: (value) {
              if (value != null) controller.updateUnit(value);
            },
            title: const Text('Ounces (oz)'),
          ),
        ],
      );
    });
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingLg,
            AppTheme.spacingMd,
            AppTheme.spacingSm,
          ),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: AppTheme.cardGlowGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: AppTheme.secondaryLight),
            boxShadow: AppTheme.shadows,
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: AppTheme.spacingLg),
      ],
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: SliderTheme(
        data: SliderThemeData(
          activeTrackColor: AppTheme.primaryMain,
          inactiveTrackColor: AppTheme.bgSecondary,
          thumbColor: AppTheme.primaryMain,
          overlayColor: AppTheme.primaryMain.withValues(alpha: 0.15),
          trackHeight: 5,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
        ),
        child: Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ),
    );
  }

  void _showIntervalDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Reminder Interval'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [1, 2, 3, 4].map((interval) {
            return RadioListTile<int>(
              value: interval,
              groupValue: controller.settings.value.reminderInterval,
              activeColor: AppTheme.primaryMain,
              onChanged: (value) {
                if (value != null) {
                  controller.updateReminderInterval(value);
                  Get.back();
                }
              },
              title: Text('Every $interval hour${interval > 1 ? 's' : ''}'),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSleepTimeDialog(SettingsController controller) {
    Get.dialog(
      AlertDialog(
        title: const Text('Sleep Hours'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Start Time'),
              trailing: Text(controller.settings.value.sleepStartTime),
              onTap: () => _selectTime(controller, true),
            ),
            ListTile(
              title: const Text('End Time'),
              trailing: Text(controller.settings.value.sleepEndTime),
              onTap: () => _selectTime(controller, false),
            ),
          ],
        ),
      ),
    );
  }

  void _selectTime(SettingsController controller, bool isStartTime) {
    showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay(
        hour: int.parse(
          isStartTime
              ? controller.settings.value.sleepStartTime.split(':')[0]
              : controller.settings.value.sleepEndTime.split(':')[0],
        ),
        minute: 0,
      ),
    ).then((time) {
      if (time != null) {
        final timeStr = '${time.hour.toString().padLeft(2, '0')}:00';
        if (isStartTime) {
          controller.updateSleepTime(
            timeStr,
            controller.settings.value.sleepEndTime,
          );
        } else {
          controller.updateSleepTime(
            controller.settings.value.sleepStartTime,
            timeStr,
          );
        }
      }
    });
  }
}
