import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis16 = MakeupAnalysis(
  assetImg: A.assets_bilra_16,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.95,
      evidence:
          "clear eye shape with naturally defined lashes and warm brown iris",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence: "natural lip definition and soft pink-peach tone visible",
    ),
    overallVibe: OverallVibe(
      value: "light_and_fresh",
      confidence: 0.95,
      evidence: "radiant skin texture and bright, even natural lighting",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.85,
      evidence: "golden and peachy hues present in the skin tone",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "harmonious proportions between eyes, nose, and lips",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "soft_peach_glow",
    styleTagline: "Soft Peach Glow for Everyday Radiance",
    keywords: [
      "dewy skin base",
      "feathered natural brows",
      "peach monochrome lids",
      "brown tubing mascara",
      "warm apricot blush",
      "sheer coral lip oil"
    ],
    whyItWorks:
        "Your warm skin undertone and balanced features are perfectly complemented by monochromatic peach tones. This style enhances your natural radiance without overpowering your delicate features.",
    startWithTip:
        "Start by grooming your brows with a clear gel and applying a lightweight skin tint for a dewy foundation.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "soft peach makeup tutorial for beginners",
      "clean girl makeup warm undertone"
    ],
    copyableSearchPhrase:
        "natural soft peach glow makeup tutorial for warm skin tones",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["daily_commute", "weekend_brunch", "casual_hangout"],
    occasionNotes:
        "This effortless look is ideal for daytime settings where a fresh, approachable vibe is desired.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear, high-resolution focus on facial features.",
  ),
);
