import 'dart:convert';

/// SparkFlow 灵感结果模型
class SparkResult {
  /// 场景卡片分析
  final SceneCard sceneCard;

  /// 一句话总结
  final String oneLineSummary;

  /// 标签列表
  final List<String> tags;

  /// 安全信息
  final SafetyInfo safety;

  /// 灵感点子列表
  final List<Idea> ideas;

  /// 图片资源路径 (A.dart 中的静态变量)
  String assetImg;

  /// 图片路径（本地或网络）
  String? imagePath;

  /// 创建时间
  final DateTime createdAt;

  SparkResult({
    required this.sceneCard,
    required this.oneLineSummary,
    required this.tags,
    required this.safety,
    required this.ideas,
    this.assetImg = '',
    this.imagePath,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory SparkResult.fromJson(Map<String, dynamic> json) {
    return SparkResult(
      sceneCard: SceneCard.fromJson(json['scene_card'] as Map<String, dynamic>),
      oneLineSummary: json['one_line_summary'] as String,
      tags: (json['tags'] as List).map((e) => e as String).toList(),
      safety: SafetyInfo.fromJson(json['safety'] as Map<String, dynamic>),
      ideas: (json['ideas'] as List)
          .map((e) => Idea.fromJson(e as Map<String, dynamic>))
          .toList(),
      assetImg: json['asset_img'] as String? ?? '',
      imagePath: json['image_path'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'scene_card': sceneCard.toJson(),
      'one_line_summary': oneLineSummary,
      'tags': tags,
      'safety': safety.toJson(),
      'ideas': ideas.map((e) => e.toJson()).toList(),
      'asset_img': assetImg,
      'image_path': imagePath,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String toJsonString() => jsonEncode(toJson());

  /// 生成用于展示的唯一 ID
  String get id => '${createdAt.millisecondsSinceEpoch}';
}

/// 场景卡片
class SceneCard {
  /// 视觉主体
  final ConfidenceValue visualSubject;

  /// 氛围特征
  final ConfidenceValue atmosphere;

  /// 灵感维度
  final ConfidenceValue inspirationDimension;

  SceneCard({
    required this.visualSubject,
    required this.atmosphere,
    required this.inspirationDimension,
  });

  factory SceneCard.fromJson(Map<String, dynamic> json) {
    return SceneCard(
      visualSubject: ConfidenceValue.fromJson(
          json['visual_subject'] as Map<String, dynamic>),
      atmosphere:
          ConfidenceValue.fromJson(json['atmosphere'] as Map<String, dynamic>),
      inspirationDimension: ConfidenceValue.fromJson(
          json['inspiration_dimension'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visual_subject': visualSubject.toJson(),
      'atmosphere': atmosphere.toJson(),
      'inspiration_dimension': inspirationDimension.toJson(),
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

/// 安全信息
class SafetyInfo {
  /// 是否包含敏感内容
  final bool hasSensitiveContent;

  /// 备注
  final String notes;

  SafetyInfo({
    required this.hasSensitiveContent,
    required this.notes,
  });

  factory SafetyInfo.fromJson(Map<String, dynamic> json) {
    return SafetyInfo(
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

/// 灵感点子
class Idea {
  /// 标题
  final String title;

  /// 执行方向列表
  final List<String> executionDirection;

  /// 应用场景
  final String applicationScenario;

  /// 维度
  final String dimension;

  Idea({
    required this.title,
    required this.executionDirection,
    required this.applicationScenario,
    required this.dimension,
  });

  factory Idea.fromJson(Map<String, dynamic> json) {
    return Idea(
      title: json['title'] as String,
      executionDirection: (json['execution_direction'] as List)
          .map((e) => e as String)
          .toList(),
      applicationScenario: json['application_scenario'] as String,
      dimension: json['dimension'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'execution_direction': executionDirection,
      'application_scenario': applicationScenario,
      'dimension': dimension,
    };
  }
}
