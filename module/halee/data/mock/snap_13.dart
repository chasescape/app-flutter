import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData13 = SnapAnalysis(
  assetImg: A.assets_halee_13,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Still Life', confidence: 0.95, evidence: 'camera lenses, instant photos, and a cup of tea arranged on a marble surface'),
    scene: SceneDimension(value: 'Indoor', confidence: 0.9, evidence: 'marble tabletop with a notebook and household items'),
    lighting: SceneDimension(value: 'Natural Hard', confidence: 0.9, evidence: 'strong, high-contrast shadows cast by bright sunlight from a window'),
    composition: SceneDimension(value: 'Diagonal', confidence: 0.85, evidence: 'elements are arranged along a diagonal axis from the top-left toward the bottom-right'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.9, evidence: 'golden sunlight, amber tea, and warm tones in the instant photos'),
    atmosphere: SceneDimension(value: 'Cozy', confidence: 0.85, evidence: 'the combination of steaming tea, handwritten notes, and personal photos creates a warm, reflective mood'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'A beautifully lit and creative flat lay that tells a story about the photographer\'s process and memories.',
    strengths: ['Excellent use of hard shadows to add three-dimensional depth to a flat surface', 'Strong storytelling through the variety of personal and professional objects', 'Inviting warm color palette that feels natural and authentic'],
    topImprovement: 'The composition is quite busy; simplifying the arrangement would help the main lens stand out more effectively.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Try a direct top-down view',
      action: 'Stand directly over the table and hold your phone perfectly level with the surface for a true \'flat lay\' perspective.',
      expectedResult: 'Produces a more graphic, organized, and modern look that emphasizes the shapes of the objects.',
    ),
    ImprovementTip(
      category: 'Lighting',
      title: 'Bounce some light into the shadows',
      action: 'Hold a white piece of paper or a small mirror just off-camera on the right side to reflect light back into the dark shadows.',
      expectedResult: 'Softens the harshness of the shadows while still keeping the dramatic feel of the sunlight.',
    ),
    ImprovementTip(
      category: 'Composition',
      title: 'Clear some breathing room',
      action: 'Remove two or three of the photos and the extra lens cap to create more \'negative space\' around the central lens.',
      expectedResult: 'Reduces visual clutter and allows the viewer\'s eye to focus immediately on your main subject.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Minimalist',
      description: 'A single lens and one photo placed on a clean area of the marble with plenty of white space.',
      executionTip: 'Focus on the relationship between just two objects to create a clean, high-end look.',
    ),
    CreativeVariant(
      style: 'Vintage Film',
      description: 'A nostalgic edit with muted colors, lower contrast, and a bit of added film grain.',
      executionTip: 'Slightly desaturate the greens and blues while keeping the warm highlights to mimic old film stock.',
    ),
    CreativeVariant(
      style: 'Macro',
      description: 'An extreme close-up focusing only on the steam rising from the tea or the glass of the lens.',
      executionTip: 'Get as close as possible and use a shallow depth of field to blur everything but the fine details.',
    ),
  ],
  funFact: 'Shadows are just as important as light! In still life photography, \'hard\' shadows like these are often used to define the texture and shape of objects that might otherwise look flat.',
  shareCaption: 'Morning light and memories. ☕️📸 Planning the next adventure over a cup of tea. #NextSnap',
  tags: ['photography', 'flatlay', 'stilllife', 'cameragear', 'cozyvibes', 'creativeprocess', 'naturallight', 'storytelling'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: 'The small instant photos contain people, but they are artistic representations and not identifiable as specific individuals.',
  ),
);
