import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:get/get.dart';
import 'package:senxo/senxo/app/routes/app_pages.dart';
import 'package:senxo/senxo/app/shared/widgets/common/gradient_background.dart';
import 'package:senxo/senxo/env/app_env.dart';
import 'package:senxo/gen_a/A.dart';
import '../nav/nav_view.dart';
import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic logic = Get.put(ProfileLogic());

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            _buildProfilePage(context),
            // 浮动导航栏
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: NavPage(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePage(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // Header with avatar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 24.h),
              child: TweenAnimationBuilder(
                duration: const Duration(milliseconds: 800),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          A.assets_senxo_logo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    // Username
                    Text(
                      'Senxo',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),

          // Coins card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _buildCoinsCard(),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 24.h)),

          // Settings section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                'Settings',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: 12.h)),

          // Settings list
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  _buildSettingItem(
                    context: context,
                    icon: LucideIcons.message_square,
                    title: 'feedback',
                    subtitle: 'Send us your feedback',
                    delay: 200,
                  ),
                  SizedBox(height: 8.h),
                  _buildSettingItem(
                    context: context,
                    icon: LucideIcons.file_text,
                    title: 'terms of service',
                    subtitle: 'Read our terms',
                    delay: 250,
                  ),
                  SizedBox(height: 8.h),
                  _buildSettingItem(
                    context: context,
                    icon: LucideIcons.shield,
                    title: 'Privacy',
                    subtitle: 'Privacy policy',
                    delay: 300,
                  ),
                  SizedBox(height: 8.h),
                  _buildSettingItem(
                    context: context,
                    icon: LucideIcons.clock,
                    title: 'history',
                    subtitle: 'View inspection history',
                    delay: 350,
                  ),
                  SizedBox(height: 8.h),
                  _buildSettingItem(
                    context: context,
                    icon: LucideIcons.user_minus,
                    title: 'Delete account',
                    subtitle: 'Permanently delete your account',
                    delay: 400,
                    isDeleteAccount: true,
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          // Logout button
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: _buildLogoutButton(),
            ),
          ),

          SliverToBoxAdapter(child: SizedBox(height: 100.h)),
        ],
      ),
    );
  }

  // Coins card
  Widget _buildCoinsCard() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          Get.toNamed(Routes.coins);
        },
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF9FB), // 粉白色
            borderRadius: BorderRadius.circular(24.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB6C1).withValues(alpha: 0.15),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              // Coin icon
              Container(
                width: 72.w,
                height: 72.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFFFFD700).withValues(alpha: 0.2),
                      const Color(0xFFFFB6C1).withValues(alpha: 0.2),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  LucideIcons.coins,
                  size: 36.sp,
                  color: const Color(0xFFFFB347),
                ),
              ),
              SizedBox(height: 10.h),
              // Coin info
              Text(
                'My Coins',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    LucideIcons.hand_coins,
                    size: 24.sp,
                    color: const Color(0xFFFFB347),
                  ),
                  SizedBox(width: 8.w),
                  Obx(() => Text(
                    '${logic.coins}',
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  )),
                ],
              ),
              SizedBox(height: 10.h),
              // Recharge button
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFFFFDAE0), // 淡粉色
                      Color(0xFFFFF4DC), // 淡黄色
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFDAE0).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      LucideIcons.wallet_cards,
                      size: 20.sp,
                      color: Colors.black87,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Recharge',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Setting item
  Widget _buildSettingItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required int delay,
    bool isDeleteAccount = false,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 600 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTap: () {
          if (isDeleteAccount) {
            _showDeleteAccountConfirm(context);
            return;
          }
          if (title.toLowerCase() == 'feedback') {
            Get.toNamed(Routes.feedback);
          } else if (title.toLowerCase() == 'history') {
            Get.toNamed(Routes.history);
          } else if (title.toLowerCase() == 'terms of service') {
            final appEnv = AppEnv();
            Get.toNamed(
              Routes.webview,
              arguments: {
                'url': appEnv.h5User,
                'title': 'Terms & Conditions',
              },
            );
          } else if (title.toLowerCase() == 'privacy') {
            final appEnv = AppEnv();
            Get.toNamed(
              Routes.webview,
              arguments: {
                'url': appEnv.h5Privacy,
                'title': 'Privacy Policy',
              },
            );
          }
        },
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 40.w,
                height: 40.w,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(icon, size: 20.sp, color: Colors.black87),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                LucideIcons.chevron_right,
                size: 20.sp,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteAccountConfirm(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Account data cannot be recovered after deletion. Are you sure you want to delete your account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              logic.deleteAccount();
            },
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
  }

  // Logout button
  Widget _buildLogoutButton() {
    return Obx(() {
      final loading = logic.isLoggingOut.value;
      return TweenAnimationBuilder(
        duration: const Duration(milliseconds: 1000),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Opacity(
            opacity: value,
            child: child,
          );
        },
        child: GestureDetector(
          onTap: loading ? null : () => logic.logout(),
          child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: Colors.red.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (loading)
                SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: const CircularProgressIndicator(
                    color: Colors.red,
                    strokeWidth: 2,
                  ),
                )
              else ...[
                Icon(LucideIcons.log_out, color: Colors.red, size: 20.sp),
                SizedBox(width: 8.w),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  });
  }
}
