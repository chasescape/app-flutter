class NailStyleCard {
  final String styleName;
  final List<String> styleTags;
  final String sceneFit;
  final String whyItFits;
  final List<String> visualKeywords;

  NailStyleCard({
    required this.styleName,
    required this.styleTags,
    required this.sceneFit,
    required this.whyItFits,
    required this.visualKeywords,
  });

  Map<String, dynamic> toJson() => {
        'styleName': styleName,
        'styleTags': styleTags,
        'sceneFit': sceneFit,
        'whyItFits': whyItFits,
        'visualKeywords': visualKeywords,
      };

  factory NailStyleCard.fromJson(Map<String, dynamic> json) => NailStyleCard(
        styleName: json['styleName'] as String? ?? '',
        styleTags: (json['styleTags'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
        sceneFit: json['sceneFit'] as String? ?? '',
        whyItFits: json['whyItFits'] as String? ?? '',
        visualKeywords: (json['visualKeywords'] as List<dynamic>?)
                ?.map((e) => e as String)
                .toList() ??
            [],
      );
}

class RecommendationResult {
  final String id;
  final String imagePath;
  final String? sceneTag;
  final String? preference;
  final List<NailStyleCard> styles;
  final DateTime createdAt;

  RecommendationResult({
    required this.id,
    required this.imagePath,
    this.sceneTag,
    this.preference,
    required this.styles,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'sceneTag': sceneTag,
        'preference': preference,
        'styles': styles.map((e) => e.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory RecommendationResult.fromJson(Map<String, dynamic> json) =>
      RecommendationResult(
        id: json['id'] as String? ?? '',
        imagePath: json['imagePath'] as String? ?? '',
        sceneTag: json['sceneTag'] as String?,
        preference: json['preference'] as String?,
        styles: (json['styles'] as List<dynamic>?)
                ?.map((e) => NailStyleCard.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : DateTime.now(),
      );
}

class NailRecommendationPayload {
  final List<NailStyleCard> styles;

  NailRecommendationPayload({required this.styles});

  factory NailRecommendationPayload.fromJson(Map<String, dynamic> json) =>
      NailRecommendationPayload(
        styles: (json['styles'] as List<dynamic>?)
                ?.map((e) => NailStyleCard.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

  Map<String, dynamic> toJson() => {
        'styles': styles.map((e) => e.toJson()).toList(),
      };
}

enum SceneTag {
  everyday('Everyday'),
  party('Party'),
  wedding('Wedding'),
  holiday('Holiday'),
  date('Date'),
  work('Work');

  final String label;
  const SceneTag(this.label);
}
