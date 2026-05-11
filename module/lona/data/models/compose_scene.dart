import 'package:json_annotation/json_annotation.dart';

part 'compose_scene.g.dart';

@JsonSerializable()
class ComposeScene {
  final String id;
  final String assetImg;
  final List<String> oldAssetImgs;
  final String title;
  final String subtitle;
  final String whyBetter;
  final String howItWorks;

  ComposeScene({
    required this.id,
    required this.assetImg,
    required this.oldAssetImgs,
    required this.title,
    required this.subtitle,
    required this.whyBetter,
    required this.howItWorks,
  });

  factory ComposeScene.fromJson(Map<String, dynamic> json) =>
      _$ComposeSceneFromJson(json);

  Map<String, dynamic> toJson() => _$ComposeSceneToJson(this);
}
