import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis15 = MakeupAnalysis(
  assetImg: A.assets_bilra_15,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "unclear",
      confidence: 0.95,
      evidence:
          "Eyes are closed in the photo, preventing detailed analysis of eye shape.",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence:
          "Natural lip shape and color are clearly visible with a soft smile.",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "Bright natural lighting and a cozy, relaxed indoor setting.",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.85,
      evidence:
          "Warm golden light from the window highlights golden undertones in the skin.",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.8,
      evidence: "Well-proportioned features with soft, defined cheekbones.",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_peach_glow",
    styleTagline: "Sun-Kissed Peach Glow for a Radiant Look",
    keywords: [
      "dewy skin tint",
      "peach cream blush",
      "fluffy natural brows",
      "shimmering champagne lids",
      "tinted lip balm",
      "warm brown mascara"
    ],
    whyItWorks:
        "Your balanced features and warm skin tone are beautifully enhanced by soft peach and champagne tones. This direction emphasizes your natural radiance without feeling heavy.",
    startWithTip:
        "Start with a lightweight dewy skin tint and a touch of peach cream blush on the apples of your cheeks for an instant healthy glow.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "natural peach makeup tutorial for beginners",
      "sun-kissed dewy makeup look everyday"
    ],
    copyableSearchPhrase: "soft peach glow natural makeup tutorial dewy skin",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["weekend_brunch", "casual_hangout"],
    occasionNotes:
        "This fresh, effortless look is perfect for relaxed daytime activities and golden hour photos.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clarity. Note: Eyes are closed, so eye-specific recommendations are based on general vibe rather than eye shape.",
  ),
);
