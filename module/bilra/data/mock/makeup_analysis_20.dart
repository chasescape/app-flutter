import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis20 = MakeupAnalysis(
  assetImg: A.assets_bilra_20,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "natural",
      confidence: 0.95,
      evidence:
          "Clear eye shape with naturally defined lashes and visible lid space.",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.92,
      evidence: "Well-defined lip border with a healthy natural pink tone.",
    ),
    overallVibe: OverallVibe(
      value: "defined_polished",
      confidence: 0.88,
      evidence:
          "Bright, even lighting and professional attire suggest a structured yet approachable look.",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.85,
      evidence:
          "Skin tone shows a balanced mix of warm and cool tones under natural light.",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence:
          "Symmetrical features with well-proportioned forehead, cheekbones, and jawline.",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "polished_natural",
    styleTagline: "Polished Natural Look for Professional Confidence",
    keywords: [
      "satin finish foundation",
      "softly defined arched brows",
      "champagne shimmer lid",
      "thin chocolate brown eyeliner",
      "dusty rose cream blush",
      "satin mauve lip tint"
    ],
    whyItWorks:
        "Your balanced features and neutral undertone are perfectly suited for a structured, polished look. This style enhances your natural symmetry while maintaining a professional and sophisticated edge.",
    startWithTip:
        "Focus on a clean, satin base first, then define your brows to frame your eyes before adding soft rosy tones to your cheeks and lips.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "professional office makeup tutorial natural",
      "polished everyday makeup for balanced face features"
    ],
    copyableSearchPhrase: "how to do a polished natural makeup look for work",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["office_work", "daily_commute", "weekend_brunch"],
    occasionNotes:
        "This look is ideal for professional settings where you want to look put-together yet effortless.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and clear front-facing angle make for a highly accurate analysis.",
  ),
);
