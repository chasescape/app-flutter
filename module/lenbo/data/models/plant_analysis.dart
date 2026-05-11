class PlantId {
  final String commonName;
  final String scientificName;
  final String family;
  final List<String> otherNames;
  final double identificationConfidence;
  final String funFact;

  const PlantId({
    required this.commonName,
    required this.scientificName,
    required this.family,
    this.otherNames = const [],
    required this.identificationConfidence,
    required this.funFact,
  });

  factory PlantId.fromJson(Map<String, dynamic> json) {
    return PlantId(
      commonName: json['common_name'] as String? ?? '',
      scientificName: json['scientific_name'] as String? ?? '',
      family: json['family'] as String? ?? '',
      otherNames: (json['other_names'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      identificationConfidence:
          (json['identification_confidence'] as num?)?.toDouble() ?? 0.0,
      funFact: json['fun_fact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'common_name': commonName,
        'scientific_name': scientificName,
        'family': family,
        'other_names': otherNames,
        'identification_confidence': identificationConfidence,
        'fun_fact': funFact,
      };
}

class HealthCheck {
  final String status;
  final double confidence;
  final String visualEvidence;
  final List<String> symptoms;
  final String overallImpression;

  const HealthCheck({
    required this.status,
    required this.confidence,
    required this.visualEvidence,
    this.symptoms = const [],
    required this.overallImpression,
  });

  factory HealthCheck.fromJson(Map<String, dynamic> json) {
    return HealthCheck(
      status: json['status'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      visualEvidence: json['visual_evidence'] as String? ?? '',
      symptoms: (json['symptoms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      overallImpression: json['overall_impression'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status,
        'confidence': confidence,
        'visual_evidence': visualEvidence,
        'symptoms': symptoms,
        'overall_impression': overallImpression,
      };
}

class EnvironmentReading {
  final String lightEnv;
  final String soilMoistureVisual;
  final String potTypeGuess;
  final String indoorOrOutdoor;

  const EnvironmentReading({
    required this.lightEnv,
    required this.soilMoistureVisual,
    required this.potTypeGuess,
    required this.indoorOrOutdoor,
  });

  factory EnvironmentReading.fromJson(Map<String, dynamic> json) {
    return EnvironmentReading(
      lightEnv: json['light_env'] as String? ?? '',
      soilMoistureVisual: json['soil_moisture_visual'] as String? ?? '',
      potTypeGuess: json['pot_type_guess'] as String? ?? '',
      indoorOrOutdoor: json['indoor_or_outdoor'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'light_env': lightEnv,
        'soil_moisture_visual': soilMoistureVisual,
        'pot_type_guess': potTypeGuess,
        'indoor_or_outdoor': indoorOrOutdoor,
      };
}

class GrowthInfo {
  final String stage;
  final String difficultyLevel;
  final String expectedLifespan;
  final String maxHeight;

  const GrowthInfo({
    required this.stage,
    required this.difficultyLevel,
    required this.expectedLifespan,
    required this.maxHeight,
  });

  factory GrowthInfo.fromJson(Map<String, dynamic> json) {
    return GrowthInfo(
      stage: json['stage'] as String? ?? '',
      difficultyLevel: json['difficulty_level'] as String? ?? '',
      expectedLifespan: json['expected_lifespan'] as String? ?? '',
      maxHeight: json['max_height'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'stage': stage,
        'difficulty_level': difficultyLevel,
        'expected_lifespan': expectedLifespan,
        'max_height': maxHeight,
      };
}

class WateringGuide {
  final String frequency;
  final String method;
  final String seasonalNote;

  const WateringGuide({
    required this.frequency,
    required this.method,
    required this.seasonalNote,
  });

  factory WateringGuide.fromJson(Map<String, dynamic> json) {
    return WateringGuide(
      frequency: json['frequency'] as String? ?? '',
      method: json['method'] as String? ?? '',
      seasonalNote: json['seasonal_note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'frequency': frequency,
        'method': method,
        'seasonal_note': seasonalNote,
      };
}

class LightGuide {
  final String idealCondition;
  final String currentAssessment;
  final String adjustmentTip;

  const LightGuide({
    required this.idealCondition,
    required this.currentAssessment,
    required this.adjustmentTip,
  });

  factory LightGuide.fromJson(Map<String, dynamic> json) {
    return LightGuide(
      idealCondition: json['ideal_condition'] as String? ?? '',
      currentAssessment: json['current_assessment'] as String? ?? '',
      adjustmentTip: json['adjustment_tip'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'ideal_condition': idealCondition,
        'current_assessment': currentAssessment,
        'adjustment_tip': adjustmentTip,
      };
}

class FertilizingGuide {
  final String schedule;
  final String recommendedType;
  final String seasonalNote;

  const FertilizingGuide({
    required this.schedule,
    required this.recommendedType,
    required this.seasonalNote,
  });

  factory FertilizingGuide.fromJson(Map<String, dynamic> json) {
    return FertilizingGuide(
      schedule: json['schedule'] as String? ?? '',
      recommendedType: json['recommended_type'] as String? ?? '',
      seasonalNote: json['seasonal_note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'schedule': schedule,
        'recommended_type': recommendedType,
        'seasonal_note': seasonalNote,
      };
}

class TemperatureGuide {
  final String idealRange;
  final String tolerance;

  const TemperatureGuide({
    required this.idealRange,
    required this.tolerance,
  });

  factory TemperatureGuide.fromJson(Map<String, dynamic> json) {
    return TemperatureGuide(
      idealRange: json['ideal_range'] as String? ?? '',
      tolerance: json['tolerance'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'ideal_range': idealRange,
        'tolerance': tolerance,
      };
}

class HumidityGuide {
  final String idealLevel;
  final List<String> boostMethods;

  const HumidityGuide({
    required this.idealLevel,
    this.boostMethods = const [],
  });

  factory HumidityGuide.fromJson(Map<String, dynamic> json) {
    return HumidityGuide(
      idealLevel: json['ideal_level'] as String? ?? '',
      boostMethods: (json['boost_methods'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
        'ideal_level': idealLevel,
        'boost_methods': boostMethods,
      };
}

class CareGuide {
  final String summary;
  final WateringGuide watering;
  final LightGuide light;
  final FertilizingGuide fertilizing;
  final TemperatureGuide temperature;
  final HumidityGuide humidity;

  const CareGuide({
    required this.summary,
    required this.watering,
    required this.light,
    required this.fertilizing,
    required this.temperature,
    required this.humidity,
  });

  factory CareGuide.fromJson(Map<String, dynamic> json) {
    return CareGuide(
      summary: json['summary'] as String? ?? '',
      watering: WateringGuide.fromJson(
          json['watering'] as Map<String, dynamic>? ?? {}),
      light: LightGuide.fromJson(json['light'] as Map<String, dynamic>? ?? {}),
      fertilizing: FertilizingGuide.fromJson(
          json['fertilizing'] as Map<String, dynamic>? ?? {}),
      temperature: TemperatureGuide.fromJson(
          json['temperature'] as Map<String, dynamic>? ?? {}),
      humidity: HumidityGuide.fromJson(
          json['humidity'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'watering': watering.toJson(),
        'light': light.toJson(),
        'fertilizing': fertilizing.toJson(),
        'temperature': temperature.toJson(),
        'humidity': humidity.toJson(),
      };
}

class CommonIssue {
  final String problem;
  final String cause;
  final String prevention;
  final String fix;

  const CommonIssue({
    required this.problem,
    required this.cause,
    required this.prevention,
    required this.fix,
  });

  factory CommonIssue.fromJson(Map<String, dynamic> json) {
    return CommonIssue(
      problem: json['problem'] as String? ?? '',
      cause: json['cause'] as String? ?? '',
      prevention: json['prevention'] as String? ?? '',
      fix: json['fix'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'problem': problem,
        'cause': cause,
        'prevention': prevention,
        'fix': fix,
      };
}

class SafetyInfo {
  final String toxicityNote;
  final bool petSafe;
  final bool hasSensitiveContent;
  final String notes;

  const SafetyInfo({
    required this.toxicityNote,
    required this.petSafe,
    required this.hasSensitiveContent,
    required this.notes,
  });

  factory SafetyInfo.fromJson(Map<String, dynamic> json) {
    return SafetyInfo(
      toxicityNote: json['toxicity_note'] as String? ?? '',
      petSafe: json['pet_safe'] as bool? ?? false,
      hasSensitiveContent: json['has_sensitive_content'] as bool? ?? false,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'toxicity_note': toxicityNote,
        'pet_safe': petSafe,
        'has_sensitive_content': hasSensitiveContent,
        'notes': notes,
      };
}

class PlantAnalysis {
  final String assetImg;
  final PlantId plantId;
  final HealthCheck healthCheck;
  final EnvironmentReading environmentReading;
  final GrowthInfo growthInfo;
  final CareGuide careGuide;
  final List<CommonIssue> commonIssues;
  final String proTip;
  final String plantPersonality;
  final SafetyInfo safety;

  const PlantAnalysis({
    required this.assetImg,
    required this.plantId,
    required this.healthCheck,
    required this.environmentReading,
    required this.growthInfo,
    required this.careGuide,
    this.commonIssues = const [],
    required this.proTip,
    required this.plantPersonality,
    required this.safety,
  });

  factory PlantAnalysis.fromJson(Map<String, dynamic> json) {
    return PlantAnalysis(
      assetImg: json['assetImg'] as String? ?? '',
      plantId:
          PlantId.fromJson(json['plant_id'] as Map<String, dynamic>? ?? {}),
      healthCheck: HealthCheck.fromJson(
          json['health_check'] as Map<String, dynamic>? ?? {}),
      environmentReading: EnvironmentReading.fromJson(
          json['environment_reading'] as Map<String, dynamic>? ?? {}),
      growthInfo:
          GrowthInfo.fromJson(json['growth_info'] as Map<String, dynamic>? ?? {}),
      careGuide:
          CareGuide.fromJson(json['care_guide'] as Map<String, dynamic>? ?? {}),
      commonIssues: (json['common_issues'] as List<dynamic>?)
              ?.map(
                  (e) => CommonIssue.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      proTip: json['pro_tip'] as String? ?? '',
      plantPersonality: json['plant_personality'] as String? ?? '',
      safety:
          SafetyInfo.fromJson(json['safety'] as Map<String, dynamic>? ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
        'assetImg': assetImg,
        'plant_id': plantId.toJson(),
        'health_check': healthCheck.toJson(),
        'environment_reading': environmentReading.toJson(),
        'growth_info': growthInfo.toJson(),
        'care_guide': careGuide.toJson(),
        'common_issues': commonIssues.map((e) => e.toJson()).toList(),
        'pro_tip': proTip,
        'plant_personality': plantPersonality,
        'safety': safety.toJson(),
      };

  PlantAnalysis copyWith({String? assetImg}) {
    return PlantAnalysis(
      assetImg: assetImg ?? this.assetImg,
      plantId: plantId,
      healthCheck: healthCheck,
      environmentReading: environmentReading,
      growthInfo: growthInfo,
      careGuide: careGuide,
      commonIssues: commonIssues,
      proTip: proTip,
      plantPersonality: plantPersonality,
      safety: safety,
    );
  }
}
