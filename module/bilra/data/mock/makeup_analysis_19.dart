import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis19 = MakeupAnalysis(
  assetImg: A.assets_bilra_19,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "dramatic",
      confidence: 0.98,
      evidence: "bold winged eyeliner and deep smoky eyeshadow visible",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.95,
      evidence: "well-defined lips with a glossy natural-toned finish",
    ),
    overallVibe: OverallVibe(
      value: "defined_polished",
      confidence: 0.95,
      evidence: "high-contrast makeup with sculpted features and dramatic eyes",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.9,
      evidence: "golden and honey tones visible in skin and highlights",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.95,
      evidence: "symmetrical features with a well-proportioned oval face shape",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "defined_eye_focus",
    styleTagline: "Dramatic Sultry Eyes with a Polished Glow",
    keywords: [
      "sharp winged eyeliner",
      "smoky bronze eyeshadow",
      "sculpted arched brows",
      "golden inner corner highlight",
      "contoured cheekbones",
      "glossy nude lip"
    ],
    whyItWorks:
        "Your balanced facial structure allows for a bold, dramatic eye without overwhelming your features. The warm tones in the eyeshadow perfectly complement your skin's golden undertone.",
    startWithTip:
        "Start by mapping out your winged liner and blending your smoky transition shades before applying your foundation to avoid fallout.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "dramatic smoky eye with winged liner tutorial",
      "warm bronze glam makeup look",
      "sculpted face and bold eye tutorial"
    ],
    copyableSearchPhrase:
        "dramatic smoky eye makeup tutorial with winged liner and glossy lips",
    recommendedPlatforms: ["YouTube", "Instagram", "Xiaohongshu"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["date_night", "special_event", "content_shooting"],
    occasionNotes:
        "This high-impact, polished look is ideal for evening events, photography, or any occasion where you want a sophisticated and bold presence.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear front-facing angle allow for high-confidence analysis.",
  ),
);
