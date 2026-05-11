import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData17 = SnapAnalysis(
  assetImg: A.assets_halee_17,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Architecture', confidence: 0.98, evidence: 'multi-story modern building interior with glass and steel structure'),
    scene: SceneDimension(value: 'Indoor', confidence: 0.99, evidence: 'atrium of a large office or commercial building'),
    lighting: SceneDimension(value: 'Natural Soft', confidence: 0.92, evidence: 'diffused daylight entering through extensive glass windows and ceiling'),
    composition: SceneDimension(value: 'Symmetrical', confidence: 0.97, evidence: 'central vertical axis with repeating floors on both sides'),
    colorTone: SceneDimension(value: 'Cool', confidence: 0.95, evidence: 'predominance of blue, grey, and silver tones from glass and metal'),
    atmosphere: SceneDimension(value: 'Serene', confidence: 0.88, evidence: 'clean lines, balanced light, and empty, quiet space'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a beautifully balanced architectural shot that expertly captures the impressive scale and geometric rhythm of the atrium.',
    strengths: ['Perfectly executed vertical symmetry', 'Clean and consistent cool color palette', 'Excellent handling of diffused light across all levels'],
    topImprovement: 'Add a human element or a specific focal point to provide a sense of scale and a narrative touch to the empty space.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Subject Placement',
      title: 'Introduce a focal point',
      action: 'Wait for a person to walk across one of the middle bridges or stand near the center of the ground floor before taking the shot.',
      expectedResult: 'Provides a sense of scale and creates a \'hero\' for the viewer\'s eye to land on amidst the geometry.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Try a worm\'s eye view',
      action: 'Move to the very center of the ground floor, crouch down low, and point your lens directly up toward the roof peak.',
      expectedResult: 'Creates an abstract, kaleidoscopic pattern that emphasizes the verticality of the architecture.',
    ),
    ImprovementTip(
      category: 'Timing',
      title: 'Shoot during Blue Hour',
      action: 'Return to this spot about 20 minutes after sunset when the sky outside is deep blue and the interior warm lights are turned on.',
      expectedResult: 'Creates a stunning color contrast between the cool exterior light and the warm interior glow.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Minimalist',
      description: 'A tight, abstract crop focusing only on the repeating patterns of the windows and steel beams.',
      executionTip: 'Zoom in significantly to remove the floor and ceiling, focusing purely on the rhythm of the lines.',
    ),
    CreativeVariant(
      style: 'Motion Blur',
      description: 'The static building remains tack-sharp while people moving through the atrium become ghostly, ethereal streaks.',
      executionTip: 'Rest your phone on the railing to keep it steady and use a long-exposure mode (2-5 seconds) while people are walking.',
    ),
    CreativeVariant(
      style: 'Symmetrical',
      description: 'A high-contrast black and white edit that strips away color to emphasize the raw structure and shadows.',
      executionTip: 'Convert to monochrome and boost the \'Clarity\' or \'Contrast\' to make the metallic edges pop.',
    ),
  ],
  funFact: 'The human brain is naturally drawn to symmetry because it signals order and stability—which is why architectural photos like this feel so satisfying to look at!',
  shareCaption: 'Finding the perfect balance in the heart of the city. 🏙️✨ Geometry and glass never looked so peaceful.',
  tags: ['architecture', 'symmetry', 'interiordesign', 'minimalism', 'cityscape', 'geometry', 'nextsnap'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
