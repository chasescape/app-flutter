import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NavLogic extends GetxController with GetSingleTickerProviderStateMixin {
  static NavLogic get to => Get.find<NavLogic>();
  
  String currentRoute = '';
  final currentIndex = 0.obs;
  
  late AnimationController slideController;
  late Animation<double> slideAnimation;

  final routes = [
    '/home',
    '/generate',
    '/profile',
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeRoute();
    
    // 初始化滑动动画控制器
    slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // 设置初始动画值
    slideAnimation = Tween<double>(
      begin: currentIndex.value.toDouble(),
      end: currentIndex.value.toDouble(),
    ).animate(CurvedAnimation(
      parent: slideController,
      curve: Curves.easeInOut,
    ));
    
    // 立即设置到初始位置
    slideController.value = 1.0;
  }
  
  void _initializeRoute() {
    currentRoute = Get.currentRoute;
    final initialIndex = routes.indexOf(currentRoute);
    currentIndex.value = initialIndex >= 0 ? initialIndex : 0;
  }
  
  // 页面切换后更新状态
  void updateRoute(String route) {
    if (currentRoute != route) {
      currentRoute = route;
      final newIndex = routes.indexOf(route);
      if (newIndex >= 0) {
        final oldIndex = currentIndex.value;
        
        // 更新动画
        slideAnimation = Tween<double>(
          begin: oldIndex.toDouble(),
          end: newIndex.toDouble(),
        ).animate(CurvedAnimation(
          parent: slideController,
          curve: Curves.easeInOut,
        ));
        
        // 重置并启动动画
        slideController.reset();
        slideController.forward();
        
        currentIndex.value = newIndex;
      }
      update();
    }
  }

  void navigateTo(String route, int index) {
    if (currentRoute != route) {
      final oldIndex = currentIndex.value;
      
      // 更新动画
      slideAnimation = Tween<double>(
        begin: oldIndex.toDouble(),
        end: index.toDouble(),
      ).animate(CurvedAnimation(
        parent: slideController,
        curve: Curves.easeInOut,
      ));
      
      // 重置并启动动画
      slideController.reset();
      slideController.forward();
      
      currentIndex.value = index;
      currentRoute = route;
      
      // 使用Get.toNamed而不是Get.offAllNamed，避免销毁NavLogic
      Get.toNamed(route);
      update();
    }
  }

  bool isActive(String route) {
    return currentRoute == route;
  }
  
  int getRouteIndex(String route) {
    final index = routes.indexOf(route);
    return index >= 0 ? index : 0;
  }

  @override
  void onClose() {
    slideController.dispose();
    super.onClose();
  }
}

class NavItemLogic extends GetxController with GetSingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation<Offset> slideAnimation;

  @override
  void onInit() {
    super.onInit();
    animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    slideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animationController,
      curve: Curves.easeInOut,
    ));
  }

  void setActive(bool isActive) {
    // 确保动画控制器还未被销毁
    if (isClosed) return;
    
    if (isActive) {
      animationController.forward();
    } else {
      animationController.reverse();
    }
  }

  @override
  void onClose() {
    animationController.dispose();
    super.onClose();
  }
}
