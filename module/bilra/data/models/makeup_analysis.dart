class MakeupAnalysis {
  final String assetImg;
  final FaceAnalysis faceAnalysis;
  final MakeupRecommendation makeupRecommendation;
  final SearchGuidance searchGuidance;
  final OccasionMatch occasionMatch;
  final QualityCheck qualityCheck;

  MakeupAnalysis({
    required this.assetImg,
    required this.faceAnalysis,
    required this.makeupRecommendation,
    required this.searchGuidance,
    required this.occasionMatch,
    required this.qualityCheck,
  });

  factory MakeupAnalysis.fromJson(Map<String, dynamic> json) {
    return MakeupAnalysis(
      assetImg: json['assetImg'] as String,
      faceAnalysis:
          FaceAnalysis.fromJson(json['face_analysis'] as Map<String, dynamic>),
      makeupRecommendation: MakeupRecommendation.fromJson(
          json['makeup_recommendation'] as Map<String, dynamic>),
      searchGuidance: SearchGuidance.fromJson(
          json['search_guidance'] as Map<String, dynamic>),
      occasionMatch: OccasionMatch.fromJson(
          json['occasion_match'] as Map<String, dynamic>),
      qualityCheck:
          QualityCheck.fromJson(json['quality_check'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetImg': assetImg,
      'face_analysis': faceAnalysis.toJson(),
      'makeup_recommendation': makeupRecommendation.toJson(),
      'search_guidance': searchGuidance.toJson(),
      'occasion_match': occasionMatch.toJson(),
      'quality_check': qualityCheck.toJson(),
    };
  }
}

class FaceAnalysis {
  final EyePresence eyePresence;
  final LipPresence lipPresence;
  final OverallVibe overallVibe;
  final SkinUndertone skinUndertone;
  final FaceStructure faceStructure;

  FaceAnalysis({
    required this.eyePresence,
    required this.lipPresence,
    required this.overallVibe,
    required this.skinUndertone,
    required this.faceStructure,
  });

  factory FaceAnalysis.fromJson(Map<String, dynamic> json) {
    return FaceAnalysis(
      eyePresence:
          EyePresence.fromJson(json['eye_presence'] as Map<String, dynamic>),
      lipPresence:
          LipPresence.fromJson(json['lip_presence'] as Map<String, dynamic>),
      overallVibe:
          OverallVibe.fromJson(json['overall_vibe'] as Map<String, dynamic>),
      skinUndertone: SkinUndertone.fromJson(
          json['skin_undertone'] as Map<String, dynamic>),
      faceStructure: FaceStructure.fromJson(
          json['face_structure'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'eye_presence': eyePresence.toJson(),
      'lip_presence': lipPresence.toJson(),
      'overall_vibe': overallVibe.toJson(),
      'skin_undertone': skinUndertone.toJson(),
      'face_structure': faceStructure.toJson(),
    };
  }
}

class EyePresence {
  final String value;
  final double confidence;
  final String evidence;

  EyePresence({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory EyePresence.fromJson(Map<String, dynamic> json) {
    return EyePresence(
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

class LipPresence {
  final String value;
  final double confidence;
  final String evidence;

  LipPresence({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory LipPresence.fromJson(Map<String, dynamic> json) {
    return LipPresence(
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

class OverallVibe {
  final String value;
  final double confidence;
  final String evidence;

  OverallVibe({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory OverallVibe.fromJson(Map<String, dynamic> json) {
    return OverallVibe(
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

class SkinUndertone {
  final String value;
  final double confidence;
  final String evidence;

  SkinUndertone({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory SkinUndertone.fromJson(Map<String, dynamic> json) {
    return SkinUndertone(
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

class FaceStructure {
  final String value;
  final double confidence;
  final String evidence;

  FaceStructure({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory FaceStructure.fromJson(Map<String, dynamic> json) {
    return FaceStructure(
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

class MakeupRecommendation {
  final String primaryStyle;
  final String styleTagline;
  final List<String> keywords;
  final String whyItWorks;
  final String startWithTip;

  MakeupRecommendation({
    required this.primaryStyle,
    required this.styleTagline,
    required this.keywords,
    required this.whyItWorks,
    required this.startWithTip,
  });

  factory MakeupRecommendation.fromJson(Map<String, dynamic> json) {
    return MakeupRecommendation(
      primaryStyle: json['primary_style'] as String,
      styleTagline: json['style_tagline'] as String,
      keywords: List<String>.from(json['keywords'] as List),
      whyItWorks: json['why_it_works'] as String,
      startWithTip: json['start_with_tip'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary_style': primaryStyle,
      'style_tagline': styleTagline,
      'keywords': keywords,
      'why_it_works': whyItWorks,
      'start_with_tip': startWithTip,
    };
  }
}

class SearchGuidance {
  final List<String> tutorialSearchTerms;
  final String copyableSearchPhrase;
  final List<String> recommendedPlatforms;

  SearchGuidance({
    required this.tutorialSearchTerms,
    required this.copyableSearchPhrase,
    required this.recommendedPlatforms,
  });

  factory SearchGuidance.fromJson(Map<String, dynamic> json) {
    return SearchGuidance(
      tutorialSearchTerms:
          List<String>.from(json['tutorial_search_terms'] as List),
      copyableSearchPhrase: json['copyable_search_phrase'] as String,
      recommendedPlatforms:
          List<String>.from(json['recommended_platforms'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tutorial_search_terms': tutorialSearchTerms,
      'copyable_search_phrase': copyableSearchPhrase,
      'recommended_platforms': recommendedPlatforms,
    };
  }
}

class OccasionMatch {
  final List<String> suitableOccasions;
  final String occasionNotes;

  OccasionMatch({
    required this.suitableOccasions,
    required this.occasionNotes,
  });

  factory OccasionMatch.fromJson(Map<String, dynamic> json) {
    return OccasionMatch(
      suitableOccasions: List<String>.from(json['suitable_occasions'] as List),
      occasionNotes: json['occasion_notes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'suitable_occasions': suitableOccasions,
      'occasion_notes': occasionNotes,
    };
  }
}

class QualityCheck {
  final bool isAnalyzable;
  final String retryReason;
  final String imageQualityNotes;

  QualityCheck({
    required this.isAnalyzable,
    required this.retryReason,
    required this.imageQualityNotes,
  });

  factory QualityCheck.fromJson(Map<String, dynamic> json) {
    return QualityCheck(
      isAnalyzable: json['is_analyzable'] as bool,
      retryReason: json['retry_reason'] as String,
      imageQualityNotes: json['image_quality_notes'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'is_analyzable': isAnalyzable,
      'retry_reason': retryReason,
      'image_quality_notes': imageQualityNotes,
    };
  }
}
