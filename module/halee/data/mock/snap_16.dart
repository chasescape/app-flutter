import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData16 = SnapAnalysis(
  assetImg: A.assets_halee_16,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Street', confidence: 0.95, evidence: 'narrow alleyway with a lone figure walking away'),
    scene: SceneDimension(value: 'Urban', confidence: 0.98, evidence: 'brick buildings, paved path, and fire escapes'),
    lighting: SceneDimension(value: 'Overcast', confidence: 0.85, evidence: 'soft, diffused light from above with minimal harsh shadows'),
    composition: SceneDimension(value: 'Leading Lines', confidence: 0.95, evidence: 'the pavement tiles and building walls converge toward the center'),
    colorTone: SceneDimension(value: 'Dark & Moody', confidence: 0.9, evidence: 'sepia-toned palette with deep shadows and muted highlights'),
    atmosphere: SceneDimension(value: 'Mysterious', confidence: 0.85, evidence: 'narrow perspective and a solitary figure creating a sense of solitude'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'A striking urban shot that uses powerful leading lines to draw the eye through a moody, historic-feeling alleyway.',
    strengths: ['Excellent use of vertical lines to create a sense of scale', 'Consistent warm, earthy color palette', 'Perfect central alignment of the pathway'],
    topImprovement: 'The subject is currently a bit far away; bringing them closer would create a more compelling focal point.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Subject Placement',
      title: 'Bring the subject closer',
      action: 'Wait for a person to walk into the lower third of the frame before snapping the shutter.',
      expectedResult: 'Creates a stronger emotional connection and a clearer focal point for the viewer.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your camera height',
      action: 'Crouch down and hold your phone closer to the ground, tilting it slightly upward.',
      expectedResult: 'Exaggerates the height of the buildings and makes the leading lines on the pavement feel more immersive.',
    ),
    ImprovementTip(
      category: 'Timing',
      title: 'Chase the shadows',
      action: 'Return to this spot during the early morning or late afternoon when the sun is low enough to hit one side of the alley.',
      expectedResult: 'Adds high-contrast texture to the brickwork and creates more depth through shadow play.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Symmetrical',
      description: 'A perfectly balanced shot where the left and right sides of the alley mirror each other exactly.',
      executionTip: 'Use your camera\'s grid lines to ensure the center line of the pavement is perfectly vertical and centered.',
    ),
    CreativeVariant(
      style: 'Cinematic',
      description: 'A wide-screen perspective that looks like a still from a gritty urban drama.',
      executionTip: 'Crop the image to a 16:9 or 2.35:1 aspect ratio and deepen the blacks in your editor.',
    ),
    CreativeVariant(
      style: 'Minimalist',
      description: 'A focus on the geometric patterns and textures of the brickwork without any human presence.',
      executionTip: 'Wait for the alley to be completely empty and focus on the repeating patterns of the windows.',
    ),
  ],
  funFact: 'This \'urban canyon\' effect is a favorite of street photographers because the narrow walls naturally act as a \'frame within a frame,\' focusing all attention on the center.',
  shareCaption: 'Lost in the rhythm of the city. 🏙️ Sometimes the best path is the one that narrows.',
  tags: ['streetphotography', 'urbanexplorer', 'leadinglines', 'cityscape', 'moodygrams', 'architecture', 'alleyway'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: 'The person in the distance is unrecognizable and no sensitive details are visible.',
  ),
);
