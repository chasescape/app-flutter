import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis11 = MakeupAnalysis(
  assetImg: A.assets_bilra_11,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.92,
      evidence: "clear eye shape with subtle natural definition",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence: "soft pinkish-mauve tone visible",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "natural lighting and polished, harmonious features",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.85,
      evidence: "balanced skin tone under warm natural light",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "well-proportioned and symmetrical facial features",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "muted_rose_vibes",
    styleTagline: "Muted Rose Radiance for a Sophisticated Glow",
    keywords: [
      "dewy skin finish",
      "dusty rose eyeshadow",
      "soft brown wing liner",
      "mauve lip tint",
      "cream blush in rosewood",
      "natural feathered brows"
    ],
    whyItWorks:
        "The muted rose tones harmonize perfectly with your neutral undertone and the soft, balanced nature of your features, enhancing your natural elegance.",
    startWithTip:
        "Start with a hydrating primer and a light-coverage dewy base, then blend a soft rose shadow across the lids for effortless depth.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "muted rose makeup tutorial for beginners",
      "soft glam mauve makeup look everyday"
    ],
    copyableSearchPhrase:
        "muted rose soft glam makeup tutorial for a natural glow",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["weekend_brunch", "office_work", "casual_hangout"],
    occasionNotes:
        "This polished yet effortless look is ideal for chic daytime settings and professional environments.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear front-facing angle for accurate feature analysis.",
  ),
);
