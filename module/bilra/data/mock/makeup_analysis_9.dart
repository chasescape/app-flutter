import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis9 = MakeupAnalysis(
  assetImg: A.assets_bilra_9,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "defined",
      confidence: 0.98,
      evidence: "sharp winged eyeliner and highly defined lash line",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.92,
      evidence: "soft glossy nude finish with visible lip shape",
    ),
    overallVibe: OverallVibe(
      value: "defined_polished",
      confidence: 0.95,
      evidence: "precise makeup application and structured brow grooming",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.88,
      evidence: "golden skin tones and warm-toned eyeshadow palette",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "symmetrical features and clear cheekbone definition",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "defined_eye_focus",
    styleTagline: "Sleek Winged Eyeliner for a Polished Eye Focus",
    keywords: [
      "sharp winged liner",
      "fluffy feathered brows",
      "neutral matte eyeshadow",
      "inner corner highlight",
      "satin skin finish",
      "nude gloss lip",
      "subtle cheek contour"
    ],
    whyItWorks:
        "The sharp eyeliner draws attention to your eye shape, while the warm neutral tones complement your skin's natural undertone without overwhelming your features.",
    startWithTip:
        "Start by mapping out your eyeliner wing with a dark shadow first, then go over it with liquid liner for maximum precision.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "sharp winged eyeliner tutorial for almond eyes",
      "clean girl soft glam makeup tutorial",
      "fluffy brow grooming technique"
    ],
    copyableSearchPhrase:
        "defined winged eyeliner and neutral glam makeup tutorial",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: [
      "date_night",
      "content_shooting",
      "special_event",
      "office_work"
    ],
    occasionNotes:
        "This look is sophisticated enough for professional settings but striking enough for evening events and photography.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "High-quality close-up with excellent lighting and feature clarity.",
  ),
);
