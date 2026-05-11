class LashHistoryItem {
  final String id;
  final String originalImageUrl;
  final String previewImageUrl;
  final String styleId;
  final String styleName;
  final DateTime createdAt;
  final int coinsUsed;
  final String? resultImageUrl;
  final List<String>? sourceImagePaths;
  final String? prompt;
  final String? title;
  final String? subtitle;
  final String? whyBetter;
  final String? howItWorks;
  final String? styleMood;
  final String? bestFor;

  LashHistoryItem({
    required this.id,
    required this.originalImageUrl,
    required this.previewImageUrl,
    required this.styleId,
    required this.styleName,
    required this.createdAt,
    required this.coinsUsed,
    this.resultImageUrl,
    this.sourceImagePaths,
    this.prompt,
    this.title,
    this.subtitle,
    this.whyBetter,
    this.howItWorks,
    this.styleMood,
    this.bestFor,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'originalImageUrl': originalImageUrl,
      'previewImageUrl': previewImageUrl,
      'styleId': styleId,
      'styleName': styleName,
      'createdAt': createdAt.toIso8601String(),
      'coinsUsed': coinsUsed,
      'resultImageUrl': resultImageUrl,
      'sourceImagePaths': sourceImagePaths,
      'prompt': prompt,
      'title': title,
      'subtitle': subtitle,
      'whyBetter': whyBetter,
      'howItWorks': howItWorks,
      'styleMood': styleMood,
      'bestFor': bestFor,
    };
  }

  factory LashHistoryItem.fromJson(Map<String, dynamic> json) {
    return LashHistoryItem(
      id: json['id'] as String,
      originalImageUrl: json['originalImageUrl'] as String,
      previewImageUrl: json['previewImageUrl'] as String,
      styleId: json['styleId'] as String,
      styleName: json['styleName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      coinsUsed: json['coinsUsed'] as int,
      resultImageUrl: json['resultImageUrl'] as String?,
      sourceImagePaths: json['sourceImagePaths'] != null
          ? List<String>.from(json['sourceImagePaths'] as List)
          : null,
      prompt: json['prompt'] as String?,
      title: json['title'] as String?,
      subtitle: json['subtitle'] as String?,
      whyBetter: json['whyBetter'] as String?,
      howItWorks: json['howItWorks'] as String?,
      styleMood: json['styleMood'] as String?,
      bestFor: json['bestFor'] as String?,
    );
  }

  LashHistoryItem copyWith({
    String? id,
    String? originalImageUrl,
    String? previewImageUrl,
    String? styleId,
    String? styleName,
    DateTime? createdAt,
    int? coinsUsed,
    String? resultImageUrl,
    List<String>? sourceImagePaths,
    String? prompt,
    String? title,
    String? subtitle,
    String? whyBetter,
    String? howItWorks,
    String? styleMood,
    String? bestFor,
  }) {
    return LashHistoryItem(
      id: id ?? this.id,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      previewImageUrl: previewImageUrl ?? this.previewImageUrl,
      styleId: styleId ?? this.styleId,
      styleName: styleName ?? this.styleName,
      createdAt: createdAt ?? this.createdAt,
      coinsUsed: coinsUsed ?? this.coinsUsed,
      resultImageUrl: resultImageUrl ?? this.resultImageUrl,
      sourceImagePaths: sourceImagePaths ?? this.sourceImagePaths,
      prompt: prompt ?? this.prompt,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      whyBetter: whyBetter ?? this.whyBetter,
      howItWorks: howItWorks ?? this.howItWorks,
      styleMood: styleMood ?? this.styleMood,
      bestFor: bestFor ?? this.bestFor,
    );
  }
}
