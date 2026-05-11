import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis3 = MakeupAnalysis(
  assetImg: A.assets_bilra_3,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.92,
      evidence:
          "Visible eye shape with clear lid space and natural lash line definition.",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.88,
      evidence: "Defined lip border with natural pink-beige tones visible.",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "Soft lighting and a clear, luminous complexion base.",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.82,
      evidence:
          "Balanced skin tone that works well with both warm and cool-toned products on the vanity.",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence:
          "Harmonious proportions between the forehead, cheekbones, and jawline.",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "polished_natural",
    styleTagline: "Polished Natural Look for Radiant Everyday Elegance",
    keywords: [
      "dewy skin finish",
      "soft brown mascara",
      "natural feathered brows",
      "muted peach blush",
      "satin nude lipstick",
      "champagne inner corner highlight"
    ],
    whyItWorks:
        "Your balanced facial structure and neutral undertone allow for a 'no-makeup' makeup look that enhances your natural glow without masking your features.",
    startWithTip:
        "Focus on perfecting a seamless base with a damp beauty sponge, then groom your brows upward for a lifted effect.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "clean girl makeup tutorial for beginners",
      "natural everyday glowy makeup routine"
    ],
    copyableSearchPhrase:
        "polished natural makeup tutorial for everyday fresh look",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["daily_commute", "office_work", "weekend_brunch"],
    occasionNotes:
        "This look provides a professional yet approachable appearance perfect for daytime settings.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear facial visibility in the mirror reflection.",
  ),
);
