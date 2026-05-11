import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis4 = MakeupAnalysis(
  assetImg: A.assets_bilra_4,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.95,
      evidence: "clear almond shape with ample lid space for blending",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence: "well-defined lip border and balanced proportions",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "even skin tone and soft, harmonious natural features",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.85,
      evidence:
          "skin shows a balanced mix of warm and cool tones in natural light",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "symmetrical features with a soft oval face shape",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_glam_even",
    styleTagline: "Radiant Soft Glam for a Polished, High-Definition Look",
    keywords: [
      "luminous medium coverage base",
      "warm cocoa smokey eye",
      "gold shimmer center lid",
      "defined arched brow",
      "sculpted cheekbones",
      "bold berry matte lip"
    ],
    whyItWorks:
        "Your balanced features and neutral undertone provide the perfect canvas for a 'soft glam' approach. Defining both the eyes and lips creates a sophisticated contrast that enhances your natural symmetry.",
    startWithTip:
        "Start by defining your brow arch and applying a luminous base. This creates the structure needed before adding the dramatic eye and lip colors.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "soft glam makeup for neutral skin",
      "smokey eye with bold berry lip tutorial"
    ],
    copyableSearchPhrase:
        "professional soft glam makeup tutorial for special events",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["special_event", "date_night", "content_shooting"],
    occasionNotes:
        "This high-definition look is ideal for photography, evening celebrations, or any moment where you want a polished presence.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear visibility of features in both natural and made-up states.",
  ),
);
