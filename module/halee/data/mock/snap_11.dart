import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData11 = SnapAnalysis(
  assetImg: A.assets_halee_11,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Street', confidence: 0.95, evidence: 'crowded outdoor market with vendors and customers'),
    scene: SceneDimension(value: 'Outdoor', confidence: 0.98, evidence: 'open air market stalls and city buildings in background'),
    lighting: SceneDimension(value: 'Natural Soft', confidence: 0.9, evidence: 'warm diffused sunlight from the upper left with gentle shadows'),
    composition: SceneDimension(value: 'Leading Lines', confidence: 0.85, evidence: 'the row of market stalls creates a diagonal line leading into the frame'),
    colorTone: SceneDimension(value: 'Vibrant', confidence: 0.95, evidence: 'saturated reds, yellows, and greens from the produce and awnings'),
    atmosphere: SceneDimension(value: 'Energetic', confidence: 0.9, evidence: 'busy crowd and active commerce create a lively feel'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a wonderful, high-energy shot that perfectly captures the vibrant atmosphere of a local market.',
    strengths: ['Excellent use of color to draw the eye', 'Great sense of depth and perspective'],
    topImprovement: 'Identify a single subject or interaction to act as a clear focal point within the busy scene.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your perspective',
      action: 'Crouch down so your camera is level with the produce on the tables.',
      expectedResult: 'This creates a more immersive feel, making the viewer feel like they are right in the middle of the market.',
    ),
    ImprovementTip(
      category: 'Subject Placement',
      title: 'Capture a human moment',
      action: 'Wait for a specific interaction, like a vendor handing a bag to a customer, and center that action in your frame.',
      expectedResult: 'Adds a storytelling element that grounds the busy environment with a relatable human connection.',
    ),
    ImprovementTip(
      category: 'Framing',
      title: 'Use the awnings to frame',
      action: 'Step back slightly and use the edge of a yellow or red awning to create a natural border at the top of your shot.',
      expectedResult: 'Helps contain the energy of the photo and directs the viewer\'s eye toward the people below.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Documentary',
      description: 'A candid, wide-angle shot that captures the unposed reality of the market\'s morning rush.',
      executionTip: 'Keep your camera at chest level and use a wider lens to capture more of the surrounding environment.',
    ),
    CreativeVariant(
      style: 'Macro',
      description: 'An extreme close-up focusing purely on the textures and colors of the fresh produce.',
      executionTip: 'Move in very close to a pile of tomatoes or peppers to blur everything else into a wash of color.',
    ),
    CreativeVariant(
      style: 'Vintage Film',
      description: 'A nostalgic look with slightly muted tones and a warm, grainy texture.',
      executionTip: 'Look for older architectural details in the background and use a slightly warmer white balance setting.',
    ),
  ],
  funFact: 'In street photography, \'layers\' refer to having interest in the foreground, middle ground, and background—your shot does this beautifully!',
  shareCaption: 'Nothing beats the energy and colors of a morning market run! 🍎✨',
  tags: ['streetphotography', 'marketlife', 'freshproduce', 'cityvibes', 'colorfullife', 'nextsnap', 'travelgram'],
  safety: SafetyInfo(
    hasSensitiveContent: true,
    notes: 'Multiple recognizable faces of vendors and shoppers are visible; consider blurring faces for public sharing.',
  ),
);
