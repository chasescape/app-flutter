import 'dart:convert';

StyleVibe styleVibeFromJson(String str) => StyleVibe.fromJson(json.decode(str));
String styleVibeToJson(StyleVibe data) => json.encode(data.toJson());

HairstyleCategory hairstyleCategoryFromJson(String str) =>
    HairstyleCategory.fromJson(json.decode(str));
String hairstyleCategoryToJson(HairstyleCategory data) =>
    json.encode(data.toJson());

MakeupIntensity makeupIntensityFromJson(String str) =>
    MakeupIntensity.fromJson(json.decode(str));
String makeupIntensityToJson(MakeupIntensity data) =>
    json.encode(data.toJson());

OutfitStyle outfitStyleFromJson(String str) =>
    OutfitStyle.fromJson(json.decode(str));
String outfitStyleToJson(OutfitStyle data) => json.encode(data.toJson());

PhotoMood photoMoodFromJson(String str) => PhotoMood.fromJson(json.decode(str));
String photoMoodToJson(PhotoMood data) => json.encode(data.toJson());

SearchKeywords searchKeywordsFromJson(String str) =>
    SearchKeywords.fromJson(json.decode(str));
String searchKeywordsToJson(SearchKeywords data) => json.encode(data.toJson());

StyleDescription styleDescriptionFromJson(String str) =>
    StyleDescription.fromJson(json.decode(str));
String styleDescriptionToJson(StyleDescription data) =>
    json.encode(data.toJson());

QuickActionPlan quickActionPlanFromJson(String str) =>
    QuickActionPlan.fromJson(json.decode(str));
String quickActionPlanToJson(QuickActionPlan data) =>
    json.encode(data.toJson());

VisualNotes visualNotesFromJson(String str) =>
    VisualNotes.fromJson(json.decode(str));
String visualNotesToJson(VisualNotes data) => json.encode(data.toJson());

SafetyCheck safetyCheckFromJson(String str) =>
    SafetyCheck.fromJson(json.decode(str));
String safetyCheckToJson(SafetyCheck data) => json.encode(data.toJson());

StyleAnalysis styleAnalysisFromJson(String str) =>
    StyleAnalysis.fromJson(json.decode(str));
String styleAnalysisToJson(StyleAnalysis data) => json.encode(data.toJson());

class StyleVibe {
  String value;
  double confidence;
  String evidence;

