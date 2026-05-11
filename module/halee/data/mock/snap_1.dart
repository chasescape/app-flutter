import '../models/snap_analysis.dart';
import 'package:halee/gen_a/A.dart';

final snapData1 = SnapAnalysis(
  assetImg: A.assets_halee_1,
  sceneCard: SceneCard(
    subjectType: SceneDimension(value: 'Nature', confidence: 0.95, evidence: 'Purple globe-shaped flower featured prominently on the smartphone screen.'),
    scene: SceneDimension(value: 'Nature', confidence: 0.98, evidence: 'Lush green garden foliage and trees in the background.'),
    lighting: SceneDimension(value: 'Golden Hour', confidence: 0.99, evidence: 'Warm orange sun flare and soft, directional light casting a glow.'),
    composition: SceneDimension(value: 'Center Framed', confidence: 0.92, evidence: 'The smartphone and the flower within it are both centered in the frame.'),
    colorTone: SceneDimension(value: 'Warm', confidence: 0.95, evidence: 'Golden sunlight highlights and vibrant green and purple hues.'),
    atmosphere: SceneDimension(value: 'Fresh', confidence: 0.88, evidence: 'Bright, clean outdoor setting with blooming flora.'),
  ),
  diagnosis: Diagnosis(
    oneLineSummary: 'This is a wonderful \'meta\' shot that captures the magic of golden hour and the beauty of nature through a lens.',
    strengths: ['Excellent capture of backlighting and lens flare', 'Sharp focus on the digital subject', 'Strong color contrast between the purple flower and green backdrop'],
    topImprovement: 'Try moving the subject off-center to create a more dynamic composition using the grid lines visible on your screen.',
  ),
  improvementTips: [
    ImprovementTip(
      category: 'Composition',
      title: 'Apply the Rule of Thirds',
      action: 'Shift your camera slightly so the flower sits at one of the four intersections of the grid lines rather than the dead center.',
      expectedResult: 'Creates a more balanced and professional feel that allows the eye to wander through the garden scene.',
    ),
    ImprovementTip(
      category: 'Angle & Perspective',
      title: 'Lower your perspective',
      action: 'Crouch down so your camera lens is at the same height as the flower\'s bloom.',
      expectedResult: 'Creates a more intimate connection with the subject and makes the flower feel more prominent against the sky.',
    ),
    ImprovementTip(
      category: 'Background',
      title: 'Simplify the backdrop',
      action: 'Move slightly to the left or right to find a background area with fewer distracting bright spots of light.',
      expectedResult: 'Reduces visual \'noise\' and makes the purple of the flower pop even more intensely.',
    ),
  ],
  creativeVariants: [
    CreativeVariant(
      style: 'Macro',
      description: 'An extreme close-up focusing on the individual tiny petals and the texture of the flower head.',
      executionTip: 'Move your phone as close as possible while maintaining focus, and use a tripod if available to avoid blur.',
    ),
    CreativeVariant(
      style: 'Silhouette',
      description: 'A dramatic shot where the flower becomes a dark, sharp outline against the bright sun.',
      executionTip: 'Position the flower directly in front of the sun and tap the brightest part of the screen to lower the exposure.',
    ),
    CreativeVariant(
      style: 'Vintage Film',
      description: 'A nostalgic version with muted greens and a slight warm haze to emphasize the sunset mood.',
      executionTip: 'Slightly overexpose the shot and look for a \'warm\' or \'sepia\' filter to mimic old-school film stock.',
    ),
  ],
  funFact: 'The \'starburst\' effect from the sun is caused by light diffracting through the small aperture of your lens—keeping your lens perfectly clean helps make those rays look sharp and clear!',
  shareCaption: 'Chasing the golden hour glow. 🌻✨ There’s nothing like that perfect afternoon light to make nature\'s colors sing!',
  tags: ['#naturephotography', '#goldenhour', '#flowerstagram', '#shotonmobile', '#photographytips', '#gardenlife', '#sunflare'],
  safety: SafetyInfo(
    hasSensitiveContent: false,
    notes: 'The image contains a hand, but no identifiable faces or sensitive personal information are present.',
  ),
);
