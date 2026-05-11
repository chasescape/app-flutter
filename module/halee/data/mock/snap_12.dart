import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData12 = SnapAnalysis(
  assetImg: A.assets_halee_12,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Still Life', confidence: 0.95, evidence: 'a single coffee cup resting on a table'),
    scene: SceneDimension(value: 'Home', confidence: 0.85, evidence: 'wooden furniture and soft window light suggesting an indoor living space'),
    lighting: SceneDimension(value: 'Side Lit', confidence: 0.98, evidence: 'strong directional light from the left creating long shadows to the right'),
    composition: SceneDimension(value: 'Rule of Thirds', confidence: 0.9, evidence: 'the cup is positioned in the lower-right quadrant of the frame'),
    colorTone: SceneDimension(value: 'High Contrast', confidence: 0.92, evidence: 'sharp transition between bright highlights on the cup and deep shadows on the table'),
    atmosphere: SceneDimension(value: 'Cozy', confidence: 0.88, evidence: 'warm wood tones and the presence of a hot beverage'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'A striking minimalist shot that uses dramatic side lighting to turn a simple coffee cup into a compelling subject.',
    strengths: ['Excellent use of high-contrast natural light', 'Clean and uncluttered composition', 'Beautiful warm tones that feel inviting'],
    topImprovement: 'Try lowering your camera angle to eye-level with the cup to create a more intimate and \'heroic\' perspective.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your lens',
      action: 'Crouch down so the camera lens is level with the rim of the cup rather than looking down at it.',
      expectedResult: 'This makes the cup feel more prominent and allows you to see the surface of the coffee more clearly.',
    ),
    ImprovementTip(
      category: 'Foreground Interest',
      title: 'Add a storytelling element',
      action: 'Place a spoon or a small linen napkin partially in the bottom corner of the frame, slightly out of focus.',
      expectedResult: 'Adds a sense of depth and a \'lived-in\' narrative to the scene.',
    ),
    ImprovementTip(
      category: 'Lighting',
      title: 'Softly fill the shadows',
      action: 'Hold a white piece of paper just outside the right side of the frame to bounce some light back into the dark side of the cup.',
      expectedResult: 'Preserves the drama while revealing subtle textures in the shadowed ceramic.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Minimalist',
      description: 'A tighter crop focusing only on the rim of the cup where the light hits the liquid.',
      executionTip: 'Move closer and focus on the specular highlight on the edge of the coffee.',
    ),
    CreativeVariant(
      style: 'Cinematic',
      description: 'Capture the scene with visible steam rising against the dark background.',
      executionTip: 'Ensure the background is as dark as possible and use a slightly faster shutter speed to freeze the steam patterns.',
    ),
    CreativeVariant(
      style: 'Symmetrical',
      description: 'A perfectly centered, top-down \'flat lay\' view of the cup.',
      executionTip: 'Hold your phone directly over the center of the cup and use the grid overlay to ensure perfect alignment.',
    ),
  ],
  funFact: 'Side lighting is often called \'Rembrandt lighting\' in portraiture; it\'s perfect for still life because it emphasizes the three-dimensional form of objects.',
  shareCaption: 'Finding the art in the morning routine. ☕️✨',
  tags: ['coffeephotography', 'stilllife', 'naturallight', 'minimalism', 'cozyvibes', 'shadowplay', 'morningmood'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: '',
  ),
);
