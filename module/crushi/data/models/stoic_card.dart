class TaggedField {
  final String value;
  final double confidence;
  final String? detail;

  const TaggedField({
    required this.value,
    required this.confidence,
    this.detail,
  });

  factory TaggedField.fromJson(Map<String, dynamic> json) {
    return TaggedField(
      value: json['value'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      detail: json['evidence'] as String? ?? json['reason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'confidence': confidence,
      if (detail != null) 'detail': detail,
    };
  }
}

class SceneCard {
  final TaggedField setting;
  final TaggedField timeOfDay;
  final TaggedField visualMood;
  final TaggedField stoicVirtue;
  final TaggedField humanPresence;
  final TaggedField natureRatio;
  final List<String> keyObjects;
  final List<String> dominantColors;
  final String lightQuality;

  const SceneCard({
    required this.setting,
    required this.timeOfDay,
    required this.visualMood,
    required this.stoicVirtue,
    required this.humanPresence,
    required this.natureRatio,
    required this.keyObjects,
    required this.dominantColors,
    required this.lightQuality,
  });

  factory SceneCard.fromJson(Map<String, dynamic> json) {
    return SceneCard(
      setting: TaggedField.fromJson(json['setting'] as Map<String, dynamic>),
      timeOfDay: TaggedField.fromJson(json['time_of_day'] as Map<String, dynamic>),
      visualMood: TaggedField.fromJson(json['visual_mood'] as Map<String, dynamic>),
      stoicVirtue: TaggedField.fromJson(json['stoic_virtue'] as Map<String, dynamic>),
      humanPresence: TaggedField.fromJson(json['human_presence'] as Map<String, dynamic>),
      natureRatio: TaggedField.fromJson(json['nature_ratio'] as Map<String, dynamic>),
      keyObjects: List<String>.from(json['key_objects'] as List),
      dominantColors: List<String>.from(json['dominant_colors'] as List),
      lightQuality: json['light_quality'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'setting': setting.toJson(),
      'time_of_day': timeOfDay.toJson(),
      'visual_mood': visualMood.toJson(),
      'stoic_virtue': stoicVirtue.toJson(),
      'human_presence': humanPresence.toJson(),
      'nature_ratio': natureRatio.toJson(),
      'key_objects': keyObjects,
      'dominant_colors': dominantColors,
      'light_quality': lightQuality,
    };
  }
}

class SafetyInfo {
  final bool hasSensitiveContent;
  final String notes;

  const SafetyInfo({
    required this.hasSensitiveContent,
    this.notes = '',
  });

  factory SafetyInfo.fromJson(Map<String, dynamic> json) {
    return SafetyInfo(
      hasSensitiveContent: json['has_sensitive_content'] as bool,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'has_sensitive_content': hasSensitiveContent,
      'notes': notes,
    };
  }
}

class StoicCard {
  final String assetImg;
  final SceneCard sceneCard;
  final String oneLineCapture;
  final List<String> tags;
  final SafetyInfo safety;

  const StoicCard({
    required this.assetImg,
    required this.sceneCard,
    required this.oneLineCapture,
    required this.tags,
    required this.safety,
  });

  factory StoicCard.fromJson(Map<String, dynamic> json, {required String assetImg}) {
    return StoicCard(
      assetImg: assetImg,
      sceneCard: SceneCard.fromJson(json['scene_card'] as Map<String, dynamic>),
      oneLineCapture: json['one_line_capture'] as String,
      tags: List<String>.from(json['tags'] as List),
      safety: SafetyInfo.fromJson(json['safety'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_img': assetImg,
      'scene_card': sceneCard.toJson(),
      'one_line_capture': oneLineCapture,
      'tags': tags,
      'safety': safety.toJson(),
    };
  }
}
