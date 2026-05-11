import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:enkou/gen_a/A.dart';

import 'package:enkou/enkou/app/module/calendar/calendar_logic.dart';
import 'package:enkou/enkou/app/module/nav/nav_logic.dart';

import 'profile_logic.dart';

// Lunar Whisper（雾感渐变）配色：用于背景氛围，避免过饱和
const Color _lunarPink = Color(0xB3EED0F2);
const Color _lunarLavender = Color(0xB39EBAEB);
// 降低蓝色不透明度，并缩短蓝色停留区间，让下半部分更偏白
const Color _lunarSky = Color(0x5596DFF5);
const LinearGradient _pageBgGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  stops: [0.0, 0.22, 0.38, 1.0],
  colors: [_lunarPink, _lunarLavender, _lunarSky, Colors.white],
);

const Color _bg = Color(0xFFF6F4FB); // lavender fog background
const Color _surface = Color(0xFFFDFBFF); // soft lavender-tinted surface
const Color _titleColor = Color(0xFF242129); // softened near-black
const Color _mutedColor = Color(0xFF7C7785); // muted purple-grey
const Color _accent = Color(0xFF8F6AD8); // soft violet accent (match home)
const Color _headerPurple = _accent;
const Color _separator = Color(0xFFE6E0EF); // lavender separator
const Color _weekWarmAccent = _accent;
const Color _weekWarmSoft = Color(0x66EED0F2); // very soft pink highlight
const Color _weekWarmMuted = _mutedColor;

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final logic = Get.isRegistered<ProfileLogic>()
        ? Get.find<ProfileLogic>()
        : Get.put(ProfileLogic());
    final calendarLogic = Get.put(CalendarLogic());
    final navLogic = Get.find<NavLogic>();
    final theme = Theme.of(context);

    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(gradient: _pageBgGradient),
      child: SafeArea(
        bottom: true,
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: _buildHeaderWithAvatar(context, theme, topPadding),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Obx(() {
                      final today = calendarLogic.normalizeDate(DateTime.now());
                      final weekDays = _currentWeekDays(today);
                      return _buildCalendarRow(
                        theme,
                        weekDays,
                        today,
                        calendarLogic,
                            () => navLogic.changeTab(2),
                      );
                    }),
                    const SizedBox(height: 20),
                    _buildSectionTitle(theme, 'Services'),
                    const SizedBox(height: 8),
                    _buildServicesCard(theme, logic),
                    const SizedBox(height: 20),
                    _buildSectionTitle(theme, 'Support'),
                    const SizedBox(height: 8),
                    _buildSupportCard(theme, logic),
                    const SizedBox(height: 20),
                    _buildSectionTitle(theme, 'Account'),
                    const SizedBox(height: 8),
                    _buildAccountCard(context, theme, logic),
                    const SizedBox(height: 20),
                    Obx(
                          () => AnimatedOpacity(
                        opacity: logic.isSubmitting.value ? 1 : 0,
                        duration: const Duration(milliseconds: 180),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: _accent,
                                ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Processing...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: _mutedColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithAvatar(
      BuildContext context, ThemeData theme, double topPadding) {
    const avatarSize = 96.0;

    return SizedBox(
      height: topPadding + 180,
      child: Column(
        children: [
          SizedBox(height: topPadding + 24),
          Container(
            width: avatarSize,
            height: avatarSize,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _surface,
              border: Border.fromBorderSide(
                BorderSide(color: _separator, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 10,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: ClipOval(
              child: Image.asset(
                A.assets_enkou_logo,
                width: avatarSize * 0.9,
                height: avatarSize * 0.9,
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enkou',
            style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ) ??
                const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _titleColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserNameAndLocation(ThemeData theme) {
    // 已由顶部头像 + 名字替代，这里暂时保留空实现避免误用
    return const SizedBox.shrink();
  }

  List<DateTime> _currentWeekDays(DateTime today) {
    final weekday = today.weekday % 7;
    final start = today.subtract(Duration(days: weekday));
    return List.generate(7, (i) => start.add(Duration(days: i)));
  }

  Widget _buildCalendarRow(
      ThemeData theme,
      List<DateTime> weekDays,
      DateTime today,
      CalendarLogic logic,
      VoidCallback onTap,
      ) {
    const labels = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _separator, width: 1),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'This week',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: _titleColor,
                  ) ??
                      const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _titleColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: labels
                  .map(
                    (text) => Expanded(
                  child: Center(
                    child: Text(
                      text,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: _weekWarmMuted,
                      ) ??
                          const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _weekWarmMuted,
                          ),
                    ),
                  ),
                ),
              )
                  .toList(),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(7, (i) {
                final date = weekDays[i];
                final normalized = logic.normalizeDate(date);
                final isToday = normalized == today;
                final plannedLocation = logic.getPlannedLocation(normalized);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _CalendarDayCell(
                      date: normalized,
                      isToday: isToday,
                      plannedLocation: plannedLocation,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(ThemeData theme, String title) {
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: _titleColor,
      ) ??
          const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: _titleColor,
          ),
    );
  }

  Widget _buildServicesCard(ThemeData theme, ProfileLogic logic) {
    return _SectionCard(
      children: [
        _ListTile(
          title: 'Recharge',
          icon: Icons.account_balance_wallet_rounded,
          onTap: logic.openRecharge,
        ),
        _ListTile(
          title: 'Guides',
          icon: Icons.book,
          onTap: logic.openHistory,
        ),
      ],
    );
  }



  Widget _buildSupportCard(ThemeData theme, ProfileLogic logic) {
    return _SectionCard(
      children: [
        _ListTile(
          title: 'Feedback',
          icon: Icons.chat_bubble_rounded,
          onTap: logic.openFeedback,
        ),
        _ListTile(
          title: 'Terms of service',
          icon: Icons.description_rounded,
          onTap: logic.openTerms,
        ),
        _ListTile(
          title: 'Privacy Policy',
          icon: Icons.privacy_tip_rounded,
          onTap: logic.openPrivacy,
        ),
      ],
    );
  }
  Widget _buildAccountCard(
      BuildContext context, ThemeData theme, ProfileLogic logic) {
    return _SectionCard(
      children: [
        _ListTile(
          title: 'Log out',
          icon: Icons.logout_rounded,
          onTap: () => _confirmLogout(context, logic),
        ),
        _ListTile(
          title: 'Delete account',
          icon: Icons.delete_forever_rounded,
          textColor: const Color(0xFFE53935),
          iconColor: const Color(0xFFE53935),
          onTap: () => _confirmDelete(context, logic),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, ProfileLogic logic) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            // 顶部图标圆形渐变
            SizedBox(height: 4),
            _DialogIcon(),
            SizedBox(height: 14),
            Text(
              'Logout',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _titleColor,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Are you sure you want to logout?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _mutedColor,
                height: 1.4,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _separator, width: 1),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _titleColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Logout'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (ok == true) await logic.logout();
  }

  Future<void> _confirmDelete(BuildContext context, ProfileLogic logic) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _surface,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            SizedBox(height: 4),
            _DialogIcon(isDanger: true),
            SizedBox(height: 14),
            Text(
              'Delete account',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _titleColor,
                decoration: TextDecoration.none,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'This will permanently remove your account data.\nThis action cannot be undone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: _mutedColor,
                height: 1.4,
                decoration: TextDecoration.none,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _separator, width: 1),
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _titleColor,
                      decoration: TextDecoration.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.none,
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    if (ok == true) await logic.deleteAccount();
  }
}

class _CalendarDayCell extends StatelessWidget {
  const _CalendarDayCell({
    required this.date,
    required this.isToday,
    required this.plannedLocation,
  });

  final DateTime date;
  final bool isToday;
  final String? plannedLocation;

  @override
  Widget build(BuildContext context) {
    final hasPlan = plannedLocation != null && plannedLocation!.isNotEmpty;

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: isToday ? _weekWarmSoft : const Color(0x00FFFFFF),
        borderRadius: BorderRadius.circular(8),
        border: isToday
            ? Border.all(color: _weekWarmAccent, width: 1.0)
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            date.day.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isToday ? _weekWarmAccent : _titleColor,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: hasPlan
                  ? _weekWarmAccent
                  : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogIcon extends StatelessWidget {
  const _DialogIcon({this.isDanger = false});

  final bool isDanger;

  @override
  Widget build(BuildContext context) {
    final List<Color> colors = isDanger
        ? const [Color(0xFFFF9A8B), Color(0xFFFF6A88)]
        : const [Color(0xFFEED0F2), Color(0xFF9EBAEB)];

    final IconData iconData =
        isDanger ? Icons.warning_rounded : Icons.logout_rounded;

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x338F6AD8),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          iconData,
          size: 26,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _separator, width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: _listWithDividers(children),
      ),
    );
  }

  List<Widget> _listWithDividers(List<Widget> items) {
    if (items.isEmpty) return [];
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i < items.length - 1) {
        result.add(
          const Divider(height: 1, color: _separator),
        );
      }
    }
    return result;
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({
    required this.title,
    required this.icon,
    required this.onTap,
    this.textColor,
    this.iconColor,
  });

  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: (iconColor ?? _accent).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 18,
                color: iconColor ?? _accent,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: textColor ?? _titleColor,
                    ) ??
                        TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: textColor ?? _titleColor,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, size: 22, color: _mutedColor),
          ],
        ),
      ),
    );
  }
}
