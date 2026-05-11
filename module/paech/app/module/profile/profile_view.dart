import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:paech/gen_a/A.dart';

import '../../../env/app_env.dart';
import '../deposit/deposit_view.dart';
import '../feedback/feedback_view.dart';
import '../generate/generate_logic.dart';
import '../history/history_view.dart';
import '../nav/nav_logic.dart';
import '../protocol/protocol_view.dart';
import 'profile_logic.dart';

class ProfilePage extends StatefulWidget {
  ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with SingleTickerProviderStateMixin {
  late final ProfileLogic logic;
  late final AnimationController _animationController;
  late final Animation<double> _avatarFade;
  late final Animation<double> _avatarScale;
  late final Animation<double> _creditsFade;
  late final Animation<double> _infoFade;
  late final Animation<double> _settingsFade;

  static const int _kProfileTabIndex = 2;
  bool _hasPlayedEntrance = false;

  @override
  void initState() {
    super.initState();
    logic = Get.put(ProfileLogic());
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _avatarFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
      ),
    );
    _avatarScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _creditsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.55, curve: Curves.easeOut),
      ),
    );
    _infoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );
    _settingsFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.85, curve: Curves.easeOut),
      ),
    );
    // 仅首次切到本 Tab 时播放入场渐入动画
    final navLogic = Get.find<NavLogic>();
    ever(navLogic.tabIndex, (int index) {
      if (!mounted || index != _kProfileTabIndex || _hasPlayedEntrance) return;
      _hasPlayedEntrance = true;
      _animationController.reset();
      _animationController.forward();
    });
    if (navLogic.tabIndex.value == _kProfileTabIndex) {
      _hasPlayedEntrance = true;
      Future.delayed(const Duration(milliseconds: 50), () {
        if (mounted) _animationController.forward();
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F1EA),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Text(
                    'Profile',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF2D2A26),
                    ),
                  ),
                ),
                const Divider(height: 1, color: Color(0xFFE8E0D7)),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FadeTransition(
                          opacity: _avatarFade,
                          child: ScaleTransition(
                            scale: _avatarScale,
                            child: Column(
                              children: [
                                Container(
                                  width: 110,
                                  height: 110,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF3EDE6),
                                    shape: BoxShape.circle,
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: Image.asset(
                                    A.assets_paech_logo,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Paech',
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF2D2A26),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        FadeTransition(
                          opacity: _creditsFade,
                          child: _CreditsCard(
                            onTap: () => Get.to(() => DepositPage()),
                          ),
                        ),
                        const SizedBox(height: 25),
                        FadeTransition(
                          opacity: _infoFade,
                          child: const _InfoCard(),
                        ),
                        const SizedBox(height: 25),
                        FadeTransition(
                          opacity: _settingsFade,
                          child: _SettingsCard(
                          items: [
                            _SettingsItem(
                              icon: Icons.history,
                              title: 'History',
                              onTap: () => Get.to(() => HistoryPage()),
                            ),
                            _SettingsItem(
                              icon: Icons.share,
                              title: 'Feedback',
                              onTap: () => Get.to(() => FeedbackPage()),
                            ),
                            _SettingsItem(
                              icon: Icons.privacy_tip_outlined,
                              title: 'Privacy Policy',
                              onTap: () {
                                final env = Aquaria255AppEnv();
                                if (env.h5Privacy.isNotEmpty) {
                                  Get.to(() => ProtocolPage(
                                        url: env.h5Privacy,
                                        title: 'Privacy Policy',
                                      ));
                                }
                              },
                            ),
                            _SettingsItem(
                              icon: Icons.description_outlined,
                              title: 'Terms of Service',
                              onTap: () {
                                final env = Aquaria255AppEnv();
                                if (env.h5User.isNotEmpty) {
                                  Get.to(() => ProtocolPage(
                                        url: env.h5User,
                                        title: 'Terms of Service',
                                      ));
                                }
                              },
                            ),
                            _SettingsItem(
                              icon: Icons.logout,
                              title: 'Log Out',
                              onTap: () async {
                                final ok = await Get.dialog<bool>(
                                  Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: 8,
                                    shadowColor: Colors.black26,
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 320),
                                      padding: const EdgeInsets.fromLTRB(
                                          28, 28, 28, 24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 22),
                                          const Text(
                                            'Log Out',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2D2A26),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Are you sure you want to log out?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.45,
                                              color: const Color(0xFF2D2A26)
                                                  .withValues(alpha: 0.85),
                                            ),
                                          ),
                                          const SizedBox(height: 28),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () =>
                                                      Get.back(result: false),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        const Color(0xFF2D2A26),
                                                    side: const BorderSide(
                                                        color:
                                                            Color(0xFFE8E0D7)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text('Cancel'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      Get.back(result: true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFD8B792)
                                                            .withValues(
                                                                alpha: 0.85),
                                                    foregroundColor:
                                                        const Color(0xff130e14),
                                                    elevation: 0,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text('Log Out'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: false,
                                );
                                if (ok == true) {
                                  await logic.performLogout();
                                }
                              },
                            ),
                            _SettingsItem(
                              icon: Icons.delete_outline,
                              title: 'Delete Account',
                              isDestructive: true,
                              onTap: () async {
                                final ok = await Get.dialog<bool>(
                                  Dialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    backgroundColor: Colors.white,
                                    elevation: 8,
                                    shadowColor: Colors.black26,
                                    child: Container(
                                      constraints:
                                          const BoxConstraints(maxWidth: 320),
                                      padding: const EdgeInsets.fromLTRB(
                                          28, 28, 28, 24),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const SizedBox(height: 22),
                                          const Text(
                                            'Delete Account',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                              color: Color(0xFF2D2A26),
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'This action cannot be undone. All your data will be permanently deleted. Are you sure?',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 14,
                                              height: 1.45,
                                              color: const Color(0xFF2D2A26)
                                                  .withValues(alpha: 0.85),
                                            ),
                                          ),
                                          const SizedBox(height: 28),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
                                                  onPressed: () =>
                                                      Get.back(result: false),
                                                  style:
                                                      OutlinedButton.styleFrom(
                                                    foregroundColor:
                                                        const Color(0xFF2D2A26),
                                                    side: const BorderSide(
                                                        color:
                                                            Color(0xFFE8E0D7)),
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text('Cancel'),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () =>
                                                      Get.back(result: true),
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color(0xFFE25555),
                                                    foregroundColor:
                                                        Colors.white,
                                                    elevation: 0,
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 14),
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                  ),
                                                  child: const Text('Delete'),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  barrierDismissible: false,
                                );
                                if (ok == true) {
                                  await logic.performDeleteAccount();
                                }
                              },
                            ),
                          ],
                        ),
                        ),
                        const SizedBox(height: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Obx(() {
            if (!logic.isDeleting.value) return const SizedBox.shrink();
            return Stack(
              fit: StackFit.expand,
              children: [
                ModalBarrier(
                  color: Colors.black54,
                  dismissible: false,
                ),
                const Center(child: CircularProgressIndicator()),
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _CreditsCard extends StatefulWidget {
  const _CreditsCard({this.onTap});

  final VoidCallback? onTap;

  @override
  State<_CreditsCard> createState() => _CreditsCardState();
}

class _CreditsCardState extends State<_CreditsCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (isHighlighted) {
          if (_pressed == isHighlighted) return;
          setState(() => _pressed = isHighlighted);
        },
        borderRadius: BorderRadius.circular(20),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOut,
          scale: _pressed ? 0.98 : 1,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFD8B792),
                  Color(0xFFC8A57E),
                ],
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -60,
                  right: -60,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Available Credits',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Obx(() {
                        String creditsText = '0 Coins';
                        if (Get.isRegistered<GenerateLogic>()) {
                          try {
                            final generateLogic = Get.find<GenerateLogic>();
                            creditsText =
                                '${generateLogic.credits.value} Coins';
                          } catch (_) {
                            creditsText = '0 Coins';
                          }
                        }
                        return Text(
                          creditsText,
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            fontSize: 26,
                          ),
                        );
                      }),
                      const SizedBox(height: 18),
                      Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              A.assets_paech_ic_coin,
                              width: 18,
                              height: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Purchase More Credits',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFC8A57E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Get AI-powered care & styling suggestions',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 13,
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
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFEFE7DE)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFF2EBE3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt,
              size: 18,
              color: Color(0xFFC9A882),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How Credits Work',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: const Color(0xFF4A3C2E),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Each AI generation uses 100 coins. Purchase credit packs to analyze your clothing and get personalized care & styling tips.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 13,
                    color: const Color(0xFF8B7968),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem({
    required this.icon,
    required this.title,
    this.isDestructive = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.items,
  });

  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            _SettingsRow(
              item: items[i],
              showDivider: i != items.length - 1,
            ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.item,
    required this.showDivider,
  });

  final _SettingsItem item;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: item.onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: Color(0xFFF1EBE3)),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: item.isDestructive
                    ? const Color(0xFFE25555)
                    : const Color(0xFF8D857C),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  item.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: item.isDestructive
                        ? const Color(0xFFE25555)
                        : const Color(0xFF2D2A26),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: item.isDestructive
                    ? const Color(0xFFE25555)
                    : const Color(0xFFB8B0A6),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
