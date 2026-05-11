/// ReflectLens - Photo-based reflection entry model
class ReflectionEntry {
  /// Image asset reference from A.dart
  final String assetImg;

  /// Scene understanding data
  final SceneUnderstanding sceneUnderstanding;

  /// Reflection content
  final ReflectionContent reflection;

  ReflectionEntry({
    required this.assetImg,
    required this.sceneUnderstanding,
    required this.reflection,
  });

  factory ReflectionEntry.fromJson(Map<String, dynamic> json) {
    return ReflectionEntry(
      assetImg: json['assetImg'] as String,
      sceneUnderstanding: SceneUnderstanding.fromJson(
        json['scene_understanding'] as Map<String, dynamic>,
      ),
      reflection: ReflectionContent.fromJson(
        json['reflection'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'assetImg': assetImg,
      'scene_understanding': sceneUnderstanding.toJson(),
      'reflection': reflection.toJson(),
    };
  }
}

class SceneUnderstanding {
  final String location;
  final String timeOfDay;
  final String atmosphere;
  final String mainSubject;
  final String emotionalCue;

  SceneUnderstanding({
    required this.location,
    required this.timeOfDay,
    required this.atmosphere,
    required this.mainSubject,
    required this.emotionalCue,
  });

  factory SceneUnderstanding.fromJson(Map<String, dynamic> json) {
    return SceneUnderstanding(
      location: json['location'] as String,
      timeOfDay: json['time_of_day'] as String,
      atmosphere: json['atmosphere'] as String,
      mainSubject: json['main_subject'] as String,
      emotionalCue: json['emotional_cue'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'location': location,
      'time_of_day': timeOfDay,
      'atmosphere': atmosphere,
      'main_subject': mainSubject,
      'emotional_cue': emotionalCue,
    };
  }
}

class ReflectionContent {
  final String observation;
  final String deeperThought;
  final String insight;
  final String actionPrompt;

  ReflectionContent({
    required this.observation,
    required this.deeperThought,
    required this.insight,
    required this.actionPrompt,
  });

  factory ReflectionContent.fromJson(Map<String, dynamic> json) {
    return ReflectionContent(
      observation: json['observation'] as String,
      deeperThought: json['deeper_thought'] as String,
      insight: json['insight'] as String,
      actionPrompt: json['action_prompt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'observation': observation,
      'deeper_thought': deeperThought,
      'insight': insight,
      'action_prompt': actionPrompt,
    };
  }
}
