import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis7 = MakeupAnalysis(
  assetImg: A.assets_bilra_7,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "defined",
      confidence: 0.95,
      evidence:
          "Visible eyelid crease, clear lash definition, and bright iris color.",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence: "Well-defined lip border with a soft, natural peach-nude tone.",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "Luminous skin texture and monochromatic warm-toned makeup.",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.85,
      evidence: "A balanced mix of peach and beige tones in the skin.",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence:
          "Harmonious proportions between the eyes, nose, and cheekbones.",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_peach_glow",
    styleTagline: "Luminous Peach Radiance for a Fresh Daily Look",
    keywords: [
      "dewy skin tint",
      "fluffy natural brows",
      "monochromatic peach lids",
      "champagne inner corner highlight",
      "soft brown mascara",
      "satin nude-peach lip",
      "cream apricot blush"
    ],
    whyItWorks:
        "The soft peach tones create a beautiful contrast with your green eyes while the dewy finish enhances your naturally smooth skin texture.",
    startWithTip:
        "Start with a hydrating primer for that glow, then apply a single peach eyeshadow shade across the entire lid.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "monochromatic peach makeup tutorial",
      "clean girl glowy makeup for beginners",
      "soft peach makeup for green eyes"
    ],
    copyableSearchPhrase:
        "soft peach glow makeup tutorial for a fresh everyday look",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["daily_commute", "weekend_brunch", "office_work"],
    occasionNotes:
        "This look provides a polished, 'no-makeup' makeup feel that is perfect for professional and casual settings.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and high-resolution detail for accurate feature analysis.",
  ),
);
