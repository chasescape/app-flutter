import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:yapo/yapo/app/module/Listings/listings_view.dart';
import 'package:yapo/yapo/app/module/history/history_view.dart';
import 'package:yapo/yapo/app/module/home/home_view.dart';
import 'package:yapo/yapo/app/module/profile/profile_view.dart';

/// 导航逻辑控制器
///
/// 性能优化：
/// - 页面缓存避免重复创建
/// - 减少内存占用
class NavLogic extends GetxController {
  final currentIndex = 0.obs;

  late final PageController pageController;

  late final List<Widget> pages;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    
    // 初始化页面列表
    pages = [
      const HomePage(),
      ListingsPage(),
      HistoryPage(),
      ProfilePage(),
    ];
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void changePage(int index) {
    if (index == currentIndex.value) return;

    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
    currentIndex.value = index;
  }
}
