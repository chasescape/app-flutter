import '../models/cherish_moment.dart';
import 'package:tavia/gen_a/A.dart';

/// Cherish moment data generated from image analysis
final cherish_moment_5 = CherishMoment(
  assetImg: A.assets_tavia_5,
  timeOfDay: SceneCard(
    value: "Afternoon",
    confidence: 0.9,
    evidence: r"""soft natural light entering through the window""",
  ),
  sceneType: SceneCard(
    value: "Home",
    confidence: 1.0,
    evidence: r"""armchair, indoor plants, and bookshelf""",
  ),
  mainSubject: SceneCard(
    value: "Pet",
    confidence: 1.0,
    evidence: r"""a tabby cat sleeping soundly on the chair""",
  ),
  emotionalTone: SceneCard(
    value: "Cozy",
    confidence: 0.95,
    evidence: r"""knitted blanket and peaceful sleeping animal""",
  ),
  lightingQuality: SceneCard(
    value: "Soft Diffused",
    confidence: 0.9,
    evidence: r"""gentle light filtered through curtains and window""",
  ),
  oneLineMoment: r"""A peaceful afternoon nap tucked away in a sunlit corner.""",
  visualElements: ["tabby cat", "knit blanket", "beige armchair", "potted plants", "soft window light"],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: r"""""",
  ),
  essay: CherishEssay(
    opening: r"""There is a gentle stillness in this sun-drenched corner. The soft light highlights the intricate patterns of the knit blanket and the peaceful form of a sleeping companion, creating a perfect sanctuary within the room.""",
    feeling: r"""In the quiet rhythm of a cat’s breath, there is a profound sense of safety and belonging. This scene invites you to slow down and notice the textures of comfort—the warmth of the fabric and the vibrant life of the plants nearby. It is a reminder that peace doesn't always need to be found far away.""",
    gratitude: r"""We often overlook the simple beauty of a quiet afternoon at home. Today, we can be grateful for these small pockets of serenity that recharge our spirits. These are the anchors of a well-lived day.""",
  ),
  moodTags: ["#cozyhome", "#catnap", "#simplejoys", "#serenity", "#afternoonlight"],
  visualStyleRecommendation: "Warm Beige",
  shareableCaption: r"""Finding peace in the stillness of home. A quiet afternoon moment to cherish.""",
  cardTitle: r"""The Soft Sanctuary of Home""",
);