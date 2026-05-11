import 'dart:convert';
import 'package:minne/gen_a/A.dart';

/// CherishLens - 每日小确幸卡片数据模型
class CherishCard {
  /// 卡片唯一标识
  final String id;

  /// 图片资源路径（对应 A.dart 中的静态变量）
  final String assetImg;

  /// 场景卡片数据
  final SceneCard sceneCard;

  /// 视觉诗意内容
  final VisualPoetry visualPoetry;

  /// 元数据
  final Meta meta;

  CherishCard({
    required this.id,
    required this.assetImg,
    required this.sceneCard,
    required this.visualPoetry,
    required this.meta,
  });

  factory CherishCard.fromJson(Map<String, dynamic> json, {required String assetImg}) {
    return CherishCard(
      id: json['id'] as String? ?? _generateId(),
      assetImg: assetImg,
      sceneCard: SceneCard.fromJson(json['scene_card'] as Map<String, dynamic>),
      visualPoetry: VisualPoetry.fromJson(json['visual_poetry'] as Map<String, dynamic>),
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  static String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'assetImg': assetImg,
      'scene_card': sceneCard.toJson(),
      'visual_poetry': visualPoetry.toJson(),
      'meta': meta.toJson(),
    };
  }

  /// Create CherishCard from JSON map with assetImg
  static CherishCard fromJsonMap(Map<String, dynamic> json, {required String assetImg}) {
    return CherishCard(
      id: json['id'] as String? ?? _generateId(),
      assetImg: json['assetImg'] as String? ?? assetImg,
      sceneCard: SceneCard.fromJson(json['scene_card'] as Map<String, dynamic>),
      visualPoetry: VisualPoetry.fromJson(json['visual_poetry'] as Map<String, dynamic>),
      meta: Meta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  /// Convert to storage format (JSON string with embedded assetImg)
  String toStorageJson() {
    return jsonEncode(toJson());
  }

  /// Create from storage format
  static CherishCard fromStorageJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return fromJsonMap(json, assetImg: json['assetImg'] as String);
  }
}

/// 场景卡片
class SceneCard {
  /// 时间氛围
  final ConfidenceValue timeAtmosphere;

  /// 场景类型
  final ConfidenceValue sceneType;

  /// 主体对象
  final ConfidenceValue primarySubject;

  /// 情绪基调
  final ConfidenceValue moodTone;

  /// 光线质量
  final ConfidenceValue lightQuality;

  /// 色温
  final ConfidenceValue colorTemperature;

  SceneCard({
    required this.timeAtmosphere,
    required this.sceneType,
    required this.primarySubject,
    required this.moodTone,
    required this.lightQuality,
    required this.colorTemperature,
  });

  factory SceneCard.fromJson(Map<String, dynamic> json) {
    return SceneCard(
      timeAtmosphere: ConfidenceValue.fromJson(json['time_atmosphere'] as Map<String, dynamic>),
      sceneType: ConfidenceValue.fromJson(json['scene_type'] as Map<String, dynamic>),
      primarySubject: ConfidenceValue.fromJson(json['primary_subject'] as Map<String, dynamic>),
      moodTone: ConfidenceValue.fromJson(json['mood_tone'] as Map<String, dynamic>),
      lightQuality: ConfidenceValue.fromJson(json['light_quality'] as Map<String, dynamic>),
      colorTemperature: ConfidenceValue.fromJson(json['color_temperature'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_atmosphere': timeAtmosphere.toJson(),
      'scene_type': sceneType.toJson(),
      'primary_subject': primarySubject.toJson(),
      'mood_tone': moodTone.toJson(),
      'light_quality': lightQuality.toJson(),
      'color_temperature': colorTemperature.toJson(),
    };
  }
}

/// 带置信度的值
class ConfidenceValue {
  /// 值
  final String value;

  /// 置信度
  final double confidence;

  /// 证据/说明
  final String evidence;

  ConfidenceValue({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory ConfidenceValue.fromJson(Map<String, dynamic> json) {
    return ConfidenceValue(
      value: json['value'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      evidence: json['evidence'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'confidence': confidence,
      'evidence': evidence,
    };
  }
}

/// 视觉诗意内容
class VisualPoetry {
  /// 治愈短文
  final String shortHealingText;

  /// 每日寄语
  final String dailyAffirmation;

  /// 珍视标签
  final List<String> cherishTags;

  VisualPoetry({
    required this.shortHealingText,
    required this.dailyAffirmation,
    required this.cherishTags,
  });

  factory VisualPoetry.fromJson(Map<String, dynamic> json) {
    return VisualPoetry(
      shortHealingText: json['short_healing_text'] as String,
      dailyAffirmation: json['daily_affirmation'] as String,
      cherishTags: (json['cherish_tags'] as List<dynamic>).cast<String>(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'short_healing_text': shortHealingText,
      'daily_affirmation': dailyAffirmation,
      'cherish_tags': cherishTags,
    };
  }
}

/// 元数据
class Meta {
  /// 卡片唯一标识
  final String id;

  /// 一句话描述
  final String oneLineMoment;

  /// 点赞数
  final int likeCount;

  /// 安全信息
  final Safety safety;

  Meta({
    required this.id,
    required this.oneLineMoment,
    this.likeCount = 0,
    required this.safety,
  });

  factory Meta.fromJson(Map<String, dynamic> json) {
    return Meta(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      oneLineMoment: json['one_line_moment'] as String,
      likeCount: json['like_count'] as int? ?? 0,
      safety: Safety.fromJson(json['safety'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'one_line_moment': oneLineMoment,
      'like_count': likeCount,
      'safety': safety.toJson(),
    };
  }
}

/// 安全信息
class Safety {
  /// 是否包含敏感内容
  final bool hasSensitiveContent;

  /// 备注
  final String notes;

  Safety({
    required this.hasSensitiveContent,
    required this.notes,
  });

  factory Safety.fromJson(Map<String, dynamic> json) {
    return Safety(
      hasSensitiveContent: json['has_sensitive_content'] as bool,
      notes: json['notes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_sensitive_content': hasSensitiveContent,
      'notes': notes,
    };
  }
}