  StyleVibe({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory StyleVibe.fromJson(Map<String, dynamic> json) => StyleVibe(
        value: json["value"],
        confidence: json["confidence"]?.toDouble(),
        evidence: json["evidence"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "confidence": confidence,
        "evidence": evidence,
      };
}

class HairstyleCategory {
  String value;
  double confidence;
  String evidence;

  HairstyleCategory({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory HairstyleCategory.fromJson(Map<String, dynamic> json) =>
      HairstyleCategory(
        value: json["value"],
        confidence: json["confidence"]?.toDouble(),
        evidence: json["evidence"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "confidence": confidence,
        "evidence": evidence,
      };
}

class MakeupIntensity {
  String value;
  double confidence;
  String evidence;

  MakeupIntensity({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory MakeupIntensity.fromJson(Map<String, dynamic> json) =>
      MakeupIntensity(
        value: json["value"],
        confidence: json["confidence"]?.toDouble(),
        evidence: json["evidence"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "confidence": confidence,
        "evidence": evidence,
      };
}

class OutfitStyle {
  String value;
  double confidence;
  String evidence;

  OutfitStyle({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory OutfitStyle.fromJson(Map<String, dynamic> json) => OutfitStyle(
        value: json["value"],
        confidence: json["confidence"]?.toDouble(),
        evidence: json["evidence"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "confidence": confidence,
        "evidence": evidence,
      };
}

class PhotoMood {
  String value;
  double confidence;
  String evidence;

  PhotoMood({
    required this.value,
    required this.confidence,
    required this.evidence,
  });

  factory PhotoMood.fromJson(Map<String, dynamic> json) => PhotoMood(
        value: json["value"],
        confidence: json["confidence"]?.toDouble(),
        evidence: json["evidence"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
        "confidence": confidence,
        "evidence": evidence,
      };
}

class SearchKeywords {
  String youtubeSearch;
  String instagramSearch;
  String? alternativeSearch1;
  String? alternativeSearch2;

  SearchKeywords({
    required this.youtubeSearch,
    required this.instagramSearch,
    this.alternativeSearch1,
    this.alternativeSearch2,
  });

  factory SearchKeywords.fromJson(Map<String, dynamic> json) => SearchKeywords(
        youtubeSearch: json["youtube_search"] ?? '',
        instagramSearch: json["instagram_search"] ?? '',
        alternativeSearch1: json["alternative_search_1"],
        alternativeSearch2: json["alternative_search_2"],
      );

  Map<String, dynamic> toJson() => {
        "youtube_search": youtubeSearch,
        "instagram_search": instagramSearch,
        "alternative_search_1": alternativeSearch1,
        "alternative_search_2": alternativeSearch2,
      };
}

class StyleDescription {
  String whyThisFits;
  List<String> keyTakeaways;

  StyleDescription({
    required this.whyThisFits,
    required this.keyTakeaways,
  });

  factory StyleDescription.fromJson(Map<String, dynamic> json) =>
      StyleDescription(
        whyThisFits: json["why_this_fits"] ?? '',
        keyTakeaways: json["key_takeaways"] == null
            ? []
            : List<String>.from(json["key_takeaways"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "why_this_fits": whyThisFits,
        "key_takeaways": List<dynamic>.from(keyTakeaways.map((x) => x)),
      };
}

class QuickActionPlan {
  String startWith;
  String copyThisSearchPhrase;

  QuickActionPlan({
    required this.startWith,
    required this.copyThisSearchPhrase,
  });

  factory QuickActionPlan.fromJson(Map<String, dynamic> json) =>
      QuickActionPlan(
        startWith: json["start_with"] ?? '',
        copyThisSearchPhrase: json["copy_this_search_phrase"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "start_with": startWith,
        "copy_this_search_phrase": copyThisSearchPhrase,
      };
}

class VisualNotes {
  List<String> dominantColors;
  List<String> notableAccessories;
  List<String> photoStrengths;
  List<String> easyImprovements;

  VisualNotes({
    required this.dominantColors,
    required this.notableAccessories,
    required this.photoStrengths,
    required this.easyImprovements,
  });

  factory VisualNotes.fromJson(Map<String, dynamic> json) => VisualNotes(
        dominantColors: json["dominant_colors"] == null
            ? []
            : List<String>.from(json["dominant_colors"].map((x) => x)),
        notableAccessories: json["notable_accessories"] == null
            ? []
            : List<String>.from(json["notable_accessories"].map((x) => x)),
        photoStrengths: json["photo_strengths"] == null
            ? []
            : List<String>.from(json["photo_strengths"].map((x) => x)),
        easyImprovements: json["easy_improvements"] == null
            ? []
            : List<String>.from(json["easy_improvements"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "dominant_colors": List<dynamic>.from(dominantColors.map((x) => x)),
        "notable_accessories":
            List<dynamic>.from(notableAccessories.map((x) => x)),
        "photo_strengths": List<dynamic>.from(photoStrengths.map((x) => x)),
        "easy_improvements":
            List<dynamic>.from(easyImprovements.map((x) => x)),
      };
}

class SafetyCheck {
  bool hasQualityIssues;
  String qualityNotes;
  bool shouldReshoot;

  SafetyCheck({
    required this.hasQualityIssues,
    required this.qualityNotes,
    required this.shouldReshoot,
  });

  factory SafetyCheck.fromJson(Map<String, dynamic> json) => SafetyCheck(
        hasQualityIssues: json["has_quality_issues"] ?? false,
        qualityNotes: json["quality_notes"] ?? '',
        shouldReshoot: json["should_reshoot"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "has_quality_issues": hasQualityIssues,
        "quality_notes": qualityNotes,
        "should_reshoot": shouldReshoot,
      };
}

class StyleAnalysis {
  StyleVibe styleVibe;
  HairstyleCategory hairstyleCategory;
  MakeupIntensity makeupIntensity;
  OutfitStyle outfitStyle;
  PhotoMood photoMood;
  List<String> styleTags;
  List<String> creatorTypesToFollow;
  SearchKeywords searchKeywords;
  StyleDescription styleDescription;
  QuickActionPlan quickActionPlan;
  VisualNotes visualNotes;
  SafetyCheck safetyCheck;
  String assetImg;

  StyleAnalysis({
    required this.styleVibe,
    required this.hairstyleCategory,
    required this.makeupIntensity,
    required this.outfitStyle,
    required this.photoMood,
    required this.styleTags,
    required this.creatorTypesToFollow,
    required this.searchKeywords,
    required this.styleDescription,
    required this.quickActionPlan,
    required this.visualNotes,
    required this.safetyCheck,
    required this.assetImg,
  });

  factory StyleAnalysis.fromJson(Map<String, dynamic> json) => StyleAnalysis(
        styleVibe: StyleVibe.fromJson(json["style_analysis"]["style_vibe"]),
        hairstyleCategory: HairstyleCategory.fromJson(
            json["style_analysis"]["hairstyle_category"]),
        makeupIntensity: MakeupIntensity.fromJson(
            json["style_analysis"]["makeup_intensity"]),
        outfitStyle:
            OutfitStyle.fromJson(json["style_analysis"]["outfit_style"]),
        photoMood: PhotoMood.fromJson(json["style_analysis"]["photo_mood"]),
        styleTags: json["style_tags"] == null
            ? []
            : List<String>.from(json["style_tags"].map((x) => x)),
        creatorTypesToFollow: json["creator_types_to_follow"] == null
            ? []
            : List<String>.from(json["creator_types_to_follow"].map((x) => x)),
        searchKeywords: SearchKeywords.fromJson(json["search_keywords"]),
        styleDescription: StyleDescription.fromJson(json["style_description"]),
        quickActionPlan: QuickActionPlan.fromJson(json["quick_action_plan"]),
        visualNotes: VisualNotes.fromJson(json["visual_notes"]),
        safetyCheck: SafetyCheck.fromJson(json["safety_check"]),
        assetImg: '', // Placeholder, set when creating mock data
      );

  Map<String, dynamic> toJson() => {
        "style_analysis": {
          "style_vibe": styleVibe.toJson(),
          "hairstyle_category": hairstyleCategory.toJson(),
          "makeup_intensity": makeupIntensity.toJson(),
          "outfit_style": outfitStyle.toJson(),
          "photo_mood": photoMood.toJson(),
        },
        "style_tags": List<dynamic>.from(styleTags.map((x) => x)),
        "creator_types_to_follow":
            List<dynamic>.from(creatorTypesToFollow.map((x) => x)),
        "search_keywords": searchKeywords.toJson(),
        "style_description": styleDescription.toJson(),
        "quick_action_plan": quickActionPlan.toJson(),
        "visual_notes": visualNotes.toJson(),
        "safety_check": safetyCheck.toJson(),
      };
}
