import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis13 = MakeupAnalysis(
  assetImg: A.assets_bilra_13,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.92,
      evidence: "clear eye shape with soft natural definition",
    ),
    lipPresence: LipPresence(
      value: "soft",
      confidence: 0.88,
      evidence: "natural lip color and texture visible",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "bright natural lighting and luminous skin finish",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.8,
      evidence: "balanced warm and cool tones in natural light",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "well-proportioned features and clear cheekbone definition",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "lifted_fresh",
    styleTagline: "Radiant Lifted Glow for a Fresh Day Look",
    keywords: [
      "dewy skin tint",
      "cream blush on high points",
      "lifted brow gel",
      "natural brown mascara",
      "sheer peach lip balm",
      "liquid champagne highlighter"
    ],
    whyItWorks:
        "Your balanced features and naturally radiant skin are perfectly suited for a 'lifted' look. Enhancing your high cheekbones with cream products maintains your fresh, youthful glow.",
    startWithTip:
        "Start with a lightweight skin tint and apply your cream blush upward toward the temples for an instant lifted effect.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "clean girl makeup tutorial for beginners",
      "lifted face makeup technique cream blush"
    ],
    copyableSearchPhrase: "lifted fresh makeup tutorial for natural dewy glow",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["weekend_brunch", "casual_hangout", "daily_commute"],
    occasionNotes:
        "This effortless, breathable look is perfect for daytime activities where you want a 'no-makeup' makeup feel.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear visibility of all facial features.",
  ),
);
