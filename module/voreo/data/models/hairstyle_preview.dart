import 'package:voreo/voreo/A.dart';

class HairstylePreview {
  final String id;
  final String assetImg;
  final List<String> oldAssetImgs;
  final String title;
  final String subtitle;
  final String whyBetter;
  final String howItWorks;
  final String? featureHighlight;
  final String? maintenanceLevel;
  final String? bestFor;

  HairstylePreview({
    required this.id,
    required this.assetImg,
    required this.oldAssetImgs,
    required this.title,
    required this.subtitle,
    required this.whyBetter,
    required this.howItWorks,
    this.featureHighlight,
    this.maintenanceLevel,
    this.bestFor,
  });

  factory HairstylePreview.fromJson(Map<String, dynamic> json) {
    return HairstylePreview(
      id: json['id'] as String,
      assetImg: json['asset_img'] as String,
      oldAssetImgs: (json['old_asset_imgs'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      whyBetter: json['why_better'] as String,
      howItWorks: json['how_it_works'] as String,
      featureHighlight: json['feature_highlight'] as String?,
      maintenanceLevel: json['maintenance_level'] as String?,
      bestFor: json['best_for'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'asset_img': assetImg,
      'old_asset_imgs': oldAssetImgs,
      'title': title,
      'subtitle': subtitle,
      'why_better': whyBetter,
      'how_it_works': howItWorks,
      'feature_highlight': featureHighlight,
      'maintenance_level': maintenanceLevel,
      'best_for': bestFor,
    };
  }
}
