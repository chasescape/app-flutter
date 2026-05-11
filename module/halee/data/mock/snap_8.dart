import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData8 = SnapAnalysis(
  assetImg: A.assets_halee_8,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Architecture', confidence: 0.95, evidence: 'Interior living room space with furniture and wall decor'),
    scene: SceneDimension(value: 'Home', confidence: 0.98, evidence: 'Sofa, coffee table, rug, and residential lighting fixtures'),
    lighting: SceneDimension(value: 'Mixed', confidence: 0.9, evidence: 'Comparison shows both low artificial light and bright natural soft light'),
    composition: SceneDimension(value: 'Symmetrical', confidence: 0.85, evidence: 'Vertical split-screen dividing the before and after states'),
    colorTone: SceneDimension(value: 'High Contrast', confidence: 0.92, evidence: 'Sharp transition from dark, moody tones to bright, airy greens and creams'),
    atmosphere: SceneDimension(value: 'Fresh', confidence: 0.88, evidence: 'The \'After\' side uses light colors and greenery to create a clean feel'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a brilliant side-by-side comparison that demonstrates how natural light and intentional staging can completely transform a room\'s energy.',
    strengths: ['Excellent use of the split-screen to tell a transformation story', 'The \'After\' shot uses a cohesive color palette that feels professional', 'Smart placement of plants to add life and texture'],
    topImprovement: 'For your next shot, try to hide the power cables in the \'Before\' side to keep the focus entirely on the spatial change.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Lighting',
      title: 'Harness window light',
      action: 'Place your subject near a large window and use a white sheet to diffuse the light if it\'s too harsh.',
      expectedResult: 'Produces a soft, commercial-grade glow that eliminates unflattering shadows.',
    ),
    ImprovementTip(
      category: 'Background',
      title: 'Clear the floor path',
      action: 'Physically remove all loose cables, stray papers, and floor clutter before pressing the shutter.',
      expectedResult: 'Prevents the viewer\'s eye from being distracted by \'visual noise\' in the foreground.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Level the camera',
      action: 'Crouch down so the camera lens is at roughly the height of the sofa backrest.',
      expectedResult: 'Keeps vertical lines straight and makes the room feel more architecturally balanced.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Cinematic',
      description: 'A moody evening version of the room using only the warm glow of the brass lamps.',
      executionTip: 'Turn off all ceiling lights and use a tripod to capture a long exposure of the lamp light.',
    ),
    CreativeVariant(
      style: 'Minimalist',
      description: 'A focused close-up on just the coffee table setup with the rug texture underneath.',
      executionTip: 'Shoot from directly above (flat lay style) to emphasize the geometric shapes of the table and book.',
    ),
    CreativeVariant(
      style: 'Vintage Film',
      description: 'A nostalgic look with muted greens and a slight grain to match the retro furniture vibe.',
      executionTip: 'Slightly overexpose the image and reduce the contrast in post-processing for a faded look.',
    ),
  ],
  funFact: 'Interior photographers often use \'the blue hour\'—just after sunset—to balance warm indoor lights with the cool blue light from windows for a magical glow.',
  shareCaption: 'Proof that every space has a story waiting to be told. ✨ From cluttered to calm with just a bit of light! #HomeTransformation',
  tags: ['#interiordesign', '#homemakeover', '#lightingdesign', '#photographytricks', '#beforeandafter', '#nextsnap', '#homedecor'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: 'No people or sensitive personal identifiers detected.',
  ),
);
