import 'package:betwe/gen_a/A.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../interface.dart';

import '../../routes/app_routes.dart';
import '../../widgets/app_background.dart';
import '../../widgets/app_card.dart';
import '../coins/coins_view.dart';
import '../feedback/feedback_view.dart';
import '../history/history_view.dart';
import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({Key? key}) : super(key: key);

  final ProfileLogic logic = Get.put(ProfileLogic());

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      useImageBackground: true,
      safeArea: false,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          // 状态栏高度的占位
          SizedBox(height: MediaQuery.of(context).padding.top),
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8), // 减少顶部间距从12到8
                  const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16), // 标题后的间距
                  AppCard(
                    borderRadius: 28,
                    backgroundColor: Colors.white,
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(22),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(22),
                            child: Image.asset(
                              A.assets_betwe_logo,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Sarah Johnson',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  AppCard(
                    borderRadius: 24,
                    backgroundColor: Colors.white,
                    child: Column(
                      children: [
                        _ProfileAction(
                          icon: Icons.monetization_on,
                          title: 'My Coins',
                          iconColor: const Color(0xFFFF6B9D),
                          onTap: () {
                            Get.to(() => CoinsPage());
                          },
                        ),
                        const Divider(height: 24),
                        _ProfileAction(
                          icon: Icons.history,
                          title: 'History',
                          iconColor: const Color(0xFFB67CFF),
                          onTap: () {
                            Get.to(() => HistoryPage());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // 第二个卡片间距
                  AppCard(
                    borderRadius: 24,
                    backgroundColor: Colors.white,
                    child: Column(
                      children: [
                        _ProfileAction(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          iconColor: Colors.black54,
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.webview,
                              arguments: {
                                'title': 'Privacy Policy',
                                'url': Interface().h5Privacy ?? '',
                              },
                            );
                          },
                        ),
                        const Divider(height: 24),
                        _ProfileAction(
                          icon: Icons.description_outlined,
                          title: 'Terms of Service',
                          iconColor: Colors.black54,
                          onTap: () {
                            Get.toNamed(
                              AppRoutes.webview,
                              arguments: {
                                'title': 'Terms of Service',
                                'url': Interface().h5User ?? '',
                              },
                            );
                          },
                        ),
                        const Divider(height: 24),
                        _ProfileAction(
                          icon: Icons.feedback_outlined,
                          title: 'Feedback',
                          iconColor: Colors.black54,
                          onTap: () {
                            Get.to(() => const FeedbackPage());
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16), // 第三个卡片间距
                  AppCard(
                    borderRadius: 24,
                    backgroundColor: const Color(0xFFFFF0F5),
                    child: Column(
                      children: [
                        _ProfileAction(
                          icon: Icons.logout,
                          title: 'Log Out',
                          iconColor: const Color(0xFFFF6B9D),
                          showArrow: false,
                          onTap: () {
                            logic.logout();
                          },
                        ),
                        const Divider(height: 24, color: Color(0xFFFFB3D1)),
                        _ProfileAction(
                          icon: Icons.delete_outline,
                          title: 'Delete Account',
                          iconColor: const Color(0xFFFF6B9D), // 粉色
                          showArrow: false,
                          onTap: () {
                            Get.dialog<bool>(
                              AlertDialog(
                                title: const Text('Delete account'),
                                content: const Text(
                                  'This action cannot be undone. All your data will be permanently deleted.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(result: false),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Get.back(result: true),
                                    child: const Text('Delete'),
                                  ),
                                ],
                              ),
                            ).then((confirmed) {
                              if (confirmed == true) {
                                logic.deleteAccount();
                              }
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  // 底部导航栏高度的占位，确保内容不被遮挡
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAction extends StatelessWidget {
  const _ProfileAction({
    required this.icon,
    required this.title,
    this.subtitle,
    this.iconColor = Colors.black54,
    this.showArrow = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Color iconColor;
  final bool showArrow;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4), // 减少垂直内边距从8到4
          child: Row(
            children: [
              Container(
                width: 44,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor == const Color(0xFFFF6B9D)
                      ? const Color(0xFFFFF0F5)
                      : const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ]
                  ],
                ),
              ),
              if (showArrow) const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
