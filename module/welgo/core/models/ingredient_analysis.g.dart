part of 'ingredient_analysis.dart';

IngredientAnalysis _$IngredientAnalysisFromJson(Map<String, dynamic> json) => IngredientAnalysis(
      id: json['id'] as String,
      productName: json['productName'] as String,
      imageUrl: json['imageUrl'] as String,
      createdAt: json['createdAt'] == null
          ? DateTime.now()
          : DateTime.parse(json['createdAt'] as String),
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => Ingredient.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      categories: (json['categories'] as List<dynamic>?)?.cast<String>() ?? [],
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => Warning.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      summary: json['summary'] as String? ?? '',
    );

Map<String, dynamic> _$IngredientAnalysisToJson(IngredientAnalysis instance) =>
    <String, dynamic>{
      'id': instance.id,
      'productName': instance.productName,
      'imageUrl': instance.imageUrl,
      'createdAt': instance.createdAt.toIso8601String(),
      'ingredients': instance.ingredients.map((e) => e.toJson()).toList(),
      'categories': instance.categories,
      'warnings': instance.warnings.map((e) => e.toJson()).toList(),
      'summary': instance.summary,
    };

Ingredient _$IngredientFromJson(Map<String, dynamic> json) => Ingredient(
      name: json['name'] as String,
      commonName: json['commonName'] as String? ?? '',
      category: json['category'] as String,
      safetyRating: json['safetyRating'] as int? ?? 0,
      description: json['description'] as String? ?? '',
    );

Map<String, dynamic> _$IngredientToJson(Ingredient instance) => <String, dynamic>{
      'name': instance.name,
      'commonName': instance.commonName,
      'category': instance.category,
      'safetyRating': instance.safetyRating,
      'description': instance.description,
    };

Warning _$WarningFromJson(Map<String, dynamic> json) => Warning(
      type: json['type'] as String,
      message: json['message'] as String,
      relatedIngredients: (json['relatedIngredients'] as List<dynamic>?)?.cast<String>() ?? [],
    );

Map<String, dynamic> _$WarningToJson(Warning instance) => <String, dynamic>{
      'type': instance.type,
      'message': instance.message,
      'relatedIngredients': instance.relatedIngredients,
    };

CategoryDistribution _$CategoryDistributionFromJson(Map<String, dynamic> json) =>
    CategoryDistribution(
      category: json['category'] as String,
      count: json['count'] as int? ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );

Map<String, dynamic> _$CategoryDistributionToJson(CategoryDistribution instance) =>
    <String, dynamic>{
      'category': instance.category,
      'count': instance.count,
      'percentage': instance.percentage,
    };
