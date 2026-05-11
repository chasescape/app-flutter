import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData10 = SnapAnalysis(
  assetImg: A.assets_halee_10,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Food', confidence: 0.98, evidence: 'Plated salmon with asparagus and tomatoes, surrounded by salads and wine.'),
    scene: SceneDimension(value: 'Cafe', confidence: 0.92, evidence: 'Formal table setting with white linen, multiple courses, and glassware.'),
    lighting: SceneDimension(value: 'Artificial Warm', confidence: 0.88, evidence: 'Soft, warm highlights on the food surfaces and gentle shadows.'),
    composition: SceneDimension(value: 'Layered', confidence: 0.9, evidence: 'Multiple plates arranged at different depths from the foreground to the background.'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.95, evidence: 'Rich oranges, reds, and warm whites dominate the palette.'),
    atmosphere: SceneDimension(value: 'Cozy', confidence: 0.85, evidence: 'Inviting and abundant arrangement suggesting a pleasant dining experience.'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a fantastic capture that uses depth of field perfectly to make the main salmon dish stand out as the hero.',
    strengths: ['Excellent use of shallow depth of field to guide the viewer\'s eye', 'Vibrant and appetizing color balance', 'Professional-looking arrangement that feels abundant yet organized'],
    topImprovement: 'Try a slightly lower camera angle to emphasize the height and texture of the salmon fillet.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your perspective',
      action: 'Crouch down so the camera is more level with the plate rather than looking down from above.',
      expectedResult: 'Creates a more \'heroic\' look for the food and reveals the crispy texture of the seared salmon skin.',
    ),
    ImprovementTip(
      category: 'Composition',
      title: 'Shift the main subject',
      action: 'Move the main salmon plate slightly to the left or right of the center frame.',
      expectedResult: 'Creates a more dynamic, less \'static\' composition that feels more professional.',
    ),
    ImprovementTip(
      category: 'Lighting',
      title: 'Use a simple reflector',
      action: 'Hold a white napkin or menu just out of frame on the left side to bounce light back into the shadows.',
      expectedResult: 'Reveals more hidden detail in the darker areas of the asparagus and tomatoes.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Minimalist',
      description: 'A single plate centered on a clean table with all other dishes removed.',
      executionTip: 'Clear the background entirely to focus 100% on the shapes and colors of the main dish.',
    ),
    CreativeVariant(
      style: 'Storytelling',
      description: 'A shot captured while someone is actively pouring wine or lifting a fork.',
      executionTip: 'Use a faster shutter speed to freeze the motion and add a human element to the scene.',
    ),
    CreativeVariant(
      style: 'Macro',
      description: 'An extreme close-up focusing purely on the texture of the salmon and the glaze.',
      executionTip: 'Move in as close as possible to fill the frame with just a 2-inch section of the food.',
    ),
  ],
  funFact: 'In professional food photography, the \'hero\' is the main dish being photographed, while \'stand-ins\' are used to set up lighting so the real food stays fresh!',
  shareCaption: 'Table for one, or a feast for all? 🍽️ This salmon is almost too pretty to eat (almost!). #NextSnapEats',
  tags: ['foodphotography', 'salmon', 'finedining', 'foodstyling', 'gastronomy', 'healthyplating', 'restaurantlife'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
