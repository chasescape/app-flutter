import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/photo_data.dart';

class HomeLogic extends GetxController {
  late PageController pageController;
  late List<CardData> cards;

  final expandedIndex = Rxn<int>(); // 使用 Rxn 表示可为 null 的响应式变量
  final showSwipeHint = true.obs;

  static const List<LinearGradient> cardGradients = [
    LinearGradient(colors: [Color(0xFFf472b6), Color(0xFFec4899)]),
    LinearGradient(colors: [Color(0xFF8b5cf6), Color(0xFFa855f7)]),
    LinearGradient(colors: [Color(0xFFf59e0b), Color(0xFFef4444)]),
    LinearGradient(colors: [Color(0xFF06b6d4), Color(0xFF3b82f6)]),
    LinearGradient(colors: [Color(0xFFec4899), Color(0xFF8b5cf6)]),
    LinearGradient(colors: [Color(0xFFf472b6), Color(0xFFfbbf24)]),
    LinearGradient(colors: [Color(0xFFa855f7), Color(0xFFec4899)]),
    LinearGradient(colors: [Color(0xFF6366f1), Color(0xFF8b5cf6)]),
  ];

  @override
  void onInit() {
    super.onInit();
    pageController = PageController();
    _initializeCards();
  }

  void _initializeCards() {
    final photos = PhotoDataSource.allPhotos;
    cards = List.generate(
      photos.length,
      (i) {
        final photo = photos[i];
        return CardData(
          id: photo.id,
          title: photo.title,
          subtitle: '${photo.location} • ${photo.date}',
          image: photo.imagePath,
          gradient: cardGradients[i % cardGradients.length],
        );
      },
    );
  }

  void expandCard(int index) {
    expandedIndex.value = index;
    // 延迟跳转，确保 PageController 已经初始化
    Future.delayed(const Duration(milliseconds: 50), () {
      if (pageController.hasClients) {
        pageController.jumpToPage(index);
      }
    });
  }

  void collapseCard() {
    expandedIndex.value = null;
  }

  void onPageChanged(int index) {
    expandedIndex.value = index;
  }

  void hideSwipeHint() {
    showSwipeHint.value = false;
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

// Card data model
class CardData {
  final String? id;
  final String title;
  final String subtitle;
  final String image;
  final Gradient gradient;

  CardData({
    this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.gradient,
  });
}
