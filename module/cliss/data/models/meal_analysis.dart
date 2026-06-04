class MealAnalysis {
  final String assetImg;
  final String createdAt;
  final SceneCard sceneCard;
  final NutritionAnalysis nutritionAnalysis;
  final NextMealSuggestion nextMealSuggestion;
  final NextBreakfastSuggestion nextBreakfastSuggestion;
  final String oneLineSummary;
  final List<String> tags;
  final double confidence;

  MealAnalysis({
    required this.assetImg,
    this.createdAt = '',
    required this.sceneCard,
    required this.nutritionAnalysis,
    required this.nextMealSuggestion,
    required this.nextBreakfastSuggestion,
    required this.oneLineSummary,
    required this.tags,
    required this.confidence,
  });

  factory MealAnalysis.fromJson(Map<String, dynamic> json) {
    return MealAnalysis(
      assetImg: json['asset_img'] ?? '',
      createdAt: json['created_at'] ?? '',
      sceneCard: SceneCard.fromJson(json['scene_card']),
      nutritionAnalysis: NutritionAnalysis.fromJson(json['nutrition_analysis']),
      nextMealSuggestion: NextMealSuggestion.fromJson(json['next_meal_suggestion']),
      nextBreakfastSuggestion: NextBreakfastSuggestion.fromJson(json['next_breakfast_suggestion']),
      oneLineSummary: json['one_line_summary'] ?? '',
      tags: List<String>.from(json['tags'] ?? []),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'asset_img': assetImg,
      'created_at': createdAt,
      'scene_card': sceneCard.toJson(),
      'nutrition_analysis': nutritionAnalysis.toJson(),
      'next_meal_suggestion': nextMealSuggestion.toJson(),
      'next_breakfast_suggestion': nextBreakfastSuggestion.toJson(),
      'one_line_summary': oneLineSummary,
      'tags': tags,
      'confidence': confidence,
    };
  }
}

class SceneCard {
  final String mealType;
  final List<String> mainItems;
  final String estimatedPortion;
  final String oilLevel;
  final String balanceTag;
  final String visualDescription;

  SceneCard({
    required this.mealType,
    required this.mainItems,
    required this.estimatedPortion,
    required this.oilLevel,
    required this.balanceTag,
    required this.visualDescription,
  });

  factory SceneCard.fromJson(Map<String, dynamic> json) {
    return SceneCard(
      mealType: json['meal_type'] ?? '',
      mainItems: List<String>.from(json['main_items'] ?? []),
      estimatedPortion: json['estimated_portion'] ?? '',
      oilLevel: json['oil_level'] ?? '',
      balanceTag: json['balance_tag'] ?? '',
      visualDescription: json['visual_description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_type': mealType,
      'main_items': mainItems,
      'estimated_portion': estimatedPortion,
      'oil_level': oilLevel,
      'balance_tag': balanceTag,
      'visual_description': visualDescription,
    };
  }
}

class NutritionAnalysis {
  final CalorieEstimate calorieEstimate;
  final String proteinNote;
  final String carbNote;
  final String fatNote;
  final String overallBalanceSummary;

  NutritionAnalysis({
    required this.calorieEstimate,
    required this.proteinNote,
    required this.carbNote,
    required this.fatNote,
    required this.overallBalanceSummary,
  });

  factory NutritionAnalysis.fromJson(Map<String, dynamic> json) {
    return NutritionAnalysis(
      calorieEstimate: CalorieEstimate.fromJson(json['calorie_estimate']),
      proteinNote: json['protein_note'] ?? '',
      carbNote: json['carb_note'] ?? '',
      fatNote: json['fat_note'] ?? '',
      overallBalanceSummary: json['overall_balance_summary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calorie_estimate': calorieEstimate.toJson(),
      'protein_note': proteinNote,
      'carb_note': carbNote,
      'fat_note': fatNote,
      'overall_balance_summary': overallBalanceSummary,
    };
  }
}

class CalorieEstimate {
  final int min;
  final int max;
  final String unit;
  final double confidence;

  CalorieEstimate({
    required this.min,
    required this.max,
    required this.unit,
    required this.confidence,
  });

  factory CalorieEstimate.fromJson(Map<String, dynamic> json) {
    return CalorieEstimate(
      min: json['min'] ?? 0,
      max: json['max'] ?? 0,
      unit: json['unit'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'unit': unit,
      'confidence': confidence,
    };
  }
}

class NextMealSuggestion {
  final String mealType;
  final String focusArea;
  final String recommendationSummary;
  final List<String> foodSuggestions;
  final List<String> avoidSuggestions;
  final String portionTip;

  NextMealSuggestion({
    required this.mealType,
    required this.focusArea,
    required this.recommendationSummary,
    required this.foodSuggestions,
    required this.avoidSuggestions,
    required this.portionTip,
  });

  factory NextMealSuggestion.fromJson(Map<String, dynamic> json) {
    return NextMealSuggestion(
      mealType: json['meal_type'] ?? '',
      focusArea: json['focus_area'] ?? '',
      recommendationSummary: json['recommendation_summary'] ?? '',
      foodSuggestions: List<String>.from(json['food_suggestions'] ?? []),
      avoidSuggestions: List<String>.from(json['avoid_suggestions'] ?? []),
      portionTip: json['portion_tip'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'meal_type': mealType,
      'focus_area': focusArea,
      'recommendation_summary': recommendationSummary,
      'food_suggestions': foodSuggestions,
      'avoid_suggestions': avoidSuggestions,
      'portion_tip': portionTip,
    };
  }
}

class NextBreakfastSuggestion {
  final BreakfastOption mainOption;
  final List<String> alternativeIngredients;
  final List<String> prepTips;
  final String whyRecommended;

  NextBreakfastSuggestion({
    required this.mainOption,
    required this.alternativeIngredients,
    required this.prepTips,
    required this.whyRecommended,
  });

  factory NextBreakfastSuggestion.fromJson(Map<String, dynamic> json) {
    return NextBreakfastSuggestion(
      mainOption: BreakfastOption.fromJson(json['main_option']),
      alternativeIngredients: List<String>.from(json['alternative_ingredients'] ?? []),
      prepTips: List<String>.from(json['prep_tips'] ?? []),
      whyRecommended: json['why_recommended'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'main_option': mainOption.toJson(),
      'alternative_ingredients': alternativeIngredients,
      'prep_tips': prepTips,
      'why_recommended': whyRecommended,
    };
  }
}

class BreakfastOption {
  final String name;
  final String description;
  final String prepTime;
  final List<String> keyIngredients;

  BreakfastOption({
    required this.name,
    required this.description,
    required this.prepTime,
    required this.keyIngredients,
  });

  factory BreakfastOption.fromJson(Map<String, dynamic> json) {
    return BreakfastOption(
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      prepTime: json['prep_time'] ?? '',
      keyIngredients: List<String>.from(json['key_ingredients'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'prep_time': prepTime,
      'key_ingredients': keyIngredients,
    };
  }
}
