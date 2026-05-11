import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/routes/app_pages.dart';

/// 金币不足底部弹框组件
class InsufficientCoinsBottomSheet extends StatelessWidget {
  final int currentCoins;
  final int requiredCoins;

  const InsufficientCoinsBottomSheet({
    super.key,
    required this.currentCoins,
    required this.requiredCoins,
  });

  /// 显示底部弹框
  static void show({
    required int currentCoins,
    required int requiredCoins,
  }) {
    Get.bottomSheet(
      InsufficientCoinsBottomSheet(
        currentCoins: currentCoins,
        requiredCoins: requiredCoins,
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1a0b2e),
            Color(0xFF2d1b4e),
          ],
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        border: Border.all(
          color: const Color(0xFFfbbf24).withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFfbbf24).withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 拖拽指示器
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFfbbf24).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 图标
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFFfbbf24), Color(0xFFf97316)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFfbbf24).withValues(alpha: 0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // 标题
          Center(
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Color(0xFFfde68a), Color(0xFFfbbf24)],
              ).createShader(bounds),
              child: const Text(
                'Insufficient Coins',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // 描述内容
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFfbbf24).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFfbbf24).withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Balance',
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Color(0xFFfbbf24),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$currentCoins',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfde68a),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 15,
                        color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Color(0xFFf87171),
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$requiredCoins',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFf87171),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  height: 1,
                  color: const Color(0xFFfbbf24).withValues(alpha: 0.2),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Need More',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFfde68a),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          color: Color(0xFFfbbf24),
                          size: 20,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${requiredCoins - currentCoins}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfde68a),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          
          // 描述文本
          Text(
            'You don\'t have enough coins to publish this memory. Please top up to continue.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 28),
          
          // 按钮
          Row(
            children: [
              // 取消按钮
              Expanded(
                child: InkWell(
                  onTap: () => Get.back(),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFFec4899).withValues(alpha: 0.15),
                      border: Border.all(
                        color: const Color(0xFFec4899).withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFd8b4fe).withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // 去充值按钮
              Expanded(
                flex: 2,
                child: InkWell(
                  onTap: () {
                    Get.back();
                    Get.toNamed(Routes.coins);
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFfbbf24), Color(0xFFf97316)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFfbbf24).withValues(alpha: 0.4),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.monetization_on,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Top Up Now',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
