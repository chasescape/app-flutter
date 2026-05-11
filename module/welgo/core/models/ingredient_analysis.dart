import 'package:json_annotation/json_annotation.dart';

part 'ingredient_analysis.g.dart';

@JsonSerializable()
class IngredientAnalysis {
  final String id;
  final String productName;
  final String imageUrl;
  final DateTime createdAt;
  final List<Ingredient> ingredients;
  final List<String> categories;
  final List<Warning> warnings;
  final String summary;

  const IngredientAnalysis({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.createdAt,
    required this.ingredients,
    required this.categories,
    required this.warnings,
    required this.summary,
  });

  factory IngredientAnalysis.fromJson(Map<String, dynamic> json) => _$IngredientAnalysisFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientAnalysisToJson(this);

  IngredientAnalysis copyWith({
    String? id,
    String? productName,
    String? imageUrl,
    DateTime? createdAt,
    List<Ingredient>? ingredients,
    List<String>? categories,
    List<Warning>? warnings,
    String? summary,
  }) {
    return IngredientAnalysis(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      ingredients: ingredients ?? this.ingredients,
      categories: categories ?? this.categories,
      warnings: warnings ?? this.warnings,
      summary: summary ?? this.summary,
    );
  }
}

@JsonSerializable()
class Ingredient {
  final String name;
  final String commonName;
  final String category;
  final int safetyRating;
  final String description;

  const Ingredient({
    required this.name,
    required this.commonName,
    required this.category,
    required this.safetyRating,
    required this.description,
  });

  factory Ingredient.fromJson(Map<String, dynamic> json) => _$IngredientFromJson(json);
  Map<String, dynamic> toJson() => _$IngredientToJson(this);
}

@JsonSerializable()
class Warning {
  final String type;
  final String message;
  final List<String> relatedIngredients;

  const Warning({
    required this.type,
    required this.message,
    required this.relatedIngredients,
  });

  factory Warning.fromJson(Map<String, dynamic> json) => _$WarningFromJson(json);
  Map<String, dynamic> toJson() => _$WarningToJson(this);
}

@JsonSerializable()
class CategoryDistribution {
  final String category;
  final int count;
  final double percentage;

  const CategoryDistribution({
    required this.category,
    required this.count,
    required this.percentage,
  });

  factory CategoryDistribution.fromJson(Map<String, dynamic> json) => _$CategoryDistributionFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryDistributionToJson(this);
}
