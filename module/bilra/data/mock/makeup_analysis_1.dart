import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis1 = MakeupAnalysis(
  assetImg: A.assets_bilra_1,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "defined",
      confidence: 0.95,
      evidence: "visible mascara and warm-toned eyeshadow application",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence: "soft pink glossy finish visible on lips",
    ),
    overallVibe: OverallVibe(
      value: "soft_glam",
      confidence: 0.95,
      evidence: "glowy skin finish combined with polished eye makeup",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.9,
      evidence: "golden skin tones accentuated by sunset lighting",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.95,
      evidence: "proportional distribution of facial features",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_peach_glow",
    styleTagline: "Golden Hour Glow for Sun-Kissed Radiance",
    keywords: [
      "dewy skin base",
      "warm peach blush",
      "champagne highlighter",
      "terra-cotta eyeshadow",
      "brown volumizing mascara",
      "glossy nude lip tint"
    ],
    whyItWorks:
        "The warm peach and gold tones perfectly complement your warm undertone and natural radiance, enhancing your features while maintaining a fresh, outdoor-ready look.",
    startWithTip:
        "Start with a hydrating primer for a dewy base, then apply a cream peach blush to the apples of your cheeks for a natural flush.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "golden hour glow makeup tutorial",
      "soft peach makeup for warm skin"
    ],
    copyableSearchPhrase:
        "soft peach golden hour makeup tutorial for beginners",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["weekend_brunch", "content_shooting", "date_night"],
    occasionNotes:
        "This look is ideal for outdoor photography and social gatherings where you want a natural yet polished glow.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes: "Excellent lighting and clear facial visibility.",
  ),
);
