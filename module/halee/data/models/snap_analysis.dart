class SceneDimension {
  final String value;
  final double confidence;
  final String evidence;

  const SceneDimension({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory SceneDimension.fromJson(Map<String, dynamic> json) {
    return SceneDimension(
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

class SceneCard {
  final SceneDimension subjectType;
  final SceneDimension scene;
  final SceneDimension lighting;
  final SceneDimension composition;
  final SceneDimension colorTone;
  final SceneDimension atmosphere;

  const SceneCard({
    required this.subjectType,
    required this.scene,
    required this.lighting,
    required this.composition,
    required this.colorTone,
    required this.atmosphere,
  });

  factory SceneCard.fromJson(Map<String, dynamic> json) {
    return SceneCard(
      subjectType: SceneDimension.fromJson(json['subject_type']),
      scene: SceneDimension.fromJson(json['scene']),
      lighting: SceneDimension.fromJson(json['lighting']),
      composition: SceneDimension.fromJson(json['composition']),
      colorTone: SceneDimension.fromJson(json['color_tone']),
      atmosphere: SceneDimension.fromJson(json['atmosphere']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subject_type': subjectType.toJson(),
      'scene': scene.toJson(),
      'lighting': lighting.toJson(),
      'composition': composition.toJson(),
      'color_tone': colorTone.toJson(),
      'atmosphere': atmosphere.toJson(),
    };
  }
}

class Diagnosis {
  final String oneLineSummary;
  final List<String> strengths;
  final String topImprovement;

  const Diagnosis({
    required this.oneLineSummary,
    required this.strengths,
    required this.topImprovement,
  });

  factory Diagnosis.fromJson(Map<String, dynamic> json) {
    return Diagnosis(
      oneLineSummary: json['one_line_summary'] as String,
      strengths: (json['strengths'] as List<dynamic>).cast<String>(),
      topImprovement: json['top_improvement'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'one_line_summary': oneLineSummary,
      'strengths': strengths,
      'top_improvement': topImprovement,
    };
  }
}

class ImprovementTip {
  final String category;
  final String title;
  final String action;
  final String expectedResult;

  const ImprovementTip({
    required this.category,
    required this.title,
    required this.action,
    required this.expectedResult,
  });

  factory ImprovementTip.fromJson(Map<String, dynamic> json) {
    return ImprovementTip(
      category: json['category'] as String,
      title: json['title'] as String,
      action: json['action'] as String,
      expectedResult: json['expected_result'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'title': title,
      'action': action,
      'expected_result': expectedResult,
    };
  }
}

class CreativeVariant {
  final String style;
  final String description;
  final String executionTip;

  const CreativeVariant({
    required this.style,
    required this.description,
    required this.executionTip,
  });

  factory CreativeVariant.fromJson(Map<String, dynamic> json) {
    return CreativeVariant(
      style: json['style'] as String,
      description: json['description'] as String,
      executionTip: json['execution_tip'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'style': style,
      'description': description,
      'execution_tip': executionTip,
    };
  }
}

class SafetyInfo {
  final bool hasSensitiveContent;
  final String notes;

  const SafetyInfo({
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

class SnapAnalysis {
  final String assetImg;
  final DateTime? createdAt;
  final SceneCard sceneCard;
  final Diagnosis diagnosis;
  final List<ImprovementTip> improvementTips;
  final List<CreativeVariant> creativeVariants;
  final String funFact;
  final String shareCaption;
  final List<String> tags;
  final SafetyInfo safety;

  const SnapAnalysis({
    required this.assetImg,
    this.createdAt,
    required this.sceneCard,
    required this.diagnosis,
    required this.improvementTips,
    required this.creativeVariants,
    required this.funFact,
    required this.shareCaption,
    required this.tags,
    required this.safety,
  });

  factory SnapAnalysis.fromJson(Map<String, dynamic> json, {String? assetImg, DateTime? createdAt}) {
    return SnapAnalysis(
      assetImg: assetImg ?? (json['asset_img'] as String?) ?? '',
      createdAt: createdAt ?? (json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null),
      sceneCard: SceneCard.fromJson(json['scene_card']),
      diagnosis: Diagnosis.fromJson(json['diagnosis']),
      improvementTips: (json['improvement_tips'] as List<dynamic>)
          .map((e) => ImprovementTip.fromJson(e as Map<String, dynamic>))
          .toList(),
      creativeVariants: (json['creative_variants'] as List<dynamic>)
          .map((e) => CreativeVariant.fromJson(e as Map<String, dynamic>))
          .toList(),
      funFact: json['fun_fact'] as String,
      shareCaption: json['share_caption'] as String,
      tags: (json['tags'] as List<dynamic>).cast<String>(),
      safety: SafetyInfo.fromJson(json['safety']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_img': assetImg,
      'created_at': createdAt?.toIso8601String(),
      'scene_card': sceneCard.toJson(),
      'diagnosis': diagnosis.toJson(),
      'improvement_tips': improvementTips.map((e) => e.toJson()).toList(),
      'creative_variants': creativeVariants.map((e) => e.toJson()).toList(),
      'fun_fact': funFact,
      'share_caption': shareCaption,
      'tags': tags,
      'safety': safety.toJson(),
    };
  }
}
