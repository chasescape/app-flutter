import '../../../gen_a/A.dart';

/// 场景卡片属性值（带置信度和证据）
class SceneAttribute {
  final String value;
  final double confidence;
  final String evidence;

  SceneAttribute({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory SceneAttribute.fromJson(Map<String, dynamic> json) {
    return SceneAttribute(
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

/// 场景卡片数据
class SceneCardData {
  final SceneAttribute location;
  final SceneAttribute time;
  final SceneAttribute atmosphere;
  final SceneAttribute subject;
  final SceneAttribute mood;
  final SceneAttribute colorTone;

  SceneCardData({
    required this.location,
    required this.time,
    required this.atmosphere,
    required this.subject,
    required this.mood,
    required this.colorTone,
  });

  factory SceneCardData.fromJson(Map<String, dynamic> json) {
    return SceneCardData(
      location: SceneAttribute.fromJson(json['location'] as Map<String, dynamic>),
      time: SceneAttribute.fromJson(json['time'] as Map<String, dynamic>),
      atmosphere: SceneAttribute.fromJson(json['atmosphere'] as Map<String, dynamic>),
      subject: SceneAttribute.fromJson(json['subject'] as Map<String, dynamic>),
      mood: SceneAttribute.fromJson(json['mood'] as Map<String, dynamic>),
      colorTone: SceneAttribute.fromJson(json['color_tone'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location.toJson(),
      'time': time.toJson(),
      'atmosphere': atmosphere.toJson(),
      'subject': subject.toJson(),
      'mood': mood.toJson(),
      'color_tone': colorTone.toJson(),
    };
  }
}

/// 安全检查结果
class SafetyInfo {
  final bool hasSensitiveContent;
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

/// 完整的场景卡片模型
class SceneCard {
  /// 图片资源路径（A.dart 中的静态变量字符串）
  final String assetImg;

  /// 场景卡片数据
  final SceneCardData sceneCard;

  /// 视觉故事描述
  final String visualStory;

  /// 情绪关键词列表
  final List<String> emotionalKeywords;

  /// 建议的歌词风格
  final List<String> suggestedLyricStyles;

  /// 安全检查结果
  final SafetyInfo safety;

  SceneCard({
    required this.assetImg,
    required this.sceneCard,
    required this.visualStory,
    required this.emotionalKeywords,
    required this.suggestedLyricStyles,
    required this.safety,
  });

  factory SceneCard.fromJson(Map<String, dynamic> json) {
    return SceneCard(
      assetImg: json['assetImg'] as String,
      sceneCard: SceneCardData.fromJson(json['scene_card'] as Map<String, dynamic>),
      visualStory: json['visual_story'] as String,
      emotionalKeywords: (json['emotional_keywords'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      suggestedLyricStyles: (json['suggested_lyric_styles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      safety: SafetyInfo.fromJson(json['safety'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetImg': assetImg,
      'scene_card': sceneCard.toJson(),
      'visual_story': visualStory,
      'emotional_keywords': emotionalKeywords,
      'suggested_lyric_styles': suggestedLyricStyles,
      'safety': safety.toJson(),
    };
  }
}
