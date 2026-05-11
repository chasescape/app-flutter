import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis18 = MakeupAnalysis(
  assetImg: A.assets_bilra_18,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "defined",
      confidence: 0.95,
      evidence: "clear eye shape with defined lashes and warm eyeshadow",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.92,
      evidence: "glossy peach lip color with soft borders",
    ),
    overallVibe: OverallVibe(
      value: "soft_glam",
      confidence: 0.9,
      evidence: "polished makeup with a focus on warm, radiant tones",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.88,
      evidence: "golden skin tones and harmony with peach/copper colors",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "proportional features with soft cheekbone definition",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_peach_glow",
    styleTagline: "Warm Peach Radiance for a Polished Everyday Look",
    keywords: [
      "dewy skin tint",
      "peach shimmer lids",
      "brown lifting mascara",
      "soft arched brow",
      "cream apricot blush",
      "high-shine peach gloss"
    ],
    whyItWorks:
        "The warm peach and copper tones beautifully complement your brown eyes and warm undertone. This monochromatic approach creates a harmonious, healthy glow that looks effortless.",
    startWithTip:
        "Start with a hydrating primer and a sheer skin tint, then apply a wash of peach shadow over the entire lid for an instant brightening effect.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "soft peach makeup tutorial for warm skin",
      "monochromatic apricot makeup look",
      "glowy everyday makeup for beginners"
    ],
    copyableSearchPhrase: "soft peach glow makeup tutorial natural warm look",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["weekend_brunch", "daily_commute", "casual_hangout"],
    occasionNotes:
        "This fresh, radiant look is perfect for daytime social events and professional settings where you want to look awake and approachable.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear visibility of all facial features.",
  ),
);
