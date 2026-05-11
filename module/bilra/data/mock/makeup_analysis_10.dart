import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis10 = MakeupAnalysis(
  assetImg: A.assets_bilra_10,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.95,
      evidence: "Well-defined natural brows and soft eye definition visible.",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence: "Natural lip shape with a soft, glossy finish.",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "Radiant complexion and bright, even lighting.",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.8,
      evidence:
          "Balanced skin tone that works well with both warm and cool accents.",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "Symmetrical and well-proportioned facial features.",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_peach_glow",
    styleTagline: "Radiant Peach Glow for a Polished Everyday Look",
    keywords: [
      "dewy skin tint",
      "feathered natural brows",
      "soft peach cream blush",
      "champagne highlighter",
      "glossy nude lip",
      "brown lifting mascara"
    ],
    whyItWorks:
        "Your balanced features and radiant skin are perfectly complemented by luminous, peach-toned products that enhance your natural glow without masking it.",
    startWithTip:
        "Start with a hydrating base and groomed brows, then layer a cream peach blush onto the high points of your cheeks.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "clean girl aesthetic makeup tutorial",
      "glowy peach makeup for beginners"
    ],
    copyableSearchPhrase:
        "soft peach glow makeup tutorial for a natural dewy look",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["daily_commute", "weekend_brunch", "office_work"],
    occasionNotes:
        "This fresh, luminous look is highly versatile and perfect for both professional environments and casual social gatherings.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear visibility of facial features.",
  ),
);
