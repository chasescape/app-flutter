import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis17 = MakeupAnalysis(
  assetImg: A.assets_bilra_17,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.95,
      evidence: "clear eye shape with naturally defined lashes and lids",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence: "well-defined lip borders and soft natural pigment",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "bright natural lighting and even, radiant complexion",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.85,
      evidence: "visible golden and peachy tones in the skin",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "symmetrical and well-proportioned facial features",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_peach_glow",
    styleTagline: "Soft Peach Glow for Radiant Natural Beauty",
    keywords: [
      "dewy skin base",
      "natural arched brows",
      "peach cream blush",
      "soft brown mascara",
      "nude glossy lip",
      "subtle inner corner highlight"
    ],
    whyItWorks:
        "Your balanced features and warm undertone are perfectly complemented by soft, warm tones. This style enhances your natural radiance while keeping the look light and breathable.",
    startWithTip:
        "Start with a hydrating primer and a light-coverage foundation, then focus on grooming your brows to frame your face.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "natural peach makeup tutorial for beginners",
      "clean girl aesthetic makeup warm skin"
    ],
    copyableSearchPhrase: "soft peach glow makeup tutorial for warm skin tones",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["daily_commute", "weekend_brunch", "casual_hangout"],
    occasionNotes:
        "This fresh, glowing look is perfect for daytime activities where you want to look polished but effortless.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear visibility of facial features.",
  ),
);
