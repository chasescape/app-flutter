import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../interface.dart';
import '../../routes/app_pages.dart';
import '../../theme/app_theme.dart';
import '../../services/storage_service.dart';
import '../../services/coins_manager.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/pastel_ui.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final StorageService _storage = StorageService.instance;
  final CoinsManager _coinsManager = CoinsManager.instance;

  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _sleepTime = const TimeOfDay(hour: 23, minute: 0);
  bool _notificationsEnabled = true;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    await _coinsManager.initialize();
    await _loadSettings();
  }

  Future<void> _loadSettings() async {
    final wakeStr = _storage.targetWakeTime;
    final sleepStr = _storage.targetSleepTime;
    final notifications = _storage.notificationEnabled;

    if (wakeStr != null) {
      final parts = wakeStr.split(':');
      _wakeTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }
    if (sleepStr != null) {
      final parts = sleepStr.split(':');
      _sleepTime = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    }

    if (!mounted) return;
    setState(() {
      _notificationsEnabled = notifications;
    });
  }

  Future<void> _selectTime({
    required TimeOfDay initialTime,
    required ValueChanged<TimeOfDay> onPicked,
  }) async {
    final initialDateTime = DateTime(
      2000,
      1,
      1,
      initialTime.hour,
      initialTime.minute,
    );
    var tempTime = initialTime;

    final picked = await showModalBottomSheet<TimeOfDay>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Container(
            margin: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            decoration: BoxDecoration(
              gradient: AppGradients.softCard,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.stroke),
              boxShadow: AppShadows.md,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Text('Select time', style: AppTextStyles.h3),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(tempTime),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.accentDark,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 10,
                        ),
                      ),
                      child: const Text('Done'),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                SizedBox(
                  height: 220,
                  child: CupertinoTheme(
                    data: const CupertinoThemeData(
                      primaryColor: AppColors.accentDark,
                    ),
                    child: CupertinoDatePicker(
                      mode: CupertinoDatePickerMode.time,
                      use24hFormat: true,
                      initialDateTime: initialDateTime,
                      minuteInterval: 1,
                      onDateTimeChanged: (value) {
                        tempTime = TimeOfDay(
                          hour: value.hour,
                          minute: value.minute,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (picked != null) onPicked(picked);
  }

  Future<void> _handleClearData() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Clear all data',
      content: 'This removes check-ins, coins, and saved progress.',
      confirmText: 'Clear data',
      cancelText: 'Cancel',
      isDangerous: true,
    );

    if (confirmed != true) return;

    setState(() {
      _isDeleting = true;
    });

    await _coinsManager.clear();
    await _storage.clearAllUserData();
    Interface().authToken = null;

    if (!mounted) return;
    setState(() {
      _isDeleting = false;
    });
    AppRoutes.toLogin();
  }

  Future<void> _handleLogout() async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Sign out',
      content: 'Are you sure you want to sign out?',
      confirmText: 'Sign out',
      cancelText: 'Stay',
    );

    if (confirmed == true) {
      await _storage.removeAuthToken();
      Interface().authToken = null;
      AppRoutes.toLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PastelScaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Get.back(),
            ),
            title: const Text('Settings'),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildBalanceCard(),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionCard(
                  title: 'Sleep schedule',
                  children: [
                    _buildSettingRow(
                      icon: Icons.wb_sunny_outlined,
                      title: 'Wake-up time',
                      subtitle: 'Ideal start for your morning ritual',
                      trailingText: _formatTime(_wakeTime),
                      onTap: () => _selectTime(
                        initialTime: _wakeTime,
                        onPicked: (picked) async {
                          setState(() => _wakeTime = picked);
                          await _storage.setTargetWakeTime(
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingRow(
                      icon: Icons.bedtime_outlined,
                      title: 'Bedtime',
                      subtitle: 'A calm target to wind down',
                      trailingText: _formatTime(_sleepTime),
                      onTap: () => _selectTime(
                        initialTime: _sleepTime,
                        onPicked: (picked) async {
                          setState(() => _sleepTime = picked);
                          await _storage.setTargetSleepTime(
                            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}',
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionCard(
                  title: 'General',
                  children: [
                    _buildSwitchRow(
                      icon: Icons.notifications_none_rounded,
                      title: 'Bedtime reminders',
                      subtitle: 'Gentle nudges before sleep',
                      value: _notificationsEnabled,
                      onChanged: (value) async {
                        setState(() => _notificationsEnabled = value);
                        await _storage.setNotificationEnabled(value);
                      },
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingRow(
                      icon: Icons.feedback_outlined,
                      title: 'Send feedback',
                      subtitle: 'Tell us what should feel better',
                      onTap: AppRoutes.toFeedback,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildSectionCard(
                  title: 'Account',
                  children: [
                    _buildSettingRow(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => AppRoutes.toAgreement('Terms of Service', Interface().h5User),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingRow(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => AppRoutes.toAgreement('Privacy Policy', Interface().h5Privacy),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingRow(
                      icon: Icons.logout_rounded,
                      title: 'Sign out',
                      titleColor: AppColors.error,
                      onTap: _handleLogout,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _buildSettingRow(
                      icon: Icons.delete_outline_rounded,
                      title: 'Clear all data',
                      titleColor: AppColors.error,
                      onTap: _handleClearData,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (_isDeleting)
          Container(
            color: AppColors.backgroundOverlay,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.accentDark),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return GlassCard(
      padding: EdgeInsets.zero,
      child: ValueListenableBuilder<int>(
        valueListenable: _coinsManager.coinsNotifier,
        builder: (context, coins, child) {
          return Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFF7EFE5),
                  Color(0xFFE9DCF7),
                ],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(26),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF3C3153),
                    Color(0xFF221B34),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF221B34).withValues(alpha: 0.18),
                    blurRadius: 28,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -34,
                    right: -12,
                    child: Container(
                      width: 128,
                      height: 128,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 24,
                    top: 72,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1B96B),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(
                                Icons.account_balance_wallet_rounded,
                                color: Color(0xFF2B213F),
                                size: 28,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.10),
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.10),
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.diamond_outlined,
                                    size: 14,
                                    color: Color(0xFFFFDFA8),
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Wallet',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Current coins',
                          style: TextStyle(
                            color: Color(0xFFCBBBE3),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '$coins',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Top up anytime for more daily check-ins.',
                          style: TextStyle(
                            color: Color(0xFFB6AACD),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 48,
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: AppRoutes.toCoinShop,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF1B96B),
                              foregroundColor: const Color(0xFF2B213F),
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 22),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: const Text(
                              'Get more',
                              style: TextStyle(fontWeight: FontWeight.w700),
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
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.md),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingRow({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            _buildLeading(icon),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.body.copyWith(
                      color: titleColor ?? AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle, style: AppTextStyles.small),
                  ],
                ],
              ),
            ),
            if (trailingText != null)
              Text(
                trailingText,
                style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w500),
              )
            else
              const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          _buildLeading(icon),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w800)),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.small),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFB0A2FF),
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: const Color(0xFFE0D9F4),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildLeading(IconData icon) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(icon, color: AppColors.accentDark, size: 20),
    );
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
