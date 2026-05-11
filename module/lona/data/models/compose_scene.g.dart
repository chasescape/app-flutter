// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'compose_scene.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ComposeScene _$ComposeSceneFromJson(Map<String, dynamic> json) => ComposeScene(
      id: json['id'] as String,
      assetImg: json['assetImg'] as String,
      oldAssetImgs: (json['oldAssetImgs'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      whyBetter: json['whyBetter'] as String,
      howItWorks: json['howItWorks'] as String,
    );

Map<String, dynamic> _$ComposeSceneToJson(ComposeScene instance) =>
    <String, dynamic>{
      'id': instance.id,
      'assetImg': instance.assetImg,
      'oldAssetImgs': instance.oldAssetImgs,
      'title': instance.title,
      'subtitle': instance.subtitle,
      'whyBetter': instance.whyBetter,
      'howItWorks': instance.howItWorks,
    };
