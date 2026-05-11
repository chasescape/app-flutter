class HairstyleResult {
  final String id;
  final String originalImagePath;
  final String? previewImagePath;
  final String mainStyleName;
  final String whyItFits;
  final List<StyleSuggestion> alternativeSuggestions;
  final String barberNote;
  final DateTime createdAt;
  final int coinsUsed;
  final List<String> oldImagePaths;
  final String? editInstructionContext;

  HairstyleResult({
    required this.id,
    required this.originalImagePath,
    this.previewImagePath,
    required this.mainStyleName,
    required this.whyItFits,
    required this.alternativeSuggestions,
    required this.barberNote,
    required this.createdAt,
    required this.coinsUsed,
    this.oldImagePaths = const [],
    this.editInstructionContext,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalImagePath': originalImagePath,
      'previewImagePath': previewImagePath,
      'mainStyleName': mainStyleName,
      'whyItFits': whyItFits,
      'alternativeSuggestions': alternativeSuggestions.map((s) => s.toJson()).toList(),
      'barberNote': barberNote,
      'createdAt': createdAt.toIso8601String(),
      'coinsUsed': coinsUsed,
      'oldImagePaths': oldImagePaths,
      'editInstructionContext': editInstructionContext,
    };
  }

  factory HairstyleResult.fromJson(Map<String, dynamic> json) {
    return HairstyleResult(
      id: json['id'] as String,
      originalImagePath: json['originalImagePath'] as String,
      previewImagePath: json['previewImagePath'] as String?,
      mainStyleName: json['mainStyleName'] as String,
      whyItFits: json['whyItFits'] as String,
      alternativeSuggestions: (json['alternativeSuggestions'] as List<dynamic>)
          .map((s) => StyleSuggestion.fromJson(s as Map<String, dynamic>))
          .toList(),
      barberNote: json['barberNote'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      coinsUsed: json['coinsUsed'] as int,
      oldImagePaths: (json['oldImagePaths'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      editInstructionContext: json['editInstructionContext'] as String?,
    );
  }

  HairstyleResult copyWith({
    String? id,
    String? originalImagePath,
    String? previewImagePath,
    String? mainStyleName,
    String? whyItFits,
    List<StyleSuggestion>? alternativeSuggestions,
    String? barberNote,
    DateTime? createdAt,
    int? coinsUsed,
    List<String>? oldImagePaths,
    String? editInstructionContext,
  }) {
    return HairstyleResult(
      id: id ?? this.id,
      originalImagePath: originalImagePath ?? this.originalImagePath,
      previewImagePath: previewImagePath ?? this.previewImagePath,
      mainStyleName: mainStyleName ?? this.mainStyleName,
      whyItFits: whyItFits ?? this.whyItFits,
      alternativeSuggestions: alternativeSuggestions ?? this.alternativeSuggestions,
      barberNote: barberNote ?? this.barberNote,
      createdAt: createdAt ?? this.createdAt,
      coinsUsed: coinsUsed ?? this.coinsUsed,
      oldImagePaths: oldImagePaths ?? this.oldImagePaths,
      editInstructionContext: editInstructionContext ?? this.editInstructionContext,
    );
  }
}

class StyleSuggestion {
  final String styleName;
  final String description;

  StyleSuggestion({
    required this.styleName,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'styleName': styleName,
      'description': description,
    };
  }

  factory StyleSuggestion.fromJson(Map<String, dynamic> json) {
    return StyleSuggestion(
      styleName: json['styleName'] as String,
      description: json['description'] as String,
    );
  }
}
