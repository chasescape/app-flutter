import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis12 = MakeupAnalysis(
  assetImg: A.assets_bilra_12,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.95,
      evidence: "clear eye shape with defined natural lashes",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.92,
      evidence: "soft natural lip definition and color",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "luminous skin and soft color palette",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.85,
      evidence: "balanced skin tones in soft natural light",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "harmonious proportions of eyes, nose, and lips",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_peach_glow",
    styleTagline: "Soft Peach Glow for Luminous Radiance",
    keywords: [
      "dewy skin base",
      "peach cream blush",
      "feathered natural brows",
      "champagne shimmer lid",
      "brown lengthening mascara",
      "glossy apricot lip"
    ],
    whyItWorks:
        "Your balanced features and fresh vibe are perfectly complemented by warm, luminous tones. The soft peach hues enhance your natural flush without overpowering your delicate structure.",
    startWithTip:
        "Start with a hydrating primer for a glowy base, then apply a cream peach blush high on the cheekbones for a lifted effect.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "soft peach glow makeup tutorial",
      "clean girl aesthetic makeup for beginners"
    ],
    copyableSearchPhrase:
        "natural soft peach glow makeup tutorial for daily wear",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["weekend_brunch", "daily_commute", "casual_hangout"],
    occasionNotes:
        "This effortless, radiant look is ideal for daytime activities where you want to look polished yet natural.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes: "Excellent lighting and clear facial visibility.",
  ),
);
