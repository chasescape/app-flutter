import 'package:flutter/material.dart';

class AppAssets {
  static const List<String> galleryImages = [
    'assets/bilra/1.jpg',
    'assets/bilra/2.jpg',
    'assets/bilra/3.jpg',
    'assets/bilra/4.jpg',
    'assets/bilra/5.jpg',
    'assets/bilra/6.jpg',
    'assets/bilra/7.jpg',
    'assets/bilra/8.jpg',
    'assets/bilra/9.jpg',
    'assets/bilra/10.jpg',
    'assets/bilra/11.jpg',
    'assets/bilra/12.jpg',
    'assets/bilra/13.jpg',
    'assets/bilra/14.jpg',
    'assets/bilra/15.jpg',
    'assets/bilra/16.jpg',
    'assets/bilra/17.jpg',
    'assets/bilra/18.jpg',
    'assets/bilra/19.jpg',
    'assets/bilra/20.jpg',
  ];

  static ImageProvider get loginBackground =>
      const AssetImage('assets/bilra/1.jpg');

  static String galleryAt(int index) {
    return galleryImages[index % galleryImages.length];
  }

  static bool isBundledGalleryAsset(String source) {
    return galleryImages.contains(source);
  }

  static String resolveDisplayImage(
    String? source, {
    int fallbackIndex = 0,
    bool preferIndexedGalleryForBundledAssets = false,
  }) {
    if (source == null || source.isEmpty || source.startsWith('A.')) {
      return galleryAt(fallbackIndex);
    }
    if (preferIndexedGalleryForBundledAssets && isBundledGalleryAsset(source)) {
      return galleryAt(fallbackIndex);
    }
    return source;
  }

  static bool isFilePath(String source) => source.startsWith('/');
}
