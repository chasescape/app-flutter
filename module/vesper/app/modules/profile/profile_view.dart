import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vesper/vesper/app/data/coins_wallet_store.dart';
import 'package:vesper/vesper/app/widgets/app_background.dart';
import 'package:vesper/gen_a/A.dart';

import 'profile_logic.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});

  final ProfileLogic logic = Get.put(ProfileLogic());

  static const Color deepPink = Color(0xFFFF4FA5);
  static const Color hotPink = Color(0xFFFF66B5);
  static const Color softPink = Color(0xFFFF8AC4);
  static const Color mistPink = Color(0xFFFFB6D8);
  static const Color gold = Color(0xFFFFC247);
  static const Color ink = Color(0xFF2B1A2B);
  static const Color inkMuted = Color(0xFF6E5B6F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        useImageBackground: true,
        safeArea: false,
        padding: EdgeInsets.zero,
        child: Obx(
          () => Stack(
            children: [
              Positioned(
                top: 120,
                left: -40,
                child: _blurBlob(
                  color: softPink.withOpacity(0.35),
                  size: 180,
                ),
              ),
              Positioned(
                bottom: 180,
                right: -30,
                child: _blurBlob(
                  color: gold.withOpacity(0.3),
                  size: 200,
                ),
              ),
              Positioned(
                top: 260,
                right: 20,
                child: _blurBlob(
                  color: Colors.white.withOpacity(0.18),
                  size: 120,
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 44),
                    _buildHeader(),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GetBuilder<CoinsWalletStore>(
                        init: Get.isRegistered<CoinsWalletStore>()
                            ? Get.find<CoinsWalletStore>()
                            : Get.put(CoinsWalletStore(), permanent: true),
                        builder: (wallet) {
                          return _buildCoinsWalletCard(wallet.balance);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSection(
                        title: 'Support',
                        tiles: [
                          _ProfileTile(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: 'Feedback',
                            onTap: logic.onFeedback,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSection(
                        title: 'Legal',
                        tiles: [
                          _ProfileTile(
                            icon: Icons.verified_user_rounded,
                            label: 'Privacy Policy',
                            onTap: logic.onPrivacy,
                          ),
                          _ProfileTile(
                            icon: Icons.receipt_long_rounded,
                            label: 'Terms of Service',
                            onTap: logic.onTerms,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildSection(
                        title: 'Account',
                        tiles: [
                          _ProfileTile(
                            icon: Icons.logout_rounded,
                            label: 'Log Out',
                            onTap: logic.onLogout,
                          ),
                          _ProfileTile(
                            icon: Icons.delete_outline_rounded,
                            label: 'Delete Account',
                            onTap: logic.onDeleteAccount,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
              if (logic.isLoading.value)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.25),
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        const SizedBox(height: 80),
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [softPink, deepPink],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
            child: ClipOval(
              child: Image.asset(
                A.assets_vesper_logo,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Vesper',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: ink,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildCoinsWalletCard(int balance) {
    return InkWell(
      onTap: logic.onRecharge,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFD56A), Color(0xFFFFA800)],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 18,
              offset: const Offset(0, 10),
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
                  'Coins Wallet',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ProfilePage.ink,
                    letterSpacing: 0.3,
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: ProfilePage.ink,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _coinStack(),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      balance.toString(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: ProfilePage.ink,
                      ),
                    ),
                    Text(
                      'Available coins',
                      style: TextStyle(
                        fontSize: 12,
                        color: ProfilePage.inkMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Tap to recharge',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: ProfilePage.ink,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<_ProfileTile> tiles,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            softPink.withValues(alpha: 0.5),
            mistPink.withOpacity(0.35),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: ProfilePage.ink,
                letterSpacing: 0.3,
              ),
            ),
          ),
          ...tiles.map((tile) => _ProfileTileRow(tile: tile)).toList(),
        ],
      ),
    );
  }
}

class _ProfileTile {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _ProfileTileRow extends StatelessWidget {
  final _ProfileTile tile;

  const _ProfileTileRow({required this.tile});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: tile.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Icon(
              tile.icon,
              size: 18,
              color: ProfilePage.ink,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tile.label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: ProfilePage.ink,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: ProfilePage.ink,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

Widget _blurBlob({required Color color, required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}

Widget _coinStack() {
  return SizedBox(
    width: 68,
    height: 68,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC247),
            shape: BoxShape.circle,
          ),
        ),
        Positioned(
          left: 6,
          bottom: 6,
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFFFB21E),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 4,
          top: 4,
          child: Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFFFD56A),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const Icon(
          Icons.stars_rounded,
          size: 22,
          color: Colors.white,
        ),
      ],
    ),
  );
}
