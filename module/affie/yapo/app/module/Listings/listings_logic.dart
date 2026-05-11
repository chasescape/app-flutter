import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/photo_data.dart';

class ListingsLogic extends GetxController
    with GetSingleTickerProviderStateMixin {
  // ✅ 性能优化：移除静态数据的 .obs，这些数据不会变化，不需要响应式
  // 使用 getter 返回数据，避免不必要的响应式开销
  List<Map<String, dynamic>> get featuredPhotos =>
      PhotoDataSource.featuredPhotosMap;
  List<Map<String, dynamic>> get mockPhotos => PhotoDataSource.gridPhotosMap;
  Map<String, dynamic> get spotlightPhoto =>
      PhotoDataSource.spotlightPhoto.toMap();

  late AnimationController breathController;
  late Animation<double> breath;

  static const int carouselInitialPage = 10000;
  late PageController carouselPageController;
  // ✅ 性能优化：只保留真正需要响应式的变量
  final carouselCurrentPage = 10000.0.obs;

  // ✅ 性能优化：保存 PageController 监听器引用，用于正确释放
  VoidCallback? _pageControllerListener;
  
  // ✅ 性能优化：节流控制，避免频繁更新
  DateTime? _lastUpdateTime;
  static const _throttleDuration = Duration(milliseconds: 16); // ~60fps

  @override
  void onInit() {
    super.onInit();
    breathController = AnimationController(
      duration: const Duration(milliseconds: 2800),
      vsync: this,
    )..repeat(reverse: true);
    breath = Tween<double>(begin: 0.88, end: 1.12).animate(
      CurvedAnimation(parent: breathController, curve: Curves.easeInOut),
    );
    carouselPageController = PageController(
      viewportFraction: 0.6,
      initialPage: carouselInitialPage,
    );
    // ✅ 性能优化：保存监听器引用，确保可以正确移除
    // ✅ 性能优化：添加节流机制，避免过于频繁的更新
    _pageControllerListener = () {
      final now = DateTime.now();
      if (_lastUpdateTime == null ||
          now.difference(_lastUpdateTime!) >= _throttleDuration) {
        _lastUpdateTime = now;
        carouselCurrentPage.value =
            carouselPageController.page ?? carouselInitialPage.toDouble();
      }
    };
    carouselPageController.addListener(_pageControllerListener!);
  }

  @override
  void onClose() {
    // ✅ 性能优化：正确移除 PageController 监听器，避免内存泄漏
    if (_pageControllerListener != null) {
      carouselPageController.removeListener(_pageControllerListener!);
      _pageControllerListener = null;
    }
    breathController.dispose();
    carouselPageController.dispose();
    super.onClose();
  }

  // ✅ 性能优化：提供方法暂停/恢复呼吸动画，当页面不可见时暂停
  void pauseBreathAnimation() {
    if (breathController.isAnimating) {
      breathController.stop();
    }
  }

  void resumeBreathAnimation() {
    if (!breathController.isAnimating) {
      breathController.repeat(reverse: true);
    }
  }
}
