import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';
import 'package:yapo/gen_a/A.dart';
import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic logic = Get.put(ProfileLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 渐变背景
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Color(0xFF0d0618),
                  Color(0xFF1a0b2e),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.3),
                  radius: 0.8,
                  colors: [
                    Color(0x14a855f7), // 0.08 alpha
                    Color(0x0Aec4899), // 0.04 alpha
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // 主内容
          CustomScrollView(
            slivers: [
              // Header
              SliverAppBar(
                pinned: true,
                backgroundColor: const Color(0x801a0b2e), // 0.5 alpha
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x807c2d9e), // 0.5 alpha
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  // ✅ 移除 ShaderMask，使用简单颜色
                  title: const Text(
                    'Profile',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFf472b6),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 32),

                    // Avatar Section
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFec4899), Color(0xFF9333ea)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40ec4899), // 0.25 alpha
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          A.assets_yapo_logo,
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Yapo',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFFf9a8d4),
                      ),
                    ),

                    // Top-up Section
                    Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(Routes.coins);
                              },
                              borderRadius: BorderRadius.circular(16),
                              splashColor:
                                  const Color(0x59ec4899), // 0.35 alpha
                              highlightColor:
                                  const Color(0x33a855f7), // 0.2 alpha
                              child: Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFdb2777),
                                      Color(0xFF9333ea)
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x66ec4899), // 0.4 alpha
                                      blurRadius: 24,
                                      spreadRadius: 0,
                                      offset: Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Color(0x4Da855f7), // 0.3 alpha
                                      blurRadius: 36,
                                      spreadRadius: 2,
                                      offset: Offset(0, 6),
                                    ),
                                    BoxShadow(
                                      color: Color(0x40ec4899), // 0.25 alpha
                                      blurRadius: 20,
                                      spreadRadius: -2,
                                    ),
                                  ],
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.credit_card,
                                        color: Colors.white, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      'Top Up Credits',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            _buildMenuItem(
                              icon: Icons.feedback_outlined,
                              iconColor: const Color(0xFFfbbf24),
                              title: 'Feedback',
                              subtitle: 'Share your thoughts with us',
                              onTap: () {
                                Get.toNamed(Routes.feedback);
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.shield,
                              iconColor: const Color(0xFFd8b4fe),
                              title: 'Privacy Policy',
                              subtitle: 'View our privacy policy',
                              onTap: () {
                                logic.openPrivacyPolicy();
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.description,
                              iconColor: const Color(0xFFd8b4fe),
                              title: 'Terms of Service',
                              subtitle: 'Read our terms',
                              onTap: () {
                                logic.openTermsOfService();
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.logout,
                              iconColor: const Color(0xFFfbbf24),
                              title: 'Log Out',
                              subtitle: 'Sign out of your account',
                              onTap: () {
                                logic.logout();
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildMenuItem(
                              icon: Icons.delete,
                              iconColor: const Color(0xFFf87171),
                              title: 'Delete Account',
                              subtitle: 'Permanently delete your account',
                              borderColor: const Color(0x33ef4444), // 0.2 alpha
                              backgroundColor: const [
                                Color(0x1Aef4444), // 0.1 alpha
                                Color(0x1Aec4899), // 0.1 alpha
                              ],
                              onTap: () {
                                logic.deleteAccount();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: Obx(() {
              final isLoading =
                  logic.isLoggingOut.value || logic.isDeletingAccount.value;
              if (!isLoading) {
                return const SizedBox.shrink();
              }
              return Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Lottie.asset(
                    A.assets_loading_loading,
                    width: 140,
                    height: 140,
                    fit: BoxFit.contain,
                    repeat: true,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? borderColor,
    List<Color>? backgroundColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: const Color(0x1Fec4899), // 0.12 alpha
        highlightColor: const Color(0x0Fa855f7), // 0.06 alpha
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: backgroundColor ??
                  const [
                    Color(0x0Dec4899), // 0.05 alpha
                    Color(0x0Da855f7), // 0.05 alpha
                  ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: borderColor ?? const Color(0x1Fec4899), // 0.12 alpha
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Color.alphaBlend(
                    iconColor.withValues(alpha: 0.15),
                    Colors.transparent,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFf9a8d4),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0x99d8b4fe), // 0.6 alpha
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
}
