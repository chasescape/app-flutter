enum PhotoSceneCategory {
  food,
  landscape,
  portrait,
  pets,
  other,
}

extension PhotoSceneCategoryX on PhotoSceneCategory {
  String get id => name;

  String get label {
    switch (this) {
      case PhotoSceneCategory.food:
        return 'Food';
      case PhotoSceneCategory.landscape:
        return 'Landscape';
      case PhotoSceneCategory.portrait:
        return 'Portrait';
      case PhotoSceneCategory.pets:
        return 'Pets';
      case PhotoSceneCategory.other:
        return 'Other';
    }
  }

  static PhotoSceneCategory fromId(String? id) {
    switch (id) {
      case 'food':
        return PhotoSceneCategory.food;
      case 'landscape':
        return PhotoSceneCategory.landscape;
      case 'portrait':
        return PhotoSceneCategory.portrait;
      case 'pets':
        return PhotoSceneCategory.pets;
      default:
        return PhotoSceneCategory.other;
    }
  }
}

class PhotoSceneAnalysis {
  const PhotoSceneAnalysis({
    required this.category,
    required this.summary,
  });

  final PhotoSceneCategory category;
  final String summary;

  factory PhotoSceneAnalysis.fromJson(Map<String, dynamic> json) {
    return PhotoSceneAnalysis(
      category: PhotoSceneCategoryX.fromId(json['category'] as String?),
      summary: (json['summary'] as String?)?.trim().isNotEmpty == true
          ? (json['summary'] as String).trim()
          : 'Uncategorized photo.',
    );
  }

  Map<String, dynamic> toJson() => {
        'category': category.id,
        'summary': summary,
      };
}

class AnalyzedPhoto {
  const AnalyzedPhoto({
    required this.path,
    required this.analysis,
    required this.createdAtMs,
  });

  final String path;
  final PhotoSceneAnalysis analysis;
  final int createdAtMs;

  factory AnalyzedPhoto.fromJson(Map<String, dynamic> json) {
    return AnalyzedPhoto(
      path: json['path'] as String,
      analysis:
          PhotoSceneAnalysis.fromJson((json['analysis'] as Map).cast<String, dynamic>()),
      createdAtMs: (json['createdAtMs'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
  }

  Map<String, dynamic> toJson() => {
        'path': path,
        'analysis': analysis.toJson(),
        'createdAtMs': createdAtMs,
      };
}

