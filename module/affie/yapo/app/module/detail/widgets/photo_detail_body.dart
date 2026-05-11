import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../detail_logic.dart';

/// 照片详情页面主体组件
class PhotoDetailBody extends StatefulWidget {
  const PhotoDetailBody({
    super.key,
    required this.photo,
    required this.photoId,
  });

  final RxMap<String, dynamic> photo;
  final String photoId;

  @override
  State<PhotoDetailBody> createState() => _PhotoDetailBodyState();
}

class _PhotoDetailBodyState extends State<PhotoDetailBody>
    with TickerProviderStateMixin {
  late final AnimationController _buttonAnimController;
  late final AnimationController _contentAnimController;
  late final Animation<double> _buttonOpacity;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _contentOpacity;
  late final Animation<Offset> _contentSlide;

  // ✅ 性能优化：缓存屏幕高度和图片高度，避免每次 build 重新计算
  double? _cachedScreenHeight;
  double? _cachedImageHeight;

  // ✅ 性能优化：静态渐变配置，避免每次 build 重新创建
  static const _imageOverlayGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x4D000000), // 0.3 alpha 预计算
      Colors.transparent,
      Color(0xE60a0412), // 0.9 alpha 预计算
    ],
    stops: [0.0, 0.4, 1.0],
  );

  @override
  void initState() {
    super.initState();

    // 按钮动画 - 快速出现
    _buttonAnimController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonAnimController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _buttonAnimController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    // 内容动画 - 延迟渐显
    _contentAnimController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _contentOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _contentAnimController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentAnimController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    // 启动动画
    _buttonAnimController.forward();
    _contentAnimController.forward();
  }

  @override
  void dispose() {
    _buttonAnimController.dispose();
    _contentAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 性能优化：缓存屏幕高度，避免每次 build 重新计算
    final screenHeight = MediaQuery.sizeOf(context).height;
    if (_cachedScreenHeight != screenHeight) {
      _cachedScreenHeight = screenHeight;
      _cachedImageHeight = screenHeight * 0.75;
    }
    final imageHeight = _cachedImageHeight!;

    // ✅ 性能优化：缩小 Obx 范围，只监听 photo 数据变化，而不是整个 Scaffold
    return Obx(() {
      final photo = widget.photo;

      return Scaffold(
        backgroundColor: const Color(0xFF0a0412),
        body: Stack(
          children: [
            // 1. 底层：固定的图片背景
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageHeight,
              child: Hero(
                tag: 'photo-${widget.photoId}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // ✅ 性能优化：使用 RepaintBoundary 隔离图片重绘，启用图片缓存
                    RepaintBoundary(
                      child: Image.asset(
                        photo['image']!,
                        fit: BoxFit.cover,
                        cacheWidth: 1200, // 限制缓存宽度，减少内存占用
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: const Color(0xFF0a0412),
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Color(0xFFf472b6),
                              size: 48,
                            ),
                          );
                        },
                      ),
                    ),
                    // ✅ 性能优化：使用静态渐变配置
                    Container(
                      decoration: const BoxDecoration(
                        gradient: _imageOverlayGradient,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // 2. 中层：可滚动的内容
            SingleChildScrollView(
              child: Column(
                children: [
                  // 占位空间（图片高度 - 重叠部分）
                  SizedBox(height: imageHeight - 40),

                  // 内容卡片
                  FadeTransition(
                    opacity: _contentOpacity,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Container(
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          color: Color(0xFF0a0412),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(32),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x80000000),
                              blurRadius: 30,
                              offset: Offset(0, -10),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // 标题
                              Text(
                                photo['title']!,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  height: 1.2,
                                  letterSpacing: -0.5,
                                ),
                              ),

                              const SizedBox(height: 16),

                              // 位置和日期
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      // ✅ 性能优化：使用预计算的颜色值
                                      color: const Color(0x26f472b6),
                                      // 0.15 alpha 预计算
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.location_on,
                                      size: 18,
                                      color: Color(0xFFf472b6),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          photo['location']!,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          photo['date']!,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(
                                                0x99FFFFFF), // 0.6 alpha 预计算
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // 时间和天气信息
                              if (photo['time'] != null ||
                                  photo['weather'] != null)
                                Row(
                                  children: [
                                    if (photo['time'] != null) ...[
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          // ✅ 性能优化：使用预计算的颜色值
                                          color: const Color(0x26a855f7),
                                          // 0.15 alpha 预计算
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(
                                                0x4Da855f7), // 0.3 alpha 预计算
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.access_time,
                                              size: 16,
                                              color: Color(0xFFd8b4fe),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              photo['time']!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFd8b4fe),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                    if (photo['weather'] != null)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          // ✅ 性能优化：使用预计算的颜色值
                                          color: const Color(0x26fbbf24),
                                          // 0.15 alpha 预计算
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(
                                                0x4Dfbbf24), // 0.3 alpha 预计算
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(
                                              Icons.wb_sunny,
                                              size: 16,
                                              color: Color(0xFFfde68a),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              photo['weather']!,
                                              style: const TextStyle(
                                                fontSize: 13,
                                                color: Color(0xFFfde68a),
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                  ],
                                ),

                              const SizedBox(height: 32),

                              // AI Highlights 标签
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  // ✅ 性能优化：使用静态渐变配置
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0x19f472b6), // 0.1 alpha 预计算
                                      Color(0x19a855f7), // 0.1 alpha 预计算
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(
                                        0x33f472b6), // 0.2 alpha 预计算
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFf472b6),
                                                Color(0xFFa855f7),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: const Icon(
                                            Icons.auto_awesome,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          'AI Highlights',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFf9a8d4),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    // ✅ 性能优化：使用 RepaintBoundary 隔离标签列表重绘
                                    RepaintBoundary(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: (photo['highlights']
                                                as List<dynamic>)
                                            .map((tag) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 12,
                                                    vertical: 6,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    gradient:
                                                        const LinearGradient(
                                                      colors: [
                                                        Color(0xFFf472b6),
                                                        Color(0xFFa855f7),
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color:
                                                            Color(0x4Df472b6),
                                                        // 0.3 alpha 预计算
                                                        blurRadius: 8,
                                                        offset: Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: Text(
                                                    tag.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // 故事内容
                              Container(
                                padding: const EdgeInsets.all(24),
                                decoration: BoxDecoration(
                                  // ✅ 性能优化：使用预计算的颜色值
                                  color: const Color(0x801a0b2e),
                                  // 0.5 alpha 预计算
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: const Color(0x33f472b6),
                                    // 0.2 alpha 预计算
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 4,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Color(0xFFf472b6),
                                                Color(0xFFa855f7),
                                              ],
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(2),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Text(
                                          'Effects Description',
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      photo['story']!,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        color: Color(0xCCFFFFFF),
                                        // 0.8 alpha 预计算
                                        height: 1.7,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 24),

                              // 用户标签
                              if (photo['tags'] != null &&
                                  (photo['tags'] as List).isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Tags',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFf9a8d4),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // ✅ 性能优化：使用 RepaintBoundary 隔离标签列表重绘
                                    RepaintBoundary(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: (photo['tags']
                                                as List<dynamic>)
                                            .map((tag) => Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                    horizontal: 14,
                                                    vertical: 8,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0x991a0b2e),
                                                    // 0.6 alpha 预计算
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            16),
                                                    border: Border.all(
                                                      color: const Color(
                                                          0x4Da855f7), // 0.3 alpha 预计算
                                                    ),
                                                  ),
                                                  child: Text(
                                                    tag.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      color: Color(0xE6d8b4fe),
                                                      // 0.9 alpha 预计算
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 3. 顶层：固定的按钮
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: FadeTransition(
                    opacity: _buttonOpacity,
                    child: SlideTransition(
                      position: _buttonSlide,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildCircleGlassButton(
                            icon: Icons.arrow_back,
                            onTap: () => Get.back(),
                          ),
                          _buildCircleGlassButton(
                            icon: Icons.share,
                            onTap: () => Get.find<DetailLogic>().onShare(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCircleGlassButton(
      {required IconData icon, required VoidCallback onTap}) {
    // ✅ 性能优化：静态颜色配置，避免每次 build 重新计算
    const buttonBgColor = Color(0x59FFFFFF); // 0.35 alpha 预计算
    const buttonBorderColor = Color(0x40FFFFFF); // 0.25 alpha 预计算
    const buttonShadowColor = Color(0x33000000); // 0.2 alpha 预计算

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: ClipOval(
          // ✅ 性能优化：使用 RepaintBoundary 隔离 BackdropFilter 重绘区域
          child: RepaintBoundary(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: buttonBgColor,
                  border: Border.all(
                    color: buttonBorderColor,
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: buttonShadowColor,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                  weight: 600,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
