import 'package:bilra/gen_a/A.dart';

import '../models/makeup_analysis.dart';

final makeupAnalysis8 = MakeupAnalysis(
  assetImg: A.assets_bilra_8,
  faceAnalysis: FaceAnalysis(
    eyePresence: EyePresence(
      value: "defined",
      confidence: 0.95,
      evidence: "Clearly defined lash line and well-groomed, arched brows.",
    ),
    lipPresence: LipPresence(
      value: "natural",
      confidence: 0.9,
      evidence: "Satin-finish lip color in a natural rose shade is visible.",
    ),
    overallVibe: OverallVibe(
      value: "defined_polished",
      confidence: 0.92,
      evidence: "Clean, even complexion with intentional feature enhancement.",
    ),
    skinUndertone: SkinUndertone(
      value: "neutral",
      confidence: 0.85,
      evidence:
          "Balanced skin tone that works well with both cool and warm accents.",
    ),
    faceStructure: FaceStructure(
      value: "balanced",
      confidence: 0.9,
      evidence: "Symmetrical features with clear, soft definition.",
    ),
  ),
  makeupRecommendation: MakeupRecommendation(
    primaryStyle: "muted_rose_vibes",
    styleTagline: "Muted Rose Elegance for a Polished Glow",
    keywords: [
      "satin skin finish",
      "defined lash line",
      "arched groomed brows",
      "soft rose blush",
      "muted berry lip",
      "champagne highlight",
      "neutral eyeshadow transition"
    ],
    whyItWorks:
        "Your balanced features and neutral undertone are perfectly complemented by monochromatic rose and berry tones. This enhances your natural depth without looking heavy.",
    startWithTip:
        "Focus on a seamless satin base and grooming your brows to their natural arch before adding the soft rose tones.",
  ),
  searchGuidance: SearchGuidance(
    tutorialSearchTerms: [
      "muted rose makeup tutorial for neutral skin",
      "polished natural everyday makeup look"
    ],
    copyableSearchPhrase:
        "muted rose natural makeup tutorial for a polished daily look",
    recommendedPlatforms: ["YouTube", "Xiaohongshu", "Instagram"],
  ),
  occasionMatch: OccasionMatch(
    suitableOccasions: ["office_work", "weekend_brunch", "daily_commute"],
    occasionNotes:
        "This sophisticated yet approachable look is ideal for professional settings or social daytime events.",
  ),
  qualityCheck: QualityCheck(
    isAnalyzable: true,
    retryReason: "",
    imageQualityNotes:
        "Excellent lighting and high-resolution detail of facial features.",
  ),
);
