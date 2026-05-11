/// QuoteVibe AI complete analysis result model
class QuoteVibeAnalysisData {
  final String assetImg;
  final SceneAnalysis sceneAnalysis;
  final List<QuoteCardItem> quoteCards;
  final String styleSignature;
  final DateTime createdAt;
  final String id;

  QuoteVibeAnalysisData({
    required this.assetImg,
    required this.sceneAnalysis,
    required this.quoteCards,
    required this.styleSignature,
    DateTime? createdAt,
    String? id,
  })  : createdAt = createdAt ?? DateTime.now(),
        id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() {
    return {
      'assetImg': assetImg,
      'sceneAnalysis': sceneAnalysis.toJson(),
      'quoteCards': quoteCards.map((e) => e.toJson()).toList(),
      'styleSignature': styleSignature,
      'createdAt': createdAt.toIso8601String(),
      'id': id,
    };
  }

  factory QuoteVibeAnalysisData.fromJson(Map<String, dynamic> json) {
    final sceneAnalysisJson =
        (json['sceneAnalysis'] ?? json['scene_analysis']) as Map<String, dynamic>;
    final quoteCardsJson = (json['quoteCards'] ?? json['quote_cards']) as List<dynamic>;

    return QuoteVibeAnalysisData(
      assetImg: json['assetImg'] as String,
      sceneAnalysis: SceneAnalysis.fromJson(sceneAnalysisJson),
      quoteCards: quoteCardsJson
          .map((e) => QuoteCardItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      styleSignature: (json['styleSignature'] ?? json['style_signature']) as String,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  QuoteCardItem get firstCard => quoteCards.first;

  String get oneLineVibe => sceneAnalysis.sceneDescription;

  List<String> get tags => sceneAnalysis.moodTags;

  Map<String, dynamic> get sceneCard => sceneAnalysis.toJson();
}

class SceneAnalysis {
  final String location;
  final String timeOfDay;
  final String primaryMood;
  final List<String> moodTags;
  final VisualElements visualElements;
  final String sceneDescription;

  SceneAnalysis({
    required this.location,
    required this.timeOfDay,
    required this.primaryMood,
    required this.moodTags,
    required this.visualElements,
    required this.sceneDescription,
  });

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'timeOfDay': timeOfDay,
      'primaryMood': primaryMood,
      'moodTags': moodTags,
      'visualElements': visualElements.toJson(),
      'sceneDescription': sceneDescription,
    };
  }

  factory SceneAnalysis.fromJson(Map<String, dynamic> json) {
    return SceneAnalysis(
      location: json['location'] as String,
      timeOfDay: (json['timeOfDay'] ?? json['time_of_day']) as String,
      primaryMood: (json['primaryMood'] ?? json['primary_mood']) as String,
      moodTags: List<String>.from((json['moodTags'] ?? json['mood_tags']) as List),
      visualElements: VisualElements.fromJson(
        (json['visualElements'] ?? json['visual_elements']) as Map<String, dynamic>,
      ),
      sceneDescription: (json['sceneDescription'] ?? json['scene_description']) as String,
    );
  }
}

class VisualElements {
  final List<String> subjects;
  final List<String> actions;
  final String colorTone;
  final String atmosphere;

  VisualElements({
    required this.subjects,
    required this.actions,
    required this.colorTone,
    required this.atmosphere,
  });

  Map<String, dynamic> toJson() {
    return {
      'subjects': subjects,
      'actions': actions,
      'colorTone': colorTone,
      'atmosphere': atmosphere,
    };
  }

  factory VisualElements.fromJson(Map<String, dynamic> json) {
    return VisualElements(
      subjects: List<String>.from(json['subjects'] as List),
      actions: List<String>.from(json['actions'] as List),
      colorTone: (json['colorTone'] ?? json['color_tone']) as String,
      atmosphere: json['atmosphere'] as String,
    );
  }
}

class QuoteCardItem {
  final String quote;
  final String author;
  final String interpretation;
  final String resonanceReason;
  final String emotionalIntensity;

  QuoteCardItem({
    required this.quote,
    required this.author,
    required this.interpretation,
    required this.resonanceReason,
    required this.emotionalIntensity,
  });

  Map<String, dynamic> toJson() {
    return {
      'quote': quote,
      'author': author,
      'interpretation': interpretation,
      'resonanceReason': resonanceReason,
      'emotionalIntensity': emotionalIntensity,
    };
  }

  factory QuoteCardItem.fromJson(Map<String, dynamic> json) {
    return QuoteCardItem(
      quote: json['quote'] as String,
      author: json['author'] as String,
      interpretation: json['interpretation'] as String,
      resonanceReason: (json['resonanceReason'] ?? json['resonance_reason']) as String,
      emotionalIntensity: (json['emotionalIntensity'] ?? json['emotional_intensity']) as String,
    );
  }

  String get moodCritique => interpretation;

  String get safety => emotionalIntensity;
}

enum QuoteVibeStyle {
  healing,
  motivational,
  reflective,
  stoic,
}

extension QuoteVibeStyleExtension on QuoteVibeStyle {
  String get value {
    switch (this) {
      case QuoteVibeStyle.healing:
        return 'healing';
      case QuoteVibeStyle.motivational:
        return 'motivational';
      case QuoteVibeStyle.reflective:
        return 'reflective';
      case QuoteVibeStyle.stoic:
        return 'stoic';
    }
  }

  String get displayName {
    switch (this) {
      case QuoteVibeStyle.healing:
        return 'Healing';
      case QuoteVibeStyle.motivational:
        return 'Motivational';
      case QuoteVibeStyle.reflective:
        return 'Reflective';
      case QuoteVibeStyle.stoic:
        return 'Stoic';
    }
  }

  static QuoteVibeStyle fromString(String value) {
    switch (value.toLowerCase()) {
      case 'healing':
        return QuoteVibeStyle.healing;
      case 'motivational':
        return QuoteVibeStyle.motivational;
      case 'reflective':
        return QuoteVibeStyle.reflective;
      case 'stoic':
        return QuoteVibeStyle.stoic;
      default:
        return QuoteVibeStyle.healing;
    }
  }
}
