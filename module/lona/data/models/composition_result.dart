class CompositionResult {
  final String id;
  final String originalImagePath;
  final String? guideOverlayPath;
  final String? reframePreviewPath;
  final ImageType imageType;
  final AnalysisGoal? goal;
  final String summary;
  final List<String> issues;
  final List<String> suggestions;
  final List<String> retakeSteps;
  final DateTime createdAt;
  final int coinsUsed;

  CompositionResult({
    required this.id,
    required this.originalImagePath,
    this.guideOverlayPath,
    this.reframePreviewPath,
    required this.imageType,
    this.goal,
    required this.summary,
    required this.issues,
    required this.suggestions,
    required this.retakeSteps,
    required this.createdAt,
    required this.coinsUsed,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalImagePath': originalImagePath,
      'guideOverlayPath': guideOverlayPath,
      'reframePreviewPath': reframePreviewPath,
      'imageType': imageType.name,
      'goal': goal?.name,
      'summary': summary,
      'issues': issues,
      'suggestions': suggestions,
      'retakeSteps': retakeSteps,
      'createdAt': createdAt.toIso8601String(),
      'coinsUsed': coinsUsed,
    };
  }

  factory CompositionResult.fromJson(Map<String, dynamic> json) {
    return CompositionResult(
      id: json['id'] as String,
      originalImagePath: json['originalImagePath'] as String,
      guideOverlayPath: json['guideOverlayPath'] as String?,
      reframePreviewPath: json['reframePreviewPath'] as String?,
      imageType: ImageType.values.firstWhere(
        (e) => e.name == json['imageType'],
        orElse: () => ImageType.object,
      ),
      goal: json['goal'] != null
          ? AnalysisGoal.values.firstWhere(
              (e) => e.name == json['goal'],
              orElse: () => AnalysisGoal.betterBalance,
            )
          : null,
      summary: json['summary'] as String,
      issues: List<String>.from(json['issues'] as List),
      suggestions: List<String>.from(json['suggestions'] as List),
      retakeSteps: List<String>.from(json['retakeSteps'] as List),
      createdAt: DateTime.parse(json['createdAt'] as String),
      coinsUsed: json['coinsUsed'] as int,
    );
  }
}

enum ImageType {
  portrait('Portrait'),
  food('Food'),
  pet('Pet'),
  object('Object');

  final String label;
  const ImageType(this.label);
}

enum AnalysisGoal {
  betterBalance('Better Balance'),
  strongerSubject('Stronger Subject'),
  cleanerFrame('Cleaner Frame');

  final String label;
  const AnalysisGoal(this.label);
}
