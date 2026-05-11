import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis14 = MakeupAnalysis(
  assetImg: A.assets_bilra_14,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "unclear",
      confidence: 0.0,
      evidence: "no face detected in image",
    ),
    lipPresence: LipPresence(
      value: "unclear",
      confidence: 0.0,
      evidence: "no face detected in image",
    ),
    overallVibe: OverallVibe(
      value: "unclear",
      confidence: 0.0,
      evidence: "no face detected in image",
    ),
    skinUndertone: SkinUndertone(
      value: "unclear",
      confidence: 0.0,
      evidence: "no face detected in image",
    ),
    faceStructure: FaceStructure(
      value: "unclear",
      confidence: 0.0,
      evidence: "no face detected in image",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "clean_base_makeup",
    styleTagline: "Upload a selfie to get started",
    keywords: [],
    whyItWorks: "We couldn't find a face to analyze in this photo.",
    startWithTip:
        "Try taking a well-lit, front-facing selfie for personalized tips.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [],
    copyableSearchPhrase: "N/A",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: [],
    occasionNotes: "Please provide a selfie to see occasion-specific matches.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: false,
    retryReason: "no face detected",
    imageQualityNotes:
        "The image shows makeup products and tools, but no human face is visible for analysis.",
  ),
);
