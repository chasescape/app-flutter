import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis2 = MakeupAnalysis(
  assetImg: A.assets_bilra_2,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "defined",
      confidence: 0.92,
      evidence: "clear eye shape with defined lash line and neutral shadow",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.88,
      evidence: "soft nude-pink satin finish visible",
    ),
    overallVibe: OverallVibe(
      value: "defined_polished",
      confidence: 0.95,
      evidence: "professional studio lighting and even, radiant complexion",
    ),
    skinUndertone: SkinUndertone(
      value: "warm",
      confidence: 0.85,
      evidence: "golden and honey tones visible in the skin and hair",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "well-proportioned features with a soft, rounded jawline",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "polished_natural",
    styleTagline: "Polished Natural Glow for On-Camera Radiance",
    keywords: [
      "dewy radiant base",
      "soft brown wing",
      "defined natural brow",
      "warm peach blush",
      "nude satin lip",
      "champagne inner corner highlight"
    ],
    whyItWorks:
        "Your balanced features and warm undertone are perfectly complemented by soft, warm tones. This style provides the necessary definition for high-quality video while maintaining a fresh, approachable look.",
    startWithTip:
        "Start with a glowy primer and medium-coverage foundation, then define your brows to provide a structured frame for the eyes.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "natural glam makeup for content creators",
      "polished everyday makeup for warm skin"
    ],
    copyableSearchPhrase:
        "polished natural makeup tutorial for camera and video",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["content_shooting", "office_work", "special_event"],
    occasionNotes:
        "This look is ideal for professional environments or when you need to look put-together for the camera.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent studio lighting and clear front-facing angle allow for high-confidence analysis.",
  ),
);
