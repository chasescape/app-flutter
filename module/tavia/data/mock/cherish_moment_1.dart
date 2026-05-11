import 'package:tavia/gen_a/A.dart';
import '../models/cherish_moment.dart';

/// Cherish moment data generated from image analysis
final cherish_moment_1 = CherishMoment(
  assetImg: A.assets_tavia_1,
  timeOfDay: SceneCard(
    value: "Morning",
    confidence: 0.9,
    evidence: r"""warm golden sunlight filtering through market tents""",
  ),
  sceneType: SceneCard(
    value: "Outdoor",
    confidence: 0.95,
    evidence: r"""open-air market stalls with canvas coverings""",
  ),
  mainSubject: SceneCard(
    value: "Food",
    confidence: 0.98,
    evidence: r"""vibrant carrots and tomatoes arranged on a wooden table""",
  ),
  emotionalTone: SceneCard(
    value: "Warm",
    confidence: 0.85,
    evidence: r"""bright natural colors and soft, inviting lighting""",
  ),
  lightingQuality: SceneCard(
    value: "Warm Golden",
    confidence: 0.9,
    evidence: r"""low-angled sun creating a golden glow over the fresh produce""",
  ),
  oneLineMoment: r"""The simple abundance of a sun-drenched morning market.""",
  visualElements: ["fresh carrots", "bright red tomatoes", "market stalls", "golden sunlight", "leafy greens", "wooden table"],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: r"""""",
  ),
  essay: CherishEssay(
    opening: r"""There is a quiet vibrancy in the morning market that feels both energetic and peaceful. The sun catches the bright orange of the carrots and the deep red of the tomatoes, turning a simple wooden stall into a stunning display of natural art. Everything feels incredibly fresh and full of promise in this soft, golden light.""",
    feeling: r"""In the gentle bustle of a local market, you find a moment of grounding connection to the world around you. Seeing the earth's bounty spread out like this reminds us of the simple, beautiful cycles of life. It is more than just a place to shop; it is a sensory experience that links us back to the seasons and the land.""",
    gratitude: r"""We can be deeply thankful for these moments of abundance and the hardworking hands that brought this harvest to us. These colorful displays are a gentle reminder that nourishment is a gift to be cherished. Today, you found a beautiful reason to pause and appreciate the day's start.""",
  ),
  moodTags: ["#marketmorning", "#freshabundance", "#simplejoys", "#earthsbounty", "#morningwarmth"],
  visualStyleRecommendation: "Warm Beige",
  shareableCaption: r"""Waking up with the colors of the earth. A gentle start at the local market.""",
  cardTitle: r"""Morning Market Abundance""",
);