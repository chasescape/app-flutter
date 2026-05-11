
/// Scene card analysis data
class SceneCard {
  final String value;
  final double confidence;
  final String evidence;

  SceneCard({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory SceneCard.fromJson(Map<String, dynamic> json) {
    return SceneCard(
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

/// Cherish essay content
class CherishEssay {
  final String opening;
  final String feeling;
  final String gratitude;

  CherishEssay({
    required this.opening,
    required this.feeling,
    required this.gratitude,
  });

  factory CherishEssay.fromJson(Map<String, dynamic> json) {
    return CherishEssay(
      opening: json['opening'] as String,
      feeling: json['feeling'] as String,
      gratitude: json['gratitude'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'opening': opening,
      'feeling': feeling,
      'gratitude': gratitude,
    };
  }
}

/// Safety information
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

/// Daily Cherish Moment model
class CherishMoment {
  /// Image asset reference (required, using A.dart static variable)
  final String assetImg;

  /// Scene card analysis
  final SceneCard timeOfDay;
  final SceneCard sceneType;
  final SceneCard mainSubject;
  final SceneCard emotionalTone;
  final SceneCard lightingQuality;

  /// One line moment description
  final String oneLineMoment;

  /// Visual elements list
  final List<String> visualElements;

  /// Safety information
  final SafetyInfo safety;

  /// Cherish essay content
  final CherishEssay essay;

  /// Mood tags
  final List<String> moodTags;

  /// Visual style recommendation
  final String visualStyleRecommendation;

  /// Shareable caption
  final String shareableCaption;

  /// Card title
  final String cardTitle;

  CherishMoment({
    required this.assetImg,
    required this.timeOfDay,
    required this.sceneType,
    required this.mainSubject,
    required this.emotionalTone,
    required this.lightingQuality,
    required this.oneLineMoment,
    required this.visualElements,
    required this.safety,
    required this.essay,
    required this.moodTags,
    required this.visualStyleRecommendation,
    required this.shareableCaption,
    required this.cardTitle,
  });

  factory CherishMoment.fromJson(Map<String, dynamic> json) {
    final sceneCard = json['scene_card'] as Map<String, dynamic>;
    final cherishEssay = json['cherish_essay'] as Map<String, dynamic>;
    final safety = json['safety'] as Map<String, dynamic>;

    return CherishMoment(
      assetImg: json['asset_img'] as String,
      timeOfDay: SceneCard.fromJson(sceneCard['time_of_day'] as Map<String, dynamic>),
      sceneType: SceneCard.fromJson(sceneCard['scene_type'] as Map<String, dynamic>),
      mainSubject: SceneCard.fromJson(sceneCard['main_subject'] as Map<String, dynamic>),
      emotionalTone: SceneCard.fromJson(sceneCard['emotional_tone'] as Map<String, dynamic>),
      lightingQuality: SceneCard.fromJson(sceneCard['lighting_quality'] as Map<String, dynamic>),
      oneLineMoment: json['one_line_moment'] as String,
      visualElements: (json['visual_elements'] as List<dynamic>).cast<String>(),
      safety: SafetyInfo.fromJson(safety),
      essay: CherishEssay.fromJson(cherishEssay),
      moodTags: (json['mood_tags'] as List<dynamic>).cast<String>(),
      visualStyleRecommendation: json['visual_style_recommendation'] as String,
      shareableCaption: json['shareable_caption'] as String,
      cardTitle: json['card_title'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_img': assetImg,
      'scene_card': {
        'time_of_day': timeOfDay.toJson(),
        'scene_type': sceneType.toJson(),
        'main_subject': mainSubject.toJson(),
        'emotional_tone': emotionalTone.toJson(),
        'lighting_quality': lightingQuality.toJson(),
      },
      'one_line_moment': oneLineMoment,
      'visual_elements': visualElements,
      'safety': safety.toJson(),
      'cherish_essay': essay.toJson(),
      'mood_tags': moodTags,
      'visual_style_recommendation': visualStyleRecommendation,
      'shareable_caption': shareableCaption,
      'card_title': cardTitle,
    };
  }
}
