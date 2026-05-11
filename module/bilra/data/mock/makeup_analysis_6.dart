import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis6 = MakeupAnalysis(
  assetImg: A.assets_bilra_6,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "defined",
      confidence: 0.95,
      evidence:
          "visible winged eyeliner and lash definition with warm bronze eyeshadow",
    ),
    lipPresence: LipPresence(
      value: "bold",
      confidence: 0.98,
      evidence: "rich berry-toned lip color with clear definition",
    ),
    overallVibe: OverallVibe(
      value: "soft_glam",
      confidence: 0.92,
      evidence:
          "polished evening look with luminous skin and coordinated colors",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.88,
      evidence: "golden-tan complexion enhanced by warm ambient lighting",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence:
          "symmetrical features with well-proportioned cheekbones and jawline",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_glam_even",
    styleTagline: "Elegant Berry Glam for Evening Sophistication",
    keywords: [
      "luminous dewy base",
      "sculpted brows",
      "warm bronze eyeshadow",
      "subtle winged liner",
      "deep berry matte lip",
      "champagne cheek highlight"
    ],
    whyItWorks:
        "The deep berry lip provides a stunning contrast against your warm skin tone, while the soft eye definition ensures the look remains balanced and sophisticated for evening lighting.",
    startWithTip:
        "Start with a glowy primer and structured brow, then focus on a clean winged liner before finishing with the bold lip.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "berry lip date night makeup tutorial",
      "soft glam evening makeup for warm skin"
    ],
    copyableSearchPhrase:
        "soft glam evening makeup tutorial berry lips warm skin",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["date_night", "special_event"],
    occasionNotes:
        "This look is ideal for romantic dinners or upscale evening events where a polished, radiant presence is desired.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear front-facing angle allow for high-confidence feature analysis.",
  ),
);
