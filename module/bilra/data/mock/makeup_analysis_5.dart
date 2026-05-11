import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis5 = MakeupAnalysis(
  assetImg: A.assets_bilra_5,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.95,
      evidence: "clear eye shape with natural lash definition and bright iris",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.92,
      evidence: "well-defined lip border with natural rosy-nude pigment",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.98,
      evidence:
          "bright natural lighting, soft expression, and healthy skin texture",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.85,
      evidence:
          "balanced warm and cool tones in skin and hair under natural light",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "proportional forehead, cheekbones, and jawline",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "polished_natural",
    styleTagline: "Polished Natural Glow for Everyday Radiance",
    keywords: [
      "sheer tinted moisturizer",
      "brown lengthening mascara",
      "fluffy natural brows",
      "peach cream blush",
      "champagne cream eyeshadow",
      "tinted lip balm in rosewood"
    ],
    whyItWorks:
        "Your balanced features and neutral undertone are perfectly suited for soft, earthy tones. This look enhances your natural radiance and skin texture without masking it.",
    startWithTip:
        "Start with a sheer base or skin tint to keep your freckles visible, then set your brows with a clear gel for a lifted look.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "clean girl makeup tutorial for beginners",
      "natural everyday makeup for neutral undertones"
    ],
    copyableSearchPhrase:
        "natural polished makeup tutorial for everyday fresh look",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["daily_commute", "weekend_brunch"],
    occasionNotes:
        "This effortless look transitions perfectly from a professional office environment to a relaxed weekend outing.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear, front-facing facial visibility.",
  ),
);
